function [date, tod] = ParseDate(detection_file)
% ParseDate takes file name for .det file and finds the date that
% corresponds to the eeg data from which it was created.
% Also returns time of day as hours (integer)
% detecion_file must be just the file name

% extract YYYYMMDD
date_string = detection_file(1:8);

% separate into YYYY, MM, DD
year = date_string(1:4);
month = date_string(5:6);
day = date_string(7:8);

% reformat date into string 'YYYY-MM-DD'
reformatted_date = string(year) + '-' + string(month) + '-' + string(day);

% call datetime() to create datetime variable as output to function
date = datetime(reformatted_date,'InputFormat','yyyy-MM-dd');

% find time of day data was recorded at
time_string = char(detection_file(10:end));
try
    hour = time_string(1:2);
    minutes = str2double(time_string(3:4));
    seconds = str2double(time_string(5:6));
    hour_fraction = minutes / 60 + seconds / 3600;
%     fraction = time_string(3:end);
    tod_string = [hour '.' hour_fraction];
    tod = str2double(tod_string);
catch
    error(['Found time of recording as: '  time_string]);
end

end

