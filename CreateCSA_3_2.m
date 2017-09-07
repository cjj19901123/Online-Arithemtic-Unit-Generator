%create parallel 3: 2 carry save adder vhdl file
function CreateCSA_3_2
    FileName = 'parallel_3_2_csa';
    FileID = fopen([FileName '.vhd'], 'w');

    csa = VHDLParsorClass;
    csa.FileName = FileName;
    csa.GenericName = {'total_bit'};
    csa.GenericType = {'INTEGER'};
    csa.GenericValue = {'32'};
    csa.PortName = {'x', 'y', 'z', 'c_in', 'vs' 'vc'};
    csa.PortType = {'in', 'in', 'in', 'in', 'out', 'out'};
    csa.PortDataType = {'VEC', 'VEC', 'VEC', 'BIT', 'VEC', 'VEC'};
    csa.PortWidth = {'total_bit', 'total_bit', 'total_bit', '0', 'total_bit', 'total_bit'};
    csa.SignalName = {'x_temp', 'y_temp', 's_temp', 'c_out_temp'};
    csa.SignalDataType = {'VEC', 'VEC', 'VEC', 'VEC'};
    csa.SignalWidth = {'total_bit', 'total_bit', 'total_bit', 'total_bit + 1'};

    fa = VHDLParsorClass;
    fa.ComponentName = 'fa';
    fa.GenerateComponentName = 'csa';
    fa.PortName = {'digit_1', 'digit_2', 'c_in', 'c_out', 'sum'};
    fa.PortWidth = {'0', '0', '0', '0', '0'};
    fa.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT', 'BIT'};
    fa.PortType = {'in', 'in', 'in', 'out', 'out'};
    fa.PortAssignment = {'x(total_bit - i)', 'y(total_bit - i)', 'z(total_bit - i)', 'c_out_temp(total_bit + 1 - i)', 's_temp(total_bit - i)', };

    HeaderBuffer = CreateHeader(csa);
    EntityBuffer = CreateEntity(csa);
    SignalBuffer = CreateSignal(csa);
    ComponentBuffer = CreateComponent(fa);
    Initialise_fa_Buffer = InitialiseComponent(fa);

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
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) csa.SignalName{4} '(0)' ' <= ' csa.PortName{4} ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) csa.PortName{5} ' <= ' csa.SignalName{3} ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) csa.PortName{6} ' <= ' csa.SignalName{4} '(' csa.SignalName{4} '''high - 1 downto 0)' ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'g1: for i in 0 to ' csa.PortWidth{1}  ' generate']]; 
    ArchitectureBuffer = [ArchitectureBuffer, Initialise_fa_Buffer];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end generate;']]; 
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];

    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end

    fclose(FileID);
    
    CreateFA;

end
