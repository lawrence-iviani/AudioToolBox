function cq=CONSTQ_fft(x,   cqkernel, lenwin, noverlap )    % x must be a row vector
% This function calcolate the stft with constant Q division using the implementation 
% found in the paper of [Benjamin Blankertz]  The Constant Q Transform 
% The first two value x and cq kernel are mandatory
% x: the signal to be transformed
% cqkernel: the kernl of transformation, has to be calulated separatly
% lenwin: the fragmentation length of every slice of the stft. 
% noverlap: the overlap for any slice in the stft



if nargin < 3 || isempty(lenwin) || lenwin==0
    lenwin=UTIL_getWinLen(signal);
    disp(['CONSTQ_fft: lenwin is null, set to ' num2str(lenwin)]);
end
if nargin < 4 || isempty(noverlap)
    noverlap=floor(UTIL_getOptimalPercentOverlap(cqkernel.nameFftWin)*length(win));
    disp(['CONSTQ_fft: noverlap is null, set to ' num2str(noverlap)]);
end

disp(['CONSTQ_fft: lenwin= ' num2str(lenwin) ' noverlap=' num2str(noverlap) ])
%%Numero di salti
NFFT=size(cqkernel.K,1);
NBIN=size(cqkernel.K,2);
%%Numero di salti
hopsize=lenwin-noverlap;
nhops = 1 + floor((length(x)-lenwin)/hopsize);
nhops = max(nhops,0);%Avoid negative nhops
nlastwin=length(x)-nhops*(lenwin-noverlap);

if nlastwin > 0    
    cq=zeros(nhops+1,NBIN);
else
    cq=zeros(nhops,NBIN);
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
    cq(n,:)=fft(x(index_I:index_F),NFFT) * cqkernel.K; 
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
    index_F=length(x);
    xx=x(index_I:index_F);    
    ww=UTIL_getWindow(cqkernel.nameFftWin,index_F-index_I+1)';
    xx=xx.*ww;
    nzeros=lenwin-length(xx);
    xx=[xx zeros(1,nzeros)];
    cq(n+1,:)=fft(xx,NFFT) * cqkernel.K; 
end

                             