%convert infix expression to prefix expression
classdef InfixToPrefixConv
    properties
        InfixExp
    end
    
    methods 
        function checkInput(obj)
            if nargin == 1
                for k = 1 : length(obj.InfixExp)
                    char = obj.InfixExp(k);
                    if and(and(isletter(char) == 0, isNum(obj, char) == 0), isOp(obj, char) == 0) 
                        error('Input chars must be a decimal number less than 1, letter a to z, or operator +, -, *, /, ( or )');
                    end
                end
            end             
        end
        
        function PrefixExp = CreatePrefixExp(obj)
            checkInput(obj);
            reversePrefixExp = InfixToPrefix(obj);
            PrefixExp = reverse(obj, reversePrefixExp);
        end
        
        function prefixExp = InfixToPrefix(obj)
            i = 1; %i represent the top index
            j = 1; %j represent the current index
            stack(1) = '&'; %initialise
            reverseInfixExp = reverse(obj, obj.InfixExp);              
            for k = 1 : length(reverseInfixExp)
                char = reverseInfixExp(k);
                if isOp(obj, char) == 0                  
                    prefixExp(j) = char;   
                    j = j + 1;               
                else
                    if char == ')'    
                        i = i + 1; 
                        stack(i) = char;
                    elseif char == '('
                        while stack(i) ~= ')'
                            prefixExp(j) = stack(i);
                            i = i - 1;
                            j = j + 1;
                        end
                        prefixExp(j) = stack(i);
                        i = i - 1;
                    else
                        if precedence(obj, stack(i)) <= precedence(obj, char)
                            i = i + 1; 
                            stack(i) = char;
                        else
                            while precedence(obj, stack(i)) >= precedence(obj, char)
                                prefixExp(j) = stack(i);
                                i = i - 1;
                                j = j + 1;
                            end
                            i = i + 1; 
                            stack(i) = char;
                        end
                    end
                end
            end
            
            while stack(i) ~= '&'
                prefixExp(j) = stack(i);
                i = i - 1;
                j = j + 1;
            end       
        end  
        
        function num = isNum(obj, char)
            switch char
                case '0'
                    num = true;
                case '1'
                    num = true;
                case '2'
                    num = true;
                case '3'
                    num = true;
                case '4'
                    num = true;
                case '5'
                    num = true;
                case '6'
                    num = true;
                case '7'
                    num = true;
                case '8'
                    num = true;
                case '9'
                    num = true;
                case '.'
                    num = true;
                otherwise
                    num = false;
            end
        end
      
        function op = isOp(obj, char)
            switch char
                case '+'
                    op = true;
                case '-'
                    op = true;
                case '*'
                    op = true;
                case '/'
                    op = true;
                case '('
                    op = true;
                case ')'
                    op = true;
                otherwise
                    op = false;
            end
        end
      
        function expressionReverse = reverse(obj, expression)
            size = length(expression);
            for i = 1 : size  
                expressionReverse(i) = expression(size-i+1);
            end
        end
        
        function val = precedence(obj, char)
            switch(char)
                case '+'
                    val = 2; 
                case '-'
                    val = 2;
                case '*'
                    val = 3;
                case '/'
                    val = 3;
                case '('
                    val = 1;
                case ')'
                    val = 1;
                case '&'
                    val = 1;
                otherwise
                    val = 0;
            end
        end
    end
end