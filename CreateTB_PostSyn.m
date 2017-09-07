function CreateTB_PostSyn(name, precision, expression, waveGenBuffer)
    [prefixExp, ~, ~, ~, ~, ~, totalOnlineDelay, ~, ~, ~] = ExpressionParser(expression);
    
    variable = unique(prefixExp(isstrprop(prefixExp,'alpha')));  
    var = cellstr(variable')';
    
    %Create File using VHDL Parsor Class 
    FileName = ['tb_postsyn' name];
    FileID = fopen([FileName '.vhd'], 'w');
    
    tb = VHDLParsorClass;
    tb.FileName = FileName;
    
    tb.SignalName = {'clk', 'rst', };
    tb.SignalDataType = {'BIT', 'BIT'};
    tb.SignalDefaultValue = {'''1''', '''1'''};
    
    varSize = length(var);
    for k = 1 : varSize
        tb.SignalName = [tb.SignalName, [var{k} '_p'], [var{k} '_n']];
        tb.SignalDataType = [tb.SignalDataType, 'BIT', 'BIT'];
        tb.SignalWidth  = [tb.SignalWidth, '0', '0'];
        tb.SignalDefaultValue = [tb.SignalDefaultValue, '''0''', '''0'''];
    end
    
    tb.SignalName = [tb.SignalName, 'dout_p', 'dout_n'];
    tb.SignalDataType = [tb.SignalDataType, 'BIT', 'BIT'];
    tb.SignalWidth = [tb.SignalWidth, '0', '0'];
    tb.SignalDefaultValue = [tb.SignalDefaultValue, '''0''', '''0'''];

    oa = VHDLParsorClass;
    oa.ComponentName = name;
    oa.GenerateComponentName = 'utt';
    
    oa.PortName = {};
    oa.PortType = {};
    oa.PortDataType = {};
    oa.PortWidth = {};
    oa.PortAssignment = {};
    
    for k = 1 : varSize 
        oa.PortName = [oa.PortName, [var{k} '_p'], [var{k} '_n']];
        oa.PortType = [oa.PortType, 'in', 'in'];
        oa.PortDataType = [oa.PortDataType, 'BIT', 'BIT'];
        oa.PortWidth = [oa.PortWidth, '0', '0'];
        oa.PortAssignment = [oa.PortAssignment, [var{k} '_p'], [var{k} '_n']];
    end
    
    oa.PortName = [oa.PortName, 'clk', 'rst', 'dout_p', 'dout_n'];
    oa.PortType = [oa.PortType, 'in', 'in', 'out', 'out'];
    oa.PortDataType = [oa.PortDataType, 'BIT', 'BIT', 'BIT', 'BIT'];
    oa.PortWidth = [oa.PortWidth, '0', '0', '0', '0']; 
    oa.PortAssignment = [oa.PortAssignment, 'clk', 'rst', 'dout_p', 'dout_n']; 
    
    HeaderBuffer = CreateHeader(tb);
    HeaderBuffer = [HeaderBuffer, ' '];
    EntityBuffer = CreateEntity(tb);
    SignalBuffer = CreateSignal(tb);
    ComponentBuffer = [CreateComponent(oa), ' '];
    InitialiseBuffer = [InitialiseComponent(oa), ' '];
    
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
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'procedure waveform_gen(']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'signal clk : in STD_LOGIC;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'signal d : out STD_LOGIC;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'waveform : STD_LOGIC_VECTOR) is']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'begin']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'for i in waveform''left to waveform''right loop']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'd <= waveform(i);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'wait until RISING_EDGE(clk);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'end loop;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end waveform_gen;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'begin'];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'clk <= not clk after 5 ns;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'rst <= not rst after ' num2str((precision + totalOnlineDelay)*10)  ' ns;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, waveGenBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, InitialiseBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];
    
    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end
          
    fclose(FileID);
end