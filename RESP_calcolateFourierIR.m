function [H  f groupDelay]=RESP_calcolateFourierIR(h,fs, average, NFFT, winname, lenwin, percentOverlap)
% Calcolate the Transfomation of the Impulese Response at certain freq and
% its groupdelay, h and fs are mandatory
% Calcolate and stft and average it
% H: the transofrmed h
% f: the vector relative to the trasnfo
% groupDelay: the group delay relative to h
% h: the signal has to be transformed
% fs: sample rate
% average: which kind of average use for averaging the H stft (default is vectorial)
% NFFT: number of bins to calculate every bins (default is 4096)
% winname: the window type of any slice (default is hann)
% lenwin: the length of the win (default is calcolated with UTIL_getWinLen and is based on the length of h)
% percentOverlap: the % overlap between every windows (default is calcolated with UTIL_getOptimalPercentOverlap and is based on the window type)
%



     
if nargin < 3 || isempty(average)     
    average='vectorial';
end
if nargin < 4 || isempty(NFFT)     
    NFFT=4096;
end
if nargin < 5 || isempty(winname)     
    winname='hann';
end
if nargin < 6 || isempty(lenwin)  
    lenwin=UTIL_getWinLen(h);
    disp(['RESP_calcolateFourierIR: lenwin is null, setting lenwin=' num2str(lenwin) ])
end
if nargin < 7 || isempty(percentOverlap)
    percentOverlap=UTIL_getOptimalPercentOverlap(winname);

    disp(['RESP_calcolateFourierIR: percentOverlap is null, setting percentOverlap=' num2str(percentOverlap) ])
end
noverlap=round(lenwin*percentOverlap);
if nargout >=3 
    groupDelay=smithDly(h,NFFT,fs);
    groupDelay(1)=groupDelay(2);%To avoid some absurd value in the first position
    groupDelay=groupDelay*(1000/fs);%Recalc grp dly in msec.
end



%%Numero di salti
win=UTIL_getWindow(winname,lenwin);
hopsize=lenwin-noverlap;
nhops = 1 + floor((length(h)-lenwin)/hopsize);
nhops = max(nhops,0);%Avoid negative nhops
nlastwin=length(h)-nhops*(lenwin-noverlap);


disp(['RESP_calcolateFourierIR: going to calcolate fourier linear transfomation with fs=' num2str(fs) ...
            ' Hz nfft='  num2str(NFFT) ' ' winname ' winlength=' num2str(lenwin)  ' noverlap=' num2str(noverlap) ]);

if nlastwin > 0    
    disp(['RESP_calcolateFourierIR:  nhops=' num2str(nhops+1) ]);
    H=zeros(nhops+1,floor(NFFT/2));
else
    disp(['RESP_calcolateFourierIR:  nhops=' num2str(nhops) ]);
    H=zeros(nhops,floor(NFFT/2));
end
index_F=0;

for n=1:nhops
    if n==1
        index_I=1;
    else
        index_I=index_F-noverlap+1;
    end
    index_F=index_I+lenwin-1;
    %disp(['n=' num2str(n) ' low='  num2str(index_I) ' up=' num2str(index_F) ])
    tH=fft(win.*h(index_I:index_F),NFFT);
    H(n,:)=tH(1:floor(NFFT/2));
end
%This avoid a problemi if nhops=0,
if isempty(n)
    n=0;
end

if nlastwin > 0  
    if n==0
        index_I=1;    
    else
        index_I=index_F+1-noverlap;
    end
    index_F=length(h);
    %disp(['lastwin low='  num2str(index_I) ' up=' num2str(index_F) ])
    hh=h(index_I:index_F);
    ww=UTIL_getWindow(winname,index_F-index_I+1);
    hh=hh.*ww;
    nzeros=lenwin-length(hh);
    hh=[hh' zeros(1,nzeros)]';
    tH=fft(hh,NFFT); 
    H(n+1,:)=tH(1:floor(NFFT/2));
end

tempH=H;
if strcmp(average,'rms')
    H=UTIL_rmsSpectAvg(H);
else
    H=UTIL_vectSpectAvg(H);
end
if nargout >=2
    f=linspace(0,fs/2,length(H));
end

if nargout==0
    figure
    subplot(311)
    clims=[ min(20*log10(abs(H))) max(20*log10(abs(H)))];
    imagesc(20*log10(abs(tempH)),clims)
    tit=['linear fft' winname ', avg ' average];
    title(tit)
    subplot(312)
    %waterfall(20*log10(abs(tempH)));
    subplot(313)
    plot(unwrap(angle(H)))
end
  
