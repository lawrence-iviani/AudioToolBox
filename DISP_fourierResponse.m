function fig=DISP_fourierResponse(freq ,H , grpDly , varargin)
% Display the fourier response H,
% freq: the frequency axes
% grpDly: the group delay of the transformation
% Can plot the coherence if requested and it's possible t set some
% parameters of rendering

fig=[];
Cxy=[];
SMOOTH=5;
titleString='No title';
color='m';
graphType={'magnitude' , 'wrapped',  'unwrapped' };

for n = 1: length(varargin)
    if  (strcmp(varargin{n}, 'Smooth') == 1)
        SMOOTH = varargin{n + 1};
        n = n + 1;
    elseif (strcmp(varargin{n}, 'TitleString') == 1)
        titleString=varargin{n + 1};
        n = n + 1;
    elseif (strcmp(varargin{n}, 'Color') == 1)
        color=varargin{n + 1};
        n = n + 1;
    elseif (strcmp(varargin{n}, 'GraphType') == 1)
        graphType=varargin{n + 1};
        n = n + 1;
    elseif (strcmp(varargin{n}, 'Figure') == 1)
        fig=varargin{n + 1};
        n = n + 1;
    elseif (strcmp(varargin{n}, 'Coherence') == 1)
        Cxy=varargin{n + 1};
        n = n + 1;
    end
end

NFFT=(length(freq)-1)*2;
%preparing for display axes
magnitudeAxes.index=0;
unwrappedAxes.index=0;
wrappedAxes.index=0;
groupdelayAxes.index=0;
naxes=0;
for n=1:length(graphType)
    gt=char(graphType{n});
    if strcmp(gt,'magnitude')
        naxes=naxes+1;
        magnitudeAxes.index=naxes;
    elseif strcmp(gt,'unwrapped')
        naxes=naxes+1;
        unwrappedAxes.index=naxes;
    elseif strcmp(gt,'wrapped')
        naxes=naxes+1;
        wrappedAxes.index=naxes;
    elseif strcmp(gt,'groupdelay') || strcmp(gt,'group delay')
        naxes=naxes+1;
        groupdelayAxes.index=naxes;
    end    
end

if naxes==0
    fig=[];
    return
end

%Creating a new figure if necessary..
if isempty(fig) || ~ishandle(fig)
    fig=figure;
    for n=naxes:-1:1
         set(fig,'CurrentAxes',axes() );
         hAx=get(fig,'CurrentAxes');
         set(hAx,'Tag', [ 'measure' num2str(n) ]);
    end
    holdAxes=false;
else
    holdAxes=true;
end
    
set(fig,'Name' ,[ titleString ':  nfft=' num2str(NFFT)  ' Smooth=' num2str(SMOOTH) ]);
top=0.03;
bottom=0.07;
left=0.05;
width=1-2*left;
stepy=0.135;
totHeight=1-(naxes-1)*stepy-top-bottom;
height=totHeight/naxes;

childAx=get(fig,'Child');
for n=1:naxes
        pos=[left (n-1)*(stepy+height)+bottom width height];
        set( childAx(naxes-n+1), 'Position' , pos);
end
%Limiting frequency between 16-20000 Hz

[f H]=DISP_getLimitedSpectrum(freq,H,16,20000);
[f grpDly]=DISP_getLimitedSpectrum(freq,grpDly,16,20000);
if ~isempty(Cxy)
    [Cxy.f Cxy.C]=DISP_getLimitedSpectrum(Cxy.f,Cxy.C,16,20000);
end

% Plot the magnitude spectrum of the linear response term.
if magnitudeAxes.index 
    ax=childAx(magnitudeAxes.index );
    if holdAxes
        set(ax, 'NextPlot', 'add');
    else
        set(ax, 'NextPlot', 'replace');
    end
    PSD_H=20*log10(abs(H));
    semilogx(ax,f,smooth(PSD_H, SMOOTH),color  )
    if ~isempty(Cxy)
        oldNextPlot=get(ax, 'NextPlot');
        set(ax, 'NextPlot', 'add');
        semilogx(ax,Cxy.f,Cxy.C,[ color  '--'] )
        set(ax, 'NextPlot', oldNextPlot);
    end
    if ~holdAxes
        title(ax,' Magnitude' );
        xlabel(ax,'Frequency [Hz]')
        ylabel(ax,'Magnitude [dB]');
        grid (ax,'on')
    end
end

% Plot the minimum phase portion of the linear response term.
Fhminphase = mps(H);    % min phase version
if unwrappedAxes.index 
    ax=childAx(unwrappedAxes.index );
    if holdAxes
        set(ax, 'NextPlot', 'add');
    else
        set(ax, 'NextPlot', 'replace');
    end
    semilogx(ax,f,smooth(rad2deg(unwrap(angle(Fhminphase))),SMOOTH),color)
    if ~holdAxes
        
        title(ax,'Unwrapped phase');
        xlabel(ax,'Frequency [Hz]')
        ylabel(ax,'Angle [deg]')
        grid (ax,'on')
    end
end

if wrappedAxes.index 
    ax=childAx(wrappedAxes.index );
    if holdAxes
        set(ax, 'NextPlot', 'add');
    else
        set(ax, 'NextPlot', 'replace');
    end
    semilogx(ax,f,smooth(rad2deg(angle(Fhminphase)),SMOOTH),color)
    if ~holdAxes      
        title(ax,'Wrapped phase');
        xlabel(ax,'Frequency [Hz]')
        ylabel(ax,'Angle [deg]')
        grid (ax,'on')
    end
end

if groupdelayAxes.index
    ax=childAx(groupdelayAxes.index );
    if holdAxes
        set(ax, 'NextPlot', 'add');
    else
        set(ax, 'NextPlot', 'replace');
    end
    semilogx(ax,f,smooth(grpDly,SMOOTH),color)
    if ~holdAxes
        
        title(ax,'Group delay');
        xlabel(ax,'Frequency [Hz]')
        ylabel(ax,'Group delay [ms]')
        grid (ax,'on')
    end
end

