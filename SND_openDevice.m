function status=SND_openDevice(playDevice, recDevice, fs)
%%This function open the audio device and initialising
%%return true if success or false if was some error during the init
status='Unopen devices';


if exist('playrec', 'file') ~= 3
    status=('SND_openDevice: The Playrec MEX file does not yet exist in the current directory or on the search path');
    return;
end
buildDefines = regexpi(playrec('about'), 'Built with defines:\s*(.*?),?\s*(?:\n|$)', 'tokens');
deviceSummary = regexpi(playrec('about'), 'Available host API:\s*(.*?),?\s*(?:\n|$)', 'tokens');
if ~isempty(buildDefines)
    disp(['SND_openDevice: Playrec was built with the following defines: ' cell2mat(buildDefines{1})] );    
end
if ~isempty(deviceSummary)
    disp(['SND_openDevice: Playrec was built with the following host API: ' cell2mat(deviceSummary{1})] );    
end
if isempty(playrec('getDevices'))
    status=('SND_openDevice: There are no devices available using the selected host APIs.');
    return;
end
if playDevice.ID == -1 || recDevice.ID==-1
    status=('SND_openDevice: No device selected');
else
    
    % Check if the device has already been initialised.  If it has then
    % this would mean it cannot be initialised with the required
    % configuration so it needs to be reset.  There are a set of get*
    % commands (eg getPlayDevice) to find out more about the current
    % configuration if necessary.
    
    
    %%%ESECUZIONE WAVE
    SND_closeDevice();
    try
        playrec('init', fs, playDevice.ID, recDevice.ID)%, length(playDevice.channels), length(recDevice.channels), ...
                       %round(fs/2), 1, 1)
        disp(['SND_openDevice: Init OK. fs=' num2str(fs) ' Hz' ]);
        disp (['SND_openDevice: Starting playing using device ' num2str(playDevice.ID) ' (' playDevice.data.name ', ' playDevice.data.hostAPI ')'] )
        disp (['SND_openDevice: Starting recording using device ' num2str(recDevice.ID) ' (' recDevice.data.name ', ' recDevice.data.hostAPI ')'] )
        %playing a silence , this avoid a problem with the first samples
        %played
        waveout=zeros(floor(fs*0.1),length( playDevice.channels));
        idPage=playrec('play', waveout, playDevice.channels);
        playrec('block', idPage);   
        status='success';
    catch
        status=(['SND_openDevice:  Exception catched initialising device at ' num2str(fs) ' Hz failed: ' lasterr]); 
        disp(status);
    end
end