function [signal nameSignal]=TESTSCRIPT_generateSignal(fs, len)


t=0:(1/fs):((len-1)/fs);
signal=zeros(2,len);

%genera sinusoide centrata in ogni ottava
indexsignal=1;
f1=30;
for n=1:10
   signal(indexsignal,:)=signal(indexsignal,:)+0.1*sin(2*pi*f1*t);
   f1=f1*2;
end

%generate pink noise
indexsignal=indexsignal+1;
signal(indexsignal,:)=UTIL_spatialPattern([len,1],-1);