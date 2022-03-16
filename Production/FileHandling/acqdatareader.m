function selected_data = acqdatareader(structuretoload,t_start,length)
%This function takes a structure from acqreader, a start time, and a length
%(seconds) and returns a data structure with both EEG and a time vector.
structure = structuretoload;    %Input structure.
fseek(structure.FID,structure.DataStart + (4*t_start*structure.SampleRate*structure.nChannels),'bof');      %Seek to where the EEG begins in the ACQ.
selected_data.data = fread(structure.FID, [structure.nChannels (length*structure.SampleRate)], 'int32');    %Read in the EEG data and store it in the .data field.
selected_data.time = t_start:1/structure.SampleRate:length + t_start - (1/structure.SampleRate);            %Create a time vector and store it in the .time field. (Can get rid of this for speed if needed)
end

