function [fftvals] = FFT_V3(x,window,step,scale)
%This is a fully commented function that runs the latest version of the
%FFT Power Algorithm as of 6/22/2015... n (string) is the title of
%the acq file, window(#) is the size of the window, and step(#) is the step
%size... Written by Thomas Newell



                           %Closes all figures if any are open.
% load('C:\Users\SeizureDetection\Desktop\WeightFunc')
load('WeightFunc.mat')%Load the weight function that will be used later.
%% This portion of the code runs the actual FFT Power Algorithm.
disp('Starting Power Analysis');            %Displays the start of the spectral power analysis.
windowsize = window*500;                    %Sampling rate is 500Hz, so window size is window*500 samples.
stepsize = step*500;                        %Step size is 500 samples/sec times user-defined step.

itterations = floor((length(x)-windowsize+stepsize)/stepsize);   %Finds the number of windows that will need to be analyzed.
if itterations < 1                                              %Continues with code as long as there is a window to be analysed.
    return
end


% define window starts and ends
blockstarts = 0:step:length(x)/500-window+1; 
blockends = blockstarts + window;

fftdata = zeros(itterations,windowsize+1);
fftdata(1,1:windowsize+1) = x(1:blockends(1)*500+1);   
% for itts = 1:itterations                                        %For each window...
%     if itts == 1
%         temp = x(1:blockends(1)*500+1);
%         fftdata(itts,1:size(temp,2)) = fft(temp);
%     else
%         temp = x(blockstarts(itts)*500:blockends(itts)*500);
%         fftdata(itts,1:size(temp,2)) = fft(temp);           %Performs a fast fourier transform.
%     end
% end
tic
for itts = 1:itterations                                        %For each window...
    if itts == 1
        temp = x(1:blockends(1)*500+1);
        fftdata(itts,1:size(temp,2)) = temp;
    else
        temp = x(blockstarts(itts)*500:blockends(itts)*500);
        fftdata(itts,1:size(temp,2)) = temp;           %Performs a fast fourier transform.
    end
end
toc
fftdata = fft(fftdata, size(fftdata,2), 2);
fftdata = fliplr(abs(fftdata));                                 %Flips the data left/right.
fftdata = fftdata(:,1:floor((size(fftdata,2)-1)/2));               %Only uses half the data since the FFT spectrum is symmetrical.
newWeightFunc = interp1(linspace(0,250,length(WeightFunc)),WeightFunc,linspace(0,250,size(fftdata,2)));     %Interpolate the weight function so it can be multiplied to the generated power spectrum.
for row = 1:size(fftdata,1)
    fftdata(row,:) = fftdata(row,:).*(scale.*newWeightFunc);    %Multiply the results from the fft by the weight function.
end
fftvals = sum(fftdata,2); fftvals = fftvals';                  %Sums up the spectrum (0-250 Hz) and transposes it to make a list of sums.


%All results are stored in FFTTOT!
disp('Finished Power Analysis');                                        %Complete!