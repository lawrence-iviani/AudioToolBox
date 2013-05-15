function SND_test()


SCRIPT_setEnviromet()
fs=44100;
audioDevs = SND_findDevices();
measure=UTIL_defaultMeasParams();%TODO, cambiare nome... boh...
audioDev=measure.audioDevice;
[h status audioDev fs]=GUI_selectAudioInterface(fs,audioDevs,audioDev);
close(h)
SND_openDevice(audioDev.playDevice, audioDev.recDevice, fs);
generatorParams=DUALCHANNELFFT_generatorDefaultParams('Pink noise');

loopOutCount=0;
playPageList=[];
lenWin=fs*2;
durationWin=lenWin/fs;

while(loopOutCount < 2000)
    tic;
    
    if length(playPageList) < 4
        disp(['Preparing page loopOutCount=' num2str(loopOutCount)])
        lowSample=loopOutCount*lenWin + 1; %min(sample_no);
        upSample=lowSample+lenWin - 1;
        s=DUALCHANNELFFT_generator([], generatorParams, [], fs, lowSample ,upSample, audioDev.playDevice.channels);
        lastPageInserted=playrec('play', s, audioDev.playDevice.channels);
        playPageList=[playPageList, lastPageInserted];           
        disp(['Preparing page outPage=' num2str(playPageList)])
        loopOutCount=loopOutCount+1;
    end
    if  ~isempty(playPageList) && length(playPageList) >= 3 && playrec('isFinished', playPageList(1))
        playrec('delPage', playPageList(1));    
        playPageList = playPageList(2:end);
    end        
            
    elapsedTime=toc;
    disp(['Elapsed time:  ' num2str(elapsedTime)])
    if (durationWin-elapsedTime) > 0
        pause(durationWin-elapsedTime)
    else
        disp(['OVERRUN!!  ' num2str(abs(durationWin-elapsedTime))])
    end
 end