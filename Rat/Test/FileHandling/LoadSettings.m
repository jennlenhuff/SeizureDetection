function animal_ids = LoadSettings(folder_path)

% get settings file from folder_path
path_parts = split(folder_path,'\');
% get just folder name from path parts
folder_name = path_parts{3};
% use folder name to get name of settings file and open the file
settings_file = strcat(folder_name,'_Settings.txt');
settings_path = strcat(strcat(folder_path,'\'), settings_file);
fid = fopen(settings_path);

% handle weird files
if fid < 0
    error('Invalid file identifier.')
end

% extract text from settings file
settings_data = textscan(fid,'%s','delimiter','=');
settings_data = settings_data{1};

% only keep cells that correspond to animal id from settings
keep_cells = zeros(length(settings_data),1);
for i = 1:length(settings_data)
    current_cell = settings_data{i};
    if contains(current_cell,'ID') && ~contains(current_cell,'Dose')
        keep_cells(i+1) = 1;
    end
end
animal_ids = settings_data(logical(keep_cells));
animal_ids(cellfun(@(s) isequal(s,'e'), animal_ids)) = [];

end