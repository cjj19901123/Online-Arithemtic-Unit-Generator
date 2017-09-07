%Run the program to generate hardware

prompt_1 = 'please input the toplevel name of your IP: ';
name = input(prompt_1, 's');

prompt_2  = 'please input the symbolic expresion: ';
expression = input(prompt_2, 's');

prompt_3 = 'please input the precision bit of computation: ';
precision = input(prompt_3);

%prompt_4 = 'please input the radix index of computation: ';
%radix = input(prompt_4);
radix = 2;
%create toplevel file
Create_oa_topLevel(name, expression, radix, precision);
%create testbench;
[TestOutput, TestInput] = CreateTB(name, precision, expression);

for i = 1:length(TestOutput)
display(TestOutput{i});
end
