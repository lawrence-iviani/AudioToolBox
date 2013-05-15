actualPath=pwd;

%Aggingo la libreria playrec.mexmaci e alcune cosine utili in playrec
%scripts
path(path,pwd);
path(path,'./playrec_scripts/');
if ismac
   disp('Find a mac'); 
   path(path,'./playrec_scripts/mac/');
elseif ispc
   disp('Find a win pc') 
   path(path,'./playrec_scripts/win/');
elseif isunix
    disp('Find a unix system') 
    path(path,'./playrec_scripts/unix/');
else
   error('System not supported. exit'); 
end
path(path,'./GUI/');
path(path,'./OTHERS/');
path(path,'./CONSTQ/');
path(path,'./NTH/');

