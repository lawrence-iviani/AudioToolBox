function SCRIPT_startTwoChannelsMeasure()
  
clear all
close all
clc
SCRIPT_setEnviromet();

playDeviceID = 1;
recDeviceID = 1;
fs=44100;



% devs = playrec('getDevices');
% 
% [playDevID playDev] = select_play_device();
% playDev.ID=playDevID;
% playDev.channels=playDev.outputChans;
% [recDevID  recDev ] = select_rec_device();
% recDev.ID=recDevID;
% recDev.channels=recDev.inputChans;

audioDevs = SND_findDevices();
measure=UTIL_defaultMeasParams();%TODO, cambiare nome... boh...
audioDev=measure.audioDevice;
[h status audioDev fs]=GUI_selectAudioInterface(fs,audioDevs,audioDev);
if ~isempty(h) && ishandle(h)
    close(h)
end
if ~strcmp(status,'success')
    disp(['SCRIPT_startTwoChannelsMeasure: select interface failed. Exiting status: -' status '-' ]);
    return
end

SND_openDevice(audioDev.playDevice, audioDev.recDevice, fs);
if ~strcmp(status,'success')
    disp(['SCRIPT_startTwoChannelsMeasure: open device failed. Exiting status: -' status '-' ]);
    return
end

[hData]=GUI_DualChannelAnalyzer(fs);
SND_recAndPlayElaboration(fs, audioDev.playDevice, audioDev.recDevice, 'HandleData', hData)

if ~isempty(h) && ishandle(hData)
    close(hData)
end

end