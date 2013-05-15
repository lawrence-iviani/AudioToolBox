function [ params ] = DUALCHANNELFFT_analyzerDefaultParams( genType,fs )

params=[];
if nargin~=2 ||  isempty(genType)
    warning('DUALCHANNELFFT_analyzerDefaultParams: empty analayzer type')
    return
end

if isempty(fs)
    warning('DUALCHANNELFFT_analyzerDefaultParams: setting fs @ 44100');
    fs=44100;
end



%These are mandatory params for every analyzer
%params.axesFreq=[];
%params.axesTime=[];
params.function=['DUALCHANNELFFT_' genType];


if strcmp(genType,'RTA')
    params.win='hann';
    params.NFFT=4096;  
    params.percentOverlap=UTIL_getOptimalPercentOverlap(params.win);%percent overlap
    params.fmin=20;
    params.fmax=20000;
    params.bandsPerOctave=3;
    params.fs=fs;

    params.freq=NTH_freq_band(params.bandsPerOctave, params.fmin, 0.88*params.fmax , 0);%Perch� 0.88????
    for n=1:length(params.freq)
        [b a]=NTH_octdsgn(params.fs,params.freq(n));
        %disp(['DUALCHANNELFFT_analyzerDefaultParams: designing filter (' num2str(n) ') ' num2str(data.freq(n)) ' Hz'])
        params.filter(:,n)=freqz(b,a,params.NFFT*2,params.fs);
    end
end

if strcmp(genType,'FFT')
    params.win='tukey';
    params.NFFT=4096;  
    params.percentOverlap=UTIL_getOptimalPercentOverlap(params.win);%percent overlap
    params.fmin=16;
    params.fmax=fs/2;
    params.fs=fs;
end

if isempty(params)
    warning('DUALCHANNELFFT_analyzerDefaultParams: no analyzer selected')
end

