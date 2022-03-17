function data = ReadDetectionFile(detection_file_path)

fid = fopen(detection_file_path);
file_data = textscan(fid, '%f','delimiter',',');
fclose(fid);

% data in a single column, need to convert to two column format
x = file_data{:};

% error handling
if mod(length(x), 2) == 0
    data = zeros(length(x) / 2, 2);
else
    error('Invalid detection (.DET) file.');
end

data(:,1) = x(1:2:end);
data(:,2) = x(2:2:end);

end