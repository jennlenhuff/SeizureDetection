function seizures = ReadSeizures(file)
fid = fopen(file);

if fid > -1
    seizures = readcell(file);
    fclose(fid);
else
    warning(['Unable to read file: ' file '\n Skipping file.'])
    seizures = [];
end