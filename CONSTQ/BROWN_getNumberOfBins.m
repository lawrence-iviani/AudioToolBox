function nfreqs=BROWN_getNumberOfBins(fmin,fmax,bpo)
% a fomula to convert the bins per octave in the number of bins needed
% between fmin,fmax
nfreqs=1 + fix( log(fmax/fmin)/log(2^(1/bpo)) );