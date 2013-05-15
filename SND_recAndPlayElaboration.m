function [ status someKindOfResults] = SND_recAndPlayElaboration(fs, playDev, recDev, varargin )
% This function is a interface for collecting data and reporoduction in one
% thread. The reproduction and the analyzer function can be selected and is not implemented inside this script 
%   Detailed explanation goes here

%% Set some parameters
%If log on windows set with varargin log
log=false;
status='success';
runStatus='run'; %The possible status are, run, stop, pause

%default parameters
defaultaverageAcquisition=true; %Average the during the acquisition.
defaultwinLen=4096;%duration in sample of every page
defaultNWin=8; %number of  win
defaultMaxAmplitude=20; %max value in db to be displayed
defaultMinAmplitude=-60;%min value in db to be displayed
defaultMaxFrequency=fs/2;%max value in hz to be displayeddefaultwinLen
defaultMinFrequency=20;%min value in hz to be displayed

generalParams=[];%A struct conatining the genral params line nwin and and winlen

elaborationFunc=[];%The name of the function has to be called for the elaboration
elaborationParams=[];%The parameters of the elaboration function
elaborationData=[];%The data of the elaboration function

generatorData=[];%Data used by the signal generator
generatorParams=[];%Parameters for the generator
pageList=[];

handleData=[];%If there hare some handle data
hasGUI=false;% If there's a gui attached for process controll set true this flag

%% Getting params from varargin
for n = 1: length(varargin)
    if  (strcmp(varargin{n}, 'ElaborationParameters') == 1)
        elaborationParams=varargin{n + 1};
        n = n + 1;        
    elseif (strcmp(varargin{n}, 'ElaborationFunction') == 1)
        elaborationFunc=varargin{n + 1};
        n = n + 1;
    elseif (strcmp(varargin{n}, 'HandleData') == 1)
        handleData=varargin{n + 1};
        hasGUI=true;
        runStatus='pause';
        n = n + 1;      
    elseif  (strcmp(varargin{n}, 'ElaborationData') == 1)
        elaborationData=varargin{n + 1};
        n = n + 1;       
    elseif   (strcmp(varargin{n}, 'Average') == 1)
        average=varargin{n + 1};
        n = n + 1;       
    elseif   (strcmp(varargin{n}, 'WinLen') == 1)
        generalParams.winLen=varargin{n + 1};
        n = n + 1;       
    elseif   (strcmp(varargin{n}, 'WinNumbers') == 1)
        generalParams.nWin=varargin{n + 1};
        n = n + 1;       
    end
end

%% Get the params from the GUI
if hasGUI
    disp('SND_recAndPlayElaboration: getting GUI params');
    data=getappdata(handleData,'UserData');
    elaborationParams=data.analyzerParams;
    elaborationFunc=data.analyzerParams.function; 
    generatorParams=data.generatorParams;
    generalParams=data.generalParams;
end

%% Params for the function testDisplay, if nothing selected use this
%% function
% if isempty(elaborationFunc)
%     elaborationFunc='DUALCHANNELFFT_testDisplay';%Mandatory
%     warning(['SND_recAndPlayElaboration: elaboration function not selected. Use default  ' elaborationFunc ]); 
%     elaborationParams.average=defaultAverage;%Mandatory
%     elaborationParams.winLen=defaultwinLen;%Mandatory
%     elaborationParams.nWin=defaultNWin;%Mandatory    
%     
%     %Elaboration based params
%     elaborationParams.win='tukey';
%     elaborationParams.NFFT=4096;  
%     elaborationParams.percetnOverlap=UTIL_getOptimalPercentOverlap(elaborationParams.win);%percent overlap
%     elaborationParams.fmin=16;
%     elaborationParams.fmax=fs/2;
% end

%% Params for the function RTA, if nothing selected use this
%% function
if isempty(elaborationFunc)
    elaborationParams=DUALCHANNELFFT_analyzerDefaultParams('RTA',fs);
    elaborationFunc=elaborationParams.function; 
    warning(['SND_recAndPlayElaboration: elaboration function not selected. Use default  ' elaborationFunc ]); 
end


%% Check for mandatory params
if isempty(generalParams) ||  ~isfield(generalParams,'averageAcquisition') || isempty(generalParams.averageAcquisition)  
    generalParams.averageAcquisition=defaultaverageAcquisition;%Mandatory
    warning(['SND_recAndPlayElaboration: mandatory average acq. flag boolean not set. Setting to ' num2str(elaborationParams.averageAcquisition)]); 
end
if isempty(generalParams) || ~isfield(generalParams,'winLen') || isempty(generalParams.winLen)  
    generalParams.winLen=defaultwinLen;%Mandatory
    warning(['SND_recAndPlayElaboration: mandatory variable winLen not set. Setting to ' num2str(elaborationParams.winLen)]); 
end
if isempty(generalParams) || ~isfield(generalParams,'nWin') || isempty(generalParams.nWin)  
    generalParams.nWin=defaultNWin;%Mandatory 
    warning(['SND_recAndPlayElaboration: mandatory variable nWin not set. Setting to ' num2str(elaborationParams.nWin)]); 
end


% NOT MANDATORY BUT CHECK AND EVENTUALLY SET
if ~isfield(generalParams,'defaultMaxAmplitude') || isempty(generalParams.defaultMaxAmplitude)  
    generalParams.defaultMaxAmplitude=defaultMaxAmplitude;
end
if ~isfield(generalParams,'defaultMinAmplitude') || isempty(generalParams.defaultMinAmplitude)  
    generalParams.defaultMinAmplitude=defaultMinAmplitude;
end
if ~isfield(generalParams,'defaultMaxFrequency') || isempty(generalParams.defaultMaxFrequency)  
    generalParams.defaultMaxFrequency=defaultMaxFrequency;
end
if ~isfield(generalParams,'defaultMinFrequency') || isempty(generalParams.defaultMinFrequency)  
    generalParams.defaultMinFrequency=defaultMinFrequency;
end
 
%% Starting  acquisition process
if ~playrec('isInitialised')
    status=(['SND_recAndPlayElaboration: Failed to initialise device at the selected sample rate (' num2str(fs) ' Hz), try another one']);
    return
end

%% Settings some params for cycling
N_playbackChannels=length(playDev.channels);
N_recChannels=length(recDev.channels);

isFirst =  true;
loopOutCount=1;
pageLen=generalParams.nWin*generalParams.winLen;
pageDuration=1000*pageLen/fs;
minTimeLengthBuffer=2; %The minimum time (in sec.) of buffer ready to be playbacked
nMinBuffer=ceil((minTimeLengthBuffer*fs)/pageLen); %The minimum number of buffer ready to be playbacked
sOut=zeros(pageLen, N_playbackChannels);
sIn=zeros(pageLen, N_recChannels);
needAcquisition=true;
needReproduction=true;


tic
%% Cycle acquisition/reproduction
while ~strcmp(runStatus,'stop')
    loop=loopOutCount;
    DEBUG_arrayTime=[];
    DEBUG_arrayTime=DEBUG_addTime(toc,DEBUG_arrayTime);
    startTime=DEBUG_arrayTime(1);
    fprintf('\n\n\n\nSND_recAndPlayElaboration %5.4f:  ------starting [loop %d ] estimated duration time %f msec\n', DEBUG_arrayTime(end),loop,pageDuration)
    %fprintf('SND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  \n', DEBUG_arrayTime(end), DEBUG_elapsed)
    
    %% STARTING SELECTION
    [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
    DEBUG_dataSelection= DEBUG_arrayTime(end);
    fprintf('SND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  STARTING DATA SELECTION \n', DEBUG_arrayTime(end), DEBUG_elapsed)
    if hasGUI
        if isempty(handleData) || ~ishandle(handleData)
            [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
            fprintf('SND_recAndPlayElaboration %5.4f elaps %5.4f(ms): stopping cycle \n', DEBUG_arrayTime(end), DEBUG_elapsed )
            runStatus='stop';
        %elseif %check if is request acquisition or reproduction 
        else        
            [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
            fprintf('\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms): reading GUI DATA \n', DEBUG_arrayTime(end), DEBUG_elapsed)
            data=getappdata(handleData,'UserData');%Update data
            needAcquisition=data.analyzerOn;
            needReproduction=data.generatorOn;
            %Set analyzer parameters  and eventually reset  data                        
            prevGenerator=generatorParams.signalType; 
            if ~strcmp(prevGenerator,data.generatorParams.signalType)
                [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
                fprintf('\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms): GENERATOR CHANGED \n', DEBUG_arrayTime(end), DEBUG_elapsed)
                generatorData=[];
                if needReproduction
                    if length(pageList) >= 1
                        playrec('delPage');
                    end
                    pageList=[];
                end
            end
            generatorParams=data.generatorParams;
             
            %Set generator parameters  and eventually reset  data
            prevElaborationFunc=elaborationFunc;
            if ~strcmp(prevElaborationFunc,data.analyzerParams.function)
                [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
                fprintf('\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms): ANALYZER CHANGED \n', DEBUG_arrayTime(end), DEBUG_elapsed)
                elaborationData=[];
                elaborationFunc=data.analyzerParams.function; 
            end
            elaborationParams=data.analyzerParams;

            %Set the general params and evantually reset analyzer and
            %generator data if the window length change
            if generalParams.nWin~=data.generalParams.nWin || generalParams.winLen~=data.generalParams.winLen
                [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
                fprintf('\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms): windowing change \n', DEBUG_arrayTime(end), DEBUG_elapsed)
                generatorData=[];   
                elaborationData=[]; 
                generalParams.nWin=data.generalParams.nWin;
                generalParams.winLen=data.generalParams.winLen;
                pageLen=generalParams.nWin*generalParams.winLen;
                pageDuration=1000*pageLen/fs;
                nMinBuffer=ceil((minTimeLengthBuffer*fs)/pageLen); 
                sOut=zeros(pageLen, N_playbackChannels);
                sIn=zeros(pageLen, N_recChannels);   
                if length(pageList) >= 1
                    playrec('delPage');
                end
                pageList=[];   
            end         
                        
            %Check if gen and anal are turned on
            if needAcquisition || needReproduction            
                runStatus='run';   
            else
                runStatus='pause';
            end
        end     
    end
    [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
    DEBUG_dataSelection=DEBUG_arrayTime(end)-DEBUG_dataSelection;
    fprintf('SND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  END DATA SELECTION in %5.4f(ms) \n', DEBUG_arrayTime(end), DEBUG_elapsed,DEBUG_dataSelection )
    
 %% STARTING ELABORATION
    [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
    DEBUG_dataElaboration=DEBUG_arrayTime(end);
    fprintf('SND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  STARTING DATA ELABORATION \n', DEBUG_arrayTime(end), DEBUG_elapsed)   
    if strcmp(runStatus,'pause') 
        [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
        fprintf('\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  PAUSE STATUS \n', DEBUG_arrayTime(end), DEBUG_elapsed)
        if length(pageList) >= 1
            playrec('delPage');
        end
        pageList=[];
        pause(1)
    elseif strcmp(runStatus,'stop') 
        [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
        fprintf('\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  STOP STATUS \n', DEBUG_arrayTime(end), DEBUG_elapsed)
        if length(pageList) >= 1
            playrec('delPage');
        end
        pageList=[];
        
        
%% RUN START HERE----------------------------------------------------------------------------------------------------------------------------
    elseif strcmp(runStatus,'run') 
        [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
        fprintf('\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  RUN STATUS \n', DEBUG_arrayTime(end), DEBUG_elapsed)
        if(isFirst)
            %This is the first time through so reset the skipped sample count
            [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
            fprintf('\t\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  RESET SAMPLES SKIPPED at previous loop,  [loop %d]\n', DEBUG_arrayTime(end), DEBUG_elapsed,loop)
            playrec('resetSkippedSampleCount');
            isFirst = false;
        else
            if(playrec('getSkippedSampleCount'))
                [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
                fprintf('\t\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  RESET SAMPLES (%d) SKIPPED at [loop %d]\n', DEBUG_arrayTime(end), DEBUG_elapsed,  playrec('getSkippedSampleCount'),loop) 
                %return
                %Let the code recover and then reset the count
                isFirst = true;
                continue;
            end
        end

        %Calc sample, start/end for generate signal        
        [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
        DEBUG_generationTime=DEBUG_arrayTime(end);
        fprintf('SND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  GENERATION/ELABORATION START \n', DEBUG_arrayTime(end), DEBUG_elapsed)        
        %Generate output audio
        if length(pageList) < nMinBuffer % Fills the buffer only if needed
            nBuffer=nMinBuffer-length(pageList);
            [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
            fprintf('\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  GENERATION bufferLen=%d minBuffer=%d \n', ...
                          DEBUG_arrayTime(end), DEBUG_elapsed, length(pageList),nMinBuffer)
            for n=1:nBuffer
                lowSample=loopOutCount*pageLen + 1; %min(sample_no);
                upSample=lowSample+pageLen - 1; %max(sample_no)
                %If playback, generate sound
                refTime=toc;
                if needReproduction
                    [sOut(:,:) generatorData]=DUALCHANNELFFT_generator(generalParams, generatorParams, generatorData, fs, lowSample ,upSample, playDev.channels);
                else
                    generatorParams.signalType='Silence';
                    [sOut(:,:) ]=DUALCHANNELFFT_generator(generalParams, generatorParams, [], fs, lowSample ,upSample, playDev.channels);
                end
                [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
                fprintf('\t\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  [loop %d] GENERATION TIME %5.4f(ms)\n'...
                        , DEBUG_arrayTime(end), DEBUG_elapsed,loop,DEBUG_arrayTime(end)-refTime ) 
                
                
                refTime=toc;
                lastPageInserted=playrec('playrec', sOut, playDev.channels, -1, recDev.channels);
                pageList=[pageList, lastPageInserted];
                [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
                fprintf('\t\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms): [loop %d] I/O TIME %5.4f(ms)\n',...
                DEBUG_arrayTime(end), DEBUG_elapsed,loop,DEBUG_arrayTime(end)-refTime ) 
                loopOutCount=loopOutCount+1;
            end    
        end
        
        [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
        fprintf('\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  ELABORATION \n', DEBUG_arrayTime(end), DEBUG_elapsed)

        refTime=toc;
        if needAcquisition && playrec('isFinished', pageList(1))  

            sIn(:,:) = playrec('getRec', pageList(1));  

            %call the elabora        %% tion function
            %elaborationData=feval( elaborationFunc, generalParams,
            %elaborationParams, elaborationData, waveIn, waveOut , fs,
            %playDev.channels, recDev.channels);
            elaborationData=feval(  elaborationFunc, generalParams, elaborationParams, elaborationData, sIn, [] , fs, playDev.channels, recDev.channels);                   
            [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
            fprintf('\t\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms): [loop %d] GET REC PAGE (%d) and ELABORATED ( %5.4f(ms))\n',...
                DEBUG_arrayTime(end), DEBUG_elapsed,loop,pageList(1),DEBUG_arrayTime(end) -refTime)
        end

        refTime=toc;
        if playrec('isFinished', pageList(1))
             pageRemoving=pageList(1);
             playrec('delPage', pageRemoving);      
             %% Shift the  reprod/acq page list
             pageList = pageList(2:end);
             [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
             fprintf('\t\tSND_recAndPlayElaboration %5.4f elaps %5.4f(ms): [loop %d] DELETING PAGE %d in (%5.4f(ms))\n',...
                DEBUG_arrayTime(end), DEBUG_elapsed,loop,pageRemoving,DEBUG_arrayTime(end)-refTime)                 
        end
        [DEBUG_arrayTime DEBUG_elapsed]=DEBUG_addTime(toc,DEBUG_arrayTime);
        DEBUG_generationTime=DEBUG_arrayTime(end)-DEBUG_generationTime;
        fprintf('SND_recAndPlayElaboration %5.4f elaps %5.4f(ms):  GENERATION/ELABORATION IN %5.4f(ms)\n', DEBUG_arrayTime(end), DEBUG_elapsed,DEBUG_generationTime)
        
             
        elapsedTime=toc*1000-startTime;
        remainingTime=pageDuration-elapsedTime;
        pauseTime=0.9*remainingTime;
        if remainingTime > 0
            disp(['\tSND_recAndPlayElaboration:  [loop ' num2str(loop) '] End cicle, execution time ' num2str(elapsedTime) ' ms remainigtime ' num2str(remainingTime) ' ms pause for ' num2str(pauseTime) ' ms' ]);
            pause(pauseTime/1000);
        else
            str=(['\tSND_recAndPlayElaboration: [loop ' num2str(loop) '] End cicle, execution time ' num2str(elapsedTime) ' ms OVERRUN of ' num2str(abs(remainingTime))  ' ms !!!!!' ]);
            if log 
                %hText=GUI_writeToGui(hText,str);
            else
                disp(str);
            end
        end
        elapsedTime=toc*1000-startTime;
        disp(['SND_recAndPlayElaboration: actualPage=' num2str(playrec('getCurrentPosition')) ' , page stored ' num2str(pageList)])
        fprintf('SND_recAndPlayElaboration:  ------end [loop %d] execution time %f msec------\n',loop,elapsedTime);
    else
         warning(['SND_recAndPlayElaboration: unknown running status --' runStatus '--']);
    end    
end

playrec('reset')

end

function [tArray elapsed ]=DEBUG_addTime(t,tArray)
    if isempty(tArray)
        tArray(1)=t*1000;
        elapsed=0;
    else
        tArray(end+1)=t*1000;
        elapsed=tArray(end)-tArray(1);
    end
end

