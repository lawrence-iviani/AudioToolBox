function [s t] = UTIL_generatePinkFilteredNoise(f1,f2,Fs,duration,fadeIn,fadeOut,preSilence,postSilence)

%Genera un rumore rosa filtrato con un filtro peq tra f1 e f2, f1 e f2 sono
%nulli genera il segnale a banda larga

T=duration;
N_sample=T*Fs;
Ts=1/Fs;
N_sampleFadeIn=floor(fadeIn/Ts);
N_sampleFadeOut=floor(fadeOut/Ts);
N_preSilence=floor(preSilence/Ts);
N_postSilence=floor(postSilence/Ts);
preSilenceSig=zeros(N_preSilence,1);
postSilenceSig=zeros(N_postSilence,1);

t=0:Ts:(N_sample-1)*Ts;

noise=UTIL_spatialPattern( [length(t) 1],-1)';
%Apply fadeIn
N=1/(N_sampleFadeIn-1);
envFadeIn=N*(1:N_sampleFadeIn)-N;
noise(1:N_sampleFadeIn)=noise(1:N_sampleFadeIn).*envFadeIn;

%Apply fadeOut
N=1/(N_sampleFadeOut-1);
envFadeOut=rot90(N*(1:N_sampleFadeOut)-N,2);
L=length(noise);
noise(L-N_sampleFadeOut+1:L)=noise(L-N_sampleFadeOut+1:L).*envFadeOut;

%InsertPresilence and post silence
s=[preSilenceSig' noise postSilenceSig'];

%Recalculate t
N_sample=length(s');
t=0:Ts:(N_sample-1)*Ts;
if not(isempty(f1) && isempty(f2))
    [b a]=butter(4,[2*f1/Fs 2*f2/Fs]);
    s=filter(b,a,noise);  
end
rescale=1/max(s);
s=s.*rescale;