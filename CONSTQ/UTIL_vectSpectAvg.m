function So=UTIL_vectSpectAvg(Si)


So=zeros(size(Si,2),1);
for n=1:size(Si,1)
    So=So+Si(n,:)';
end
So=So./size(Si,1);