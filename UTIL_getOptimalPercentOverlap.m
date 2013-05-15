function percent=UTIL_getOptimalPercentOverlap(winType)

    if strcmp(winType,'rect') || strcmp(winType,'rectangular')
        percent=0;
    elseif strcmp(winType,'blackman')
        percent=0.5;
    elseif strcmp(winType,'hamming')
        percent=0.4999999;
    elseif strcmp(winType,'bartlett')
        percent=0.5;
    elseif strcmp(winType,'hann')
        percent=0.5;
    elseif strcmp(winType,'tukey')
        percent=0.25;
    else
        warning('UTIL_getOptimalPercentOverlap: Returning an arbitrary percent');
        percent=0.5;
    end