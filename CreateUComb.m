%create U combine vhdl file
function CreateUComb
    FileName = 'u_comb';
    FileID = fopen([FileName '.vhd'], 'w');

    U = VHDLParsorClass;
    U.FileName = FileName;
    U.GenericName = {'total_bit'};
    U.GenericType = {'INTEGER'};
    U.GenericValue = {'6'};
    U.PortName = {'x_p', 'x_n', 'd_p', 'd_n', 'q_s', 'u'};
    U.PortType = {'in', 'in', 'in', 'in', 'in', 'out'};
    U.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'VEC'};
    U.PortWidth = {'0', '0', '0', '0', '0,' 'total_bit - 1'};

    U.SignalName = {'x_p_temp, x_n_temp, d_p_temp, d_n_temp, x_z, d_z, d_temp_1, d_temp_2, u_temp_1, u_temp_2'};
    U.SignalDataType = {'BIT'};

    HeaderBuffer = CreateHeader(U);
    EntityBuffer = CreateEntity(U);
    SignalBuffer = CreateSignal(U);
    
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
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'x_p_temp <= ''0'' when x_p = ''1'' and x_n = ''1'' else x_p;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'x_n_temp <= ''0'' when x_p = ''1'' and x_n = ''1'' else x_n;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'd_p_temp <= ''0'' when d_p = ''1'' and d_n = ''1'' else d_p;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'd_n_temp <= ''0'' when d_p = ''1'' and d_n = ''1'' else d_n;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'x_z <= x_p XNOR x_n;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'd_z <= d_p XNOR d_n;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'd_temp_1 <= (d_p_temp and not q_s) or (d_n_temp and q_s);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'd_temp_2 <= (d_p_temp and q_s) or (d_n_temp and not q_s);']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'u_temp_1 <= x_n_temp or (x_z and d_temp_1);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'u_temp_2 <= (not x_z and d_z) or (not x_z and d_temp_2) or (x_z and d_temp_1);']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'u(0) <= u_temp_2;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'gen : for i in 1 to total_bit - 1 generate']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'u(i) <= u_temp_1;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end generate gen;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];
    
    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end

    fclose(FileID);
end