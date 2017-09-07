function d = pair_to_digit(d_p, d_n)
    if and(d_p == '1', d_n == '0')
        d = 1;
    elseif and(d_p == '0', d_n == '1')
        d = -1;
    else
        d = 0;
    end
end