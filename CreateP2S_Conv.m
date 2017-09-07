%convert binary in digit-serial manner
function CreateP2S_Conv
    FileName = 'parallel_to_serial_conv';
    FileID = fopen([FileName '.vhd'], 'w');

    p2s = VHDLParsorClass;
    p2s.FileName = FileName;
    p2s.GenericName = {'total_bit'};
    p2s.GenericType = {'INTEGER'};
    p2s.GenericValue = {'16'};
    p2s.PortName = {'clk', 'rst', 'd_in', 'd_out'};
    p2s.PortDataType = {'BIT', 'BIT', 'VEC', 'BIT'};
    p2s.PortType = {'in', 'in', 'in', 'out'};
    p2s.PortWidth = {'0', '0', 'total_bit - 1', '0'};
    p2s.SignalName = {'d_reg', 'd_temp'};
    p2s.SignalDataType = {'VEC', 'BIT'};
    p2s.SignalWidth = {'total_bit - 1', '0'};
    
    HeaderBuffer = CreateHeader(p2s);
    EntityBuffer = CreateEntity(p2s);
    SignalBuffer = CreateSignal(p2s);
    
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
    ArchitectureBuffer = [ArchitectureBuffer, 'begin'];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) p2s.PortName{4} ' <= ' p2s.SignalName{2} ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'process(' p2s.PortName{1} ', ' p2s.PortName{2} ')']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'begin']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'if RISING_EDGE(' p2s.PortName{1} ') then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'if (' p2s.PortName{2} ' = ''1'') then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) p2s.SignalName{2} ' <= ''0'';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) p2s.SignalName{1} ' <= ' p2s.PortName{3} ';']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) p2s.SignalName{2} ' <= ' p2s.SignalName{1} '(' p2s.SignalName{1} '''high);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) p2s.SignalName{1} ' <= ' p2s.SignalName{1} '(total_bit - 2 downto 0) & ''1'';']];    
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end process;']];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];
    
    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end
          
    fclose(FileID);
    
end