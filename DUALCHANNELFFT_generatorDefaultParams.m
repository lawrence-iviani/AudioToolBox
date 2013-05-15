function [ params ] = DUALCHANNELFFT_generatorDefaultParams( genType )


params=[];
if nargin~=1 ||  isempty(genType)
    warning('DUALCHANNELFFT_generatorDefaultParams: empty generator type')
    return
end

% Pink noise generator
if strcmp(genType,'Pink noise')
    params.signalType='Pink noise';
    params.gain=0; 
end

% Tone generator
if strcmp(genType,'Tone')
    params.signalType='Tone';
    params.gain=0; 
    params.f1=1000;
end

% Dual Tone generator
if strcmp(genType,'Dual Tone')
    params.signalType='Dual Tone';
    params.gain1=-6; 
    params.gain2=-6; 
    params.gain=0; 
    params.f1=1000;
    params.f2=1500;
end

% Silence
if strcmp(genType,'Silence');
    params.signalType='Silence';
end

if isempty(params)
    warning('DUALCHANNELFFT_generatorDefaultParams: no generator selected')
end

