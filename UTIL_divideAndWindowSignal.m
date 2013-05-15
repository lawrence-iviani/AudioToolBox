function out=UTIL_divideAndWindowSignal(signal,winLen,percentOverlap,winName,averageFlag)
%Divide the signal in windows of length winLen, with a percentOverlap between the
%window.
%Window parameter are name and length
%
%Return N slice of the signal or a media between slce if averageFlag is
%true

if nargin < 5 || isempty(averageFlag)
    averageFlag=true;
end
if nargin < 4 || isempty(winName)
    winName='hann';
end
if nargin < 2 || isempty(winLen)
    winLen=floor(length(signal)/8);
end
if nargin < 3 || isempty(percentOverlap)
   percentOverlap=floor(winLen*UTIL_getOptimalPercentOverlap(winName));
end

%transform percent 
if percentOverlap >= 1 
    if percentOverlap < 100
        percentOverlap=percentOverlap/100;
    else
        error(['UTIL_divideAndWindowSignal:  WRONG OVERLAP!!! ' num2str(percentOverlap) '%']);
    end
end
%Numero di salti
win=UTIL_getWindow(winName,winLen);
nOverlap=floor(winLen*percentOverlap);
hopsize=winLen-nOverlap;
nhops = 1 + floor((length(signal)-winLen)/hopsize);
nhops = max(nhops,0);%Avoid negative nhops
nlastwin=length(signal)-nhops*(winLen-nOverlap);

%disp(['UTIL_divideAndWindowSignal:  percentOverlap=' num2str(percentOverlap) ' winLen=' num2str(winLen) ' winName=' winName ' averageFlag=' num2str(averageFlag) ]);
%disp(['UTIL_divideAndWindowSignal:  nOverlap=' num2str(nOverlap) ' hopsize=' num2str(hopsize) ' nhops=' num2str(nhops) ' nlastwin=' num2str(nlastwin) ]);

if nlastwin > 0   && nlastwin <= winLen
    %disp(['UTIL_divideAndWindowSignal:  nlastwin=0 nhops=' num2str(nhops) ' plus lastwin (len=' num2str(nlastwin) ')']);
    out=zeros(nhops+1, winLen);
elseif nlastwin == 0
    %disp(['UTIL_divideAndWindowSignal:  nhops=' num2str(nhops) ]);
    out=zeros(nhops,winLen);
else
    error(['UTIL_divideAndWindowSignal: WRONG   >=0  NLASTWIN  <= ' num2str(winLen) ' !! nlastwin=' num2str(nlastwin)  ' nhops=' num2str(nhops) ]);
end

index_F=0;

for n=1:nhops
    if n==1
        index_I=1;
    else
        index_I=index_F-nOverlap+1;
    end
    index_F=index_I+winLen-1;
    %disp(['n=' num2str(n) ' low='  num2str(index_I) ' up=' num2str(index_F) ])
    out(n,:)=win.*signal(index_I:index_F);
end
%This avoid a problemi if nhops=0,
if isempty(n)
    n=0;
end

if nlastwin > 0  
    if n==0
        index_I=1;    
    else
        index_I=index_F+1-nOverlap;
    end
    index_F=length(signal);
    %disp(['lastwin low='  num2str(index_I) ' up=' num2str(index_F) ])
    ss=signal(index_I:index_F);
    ww=UTIL_getWindow(winName,index_F-index_I+1);
    ss=ss.*ww;
    nzeros=winLen-length(ss);
    out(n+1,:)=[ss' zeros(1,nzeros)]';
    nhops=nhops+1;
end


if averageFlag
     sout=zeros(1,winLen);
     for n=1:nhops
          sout=sout+out(n,:);
     end
     out=sout./nhops;
end