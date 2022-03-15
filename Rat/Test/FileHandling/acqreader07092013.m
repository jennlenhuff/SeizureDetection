function structure = acqreader07092013(n)                                   %Function to read relevant information from .acq file.
structure.filestarttime = n;                                                %Get file start time from name.
structure.FID = fopen(n);                                                   %Open the file.
if structure.FID == -1                                                      %Display a failure if the file could not be opened.
    error('File Open Failed')                                               %Error message.
end
structure.nItemHeaderLen = fread(structure.FID,1,'short');                  %Read header length.
structure.IVersion = fread(structure.FID,1,'long');                         %Read version identifier.
structure.IExtItemHeaderLen = fread(structure.FID,1,'long');                %Read extended item header length
structure.nChannels = fread(structure.FID,1,'short');                       %Read number of channels stored.
fseek(structure.FID,16,'bof');                                              %Seek to proper point of file.
structure.dSampleTime = fread(structure.FID,1,'double');                    %Read the number of milliseconds per sample.
structure.SampleRate = 1000/structure.dSampleTime;                          %Convert to sample rate.
structure.ChannelNames = zeros(structure.nChannels,1);                      %Allocate space for channel names.
fseek(structure.FID,structure.IExtItemHeaderLen,'bof');                     %Seek past header length.
structure.IChanHeaderLen = fread(structure.FID,1,'long');                   %Read length of channel header.
fseek(structure.FID,(structure.IExtItemHeaderLen + (structure.IChanHeaderLen * structure.nChannels)),'bof');    %Seek to appropriate place.
structure.nlength = fread(structure.FID,1,'int32');                         %Read nLength.
structure.DataStart = structure.nlength + (4*structure.nChannels) + (structure.IChanHeaderLen * structure.nChannels) + structure.IExtItemHeaderLen;     %Read start of data.
fseek(structure.FID,0,'eof');                                               %Seek to eof.
structure.EndOfFileInBits = ftell(structure.FID);                           %Read the end of the file in bits.
structure.EndOfFileInSeconds = (structure.EndOfFileInBits - structure.DataStart)/structure.nChannels/4/500;     %Convert end of file to seconds.
structure.EndOfFileInHours = structure.EndOfFileInSeconds/3600;             %Convert end of file to hours.
fseek(structure.FID,structure.IExtItemHeaderLen,'bof');                     %Seek back to appropriate place in file.
for channels = 1:structure.nChannels                                        %Iterate through channels.
    structure.IChanHeaderLen = fread(structure.FID,1,'long');               %Read length of channel header.
    structure.nNum = fread(structure.FID,1,'short');                        %Read channel number.
    structure.szCommentText = fread(structure.FID,40,'char');               %Read comment text.
    structure.szCommentText = structure.szCommentText';                     %Orient comment correctly.
    structure.szCommentText = char(structure.szCommentText);                %Convert comment to char.
    structure.ChannelNames(channels,1:40) = structure.szCommentText;        %Assign channel names.
    fseek(structure.FID,structure.IExtItemHeaderLen + (channels*structure.IChanHeaderLen),'bof');   %Seek back again.
end
clear('structure.szCommentText');   %Clear variable
structure.ChannelNames = char(structure.ChannelNames);  %Convert channel names to char format.
% fclose(structure.FID);
end