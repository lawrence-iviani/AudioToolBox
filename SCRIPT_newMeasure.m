function measure=SCRIPT_newMeasure(measure)

%General setting
maxSkippedRetry=3;

%Get audio devices
audioDevs = SND_findDevices();
if nargin==0 || isempty(measure)
    measure=UTIL_defaultMeasParams();
end


oldMeasure=measure;
[hnew status paramData]=GUI_newMeasure(measure.generalParams,measure.audioDevice,measure.sweepExcitationParameters,audioDevs);
if (ishandle(hnew))
    close(hnew);
end
if strcmp(status,'success' )
    disp('SCRIPT_newMeasure: Preparing for measure');
    measure.generalParams=paramData.generalParams;
    measure.audioDevice=paramData.audioDevice;
    measure.sweepExcitationParameters=paramData.sweepExcitationParameters;
    %measure.generalParams.NFFT=oldMeasure.generalParams.NFFT;
    measure.generalParams.dinamicRange_dB=oldMeasure.generalParams.dinamicRange_dB;
    measure.generalParams.fftWin=oldMeasure.generalParams.fftWin;
    %Resetting measure
    measure.audio.recordedStimulus=[];
    measure.audio.h=[];
    measure.audio.hETC=[];

    %Check audio
    if length(measure.audioDevice.playDevice.channels) < 1 
        status='Output audio channels not selected';
    elseif length(measure.audioDevice.recDevice.channels) < 1
        status='Input audio channels not selected';
    else 
        status=SND_openDevice(measure.audioDevice.playDevice, measure.audioDevice.recDevice, measure.generalParams.sampleRate);
    end   
end  
measure.recordedStimulus=[];
hlog=[];
if strcmp(status,'success' )
   %Generating stimulus
   [measure.audio.stimulus inverseSweep measure.generalParams.timeBase]= UTIL_logSweepGen(measure.sweepExcitationParameters);
   clear('inverseSweep')
   %Executing measure
   hlog=GUI_measureExecution();

   %Preparing for log the measure
   hProp=get(hlog,'Children');
   logMeasure=[];
    if ~isempty(hProp)
        for n=1:length(hProp)
            name=get(hProp(n),'Tag');
            if strcmp(name,'editMeasure')
                logMeasure.textHandle=hProp(n);
                logMeasure.text={};
                logMeasure.line=1;
                logMeasure.initTime=clock();
                logMeasure=GUI_writeToGui(logMeasure,'Starting measure...');
                break;
            end
        end
    end

    %%%%%Ciclo di misura -------------
    for nmeas=1:measure.generalParams.numberRipetitions
        for nSkipped=maxSkippedRetry:-1:1
            disp('SCRIPT_newMeasure: Calling  SND_recAndPlay');
            [recordedStimulus , ~, logMeasure status]=SND_recAndPlay(logMeasure,measure.audio.stimulus,...
                                             measure.generalParams.sampleRate,...
                                             measure.audioDevice.playDevice,...
                                             measure.audioDevice.recDevice);   
            disp(['SCRIPT_newMeasure: status=' status]);
             if ~strcmp(status,'Samples skipped during measure')
                 break;
             else
                 logMeasure=GUI_writeToGui(logMeasure,['Samples skipped, retrying ' num2str(nSkipped) ' times']);
                 statusReopen=SND_openDevice(measure.audioDevice.playDevice, measure.audioDevice.recDevice, measure.generalParams.sampleRate);
                 if ~strcmp(statusReopen,'success' )
                     logMeasure=GUI_writeToGui(logMeasure, ['Failed to reopen device ']);
                     break;
                 end
             end            
        end
        clear('notUsed')
       %Check for clip in the recorded file, otherway perform calculation
        if strcmp(status,'success'  )                                 
            [l ch]=size(recordedStimulus);
            tIR=zeros(l,ch);
            for n=1:ch
                clipHI=find(recordedStimulus(:,n) > 0.99999999);
                clipLOW=find(recordedStimulus(:,n) < -0.9999999);
                if ~isempty(clipHI) || ~isempty(clipLOW)
                    logMeasure=GUI_writeToGui(logMeasure,['Channel ' num2str(n) ' clipped']);
                    status='clipping';
                    break
                else
                    if measure.generalParams.calculateMedia
                        logMeasure=GUI_writeToGui(logMeasure,['Adding measure ' num2str(nmeas) ' on channel ' num2str(n) ]);
                        if nmeas==1
                            measure.audio.recordedStimulus(:,n)=recordedStimulus(:,n);
                            %Adding description
                            measure.audio.description(:,n)=measure.audioDevice.recDevice.channelsDescription(n);
                        else
                            measure.audio.recordedStimulus(:,n)=recordedStimulus(:,n)+measure.audio.recordedStimulus(:,n);
                        end
                    else
                        indexMeas=(nmeas-1)*ch+n;
                        logMeasure=GUI_writeToGui(logMeasure,['Calculating IR on channel ' num2str(indexMeas) ]);
                        measure.audio.recordedStimulus(:,indexMeas)=recordedStimulus(:,n);
                        measure.audio.h(:,indexMeas)= RESP_getIR(measure.audio.stimulus, ...
                                                     measure.audio.recordedStimulus(:,indexMeas), ...
                                                     measure.generalParams.dinamicRange_dB); 
                        %Adding description
                        measure.audio.description(indexMeas)={[ char(measure.audioDevice.recDevice.channelsDescription(n)) '_#' num2str(nmeas) ]};
                    end                            
                end
            end 
        else
            break;
        end
       %%%%%Fine Ciclo di misura -------------
    end
    if strcmp(status,'success' )
        if measure.generalParams.calculateMedia
            %Performing media calculus
            [l ch]=size(measure.audio.recordedStimulus);
            for n=1:ch
                logMeasure=GUI_writeToGui(logMeasure,['Calculating media IR on channel ' num2str(n) ]);
                measure.audio.recordedStimulus(:,n)=measure.audio.recordedStimulus(:,n)/nmeas;
                measure.audio.h(:,n)= RESP_getIR(measure.audio.stimulus, ...
                                                 measure.audio.recordedStimulus(:,n), ...
                                                 measure.generalParams.dinamicRange_dB); 
            end

        end     

        %Calculating ETC
        [l ch]=size(measure.audio.recordedStimulus);
        for n=1:ch
            logMeasure=GUI_writeToGui(logMeasure,['Calculating ETC on channel ' num2str(n) ]);     
            measure.audio.hETC(:,n)=20*log10(abs(hilbert(measure.audio.h(:,n)))); 
        end

    end
end

%Close Device
SND_closeDevice();

if ~strcmp(status,'success' )
    hwarn=warndlg(status,'Error during the measure. Measure not executed...','modal');
    uiwait(hwarn);
else 
    oldMeasure=measure;
    [hendmeas status measure.audio measure.generalParams saveNameFile]=GUI_endMeasure(status,measure.generalParams,measure.audio);
    if ishandle(hendmeas)
        close(hendmeas);
    end  
    if strcmp(status,'success')
        %Saving measure
        measureData.name=measure.generalParams.name;
        measureData.description=measure.generalParams.description;
        measureData.sampleRate=measure.generalParams.sampleRate;
        measureData.channelsDescription=measure.audioDevice.recDevice.channelsDescription;
        measureData.recordedStimulus=measure.audio.recordedStimulus;
        measureData.h=measure.audio.h;
        measureData.hETC=measure.audio.hETC;      
        measureData.stimulus=measure.audio.stimulus;  
        save(saveNameFile, 'measureData');
    else
        measure=oldMeasure;
    end
end

if ishandle(hlog)
    close(hlog);
end   


