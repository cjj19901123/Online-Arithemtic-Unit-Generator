function [RandNum, digit_p, digit_n] = redundantRandGenerate(precision, totalOnlineDelay)
    RandNum_P = rand(1); 
    RandNum_N = rand(1); 
    RandNum = 0; 
    % convert rand num from decimal to binary in borrow-save form
    digit_p = pad(dec2bin(RandNum_P*2^precision, precision), precision + totalOnlineDelay, 'right', '0');
    digit_n = pad(dec2bin(RandNum_N*2^precision, precision), precision + totalOnlineDelay, 'right', '0');
    for k = 1 : precision
        digit = pair_to_digit(digit_p(k), digit_n(k)); %convert to redundant representation
        RandNum = RandNum + digit*2^-k; %convert back to decimal in conventional form
    end
end