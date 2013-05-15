function measure=UTIL_defaultMeasParams()

%General parameters
measure.generalParams.sampleRate=44100;
measure.generalParams.name='Measure Title';
measure.generalParams.description='Measure Description';




%FUNZIONE LISTA DEVICES
measure.audioDevice.playDevice.ID=0;
measure.audioDevice.playDevice.channels=[1 2];
measure.audioDevice.playDevice.channelsDescription= {'Sweep' 'Aux'};
measure.audioDevice.recDevice.ID=3;
measure.audioDevice.recDevice.channels=[1 2];
measure.audioDevice.recDevice.channelsDescription={'Mic' 'Ref' };

%Test signal
measure.sweepExcitationParameters.duration=2; %Time in sec.
measure.sweepExcitationParameters.fs=measure.generalParams.sampleRate;
measure.sweepExcitationParameters.f1=10;
measure.sweepExcitationParameters.f2=measure.generalParams.sampleRate/2;
measure.sweepExcitationParameters.fadeIn=0.01;
measure.sweepExcitationParameters.fadeOut=0.01;
measure.sweepExcitationParameters.presilence=0.1;
measure.sweepExcitationParameters.postsilence=0.1;

measure.generalParams.NFFT=8192;
measure.generalParams.dinamicRange_dB=100;
measure.generalParams.numberRipetitions=1;
measure.generalParams.calculateMedia=false;
measure.generalParams.fftWin='rect';
