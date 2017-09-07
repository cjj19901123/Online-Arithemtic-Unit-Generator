%create full adder vhdl file
function CreateFA
    FileName = 'fa';
    FileID = fopen([FileName '.vhd'], 'w');

    fa = VHDLParsorClass;
    fa.FileName = FileName;
    fa.PortName = {'digit_1', 'digit_2', 'c_in', 'c_out', 'sum'};
    fa.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT', 'BIT'};
    fa.PortType = {'in', 'in', 'in', 'out', 'out'};
    fa.SignalName = {'wire_1', 'wire_2', 'wire_3'};
    fa.SignalDataType = {'BIT', 'BIT', 'BIT'};
    fa.SignalWidth = {'0', '0', '0'};

    HeaderBuffer = CreateHeader(fa);
    EntityBuffer = CreateEntity(fa);
    SignalBuffer = CreateSignal(fa);

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
    ArchitectureBuffer = [ArchitectureBuffer, 'begin'];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) fa.SignalName{1} ' <= ' fa.PortName{1} ' xor ' fa.PortName{2} ';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) fa.SignalName{2} ' <= ' fa.SignalName{1} ' and ' fa.PortName{3} ';' ]];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) fa.SignalName{3} ' <= ' fa.PortName{1} ' and ' fa.PortName{2} ';' ]];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) fa.PortName{5} ' <= ' fa.SignalName{1} ' xor ' fa.PortName{3} ';' ]];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) fa.PortName{4} ' <= ' fa.SignalName{2} ' or ' fa.SignalName{3} ';']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];

    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end

    fclose(FileID);

end

