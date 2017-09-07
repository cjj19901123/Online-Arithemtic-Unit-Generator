function [DelayStack] = checkOpDelay(DelayStack, opStack, opNum)
    opDelay = opStack{opNum, end}; 
    tokenList1 = opStack{opNum, 1};
    tokenList2 = opStack{opNum, 2};
    if and(length(tokenList1)== 1, length(tokenList2)== 1) % both operand are input symbolic variable
        DelayStack(opNum, :) = {0, 0, opDelay};  %the delays of both operands are zero
    elseif and(length(tokenList1)== 1, length(tokenList2)~= 1)  %2nd operand is not input symbolic variable 
        if tokenList2(1) == 'n'  %2nd operand is a input symbolic number
            DelayStack(opNum, :) = {0, 0, opDelay};  %the delay of operand is zero
        else % 2nd operand is the result produced by previous operations 
            DelayStack(opNum, :) = {0, DelayStack{opNum-1, end}, DelayStack{opNum-1, end} + opDelay}; %add the online delay of operation to the operand
        end
    elseif and(length(tokenList1)~= 1, length(tokenList2)== 1)  %1st operand is not input symbolic variable       
        if tokenList1(1) == 'n'
            DelayStack(opNum, :) = {0, 0, opDelay};
        else
            DelayStack(opNum, :) = {DelayStack{opNum-1, end}, 0, DelayStack{opNum-1, end} + opDelay};
        end
    else %both oprand are not symbolic variable
        if and(tokenList1(1) == 'n', tokenList2(1) == 'n') 
            DelayStack(opNum, :) = {0, 0, opDelay};
        elseif and(tokenList1(1) == 'n', tokenList2(1) ~= 'n') 
            DelayStack(opNum, :) = {0, DelayStack{opNum-1, end}, DelayStack{opNum-1, end} + opDelay};
        elseif and(tokenList1(1) ~= 'n', tokenList2(1) == 'n') 
            DelayStack(opNum, :) = {DelayStack{opNum-1, end}, 0, DelayStack{opNum-1, end} + opDelay};
        else 
            for i = opNum-1: -1 : 1
                if tokenList1 == opStack{i, 3}
                    DelayStack{opNum, 1} = DelayStack{i, 3};
                    break;
                end
            end

            for j = opNum-1: -1 : 1
                if tokenList2 == opStack{j, 3}
                    DelayStack{opNum, 2} = DelayStack{j, 3};
                    break;
                end
            end

            if DelayStack{opNum, 1} >= DelayStack{opNum, 2}
                DelayStack{opNum, 3} = DelayStack{opNum, 1} + opDelay;
            else
                DelayStack{opNum, 3} = DelayStack{opNum, 2} + opDelay;
            end
        end
    end
end