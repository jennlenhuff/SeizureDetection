function [DETECTIONS, info, szseconds] = SzDetectAlt2(SPIKES,info,absminthresh,cutoff)
%This function is what will actually detect the 'spikes' in the results
%from an algorithm result matrix... Written by Thomas Newell.



chandiff = info.nChannels-size(SPIKES,1);           %Finds the difference between the number of channels and number of channels analyzed by algorithms.
if chandiff > 0                                     %If there is a difference.
    zerotack = zeros(chandiff,size(SPIKES,2));      %Makes a vector of zeros the length of one file.
    SPIKES = [SPIKES;zerotack];                     %Tacks the zeros to the bottom of SPIKES.
end
for r = 1:size(SPIKES,1)                            %For each line of SPIKES...  
    if isnan(SPIKES(r,:))                           %If a line is full of NANs...
        SPIKES(r,:) = 0;                            %Replace the line with zeros...        
    end
end
secondsperindex = info.EndOfFileInSeconds/size(SPIKES,2);       %Conversion factor to turn spike times to seconds.
szseconds = [];                                                 %Makes space for where seizure times (in seconds) will go.
sznumber = 1;                                                   %Starts a seizure counter.
for SpikeChan = 1:size(SPIKES,1)                                %For each channel
    chanmean = mean(SPIKES(SpikeChan,:));                       %Get the mean for the channel's results.
    if chanmean == 0                                            %Don't detect any spikes if the mean is 0.
        continue; 
    end                                                         %If the channel is full of zeros, stop and move on.
    Scopy = SPIKES(SpikeChan,:);                                %Get a copy of the results for the channel.
    Scopy(find(Scopy > cutoff*mean(Scopy))) = cutoff*mean(Scopy);   %Set all values that exceed the cutoff to the cutoff value.
    minthresh = absminthresh*mean(Scopy);                       %Find the value that will be the threshold based on the multiples of the mean.
    ChanResults = SPIKES(SpikeChan,:);                          %Get the results again for the specific channel.
    [maxval,maxindex] = max(ChanResults);                       %Finds max peak in results.
    while maxval > minthresh                                    %while the max peak is above the algorithm threshold:
        szseconds(sznumber,:) = [SpikeChan,maxindex*secondsperindex, maxval];   %Stores seizure [Channel,Time(sec), val].
        lowindex = (maxindex - floor(90/secondsperindex));      %Finds point 90s before peak.
        highindex = (maxindex + floor(90/secondsperindex));     %Finds point 90s after peak.
        if lowindex <= 0                                        %This makes it so you can't zero before the start.
            lowindex = 1;                                       %If the index is negative, make it the start of the results.
        end
        if highindex >= size(SPIKES,2)                          %This makes it so you can't zero after the end.
           highindex = size(SPIKES,2);                          %If the index is too large, make it the end of the file.
        end
        ChanResults(lowindex:highindex) = 0;                    %Actually zeros spike.
        sznumber = sznumber + 1;                                %Counts seizure.
        [maxval,maxindex] = max(ChanResults);                   %Finds a next highest peak.
    end
end
DETECTIONS = sznumber - 1;                                      %Displays the number of detections.