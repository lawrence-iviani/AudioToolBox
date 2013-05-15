function [Hcq f groupDelay]=RESP_calcolateFourierIR_CONSTQ(h , cqkernel,average, winlen , perecentnoverlap)
% A bridge function to caclulate the Const Q Transform, 
% h and cqkernel are mandatory
% % average: which kind of average use for averaging the H stft (default is vectorial) 
% the window length of any slice, the win
% percentnoverlap is a percentil 0<= perecentnoverlap <= 1


Hcq=[];
f=[];
groupDelay=[];

if  nargin < 4 || isempty(average)
    average='vectorial';
    disp(['RESP_calcolateFourierIR_CONSTQ: average is null, set to ' average]);
end

if strcmp(cqkernel.algorithm,'default')
    Hcq=CONSTQ_cqTrasfo(h,cqkernel,'average',average,'perecentnoverlap',perecentnoverlap,'winlen',winlen);
elseif strcmp(cqkernel.algorithm,'brown')
    if nargin == 5 && ~isempty(perecentnoverlap)
        Hcq=CONSTQ_cqTrasfo(h,cqkernel,'average',average,'perecentnoverlap',perecentnoverlap);
    else
        Hcq=CONSTQ_cqTrasfo(h,cqkernel,'average',average);
    end

else
    warning(['Unrecognized algo ' cqkernel.algorithm ', exit null']);
    return;
end

f=cqkernel.f;
groupDelay=smithDly(h, f ,cqkernel.fs);
groupDelay(1)=groupDelay(2);
groupDelay=groupDelay*(1000/cqkernel.fs);%Recalc grp dly in msec.
