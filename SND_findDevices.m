function audioDevs=SND_findDevices()
%Just a bridge function to the compiled playrec lib

audioDevs = playrec('getDevices');