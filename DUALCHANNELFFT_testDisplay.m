function [ data ] = DUALCHANNELFFT_testDisplay( params, data, inSig, outSig, fs ,playChanList, recChanList)


if isempty(data)
    data.fftHandles.fftFigure=[];
    data.timeHandles.timeFigure=[];
end


%if params.averageAcquisition
if length(size(inSig)) ~= 2
   warning('DUALCHANNELFFT_testDisplay: signal dimension should be 2. Exiting');
   return;
end
   
    %% init fft grpahs
if isempty(data.fftHandles.fftFigure) || ~ishandle(data.fftHandles.fftFigure)
    data.fftHandles.fftFigure = figure;
    data.fftHandles.fftAxes = axes('parent', data.fftHandles.fftFigure, 'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'log', 'yscale', 'linear', 'xlim', [10 fs/2], 'ylim', [-60, 60]);
    freq=linspace(0,fs/2,params.NFFT);
    for i=1:length(recChanList)
        data.fftHandles.fftLine(i) = line('XData', freq, 'YData', ones(1, params.NFFT));
    end
end
%% Init time graphs
if isempty(data.timeHandles.timeFigure) || ~ishandle(data.timeHandles.timeFigure)    
    data.timeHandles.timeFigure = figure;
    data.timeHandles.timeAxes = axes('parent', data.timeHandles.timeFigure, 'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'linear', 'yscale', 'linear', 'xlim', [0 (params.winLen*params.nWin-1)/fs], 'ylim', [-1, 1]);
    for i=1:length(recChanList)
        data.timeHandles.timeLine(i) = line('XData', 0:(1/fs):(params.winLen*params.nWin-1)/fs,'YData', ones(1, params.winLen));
    end

end

%% calc & render
%recFFT = fft(inSig,2*params.NFFT);
if ishandle(data.fftHandles.fftFigure) && ishandle(data.timeHandles.timeFigure)
    if params.average
        for i=1:length(recChanList)
            [recFFT]=20*log10(abs(RESP_calcolateFourierIR(inSig(:,i),fs, 'rms', params.NFFT*2, params.win, params.winLen, params.nOverlap)));
            set(data.fftHandles.fftLine(i), 'YData', recFFT);        
            set(data.timeHandles.timeLine(i), 'YData', inSig(:,i));
        end
    else
        win=UTIL_getWindow(params.win,size(inSig,1));       
        for i=1:length(recChanList)
            recFFT = 20*log10(abs(fft(win.*inSig(:,i),2*params.NFFT)));
            set(data.fftHandles.fftLine(i), 'YData', recFFT(1:params.NFFT));        
            set(data.timeHandles.timeLine(i), 'YData', inSig(:,i));
        end
    end
end
drawnow;




end

