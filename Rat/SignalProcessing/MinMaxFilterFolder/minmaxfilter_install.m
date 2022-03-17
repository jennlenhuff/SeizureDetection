function minmaxfilter_install
% function minmaxfilter_install
% Installation by building the C-mex files for minmax filter package
%
% Author Bruno Luong <brunoluong@yahoo.com>
% Last update: 20-Sep-2009

here = fileparts(mfilename('fullpath'));
oldpath = cd(here);

arch=computer('arch');
mexopts = {'-O' '-v' ['-' arch]};
if ~verLessThan('MATLAB','9.4')
    R2018a_mexopts = {'-R2018a'};
else
    R2018a_mexopts = {};    
    % 64-bit platform
    if ~isempty(strfind(computer(),'64'))
        mexopts(end+1) = {'-largeArrayDims'};
    end
end

% invoke MEX compilation tool
mex(mexopts{:},'lemire_nd_minengine.c');
mex(mexopts{:},'lemire_nd_maxengine.c');

% Those mex files are no longer used, we keep for compatibility
mex(mexopts{:},R2018a_mexopts{:},'lemire_nd_engine.c');
mex(mexopts{:},R2018a_mexopts{:},'lemire_engine.c');

cd(oldpath);
