function Cxy=UTIL_rescaleCoherence(coherence,H)
% Used to render correctly the coherence (0..1) inside a graph with H.

Cxy=coherence;
Hmax=max(H);
Hmin=min(H);
%disp(['UTIL_rescaleCoherence: Hmax=' num2str(Hmax)   ' Hmin=' num2str(Hmin) ])
Cmax=max(coherence.C);
Cmin=min(coherence.C);
%disp(['UTIL_rescaleCoherence: Cmax=' num2str(Cmax)   ' Cmin=' num2str(Cmin) ])
m=(Hmax-Hmin)/(Cmax-Cmin);
q=Hmax-m*Cmax;

Cxy.C=m*coherence.C+q;
%disp(['UTIL_rescaleCoherence: new  Cmax=' num2str(max(Cxy.C))   ' new Cmin=' num2str(min(Cxy.C)) ])