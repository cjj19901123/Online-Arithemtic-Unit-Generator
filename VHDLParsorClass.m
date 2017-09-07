%Parse basic element into VHDL code such as generics, ports, singals, components and components maps
%not include the parsing of when else statement, generate statment and sequential code
classdef VHDLParsorClass
   properties
      FileName
      GenericName
      GenericType
      GenericValue
      PortName
      PortType
      PortDataType
      PortWidth
      SignalName
      SignalDataType
      SignalWidth
      SignalDefaultValue
      ConstantName
      ConstantDataType
      ConstantWidth
      ConstantValue
      ComponentName
      GenerateComponentName
      GenericAssignment
      PortAssignment
   end
   
   methods
      
      function HeaderBuffer = CreateHeader(obj)
          HeaderBuffer = {};
          HeaderBuffer = [HeaderBuffer, '--###############################'];
          HeaderBuffer = [HeaderBuffer, '--# Project Name : '];
          HeaderBuffer = [HeaderBuffer, '--# Author       : '];
          HeaderBuffer = [HeaderBuffer, '--# Description  : '];
          HeaderBuffer = [HeaderBuffer, '--# Target Devices : '];
          HeaderBuffer = [HeaderBuffer, '--###############################'];
          HeaderBuffer = [HeaderBuffer, ' '];
          HeaderBuffer = [HeaderBuffer, 'library IEEE;'];
          HeaderBuffer = [HeaderBuffer, 'use IEEE.STD_LOGIC_1164.ALL;'];
          HeaderBuffer = [HeaderBuffer, 'use IEEE.NUMERIC_STD.ALL;'];
          HeaderBuffer = [HeaderBuffer, ' '];
      end 
      
      function GenericBuffer = CreateGeneric(obj)
          GenericBuffer = {};
          size = length(obj.GenericName);
          
          if size == 0
              GenericBuffer = [GenericBuffer, [blanks(4) '--generic();']];
          elseif size == 1
              GenericBuffer = [GenericBuffer, [blanks(4) 'generic(' obj.GenericName{1} ' : ' obj.GenericType{1} ' := ' obj.GenericValue{1} ');']];
          else
              GenericBuffer = [GenericBuffer, [blanks(4) 'generic(' obj.GenericName{1} ' : ' obj.GenericType{1} ' := ' obj.GenericValue{1} ';']];
              for k = 2 : size - 1
                  GenericBuffer = [GenericBuffer, [blanks(12) obj.GenericName{k} ' : ' obj.GenericType{k} ' := ' obj.GenericValue{k} ';']];
              end
              GenericBuffer = [GenericBuffer, [blanks(12) obj.GenericName{size} ' : ' obj.GenericType{size} ' := ' obj.GenericValue{size} ');']];
          end
      end
      
      function PortBuffer = CreatePort(obj)
          PortBuffer = {};
          size = length(obj.PortName);
          
          if size == 0
              PortBuffer = [PortBuffer, [blanks(4) '--port();']];
          elseif size == 1
              if obj.PortDataType{1} == 'BIT'
                  PortBuffer = [PortBuffer, [blanks(4) 'port(' obj.PortName{1} ' : ' obj.PortType{1} ' STD_LOGIC);']];
              elseif obj.PortDataType{1} == 'VEC' 
                  PortBuffer = [PortBuffer, [blanks(4) 'port(' obj.PortName{1} ' : ' obj.PortType{1} ' STD_LOGIC_VECTOR' '(' obj.PortWidth{1} ' downto 0));']];   
              else
                  PortBuffer = [PortBuffer, [blanks(4) 'port(' obj.PortName{1} ' : ' obj.PortType{1} ' INTEGER range ' obj.PortWidth{1} ');']];    
              end
          else
              if obj.PortDataType{1} == 'BIT'
                  PortBuffer = [PortBuffer, [blanks(4) 'port(' obj.PortName{1} ' : ' obj.PortType{1} ' STD_LOGIC;']];
              elseif obj.PortDataType{1} == 'VEC' 
                  PortBuffer = [PortBuffer, [blanks(4) 'port(' obj.PortName{1} ' : ' obj.PortType{1} ' STD_LOGIC_VECTOR' '(' obj.PortWidth{1} ' downto 0);']];   
              else 
                  PortBuffer = [PortBuffer, [blanks(4) 'port(' obj.PortName{1} ' : ' obj.PortType{1} ' INTEGER range ' obj.PortWidth{1} ';']];
              end
              
              for k = 2 : size - 1
                  if obj.PortDataType{k} == 'BIT'
                      PortBuffer = [PortBuffer, [blanks(9) obj.PortName{k} ' : ' obj.PortType{k} ' STD_LOGIC;']];
                  elseif obj.PortDataType{k} == 'VEC'
                      PortBuffer = [PortBuffer, [blanks(9) obj.PortName{k} ' : ' obj.PortType{k} ' STD_LOGIC_VECTOR' '(' obj.PortWidth{k} ' downto 0);']];
                  else
                      PortBuffer = [PortBuffer, [blanks(9) obj.PortName{k} ' : ' obj.PortType{k} ' INTEGER range ' obj.PortWidth{k} ';']];
                  end
              end
              
              if obj.PortDataType{size} == 'BIT'
                  PortBuffer = [PortBuffer, [blanks(9) obj.PortName{size} ' : ' obj.PortType{size} ' STD_LOGIC);']];
              elseif obj.PortDataType{size} == 'VEC'
                  PortBuffer = [PortBuffer, [blanks(9) obj.PortName{size} ' : ' obj.PortType{size} ' STD_LOGIC_VECTOR' '(' obj.PortWidth{size} ' downto 0));']];
              else
                  PortBuffer = [PortBuffer, [blanks(4) obj.PortName{size} ' : ' obj.PortType{size} ' INTEGER range ' obj.PortWidth{size} ');']];
              end
          end
      end
      
      function EntityBuffer = CreateEntity(obj)

          GenericBuffer = CreateGeneric(obj);
          PortBuffer = CreatePort(obj);
          
          EntityBuffer = {};
          EntityBuffer = [EntityBuffer, ['entity ' obj.FileName ' is']];
          EntityBuffer = [EntityBuffer, GenericBuffer];
          EntityBuffer = [EntityBuffer, PortBuffer];
          EntityBuffer = [EntityBuffer, ['end ' obj.FileName ';']];
          EntityBuffer = [EntityBuffer, ' '];
      end
      
      function ConstBuffer = CreateConst(obj)
          ConstBuffer = {};
          size = length(obj.ConstantName);
          
          for k = 1 : size
              if obj.ConstantDataType{k} == 'BIT' 
                  ConstBuffer = [ConstBuffer, [blanks(4) 'constant ' obj.ConstantName{k} ' : STD_LOGIC := ''' obj.ConstantValue{k} ''';']];
              elseif obj.ConstantDataType{k} == 'VEC' 
                  ConstBuffer = [ConstBuffer, [blanks(4) 'constant ' obj.ConstantName{k} ' : STD_LOGIC_VECTOR('  obj.ConstantWidth{k} ' downto 0) := "' obj.ConstantValue{k} '";']];
              else
              end
          end
      end
      
      function SignalBuffer = CreateSignal(obj)
          SignalBuffer = {};
          size = length(obj.SignalName);
          if isempty(obj.SignalDefaultValue)
              for k = 1 : size
                  if obj.SignalDataType{k} == 'BIT' 
                      SignalBuffer = [SignalBuffer, [blanks(4) 'signal ' obj.SignalName{k} ' : STD_LOGIC;']];                 
                  elseif obj.SignalDataType{k} == 'VEC'          
                      SignalBuffer = [SignalBuffer, [blanks(4) 'signal ' obj.SignalName{k} ' : STD_LOGIC_VECTOR(' obj.SignalWidth{k} ' downto 0);']];
                  elseif obj.SignalDataType{k} == 'REA'
                      SignalBuffer = [SignalBuffer, [blanks(4) 'signal ' obj.SignalName{k} ' : REAL := ' obj.SignalDefaultValue{k} ';']];
                  elseif obj.SignalDataType{k} == 'INT'
                      SignalBuffer = [SignalBuffer, [blanks(4) 'signal ' obj.SignalName{k} ' : INTEGER range ' obj.SignalWidth{k} ';']];                  
                  end
              end
          else
              for k = 1 : size
                  if obj.SignalDataType{k} == 'BIT' 
                      SignalBuffer = [SignalBuffer, [blanks(4) 'signal ' obj.SignalName{k} ' : STD_LOGIC := ' obj.SignalDefaultValue{k} ';']];                 
                  elseif obj.SignalDataType{k} == 'VEC'          
                      SignalBuffer = [SignalBuffer, [blanks(4) 'signal ' obj.SignalName{k} ' : STD_LOGIC_VECTOR(' obj.SignalWidth{k} ' downto 0) := ' obj.SignalDefaultValue{k} ';']];
                  elseif obj.SignalDataType{k} == 'REA'
                      SignalBuffer = [SignalBuffer, [blanks(4) 'signal ' obj.SignalName{k} ' : REAL := ' obj.SignalDefaultValue{k} ';']];
                  elseif obj.SignalDataType{k} == 'INT'
                      SignalBuffer = [SignalBuffer, [blanks(4) 'signal ' obj.SignalName{k} ' : INTEGER range ' obj.SignalWidth{k} ' := ' obj.SignalDefaultValue{k} ';']];                  
                  end
              end
          end
      end
      
      function ComponentBuffer = CreateComponent(obj)
          
          ComponentGenericBuffer = CreateGeneric(obj);    
          ComponentPortBuffer = CreatePort(obj);
          
          ComponentBuffer = {};
          ComponentBuffer = [ComponentBuffer, [blanks(4) 'component ' obj.ComponentName]];
          ComponentBuffer = [ComponentBuffer, ComponentGenericBuffer];
          ComponentBuffer = [ComponentBuffer, ComponentPortBuffer];
          ComponentBuffer = [ComponentBuffer, [blanks(4) 'end component;']];
      end
      
      function GenericMapBuffer = CreateGenericMap(obj)
          GenericMapBuffer = {};
          size = length(obj.GenericName);
          
          if size == 0
              GenericMapBuffer = [GenericMapBuffer, [blanks(8) '--generic map();']];
          elseif size == 1
              GenericMapBuffer = [GenericMapBuffer, [blanks(8) 'generic map (' obj.GenericName{1} ' => ' obj.GenericAssignment{1} ')']];
          else
              GenericMapBuffer = [GenericMapBuffer, [blanks(8) 'generic map (' obj.GenericName{1} ' => ' obj.GenericAssignment{1} ',']];
              for k = 2 : size - 1
                  GenericMapBuffer = [GenericMapBuffer, [blanks(21) obj.GenericName{k} ' => ' obj.GenericAssignment{k} ',']];
              end
              GenericMapBuffer = [GenericMapBuffer, [blanks(21) obj.GenericName{size} ' => ' obj.GenericAssignment{size} ')']];
          end
      end
      
      function PortMapBuffer = CreatePortMap(obj)
          PortMapBuffer = {};
          size = length(obj.PortName);
          
          if size == 0 
              PortMapBuffer = [PortMapBuffer, [blanks(8) '--port map();']];
          elseif size == 1
              PortMapBuffer = [PortMapBuffer, [blanks(8) 'port map (' obj.PortName{1} ' => ' obj.PortAssignment{1} ');']];
          else
              PortMapBuffer = [PortMapBuffer, [blanks(8) 'port map (' obj.PortName{1} ' => ' obj.PortAssignment{1} ',']];
              for k = 2 : size - 1
                  PortMapBuffer = [PortMapBuffer, [blanks(18) obj.PortName{k} ' => ' obj.PortAssignment{k} ',']];
              end
              PortMapBuffer = [PortMapBuffer, [blanks(18) obj.PortName{size} ' => ' obj.PortAssignment{size} ');']];
          end
      end
      
      function InitiliseComponentBuffer = InitialiseComponent(obj)
          
          GenericMapBuffer = CreateGenericMap(obj);    
          PortMapBuffer = CreatePortMap(obj);
          
          InitiliseComponentBuffer = {};
          InitiliseComponentBuffer = [InitiliseComponentBuffer, [blanks(4) obj.GenerateComponentName ': ' obj.ComponentName]];
          InitiliseComponentBuffer = [InitiliseComponentBuffer, GenericMapBuffer];
          InitiliseComponentBuffer = [InitiliseComponentBuffer, PortMapBuffer];       
      end
   end 
end