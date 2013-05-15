function [sIn sOut hText status]=SND_recAndPlay(varargin)
% signal: the stimulus that has to be played
% fs: sample rate
% playDev:
% recDev:
% hText: the object handle where write status e append a progress bar
%%This function play and record simultaneously 
% revOverTime: contiunue record of the stimulation for the indicated time (default=0)


status='success';
hText.textHandle=[];
progBar=[];
gui=false;
skipped=false;
canceled=false;
if nargin==4
    signal=varargin{1};
    fs=varargin{2};
    playDev=varargin{3};
    recDev=varargin{4};
elseif nargin==5
    hText=varargin{1};
    signal=varargin{2};
    fs=varargin{3};
    playDev=varargin{4};
    recDev=varargin{5};
    progBar= waitbar(0,'Starting measure','CreateCancelBtn','setappdata(gcbf, ''run'', false)');
    set(progBar,'WindowStyle','modal');
    setappdata(progBar,'run', true);
    gui=true;
else
    status=(['SND_recAndPlay: wrong number of input parameter.']);
    if gui 
        delete (progBar)
    end
    return
end

%generate the out signal 
N_sig=length(signal);

N_playbackChannels=length(playDev.channels);
N_recChannels=length(recDev.channels);

%Generating output signal
sOut=zeros(N_sig,N_playbackChannels);
for n=1:N_playbackChannels
    sOut(:,n)=signal;
end

%Init recorded signal
sIn=zeros(N_sig,N_recChannels);


if ~playrec('isInitialised')
    status=(['SND_recAndPlay: Failed to initialise device at the selected sample rate (' fs ' Hz), try another one']);
    if gui 
        delete (progBar)
    end
    return
end

%General Prameters
isFirst =  true;
pageDuration=0.5;
signalDuration=length(sIn)/fs;
pageTotalNumber=ceil(signalDuration/pageDuration);
pageList=[];
maxBufferedPages=5;
outTotalSample=0;
inTotalSample=0;

[recSamples recCh]=size(sIn);
[playSamples playCh]=size(sOut);

str1=['SND_recAndPlay: going to playback ' num2str(playSamples) ' samples on ' num2str(playCh) ' channels, and recording ' num2str(recSamples)  ' samples on ' num2str(recCh) ' channels'];
str2=['SND_recAndPlay: signal time length is ' num2str(signalDuration) ' sec. Playing ' num2str(pageTotalNumber) ' pages each of ' num2str(pageDuration) ' sec.'];

if gui
    hText=GUI_writeToGui(hText,str1);
    hText=GUI_writeToGui(hText,str2);
else
   disp(str1);
   disp(str2);
end

totalLoopCount=pageTotalNumber-1;
for loopcount=0:(pageTotalNumber-1)
    if gui
        canceled=~getappdata(progBar,'run');
        if canceled
            break;
        end
    end
        
    %Generate the next page of samples to output.  This is occuring
    %whilst the previous pages are still being output.
    tic;
    sample_no = loopcount * fs*pageDuration + (1:fs*pageDuration)';
    lowSample=min(sample_no);
    upSample=max(sample_no);
    pageLength=length(sample_no);

    if loopcount==pageTotalNumber-1 
        upSample=length(sIn);
    end   
    waveOut=sOut(lowSample:upSample,:);
    %Add the new page number to the end of the list
    %disp('SND_recAndPlay: calling playrec - playrec')
    lastPageInserted=playrec('playrec', waveOut, playDev.channels, -1, recDev.channels);
    outTotalSample=outTotalSample+pageLength;

    pageList=[pageList, lastPageInserted];
    disp(['SND_recAndPlay:   [Page ' num2str(lastPageInserted) '] Playing from sample ' num2str(lowSample) ' to  sample '  num2str(upSample)  ...
            ' total samples writed ' num2str(outTotalSample)]);%, min(sample_no), max(sample_no));
   
    %If this is the first time through then reset the skipped
    %sample count
    if isFirst
        isFirst = false;
        %disp('SND_recAndPlay: resetting sample count, first passage')
        playrec('resetSkippedSampleCount');
    else
         if(playrec('getSkippedSampleCount'))
%             skipped=true;
             str=['SND_recAndPlay:'  num2str(playrec('getSkippedSampleCount')) ' samples skipped!!!!!!!'];
             disp(str);
             if gui
                 hText=GUI_writeToGui(hText,str);
             else
                 disp(str);
             end
%             %Let the code recover and then reset the count
%             disp('SND_recAndPlay: calling playrec - resetSkippedSampleCount')
              playrec('resetSkippedSampleCount');
%             disp('SND_recAndPlay: playrec - calling reset')
%             playrec('reset');
%             break;
         end
    end
        
        
    if( length(pageList) > maxBufferedPages )
        %Extract page from list
        pageRemoving=pageList(1);
        %disp('SND_recAndPlay: playrec - calling isFinished');
        while(playrec('isFinished', pageRemoving) == 0)
            pause(pageDuration/10);
        end 
        %disp('SND_recAndPlay: playrec - calling getRec');
        lastRecording = playrec('getRec', pageRemoving);
        [recSamples recCh]=size(lastRecording);
        if(~isempty(lastRecording))
            lindex=inTotalSample+1;
            uindex=inTotalSample+recSamples;
            sIn(lindex:uindex,:) = lastRecording;
            inTotalSample=inTotalSample+length(lastRecording);
            disp(['SND_recAndPlay:   [Page ' num2str(pageRemoving) '] extract (' num2str(lindex) ':' num2str(uindex) ') ' num2str(length(lastRecording)) ' samples, total extract ' num2str(inTotalSample) ' samples']);
        end
        %Remove finished page from list
        %disp('SND_recAndPlay: playrec - calling delPage');
        playrec('delPage', pageRemoving);          
        pageList = pageList(2:end);
    end

    elapsedTime=toc;
    remainingTime=pageDuration-elapsedTime;
    if remainingTime > 0
        %disp(['SND_recAndPlay:   [Page ' num2str(lastPageInserted) '] End cicle, execution time ' num2str(elapsedTime) ' sec. remainigtime ' num2str(remainingTime) ' sec.']);
        pause(0.5*remainingTime);
    else
        str=(['SND_recAndPlay: [Page ' num2str(lastPageInserted) '] End cicle, execution time ' num2str(elapsedTime) ' OVERRUN of ' num2str(abs(remainingTime))  ' sec. !!!!!' ]);
        %disp(str);
        if gui 
            hText=GUI_writeToGui(hText,str);
        else
            disp(str);
        end
    end
    if gui 
        waitbar(loopcount/totalLoopCount,progBar,'Measuring...');
    end
end    

    

while( ~isempty(pageList) && ~skipped )
    %Extract page from list
    pageRemoving=pageList(1);
    while(playrec('isFinished', pageRemoving) == 0)
        pause(pageDuration/10);
    end 
    lastRecording = playrec('getRec', pageRemoving);
    [recSamples recCh]=size(lastRecording);
    if(~isempty(lastRecording))
        lindex=inTotalSample+1;
        uindex=inTotalSample+recSamples;
        sIn(lindex:uindex,:) = lastRecording;
        inTotalSample=inTotalSample+length(lastRecording);
        %disp(['SND_recAndPlay:   [Page ' num2str(pageRemoving) '] extract (' num2str(lindex) ':' num2str(uindex) ') ' num2str(length(lastRecording)) ' samples, total extract ' num2str(inTotalSample) ' samples']);
    end
    %Remove finished page from list
    playrec('delPage', pageRemoving);          
    pageList = pageList(2:end);
end
[recSamples recCh]=size(sIn);
[playSamples playCh]=size(sOut);
str1=(['SND_recAndPlay: task finished. Write ' num2str(outTotalSample) ' samples, read ' ' sample ' num2str(inTotalSample) ]);
str2=(['SND_recAndPlay: playbacked ' num2str(playSamples) ' samples on ' num2str(playCh) ' channels, recorded ' num2str(recSamples)  ' samples on ' num2str(recCh) ' channels']);
if gui 
    hText=GUI_writeToGui(hText,str1);
    hText=GUI_writeToGui(hText,str2);
else
    disp(str1);
    disp(str2);
end

if (skipped)
    status='Samples skipped during measure';
elseif canceled
    status='Cancelled by user';
else
    status='success';
end

if gui
    delete (progBar)
end



