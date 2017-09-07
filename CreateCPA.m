%create carry ripple adder vhdl file
function CreateCPA
    FileName = 'cpa';
    FileID = fopen([FileName '.vhd'], 'w');

    cpa = VHDLParsorClass;
    cpa.FileName = FileName;
    cpa.GenericName = {'total_bit'};
    cpa.GenericType = {'INTEGER'};
    cpa.GenericValue = {'4'};
    cpa.PortName = {'x', 'y', 'c_in', 's'};
    cpa.PortDataType = {'VEC', 'VEC', 'BIT', 'VEC'};
    cpa.PortType = {'in', 'in', 'in', 'out'};
    cpa.PortWidth = {'total_bit - 1', 'total_bit - 1', '0', 'total_bit - 1'};
    cpa.SignalName = {'c_temp'};
    cpa.SignalDataType = {'VEC'};
    cpa.SignalWidth = {'total_bit'};

    fa = VHDLParsorClass;
    fa.ComponentName = 'fa';
    fa.GenerateComponentName = 'cpa';
    fa.PortName = {'digit_1', 'digit_2', 'c_in', 'c_out', 'sum'};
    fa.PortWidth = {'0', '0', '0', '0', '0'};
    fa.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT', 'BIT'};
    fa.PortType = {'in', 'in', 'in', 'out', 'out'};
    fa.PortAssignment = {'x(i)', 'y(i)', 'c_temp(i)', 'c_temp(i+1)', 's(i)'};

    HeaderBuffer = CreateHeader(cpa);
    EntityBuffer = CreateEntity(cpa);
    SignalBuffer = CreateSignal(cpa);
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
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) cpa.SignalName{1} '(0)' ' <= ' cpa.PortName{3} ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'g1: for i in 0 to ' cpa.PortWidth{1} ' generate']]; 
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
