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
modePorts = str2num(char(values(3)));
for i= 1 : modePorts
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
    
    blockPaths = find_system(blockModel,'Type','Block');
    blockTypes = get_param(blockPaths,'BlockType');
    ports = get_param(gcb,'PortHandles');
    portConnectivity = get_param(gcb, 'PortConnectivity')

    for i = 1 : length(portConnectivity)
        % if the port is not connected
        if portConnectivity(i).SrcBlock == -1
            % add a new block
            if i <= assumePorts                  
               blockHandle =  add_block('Kind/contract/assume',strcat(blockModel,'/','assume'),'MakeNameUnique','on');
            else
                if i <= assumePorts + guaranteePorts
                    blockHandle =  add_block('Kind/contract/guarantee',strcat(blockModel,'/','guarantee'),'MakeNameUnique','on');
                else 
                    blockHandle =  add_block('Kind/contract/mode',strcat(blockModel,'/','mode'),'MakeNameUnique','on');
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
        end
    end    
end
