%Create oa mult vhdl file
function Create_oa_div_r2(radix, onlineDelay, precisionBit)
    
    t = 3;
    usedBit = 4;
    
    integerBit = log2(radix) + 1;
    
    if log2(radix) == 1
        pPortType = 'BIT';
        pPortWidth = '0';
    else
        pPortType = 'VEC';
        pPortWidth = intstr2(log2(radix) - 1);
    end
    
    FileName = 'oa_div_r2';
    FileID = fopen([FileName '.vhd'], 'w');

    ODIV = VHDLParsorClass;
    ODIV.FileName = FileName;
    ODIV.GenericName = {'truncate_bit', 'online_delay', 'integer_bit', 'used_bit' 'total_bit'};
    ODIV.GenericType = {'INTEGER', 'INTEGER', 'INTEGER', 'INTEGER', 'INTEGER'};
    ODIV.GenericValue = {int2str(t), int2str(onlineDelay), int2str(integerBit), int2str(usedBit), int2str(precisionBit)};
    ODIV.PortName = {'x_p', 'x_n', 'd_p', 'd_n', 'clk', 'rst', 'q_p' 'q_n'};
    ODIV.PortType = {'in', 'in', 'in', 'in', 'in', 'in', 'out', 'out'};
    ODIV.PortDataType = {pPortType, pPortType, pPortType, pPortType, 'BIT', 'BIT', pPortType, pPortType};
    ODIV.PortWidth = {pPortWidth, pPortWidth, pPortWidth, pPortWidth, '0', '0', pPortWidth, pPortWidth};
    
    ODIV.SignalName = {'j', 'q_out, q_out_not, q_temp, q_not_temp, d_out, d_out_not, d_temp, d_not_temp', 'vs, vc, ws, wc, ws_reg, wc_reg, q_mult_digit_d, d_mult_digit_q', 'vs_est, vc_est, v_est', 'u', 'v_est_used, v_est_used_not, v_est_in', 'cd, cq, x_p_d1, x_n_d1, d_p_d1, d_n_d1, qp, qn, q_p_temp, q_n_temp'};
    ODIV.SignalWidth = {'-online_delay - 1 to total_bit - online_delay', 'total_bit', 'total_bit + integer_bit - 1', 'truncate_bit + integer_bit - 1', 'online_delay + integer_bit - 2', 'used_bit - 1', '0'};
    ODIV.SignalDataType = {'INT', 'VEC', 'VEC', 'VEC', 'VEC', 'VEC', 'BIT'};
    
    csa1 = VHDLParsorClass; 
    csa1.ComponentName = 'parallel_3_2_csa';
    csa1.GenerateComponentName = 'csa_v';
    csa1.GenericName = {'total_bit'};
    csa1.GenericType = {'INTEGER'};
    csa1.GenericValue = {'total_bit + integer_bit - 1'};
    csa1.GenericAssignment = {'total_bit + integer_bit - 1'};
    csa1.PortName = {'x', 'y', 'z', 'c_in', 'vs' 'vc'};
    csa1.PortType = {'in', 'in', 'in', 'in', 'out', 'out'};
    csa1.PortDataType = {'VEC', 'VEC', 'VEC', 'BIT', 'VEC', 'VEC'};
    csa1.PortWidth = {'total_bit', 'total_bit', 'total_bit', '0', 'total_bit', 'total_bit'};
    csa1.PortAssignment = {'q_mult_digit_d', 'ws_reg', 'wc_reg', 'cd', 'vs', 'vc'};
    
    csa2 = VHDLParsorClass; 
    csa2.ComponentName = 'parallel_3_2_csa';
    csa2.GenerateComponentName = 'csa_w';
    csa2.GenericName = {'total_bit'};
    csa2.GenericAssignment = {'total_bit + integer_bit - 1'};
    csa2.PortName = {'x', 'y', 'z', 'c_in', 'vs' 'vc'};
    csa2.PortAssignment = {'d_mult_digit_q', 'vs', 'vc', 'cq', 'ws', 'wc'};
    
    cpa = VHDLParsorClass;
    cpa.ComponentName = 'cpa';
    cpa.GenerateComponentName = 'cpa_vest';
    cpa.GenericName = {'total_bit'};
    cpa.GenericType = {'INTEGER'};
    cpa.GenericValue = {'truncate_bit + integer_bit'};
    cpa.GenericAssignment = {'truncate_bit + integer_bit'};
    cpa.PortName = {'x', 'y', 'c_in', 's'};
    cpa.PortDataType = {'VEC', 'VEC', 'BIT', 'VEC'};
    cpa.PortType = {'in', 'in', 'in', 'out'};
    cpa.PortWidth = {'total_bit - 1', 'total_bit - 1', '0', 'total_bit - 1'};
    cpa.PortAssignment = {'vs_est', 'vc_est', '''0''', 'v_est'};
    
    otf1 = VHDLParsorClass;
    otf1.ComponentName = 'on_the_fly_conv_r2';
    otf1.GenerateComponentName = 'ca_d';
    otf1.GenericName = {'total_bit', 'start_iteration'};
    otf1.GenericType = {'INTEGER', 'INTEGER'};
    otf1.GenericValue = {'total_bit', '-online_delay'};
    otf1.GenericAssignment = {'total_bit', '-online_delay'};
    otf1.PortName = {'x_p', 'x_n', 'j', 'x_out'};
    otf1.PortType = {'in', 'in', 'in', 'out'};
    otf1.PortDataType = {'BIT', 'BIT', 'INT', 'VEC'};
    otf1.PortWidth = {'0', '0', 'start_iteration to total_bit + start_iteration + 2', 'total_bit'};
    otf1.PortAssignment = {'d_p', 'd_n', 'j', 'd_out'};
    
    otf2 = VHDLParsorClass;
    otf2.ComponentName = 'on_the_fly_conv_r2';
    otf2.GenerateComponentName = 'ca_q';
    otf2.GenericName = {'total_bit', 'start_iteration'};
    otf2.GenericAssignment = {'total_bit', '0'};
    otf2.PortName = {'x_p', 'x_n', 'j', 'x_out'};
    otf2.PortAssignment = {'qp', 'qn', 'j', 'q_out'};
    
    U = VHDLParsorClass;
    U.ComponentName = 'u_comb';
    U.GenerateComponentName = 'u_comb_qs';
    U.GenericName = {'total_bit'};
    U.GenericType = {'INTEGER'};
    U.GenericValue = {'integer_bit + online_delay - 1'};
    U.GenericAssignment = {'integer_bit + online_delay - 1'};
    U.PortName = {'x_p', 'x_n', 'd_p', 'd_n', 'q_s', 'u'};
    U.PortType = {'in', 'in', 'in', 'in', 'in', 'out'};
    U.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT', 'BIT', 'VEC'};
    U.PortWidth = {'0', '0', '0', '0', '0,' 'total_bit - 1'};
    U.PortAssignment = {'x_p_d1', 'x_n_d1', 'd_p_d1', 'd_n_d1', 'q_temp(q_temp''high - online_delay)', 'u'};
    
    selm = VHDLParsorClass;
    selm.ComponentName = 'selm_div_r2';
    selm.GenerateComponentName = 'selm_div_v';
    selm.GenericName = {'total_bit'};
    selm.GenericType = {'INTEGER'};
    selm.GenericValue = {'used_bit'};
    selm.GenericAssignment = {'used_bit'};
    selm.PortName = {'v_est_in', 'q_p', 'q_n'};
    selm.PortDataType = {'VEC', pPortType, pPortType};
    selm.PortType = {'in', 'out', 'out'};
    selm.PortWidth = {'total_bit - 1', pPortWidth, pPortWidth};
    selm.PortAssignment = {'v_est_in', 'q_p_temp', 'q_n_temp'};
    
    dff1 = VHDLParsorClass; 
    dff1.PortName = {'d', 'clk', 'rst', 'q'};
    dff1.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT'};
    dff1.PortType = {'in', 'in', 'in', 'out'};
    dff1.ComponentName = 'd_ff';
    dff1.GenerateComponentName = 'latch_x_p';
    dff1.PortAssignment = {ODIV.PortName{1}, ODIV.PortName{5}, ODIV.PortName{6}, 'x_p_d1'};

    dff2 = VHDLParsorClass; 
    dff2.ComponentName = 'd_ff';
    dff2.GenerateComponentName = 'latch_x_n';
    dff2.PortName = dff1.PortName;
    dff2.PortAssignment = {ODIV.PortName{2}, ODIV.PortName{5}, ODIV.PortName{6}, 'x_n_d1'};

    dff3 = VHDLParsorClass; 
    dff3.ComponentName = 'd_ff';
    dff3.GenerateComponentName = 'latch_d_p';
    dff3.PortName = dff1.PortName;
    dff3.PortAssignment = {ODIV.PortName{3}, ODIV.PortName{5}, ODIV.PortName{6}, 'd_p_d1'};

    dff4 = VHDLParsorClass; 
    dff4.ComponentName = 'd_ff';
    dff4.GenerateComponentName = 'latch_d_n';
    dff4.PortName = dff1.PortName;
    dff4.PortAssignment = {ODIV.PortName{4}, ODIV.PortName{5}, ODIV.PortName{6}, 'd_n_d1'};
    
    HeaderBuffer = CreateHeader(ODIV);
    EntityBuffer = CreateEntity(ODIV);
    SignalBuffer = CreateSignal(ODIV);
    ComponentBuffer = [CreateComponent(csa1), ' ', CreateComponent(cpa), ' ', CreateComponent(dff1), ' ', CreateComponent(selm), ' ', CreateComponent(otf1), ' ', CreateComponent(U)];
    InitialiseBuffer = [InitialiseComponent(csa1), ' ', InitialiseComponent(csa2), ' ', InitialiseComponent(cpa), ' ', InitialiseComponent(selm), ' ', InitialiseComponent(otf1), ' ', InitialiseComponent(otf2), ' ', InitialiseComponent(U), ' ', InitialiseComponent(dff1), ' ', InitialiseComponent(dff2), ' ', InitialiseComponent(dff3), ' ', InitialiseComponent(dff4)];
    
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
    ArchitectureBuffer = [ArchitectureBuffer, ' '];  
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'q_p <= qp;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'q_n <= qn;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'd_not_temp <= not d_temp;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'q_not_temp <= not q_temp;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' ']; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'q_mult_digit_d(q_mult_digit_d''high downto total_bit - online_delay + 1) <= u;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'q_mult_digit_d(total_bit - online_delay downto 0) <= q_not_temp(total_bit - online_delay - 1 downto 0) & q_not_temp(0) when d_p_d1 = ''1'' and d_n_d1 = ''0'' and q_temp(q_temp''high - online_delay) = ''0'' else ']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(57) 'q_temp(total_bit - online_delay - 1 downto 0) & q_temp(0) when d_p_d1 = ''0'' and d_n_d1 = ''1'' and q_temp(q_temp''high - online_delay) = ''1'' else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(57) '(others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];  
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'd_mult_digit_q <= d_not_temp(d_not_temp''high) & d_not_temp when qp = ''1'' and qn = ''0'' else ']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(22) 'd_temp(d_temp''high) & d_temp when qp = ''0'' and qn = ''1'' else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(22) '(others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, ' ']; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'cd <= ''1'' when d_p_d1 = ''1'' and d_n_d1 = ''0'' and q_temp(q_temp''high - online_delay) = ''0'' else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(10) '''1'' when d_p_d1 = ''0'' and d_n_d1 = ''1'' and q_temp(q_temp''high - online_delay) = ''1'' else ']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(10) '''0'';']];
    ArchitectureBuffer = [ArchitectureBuffer, ' ']; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'cq <= ''1'' when qp = ''1'' and qn = ''0'' and d_temp(d_temp''high) = ''0'' else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(10) '''1'' when qp = ''0'' and qn = ''1'' and d_temp(d_temp''high) = ''1'' else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(10) '''0'';']];
    ArchitectureBuffer = [ArchitectureBuffer, ' ']; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'qp <= ''0'' when j < 0 else q_p_temp;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'qn <= ''0'' when j < 0 else q_n_temp;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' ']; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'vs_est <= vs(vs''high downto vs''high - truncate_bit - 1);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'vc_est <= vc(vc''high downto vc''high - truncate_bit - 1);']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'v_est_used <= v_est(v_est''high downto v_est''high - used_bit + 1);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'v_est_used_not <= not v_est(v_est''high downto v_est''high - used_bit + 1);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'v_est_in <= v_est_used when d_temp(d_temp''high) = ''0'' else v_est_used_not;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'process(' ODIV.PortName{5} ', ' ODIV.PortName{6} ')']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'begin']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'if RISING_EDGE(' ODIV.PortName{5} ') then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'if (' ODIV.PortName{6} ' = ''1'') then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'j <=  -online_delay - 1;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'if (j = total_bit - online_delay) then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'j <=  -online_delay - 1;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'j <= j + 1;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'for i in 0 to total_bit loop']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'if (j = i - online_delay - 1) then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'd_temp(total_bit downto total_bit - i) <= d_out(i downto 0);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'd_temp(total_bit - 1 - i downto 0) <= (others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'q_temp(total_bit downto total_bit - i) <= q_out(i downto 0);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'q_temp(total_bit - 1 - i downto 0) <= (others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'end loop;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end process;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'process(j)']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'begin']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'if (j = -online_delay - 1) then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'ws_reg <= (others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'wc_reg <= (others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'ws_reg <= ws(ws''high - 1 downto 0) & ws(0);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'wc_reg <= wc(wc''high - 1 downto 0) & ws(0);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end process;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, InitialiseBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];
    
    
    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end
          
    fclose(FileID);
    
    CreateCPA;
    CreateCSA_3_2;
    CreateDFF;
    CreateOTF;
    CreateSelmDiv(radix);
    CreateUComb;
    
end
