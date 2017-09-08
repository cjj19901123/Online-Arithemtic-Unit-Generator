%on the fly conversion vhdl file
%convert redundant digit to conventional form
function CreateOTF
    FileName = 'on_the_fly_conv_r2';
    FileID = fopen([FileName '.vhd'], 'w');

    otf = VHDLParsorClass;
    otf.FileName = FileName;
    otf.GenericName = {'total_bit', 'start_iteration'};
    otf.GenericType = {'INTEGER', 'INTEGER'};
    otf.GenericValue = {'32', '-5'};
    otf.PortName = {'x_p', 'x_n', 'j', 'x_out', 'x_out_not'};
    otf.PortType = {'in', 'in', 'in', 'out', 'out'};
    otf.PortDataType = {'BIT', 'BIT', 'INT', 'VEC', 'VEC'};

    IntegerRange = [otf.GenericName{2} ' to ' otf.GenericName{1} ' + ' otf.GenericName{2} ' + 2'];
    otf.PortWidth = {'0', '0', IntegerRange, 'total_bit', 'total_bit'};

    otf.SignalName = {'x', 'xm', 'x_rg', 'xm_rg', 'x_in', 'xm_in', 'sf_x', 'sf_xm', 'x_digit'};
    otf.SignalDataType = {'VEC', 'VEC', 'VEC', 'VEC', 'BIT', 'BIT', 'BIT', 'BIT', 'VEC'};
    otf.SignalWidth = {'total_bit', 'total_bit', 'total_bit', 'total_bit', '0', '0', '0', '0', '1'};

    HeaderBuffer = CreateHeader(otf);
    EntityBuffer = CreateEntity(otf);
    SignalBuffer = CreateSignal(otf);

    %create header         
    for k = 1 : length(HeaderBuffer)
        fprintf(FileID, '%s\n', HeaderBuffer{k});
    end

    %create entity          
    for k = 1: length(EntityBuffer)
        fprintf(FileID,'%s\n', EntityBuffer{k});
    end

    OthersZero = 'others => ''0''';

    %create architecture  
    ArchitectureBuffer = {};
    ArchitectureBuffer = [ArchitectureBuffer, ['architecture Behavioral of ' FileName ' is']];
    ArchitectureBuffer = [ArchitectureBuffer, SignalBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, 'begin'];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) otf.SignalName{9} ' <= ' otf.PortName{1} ' & ' otf.PortName{2} ';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) otf.PortName{4} ' <= ' otf.SignalName{3} ';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) otf.PortName{5} ' <= not ' otf.SignalName{3} ';']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'process(' otf.PortName{3} ')']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'begin']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'if (' otf.PortName{3} ' < ' otf.GenericName{2} ') then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) otf.SignalName{1} ' <= ' '(' OthersZero ');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) otf.SignalName{2} ' <= ' '(' OthersZero ');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) otf.SignalName{1} ' <= ' otf.SignalName{3} ';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) otf.SignalName{2} ' <= ' otf.SignalName{4} ';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end process;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) otf.SignalName{7} ' <= ''0'' when ' otf.SignalName{9} ' = "01" else ''1'';']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) otf.SignalName{8} ' <= ''0'' when ' otf.SignalName{9} ' = "10" else ''1'';']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) otf.SignalName{5} ' <= ''1'' when ' otf.SignalName{9} ' = "10" else ']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(11) ' ''1'' when ' otf.SignalName{9} ' = "01" else ']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(11) ' ''0''; ']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) otf.SignalName{6} ' <= ''0'' when ' otf.SignalName{9} ' = "10" else ']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) ' ''0'' when ' otf.SignalName{9} ' = "01" else ']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) ' ''1''; ']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) otf.SignalName{3} ' <= ' otf.SignalName{1} '(' otf.GenericName{1} ' - 1 downto 0) & ' otf.SignalName{5} ' when ' otf.SignalName{7} ' = ''1'' else ']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) otf.SignalName{2} '(' otf.GenericName{1} ' - 1 downto 0) & ' otf.SignalName{5} ';']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) otf.SignalName{4} ' <= ' otf.SignalName{2} '(' otf.GenericName{1} ' - 1 downto 0) & ' otf.SignalName{6} ' when ' otf.SignalName{8} ' = ''1'' else ']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(13) otf.SignalName{1} '(' otf.GenericName{1} ' - 1 downto 0) & ' otf.SignalName{6} ';']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];

    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end

    fclose(FileID);

end