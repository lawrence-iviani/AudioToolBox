function [K, k, f] = CONSTQ_cqkern(sr, bpo, f_min, f_max, thresh, fffWin, h)
% This function calculate the kernel for the default transformation
% Calculate the spectral (K) and temporal (k) kernels and a vector of f bins,
% sr, the sample rate, is mandatory
% The default value are: 
% [K, k, f] = cqkern(sr, bpo = 12, f_min = midifreq(12), f_max = sr/2, thresh=0054, fffWin=hamming)
% 
% bpo: bins per octave
% f_min: the min frequency of the transfo
% f_max: the max freq. of the transfo
% thresh: a threshold for allow sparse the kernel matrix and space optimizing the storage
% fftWin: the windowing of the kernel 
% Based on the works of:
% 1. [Benjamin Blankertz]  The Constant Q Transform 
%
% 2. An efficient algorithm for the calculation of a constant Q transform
%    Judith C. Brown and Miller S. Puckette
%    J. Acoust. Soc. Am. 92 (5), November 1992

% error(nargchk(1, 4, nargin));
if nargin < 2 || isempty(bpo)
    % semitones
    bpo = 12;
end
if nargin < 3 || isempty(f_min)
    % C0, MIDI note 12
    f_min = 16.352;
end
if nargin < 4 || isempty(f_max)
    % Nyquist
    f_max = sr/2;
end
if nargin < 5 || isempty(thresh)
    thresh= 0.0054; 
end    % for Hamming window
if nargin < 6 || isempty(fffWin)
    fffWin='hamming'; 
end  
if nargin < 7
    h=[];
end
%Calcolate freq bins... to check...
tic;
r = 2^(1/bpo);
B = ceil(log(f_max/f_min) / log(r));
o_min = 2 * pi * f_min / sr; % o for omega (w for window)
o = o_min * r.^(0:B-1)'; % vector of omegas
f=o.*(sr/(2*pi));
f=f';

Q= 1/(2^(1/bpo)-1);                                                    
KK= ceil( bpo * log2(f_max/f_min) );                                 
fftLen= 2^nextpow2( ceil(Q*sr/f_min) );
tempKernel= zeros(fftLen, 1);
K= [];
%Per ogni banda (data da bpo, fmax e fmin) calcola cqt di lunghezza
%ottimale len= ceil( Q * sr / (f_min*2^((kk-1)/bpo)) );      
for kk= KK:-1:1;
   len= ceil( Q * sr / (f_min*2^((kk-1)/bpo)) ) ;
   %fprintf('CONSTQ_cqkern: winsize=%.0f f=%.2f\n', len , f_min*2^((kk-1)/bpo));
   win=UTIL_getWindow(fffWin,len);
   %tempKernel(1:len)= hamming(len)/len .* exp(2*pi*i*Q*(0:len-1)'/len);  
   tempKernel(1:len)= win/len .* exp(2*pi*i*Q*(0:len-1)'/len);  
   specKernel= fft(tempKernel);                                          
   specKernel(find(abs(specKernel)<=thresh))= 0;
   K=sparse([specKernel K]);
   if ~isempty(h) && ishandle(h)
       progress=1-kk/KK;
       waitbar(progress,h);
   end
end
K= conj(K) / fftLen; 
N = round(2*pi*Q ./ o); % vector of Nkcqs
N0 = N(1); % Longest N

%TODO: Check for calculating k
%k=fft(K,N0);
k=[];
t=toc;
disp(['CONSTQ_cqkern: kernel calcolated. Elapsed time ' num2str(t) ' sec. bpo=' num2str(bpo) ' ' fffWin ' window  threshold=' num2str(thresh) ])

if ~isempty(h) && ishandle(h)
       close(h);
end
