function file_list = GetFileList(main_dir, ext)
% GetFileList takes a directory path and file extension to return a list of
% all the specified file types in input directory.

% retrieves a list of files of specific file extension (ext) from a primary
% directory (main_dir), may include subfolders

% Remove hidden/empty folders
main_dir_contents = RemoveHidden(dir(main_dir));

% keep only directories
sub_folds = main_dir_contents([main_dir_contents.isdir]);

if isempty(sub_folds)
    file_list = dir(fullfile(main_dir, strcat('*',ext)));  % get list of files
else
    file_list = dir(fullfile(main_dir, strcat('**\*',ext)));  % get list of files in every subfolder
end