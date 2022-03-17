function AlgorithmResults = ConcatAlgos(OUTPUTS, info)

% Get outputs from analysis modules
AC = OUTPUTS.AC;
FFT = OUTPUTS.FFT;
LL = OUTPUTS.LL;
SS = OUTPUTS.SS;

% stop analysis timer
duration = toc / 60;                                     %End the timer.
disp(['Analysis took ' num2str(duration) ' minutes']);   %Display how long the analysis took.

%Interpolate so that all the results can be
%combined if they're different sized matrices
%(shouldn't be necessary if window + step sizes
%are the same for each algorithm).
smallest = 1:min([size(AC,2),size(FFT,2),size(LL,2),size(SS,2)]);   %Find the smallest of the result matrices.
biggest = 1:max([size(AC,2),size(FFT,2),size(LL,2),size(SS,2)]);    %Find the largest of the result matrices.
PLAY = zeros(size(AC,1),smallest(end));                             %Initialize temporary matrix.
if size(AC,2) > smallest(end)                                       %If AC results are bigger than the smallest results...
    for int = 1:size(AC,1)                                          %Go through each channel in the results (First dimension).
        PLAY(int,:) = interp1(biggest,AC(int,:),smallest);          %Interpolate so that the AC results are the same size as the largest...
    end
    AC = PLAY;                                                      %Update AC in interpolated form.
end
PLAY = zeros(size(AC,1),smallest(end));                             %Initialize temporary matrix.
if size(FFT,2) > smallest(end)                                      %If FFT results are bigger than the smallest results...
    for int = 1:size(FFT,1)                                         %Go through each channel in the results (First dimension).
        PLAY(int,:) = interp1(biggest,FFT(int,:),smallest);         %Interpolate so that the FFT results are the same size as the largest...
    end
    FFT = PLAY;                                                     %Update FFT in interpolated form.
end
PLAY = zeros(size(AC,1),smallest(end));                             %Initialize temporary matrix.
if size(LL,2) > smallest(end)                                       %If LL results are bigger than the smallest results...
    for int = 1:size(LL,1)                                          %Go through each channel in the results (First dimension).
        PLAY(int,:) = interp1(biggest,LL(int,:),smallest);          %Interpolate so that the LL results are the same size as the largest...
    end
    LL = PLAY;                                                      %Update LL in interpolated form.
end
PLAY = zeros(size(AC,1),smallest(end));                             %Initialize temporary matrix.
if size(SS,2) > smallest(end)                                       %If SS results are bigger than the smallest results...
    for int = 1:size(SS,1)                                          %Go through each channel in the results (First dimension).
        PLAY(int,:) = interp1(biggest,SS(int,:),smallest);          %Interpolate so that the SS results are the same size as the largest...
    end
    SS = PLAY;                                                      %Update SS in interpolated form.
end
%Normalizing
empchan = find(lower(info.ChannelNames) == 'e');                       %Find which channels to be analyzed are empty.
for ec = 1:size(empchan,1)                                          %Set the channels that are empty to all zeros.
    AC(empchan(ec),:) = 0;
    FFT(empchan(ec),:) = 0;
    LL(empchan(ec),:) = 0;
    SS(empchan(ec),:) = 0;
end
ACNEWnorm1 = AC;        %Preallocate space for normalized results.
FFTNEWnorm1 = FFT;      %Preallocate space for normalized results.
LLNEWnorm1 = LL;        %Preallocate space for normalized results.
SSNEWnorm1 = SS;        %Preallocate space for normalized results.
for C = 1:size(AC,1)                                %Normalizing each channel so that results range from 0 to 1.
    ACNEWnorm1(C,:) = (AC(C,:)-min(AC(C,:)))...
        /(max(AC(C,:))-min(AC(C,:)));               %Normalize AC.
    FFTNEWnorm1(C,:) = (FFT(C,:)-min(FFT(C,:)))...
        /(max(FFT(C,:))-min(FFT(C,:)));             %Normalize FFT.
    LLNEWnorm1(C,:) = (LL(C,:)-min(LL(C,:)))...
        /(max(LL(C,:))-min(LL(C,:)));               %Normalize LL.
    SSNEWnorm1(C,:) = (SS(C,:)-min(SS(C,:)))...
        /(max(SS(C,:))-min(SS(C,:)));               %Normalize SS.
end
for C = 1:size(AC,1)                    %Replace NaNs with zero in case they exist.
    if isnan(ACNEWnorm1(C,1))      %Find NaNs.
        ACNEWnorm1(C,:) = 0;            %Replace them with zeros.
    end
    if isnan(FFTNEWnorm1(C,1))    %Find NaNs.
        FFTNEWnorm1(C,:) = 0;           %Replace them with zeros.
    end
    if isnan(LLNEWnorm1(C,1))      %Find NaNs.
        LLNEWnorm1(C,:) = 0;            %Replace them with zeros.
    end
    if isnan(SSNEWnorm1(C,1))     %Find NaNs.
        SSNEWnorm1(C,:) = 0;            %Replace them with zeros.
    end
end
% organize algorithm results
AlgorithmResults.Normalized.AC = ACNEWnorm1;
AlgorithmResults.Normalized.FFT = FFTNEWnorm1;
AlgorithmResults.Normalized.LL = LLNEWnorm1;
AlgorithmResults.Normalized.SS = SSNEWnorm1;

end