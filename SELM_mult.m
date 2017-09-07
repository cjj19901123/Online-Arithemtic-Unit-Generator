%slection function for mult

function [usedBit, t, pArray] = SELM_mult(radix)
    a = radix - 1;
    rho = a/(radix-1);  
    radixPower = log2(radix);
    
    if a == 1
        onlineDelay = 3;
    elseif a == 2
        onlineDelay = 3;
    else
        onlineDelay = 2;
    end
    
    w = rho*(1-2*(radix^-onlineDelay));
    
    N = 100;
    for t = 1 : N 
        bound1 = fi(w, 1, t + 1, t);
        bound2 = 0.5 + 2^(-t-1);
        if bound1 >= bound2
            break
        end
    end
    
    totalBit = radixPower + 1 + t;
    
    U = -rho*(radix - 2*(radix^-onlineDelay)) - 2^(-t+1);
    L = rho*(radix - 2*(radix^-onlineDelay));
    UB = data(fi(U, 1, totalBit, t));
    LB = data(fi(L, 1, totalBit, t));
    m0 = data(fi(w - 1 - 2^(-t), 1, t, t));
    m = abs(m0);
    
    usedBit = -log2(m) + radixPower + 1;
   
    v =  [0 : m : LB, UB : m : -m];
    
    for i = 1 : length(v)
        for k = -a : a
            if k == -a
                Lk = data(fi(w + k - 2^(-t), 1, totalBit, t));
                if v(i) < Lk
                    p{i} = k;
                end   
            elseif k == a
                Uk = data(fi(w + k - 1 - 2^(-t), 1, totalBit, t));
                if v(i) >= Uk
                    p{i} = k;
                end   
            else
                Uk = data(fi(w + k - 1 - 2^(-t), 1, totalBit+1, t));
                Lk = data(fi(w + k - 2^(-t) + m, 1, totalBit+1, t));
                if and (v(i) < Lk, v(i) >= Uk)
                    p{i} = k;
                end   
            end                 
        end
    end
    
    pArray = cell(2, length(p));
    
    for j = 1 : length(p)
       for k = 1 : a
            switch(p{j})
            case k
                pArray{1, j} = dec2bin(k, radixPower);
                pArray{2, j} = dec2bin(0, radixPower);
            case -k
                pArray{1, j} = dec2bin(0, radixPower);
                pArray{2, j} = dec2bin(k, radixPower);
            case 0
                pArray{1, j} = dec2bin(0, radixPower);
                pArray{2, j} = dec2bin(0, radixPower);
            otherwise
                pArray{1, j} = pArray{1, j};
                pArray{2, j} = pArray{2, j};
            end
        end
    end            
                 
end