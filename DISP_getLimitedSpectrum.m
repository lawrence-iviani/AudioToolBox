function [f H]=DISP_getLimitedSpectrum(f,H,lowF,hiF)
%Limit the band spectrum between flowF-hiF Hz, cut off freq and H response outside
%this range.

        index=find(f > lowF);
        f=f(index);
        if ~isempty(H)
            H=H(index);
        end
        index=find(f <hiF);
        f=f(index);
        if ~isempty(H)
            H=H(index)';
        end