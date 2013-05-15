function [playDev recDev]=SND_selectDevice(type)
%%Select a device to be open
%%type: is a string with the type of device rec play or playrec
%%Return a struct with an ID and a data (containing the description from
%%the recplay library)

playDev.ID=-1; %device ID
playDev.data=[]; %Device description
playDev.channels=1; %Device playback channels
playDev.channelsDescription=[];%A description of the channels
recDev.ID=-1; %device ID
recDev.data=[]; %Device description
recDev.channels=1; %Device recording channels
recDev.channelsDescription=[];%A description of the channels

%%----------ORIGINAL CODE FROM:
%SELECT_PLAY_DEVICE provides a prompt to select which device to output from
%using Playrec.  Returns the device ID followed by a struct containing
%all available information on the device.
%
%Robert Humphrey, January 2008

if strcmp(type,'play') || strcmp(type,'playrec')
    devs = playrec('getDevices');
    validIDs = -1;

    prompt = '\nAvailable output devices:\n -1) No Device\n';

    for k=1:length(devs)
        if(devs(k).outputChans)
            prompt = [prompt, sprintf(' %2d) %s (%s) %d channels\n', ...
                devs(k).deviceID, devs(k).name, ...
                devs(k).hostAPI, devs(k).outputChans)];
            validIDs = [validIDs, devs(k).deviceID];
        end
    end

    fprintf([prompt, '\n']);

    deviceID = input('Select which device to use [default -1]: ', 's');

    while(~isempty(deviceID) && ~any(validIDs == str2double(deviceID)))
        deviceID = input('Invalid choice, please select which device to use [default -1]: ', 's');
    end

    if isempty(deviceID)
        playDev.ID = -1;
        playDev.data = [];
    else
        playDev.ID = str2double(deviceID);
        playDev.data = devs([devs.deviceID] == deviceID);
    end
end


if strcmp(type,'rec') || strcmp(type,'playrec')
    %SELECT_REC_DEVICE provides a prompt to select which device to record from
%using Playrec.  Returns the device ID followed by a struct containing
%all available information on the device.
%
%Robert Humphrey, January 2008

    devs = playrec('getDevices');
    validIDs = -1;

    prompt = '\nAvailable input devices:\n -1) No Device\n';

    for k=1:length(devs)
        if(devs(k).inputChans)
            prompt = [prompt, sprintf(' %2d) %s (%s) %d channels\n', ...
                devs(k).deviceID, devs(k).name, ...
                devs(k).hostAPI, devs(k).inputChans)];
            validIDs = [validIDs, devs(k).deviceID];
        end
    end

    fprintf([prompt, '\n']);

    if is_octave
        fflush(stdout);
    end

    deviceID = input('Select which device to use [default -1]: ', 's');

    while(~isempty(deviceID) && ~any(validIDs == str2double(deviceID)))
        deviceID = input('Invalid choice, please select which device to use [default -1]: ', 's');
    end

    if isempty(deviceID)
        recDev.ID=-1;
        recDev.data=[];
    else
        recDev.ID = str2double(deviceID);
        recDev.data = devs([devs.deviceID] == deviceID);
    end
end