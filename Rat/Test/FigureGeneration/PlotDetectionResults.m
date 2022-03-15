function PlotDetectionResults(COMB, thrval, info)

clf                                         %Clear current figure window if one is open.
fl = (info.EndOfFileInHours);               %Get the length of the file in hours.
timevar = linspace(0,fl,size(COMB,2));      %Create a time vector for the x-axis.
for ccc=1:size(COMB,1)                      %Iterate through channels.
    if ccc > size(info.ChannelNames,1)      %If the current channel is greater than the number of channels in the file (error if empty last channel)...
        break                               %Break out of the loop.
    else
        plot(timevar, COMB(ccc,:));         %Plot the combination results for that channel.
        line([timevar(1) timevar(end)],[thrval(ccc,1) thrval(ccc,1)],'color','g','linewidth',3);    %Plot a horizontal threshold line in green.
        xlabel('time'), ylabel('COMB');title([n ' channel ' num2str(ccc)]);                         %Add labels and title.
        text(1,.8, [info.ChannelNames(ccc,:)]);                                                     %Add channel name into figure.
        if mean(COMB(ccc,:)) > 0
            axis([0 info.EndOfFileInHours -.1*min(COMB(ccc,:)) 1.1*(max(COMB(ccc,:)))])             %Set axes if the results for that channel aren't all zeros.
        else
            axis([0 info.EndOfFileInHours -.1 1.1])                                                 %Set axes if the results are all zeros.
        end
        saveas(gcf,'_SzDetectionV6_Chan_' num2str(ccc) '_results','png')     %Save the figure as a .png in the same folder as the .acq file.
        close('all');   %Close the figure.
    end
end

end