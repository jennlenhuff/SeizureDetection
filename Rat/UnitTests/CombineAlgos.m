function CombinedResults = CombineAlgos(AlgorithmResults, Parameters, info)
% CombineAlgos takes 3 structures as input and returns a structure with
% combined detection results
% AlgorithmResults: structure with normalized outputs from each 4 algos
% Parameters: parameter set for the combined algorithm formula
% info: structure containing file data for .acq

Normalized = AlgorithmResults.Normalized;

% Fetch parameters

% weights
ACw = Parameters.ACw;
FFTw = Parameters.FFTw;
LLw = Parameters.LLw;
SSw = Parameters.SSw;

% exponential scalars
ACe = Parameters.ACe;
FFTe = Parameters.FFTe;
LLe = Parameters.LLe;
SSe = Parameters.SSe;

% combined results
COMB = (ACw.*(Normalized.AC.^ACe) + FFTw.*(Normalized.FFT.^FFTe) + LLw.*(Normalized.LL.^LLe) + SSw.*(Normalized.SS.^SSe))...
                            / (ACw + FFTw + LLw + SSw);

% pass combined results into final module to return our 2-column
% output (channel#, seizure time(s))
cutoff = inf;
[combDETECTIONS, ~, combszseconds] = SzDetectAlt2(COMB,info,Parameters.Threshold,cutoff);

% store all important outputs into structure/function return variable
CombinedResults.Detections = combDETECTIONS;
CombinedResults.DetTimes = combszseconds;
CombinedResults.COMB = COMB;

end


