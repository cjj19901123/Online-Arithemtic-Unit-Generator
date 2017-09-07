% create toplevel vhdl file from input expresssion
function Create_oa_topLevel(name, expression, radix, precisionBit)
    
    onlineMultDelay = 3;
    onlineDivDelay = 4;
    
    [prefixExp, doutName, addBuffer, multBuffer, divBuffer, constantBuffer, totalOnlineDelay, delayUnitBuffer, maxRstDelay] = ExpressionParser(expression);

    FileName = name;
    FileID = fopen([FileName '.vhd'], 'w');
    
    toplevel = VHDLParsorClass;
    toplevel.FileName = FileName;
    toplevel.GenericName = {'precision_bit', 'total_online_delay'};
    toplevel.GenericType = {'INTEGER', 'INTEGER'};
    toplevel.GenericValue = {int2str(precisionBit), int2str(totalOnlineDelay)};

    variable = unique(prefixExp(isstrprop(prefixExp,'alpha'))); 
    var = cellstr(variable')';
    
    toplevel.PortName = {};
    toplevel.PortType = {};
    toplevel.PortWidth = {};
    toplevel.PortDataType = {};
    toplevel.SignalName = {};
    toplevel.SignalDataType = {};
    toplevel.SignalWidth = {};
    toplevel.ConstantName = {};
    toplevel.ConstantDataType = {};
    toplevel.ConstantWidth = {};
    toplevel.ConstantValue = {};
    ComponentBuffer = {};
    InitialiseBuffer = {};

    for k = 1 : length(var)
        toplevel.PortName = [toplevel.PortName, [var{k} '_p'], [var{k} '_n']];
        toplevel.PortType = [toplevel.PortType, 'in', 'in'];
        toplevel.PortWidth = [toplevel.PortWidth, '0', '0'];
        toplevel.PortDataType = [toplevel.PortDataType, 'BIT', 'BIT'];
    end
    toplevel.PortName = [toplevel.PortName, 'clk', 'rst', 'j_out', 'dout_p', 'dout_n'];
    toplevel.PortType = [toplevel.PortType, 'in', 'in', 'out', 'out', 'out'];
    toplevel.PortWidth = [toplevel.PortWidth, '0', '0', '-total_online_delay - 1 to precision_bit', '0', '0'];
    toplevel.PortDataType = [toplevel.PortDataType, 'BIT', 'BIT', 'INT', 'BIT', 'BIT'];
    
    toplevel.SignalName = [toplevel.SignalName, 'j'];
    toplevel.SignalDataType = [toplevel.SignalDataType, 'INT'];
    toplevel.SignalWidth = [toplevel.SignalWidth, '-total_online_delay - 1 to precision_bit'];
    
    constSize = size(constantBuffer);
    if constSize(1) ~= 0  
        CreateP2S_Conv;
        for i = 1 : constSize(1)
            toplevel.SignalName = [toplevel.SignalName, [constantBuffer{i} '_p'], [constantBuffer{i} '_n']];
            toplevel.SignalDataType = [toplevel.SignalDataType, 'BIT', 'BIT'];
            toplevel.ConstantName = [toplevel.ConstantName, constantBuffer{i}];
            toplevel.ConstantDataType = [toplevel.ConstantDataType, 'VEC'];
            toplevel.ConstantWidth = [toplevel.ConstantWidth, 'precision_bit + total_online_delay - 1'];
            %The total length of constant register is precision bit + online delay
            %zero padding for the online delay after binary conversion
            ConstantValue = pad(dec2bin(str2double(constantBuffer{i, 2})*2^precisionBit, precisionBit), precisionBit + totalOnlineDelay, 'right', '0');
            toplevel.ConstantValue = [toplevel.ConstantValue, ConstantValue];
            
            p2s{i} = VHDLParsorClass;
            p2s{i}.ComponentName = 'parallel_to_serial_conv';
            p2s{i}.GenerateComponentName = ['p2s' int2str(i)];
            p2s{i}.GenericName = {'total_bit'};
            p2s{i}.GenericAssignment = {'precision_bit + total_online_delay'}; 
            p2s{i}.PortName = {'clk', 'rst', 'd_in', 'd_out'};
            p2s{i}.PortAssignment = {'clk', 'rst', constantBuffer{i, 1}, [constantBuffer{i, 1} '_p']};
        end
        p2s{1}.GenericType = {'INTEGER'};
        p2s{1}.GenericValue = {int2str(precisionBit + totalOnlineDelay)};
        p2s{1}.PortType = {'in', 'in', 'in', 'out'};
        p2s{1}.PortDataType = {'BIT', 'BIT', 'VEC', 'BIT'};
        p2s{1}.PortWidth = {'0', '0', 'total_bit - 1', '0'};
        
        ComponentBuffer = [ComponentBuffer, CreateComponent(p2s{1}), ' '];
        for j = 1 : length(p2s)
            InitialiseBuffer = [InitialiseBuffer, InitialiseComponent(p2s{j}), ' '];
        end
        
    end
        
    addSize = size(addBuffer);
    multSize = size(multBuffer);
    divSize = size(divBuffer);
    
    if addSize(1) ~= 0  
        Create_oa_add_r2(radix);
        for i = 1 : addSize(1)            
            toplevel.SignalName = [toplevel.SignalName, addBuffer(i, 7:8)];
            toplevel.SignalDataType = [toplevel.SignalDataType, 'BIT', 'BIT'];
            
            add{i} = VHDLParsorClass;
            add{i}.ComponentName = 'oa_add_r2';
            add{i}.GenerateComponentName = ['add' int2str(i)];
            add{i}.PortName = {'x_p', 'x_n', 'y_p', 'y_n', 'clk', 'rst', 'z_p' 'z_n'};
            add{i}.PortAssignment = addBuffer(i,:);
        end
        add{1}.PortType = {'in', 'in', 'in', 'in', 'in', 'in', 'out', 'out'};
        add{1}.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'BIT'};
        
        ComponentBuffer = [ComponentBuffer, CreateComponent(add{1}), ' '];
        for j = 1 : length(add)
            InitialiseBuffer = [InitialiseBuffer, InitialiseComponent(add{j}), ' '];
        end
        
    end
    
    if multSize(1) ~= 0
        Create_oa_mult_r2(radix, onlineMultDelay, precisionBit);
        for i = 1 : multSize(1) 
            toplevel.SignalName = [toplevel.SignalName, multBuffer(i, 7:8)];
            toplevel.SignalDataType = [toplevel.SignalDataType, 'BIT', 'BIT'];
            
            mult{i} = VHDLParsorClass;
            mult{i}.ComponentName = 'oa_mult_r2';
            mult{i}.GenerateComponentName = ['mult' int2str(i)];
            mult{i}.GenericName = {'online_delay', 'total_bit'};
            mult{i}.GenericAssignment = {int2str(multBuffer{i,end}), 'precision_bit + total_online_delay'};
            mult{i}.PortName = {'x_p', 'x_n', 'y_p', 'y_n', 'clk', 'rst', 'p_p' 'p_n'};
            mult{i}.PortAssignment = multBuffer(i,1:end-1);
        end
        mult{1}.GenericType = {'INTEGER', 'INTEGER'};
        mult{1}.GenericValue = {int2str(onlineMultDelay), int2str(precisionBit+totalOnlineDelay)};
        mult{1}.PortType = {'in', 'in', 'in', 'in', 'in', 'in', 'out', 'out'};
        mult{1}.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'BIT'};
        
        ComponentBuffer = [ComponentBuffer, CreateComponent(mult{1}), ' '];
        for j = 1 : length(mult)
            InitialiseBuffer = [InitialiseBuffer, InitialiseComponent(mult{j}), ' '];
        end
    end
    
    if divSize(1) ~= 0  
        Create_oa_div_r2(radix, onlineDivDelay, precisionBit);
        for i = 1 : divSize(1) 
            toplevel.SignalName = [toplevel.SignalName, divBuffer(i, 7:8)];
            toplevel.SignalDataType = [toplevel.SignalDataType, 'BIT', 'BIT'];
            
            div{i} = VHDLParsorClass;
            div{i}.ComponentName = 'oa_div_r2';
            div{i}.GenerateComponentName = ['div' int2str(i)];
            div{i}.GenericName = {'online_delay', 'total_bit'};
            div{i}.GenericAssignment = {int2str(divBuffer{i,end}), 'precision_bit + total_online_delay', };
            div{i}.PortName = {'x_p', 'x_n', 'd_p', 'd_n', 'clk', 'rst', 'q_p' 'q_n'};
            div{i}.PortAssignment = divBuffer(i,1:end-1);
        end
        div{1}.GenericType = {'INTEGER', 'INTEGER'};
        div{1}.GenericValue = {int2str(onlineDivDelay), int2str(precisionBit + totalOnlineDelay)};
        div{1}.PortType = {'in', 'in', 'in', 'in', 'in', 'in', 'out', 'out'};
        div{1}.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'BIT'};
        
        ComponentBuffer = [ComponentBuffer, CreateComponent(div{1}), ' '];
        for j = 1 : length(div)
            InitialiseBuffer = [InitialiseBuffer, InitialiseComponent(div{j}), ' '];
        end
    end
    
    delayUnitSize = size(delayUnitBuffer);
    if delayUnitSize(1) ~= 0  
        CreateUnitDelay;
        for i = 1 : delayUnitSize(1)
            toplevel.SignalName = [toplevel.SignalName, delayUnitBuffer{i}{end}];
            toplevel.SignalDataType = [toplevel.SignalDataType, 'BIT'];
            
            N_UnitDelay{i} = VHDLParsorClass;
            N_UnitDelay{i}.ComponentName = 'n_unit_delay';
            N_UnitDelay{i}.GenerateComponentName = ['delay_unit_' int2str(i)];
            N_UnitDelay{i}.GenericName = {'delay_unit'};
            N_UnitDelay{i}.GenericAssignment = {delayUnitBuffer{i}{2}};
            N_UnitDelay{i}.PortName = {'d', 'clk', 'rst', 'q'};
            N_UnitDelay{i}.PortAssignment = {delayUnitBuffer{i}{1}, 'clk', 'rst', delayUnitBuffer{i}{end}};
        end
        N_UnitDelay{1}.GenericType = {'INTEGER'};
        N_UnitDelay{1}.GenericValue = {'1'};
        N_UnitDelay{1}.PortType = {'in', 'in', 'in', 'out'};
        N_UnitDelay{1}.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT'};
        
        ComponentBuffer = [ComponentBuffer, CreateComponent(N_UnitDelay{1}), ' '];
        for j = 1 : length(N_UnitDelay)
            InitialiseBuffer = [InitialiseBuffer, InitialiseComponent(N_UnitDelay{j}), ' '];
        end
    end
    
    %rstDelayUnitSize = size(rstDelayUnitBuffer);
    if maxRstDelay > 0  
        CreateDFF_NoRst;
        rstSignalStack = {'rst'};
        for i = 1 : maxRstDelay
            rstSignalStack = [rstSignalStack, ['rst_d' int2str(i)]]; 
            toplevel.SignalName = [toplevel.SignalName, ['rst_d' int2str(i)]];  
            toplevel.SignalDataType = [toplevel.SignalDataType, 'BIT'];

            dff{i} = VHDLParsorClass;
            dff{i}.ComponentName = 'dff_no_rst';
            dff{i}.GenerateComponentName = ['delay_rst_' int2str(i)];
            dff{i}.PortName = {'d', 'clk', 'q'};
            dff{i}.PortAssignment = {rstSignalStack{i}, 'clk', rstSignalStack{i+1}};
        end
        dff{1}.PortType = {'in', 'in', 'out'};
        dff{1}.PortDataType = {'BIT', 'BIT', 'BIT'};

        ComponentBuffer = [ComponentBuffer, CreateComponent(dff{1}), ' '];
        for j = 1 : length(dff)
            InitialiseBuffer = [InitialiseBuffer, InitialiseComponent(dff{j}), ' '];
        end
    end
    
    HeaderBuffer = CreateHeader(toplevel);
    EntityBuffer = CreateEntity(toplevel);
    SignalBuffer = CreateSignal(toplevel);
    ConstBuffer = CreateConst(toplevel);

    %create header         
    for k = 1 : length(HeaderBuffer)
        fprintf(FileID, '%s\n', HeaderBuffer{k});
    end
    
    %create entity          
    for k = 1: length(EntityBuffer)
        fprintf(FileID,'%s\n', EntityBuffer{k});
    end    
    
    %create architecture
    ArchitectureBuffer = {};
    ArchitectureBuffer = [ArchitectureBuffer, ['architecture Behavioral of ' FileName ' is']];
    ArchitectureBuffer = [ArchitectureBuffer, ConstBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, SignalBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, ComponentBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, 'begin'];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'j_out <= j;']];
    
    if constSize(1) ~= 0  
        for i = 1 : constSize(1) 
            ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) constantBuffer{i} '_n <= ''0'';']];
        end
    end
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'process(clk, rst)']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'begin']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'if RISING_EDGE(clk) then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'if rst = ''1'' then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'j <=  -total_online_delay - 1;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'if (j = precision_bit) then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'j <=  -total_online_delay - 1;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'j <= j + 1;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end process;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'process(clk, rst)']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'begin']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'if RISING_EDGE(clk) then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'if rst = ''1'' then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'dout_p <= ''0'';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'dout_n <= ''0'';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'dout_p <= ' doutName{1} '_p;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'dout_n <= ' doutName{1} '_n;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end process;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, InitialiseBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];
    
    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end
          
    fclose(FileID);
    
end