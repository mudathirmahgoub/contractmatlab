function contract_callback(action,block)
    feval(action,block)
end

function inputs_callback(block)
% get the values of the mask
values = get_param(block,'MaskValues');

% get the size of assume ports
assumePorts = str2num(char(values(1)));
for i= 1 : assumePorts
    portStr(i) = {['port_label(''input'',',num2str(i),',''assume'')']};
end
% get the size of mode ports
modePorts = str2num(char(values(2)));
for i= 1 : modePorts
    portStr(assumePorts + i) = {['port_label(''input'',',num2str(assumePorts + i),',''mode'')']};
end
set_param(block,'MaskDisplay',char(portStr));
end
