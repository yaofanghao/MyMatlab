function [Y,Xf,Af] = (X,~,~)
%MYNEURALNETWORKFUNCTION neural network simulation function.
%
% Auto-generated by MATLAB, 11-Mar-2022 17:11:01.
%
% [Y] = myNeuralNetworkFunction(X,~,~) takes these arguments:
%
%   X = 1xTS cell, 1 inputs over TS timesteps
%   Each X{1,ts} = Qx3 matrix, input #1 at timestep ts.
%
% and returns:
%   Y = 1xTS cell of 1 outputs over TS timesteps.
%   Each Y{1,ts} = Qx1 matrix, output #1 at timestep ts.
%
% where Q is number of samples (or series) and TS is the number of timesteps.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [200;10;0];
x1_step1.gain = [0.00666666666666667;0.00425531914893617;0.0222222222222222];
x1_step1.ymin = -1;

% Layer 1
b1 = [-4.0498777933359413339;-2.6353070457567393525;2.2869139703222667315;-1.3224361582573731511;2.8943065743776026366;-0.72982713215094274783;1.4465043824732952693;1.0782968538718116225;-4.2184675058247407264;-2.8856486232934326353];
IW1_1 = [-0.19245661576092820688 -3.2680636359101868926 1.7110611671867321792;2.0494721123448313982 -0.62686881647055525679 -1.7590728495616294591;0.01379137558375085823 1.9911138689584810813 1.4950715376704453163;2.0573395687603701631 -1.1483530293695545232 2.1480384200261317673;-0.097712150165148642378 7.1901858297219982674 1.9469012268277543498;-0.16866184768956063444 -1.6371029415808575624 2.783417417815666095;1.8947778656143590137 -2.1754143948774138373 0.37966277029441186652;2.3555252255427037156 1.4636462302469637198 -2.2636961103258559369;0.22433992241047465144 -2.4831358476039575578 1.0330541141659843607;-2.1836200989488854241 2.1843542277551168951 -0.30454930777188710112];

% Layer 2
b2 = -1.3538062726476607356;
LW2_1 = [-2.4712702527983241296 1.0535675988192425567 -0.45534995890839868871 1.4897697478561895412 8.2060233404879756591 1.8450207990990825646 -1.3755565962138083247 -1.9402810044685911972 -2.139039870582637004 1.9218120291458034021];

% ===== SIMULATION ========

% Format Input Arguments
isCellX = iscell(X);
if ~isCellX
    X = {X};
end

% Dimensions
TS = size(X,2); % timesteps
if ~isempty(X)
    Q = size(X{1},1); % samples/series
else
    Q = 0;
end

% Allocate Outputs
Y = cell(1,TS);

% Time loop
for ts=1:TS
    
    % Input 1
    X{1,ts} = X{1,ts}';
    Xp1 = mapminmax_apply(X{1,ts},x1_step1);
    
    % Layer 1
    a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*Xp1);
    
    % Layer 2
    a2 = logsig_apply(repmat(b2,1,Q) + LW2_1*a1);
    
    % Output 1
    Y{1,ts} = a2;
    Y{1,ts} = Y{1,ts}';
end

% Final Delay States
Xf = cell(1,0);
Af = cell(2,0);

% Format Output Arguments
if ~isCellX
    Y = cell2mat(Y);
end
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
y = bsxfun(@minus,x,settings.xoffset);
y = bsxfun(@times,y,settings.gain);
y = bsxfun(@plus,y,settings.ymin);
end

% Sigmoid Positive Transfer Function
function a = logsig_apply(n,~)
a = 1 ./ (1 + exp(-n));
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
a = 2 ./ (1 + exp(-2*n)) - 1;
end
