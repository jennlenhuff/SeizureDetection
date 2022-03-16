%% Load in acq file
filename = 'E:\test_data\20220222-134101\20220222-134101-000.acq';
file =  acqreader07092013(filename); 

emp = 0;
% identify channels without an animal recording
emptychans = lower(file.ChannelNames) == 'e';
% extract all data from the .acq
selected_data = acqdatareader(file,0,24*3600);
eeg_data = selected_data.data;
% length of file in hours
hours  = floor(file.EndOfFileInHours); 

% some parameters
window = 25;
step = 1;
winsize = window*500;
stepsize = step*500;   
%% Compare AutoCorrelation algorithms
winvec = 1:stepsize:size(eeg_data,2)-winsize; 
% First old one
tic
AC_old = AC_V1(filename,window,step,60);
ac_old_time = toc;

tic
AC_new = nan(file.nChannels, numel(winvec));
for chan = 1:file.nChannels                         %Stepping through channels...
    if any(chan == emptychans)                      %If the channel is one of the empty ones.
        emp = emp + 1;                              %Adds one to the empty channel counter.
        continue;                                   %Skips to the next channel if the current one is empty.
    end
    tempAC = AC_V3(eeg_data(chan,:),window,step,60);
    AC_new(chan, 1:numel(tempAC)) = tempAC; 
end
ac_new_time = toc;

%% Compare FFT algorithm
itterations = floor((size(eeg_data,2)-winsize+stepsize)/stepsize);
tic
FFT_old = FFT_V1(filename,window,step,1); 
fft_old_time = toc;

tic
FFT_new = nan(file.nChannels, itterations);
for chan = 1:file.nChannels                         %Stepping through channels...
    if any(chan == emptychans)                      %If the channel is one of the empty ones.
        emp = emp + 1;                              %Adds one to the empty channel counter.
        continue;                                   %Skips to the next channel if the current one is empty.
    end
    tempFFT = FFT_V3(eeg_data(chan,:),window,step,1); 
    FFT_new(chan, 1:numel(tempFFT)) = tempFFT;
end
fft_new_time = toc;
disp(['Memory used: ' num2str(monitor_memory_whos()) ' MB'])
%% Compare ll algorithm
tic
LL_old = LL_V1(filename, window,step);
ll_old_time = toc;

tic
LL_new = nan(file.nChannels, itterations);
for chan = 1:file.nChannels                         %Stepping through channels...
    if any(chan == emptychans)                      %If the channel is one of the empty ones.
        emp = emp + 1;                              %Adds one to the empty channel counter.
        continue;                                   %Skips to the next channel if the current one is empty.
    end
    tempLL = LL_V3(eeg_data(chan,:),window,step); 
    LL_new(chan, 1:numel(tempLL)) = tempLL; 
end
ll_new_time = toc;
%% Compare SS algorithm
% do some gymnastics to make sure we initialize with the right length
x = eeg_data(1,:);           
s = abs(diff(x)/.002);                         
s(end+1) = s(end);                             
S = minmaxfilt(s,5,'max','same');              
itterations = floor((length(S)-winsize+stepsize)/stepsize);

tic
SS_old = SS_V1(filename,window,step,7.6e10);
ss_old_time = toc;

tic
SS_new = nan(file.nChannels, itterations);

for chan = 1:file.nChannels                         %Stepping through channels...
    if any(chan == emptychans)                      %If the channel is one of the empty ones.
        emp = emp + 1;                              %Adds one to the empty channel counter.
        continue;                                   %Skips to the next channel if the current one is empty.
    end
    tempSS = SS_V3(eeg_data(chan,:),window,step,7.6e10); 
    SS_new(chan, 1:numel(tempSS)) = tempSS; 
end
ss_new_time = toc;

figure()
length(AC_old(1,:))
title('OLD')

figure()
length(AC_new(1,:))
title('NEW')
%% Combine old and new algorithm results
Parameters.ACw = 0.17;
Parameters.FFTw = 0.49;
Parameters.LLw = 0.87;
Parameters.SSw = 0.96;

% exponential scalars
Parameters.ACe = 1.50;
Parameters.FFTe = 1.57;
Parameters.LLe = 1.82;
Parameters.SSe = 1.70;

% threshold
Parameters.Threshold = 2.9;

% create structure for old algorithms
old_output.AC = AC_old;
old_output.FFT = FFT_old;
old_output.LL = LL_old;
old_output.SS = SS_old;
COMBINED_old = ConcatAlgos(old_output, file);
final_old = CombineAlgos(COMBINED_old, Parameters, file);
% create structure for new algorithms
new_output.AC = AC_new;
new_output.FFT = FFT_new;
new_output.LL = LL_new;
new_output.SS = SS_new;
COMBINED_new = ConcatAlgos(new_output, file);
final_new = CombineAlgos(COMBINED_new, Parameters, file);

num_differences = size(final_new.DetTimes, 1) - size(final_old.DetTimes, 1);

if num_differences < 0
    disp('Differences are likely from old.')
else
    disp('Differences are likely from new.')
end

store_diffs = zeros(num_differences, 3);

for i = 1:size(final_new.DetTimes, 1)
    for j = 1:size(final_old.DetTimes, 1)
        % stuff here to compare
    end
end

%% Compare detections using reviewed seizures

% Load in seizures using ReadSeizures(seizures.txt)
newStr = split(filename, '\');
seizureFile = [newStr{1} '\' newStr{2} '\' newStr{3} '\Seizure\' newStr{3} '.txt'];
seizures = ReadSeizures(seizureFile);

% We can use the reviewed, confirmed seizures to check the accuracy of each
% algo output. They should, at the bare min., be the same. If there is
% discrepancy between the accuracies, then proceed to cross check which
% seizures were unique to each detection approach and if those are either
% false positives or real seizures.

% Check with old algo detections first
oldDetTimes = final_old.DetTimes;
newDetTimes = final_new.DetTimes;
oldHits = 0;
newHits = 0;
for i = 1:size(seizures, 1)
    channel = seizures{i, 1};
    sz_start = seconds(seizures{i, 4});
    sz_end = sz_start + seizures{i, 5};

    
    old_match_chan = oldDetTimes(oldDetTimes(:, 1) == channel, :);
    old_match_time = old_match_chan(sz_start - 90 <= old_match_chan(:, 2) & sz_end + 90 >= old_match_chan(:, 2), :);

    new_match_chan = newDetTimes(newDetTimes(:, 1) == channel, :);
    new_match_time = new_match_chan(sz_start - 90 <= new_match_chan(:, 2) & sz_end + 90 >= new_match_chan(:, 2), :);
    
    if any(old_match_time)
        oldHits = oldHits + 1;
    end

    if any(new_match_time)
        newHits = newHits + 1;
    end

end

disp(['Old method had: ' num2str(size(seizures,1) - oldHits) ' misses.'])
disp(['New method had: ' num2str(size(seizures,1) - newHits) ' misses.'])