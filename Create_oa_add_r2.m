%create online adder vhdl file
function Create_oa_add_r2(radix)
    FileName = 'oa_add_r2';
    FileID = fopen([FileName '.vhd'], 'w');

    OADD = VHDLParsorClass;
    OADD.FileName = FileName;
    OADD.PortName = {'x_p', 'x_n', 'y_p', 'y_n', 'clk', 'rst', 'z_p' 'z_n'};
    OADD.PortType = {'in', 'in', 'in', 'in', 'in', 'in', 'out', 'out'};
    OADD.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'BIT'};

    OADD.SignalName = {'x_p_temp', 'x_n_temp', 'y_p_temp', 'y_n_temp', 'z_p_temp', 'z_n_temp', 'c_out_temp', 'g0_temp', 'g0_temp_d1', 'g1_temp_d1', 't_temp', 'w_temp'};
    for i = 1 : length(OADD.SignalName)
        OADD.SignalDataType{i} = 'BIT';
    end

    fa1 = VHDLParsorClass; 
    fa1.ComponentName = 'fa';
    fa1.PortName = {'digit_1', 'digit_2', 'c_in', 'c_out', 'sum'};
    fa1.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT', 'BIT'};
    fa1.PortWidth = {'0', '0', '0', '0', '0'};
    fa1.PortType = {'in', 'in', 'in', 'out', 'out'};
    fa1.GenerateComponentName = 'sda1';
    fa1.PortAssignment = {OADD.SignalName{1}, OADD.SignalName{2}, OADD.SignalName{3}, OADD.SignalName{7}, OADD.SignalName{8}};

    fa2 = VHDLParsorClass; 
    fa2.ComponentName = 'fa';
    fa2.GenerateComponentName = 'sda2';
    fa2.PortName = fa1.PortName;
    fa2.PortAssignment = {OADD.SignalName{9}, OADD.SignalName{10}, OADD.SignalName{7}, OADD.SignalName{11}, OADD.SignalName{12}};

    dff1 = VHDLParsorClass; 
    dff1.PortName = {'d', 'clk', 'rst', 'q'};
    dff1.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT'};
    dff1.PortType = {'in', 'in', 'in', 'out'};
    dff1.ComponentName = 'd_ff';
    dff1.GenerateComponentName = 'latch1';
    dff1.PortAssignment = {OADD.SignalName{8}, OADD.PortName{5}, OADD.PortName{6}, OADD.SignalName{9}};

    dff2 = VHDLParsorClass; 
    dff2.ComponentName = 'd_ff';
    dff2.GenerateComponentName = 'latch2';
    dff2.PortName = dff1.PortName;
    dff2.PortAssignment = {OADD.SignalName{4}, OADD.PortName{5}, OADD.PortName{6}, OADD.SignalName{10}};

    dff3 = VHDLParsorClass; 
    dff3.ComponentName = 'd_ff';
    dff3.GenerateComponentName = 'latch3';
    dff3.PortName = dff1.PortName;
    dff3.PortAssignment = {OADD.SignalName{12}, OADD.PortName{5}, OADD.PortName{6}, OADD.SignalName{5}};

    HeaderBuffer = CreateHeader(OADD);
    EntityBuffer = CreateEntity(OADD);
    SignalBuffer = CreateSignal(OADD);
    ComponentBuffer = [CreateComponent(fa1), ' ', CreateComponent(dff1)] ;
    InitialiseBuffer = [InitialiseComponent(fa1), ' ', InitialiseComponent(fa2), ' ', InitialiseComponent(dff1), ' ', InitialiseComponent(dff2), ' ', InitialiseComponent(dff3)];

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
    ArchitectureBuffer = [ArchitectureBuffer, SignalBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, ComponentBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'begin'];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) OADD.SignalName{1} ' <= ' OADD.PortName{1} ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) OADD.SignalName{2} ' <= not ' OADD.PortName{2} ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) OADD.SignalName{3} ' <= ' OADD.PortName{3} ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) OADD.SignalName{4} ' <= not ' OADD.PortName{4} ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) OADD.SignalName{6} ' <= not ' OADD.SignalName{11} ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) OADD.PortName{7} ' <= ' OADD.SignalName{5} ' when ' OADD.PortName{6} ' = ''0'' else ''0'';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) OADD.PortName{8} ' <= ' OADD.SignalName{6} ' when ' OADD.PortName{6} ' = ''0'' else ''0'';']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, InitialiseBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];

    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end
          
    fclose(FileID);
    
    CreateDFF;
    CreateFA;

end