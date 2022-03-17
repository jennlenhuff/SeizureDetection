%% Reset vars
clc, clear

%% Setup parallel computing

% number of workers is the number of directories that'll be processed in
% parallel
numWorkers = 2;

% boot up parallel workers if they aren't active
if isempty(gcp('nocreate'))
    parpool('local',numWorkers)
end

%% Set environment 
SetPath('E:\SeizureDetection_organization_example\Rat');

% load parameters
Parameters = load('E:\SeizureDetection_organization_example\Rat\Test\variables\Parameters.mat', 'Parameters');
Parameters = Parameters.Parameters;

%% Start seizure detection

% Paths for John's home work comp:
% paths = {'D:\diaz_2018_A','D:\CBZ_2019_C','D:\phenytoin2018_D'};

% Paths for ADD Lab EEG comps:
paths = {'E:\NewAlgoTest'};
for i = 1:numel(paths)
    % pass analysis path and parameters structure
    AutomatedSzDetect_DeployTest(paths{i}, Parameters)
end