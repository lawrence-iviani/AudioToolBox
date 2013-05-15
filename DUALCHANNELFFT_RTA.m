function [ data ] = DUALCHANNELFFT_RTA(generalParams, params, data, inSig, outSig, fs ,playChanList, recChanList)


if isempty(params)
    warning('DUALCHANNELFFT_RTA: No parameters specified. Exiting');
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

%disp(['DUALCHANNELFFT_RTA: externalTimeAxes is ' num2str(externalTimeAxes) ' externalFreqAxes is ' num2str(externalFreqAxes)])
%% Check if exists an external axes for time figure, otherway create  one
if ~externalTimeAxes  && (isempty(data) ||  ~isfield(data,'timeHandles')  )
    disp('DUALCHANNELFFT_RTA: time axes not present, creating fiugre' )
    data.timeHandles.timeFigure=figure; 
end

%% Check if exists an external axes for RTA figure, otherway create one
if ~externalFreqAxes  && (isempty(data) || ~isfield(data,'rtaHandles')  )
     disp('DUALCHANNELFFT_RTA: RTA axes not present, creating fiugre' )
    data.rtaHandles.rtaFigure=figure; 
    %data.rtaHandles.fftAxes = axes('parent', data.rtaHandles.fftFigure, 'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'log', 'yscale', 'linear', 'xlim', [10 fs/2], 'ylim', [-60, 60]);
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

if (isempty(data)) || ~isfield(data,'rtaHandles')  || ~isfield(data.rtaHandles,'rtaAxes') 
    if externalFreqAxes
        data.rtaHandles.rtaAxes = params.axesFreq;
    else
        data.rtaHandles.rtaAxes = axes('parent', data.rtaHandles.rtaFigure);
    end
    %set(data.rtaHandles.rtaAxes , 'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'log', 'yscale', 'linear', 'xlim', [10 fs/2], 'ylim', [-60, 60]);
end

%if params.averageAcquisition
if length(size(inSig)) ~= 2
   warning('DUALCHANNELFFT_testDisplay: signal dimension should be 2. Exiting');
   return;
end







%% calc & render
%recFFT = fft(inSig,2*params.NFFT);
RTA=zeros(size(params.filter,2),length(recChanList) );
if isfield(data.rtaHandles,'rtaAxes') && isfield(data.timeHandles,'timeAxes')     
    for i=1:length(recChanList)        
        if generalParams.averageAcquisition
%             sig=UTIL_divideAndWindowSignal(inSig(:,i),generalParams.winLen,params.nOverlap,params.win,true);
%             SIG = fft(sig,2*params.NFFT);   
            %size(sig)
            
            %Mehtod 2
            sig=UTIL_divideAndWindowSignal(inSig(:,i),generalParams.winLen,params.percentOverlap,params.win,false);
            recFFT = fft(sig',2*params.NFFT)';
            nAverage=size(recFFT,1);
            recFFT=sum(recFFT,1);
            SIG=recFFT./nAverage;
        else
            %sig=UTIL_divideAndWindowSignal(inSig(:,i),generalParams.winLen,params.nOverlap,params.win,false);
            sig=inSig(:,i)';
            sig=(UTIL_getWindow(params.win,size(inSig,1))').*sig;
            SIG = fft(sig,2*params.NFFT);   
        end
         

        for n=1:size(params.filter,2)
            SS=SIG.*(params.filter(:,n)');
            totalEnergy = sum(SS.*conj(SS))/length(SS);
            meanEnergy = totalEnergy/((1/fs)*length(sig(:,i)));
            RTA(n,i)= 10*log10(meanEnergy);
        end
       %set(data.fftHandles.fftLine(i), 'YData', RTA(:,i));  
       if (i==1) 
           hold(data.rtaHandles.rtaAxes,'off')
           disp(['DUALCHANNELFFT_RTA: length freq ' num2str(length(params.freq)) ' length data ' num2str(length( RTA(:,i)))])
           stem(data.rtaHandles.rtaAxes, params.freq, RTA(:,i),'BaseValue', params.minAmplitude,'Color',UTIL_getColor(i),'LineWidth' , 9, 'Marker', 'none');      
           set(data.rtaHandles.rtaAxes,'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'log', 'yscale', 'linear', 'xlim', [params.minFrequency params.maxFrequency], 'ylim', [params.minAmplitude params.maxAmplitude]);
           
           hold(data.timeHandles.timeAxes,'off')
           timeBase=0:(1/fs):(generalParams.winLen*generalParams.nWin-1)/fs;
           plot(data.timeHandles.timeAxes,timeBase,inSig(:,i),UTIL_getColor(i));
           set(data.timeHandles.timeAxes, 'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'linear', 'yscale', 'linear', 'xlim', [0 (generalParams.winLen*generalParams.nWin-1)/fs], 'ylim', [-1, 1]);      
       else
           hold(data.rtaHandles.rtaAxes,'on')
           stem(data.rtaHandles.rtaAxes, params.freq, RTA(:,i),'BaseValue', params.minAmplitude,'Color',UTIL_getColor(i),'LineWidth' , 9, 'Marker', 'none');
            
           hold(data.timeHandles.timeAxes,'on')
           plot(data.timeHandles.timeAxes,timeBase,inSig(:,i),UTIL_getColor(i));
       end
    end

end
drawnow;



end


