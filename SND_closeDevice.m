function SND_closeDevice( )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if playrec('isInitialised') 
    disp ('SND_closeDevice: Resetting playrec');
    playrec('reset');
else
    disp ('SND_closeDevice: playrec not initialised');
end 

end

