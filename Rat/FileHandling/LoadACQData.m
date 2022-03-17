function data = LoadACQData(acq_file)

fid = fopen(acq_file);

if fid > -1
    file = acqreader07092013(acq_file);
    data = acqdatareader(file, 0, 24*3600);
else
    error(['Error loading file: ' acq_file])
end