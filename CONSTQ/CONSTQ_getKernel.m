function cqkernel=CONSTQ_getKernel(sr, varargin) %,bpo,fftWin, threshold , msgBox, algorithm)

%This function return a kernel for evalutate the constant Q transform%
%It's possible to use two types of implementation
%For default i use one based on the  work  of Benjamin Blankertz 
%http://wwwmath.uni-muenster.de/logik/Personen/blankertz/constQ/constQ.html

%The other is based on the code of Judy Brown 
% http://web.media.mit.edu/~brown/cqtrans.htm

% cqkernel=CONSTQ_getKernel(sr,bpo,nameFftWin, threshold , msgBox, method)
% This method return a kernel for the trasformation, the kernel is
% little different in case of Benjamin's work or Judith's work.
% sr: sample rate  (mandatory)
% Optional 
% bpo: bins per octave
% fftwin: The data window
% winmaxlen: the maximum length of spare kernel (uesed only in brown's algo)
% winlen: the length of
% threshold: is the value for making sparse matrix (optimizing space)
% msgbox: if you want a progress bar  indicate the current percent of calculation
% method: if you want use judy brown's algo use method='brown'

bpo=14;
algorithm='default';
nameFftWin='hamming';
msgBox=false;
threshold=[];
winMaxLen=BROWN_getDefaultWinSize(sr);
constWinLen=[];
isBrownAlgo=false;

for n = 1: length(varargin)
    if(strcmp(varargin{n}, 'bpo') == 1)
        bpo=varargin{n + 1};	   
        n = n + 1;
    elseif(strcmp('threshold', varargin{n}))
        threshold = varargin{n + 1};
        n = n + 1;
    elseif(strcmp('namefftwin', varargin{n}))
        nameFftWin = varargin{n + 1};
        n = n + 1;
    elseif(strcmp('algorithm', varargin{n}))
        algorithm = varargin{n + 1};
        n = n + 1; 
    elseif(strcmp('winmaxlen', varargin{n}))
        winMaxLen = varargin{n + 1};
        n = n + 1;     
    elseif(strcmp('constwinlen', varargin{n}))
        constWinLen = varargin{n + 1};
        n = n + 1;     
     elseif(strcmp('msgbox', varargin{n}))
        msgBox = varargin{n + 1};
        n = n + 1;      
    end
end

if ~isempty(algorithm) && strcmp(algorithm,'brown')
    isBrownAlgo=true;
end

if isempty(threshold)
    threshold=getThreshold(nameFftWin);
end

h=[];
if isBrownAlgo
    if isempty(constWinLen)
        nameFile=['BROWN_cqkernel_' nameFftWin '_' num2str(sr) 'sr_'  num2str(winMaxLen) 'winmaxlen_' num2str(bpo) 'bpo.mat'];
    else
        nameFile=['BROWN_cqkernel_' nameFftWin '_' num2str(sr) 'sr_'  num2str(winMaxLen) 'winmaxlen_' num2str(constWinLen) 'constwinlen_' num2str(bpo) 'bpo.mat'];
    end
else
        nameFile=['cqkernel_'       nameFftWin '_' num2str(sr) 'sr_'  num2str(threshold) 'threshold_'  num2str(bpo) 'bpo.mat'];
end    
disp(['CONSTQ_getKernel: looking for ' nameFile ' trasformation data']);
if exist(['./CONSTQ/' nameFile] ,'file')
    if msgBox
        h = waitbar(0,'loading kernel') ;
        waitbar(0.1,h) 
    else
        disp('CONSTQ_getKernel: loading kernel');
    end    
    load(['./CONSTQ/' nameFile]);
    if msgBox       
        if ~isempty(h) && ishandle(h)
            waitbar(0.9,h) 
            delete(h)
        end
    else
        disp('CONSTQ_getKernel: kernel loaded');
    end
else
    disp('CONSTQ_getKernel: unaviable kernel');
    cqkernel.fs=sr;
    cqkernel.bpo=bpo;
    cqkernel.fMin=16.352; % C0 note frequency
    cqkernel.fMax=sr/2;
    cqkernel.nameFftWin=nameFftWin;   
    
    disp(['CONSTQ_getKernel: calcolate new  kernel fs=' num2str(cqkernel.fs) ' bpo=' num2str(cqkernel.bpo) ' fmin=' num2str(cqkernel.fMin) ...
        'Hz fmax=' num2str(cqkernel.fMax) 'Hz win is ' cqkernel.nameFftWin ])
    
    if isBrownAlgo
        nfreqs=BROWN_getNumberOfBins(cqkernel.fMin,cqkernel.fMax,cqkernel.bpo);
        cqkernel.winMaxLen=winMaxLen;
        cqkernel.constWinLen=constWinLen;
        disp(['CONSTQ_getKernel: brown algo winMaxLen=' num2str(cqkernel.winMaxLen) ' constWinLen=' num2str(cqkernel.constWinLen) ])
        h = waitbar(0,'Calculating new kernel') ;
        if msgBox
            h = waitbar(0,'Calculating new kernel') ;
        else
            disp('CONSTQ_getKernel: calculating new brown kernel');
        end
  %function [kerncos, kernsin, freqs]=BROWN_genlgftkern(minfreq, freqrat,            SR,          nfreqs, windsizmax,          winnam,         constwind)
        if isempty(h) && ishandle(h)
            [kerncos, kernsin, freqs] = BROWN_genlgftkern(cqkernel.fMin, 2^(1/cqkernel.bpo), cqkernel.fs, nfreqs, cqkernel.winMaxLen, cqkernel.nameFftWin, constWinLen);
        else
            [kerncos, kernsin, freqs] = BROWN_genlgftkern(cqkernel.fMin, 2^(1/cqkernel.bpo), cqkernel.fs, nfreqs, cqkernel.winMaxLen, cqkernel.nameFftWin, constWinLen,h);
        end
        
        h = waitbar(1,'Calculating new kernel') ;
        %TODO: make sparse matrix...      
        cqkernel.algorithm='brown';
        cqkernel.kerncos=kerncos;
        cqkernel.kernsin=kernsin;
        cqkernel.f=freqs;
    else
        cqkernel.threshold=threshold;
        disp(['CONSTQ_getKernel: algo threshold=' num2str(cqkernel.threshold)  ])
        if msgBox
            h = waitbar(0,'Calculating new kernel') ;
        else
            disp('CONSTQ_getKernel: calculating new default kernel');
        end
        if isempty(h) && ishandle(h)
            [K k f]=CONSTQ_cqkern(cqkernel.fs, cqkernel.bpo, cqkernel.fMin, cqkernel.fMax,cqkernel.threshold, cqkernel.nameFftWin);
        else
            [K k f]=CONSTQ_cqkern(cqkernel.fs, cqkernel.bpo, cqkernel.fMin, cqkernel.fMax,cqkernel.threshold, cqkernel.nameFftWin,h);
        end
        cqkernel.algorithm='default';
        cqkernel.K=K;
        cqkernel.k=k;
        cqkernel.f=f;
    end 

    cqkernel.changed=false;
    disp('CONSTQ_getKernel: saving kernel');
    save(['./CONSTQ/' nameFile] , 'cqkernel');
    if  ~isempty(h) && ishandle(h)
        delete(h)
    end
    disp('CONSTQ_getKernel: kernel saved');
end

%%DEBUG!!!
% disp('size kerncos, kernsin, freqs, algo')
%         size(cqkernel.kerncos)
%         size(cqkernel.kernsin)
%         size(cqkernel.f)
% cqkernel.algorithm


function th=getThreshold(nameFftWin)
%These threshold come out via experimental way. Any suggestions are
%appreciated
%hamming th=0.0054
%rect th=0.1
%hann th=0.0054/2
%blcakman th=0.0054/8
%bartlett th=0.05
%tukey th=0.0054*16
disp('CONSTQ_getKernel.getThreshold: Selecting experimental threshold')
th=0.01;%%Boh....
if strcmp(nameFftWin,'rect') || strcmp(nameFftWin,'rectangular')
    th=0.1;
elseif strcmp(nameFftWin,'blackman')
    th=0.0054/8;
elseif strcmp(nameFftWin,'hamming')
    th=0.0054;
elseif strcmp(nameFftWin,'bartlett')
    th=0.05;
elseif strcmp(nameFftWin,'hann')
    th=0.0054/2;
elseif strcmp(nameFftWin,'tukey')
    th=0.0054*16;    
else
    warning('CONSTQ_getKernel.getThreshold: unwknown window, thresh is not optimal...')
end
