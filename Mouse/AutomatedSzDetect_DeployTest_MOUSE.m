function AutomatedSzDetect_DeployTest_MOUSE(PATH)
%Automated Sz Detection V6
%Original versions (V1-V6) Written by Thomas Newell
%Last Update: 11/19/2021
% All recent updates have been to time performance and not to altering
% original intention of the output/analysis.
NOW = clock;            %Get current time.
NOW_DATE = datetime(NOW(1), NOW(2), NOW(3));
keep('NOW','paths','PATH','project_file','AllPaths')                  %Clear all variables that aren']t NOW, pahts, or PATH (speeds things up when handling multiple runs).
disp(['Starting analysis of ' PATH]);
%Display which directory is being analyzed to the command window.
foldlist = dir(PATH);                      %Get a list of folders in that directory.
fold = 3;                                   %The first two folders are junk/hidden. Start with the third.
while fold < size(foldlist,1) + 1           %Go through all the folders in the directory, except the active recording directory.
    folddate = foldlist(fold,1).name;       %Get the name of the folder...
    folder = [PATH '\' folddate];          %Create string that is the path to that folder.
    if size(folddate,2) > 8                 %Folder size must be longer than 8... As it should be (EG: 20200422-000000 for 4/22/2020 @ 00:00:00).
        if folddate(9) == '-'               %Ninth index should be a '-' for the folders we're using.
            % Check the time that file was recorded and if it's too old to
            % be processed.
            % Parse date
            folder_year = str2double(folddate(1:4));
            folder_month = str2double(folddate(5:6));
            folder_day = str2double(folddate(7:8));
            folder_date = datetime(folder_year, folder_month, folder_day);
            date_difference = days(NOW_DATE - folder_date);
            if date_difference < 14  %Must be less than 14 days old. Change this if necessary.
                if NOW(3) ~= str2double(folddate(7:8))  %As long as the date isn't the same... (no analyzing active recording directory).
                    %THERE MUST BE NO .DET FILE (Already analyzed)
                    dirlist = dir(folder);                              %Get a structure full of all the items in the folder.
                    isDET = -1;                                         %Initialize under assumption that no ACQ has been analyzed.
                    for D = 3:size(dirlist,1)                           %Going through each item in the folder...
                        % Using .dt2 extension so no conflict from V6 of
                        % seizure detection
                        if strcmp(dirlist(D,1).name(end-2:end),'dt2')       %Check if the item is a .det file.
                            isDET = D;                                  %Mark that item is a .det file.
                        end
                    end
                    if isDET > 0                                        %If a .det was found in the folder...
                        disp(['There is already a .dt2 file for folder ' folddate]);    %Display that...
                        fold = fold + 1;                                %Iterate.
                        continue
                    else
                        for k = 3:size(dirlist,1)                       %Go through the list of items in the directory again.
                            name = dirlist(k,1).name;                   %Get the name of an item.
                            if strcmp(name(end-2:end),'acq') == 1       %If the item is a .acq file...
                                n = name;                               %Save the name to a variable.
                                break                                   %Break out of the loop. We have an ACQ to analyze.
                            end
                        end
                        if exist('n','var') == 0                        %If 'n' hasn't been assigned.
                            disp(['No ACQ file in directory ' folder])  %Display no ACQ file was found.
                            break
                        end
                        disp(['Seizure Detection initiated on ' date ' for File: ' n]);     %Display that seizure detection is being initiated...
                        %% ANALYSIS
                        direc = [PATH '\' n(1:15)];                    %Get the name of the .acq file.
                        sss = dir([direc '\' n]);                       %Get information on the .acq file itself.
                        if sss.bytes < 7.5986e+06                       %File must be > 5 mins in length (this many bytes).
                            disp('ACQ file is too small to analyze!')   %If file is too small, break out of the analysis loop.
                            fold = fold + 1;                            %Iterate.
                            continue
                        end
                        info =  acqreader07092013([direc '\' n]);           %Get information from the acq file.
                        tic;                                                %Start a timer.

                        % Call MainAnalysis function
                        OUTPUTS = MainAnalysisV2(info);

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

                        % % % original parameters % % %
                        % weights
                        Parameters.ACw = 0.17;
                        Parameters.FFTw = 0.49;
                        Parameters.LLw = 0.87;
                        Parameters.SSw = 0.96;

                        % exponential scalars
                        Parameters.ACe = 1.50;
                        Parameters.FFTe = 5;
                        Parameters.LLe = 1.82;
                        Parameters.SSe = 1.70;

                        % threshold
                        Parameters.Threshold = 0.5;

                        % Use parameters to combine algorithms
                        CombinedResults = CombineAlgos(AlgorithmResults, Parameters, info);
                        % Return threshold values out of SaveDetFile to
                        % pass to PlotDetection results
                        thrval = SaveDetFile(CombinedResults.COMB, CombinedResults.DetTimes, direc, folddate, Parameters.Threshold);
%                         PlotDetectionResults(CombinedResults.COMB, thrval, info);

                        nowza = clock;          %Get current time.
                        disp(['Finished at ' num2str(nowza(4)) ':' num2str(nowza(5))]);     %Display when seizure detection for the current file was completed.
                    end
                else
                    disp([folddate ' is or was being recorded today... This folder will be analyzed tomorrow']);    %Display this if current folder is the active recordering directory / was created within the last day.
                end
            else
                disp([folddate ' is too old to review']);   %Display if the current folder is older than the age threshold.
            end
        end
    end
    fold = fold + 1; 	%Iterate folder
end

end