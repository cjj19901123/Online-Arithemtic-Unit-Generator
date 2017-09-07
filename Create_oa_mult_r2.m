%Create oa mult vhdl file
function Create_oa_mult_r2(radix, onlineDelay, precisionBit)
    [usedBit, t, ~] = SELM_mult(radix); 
    
    integerBit = log2(radix) + 1;
    
    if log2(radix) == 1
        pPortType = 'BIT';
        pPortWidth = '0';
    else
        pPortType = 'VEC';
        pPortWidth = intstr2(log2(radix) - 1);
    end
    
    FileName = 'oa_mult_r2';
    FileID = fopen([FileName '.vhd'], 'w');

    OMULT = VHDLParsorClass;
    OMULT.FileName = FileName;
    OMULT.GenericName = {'truncate_bit', 'online_delay', 'integer_bit', 'used_bit' 'total_bit'};
    OMULT.GenericType = {'INTEGER', 'INTEGER', 'INTEGER', 'INTEGER', 'INTEGER'};
    OMULT.GenericValue = {int2str(t), int2str(onlineDelay), int2str(integerBit), int2str(usedBit), int2str(precisionBit+onlineDelay)};
    OMULT.PortName = {'x_p', 'x_n', 'y_p', 'y_n', 'clk', 'rst', 'p_p' 'p_n'};
    OMULT.PortType = {'in', 'in', 'in', 'in', 'in', 'in', 'out', 'out'};
    OMULT.PortDataType = {pPortType, pPortType, pPortType, pPortType, 'BIT', 'BIT', pPortType, pPortType};
    OMULT.PortWidth = {pPortWidth, pPortWidth, pPortWidth, pPortWidth, '0', '0', pPortWidth, pPortWidth};
    
    OMULT.SignalName = {'j', 'x_out, x_out_not, x_temp, x_not_temp, y_out, y_out_not, y_temp, y_not_temp', 'vs, vc, ws, wc, ws_temp, wc_temp, x_mult_digit_y, y_mult_digit_x', 'vs_est, vc_est, v_est', 'x_unit_shift, x_not_unit_shift, y_unit_shift, y_not_unit_shift', 'cx, cy, x_p_d1, x_n_d1, y_p_d1, y_n_d1, v_sub_p_msb, p_abs, pp, pn'};
    OMULT.SignalWidth = {'-online_delay - 1 to total_bit - online_delay', 'total_bit', 'total_bit + integer_bit - 1', 'truncate_bit + 1', 'online_delay - 1', '0'};
    OMULT.SignalDataType = {'INT', 'VEC', 'VEC', 'VEC', 'VEC', 'BIT'};
    
    csa = VHDLParsorClass; 
    csa.ComponentName = 'parallel_4_2_csa';
    csa.GenerateComponentName = 'csa';
    csa.GenericName = {'total_bit'};
    csa.GenericType = {'INTEGER'};
    csa.GenericValue = {'total_bit + integer_bit - 1'};
    csa.GenericAssignment = {'total_bit + integer_bit - 1'};
    csa.PortName = {'x', 'y', 'w', 'z', 'c_x', 'c_y', 'vs' 'vc'};
    csa.PortType = {'in', 'in', 'in', 'in', 'in', 'in', 'out', 'out'};
    csa.PortDataType = {'VEC', 'VEC', 'VEC', 'VEC', 'BIT', 'BIT', 'VEC', 'VEC'};
    csa.PortWidth = {'total_bit', 'total_bit', 'total_bit', 'total_bit', '0', '0', 'total_bit', 'total_bit'};
    csa.PortAssignment = {'x_mult_digit_y', 'y_mult_digit_x', 'ws', 'wc', 'cx', 'cy', 'vs', 'vc'};
    
    cpa = VHDLParsorClass;
    cpa.ComponentName = 'cpa';
    cpa.GenerateComponentName = 'cpa_vest';
    cpa.GenericName = {'total_bit'};
    cpa.GenericType = {'INTEGER'};
    cpa.GenericValue = {'truncate_bit + 2'};
    cpa.GenericAssignment = {'truncate_bit + 2'};
    cpa.PortName = {'x', 'y', 'c_in', 's'};
    cpa.PortDataType = {'VEC', 'VEC', 'BIT', 'VEC'};
    cpa.PortType = {'in', 'in', 'in', 'out'};
    cpa.PortWidth = {'total_bit - 1', 'total_bit - 1', '0', 'total_bit - 1'};
    cpa.PortAssignment = {'vs_est', 'vc_est', '''0''', 'v_est'};
    
    selm = VHDLParsorClass;
    selm.ComponentName = 'selm_mult_r2';
    selm.GenerateComponentName = 'selm_mult_v';
    selm.GenericName = {'total_bit'};
    selm.GenericType = {'INTEGER'};
    selm.GenericValue = {'used_bit'};
    selm.GenericAssignment = {'used_bit'};
    selm.PortName = {'v_est_in', 'p_p', 'p_n'};
    selm.PortDataType = {'VEC', pPortType, pPortType};
    selm.PortType = {'in', 'out', 'out'};
    selm.PortWidth = {'total_bit - 1', pPortWidth, pPortWidth};
    selm.PortAssignment = {'v_est(v_est''high downto v_est''high - used_bit + 1)', 'pp', 'pn'};
    
    otf1 = VHDLParsorClass;
    otf1.ComponentName = 'on_the_fly_conv_r2';
    otf1.GenerateComponentName = 'ca_x';
    otf1.GenericName = {'total_bit', 'start_iteration'};
    otf1.GenericType = {'INTEGER', 'INTEGER'};
    otf1.GenericValue = {'total_bit', '-online_delay - 1'};
    otf1.GenericAssignment = {'total_bit', '-online_delay - 1'};
    otf1.PortName = {'x_p', 'x_n', 'j', 'x_out', 'x_out_not'};
    otf1.PortType = {'in', 'in', 'in', 'out', 'out'};
    otf1.PortDataType = {'BIT', 'BIT', 'INT', 'VEC', 'VEC'};
    otf1.PortWidth = {'0', '0', 'start_iteration to total_bit + start_iteration + 2', 'total_bit', 'total_bit'};
    otf1.PortAssignment = {'x_p_d1', 'x_n_d1', 'j', 'x_out', 'x_out_not'};
    
    otf2 = VHDLParsorClass;
    otf2.ComponentName = 'on_the_fly_conv_r2';
    otf2.GenerateComponentName = 'ca_y';
    otf2.GenericName = {'total_bit', 'start_iteration'};
    otf2.GenericAssignment = {'total_bit', '-online_delay - 1'};
    otf2.PortName = {'x_p', 'x_n', 'j', 'x_out', 'x_out_not'};
    otf2.PortAssignment = {'y_p', 'y_n', 'j', 'y_out', 'y_out_not'};
    
    dff1 = VHDLParsorClass; 
    dff1.PortName = {'d', 'clk', 'rst', 'q'};
    dff1.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT'};
    dff1.PortType = {'in', 'in', 'in', 'out'};
    dff1.ComponentName = 'd_ff';
    dff1.GenerateComponentName = 'latch_x_p';
    dff1.PortAssignment = {OMULT.PortName{1}, OMULT.PortName{5}, OMULT.PortName{6}, 'x_p_d1'};

    dff2 = VHDLParsorClass; 
    dff2.ComponentName = 'd_ff';
    dff2.GenerateComponentName = 'latch_x_n';
    dff2.PortName = dff1.PortName;
    dff2.PortAssignment = {OMULT.PortName{2}, OMULT.PortName{5}, OMULT.PortName{6}, 'x_n_d1'};

    dff3 = VHDLParsorClass; 
    dff3.ComponentName = 'd_ff';
    dff3.GenerateComponentName = 'latch_y_p';
    dff3.PortName = dff1.PortName;
    dff3.PortAssignment = {OMULT.PortName{3}, OMULT.PortName{5}, OMULT.PortName{6}, 'y_p_d1'};

    dff4 = VHDLParsorClass; 
    dff4.ComponentName = 'd_ff';
    dff4.GenerateComponentName = 'latch_y_n';
    dff4.PortName = dff1.PortName;
    dff4.PortAssignment = {OMULT.PortName{4}, OMULT.PortName{5}, OMULT.PortName{6}, 'y_n_d1'};
    
    HeaderBuffer = CreateHeader(OMULT);
    EntityBuffer = CreateEntity(OMULT);
    SignalBuffer = CreateSignal(OMULT);
    ComponentBuffer = [CreateComponent(csa), ' ', CreateComponent(cpa), ' ', CreateComponent(dff1), ' ', CreateComponent(selm), ' ', CreateComponent(otf1)];
    InitialiseBuffer = [InitialiseComponent(csa), ' ', InitialiseComponent(cpa), ' ', InitialiseComponent(selm), ' ', InitialiseComponent(otf1), ' ', InitialiseComponent(otf2), ' ', InitialiseComponent(dff1), ' ', InitialiseComponent(dff2), ' ', InitialiseComponent(dff3), ' ', InitialiseComponent(dff4), ' '];
    
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
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'p_p <= pp;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'p_n <= pn;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' ']; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'x_unit_shift <= (others => ''0'') when x_temp(x_temp''high) = ''0'' else (others => ''1'');']]; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'x_not_unit_shift <= (others => ''0'') when x_not_temp(x_not_temp''high) = ''0'' else (others => ''1'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'y_unit_shift <= (others => ''0'') when y_temp(y_temp''high) = ''0'' else (others => ''1'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'y_not_unit_shift <= (others => ''0'') when y_not_temp(y_not_temp''high) = ''0'' else (others => ''1'');']];
    ArchitectureBuffer = [ArchitectureBuffer, ' ']; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'x_mult_digit_y <= x_unit_shift & x_temp(total_bit - 1 downto online_delay) & "00" when y_p_d1 = ''1'' and y_n_d1 = ''0'' else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(22) 'x_not_unit_shift & x_not_temp(total_bit - 1 downto online_delay) & "11" when y_p_d1 = ''0'' and y_n_d1 = ''1'' else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(22) '(others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, ' ']; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'y_mult_digit_x <= y_unit_shift & y_temp(total_bit downto online_delay) & ''0'' when x_p_d1 = ''1'' and x_n_d1 = ''0'' else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(22) 'y_not_unit_shift & y_not_temp(total_bit downto online_delay) & ''1'' when x_p_d1 = ''0'' and x_n_d1 = ''1'' else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(22) '(others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, ' ']; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'cx <= ''1'' when x_p_d1 = ''0'' and x_n_d1 = ''1'' else ''0'';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'cy <= ''1'' when y_p_d1 = ''0'' and y_n_d1 = ''1'' else ''0'';']];
    ArchitectureBuffer = [ArchitectureBuffer, ' ']; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'p_abs <= ''0'' when pp = ''0'' and pn = ''0'' else ''1'';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'v_sub_p_msb <= v_est(v_est''high - integer_bit + 1) xor p_abs;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'vs_est <= vs(vs''high downto vs''high - truncate_bit - integer_bit + 1);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'vc_est <= vc(vc''high downto vc''high - truncate_bit - integer_bit + 1);']];
    ArchitectureBuffer = [ArchitectureBuffer, ' ']; 
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'ws_temp <= v_sub_p_msb & v_est(v_est''high - integer_bit downto 0) & vs(vs''high - truncate_bit - integer_bit downto 0) & ''0'';']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'wc_temp(wc_temp''high downto wc_temp''high - truncate_bit) <= (others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'wc_temp(wc_temp''high - truncate_bit - 1 downto 0) <= vc(vc''high - truncate_bit - integer_bit downto 0) & ''0'';']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'process(' OMULT.PortName{5} ', ' OMULT.PortName{6} ')']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'begin']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'if RISING_EDGE(' OMULT.PortName{5} ') then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'if (' OMULT.PortName{6} ' = ''1'') then']];
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
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'x_temp(total_bit downto total_bit - i) <= x_out(i downto 0);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'x_temp(total_bit - 1 - i downto 0) <= (others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'x_not_temp(total_bit downto total_bit - i) <= x_out_not(i downto 0);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'x_not_temp(total_bit - 1 - i downto 0) <= (others => ''1'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'y_temp(total_bit downto total_bit - i) <= y_out(i downto 0);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'y_temp(total_bit - 1 - i downto 0) <= (others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'y_not_temp(total_bit downto total_bit - i) <= y_out_not(i downto 0);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(20) 'y_not_temp(total_bit - 1 - i downto 0) <= (others => ''1'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(16) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'end loop;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'end if;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end process;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'process(j)']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'begin']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'if (j = -online_delay - 1) then']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'ws <= (others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'wc <= (others => ''0'');']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'else']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'ws <= ws_temp;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'wc <= wc_temp;']];
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
    CreateCSA_4_2;
    CreateDFF;
    CreateOTF;
    CreateSelmMult(radix);
end