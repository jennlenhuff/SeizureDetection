function Detections = CompareAlgo(Combined, project_file, file, path)
% Only compares algorithmic results for one data folder. AnalyzeDirectory
% will compare multiple folders.
length_of_file = size(Combined.COMB, 2);
% project_file is a list of csv files, generated from project files
for csv_file = 1:size(project_file,1)
    % see if input is single file or multiple csv files then import
    if iscell(project_file)
        error('Hey you can only input one project file >:(')
    else
        [detection_results, dates, all_animals] = ImportProjectFile(project_file);
    end
    if isempty(Combined.DetTimes)
        algo_data = [];
    else
        algo_data = [Combined.DetTimes(:,1),Combined.DetTimes(:,2),Combined.DetTimes(:,3)];
    end

    % load animals ids from settings file
    animal_ids = LoadSettings(path);
    animal_ids = strrep(animal_ids,' ','');

    % create logical indexing so that we can remove
    keep_animals = zeros(size(detection_results,1), 1);
    new_chans = zeros(size(detection_results,1), 1);
    for i = 1:length(animal_ids)
        % please don't judge O(nm) here
        for j = 1:length(all_animals)
            if strcmp(animal_ids{i}, all_animals{j})
                keep_animals(j) = 1;
                new_chans(j) = i;
            end
        end
    end
    relevant_results = detection_results(logical(keep_animals),:);
    relevant_chans = new_chans(logical(keep_animals),:);
    relevant_results(:,1) = relevant_chans;
    relevant_dates = dates(logical(keep_animals));

    % determine date that detection file comes from
    [algo_date, algo_tod] = ParseDate(file);

    % make struct name from detection file name
    % replace dash with underscore
%     struct_name = ['File_', strrep(file, '-','_')];

    % test CountDetections
    Detections = CountDetections(algo_data, relevant_results, relevant_dates, algo_date, algo_tod, length_of_file);

    num_hits = Detections.AllSeizures.total_algo_seizures - Detections.AllSeizures.false_positives;
    gap = FindGap(algo_data, relevant_results, relevant_dates, algo_date, algo_tod, num_hits);
    Detections.Gaps = gap;
end

