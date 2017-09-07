%Create selection function for division
%Unlike multiplication, we manully define the lookup table for radix-2 division as as qp and qn
%In the future, we may update the generator for an arbitary radix division that requries a function to generate the select function of division 
function CreateSelmDiv(radix)
    
    qp = {'0', '1', '1', '1', '1', '1', '1', '1', '0', '0', '0', '0', '0', '0', '0', '0'};
    qn = {'0', '0', '0', '0', '0', '0', '0', '0', '1', '1', '1', '1', '1', '1', '1', '0'};
    
    usedBit = 4;
    
    if length(qp(1)) == 1
        pPortType = 'BIT';
        pPortWidth = '0';
    else
        pPortType = 'VEC';
        pPortWidth = intstr2(length(qp(1)) - 1);
    end
    
    FileName = 'selm_div_r2';
    FileID = fopen([FileName '.vhd'], 'w');

    selm = VHDLParsorClass;
    selm.FileName = FileName;
    selm.GenericName = {'total_bit'};
    selm.GenericType = {'INTEGER'};
    selm.GenericValue = {int2str(usedBit)};
    selm.PortName = {'v_est_in', 'q_p', 'q_n'};
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
    q_p_count = [];
    q_n_count = [];
    for i = 1 : length(qp)
        if i < length(qp)
            q_p_count = [q_p_count, '''', qp{i}, '''' ', '];
            q_n_count = [q_n_count, '''', qn{i}, '''' ', '];
        else
            q_p_count = [q_p_count, '''', qp{i}, ''''];
            q_n_count = [q_n_count, '''', qn{i}, ''''];
        end
    end 
    
    ArchitectureBuffer = {};
    ArchitectureBuffer = [ArchitectureBuffer, ['architecture Behavioral of ' FileName ' is']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'subtype lut_out is STD_LOGIC;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'type lut_in is array (NATURAL range 0 to 2**total_bit - 1) of lut_out;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'constant q_p_count: lut_in := (' q_p_count ');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'constant q_n_count: lut_in := (' q_n_count ');']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'begin'];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) selm.PortName{2} ' <= q_p_count(to_integer(unsigned(' selm.PortName{1} ')));']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) selm.PortName{3} ' <= q_n_count(to_integer(unsigned(' selm.PortName{1} ')));']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];
    
    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end
          
    fclose(FileID);
end 