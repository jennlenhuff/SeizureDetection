function OUTPUTS = MainAnalysisV2(file)
%% Main Analysis function takes file being analyzed, hour of data from single channel,
% and the channel number that is being analyzed. Returns outputs from
% analysis modules in structure, OUTPUTS.

% input paramters
window = 25;
step = 1;

M3tot = [];
FFTTOT = [];
LLTOT = [];
SPIKETOT = [];

% initialize outputs
emp = 0;
emptychans = lower(file.ChannelNames) == 'e';        %Gets empty channel names from file (any channel with an 'e' in an animal name).
selected_data = acqdatareader(file,0,12*3600);    %Loads in 1 hour of data.
data = selected_data.data;
hours  = floor(file.EndOfFileInHours); 

if size(selected_data.data,1) == 0              %If there is no data in the first channel...
    return                                       %Break out of this loop (some bug fix).
end

if size(data,1) == 0                          %If there is no data in the first channel...
    return                                    %Break out of this loop (some bug fix).
end

% count empty channels


for chan = 1:file.nChannels                         %Stepping through channels...
    if any(chan == emptychans)                      %If the channel is one of the empty ones.
        emp = emp + 1;                              %Adds one to the empty channel counter.
        continue;                                   %Skips to the next channel if the current one is empty.
    end
    
    
        %AC
        ACval = AC_V3(data(chan,:),window,step,60);                  %Run Autocorrelation algorithm.
        M3tot(chan,1:size(ACval,2)) = ACval;                              %Results for each channel saved in M3chan.
        %FFT
        fftvals = FFT_V3(data(chan,:),window,step,1);                 %Run FFT/Spectral analysis algorithm.
        FFTTOT(chan,1:size(fftvals,2)) = fftvals;                     %Puts the results into a matrix titled FFTchan.
        %LL
        linelengths = LL_V3(data(chan,:),window,step);                %Run Linelength algorithm.
        LLTOT(chan,1:size(fftvals,2)) = linelengths; %Stores hour of data in LLTOT.
        %SS
        SPIKECOUNTchan = SS_V3(data(chan,:),window,step,7.6e10);      %Run Spike analysis algorithm.
        SPIKETOT(chan,1:size(fftvals,2)) = SPIKECOUNTchan; %Stores hour of data in SPIKETOT.
 
    if chan == file.nChannels
        OUTPUTS.AC = M3tot;
        OUTPUTS.FFT = FFTTOT;
        OUTPUTS.LL = LLTOT;
        OUTPUTS.SS = SPIKETOT;
        OUTPUTS.empychans = emp;
    end
end
