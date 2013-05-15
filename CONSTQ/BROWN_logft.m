function  [cq, time]  = BROWN_logft(infile, noverlap, kerncos, kernsin,  windsizmax, nfreqs, SR, ccx)
% (kerncos, kernsin) are the brown algorithm kernel
% the relative vector of frequency (freqs)
% infile: the signal has to be transfomed
% SR: sample rate
% noverlap: the number of bins of overlapping for any slice
% minfreq: the min frequency of the transfo
% freqrat: the max freq. of the transfo
% nfreqs: the number of bins needed for this transformation
% windsizmax: the maximum length of the kernel, the algorithm choose the right win length but aren't allowed winlen > windsizmax
% 1. An efficient algorithm for the calculation of a constant Q transform
%    Judith C. Brown and Miller S. Puckette
%    J. Acoust. Soc. Am. 92 (5), November 1992
%TODO: verificare il comportamento di ccx!!!!
% infile = vsc11;
% hopsiz = 256; % The hop for any step, if you got noverlap like in case of
% sepectrum hopsiz=windsizmax-noverlap
% 
% infile has to be a column array
[nrows ncols] = size(infile);

if ncols ~= 1 & nrows ~= 1

   error('infile not a row or col array');

elseif ncols ~= 1

   infile = infile';

end

[nr nc] = size(kerncos);
%if  windsizmax =  %  no input windsizmax
if  isempty(windsizmax) || windsizmax == 0
	windsizmax = nc; 
	fprintf('BROWN_logft: No input maximum window size. Taking the size of kerncos %.0f \n',nc);
end


%if  nfreqs == 0)   % no nfreqs either
if  isempty(nfreqs) || nfreqs == 0
    warning('BROWN_logft: DEBUG, are the same??');
    nfreqs = BROWN_getNumberOfBins(minfreq,SR/2,freqrat); % to give highest freq at the Nyq
	fprintf('BROWN_logft: No input number of freqs; taking freqs from minfreq to Nyquist = %.0f freq bins\n', nfreqs);
end

fprintf('BROWN_logft:  nc=%.0f windsizmax=%.0f \n',nc, windsizmax);
if nc < windsizmax
	windsizmax = nc;
	fprintf(['BROWN_logft: winsizmax longer than need for this minfreq; changing to ' num2str(nc) ' = ' num2str(1000*nc/SR) ' ms (freq=' num2str(SR/nc) ' Hz'])
elseif  nc > windsizmax
    windsizmax = nc;
    fprintf(['BROWN_logft: winsizmax shorter, changing to ' num2str(nc) ' = ' num2str(1000*nc/SR) ' ms (freq=' num2str(SR/nc) ' Hz'])  
else
    fprintf('BROWN_logft: winsizmax ok\n');
end

%windsizmax=nc;
hopsiz=windsizmax-noverlap;
nhops = 1 + floor((length(infile)-windsizmax)/hopsiz);
nhops = max(0,nhops);
fprintf('BROWN_logft: lengthsig=%.0f hopsize=%.0f noverlap=%.0f windsizmax=%.0f nhops=%.0f\n',length(infile), hopsiz,noverlap, windsizmax, nhops);
lastwin=length(infile)-nhops*hopsiz;

%todo, non viene utilizzata l'ultima finestra (incompleta)
if lastwin > 0
    cq = zeros(nfreqs, nhops+1);
else
    cq = zeros(nfreqs, nhops);
end

for jj = 0:nhops-1
    ninit = jj*hopsiz+1;
    nfnl  =  jj*hopsiz +1 + windsizmax - 1;
    	%fprintf('BROWN_logft:  %.0f\t %.0f\n',ninit, nfnl);
    infile2 = infile(ninit:nfnl);
    reOinfil = kerncos * infile2;
    imOinfil = kernsin * infile2;
    if ccx == 1,
        cq(:,jj+1) = reOinfil  +  i * imOinfil;
    else
        cq(:,jj+1) = ((reOinfil .^ 2) + (imOinfil .^ 2)) .^(.5);
    end
end

if lastwin > 0
    if nhops==0
        ninit = 1;
    else
        ninit = nhops*hopsiz+1;
    end
    nfnl = length(infile);
    infile2 = infile(ninit:nfnl);
    nzeros=windsizmax-length(infile2);
    
    infile2=[infile2' zeros(1,nzeros)]';
    reOinfil = kerncos * infile2;
    imOinfil = kernsin * infile2;
    if ccx == 1
        cq(:,nhops+1) = reOinfil  +  i * imOinfil;
    else
        cq(:,nhops+1) = ((reOinfil .^ 2) + (imOinfil .^ 2)) .^(.5);
    end
end


cq = cq';
[rowcq collcq] = size(cq);
time = (hopsiz / SR )  * [1 : rowcq] ;
        
if nargout==0
    figure;
    semilogx(freqs, cq)
    waterfall(freqs, time, cq);
end
