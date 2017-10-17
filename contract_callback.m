function contract_callback(action,block)
    feval(action,block)
end

function inputs_callback(block)
% get the values of the mask
values = get_param(block,'MaskValues');

index = 0;
% get the size of assume ports
assumePorts = str2num(char(values(1)));
for i= 1 : assumePorts
    index = index + 1;
    portStr(index) = {['port_label(''input'',',num2str(index),',''assume'')']};       
end

% get the size of guarantee ports
guaranteePorts = str2num(char(values(2)));
for i= 1 : guaranteePorts
    index = index + 1;
    portStr(index) = {['port_label(''input'',',num2str(index),',''guarantee'')']};    
end

% get the size of mode ports
modeBlocksPorts = str2num(char(values(3)));
for i= 1 : modeBlocksPorts
    index = index + 1;
    portStr(index) = {['port_label(''input'',',num2str(index),',''mode'')']};    
end

% output ports
% assume output port
index = index + 1;
portStr(index) = {['port_label(''output'',',num2str(1),',''assume'')']};
% validator output port
index = index + 1;
portStr(index) = {['port_label(''output'',',num2str(2),',''valid'')']};

set_param(block,'MaskDisplay',char(portStr));


 %% add or remove blocks
    blockModel = get_param(gcb, 'Parent');              
    ports = get_param(gcb,'PortHandles');
    portConnectivity = get_param(gcb, 'PortConnectivity');          
    for i = 1 : length(portConnectivity)
        % if the port is not connected
        if portConnectivity(i).SrcBlock == -1
            % add a new block
            if i <= assumePorts                  
               blockHandle =  add_block('Kind/assume',strcat(blockModel,'/','assume'),'MakeNameUnique','on');
            else
                if i <= assumePorts + guaranteePorts
                    blockHandle =  add_block('Kind/guarantee',strcat(blockModel,'/','guarantee'),'MakeNameUnique','on');
                else 
                    blockHandle =  add_block('Kind/mode',strcat(blockModel,'/','mode'),'MakeNameUnique','on');
                end
            end  
           % move the new block closer to its port
           position = get_param(blockHandle,'position');
           width = position(3) - position(1);
           height = position(4) - position(2);
           position(1) = portConnectivity(i).Position(1) - width - 30;
           position(2) = portConnectivity(i).Position(2) - height/2;
           position(3) = portConnectivity(i).Position(1)  - 30;
           position(4) = portConnectivity(i).Position(2) + height/2;                   
           set_param(blockHandle,'position',position);

           % connect the new block with its port
           blockPorts = get_param(blockHandle, 'PortConnectivity');
           [outputPortIndex , ~] = size(blockPorts);
           add_line(blockModel, [blockPorts(outputPortIndex).Position; portConnectivity(i).Position ]); 
           
           % add all assumptions to each mode port
           if i > assumePorts + guaranteePorts
               % assume is the first inport in mode block
               %add_line(blockModel, [portConnectivity(assumptionsPortIndex).Position; blockPorts(1).Position]); 
               modePorts = get_param(blockHandle, 'PortHandles');
                %check if the mode assume port is already connected
                portLine = get_param(modePorts.Inport(1),'Line'); 
                if portLine == -1   
                    add_line(blockModel, ports.Outport(1) ,modePorts.Inport(1), 'autorouting','on');
                end
               %register a callback function when the mode inport
               %connectivity changes
               set_param(ports.Inport(i), 'ConnectionCallback', 'checkModePort');               
           end
        end
    end
    
    blockPaths = find_system(blockModel,'SearchDepth',1,'Type','Block');
    blockTypes = get_param(blockPaths,'BlockType');
    %set_param('Kind/contract/input1', 'CopyFcn', testvar)
    for i = 1:length(blockTypes)
        if strcmp(blockTypes(i),'Inport') 
            % get the inport outport
            input = get_param(blockPaths(i), 'PortHandles');
            inputLine = get_param(input{1,1}.Outport,'Line');
            
            destinationBlockHandles = [];
            if inputLine ~= -1
                destinationBlockHandles = get_param(inputLine, 'DstBlockHandle');
            end
            
            for j = 1 : (assumePorts + guaranteePorts + modeBlocksPorts)
                % if the line is not connected to the block
                if ~ismember(portConnectivity(j).SrcBlock, destinationBlockHandles) 
                    
                    % disable the library links for the target block
                    % for the first time, the SrcBlock is -1, invalid.
                    set_param(portConnectivity(j).SrcBlock, 'LinkStatus', 'inactive');
                    % get the target block name
                    targetBlockName = get_param(portConnectivity(j).SrcBlock, 'Name');
                    % add new port inside that block
                    add_block('built-in/Inport', ...
                                    strcat(blockModel,'/',targetBlockName,'/','input'),'MakeNameUnique','on');
                    
                    targetBlockPorts = get_param(portConnectivity(j).SrcBlock, 'PortHandles');
                    %connect the inport with the block            
                    add_line(blockModel, input{1,1}.Outport ,targetBlockPorts.Inport(length(targetBlockPorts.Inport)), 'autorouting','on');
                end
            end
        end
    end
end

