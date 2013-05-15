function [S cqtrans cqkernel]=CONSTQ_cqTrasfo(signal,cqkernel,varargin)
% This the main function for calulating a const q transformation.
% if cqkernel is empty try to recalcolate a new kernel (don't use this method is too generic, use CONSTQ_getKernel instead)
% signal: the signal need to be transofrmed
% cqkernel: a data strucure containing the kernel and the options used for calcolating
% S: the transfomed signal
% cqtrans: a stft constq of the signal 
% if aren't specified exit arguments plot a waterfall of the transofrmation
% Other options (not mandatory) are:
% fs: the sample rate of the trasformation (default=44100)
% bpo: the bins per octave of the trasformation (default=12)
% fmin: the minimun frequency for calcolate the transfo (default=16.352)
% fmax: the maximum frequency for calcolate the transfo (default=20000)

if nargin < 2
    error('CONSTQ_cqTrasfo: need a signal and a kernel for executing transformation');
end

if isempty(cqkernel)
    warning('CONSTQ_cqTrasfo: called without a kernel, use a default one but results may be incorrect');
    cqkernel.fs=44100;
    cqkernel.bpo=16;
    cqkernel.fMin=16.352; % C0 note frequency
    cqkernel.fMax=cqkernel.fs/2;   
    cqkernel.threshold=[]; %Use default value
    cqkernel.nameFftWin='hamming';
    cqkernel.winMaxLen=BROWN_getDefaultWinSize(cqkernel.fs); 
    cqkernel.algorithm='default';
    cqkernel.changed=true;% A bool saying if the options  of the trasnfomation kernel are changed and need to recalcolate the kernel    
end

%Calcolate the average for spectrogram
average='vectorial';
npercentOverlap=[];
winLen=[];

for n = 1: length(varargin)
        if(strcmp('winlen', varargin{n}))
			winLen = varargin{n + 1};
			n = n + 1; 
        elseif (strcmp('perecentnoverlap', varargin{n}))
            npercentOverlap=varargin{n + 1};
            n = n + 1;
        elseif (strcmp('average', varargin{n}))
            average=varargin{n + 1};
            n = n + 1;
        end
end


if isempty(winLen)    
    if strcmp('brown',cqkernel.algorithm)
        if isempty(cqkernel.constWinLen)
            if isempty(cqkernel.winMaxLen)
                winLen=BROWN_getDefaultWinSize(cqkernel.fs); 
            else
                winLen=cqkernel.winMaxLen;
            end
        else
            winLen=cqkernel.constWinLen;
        end
    else
        if isempty(winlen)
            winLen=UTIL_getWinLen(signal);
        end
    end
    disp(['CONSTQ_cqTrasfo: winlen set to ' num2str(winLen) ' samples']);
end

if isempty(npercentOverlap)
    npercentOverlap=UTIL_getOptimalPercentOverlap(cqkernel.nameFftWin);
end
nOverlap=round(npercentOverlap*winLen);

if cqkernel.changed
    disp(['CONSTQ_cqTrasfo: going to calcolate (' algorithm ') kernel with fs=' num2str(cqkernel.fs) ' Hz bins_per_octave='  num2str(cqkernel.bpo) ' ' cqkernel.nameFftWin ...
            ' window thresold=' num2str(cqkernel.threshold) ' fmin=' num2str(cqkernel.fMin) 'Hz  fmax=' num2str(cqkernel.fMax) 'Hz ']);
    if strcmp('brown',cqkernel.algorithm)
        nfreqs=BROWN_getNumberOfBins(cqkernel.fMin,cqkernel.fMax, cqkernel.bpo);
                                   %BROWN_genlgftkern(minfreq,      freqrat,             SR,          nfreqs, windsizmax,         winnam,          constwind)
        [kerncos, kernsin, freqs] = BROWN_genlgftkern(cqkernel.fMin, 2^(1/cqkernel.bpo), cqkernel.fs, nfreqs, cqkernel.winMaxLen, cqkernel.nameFftWin, []);
        h = waitbar(1,'Calculating new kernel') ;
        cqkernel.algorithm='brown';
        cqkernel.kerncos=kerncos;
        cqkernel.kernsin=kernsin;
        cqkernel.f=freqs;
    else
        cqkernel.algorithm='default';
        [K k f]=CONSTQ_cqkern(cqkernel.fs, cqkernel.bpo, cqkernel.fMin, cqkernel.fMax,cqkernel.threshold, cqkernel.nameFftWin, true);
        cqkernel.K=K;
        cqkernel.k=k;
        cqkernel.f=f;
    end
    cqkernel.changed=false;
end
disp(['CONSTQ_cqTrasfo: going to calcolate (' cqkernel.algorithm ') fourier constant Q transfomation with fs=' num2str(cqkernel.fs) ...
      ' Hz bins_per_octave='  num2str(cqkernel.bpo) ' %noverlap=' num2str(npercentOverlap*100) ' (noverlap=' num2str(nOverlap)  ') win is ' cqkernel.nameFftWin ... 
      ' fmin=' num2str(cqkernel.fMin) ...
      ' Hz  fmax=' num2str(cqkernel.fMax) 'Hz ']);
   
        
if strcmp('brown',cqkernel.algorithm)
    nfreqs=BROWN_getNumberOfBins(cqkernel.fMin,cqkernel.fMax,cqkernel.bpo);
    warning('TODO: CONSTQ_cqTrasfo: verficare flag ccx  ');
    disp(['CONSTQ_cqTrasfo: brown algo params. constwinlen=' num2str(cqkernel.constWinLen) '  winmaxlen=' num2str(cqkernel.winMaxLen)])
    [cqtrans, time]  = BROWN_logft(signal, nOverlap, cqkernel.kerncos,  cqkernel.kernsin, cqkernel.winMaxLen, nfreqs, cqkernel.fs, 1);  
elseif strcmp('default',cqkernel.algorithm)
    disp(['CONSTQ_cqTrasfo: default algo  params.  threshold=' num2str(cqkernel.threshold) ' winlen='   num2str(winLen)])
    cqtrans=CONSTQ_fft(signal',cqkernel , winLen,  nOverlap ); 
else 
    warning(['CONSTQ_cqTrasfo: unkwnown algorithm ' cqkernel.algorithm ', using default']);
    disp(['CONSTQ_cqTrasfo: default algo  params.  threshold=' num2str(cqkernel.threshold) ' winlen='   num2str(winLen)])
    cqtrans=CONSTQ_fft(signal',cqkernel , winLen,  nOverlap ); 
end
%disp(['CONSTQ_cqTrasfo: nslice=' num2str(size(cqtrans,1)) ' nbins=' num2str(size(cqtrans,2)) ]);

if strcmp(average,'rms')
    S=UTIL_rmsSpectAvg(cqtrans);
else
    S=UTIL_vectSpectAvg(cqtrans);
end


if nargout==0
    figure
    clims=[ min(20*log10(abs(S))) max(20*log10(abs(S)))];
    subplot(311)
    imagesc(20*log10(abs(cqtrans)),clims)
    tit=[cqkernel.algorithm ' fft, avg ' average];
    title(tit)
    subplot(312)
    %waterfall(20*log10(abs(cqtrans)));
    subplot(313)
    plot(unwrap(angle(S)))
end




