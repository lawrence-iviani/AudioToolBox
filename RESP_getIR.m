function h=RESP_getIR(sweep, response, range_dB)

% getIR uses the swept sine excitation stored in
% sweep to calculate an inverse filter using the FFT.
% The inverse filter is applied cyclically by dividing in the 
% frequency domain.  For this reason, the dynamic range of the 
% inverse filter is limited by range to help avoid divide by zero errors.  
% 
% Based on:
% https://ccrma.stanford.edu/realsimple/imp_meas/sinesweeps_response.m


if nargin < 3 || isempty(range_dB)
  range_dB=90;
end


range=10^(range_dB/20);
Fs = fft(sweep);
ind = find(abs(Fs) < max(abs(Fs))/range);
Fs(ind) = ones(size(ind)) * max(abs(Fs))/range;
h = ifft(fft(response)./Fs);
h = real(h);




