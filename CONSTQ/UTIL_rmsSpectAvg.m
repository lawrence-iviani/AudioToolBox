function So=UTIL_rmsSpectAvg(Si)

%media puntuale... TODO: fase????
So=zeros(size(Si,2),1);
Sph=zeros(size(Si,2),1);
for n=1:size(Si,1)
    So=abs(So)+(abs(Si(n,:)').^2);
    Sph=Sph+angle(Si(n,:)');
end
So=sqrt(So).*exp(i*Sph);
So=So./size(Si,1);

