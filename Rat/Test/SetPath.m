function SetPath(top_folder)
% SetPath is a function that will set the MATLAB path to top_folder and all
% of its subfolders. This is so that functions and scripts in that directory tree will
% be prioritized.

% Check input type first.
if ~isText(top_folder)
    error('Input must be a string or character array.')
end

% If the input is a cell array of text, just extract the first element of
% that cell array.
if iscell(top_folder)
    top_folder = top_folder{1};
end

% Set the warning generated for attempting to add invalid path name to an
% error. This allows the try-catch to effectively trap the warning.
s = warning('error', 'MATLAB:mpath:nameNonexistentOrNotADirectory');

% Try-catch block to check if input is a valid directory.
try
    % First change directory to top of tree, then add the subfolders.
    cd(top_folder);
    addpath(genpath(top_folder))
catch
    error(['folder provided is not a valid directory: ' pwd() '\' top_folder])
end

% Set the warning back to an actual warning before exiting the function.
% Otherwise it'll remain an error.
warning(s);

end