%create parallel 4: 2 carry save adder vhdl file
function CreateCSA_4_2
    FileName = 'parallel_4_2_csa';
    FileID = fopen([FileName '.vhd'], 'w');

    csa = VHDLParsorClass;
    csa.FileName = FileName;
    csa.GenericName = {'total_bit'};
    csa.GenericType = {'INTEGER'};
    csa.GenericValue = {'32'};
    csa.PortName = {'x', 'y', 'w', 'z', 'c_x', 'c_y', 'vs' 'vc'};
    csa.PortType = {'in', 'in', 'in', 'in', 'in', 'in', 'out', 'out'};
    csa.PortDataType = {'VEC', 'VEC', 'VEC', 'VEC', 'BIT', 'BIT', 'VEC', 'VEC'};
    csa.PortWidth = {'total_bit', 'total_bit', 'total_bit', 'total_bit', '0', '0', 'total_bit', 'total_bit'};
    csa.SignalName = {'s_temp', 'c_out_temp', 'vs_temp', 'vc_temp'};
    csa.SignalDataType = {'VEC', 'VEC', 'VEC', 'VEC'};
    csa.SignalWidth = {'total_bit', 'total_bit + 1', 'total_bit + 1', 'total_bit + 1'};

    fa1 = VHDLParsorClass; 
    fa1.ComponentName = 'fa';
    fa1.GenerateComponentName = 'csa1';
    fa1.PortName = {'digit_1', 'digit_2', 'c_in', 'c_out', 'sum'};
    fa1.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT', 'BIT'};
    fa1.PortWidth = {'0', '0', '0', '0', '0'};
    fa1.PortType = {'in', 'in', 'in', 'out', 'out'};
    fa1.PortAssignment = {'x(total_bit - i)', 'y(total_bit - i)', 'w(total_bit - i)', 'c_out_temp(total_bit + 1 - i)', 's_temp(total_bit - i)'};

    fa2 = VHDLParsorClass; 
    fa2.ComponentName = 'fa';
    fa2.GenerateComponentName = 'csa2';
    fa2.PortName = fa1.PortName;
    fa2.PortAssignment = {'s_temp(total_bit - i)', 'z(total_bit - i)', 'c_out_temp(total_bit - i)', 'vc_temp(total_bit + 1 - i)', 'vs_temp(total_bit - i)'};

    HeaderBuffer = CreateHeader(csa);
    EntityBuffer = CreateEntity(csa);
    SignalBuffer = CreateSignal(csa);
    ComponentBuffer = CreateComponent(fa1);
    InitialiseBuffer = [InitialiseComponent(fa1), ' ', InitialiseComponent(fa2)];

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
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) csa.SignalName{2} '(0)' ' <= ' csa.PortName{5} ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) csa.SignalName{3} '(' csa.SignalName{3} '''high)' ' <= ' csa.SignalName{2} '(' csa.SignalName{2} '''high)' ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) csa.SignalName{4} '(0)' ' <= ' csa.PortName{6} ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) csa.PortName{7} ' <= ' csa.SignalName{3} '(' csa.SignalName{3} '''high - 1 downto 0)' ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) csa.PortName{8} ' <= ' csa.SignalName{4} '(' csa.SignalName{4} '''high - 1 downto 0)' ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'g1: for i in 0 to ' csa.PortWidth{1}  ' generate']]; 
    ArchitectureBuffer = [ArchitectureBuffer, InitialiseBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end generate;']]; 
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];

    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end

    fclose(FileID);
    
    CreateFA;

end