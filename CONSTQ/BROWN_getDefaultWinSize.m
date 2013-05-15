function windsizmax=BROWN_getDefaultWinSize(SR)
% A default parameter to  get an appropriate winsize max of the kernel window for the brown algorithm
% SR is the sample rate
windsizmax = 2^nextpow2( 0.08 * SR);  % take a  ms 