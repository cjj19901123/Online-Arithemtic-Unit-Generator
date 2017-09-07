function ifValid = checkInputNum(inputNum)
    val = double(inputNum);
    if val >= 1
       ifValid = false;
    elseif val <= -1
       ifValid = false;
    else
       ifValid = true; 
    end
end