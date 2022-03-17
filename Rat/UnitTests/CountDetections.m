function Detections = CountDetections(algo_results, main_results, main_dates, algo_date, algo_tod, length_of_file)

% algo results is formatted n x 2 (first column is channel, second is where
% potential seizure was detected in seconds)

% main results are from manual eeg review in the playback software
% n x 4: first column is chan number, second is seizure start, third is the
% end time, 4th is the seizure stage

% algo_date: datetime of data that was used as input to algorithm
% algo_tod: time of day (either AM or PM) for data used as input to
% algorirthm
% main_dates: row-oriented vector of datetimes for each seizure in imported
% project file

% purpose of this function is to see if the second column value in
% algo_results is in range with any corresponding channel seizure duration
% in the main_results. from this, a hits, misses, and fp's can be counted

% from manual eeg review
% only use results that match the current .det file date
main_results = main_results(main_dates == algo_date, :);
all_stages = main_results(:,4);

% intialize structure as output
Detections.Stage0.hits = 0;
Detections.Stage1.hits = 0;
Detections.Stage2.hits = 0;
Detections.Stage3.hits = 0;
Detections.Stage4.hits = 0;
Detections.Stage5.hits = 0;

% initialize seizure counts
stage0_count = 0;
stage1_count = 0;
stage2_count = 0;
stage3_count = 0;
stage4_count = 0;
stage5_count = 0;

% set gap counter
gap = 0;

if algo_date == datetime(2018, 11, 16)
    disp('stop')
end

gaps = NaN(1000, 1);
prev = 0;
j = 1; % slow pointer

% count false positives first by using manual results as frame of reference
for i = 1:size(main_results,1)
    % data for current manually detected seizure
    current_chan = main_results(i, 1);
    current_start = main_results(i, 2);
    current_end = main_results(i, 3);
    stage = main_results(i, 4);

    % get end of file in seconds and start of file
    end_of_file = (algo_tod * 3600) + length_of_file;
    start_of_file = (algo_tod * 3600);

    % check if manual seizure from current date came from current file
    if (current_start >= (start_of_file)) && (current_start < end_of_file)
        current_start = current_start - algo_tod * 3600;
        current_end = current_end - algo_tod * 3600;
    else
        continue
    end
    
    % count seizures by stage
    switch stage
        case 0
            stage0_count = stage0_count + 1;
        case 1
            stage1_count = stage1_count + 1;
        case 2
            stage2_count = stage2_count + 1;
        case 3
            stage3_count = stage3_count + 1;
        case 4
            stage4_count = stage4_count + 1;
        case 5
            stage5_count = stage5_count + 1;
    end
    % check if the algorithm results have a seizure with same channel as
    % current seizure
    if isempty(algo_results)
        continue;
    else
        algo_matching_chan = algo_results(algo_results(:,1) == current_chan, :);
    end
    
    % logicals if algo results contain a seizure, extend window 10 secs on
    % start side to account for user variation where seizure is first
    % marked
    seizure_duration_idx = (current_start-120 <= algo_matching_chan(:,2) & current_end+120 >= algo_matching_chan(:,2));
    first = find(algo_results(:,1) == current_chan, 1, "first");
    testcount = sum(~(algo_results(:,1) == current_chan));
    
    all_idx = (current_start-90 <= algo_results(:,2)) & (current_end+90 >= algo_results(:,2)) & algo_results(:,1) == current_chan;
    

    % hit if there is at least one satisfied condition, if there is more
    % than one algo seizure that matches, then the seizure was just really
    % long. i guess the user should have to figure this one out?
    if any(seizure_duration_idx)
        % if there was one comparison satisfied then it's a hit
        struct_name = strcat('Stage',num2str(stage));
        Detections.(struct_name).hits = Detections.(struct_name).hits + 1;
    elseif sum(seizure_duration_idx) == 0
        disp('No hits found')
    else
        % I'll be terrified if this is reached.
        error('This shouldn''t happen.');
    end
    
end
% Count total seizures
manual_seizure_count = stage0_count + stage1_count + stage2_count + ...
    stage3_count + stage4_count + stage5_count;
% set total seizures
Detections.AllSeizures.total_manual_seizures = manual_seizure_count;
Detections.AllSeizures.total_algo_seizures = size(algo_results, 1);

% set seizures per stage
Detections.Stage0.seizure_count = stage0_count;
Detections.Stage1.seizure_count = stage1_count;
Detections.Stage2.seizure_count = stage2_count;
Detections.Stage3.seizure_count = stage3_count;
Detections.Stage4.seizure_count = stage4_count;
Detections.Stage5.seizure_count = stage5_count;

% the candidate seizures in algo_results can ONLY be hits or false
% positives. Therefore, false positives is just the total number of
% algorithm detections - hits
total_hits = Detections.Stage0.hits + Detections.Stage1.hits + Detections.Stage2.hits + ...
    Detections.Stage3.hits + Detections.Stage4.hits + Detections.Stage5.hits;

% calculate false positives
Detections.AllSeizures.false_positives = Detections.AllSeizures.total_algo_seizures - total_hits;

% we calculate misses similarly to false positives:
% misses(stageX) = seizures detected manually(stageX) - hits(stageX)
Detections.Stage0.misses = Detections.Stage0.seizure_count - Detections.Stage0.hits;
Detections.Stage1.misses = Detections.Stage1.seizure_count - Detections.Stage1.hits;
Detections.Stage2.misses = Detections.Stage2.seizure_count - Detections.Stage2.hits;
Detections.Stage3.misses = Detections.Stage3.seizure_count - Detections.Stage3.hits;
Detections.Stage4.misses = Detections.Stage4.seizure_count - Detections.Stage4.hits;
Detections.Stage5.misses = Detections.Stage5.seizure_count - Detections.Stage5.hits;

% gaps = gaps(~isnan(gaps));
% Detections.Gaps = gaps;

end