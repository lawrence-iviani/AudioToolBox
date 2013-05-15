function win=UTIL_getWindow(winType,lenWin)
%return a window of length lenWin and calculated with the relative windows
%With no input args return a list of possible windows
if nargin==0
    win={'rectangular','blackman','hamming','bartlett','hann','tukey'};
else
    win=rectwin(lenWin);
    if strcmp(winType,'rect') || strcmp(winType,'rectangular')
        win=rectwin(lenWin);
    elseif strcmp(winType,'blackman')
        win=blackman(lenWin);
    elseif strcmp(winType,'hamming')
        win=hamming(lenWin);
    elseif strcmp(winType,'bartlett')
        win=bartlett(lenWin);
    elseif strcmp(winType,'hann')
        win=hann(lenWin);
    elseif strcmp(winType,'tukey')
        win=tukeywin(lenWin);
    end
end

[nrows ncols] = size(win);

if ncols ~= 1

   win = win';

end
