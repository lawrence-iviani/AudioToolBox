function [ CxyLOG ] = UTIL_coherenceLinearFREQToLog(Cxy, logFreq )
%UTIL_coherenceLinearFREQToLog Summary of this function goes here
%   Detailed explanation goes here
C=Cxy.C;
linFreq=Cxy.f;
CxyLOG=Cxy;
    for n=1:length(logFreq)
        indL=find (linFreq<=logFreq(n),1,'last');
        indU=find (linFreq>=logFreq(n),1,'first');
        CLogQ(n)= UTIL_interpolate(logFreq(n) ,C(indU), C(indL),linFreq(indU), linFreq(indL));
    end    
CxyLOG.C=CLogQ;
CxyLOG.f=logFreq;