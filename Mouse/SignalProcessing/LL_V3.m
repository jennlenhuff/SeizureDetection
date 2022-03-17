function [linelengths] = LL_V3(x,window,step) 
%This is a fully commented function that runs the latest version of the
%Line Length Algorithm as of 6/22/2015... n (string) is the title of
%the acq file, window(#) is the size of the window, and step(#) is the step
%size... Written by Thomas Newell

%% This portion of the code runs the Line Length Algorithm
disp('Starting LineLength Analysis');                   %Displays the start of the linelength analysis.
winsize = window*500;                                   %Sampling rate is 500Hz, so window size is window*500 samples.
stepsize = step*500;                                    %Step size is 500 samples/sec times user-defined step.

itterations = floor((length(x)-winsize+stepsize)/stepsize);
if itterations < 1                                      %Continues with code as long as there is a window to be analysed.
    return
end

linelengths = zeros(1,itterations);             %Allocates space for the linelength results.

for k = 1:itterations                           %Takes chunks that overlap by (step) seconds...
    loc=(k-1)*stepsize;                         %Location of the beginning of the data to be analyzed.
    LL = mean(abs(diff(x(1+loc:loc+winsize)))); %Finds line length for the current window.
    linelengths(k) = LL;                        %Stores linelength results in LL matrix.
end
%ALL RESULTS ARE STORED IN THE MATRIX LLTOT!!!
disp('Finished LineLength Analysis');                   %Complete!
