function vab_to_uvw(block)

setup(block);
%endfunction

%% Function: setup 
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
function setup(block)

% Register number of ports
values = get_param(block.BlockHandle,'MaskValues');

% get the size of input ports
assumePorts = str2num(char(values(1)));
modePorts = str2num(char(values(2)));
block.NumInputPorts  = assumePorts + modePorts;

% only one output port for the contract
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [0 0];


%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------


block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode);
block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup
%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)

V = block.InputPort(1).Data;
alpha = block.InputPort(2).Data;
beta = block.InputPort(3).Data;

block.OutputPort(1).Data = V * cos(alpha) * cos(beta);
%end Outputs


%% Set the sampling of the input ports
function SetInputPortSamplingMode(block, idx, fd)
block.InputPort(idx).SamplingMode = fd;

for i = 1 : block.NumOutputPorts
    block.OutputPort(i).SamplingMode = fd;
end

%end Update

%%
%% Terminate:
%% Called at the end of simulation for cleanup
function Terminate(block)

%end Terminate

