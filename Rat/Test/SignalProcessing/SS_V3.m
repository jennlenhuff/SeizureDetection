function [SPIKECOUNTchan] = SS_V3(x,window,step,spikethresh)
%This is a fully commented function that runs the latest version of the
%Line Length Algorithm as of 6/22/2015... n (string) is the title of
%the acq file, spikethresh is the value that is used to detect a single
%spike, window(#) is the size of the window, and step(#) is the step
%size... Written by Thomas Newell



load('SpikeFunc.mat');    %Load Spike Frequency weight function that will be used later.
%% This portion of the code runs the Slope Analysis Algorithm
disp('Starting Slope Analysis');                        %Displays the start of the spike frequency analysis.
winsize = window*500;                                   %Sampling rate is 500Hz, so window size is window*500 samples.
stepsize = step*500;                                    %Step size is 500 samples/sec times user-defined step.
s = abs(diff(x)/.002);                          %Get the difference in hight between samples.
s(1,end+1) = s(1,end);                              %Copy last diff since the results will return a smaller result by 1.
S = minmaxfilt(s,5,'max','same');               %Filter the results using a moving max filter.

itterations = floor((length(S)-winsize+stepsize)/stepsize);%Finds the number of windows that will need to be analyzed.
SPIKECOUNTchan = zeros(1,itterations);          %Preallocate space.
if itterations < 1                              %Continues with code as long as there is a window to be analysed.
    return
end

result = 1;
itterations = floor((length(x)-winsize+stepsize)/stepsize);

for k = 1:itterations                           %Takes chunks that overlap by (step) seconds...
    loc=(k-1)*stepsize;                         %Location of the beginning of the data to be analyzed.
    A = S(loc+1:loc+winsize) - spikethresh;     %Subtract the spike thresh so that crossings are identified as either positive or negative values.
    crossings = find(A(1:end-1).*A(2:end)<0);   %Find the crossings.
    numspikes = (size(crossings,2)/2)/window;   %Find the spiking frequency (number of crossings/2 divided by the window size)
    [~,ind] = min(abs(f_spike-numspikes));    %Find the index closest to corresponding with the value from spike func imported earlier.
    if numspikes*(w_spike(ind)) < 0.1           %Eliminate the results that are too small.
        SPIKECOUNTchan(result) = 0;             %Set them to zero.
    else
        SPIKECOUNTchan(result) = numspikes*(w_spike(ind));  %Multiply results by the appropriate value from the spike func imported earlier.
    end
    result = result+1;                          %Iterate.
end
%ALL RESULTS ARE STORED IN THE MATRIX SPIKETOT!!!
disp('Finished Slope Analysis');                   %Complete!
