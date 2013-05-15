function  [kerncos, kernsin, freqs] = BROWN_genlgftkern(minfreq, freqrat, SR, nfreqs, windsizmax, winnam, constwind,h)
% Generate kernel matrix for const q transformation (kerncos, kernsin) and
% the relative vector of frequency (freqs)
%
% minfreq, freqrat, SR are mandatory
% 
% SR: sample rate
% minfreq: the min frequency of the transfo
% freqrat: the max freq. of the transfo
% nfreqs: the number of bins needed for this transformation
% windsizmax: the maximum length of the kernel, the algorithm choose the right win length but aren't allowed winlen > windsizmax
% constwind: if not null impose this win length for any parts of the kernel
% winnam: the windowing of the kernel 
% 1. An efficient algorithm for the calculation of a constant Q transform
%    Judith C. Brown and Miller S. Puckette
%    J. Acoust. Soc. Am. 92 (5), November 1992



if  nargin < 7 || isempty( constwind ) || constwind==0;
    constwind = 0;
    fprintf('BROWN_genlgftkern: no constant window size\n');   
else
    fprintf('BROWN_genlgftkern: Calculating kernels with constant windowsiz = %.0f\n', constwind); 
end

%if (nargin < 5) windsizmax =  %  no input windsizmax
if (nargin < 5) || isempty(windsizmax) || windsizmax == 0
	windsizmax = BROWN_getDefaultWinSize(SR);  % SUGGESTION: take a 100 ms max
	fprintf('BROWN_genlgftkern: No input maximum window size. Taking %f ms max.\n',floor(windsizmax*1000/SR)  );
end
%if (nargin < 4 | nfreqs == 0)   % no nfreqs either
if (nargin < 4) || isempty(nfreqs) || nfreqs == 0   
    nfreqs = BROWN_getNumberOfBins(minfreq,SR/2,freqrat); % to give highest freq at the Nyq
	fprintf('BROWN_genlgftkern: No input number of freqs; taking freqs from minfreq to Nyquist = %.0f freq bins\n', nfreqs);
end
if nargin < 8
    h=[];
end

tic;
% winnam = 'hamming';
if nargin < 6 || isempty(winnam)
    winnam = 'hamming';
    fprintf('BROWN_genlgftkern: Using default window Hamming\n');
else
    fprintf('BROWN_genlgftkern: Input window %s \n', winnam);
end  
if strcmp(winnam, 'rect') || strcmp(winnam, 'rectangular')
    winnam = 'boxcar'; 
end
    
Q = 1/(freqrat - 1);
TWOPI = 2*pi;
mindigfreq = TWOPI * minfreq / SR;
freqs = minfreq * (freqrat .^ [(0:1:nfreqs-1)]);
pos = find(freqs < SR/2);
freqs = freqs(pos);
nfreqs = length(freqs);
digfreq =  freqs * TWOPI/SR;
	% shouldn't need the following since fixed up freqs
if sum(find(digfreq > pi)) ~= 0
    error('BROWN_genlgftkern: freq over Nyq');
end


if isempty(constwind) || constwind == 0
    windsizOk = fix (TWOPI*Q ./digfreq);  % period in samples time Q
    % arg = (pi/2) * ones(nfreqs, windsiz);
    %windsizmax;
    fprintf('BROWN_genlgftkern:  windsizOk=%.0f windsizmax=%.0f \n', windsizOk(1),windsizmax);
    % if windsizmax < windsizOk(1) so get some windows not as long as necess for that Q
    if (windsizmax >  windsizOk(1)),
        windsizmax = windsizOk(1);
        fprintf('BROWN_genlgftkern: No const window; windsizmax = %.0f = windsizMinfreq = %.0f Q=%.1f\n', ...
            windsizmax,  windsizOk(1), Q);
    else
        fprintf('BROWN_genlgftkern: Const window %.0f up to freq position %.0f and frequency %.0f out of %.0f frequencies. windsizMinfreq = %.0f Q=%.1f\n', ...
            windsizmax, max(pos), digfreq(max(pos)) * SR/(2*pi), length(digfreq), windsizOk(1), Q);
    end
    fprintf('\n');         
    pos = find(windsizOk > windsizmax);
    
     
    windsizOk(pos) = windsizmax;
    
    kerncos = zeros(nfreqs, windsizOk(1) );
    kernsin = zeros(nfreqs, windsizOk(1) );
    numzeros = windsizOk(1) - windsizOk;
    numzerosO2 = round(numzeros/2);
    
else
    kerncos = zeros(nfreqs, constwind );
    kernsin = zeros(nfreqs, constwind );
end

% Get kaiser number if window is kaiser
if length(winnam) > 5   
  if   winnam(1:6) == 'kaiser'
    if length(winnam) == 7
        kaiserno = winnam(7); 
    elseif length(winnam) == 8
        kaiserno = winnam(7:8);
    else
        kaiserno = '8'; % default is 8 for no input kaiser number
    end
    winnam = 'kaiser';   
  end
end


if isempty(constwind) || constwind == 0 ,
  for k = 1:nfreqs
      if ~isempty(h) && ishandle(h)
        progress=k/nfreqs;
        waitbar(progress,h);
      end
      sz = windsizOk(k);
      switch(winnam)
      case 'kaiser'
          winstr = [ winnam '(' num2str(sz) ',' kaiserno ')'];
       case 'tukey'
          winstr = [ winnam 'win(' num2str(sz) ')'];
          otherwise
          winstr = [ winnam '(' num2str(sz) ')'];
      end
      %fprintf('BROWN_genlgftkern: win is %s winsize=%.0f f=%.2f\n', winstr, sz , digfreq(k)*SR/(2*pi));
      wind = eval(winstr); 
      wind = wind';

      %        wind = boxcar(windsizOk(k))'; 
      numz = 1;
      if numzerosO2(k) ~= 0, numz =  numzerosO2(k); end;
      kerncos(k, numz: numz + windsizOk(k)-1) = (1/windsizOk(k)) * ...
           cos(digfreq(k)*( -sz/2 : sz/2 - 1 )).* wind;
       %   cos(digfreq(k)*(0:windsizOk(k)-1)).* wind;

      %		    cos(digfreq(k)*(0:windsizOk(k)-1)).* wind((1:windsizOk(k)));
      kernsin(k, numz: numz + windsizOk(k)-1) = (1/windsizOk(k)) * ...
                sin(digfreq(k)*( -sz/2 : sz/2 - 1 )).* wind;
      %    sin(digfreq(k)*(0:windsizOk(k)-1)).* wind;
      %		    sin(digfreq(k)*(0:windsizOk(k)-1)).* wind((1:windsizOk(k)));
  end
else
  for k = 1:nfreqs
      if ~isempty(h) && ishandle(h)
        progress=k/nfreqs;
        waitbar(progress,h);
      end
      sz = constwind;
      switch(winnam)
      case 'kaiser'
          winstr = [ winnam '(' num2str(sz) ',' kaiserno ')'];
      case 'tukey'
          winstr = [ winnam 'win(' num2str(sz) ')'];
      otherwise
          winstr = [ winnam '(' num2str(sz) ')'];
      end
      %fprintf('BROWN_genlgftkern: win is %s winsize=%.0f f=%.2f\n', winstr, sz , digfreq(k)*SR/(2*pi));

      wind = eval(winstr); 
      wind = wind';

      %        wind = boxcar(windsizOk(k))'; 

       kerncos(k, 1 : constwind) = (cos(digfreq(k)*( -constwind/2 : constwind/2 -1 ))).* wind; 
      % kerncos(k, 1 : constwind) = (cos(digfreq(k)*(0:constwind-1))).* wind;

      %		    cos(digfreq(k)*(0:windsizOk(k)-1)).* wind((1:windsizOk(k)));
      kernsin(k, 1 : constwind) = (sin(digfreq(k)*( -constwind/2 : constwind/2 -1 ))).* wind; 
     % kernsin(k, 1:constwind) =  (sin(digfreq(k)*(0:constwind-1))).* wind;
  end
end
t=toc;
disp(['BROWN_genlgftkern: kernel calcolated. Elapsed time ' num2str(t) ' sec. bpo=' num2str(1/log2(freqrat)) ' ' winnam ' window  winsize='  num2str(sz) ])

if ~isempty(h) && ishandle(h)
       close(h);
end
