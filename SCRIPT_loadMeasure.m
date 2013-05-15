function SCRIPT_loadMeasure()

% loadNameFile='./misure/mic2.meas';
% vars = whos('-file', loadNameFile);
% load(loadNameFile, '-mat', vars(1:end).name);
% 
% %measureData=load(loadNameFile, 'measureData');
% 
% measure.generalParams.name=measureData.name;
% measure.generalParams.description=measureData.description;
% measure.generalParams.sampleRate=measureData.sampleRate;
% measure.audioDevice.recDevice.channelsDescription=measureData.channelsDescription;
% measure.audio.h=measureData.h;
% measure.audio.hETC=measureData.hETC;     
% measure.audio.stimulus=measureData.stimulus;  
% measure.audio.recordedStimulus=measureData.stimulus;
% 
% %Solo per tentare di riutilizzare GUI_endMeasure
% measure.generalParams.dinamicRange_dB=100;
% measure.generalParams.timeBase=0:(1/measureData.sampleRate): (length(measure.audio.stimulus)-1)/(measureData.sampleRate);
% measure.audio.description= {'wrapped','unwrapped','group delay'};
% 
% GUI_endMeasure('succes',measure.generalParams,measure.audio);