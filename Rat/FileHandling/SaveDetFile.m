function thrval = SaveDetFile(COMB, combszseconds, direc, folddate, THRESH)

cutoff = inf;
fclose('all');                  %Close open files.
for tv = 1:size(COMB,1)         %Iterate through each channel.
    Scopy = COMB(tv,:);         %Copy results from that channel.
    Scopy(Scopy > cutoff*mean(Scopy)) = cutoff*mean(Scopy);   %Find all results over the cutoff*mean value and set them to the cutoff*mean value.
    thrval(tv,1) = THRESH*mean(Scopy);  %Get the threshvalue for each channel. Thresh is set to THRESH multiples of the mean.
end
DetFile = [direc '\' folddate '_Version3_' date '.det'];  %Create a name for the .det file.
DetFID = fopen(DetFile,'w');                                %Open the file.
if size(combszseconds,2) > 0                                %If there are detections...
    combszseconds = sortrows(combszseconds,2);              %Sort the detections based on the time they occured.
    for ccc = 1:size(combszseconds,1)                       %Iterate through detected events.
        fprintf(DetFID,['%d, ' num2str(floor(combszseconds(ccc,2))) '\n'],combszseconds(ccc,1));    %Add event to .det file.
    end
end
fclose(DetFID);