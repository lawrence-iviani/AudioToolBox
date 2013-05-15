function [ status ] = SND_recAndPlayElaboration(fs, playDev, recDev, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%If log on windows set with varargin log
log=false;
status='success';
stop = false;


%Some default params for fft
nAverage=1; %number of  average
nLenWin=4096;%duration in sample of every page
win='rect';
nFFFT=8192;





if ~playrec('isInitialised')
    status=(['SND_recAndPlay: Failed to initialise device at the selected sample rate (' fs ' Hz), try another one']);
    return
end


N_playbackChannels=length(playDev.channels);
N_recChannels=length(recDev.channels);

isFirst =  true;
loopcount=0;
while ~stop
    if(isFirst)
        %This is the first time through so reset the skipped sample count
        playrec('resetSkippedSampleCount');
        isFirst = false;
    else
        if(playrec('getSkippedSampleCount'))
            fprintf('%d samples skipped!!\n', playrec('getSkippedSampleCount'));
            %return
            %Let the code recover and then reset the count
            isFirst = true;
        end
    end
    sample_no = loopcount * nLenWin + (1:nLenWin)';
    lowSample=min(sample_no);
    upSample=max(sample_no);
    pageLength=length(sample_no);
    waveOut=zeros(lowSample:upSample,N_playbackChannels);%sOut(lowSample:upSample,:);TODO NOW PLAY SILENCE, has to be played a sound
    lastPageInserted=playrec('playrec', waveOut, playDev.channels, -1, recDev.channels);
    pageList=[pageList, lastPageInserted];
    if( length(pageList) > nAverage )
        %Extract page from list
        for n=1:length(pageList)
            pageRemoving=pageList(1);
            while(playrec('isFinished', pageRemoving) == 0)
                pause(pageDuration/10);
            end 
            lastRecording = playrec('getRec', pageRemoving);
            [recSamples recCh]=size(lastRecording);
            if(~isempty(lastRecording))           
                waveIn=waveIn+lastRecording;
                %disp(['SND_recAndPlay:   [Page ' num2str(pageRemoving) '] extract (' num2str(lindex) ':' num2str(uindex) ') ' num2str(length(lastRecording)) ' samples, total extract ' num2str(inTotalSample) ' samples']);
            end
            waveIn=waveIn./nAverage;
            %Remove finished page from list
            playrec('delPage', pageRemoving);          
        end
        pageList = pageList(end);
    end
    
end
end

