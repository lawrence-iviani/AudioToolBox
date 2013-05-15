function cqkernel=SCRIPT_provaCONSTQ(signal)

path(path,'./CONSTQ/cqt');
sr=44100;
bpo=14;
smth=1;
nameFftWin='hamming';
nfft=8192;
    BROWNWINDOWSLENGTH=1024;
%BROWNWINDOWSLENGTH=[];
%NOVERLAP=floor(WINDOWSLENGTH*0.25);%TODO find optimum base on NOVERLAP
%PERCENTOVERLAP=NOVERLAP/WINDOWSLENGTH
%disp(['PERCENTOVERLAP=' num2str(PERCENTOVERLAP)])
%winLen=BROWN_getDefaultWinSize(sr);
winMaxLen=BROWN_getDefaultWinSize(sr) ;
average='vectorial';
%hamming th=0.0054
%rect th=0.1
%hann th=0.0054/2
%blcakman th=0.0054/8
%bartlett th=0.05
%tukey th=0.0054*16


LINEAR=1;
DEFAULT=0;
BROWN=1;

% percentFade=0;
% ind_fadein=ceil(sr*percentFade);
% ind_fadeout=length(signal)-ceil(sr*percentFade);
% 
% m_fadein=1/ind_fadein;
% m_fadeout=ind_fadeout-length(signal);
% q_fadeout=-m_fadeout*length(signal);
% 
% %fadein
% signal(1:ind_fadein)=signal(1:ind_fadein).*(m_fadein*(1:ind_fadein))';
% signal(ind_fadeout:end)=signal(ind_fadeout:end).*(m_fadeout*(ind_fadeout:length(signal))+ q_fadeout)' ;


% if (nargin <2 || isempty(cqkernel))
%     cqkernel=CONSTQ_getKernel(sr,bpo, true);
% end
% size(win)
% size(signal)


if DEFAULT
    cqkernel=CONSTQ_getKernel(sr, 'bpo', bpo, 'namefftwin',nameFftWin, 'msgbox',true);
end
if BROWN
    if isempty (BROWNWINDOWSLENGTH)
        cqkernelbrown=CONSTQ_getKernel(sr, 'bpo', bpo, 'namefftwin',nameFftWin, 'winmaxlen',  winMaxLen,'msgbox',true,'algorithm','brown');%, 'constwinlen',BROWNWINDOWSLENGTH);
    else
        cqkernelbrown=CONSTQ_getKernel(sr, 'bpo', bpo, 'namefftwin',nameFftWin, 'winmaxlen',  winMaxLen,'msgbox',true,'algorithm','brown','constwinlen',BROWNWINDOWSLENGTH);
    end
end

[lensig nsig ]=size(signal);
disp(['number signals ' num2str(nsig)]);
for n=1:nsig
    sig = signal(:,n);
    % [CONSTQH CONSTQf]=RESP_calcolateFourierIR_CONSTQ( tmpH, cqkernel);
    if LINEAR
        disp('calling RESP_calcolateFourierIR');
        tic;        
        [H f gd]=RESP_calcolateFourierIR( sig, sr, average, nfft, nameFftWin);
        t=toc;
        disp(['time elapsed ' num2str(t) ' sec.']);
        gd=gd*1000/sr;
    end

    if DEFAULT
        disp('calling RESP_calcolateFourierIR_CONSTQ (default)');
        tic;
        [Hcq fcq gdcq]=RESP_calcolateFourierIR_CONSTQ(sig ,cqkernel , average);
        t=toc;
        disp(['time elapsed ' num2str(t) ' sec.']);
        gdcq=gdcq*1000/sr;
    end
    if BROWN
        disp('calling RESP_calcolateFourierIR_CONSTQ (brown)');
        tic;
        [Hcqbrown fcqbrown gdcqbrown]=RESP_calcolateFourierIR_CONSTQ(sig  ,cqkernelbrown, average);
        t=toc;
    disp(['time elapsed ' num2str(t) ' sec.']);
    end
    % disp('calling cqt (default)');
    % tic;
    % 
    % t=toc;
    % disp(['time elapsed ' num2str(t) ' sec.']);

    disp('end trasfo');




    figure
    if LINEAR
        subplot(311)
        semilogx(f , smooth(20*log10(abs(H)),smth)   )
        title(gca,['linear ' nameFftWin ' nfft=' num2str(nfft)  ]);
    end
    if DEFAULT 
        subplot(312)
        semilogx(fcq , smooth(20*log10(abs(Hcq)),smth)  )
        title(gca,['cq default ' nameFftWin ' bpo=' num2str(bpo) ' th=' num2str(cqkernel.threshold) ]);
    end
    if BROWN
        subplot(313)
        semilogx(fcqbrown , smooth(20*log10(abs(Hcqbrown)),smth)  )
        title(gca,['cq brown ' nameFftWin ' bpo=' num2str(bpo) ' winlen=' num2str(winMaxLen) ' samples']);
    end
end



% figure
% subplot(211)
% semilogx(fcq , smooth(unwrap(angle((Hcq))),smth)  )
% 
% subplot(212)
% semilogx(f , smooth(unwrap(angle(mps(H))) ,smth) )
% 
% figure
% subplot(211)
% semilogx(fcq , smooth(gdcq,smth)  )
% 
% subplot(212)
% size(f)
% size(gd)
% %semilogx(f , smooth(gd,smth) )
% 

%  function [H  f groupDelay]=LOCALRESP_calcolateFourierIR(h,fs, average, NFFT, winname, lenwin, noverlap)
% %Mandatory: h fs..
% %NFFT=4096
% %noverlap=0.25*length(win)
% %win=hamming()
%      
% if nargin < 3 || isempty(average)     
%     average='vectorial';
% end
% if nargin < 4 || isempty(NFFT)     
%     NFFT=4096;
% end
% if nargin < 5 || isempty(winname)     
%     winname='hann';
% end
% if nargin < 6 || isempty(lenwin)     
%     lenwin=min(8192,2^nextpow2(length(h)/16));
% end
% if nargin < 7 || isempty(noverlap)
%     noverlap=lenwin*UTIL_getOptimalPercentOverlap(winname);
% end
% 
% groupDelay=smithDly(h,NFFT,fs);
% groupDelay(1)=groupDelay(2);
% groupDelay=groupDelay*(1000/fs);%Recalc grp dly in msec.
% 
% %%Numero di salti
% win=UTIL_getWindow(winname,lenwin);
% hopsize=lenwin-noverlap;
% nhops = 1 + floor((length(h)-lenwin)/hopsize);
% %disp(['siglen='  num2str(length(h)) ' nhop=' num2str(nhops) ' nhop*lenwin=' num2str(nhops*(lenwin-noverlap) )]);
% nlastwin=length(h)-nhops*(lenwin-noverlap);
% if nlastwin > 0    
%     H=zeros(nhops+1,floor(NFFT/2));
% else
%     H=zeros(nhops,floor(NFFT/2));
% end
% index_F=0;
% for n=1:nhops
%     if n==1
%         index_I=(n-1)*lenwin+1;
%     else
%         index_I=index_F-noverlap+1;
%     end
%     index_F=index_I+lenwin-1;
%     disp(['n=' num2str(n) ' low='  num2str(index_I) ' up=' num2str(index_F) ])
%     tH=fft(win.*h(index_I:index_F),NFFT);
%     H(n,:)=tH(1:floor(NFFT/2));
% end
% 
% if nlastwin > 0   
%     index_I=index_F+1-noverlap;
%     index_F=length(h);
%     disp(['lastwin low='  num2str(index_I) ' up=' num2str(index_F) ])
%     hh=h(index_I:index_F);
%     nzeros=lenwin-length(hh);
%     hh=[hh' zeros(1,nzeros)]';
%     size(hh)
%     size(win)
%     tH=fft(win.*hh,NFFT); 
%     H(n+1,:)=tH(1:floor(NFFT/2));
% end
% 
% tempH=H;
% if strcmp(average,'rms')
%     H=UTIL_rmsSpectAvg(H);
% else
%     H=UTIL_vectSpectAvg(H);
% end
% 
% f=linspace(0,fs/2,length(H));
% 
% %if nargout==0
%     figure
%     subplot(311)
%     clims=[ min(20*log10(abs(H))) max(20*log10(abs(H)))];
%     imagesc(20*log10(abs(tempH)),clims)
%     tit=['linear fft' winname ', avg ' average];
%     title(tit)
%     subplot(312)
%     waterfall(20*log10(abs(tempH)));
%     subplot(313)
%     plot(unwrap(angle(H)))
% %end
  