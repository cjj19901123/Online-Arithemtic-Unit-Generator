%create D-FlipFlop vhdl file
function CreateDFF
    FileName = 'd_ff';
    FileID = fopen([FileName '.vhd'], 'w');

    dff = VHDLParsorClass;
    dff.FileName = FileName;
    dff.PortName = {'d', 'clk', 'rst', 'q'};
    dff.PortType = {'in', 'in', 'in', 'out'};
    dff.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT'};

    HeaderBuffer = CreateHeader(dff);
    EntityBuffer = CreateEntity(dff);


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
    ArchitectureBuffer = [ArchitectureBuffer, 'begin'];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'process(' dff.PortName{2} ', ' dff.PortName{3} ')']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'begin']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'if RISING_EDGE(' dff.PortName{2} ') then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'if (' dff.PortName{3} ' = ''1'') then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) dff.PortName{4} ' <= ''0'';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) dff.PortName{4} ' <= ' dff.PortName{1} ';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end process;']];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];

    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end
          
    fclose(FileID);

end
