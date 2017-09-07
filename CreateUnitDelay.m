%create vhdl file to delay n unit
function CreateUnitDelay
    FileName = 'n_unit_delay';
    FileID = fopen([FileName '.vhd'], 'w');
    
    delay = VHDLParsorClass;
    delay.FileName = FileName;
    delay.GenericName = {'delay_unit'};
    delay.GenericType = {'INTEGER'};
    delay.GenericValue = {'3'};
    delay.PortName = {'d', 'clk', 'rst', 'q'};
    delay.PortType = {'in', 'in', 'in', 'out'};
    delay.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT'};
    
    delay.SignalName = {'d_temp'};
    delay.SignalDataType = {'VEC'};
    delay.SignalWidth = {'delay_unit'};
    
    dff = VHDLParsorClass; 
    dff.PortName = {'d', 'clk', 'rst', 'q'};
    dff.PortDataType = {'BIT', 'BIT', 'BIT', 'BIT'};
    dff.PortType = {'in', 'in', 'in', 'out'};
    dff.ComponentName = 'd_ff';
    dff.GenerateComponentName = 'latch_unit';
    dff.PortAssignment = {'d_temp(i)', delay.PortName{2}, delay.PortName{3}, 'd_temp(i+1)'};
    
    HeaderBuffer = CreateHeader(delay);
    EntityBuffer = CreateEntity(delay);
    SignalBuffer = CreateSignal(delay);
    ComponentBuffer = CreateComponent(dff);
    InitialiseBuffer = InitialiseComponent(dff);
    
    %create header         
    for k = 1 : length(HeaderBuffer)
        fprintf(FileID, '%s\n', HeaderBuffer{k});
    end

    %create entity          
    for k = 1: length(EntityBuffer)
        fprintf(FileID,'%s\n', EntityBuffer{k});
    end

    %create architecture  
    ArchitectureBuffer = {};
    ArchitectureBuffer = [ArchitectureBuffer, ['architecture Behavioral of ' FileName ' is']];
    ArchitectureBuffer = [ArchitectureBuffer, SignalBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, ComponentBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'begin'];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'd_temp(d_temp''low) <= d;']];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'q <= d_temp(d_temp''high);']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'gen_delay : for i in 0 to delay_unit - 1 generate']];
    ArchitectureBuffer = [ArchitectureBuffer, InitialiseBuffer];
    ArchitectureBuffer = [ArchitectureBuffer, [blanks(4) 'end generate gen_delay;']];
    ArchitectureBuffer = [ArchitectureBuffer, ' '];
    ArchitectureBuffer = [ArchitectureBuffer, 'end Behavioral;'];
    
    for k = 1: length(ArchitectureBuffer)
        fprintf(FileID,'%s\n', ArchitectureBuffer{k});
    end
          
    fclose(FileID);
    
    CreateDFF;

    
end