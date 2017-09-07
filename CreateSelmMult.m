%Create Selet Fucnction for mult
%the used bit, truncated bit t and lookup table of select function is generated by a funtion SELM_mult 
%that is designed for an arbitary radix even if we only use radix 2 here
%pArray is a ROM to store the corresponding output digit in borrow save form
function CreateSelmMult(radix)
    
    [usedBit, t, pArray] = SELM_mult(radix);
    
    pp = pArray(1, :);
    pn = pArray(2, :);
    
    if length(pp(1)) == 1
        pPortType = 'BIT';
        pPortWidth = '0';
    else
        pPortType = 'VEC';
        pPortWidth = intstr2(length(pp(1)) - 1);
    end
    
    FileName = 'selm_mult_r2';
    FileID = fopen([FileName '.vhd'], 'w');

    selm = VHDLParsorClass;
    selm.FileName = FileName;
    selm.GenericName = {'total_bit'};
    selm.GenericType = {'INTEGER'};
    selm.GenericValue = {int2str(usedBit)};
    selm.PortName = {'v_est_in', 'p_p', 'p_n'};
    selm.PortDataType = {'VEC', pPortType, pPortType};
    selm.PortType = {'in', 'out', 'out'};
    selm.PortWidth = {'total_bit - 1', pPortWidth, pPortWidth};

    HeaderBuffer = CreateHeader(selm);
    EntityBuffer = CreateEntity(selm);  
    
    %create header         
    for k = 1 : length(HeaderBuffer)
        fprintf(FileID, '%s\n', HeaderBuffer{k});
    end
    
    %create entity          
    for k = 1: length(EntityBuffer)
        fprintf(FileID,'%s\n', EntityBuffer{k});
    end
    
    %create architecture 
    p_p_count = [];
    p_n_count = [];
    for i = 1 : length(pp)
        if i < length(pp)
            p_p_count = [p_p_count, '''', pp{i}, '''' ', '];
            p_n_count = [p_n_count, '''', pn{i}, '''' ', '];
        else
            p_p_count = [p_p_count, '''', pp{i}, ''''];
            p_n_count = [p_n_count, '''', pn{i}, ''''];
        end
    end 
    
    ArchitectureBuffer = {};
    ArchitectureBuffer = [ArchitectureBuffer, ['architecture Behavioral of ' FileName ' is']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'subtype lut_out is STD_LOGIC;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'type lut_in is array (NATURAL range 0 to 2**total_bit - 1) of lut_out;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'constant p_p_count: lut_in := (' p_p_count ');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'constant p_n_count: lut_in := (' p_n_count ');']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'begin'];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) selm.PortName{2} ' <= p_p_count(to_integer(unsigned(' selm.PortName{1} ')));']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) selm.PortName{3} ' <= p_n_count(to_integer(unsigned(' selm.PortName{1} ')));']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];
    
    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end
          
    fclose(FileID);
end 