%Create OA TestBench for behaviour simulation
%use matlab rand function to generate 10 pairs of random number (each pair represent a number), 
%convert the pair number to binary that is serial in to the hardware unit  
%the harware unit generate the result of expression in digit-serial manner
%each digit output is stored in a register and then convert to decimal in the end of cycle
%also compute the result using matlab symbolic expression which can be used to verify the result

function [Decimal_Output, Decimal_Input] = CreateTB(name, precision, expression)
    
    [prefixExp, ~, ~, ~, ~, ~, totalOnlineDelay, ~, ~, ExpressionBuffer] = ExpressionParser(expression);
    
    variable = unique(prefixExp(isstrprop(prefixExp,'alpha')));  
    var = cellstr(variable')';
    
    %Create File using VHDL Parsor Class 
    FileName = ['tb_behave_' name];
    FileID = fopen([FileName '.vhd'], 'w');
    
    tb = VHDLParsorClass;
    tb.FileName = FileName;
    tb.GenericName = {'precision_bit', 'total_online_delay'};
    tb.GenericType = {'INTEGER', 'INTEGER'};
    tb.GenericValue = {int2str(precision), int2str(totalOnlineDelay)};
    
    tb.SignalName = {'j', 'clk', 'rst', };
    tb.SignalDataType = {'INT', 'BIT', 'BIT'};
    tb.SignalWidth = {'-total_online_delay - 1 to precision_bit', '0', '0'};
    tb.SignalDefaultValue = {'-total_online_delay - 1', '''1''', '''1'''};
    
    varSize = length(var);
    for k = 1 : varSize
        tb.SignalName = [tb.SignalName, [var{k} '_p'], [var{k} '_n']];
        tb.SignalDataType = [tb.SignalDataType, 'BIT', 'BIT'];
        tb.SignalWidth  = [tb.SignalWidth, '0', '0'];
        tb.SignalDefaultValue = [tb.SignalDefaultValue, '''0''', '''0'''];
    end
    
    tb.SignalName = [tb.SignalName, 'dout_p', 'dout_n', 'dout', 'd_out', 'd_val'];
    tb.SignalDataType = [tb.SignalDataType, 'BIT', 'BIT', 'VEC', 'VEC', 'REA'];
    tb.SignalWidth = [tb.SignalWidth, '0', '0', 'precision_bit + total_online_delay - 1', 'precision_bit - 1', '0'];
    tb.SignalDefaultValue = [tb.SignalDefaultValue, '''0''', '''0''', '(others => ''0'')', '(others => ''0'')', '0.0'];

    oa = VHDLParsorClass;
    oa.ComponentName = name;
    oa.GenerateComponentName = 'utt';
    oa.GenericName = {'precision_bit', 'total_online_delay'};
    oa.GenericType = {'INTEGER', 'INTEGER'};
    oa.GenericValue = {int2str(precision), int2str(totalOnlineDelay)};
    oa.GenericAssignment = {'precision_bit', 'total_online_delay'};
    
    oa.PortName = {};
    oa.PortType = {};
    oa.PortDataType = {};
    oa.PortWidth = {};
    oa.PortAssignment = {};
    
    for k = 1 : varSize 
        oa.PortName = [oa.PortName, [var{k} '_p'], [var{k} '_n']];
        oa.PortType = [oa.PortType, 'in', 'in'];
        oa.PortDataType = [oa.PortDataType, 'BIT', 'BIT'];
        oa.PortWidth = [oa.PortWidth, '0', '0'];
        oa.PortAssignment = [oa.PortAssignment, [var{k} '_p'], [var{k} '_n']];
    end
    
    oa.PortName = [oa.PortName, 'clk', 'rst', 'j_out', 'dout_p', 'dout_n'];
    oa.PortType = [oa.PortType, 'in', 'in', 'out', 'out', 'out'];
    oa.PortDataType = [oa.PortDataType, 'BIT', 'BIT', 'INT', 'BIT', 'BIT'];
    oa.PortWidth = [oa.PortWidth, '0', '0', '-total_online_delay - 1 to precision_bit', '0', '0']; 
    oa.PortAssignment = [oa.PortAssignment, 'clk', 'rst', 'j', 'dout_p', 'dout_n']; 
    
    otf = VHDLParsorClass;
    otf.ComponentName = 'on_the_fly_conv_r2';
    otf.GenerateComponentName = 'ca_dout';
    otf.GenericName = {'total_bit', 'start_iteration'};
    otf.GenericType = {'INTEGER', 'INTEGER'};
    otf.GenericValue = {'precision_bit + total_online_delay - 1', '-total_online_delay - 1'};
    otf.GenericAssignment = {'precision_bit + total_online_delay - 1', '-total_online_delay - 1'};
    otf.PortName = {'x_p', 'x_n', 'j', 'x_out'};
    otf.PortType = {'in', 'in', 'in', 'out'};
    otf.PortDataType = {'BIT', 'BIT', 'INT', 'VEC'};
    otf.PortWidth = {'0', '0', 'start_iteration to total_bit + start_iteration + 2', 'total_bit'};
    otf.PortAssignment = {'dout_p', 'dout_n', 'j', 'dout'};
    
    HeaderBuffer = CreateHeader(tb);
    HeaderBuffer = [HeaderBuffer, 'use IEEE.MATH_REAL.ALL;', ' '];
    EntityBuffer = CreateEntity(tb);
    SignalBuffer = CreateSignal(tb);
    ComponentBuffer = [CreateComponent(oa), ' ', CreateComponent(otf)];
    InitialiseBuffer = [InitialiseComponent(oa), ' ', InitialiseComponent(otf)];
    
    %create header         
    for k = 1 : length(HeaderBuffer)
        fprintf(FileID, '%s\n', HeaderBuffer{k});
    end
    
    %create entity          
    for k = 1: length(EntityBuffer)
        fprintf(FileID,'%s\n', EntityBuffer{k});
    end
    
    %generate 10 paris of random testing number - Decimal_Input
    %compute the result for verification using symbolic compuatation -Decimal_Output
    %stores the digits to be generated for testbench -digitBuffer 
    NumOfRd = 10; 
    [Decimal_Input, digitBuffer, Decimal_Output] = SymbolicComputation(NumOfRd, ExpressionBuffer, var, precision, totalOnlineDelay);
    
    %generate the input waveform
    %The total length for each input binary = precision + online delay  
    waveGenBuffer = {}; 
    %zero padding for the waveform in the reset stage
    zero = pad('', precision + totalOnlineDelay, 'right', '0');
    
    for i = 1 : 2*varSize
        waveGenBuffer = [waveGenBuffer, ' '];
        waveGenBuffer = [waveGenBuffer, [blanks(4) 'process is']];
        waveGenBuffer = [waveGenBuffer, [blanks(4) 'begin']];
        for k = 1 : NumOfRd     
            waveGenBuffer = [waveGenBuffer, [blanks(8) 'waveform_gen(clk, ' oa.PortName{i} ', ' '"' zero '");']]; %when reset is 1
            waveGenBuffer = [waveGenBuffer, [blanks(8) 'waveform_gen(clk, ' oa.PortName{i} ', ' '"' digitBuffer{i, k} '");']]; %when reset is 0        
        end
        waveGenBuffer = [waveGenBuffer, [blanks(4) 'end process;']];
    end
    
    %create architecture
    ArchitectureBuffer = {};
    ArchitectureBuffer = [ArchitectureBuffer, ['architecture Behavioral of ' FileName ' is']];
    ArchitectureBuffer = [ArchitectureBuffer, SignalBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, ComponentBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'procedure waveform_gen(']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'signal clk : in STD_LOGIC;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'signal d : out STD_LOGIC;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'waveform : STD_LOGIC_VECTOR) is']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'begin']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'for i in waveform''left to waveform''right loop']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'd <= waveform(i);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(12) 'wait until RISING_EDGE(clk);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(8) 'end loop;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end waveform_gen;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'begin'];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'clk <= not clk after 5 ns;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'rst <= not rst after ' num2str((precision + totalOnlineDelay)*10)  ' ns;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'd_out <= dout(precision_bit - 1 downto 0);']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'd_val <= REAL(to_integer(SIGNED(d_out)))/(2**(precision_bit - 2)-1+2**(precision_bit - 2)) when j = precision_bit - 1 else REAL(0);']];
    ArchitectureBuffer = [ArchitectureBuffer, waveGenBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, InitialiseBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];
    
    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end
          
    fclose(FileID);
    
    %this testbench is for behaviour simulation and verification
    %not suit to post-synthesis simulation
    %a new testbench is generated for post-synthesis
    CreateTB_PostSyn(name, precision, expression, waveGenBuffer);
    
end