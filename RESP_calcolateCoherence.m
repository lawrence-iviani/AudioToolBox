function [Cxy f coherenceParameters]=RESP_calcolateCoherence(x,y,coherenceParameters,delayYtoX)
% This function is an interface for use mscohere inside the toolbox
% x, y the signal has to be calcolate the frequency, 
% coherenceParameters: information about how to calcolate the coherence 
% delayYtoX: the delay between X and Y, if empty is calcoltaed with UTIL_findDelay

Cxy=[];
f=[];
if length(x)~=length(y)
    warning('x and y has not the same length');
    return
end
if nargin < 3 || isempty(coherenceParameters)
    len=2^nextpow2(floor(length(x)/8));
    coherenceParameters.nfft=2^16;
    coherenceParameters.noverlap=floor(len/2);
    coherenceParameters.fs=44100;
    coherenceParameters.window=blackmanharris(len);
    coherenceParameters.smooth=3;
    warning('RESP_calcolateCoherence: coherenceParameters is null, assuming default coherence parameters may be faulty');
end

if nargin < 4 || isempty(delayYtoX)
    [dly deltai]=UTIL_findDelay(x,y,coherenceParameters.fs,'mycorr');
else
    deltai=-round(delayYtoX/(1/coherenceParameters.fs));
end


y=circshift(y,deltai);
coherenceParameters.noverlap=[];
coherenceParameters.window=[];
coherenceParameters.smooth=2;

%find the delay between the stimulus and the recorded stimulus
[Cxy f ]=mscohere(x,y,coherenceParameters.window,coherenceParameters.noverlap,coherenceParameters.nfft,coherenceParameters.fs);
Cxy=smooth(Cxy,coherenceParameters.smooth);

