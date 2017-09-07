function [Decimal_Input, digitBuffer, Decimal_Output] = SymbolicComputation(NumOfRd, ExpressionBuffer, var, precision, totalOnlineDelay)
   %the input and output of the any online arithmeitc operations should be bounded between -1 and 1    
    %Generate 10 paris of random numbers in borrow-save form  
    %Compute the result of expression using Symbolic Expression 
    %If the generated random number is out of the bounding, re-generate
    %store the bounded random numbers in digitbuffer for waveform generation

    j = 1;
    while j <= NumOfRd
        inputTest = true;
        tokenList = ExpressionBuffer;
        
        for k = 1 : length(var)
            [RandBuffer{k,j}, digitBuffer{2*k-1, j}, digitBuffer{2*k, j}] = redundantRandGenerate(precision, totalOnlineDelay);
        end
        
        for i = length(ExpressionBuffer) : -1 : 1
            token = tokenList{i};
            if token == '+'   
                f = tokenList{i+1} + tokenList{i+2}; %create symbolic function for adder
                for m = 1 : length(var)
                    f = subs(f, var{m}, RandBuffer{m,j}); %symbolic function substitude
                end
                
                if checkInputNum(f) == false %check if the result is between 1 and -1
                    inputTest = false; 
                    break;
                end
                
                tokenList{i} = vpa(f);
                tokenList{i+1} = [];
                tokenList{i+2} = [];
                tokenList = tokenList(~cellfun('isempty',tokenList));
            elseif token == '-'
                f = tokenList{i+1} - tokenList{i+2};
                for m = 1 : length(var)
                    f = subs(f, var{m}, RandBuffer{m,j}); 
                end
                
                if checkInputNum(f) == false
                    inputTest = false; 
                    break;
                end
                
                tokenList{i} = vpa(f);
                tokenList{i+1} = [];
                tokenList{i+2} = [];
                tokenList = tokenList(~cellfun('isempty',tokenList));
            elseif token == '*'
                f = tokenList{i+1} * tokenList{i+2};
                for m = 1 : length(var)
                    f = subs(f, var{m}, RandBuffer{m,j});
                end
                
                if checkInputNum(f) == false
                    inputTest = false; 
                    break;
                end
                
                tokenList{i} = vpa(f);
                tokenList{i+1} = [];
                tokenList{i+2} = [];
                tokenList = tokenList(~cellfun('isempty',tokenList));
            elseif token == '/' 
                f = tokenList{i+1} / tokenList{i+2};
                for m = 1 : length(var)
                    f = subs(f, var{m}, RandBuffer{m,j}); 
                end
                
                if checkInputNum(f) == false
                    inputTest = false; 
                    break;
                end
                
                tokenList{i} = vpa(f);
                tokenList{i+1} = [];
                tokenList{i+2} = [];
                tokenList = tokenList(~cellfun('isempty',tokenList));
            else
                tokenList{i} = cell2sym(tokenList(i));
            end
        end
        
        if inputTest == true
            Decimal_Output{j} = vpa(f); %for testing: computed from symbolic function
            j = j + 1; %if true, run next 
        else
            %if false, restart the while loop from iteration j
        end
        
    end
    Decimal_Input = RandBuffer;
end