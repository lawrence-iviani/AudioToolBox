function [ data ] = DUALCHANNELFFT_FFT( generalParams, params, data, inSig, outSig, fs ,playChanList, recChanList)


if isempty(params)
    warning('DUALCHANNELFFT_FFT: No parameters specified. Exiting');
   return;
end

% Following flag to true if the axes are external
externalTimeAxes=false;
if isfield(params,'axesTime')
    externalTimeAxes=true;
end

externalFreqAxes=false;
if isfield(params,'axesFreq')
    externalFreqAxes=true;
end

%disp(['DUALCHANNELFFT_FFT: externalTimeAxes is ' num2str(externalTimeAxes) ' externalFreqAxes is ' num2str(externalFreqAxes)])
%% Check if exists an external axes for time figure, otherway create  one
if ~externalTimeAxes  && (isempty(data) ||  ~isfield(data,'timeHandles')  )
    disp('DUALCHANNELFFT_FFT: time axes not present, creating fiugre' )
    data.timeHandles.timeFigure=figure; 
end

%% Check if exists an external axes for RTA figure, otherway create one
if ~externalFreqAxes  && (isempty(data) || ~isfield(data,'fftHandles')  )
     disp('DUALCHANNELFFT_FFT: RTA axes not present, creating fiugre' )
    data.fftHandles.fftFigure=figure; 
    %data.fftHandles.fftAxes = axes('parent', data.fftHandles.fftFigure, 'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'log', 'yscale', 'linear', 'xlim', [10 fs/2], 'ylim', [-60, 60]);
end


%% Setting the axes, and its parameters
if (isempty(data)) || ~isfield(data,'timeHandles')  || ~isfield(data.timeHandles,'timeAxes') 
    if externalTimeAxes
        data.timeHandles.timeAxes = params.axesTime;
    else
        data.timeHandles.timeAxes = axes('parent', data.timeHandles.timeFigure);
    end
    %set(data.timeHandles.timeAxes, 'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'linear', 'yscale', 'linear', 'xlim', [0 (generalParams.winLen*generalParams.nWin-1)/fs], 'ylim', [-1, 1]);      


end

if (isempty(data)) || ~isfield(data,'fftHandles')  || ~isfield(data.fftHandles,'fftAxes') 
    if externalFreqAxes
        data.fftHandles.fftAxes = params.axesFreq;
    else
        data.fftHandles.fftAxes = axes('parent', data.fftHandles.fftFigure);
    end
    %set(data.fftHandles.fftAxes, 'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'log', 'yscale', 'linear', 'xlim', [10 fs/2], 'ylim', [-60, 60]);
end

%if params.averageAcquisition
if length(size(inSig)) ~= 2
   warning('DUALCHANNELFFT_testDisplay: signal dimension should be 2. Exiting');
   return;
end







%% calc & render
if isfield(data.fftHandles,'fftAxes') && isfield(data.timeHandles,'timeAxes')     
    for i=1:length(recChanList)        
        if generalParams.averageAcquisition            
            %Mehtod 2
            %disp(['DUALCHANNELFFT_FFT:  signalLength=' num2str(length(inSig(:,i))) ' winLen=' num2str(generalParams.winLen) ' percentOverlap=' num2str(params.percentOverlap) ])
            sig=UTIL_divideAndWindowSignal(inSig(:,i),generalParams.winLen,params.percentOverlap,params.win,false);
            recFFT = fft(sig',2*params.NFFT)';
            nAverage=size(recFFT,1);
            recFFT=sum(recFFT,1);
            SIG=recFFT./nAverage;
        else
            sig=inSig(:,i)';
            sig=(UTIL_getWindow(params.win,size(inSig,1))').*sig;
            SIG = fft(sig,2*params.NFFT);   
        end
        SIGFFT=20*log10(abs(SIG(1:params.NFFT))); 

       if (i==1) 
           freq=linspace(0,fs/2,params.NFFT);
           hold(data.fftHandles.fftAxes,'off')
           plot(data.fftHandles.fftAxes,freq,SIGFFT,UTIL_getColor(i));
           set(data.fftHandles.fftAxes,'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'log', 'yscale', 'linear', 'xlim', [params.minFrequency params.maxFrequency], 'ylim', [params.minAmplitude params.maxAmplitude]);          
           
           hold(data.timeHandles.timeAxes,'off')
           timeBase=0:(1/fs):(generalParams.winLen*generalParams.nWin-1)/fs;
           plot(data.timeHandles.timeAxes,timeBase,inSig(:,i),UTIL_getColor(i));
           set(data.timeHandles.timeAxes, 'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'linear', 'yscale', 'linear', 'xlim', [0 (generalParams.winLen*generalParams.nWin-1)/fs], 'ylim', [-1, 1]);      
       else
           hold(data.fftHandles.fftAxes,'on')
           plot(data.fftHandles.fftAxes,freq,SIGFFT,UTIL_getColor(i));
           
           hold(data.timeHandles.timeAxes,'on')
           plot(data.timeHandles.timeAxes,timeBase,inSig(:,i),UTIL_getColor(i));
       end
    end

end
drawnow;



end


