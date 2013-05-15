function winlen=UTIL_getWinLen(x, sr)

if nargin < 2 || isempty(sr)
   sr=44100; %assume default sr 
end
winlen = BROWN_getDefaultWinSize(sr);

winlen=min(winlen,ceil(2^nextpow2(length(x)/16)));