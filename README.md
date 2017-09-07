
# Online-Arithemtic-Unit-Generator
Introduction:
A software program to generate hardware in VHDL to perform online arithmetic operaitions 
The software system written in MATLAB, taking an arbitrary symbolic expression as input and producing pieces of VHDL files to describe an arithmetic functional unit.  
The building blocks of generated hardware implements the online algorithms to design  online adder, multiplier and divider. Sequence of operators are interconnected in a network for multi-operations.
The generator-based hardware is fully simulatable and synthesizable. It is intended for the custom computing for a long sequence of arithmetic operations on FPGA platform.



User Guide:
Run the file online_unit_generator.m
Inputt the parameters inclues, the name of hardware to be generated, an expression to be evalauted and performed, and digit precision of result. 
Output files incldues some VHDL files to describe the funcationality of the hardware.
The output files are stored in the same directory as the MATLAB design file.
The result compuated by MATLAB symbolic toolbox is displayed on the command window for the verification of the hardware functionality. 
Testbench are genrated as part of software, two testbench as generated for behaviour simulation and post-synthesis/implementation simulation seperately. Ten sets of testing data vector are generated for verification.  

User interface example:
>> online_unit_generator
please input the toplevel name of your IP: OA
please input the symbolic expresion: (a+b)*c/0.5
please input the precision bit of computation: 16
ans =
 
0.02746467106044292449951171875
 
 
ans =
 
0.0589167741127312183380126953125
 
 
ans =
 
0.0000897408463060855865478515625
 
 
ans =
 
-0.20118319033645093441009521484375
 
 
ans =
 
-0.0240654866211116313934326171875
 
 
ans =
 
-0.0954010770656168460845947265625
 
 
ans =
 
0.28552312799729406833648681640625
 
 
ans =
 
0.01585359522141516208648681640625
 
 
ans =
 
0.184384468011558055877685546875
 
 
ans =
 
-0.20445644273422658443450927734375
>>
