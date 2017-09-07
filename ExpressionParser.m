%Evaluate the input expression
%The port connection of the OA arithmetic componnets and delay units are stored in buffers below 
function [prefixExp, tokenList, addStack, multStack, divStack, constantStack, totalOnlineDelay, delayUnitStack, rstDelayUnit, expressionStack, opStack, delayStack] = ExpressionParser(expression)
    exp = InfixToPrefixConv;
    %remove the integer part of numeric input
    expression = expression(~isspace(expression));
    for i = length(expression) : -1 : 2
        if expression(i) == '.'
            for j = i-1 : -1 : 1
                if isNum(exp, expression(j)) == true
                    expression(j) = '';
                else
                    break;
                end
            end
        end                 
    end
    
    exp.InfixExp = expression;
    prefixExp = CreatePrefixExp(exp);
    tokenList = cellstr(prefixExp')';
    
    % merge numeric digits from adjacent cells to a decimal in one cell
    for i = 1 : length(tokenList)-1
        if tokenList{i} == '.'
            tokenList{i} = '0.';
            for j = i+1 : length(tokenList)
                if and(isNum(exp, tokenList{j}) == true, tokenList{j} ~= '.')
                    tokenList{i} = strcat(tokenList{i}, tokenList{j});
                    tokenList{j} = [];
                else
                    break
                end
            end  
        end
    end
    tokenList = tokenList(~cellfun('isempty',tokenList));
    expressionStack = tokenList;
    
    %stacks to store signals to construct components for +, *, /
    %constant stack stores the fixed input data
    addNum = 0;
    multNum = 0;
    divNum = 0;
    constNum = 0;
    for k = 1:length(tokenList)
        if tokenList{k} == '+'
            addNum = addNum + 1;
        elseif tokenList{k} == '-'
            addNum = addNum + 1;
        elseif tokenList{k} == '*'   
            multNum = multNum + 1;
        elseif tokenList{k} == '/' 
            divNum = divNum + 1;
        else
            if tokenList{k}(1) == '0'
                constNum = constNum + 1;
            end
        end
    end
    
    %operation stack stores the informations to generate components
    %the last cell in rows of mult/div stores the online delay after retiming
    addStack = cell(addNum, 8);
    multStack = cell(multNum, 9);
    divStack = cell(divNum, 9);
    %constant stores the constant name and constant value
    constantStack = cell(constNum, 2);
    
    opNum = addNum + multNum + divNum;
    %opStack stores operations operand in order after parsing
    opStack = cell(opNum, 4);
    %delayStack stores delays of both operands in order 
    delayStack = cell(opNum, 3);
    
    %default online delay for +,*,/
    multDelay = 3;
    divDelay = 4;
    addDelay = 2;
    
    size = length(tokenList);
    %initilise the number of omponents for +,*,/,constant and delay unit
    s = 1;
    p = 1;
    q = 1;
    op = 1;
    const = 1;
    delayNum = 1;
    rstDelayUnit = 0;
    
    %some expressions have synchronous operands by default
    %for single-op case, syn by default
    %for part of multi-op cases, operand are syn by default, such as (a+b)*(c+d)
    %for other cases, it needs adding extra delays to retime the circuit 
    
    %two steps to syn an arithmetic expression
    %1st step: syn oprand of any operations
    %if one operand have a delay greater than the other
    %delay the other operand to make both operands have same delay before perform any operations
    %2nd step: syn the result after mult and div 
    %product/div result needs to be retimed if two adjacent operations are dependent. 
    
    %for example add-mult: (a+b)*c
    %1st step: delay the operand c by 2 cycle
    %2nd step: delay the rst signal of mult by n unit, n is 1 unit less than the delay of input operand, 1 cycle delay in this case
    %3rd step: reduce online delay of mult by 1 to compensate the rst 

    for i = size : -1 : 1
        token = tokenList{i};
        if token == '+'   
            opStack(op,:) = {tokenList{i+1}, tokenList{i+2}, ['s_' int2str(s)], addDelay};
            delayStack = checkOpDelay(delayStack, opStack, op);
            %retiming
            if delayStack{op, 1} > delayStack{op, 2}       %if delay of 1st operand > 2nd operand
                delay = int2str(delayStack{op, 1} - delayStack{op, 2});
                delayUnit{delayNum,:} = {[tokenList{i+2} '_p'], delay, [tokenList{i+2} '_p_d' delay]};
                delayUnit{delayNum+1,:} = {[tokenList{i+2} '_n'], delay, [tokenList{i+2} '_n_d' delay]};
                addStack(s,:) = {[tokenList{i+1} '_p'], [tokenList{i+1} '_n'], [tokenList{i+2} '_p_d' delay], [tokenList{i+2} '_n_d' delay], 'clk', 'rst', ['s_' int2str(s) '_p'], ['s_' int2str(s) '_n']};
                delayNum = delayNum + 2;
            elseif delayStack{op, 1} < delayStack{op, 2}             %if delay of 1st operand < 2nd operand
                delay = int2str(delayStack{op, 2} - delayStack{op, 1});
                delayUnit{delayNum,:} = {[tokenList{i+1} '_p'], delay, [tokenList{i+1} '_p_d' delay]};
                delayUnit{delayNum+1,:} = {[tokenList{i+1} '_n'], delay, [tokenList{i+1} '_n_d' delay]};
                addStack(s,:) = {[tokenList{i+1} '_p_d' delay], [tokenList{i+1} '_n_d' delay], [tokenList{i+2} '_p'], [tokenList{i+2} '_n'], 'clk', 'rst', ['s_' int2str(s) '_p'], ['s_' int2str(s) '_n']};
                delayNum = delayNum + 2;      
            else %if delay of 1st operand = 2nd operand  
                addStack(s,:) = {[tokenList{i+1} '_p'], [tokenList{i+1} '_n'], [tokenList{i+2} '_p'], [tokenList{i+2} '_n'], 'clk', 'rst', ['s_' int2str(s) '_p'], ['s_' int2str(s) '_n']};
                delayUnit{delayNum, :} = {};
            end
            %append the expression
            tokenList{i} = ['s_' int2str(s)];
            tokenList{i+1} = [];
            tokenList{i+2} = [];
            tokenList = tokenList(~cellfun('isempty',tokenList));
            s = s + 1;        %number of sum + 1
            op = op + 1;      %number of all operations + 1 
        elseif token == '-'
            %for adder in borrow save form, s = x_p - x_n + y_p - y_n
            %for subtractor, s = x_p - x_n + y_n - y_p
            opStack(op,:) = {tokenList{i+1}, tokenList{i+2}, ['s_' int2str(s)], addDelay};        
            delayStack = checkOpDelay(delayStack , opStack, op);
            if delayStack{op, 1} > delayStack{op, 2}
                delay = int2str(delayStack{op, 1} - delayStack{op, 2});
                delayUnit{delayNum,:} = {[tokenList{i+2} '_p'], delay, [tokenList{i+2} '_p_d' delay]};
                delayUnit{delayNum+1,:} = {[tokenList{i+2} '_n'], delay, [tokenList{i+2} '_n_d' delay]};
                addStack(s,:) = {[tokenList{i+1} '_p'], [tokenList{i+1} '_n'], [tokenList{i+2} '_n_d' delay], [tokenList{i+2} '_p_d' delay], 'clk', 'rst', ['s_' int2str(s) '_p'], ['s_' int2str(s) '_n']};
                delayNum = delayNum + 2;
            elseif delayStack{op, 1} < delayStack{op, 2}
                delay = int2str(delayStack{op, 2} - delayStack{op, 1});
                delayUnit{delayNum,:} = {[tokenList{i+1} '_p'], delay, [tokenList{i+1} '_p_d' delay]};
                delayUnit{delayNum+1,:} = {[tokenList{i+1} '_n'], delay, [tokenList{i+1} '_n_d' delay]};
                addStack(s,:) = {[tokenList{i+1} '_p_d' delay], [tokenList{i+1} '_n_d' delay], [tokenList{i+2} '_p'], [tokenList{i+2} '_n'], 'clk', 'rst', ['s_' int2str(s) '_p'], ['s_' int2str(s) '_n']};
                delayNum = delayNum + 2;
            else
                addStack(s,:) = {[tokenList{i+1} '_p'], [tokenList{i+1} '_n'], [tokenList{i+2} '_n'], [tokenList{i+2} '_p'], 'clk', 'rst', ['s_' int2str(s) '_p'], ['s_' int2str(s) '_n']};
                delayUnit{delayNum, :} = {};
            end
            tokenList{i} = ['s_' int2str(s)];
            tokenList{i+1} = [];
            tokenList{i+2} = [];
            tokenList = tokenList(~cellfun('isempty',tokenList));
            s = s + 1;
            op = op + 1;
        elseif token == '*'
            opStack(op,:) = {tokenList{i+1}, tokenList{i+2}, ['p_' int2str(p)], multDelay};
            delayStack = checkOpDelay(delayStack, opStack, op);
            if delayStack{op, 1} > delayStack{op, 2}
                delay = int2str(delayStack{op, 1} - delayStack{op, 2});
                delayUnit{delayNum,:} = {[tokenList{i+2} '_p'], delay, [tokenList{i+2} '_p_d' delay]};
                delayUnit{delayNum+1,:} = {[tokenList{i+2} '_n'], delay, [tokenList{i+2} '_n_d' delay]};
                rstDelayUnit = delayStack{op, 1}-1;
                multStack(p,:) = {[tokenList{i+1} '_p'], [tokenList{i+1} '_n'], [tokenList{i+2} '_p_d' delay], [tokenList{i+2} '_n_d' delay], 'clk', ['rst_d' int2str(rstDelayUnit)], ['p_' int2str(p) '_p'], ['p_' int2str(p) '_n'], multDelay-1};
                delayNum = delayNum + 2; 
            elseif delayStack{op, 1} < delayStack{op, 2}
                delay = int2str(delayStack{op, 2} - delayStack{op, 1});
                delayUnit{delayNum,:} = {[tokenList{i+1} '_p'], delay, [tokenList{i+1} '_p_d' delay]};
                delayUnit{delayNum+1,:} = {[tokenList{i+1} '_n'], delay, [tokenList{i+1} '_n_d' delay]};
                rstDelayUnit = delayStack{op, 2}-1;
                multStack(p,:) = {[tokenList{i+1} '_p_d' delay], [tokenList{i+1} '_n_d' delay], [tokenList{i+2} '_p'], [tokenList{i+2} '_n'], 'clk', ['rst_d' int2str(rstDelayUnit)], ['p_' int2str(p) '_p'], ['p_' int2str(p) '_n'], multDelay-1};
                delayNum = delayNum + 2;
            else
                if delayStack{op, 1} == 0 
                    %no need retiming for mult/div only if both operands has 0 delay 
                    multStack(p,:) = {[tokenList{i+1} '_p'], [tokenList{i+1} '_n'], [tokenList{i+2} '_p'], [tokenList{i+2} '_n'], 'clk', 'rst', ['p_' int2str(p) '_p'], ['p_' int2str(p) '_n'], multDelay};                   
                else
                    rstDelayUnit = delayStack{op, 1}-1;
                    multStack(p,:) = {[tokenList{i+1} '_p'], [tokenList{i+1} '_n'], [tokenList{i+2} '_p'], [tokenList{i+2} '_n'], 'clk', ['rst_d' int2str(rstDelayUnit)], ['p_' int2str(p) '_p'], ['p_' int2str(p) '_n'], multDelay-1};
                end
                delayUnit{delayNum, :} = {};
            end
            
            tokenList{i} = ['p_' int2str(p)];
            tokenList{i+1} = [];
            tokenList{i+2} = [];
            tokenList = tokenList(~cellfun('isempty',tokenList));
            p = p + 1;
            op = op + 1;
        elseif token == '/' 
            opStack(op,:) = {tokenList{i+1}, tokenList{i+2}, ['q_' int2str(q)], divDelay};
            delayStack = checkOpDelay(delayStack, opStack, op);
            
            if delayStack{op, 1} > delayStack{op, 2}
                delay = int2str(delayStack{op, 1} - delayStack{op, 2});
                delayUnit{delayNum,:} = {[tokenList{i+2} '_p'], delay, [tokenList{i+2} '_p_d' delay]};
                delayUnit{delayNum+1,:} = {[tokenList{i+2} '_n'], delay, [tokenList{i+2} '_n_d' delay]};
                rstDelayUnit = delayStack{op, 1}-1;
                divStack(q,:) = {[tokenList{i+1} '_p'], [tokenList{i+1} '_n'], [tokenList{i+2} '_p_d' delay], [tokenList{i+2} '_n_d' delay], 'clk', ['rst_d' int2str(rstDelayUnit)], ['q_' int2str(q) '_p'], ['q_' int2str(q) '_n'], divDelay+1};
                delayNum = delayNum + 2;
            elseif delayStack{op, 1} < delayStack{op, 2}
                delay = int2str(delayStack{op, 2} - delayStack{op, 1});
                delayUnit{delayNum,:} = {[tokenList{i+1} '_p'], delay, [tokenList{i+1} '_p_d' delay]};
                delayUnit{delayNum+1,:} = {[tokenList{i+1} '_n'], delay, [tokenList{i+1} '_n_d' delay]};
                rstDelayUnit = delayStack{op, 2}-1;
                divStack(q,:) = {[tokenList{i+1} '_p_d' delay], [tokenList{i+1} '_n_d' delay], [tokenList{i+2} '_p'], [tokenList{i+2} '_n'], 'clk', ['rst_d' int2str(rstDelayUnit)], ['q_' int2str(q) '_p'], ['q_' int2str(q) '_n'], divDelay+1};
                delayNum = delayNum + 2;
            else
                if delayStack{op, 1} == 0 
                    divStack(q,:) = {[tokenList{i+1} '_p'], [tokenList{i+1} '_n'], [tokenList{i+2} '_p'], [tokenList{i+2} '_n'], 'clk', 'rst', ['q_' int2str(q) '_p'], ['q_' int2str(q) '_n'], divDelay};
                else
                    rstDelayUnit = delayStack{op, 1}-1;
                    divStack(q,:) = {[tokenList{i+1} '_p'], [tokenList{i+1} '_n'], [tokenList{i+2} '_p'], [tokenList{i+2} '_n'], 'clk', ['rst_d' int2str(rstDelayUnit)], ['q_' int2str(q) '_p'], ['q_' int2str(q) '_n'], divDelay+1};
                end
                delayUnit{delayNum, :} = {};
            end
            
            tokenList{i} = ['q_' int2str(q) ];
            tokenList{i+1} = [];
            tokenList{i+2} = [];
            tokenList = tokenList(~cellfun('isempty',tokenList));
            q = q + 1;
            op = op + 1;
        elseif token(1) == '0'
            constantStack(const,:) = {['num_' int2str(const)], token};
            tokenList{i} = ['num_', int2str(const)]; 
            const = const + 1;
        end       
    end
    
    if opNum == 1 
        delayUnitStack = {};
    elseif isempty(delayUnit{1}) == true 
        delayUnitStack = {};
    else
        delayUnitStack = delayUnit; 
    end
    
    totalOnlineDelay = delayStack{end}; %total online delay
    
end