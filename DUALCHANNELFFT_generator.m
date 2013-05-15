function [ signal, data ] = DUALCHANNELFFT_generator(generalParams, params, data, fs, indexLow ,indexUp, playChanList )
%This function generate a portion of signal specified in params struct.
%(See below for a description of params). The signal is generated between
%the low index and the up index

%These are the information independent from the type of signal
%params.signalType %A string with the type of signal that has to be
%generated
%params.gain %The gain in db. 0 db is the top
%params.periodLength



signal=zeros(indexUp-indexLow+1,length(playChanList));
disp(['DUALCHANNELFFT_generator: using ' params.signalType]);
switch (params.signalType)
    case 'Pink noise' 
        signal(:,:)=UTIL_spatialPattern( [ indexUp-indexLow+1 length(playChanList) ] , -1 );        
        signal=0.9999.*normalize(signal);
    case 'Tone'
        s=0.9999.*sin((2*pi*params.f1/fs).*(indexLow:indexUp));
        for n=1:length(playChanList)
            signal(:,n)=s;
        end
    case 'Dual Tone'
        gains1=10^(params.gain1/20);
        gains2=10^(params.gain2/20);
        s1=gains1.*0.9999.*sin((2*pi*params.f1/fs).*(indexLow:indexUp));
        s2=gains2.*0.9999.*sin((2*pi*params.f2/fs).*(indexLow:indexUp));
        for n=1:length(playChanList)
            signal(:,n)=s1+s2;
        end
    case 'Silence'
        return;
end
linearGain=10^(params.gain/20);
signal=linearGain.*signal;

%Normalize
m=max(signal);
if m >= 1
    signal=normalize(signal);
    disp(['DUALCHANNELFFT_generator: need normalization of  ' num2str(20*log10(rescale)) ] );
    signal=signal.*rescale;
end

end




function s=normalize(s)
[l dim]=size(s);
for n=1:dim
    scale=1/max(abs(s(:,n)));
    s(:,n)=scale.*s(:,n);
end

end