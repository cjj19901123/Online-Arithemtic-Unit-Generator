function createDataShift(precisionBit, onlineDelay)
    FileName = 'case_mult';
    FileID = fopen([FileName '.txt'], 'w');
    
    caseBuffer = {};
    caseBuffer = [caseBuffer, [blanks(4) 'process(j)']];
    caseBuffer = [caseBuffer, [blanks(4) 'begin']];
    caseBuffer = [caseBuffer, [blanks(8) 'case j is']];
    for k = -onlineDelay : precisionBit-2
        a = num2str(k+3);
        b = num2str(k+4);
        caseBuffer = [caseBuffer, [blanks(12), 'when ' num2str(k) ' =>']];
        caseBuffer = [caseBuffer, [blanks(16), 'x_temp(total_bit downto total_bit-' a  ') <= x_out(' a ' downto 0);']];
        caseBuffer = [caseBuffer, [blanks(16), 'x_temp(total_bit-' b ' downto 0) <= (others => ''0'');']];
        caseBuffer = [caseBuffer, [blanks(16), 'x_not_temp(total_bit downto total_bit-' a  ') <= x_out_not(' a ' downto 0);']];
        caseBuffer = [caseBuffer, [blanks(16), 'x_not_temp(total_bit-' b ' downto 0) <= (others => ''1'');']];
        caseBuffer = [caseBuffer, [blanks(16), 'y_temp(total_bit downto total_bit-' a  ') <= y_out(' a ' downto 0);']];
        caseBuffer = [caseBuffer, [blanks(16), 'y_temp(total_bit-' b ' downto 0) <= (others => ''0'');']];
        caseBuffer = [caseBuffer, [blanks(16), 'y_not_temp(total_bit downto total_bit-' a  ') <= y_out_not(' a ' downto 0);']];
        caseBuffer = [caseBuffer, [blanks(16), 'y_not_temp(total_bit-' b ' downto 0) <= (others => ''1'');']];
    end
    caseBuffer = [caseBuffer, [blanks(12), 'when ' num2str(precisionBit-1) ' =>']];
    caseBuffer = [caseBuffer, [blanks(16), 'x_temp <= x_out;']];
    caseBuffer = [caseBuffer, [blanks(16), 'x_not_temp <= x_out_not;']];
    caseBuffer = [caseBuffer, [blanks(16), 'y_temp <= y_out;']];
    caseBuffer = [caseBuffer, [blanks(16), 'y_not_temp <= y_out_not;']];
    caseBuffer = [caseBuffer, [blanks(12), 'when others =>']];
    caseBuffer = [caseBuffer, [blanks(16), 'x_temp <= (others => ''0'');']];
    caseBuffer = [caseBuffer, [blanks(16), 'x_not_temp <= (others => ''1'');']];
    caseBuffer = [caseBuffer, [blanks(16), 'y_temp <= (others => ''0'');']];
    caseBuffer = [caseBuffer, [blanks(16), 'y_not_temp <= (others => ''1'');']];
    caseBuffer = [caseBuffer, [blanks(8), 'end case;']];
    caseBuffer = [caseBuffer, [blanks(4), 'end process;']];
    
    for k = 1: length(caseBuffer)
        fprintf(FileID,'%s\n', caseBuffer{k});
    end
end