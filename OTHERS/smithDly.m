function [gd_out,w_out] = smithDly(b,n,Fs)
% [gd_out,w_out] = smithDly(b,n,Fs) returns length N vectors gd_out and w_out
%   containing the group delay and the frequencies (in radians) at which it 
%   is evaluated. Group delay is -d{angle(w)}/dw. The frequency
%   response is evaluated at N points equally spaced around the whole
%   unit circle. If n is a vector, n rappresents a vetcor of frequency to
%   calcolate gd.
% The Smith algorithm is employed for FIR filters
%  - unpublished algorithm from J. O. Smith, 9-May-1988
%  - faster than the Shpak algorithm, best suited to FIR filters

% My modification:
% 1 - The length of variable a (denominator of the filter) to 1
% 2 - n, the length of the output vectors is doubled, than gd and f are
% halfed.
% 3 - if n is a vector, n becomes a vector of frequency where calcolate the
% gd


if length(n) > 1
    isLinearFrequency=0;
    freq=n;
else
    n=n*2;
    isLinearFrequency=1;
end
isNormalizedFreq=0;
isWholeUnitCircle=1;

a=1; %FIR filter, impose 1, this avoid long time in calculating the convolution
     %between a and b. 


na = length(a);
c = conv(b, conj(a(na:-1:1)));
c = c(:).';	% make a row vector
nc = length(c);
cr = c.*(0:(nc-1));

if isWholeUnitCircle, s=1; else s=2; end

if isLinearFrequency
   w = (2*pi/s*(0:n-1)/n)';
   if s*n >= nc	% pad with zeros to get the n values needed
      % dividenowarn temporarily supresses warnings to avoid "Divide by zero"
      %gd = dividenowarn(fft([cr zeros(1,s*n-nc)]),...
      %                  fft([c zeros(1,s*n-nc)]));
      gd = fft([cr zeros(1,s*n-nc)])./fft([c zeros(1,s*n-nc)]);     
      gd = real(gd(1:n)) - ones(1,n)*(na-1);
   else	% find multiple of s*n points greater than nc
      nfact = s*ceil(nc/(s*n));
      mmax = n*nfact;
      % dividenowarn temporarily supresses warnings to avoid "Divide by zero"
      %gd = dividenowarn(fft(cr,mmax), fft(c,mmax));
      gd = fft(cr,mmax)./fft(c,mmax);
      gd = real(gd(1:nfact:mmax)) - ones(1,n)*(na-1);
   end
   gd = gd(:);
else
    if isNormalizedFreq,
       w = n;
    else
        freq=[freq freq+Fs/2];
        nf=freq/Fs;
        w = (2*pi/s*nf)';
       %w = 2*pi*n/Fs;
    end
    s = exp(j*w);
    gd = real(polyval(cr,s)./polyval(c,s));
    gd = gd - ones(size(gd))*(na-1);
end


% Linear phase FIRs
if signalpolyutils('islinphase',b,a,0),
    % Remove leading and trailing zeros
    startidx = find(b,1);
    stopidx = find(b,1,'last');
    if max(abs(b)) == 0,
        b = 0;
    else
        % Remove leading and trailing zeros of b
        b = b(startidx:stopidx);
    end

    % Compute group delay
    if isempty(startidx),
        G1 = 0;
    else
        G1 = max(startidx-1,0); % Delay introduced by leading zeros
    end
    G2 = (length(b)-1)/2; % Delay of symmetric FIR filter
    G = G1+G2;
    gd(:) = G;
end

gd = gd(:);

% Compute frequency vector (normalized or  Hz):
if isNormalizedFreq,
    f = w;
else
    f = w * Fs/(2*pi);
end

%Half the length of gd and f
gd=gd(1:ceil(end/2));
f=f(1:ceil(end/2));

if nargout == 0,
    % Produce plots of group delay calculations:
    newplot;
    if isNormalizedFreq,
        plot(f/pi,gd)
        xlabel('Normalized Frequency (\times\pi rad/sample)')
    else
        plot(f,gd)
        xlabel('Frequency (Hz)')
    end
    ylabel('Group delay (samples)')
    set(gca,'xgrid','on','ygrid','on')
    
elseif nargout == 1,
    gd_out = gd;
    
elseif nargout == 2,
    gd_out = gd;
    w_out = f;
end