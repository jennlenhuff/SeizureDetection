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

%% Start seizure detection

% Paths for John's home work comp:
% paths = {'D:\diaz_2018_A','D:\CBZ_2019_C','D:\phenytoin2018_D'};

% Paths for ADD Lab EEG comps:
paths = {
    '\\MOUSEEEG-UNIT10\Data',
    '\\MOUSEEEG-UNIT10\Data2',
    '\\MOUSEEEG-UNIT10\Data3',    
    '\\MOUSEEEG-UNIT11\Data',
    '\\MOUSEEEG-UNIT11\Data2',
    '\\MOUSEEEG-UNIT11\Data3',
    '\\MOUSEEEG-UNIT12\Data',
    '\\MOUSEEEG-UNIT12\Data2',    
    '\\MOUSEEEG-UNIT13\Data',
    '\\MOUSEEEG-UNIT13\Data2',   
     '\\MOUSEEEG-UNIT4\Data',
    '\\MOUSEEEG-UNIT4\Data2',
    '\\MOUSEEEG-UNIT5\Data',
    '\\MOUSEEEG-UNIT5\Data2',    
    '\\MOUSEEEG-UNIT6\Data',
    '\\MOUSEEEG-UNIT6\Data2',    
    '\\MOUSEEEG-UNIT7\Data',
    '\\MOUSEEEG-UNIT7\Data2',    
    };

parfor i = 1:numel(paths)
    AutomatedSzDetect_DeployTest(paths{i})
end