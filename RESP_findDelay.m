function [dly deltai]=RESP_findDelay(x,y,fs,method)

%Find the delay of y respect to x.
%Can use two methods, normal (based on the peak of the xcorrelation) or
%my modified method that's is based on the x corr too but use the first
%peak of the autocorr that is major o threshold

if nargin < 4
    method=[]; 
end


if strcmp(method,'autocorr')
    R_xy=xcorr(y,x);
    [maxR indexR]=max(R_xy);
    deltai=round((length(R_xy)/2-indexR))+1;
    dly=-deltai*(1/fs);
    disp( ['UTIL_findDelay: autocorr delay is ' num2str(dly) ' sec.' ])
elseif strcmp(method,'mycorr') || isempty(method)
    R_xy=xcorr(y,x);
    [maxR indexR]=max(R_xy);
    th = 0.5;
    ind=find(abs(R_xy) > th*maxR);
    R_xynew=zeros(1,length(R_xy));
    R_xynew(ind)=abs(R_xy(ind));
    [pk ind]=findpeaks((R_xynew),'npeaks',1);
    deltai=round((length(R_xynew)/2-ind))+1;
    dly=-deltai*(1/fs);
    disp( ['UTIL_findDelay: mycorr delay is ' num2str(dly) ' sec.' ])
elseif strcmp(method,'csp')
    
    %Sperimentale, basato sul paper di...
    %EFFICIENT TIME DELAY ESTIMATION BASED ON CROSS-POWER SPECTRUM PHASE M. Matassoni and P. Svaizer 
    winlen=8192;
    nfft=winlen*2;
    nwin=floor(length(x)/winlen);
    GP=zeros(nfft,1);
    for n=1:nwin
        ind_l=winlen*(n-1)+1;
        ind_u=ind_l+winlen-1;
        X=fft(x(ind_l:ind_u),nfft);
        Y=fft(y(ind_l:ind_u),nfft);
        GP=GP+(X.*conj(Y))./(abs(X).*abs(Y));
    end
    gp=ifft(GP,nfft);
    [maxR indexR]=max(gp);
    
    dly=max(gp);
    disp( ['UTIL_findDelay: cps delay is ' num2str(dly) ' sec.' ])
else
    warning(['UTIL_findDelay: method ' method ' inexistent' ]);
    dly=[];
end
    


if nargout==0
    if strcmp(method,'csp')
        figure
        plot(gp)
    else
        tt=0:(1/fs):(length(y)-1)/fs;
        t=[fliplr(tt(2:end)) tt];
        figure
        plot(t,R_xy)
    end
end