function [d_high, d_low] = digit_to_pair(d)
    if d == 1
        d_high = '1';
        d_low = '0';
    elseif d == -1
        d_high = '0';
        d_low = '1';
    else
        d_high = '0';
        d_low = '0';
    end
end