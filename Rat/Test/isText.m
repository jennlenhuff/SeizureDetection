function output = isText(myVar)
% isText is a function that checks if a given input is of type string or
% character or cell array of srtings\chars. Return type is bool

    output = isstring(myVar)||ischar(myVar)||iscellstr(myVar);
end