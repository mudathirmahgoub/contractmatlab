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

% output port
index = index + 1;
portStr(index) = {['port_label(''output'',',num2str(1),',''valid'')']};    
set_param(block,'MaskDisplay',char(portStr));
end
