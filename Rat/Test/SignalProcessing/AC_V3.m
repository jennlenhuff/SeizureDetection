function [ACval] = AC_V3(x,window,step,subwinlen)
%This is a fully commented function that runs the latest version of the
%Autocorrelation Algorithm as of 6/22/2015... n (string) is the title of
%the acq file, window(#) is the size of the window, step(#) is the step
%size, subwinlen(#) is the subwindow size in samples... Written by Thomas Newell



%% This portion of the code runs the actual Autocorrelation Algorithm.
%disp('Starting *NEW* AutoCorrelation Analysis');    %Displays the start of the autocorr analysis.

% Convert window (seconds) to number of samples
winsize = window*500;                               %Sampling rate is 500Hz, so window size is window*500 samples.
% Define the window step size in samples
stepsize = step*500;                                %Step size is 500 samples/sec times user-defined step.

% winvec is a vector of start points for moving windows
winvec = 1:stepsize:size(x,2)-winsize; 
windata = zeros(size(winvec,2),winsize);                    %Allocates space for each window.
for wincount = 1:size(winvec,2)                                    %Stepping through each window start...
    if winvec(wincount) + winsize < length(x)
        windata(wincount,1:winsize+1) = ...
        x(1,winvec(wincount):winvec(wincount)+winsize);  %Creates matrix of windows.
    else
        windata(wincount,1:length(x(1,winvec(wincount):end))) = ...
        x(1,winvec(wincount):end);  %Creates matrix of windows.
    end
end
subwinvec = 1:subwinlen:size(windata,2);                    %Creates vector of start points for subwindows.
ACval = zeros(1,size(windata,1));                           %Preallocating space.
for BigWin = 1:size(windata,1)                              %For each big window.
    EEG = windata(BigWin,:);                                %Saves the big window EEG to a new variable.
    subwincount = 1;                                        %Initialize counting variable.
    start = 1;                                              %Initialize starta variable.
    Smax = zeros(1,size(subwinvec,2)); Smin = zeros(1,size(subwinvec,2));   %Preallocate vectors for max and mins.
    while start < size(EEG,2)                               %While analyzing...
        if size(EEG,2)-start > 60                           %If window is greater than 60 samples
            subwindata = EEG(1,start:start+subwinlen);          %Get the data from the window.
        else
            subwindata = EEG(1,start:size(EEG,2));          %Otherwise get what is possible.
        end
        Smax(1,subwincount) = max(subwindata);              %Get the max for a subwindow.
        Smin(1,subwincount) = min(subwindata);              %Get the min for a subwindow.
        start = start + subwinlen;                          %Overwrite starting point.
        subwincount = subwincount + 1;                      %Count a subwindow analyzed.
    end
    %Now we have the max and min of each subwindow
    count = 1;                                              %Initialize counting variable.
    HV = zeros(size(Smax,2)-2, 1);
    LV = HV;
    while count <= size(Smax,2)-2                           %While there are subwindows to analyze.
        HV(count) = min([Smax(count),max([Smax(count+1),Smax(count+2)])]);  %High values are the minimum of a particular subwindow max and the following two subwindows.
        LV(count) = max([Smin(count),min([Smin(count+1),Smin(count+2)])]);  %Low values are the maximum of a particular subwindow min and the following two subwindows.
        count = count + 1;                                  %Iterate counter.
    end
    ACval(1,BigWin) = sum(HV-LV);                           %Store the difference between high and low values in ACval.
end



%All results stored in M3tot!!!
disp(['Memory used: ' num2str(monitor_memory_whos()) ' MB'])
%disp('Finished *NEW* AutoCorrelation Analysis Test');                                       %Complete!
