function varargout = GUI_endMeasure(varargin)
% GUI_ENDMEASURE M-file for GUI_endMeasure.fig
%      GUI_ENDMEASURE, by itself, creates a new GUI_ENDMEASURE or raises the existing
%      singleton*.
%
%      H = GUI_ENDMEASURE returns the handle to a new GUI_ENDMEASURE or the handle to
%      the existing singleton*.
%
%      GUI_ENDMEASURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_ENDMEASURE.M with the given input arguments.
%
%      GUI_ENDMEASURE('Property','Value',...) creates a new GUI_ENDMEASURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_endMeasure_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_endMeasure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_endMeasure

% Last Modified by GUIDE v2.5 26-Sep-2010 16:39:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_endMeasure_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_endMeasure_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI_endMeasure is made visible.
function GUI_endMeasure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_endMeasure (see VARARGIN)

% Choose default command line output for GUI_endMeasure
handles.output = hObject;
if nargin == 6
    handles.status=varargin{1};
    handles.generalParams=varargin{2};
    handles.audio=varargin{3};
   % handles.audioDevice=varargin{4};
else
    GUI_endMeasure_OutputFcn(hObject, eventdata, handles) ;
end

%setting fft parameters
handles.fftFigure=[];

%Set the supported fft
set(handles.popupmenuFFTType,'String', {'linear','defaultconstq','brownconstq'});
set(handles.popupmenuFFTType,'Value', 1); 
contents = get(handles.popupmenuFFTType,'String');
handles.generalParams.algorithm=contents{get(handles.popupmenuFFTType,'Value')};



%Default params for linear fft
handles.generalParams.linear.nfft=8192;
handles.generalParams.linear.fftWin='rectangular';
handles.generalParams.linear.average='vectorial';
handles.generalParams.linear.winlen=8192;
handles.generalParams.linear.percentOverlap=[];

%Default params for const Q fft
handles.generalParams.constq.bpo=16;
handles.generalParams.constq.average='vectorial';
handles.generalParams.constq.fftWin='rectangular';
handles.generalParams.constq.winlen=8192;
handles.generalParams.constq.percentOverlap=[];

%Default params for const Q fft brown method
handles.generalParams.constqbrown.bpo=16;
handles.generalParams.constqbrown.average='vectorial';
handles.generalParams.constqbrown.fftWin='rectangular';
handles.generalParams.constqbrown.percentOverlap=[];
handles.generalParams.constqbrown.winMaxLen=BROWN_getDefaultWinSize(handles.generalParams.sampleRate);
handles.generalParams.constqbrown.constWinLen=8192;%Altrimenti []

%Preparing the default const q kernel aviable
handles.generalParams.defaultKernel=[];
handles.generalParams.brownKernel=[];

%Init some field will be filled inside GUI_endMeasure.m
handles.response=[];
handles.newFFTPlot=false;
handles.pathFileName=[pwd '/'];
handles.fileName=[handles.generalParams.name '.meas' ];
set(handles.editPathFilename, 'String' , handles.pathFileName);
set(handles.editFileMeasureName, 'String', handles.fileName);

%setting IR response data
set(handles.editDynaRange, 'String', num2str(handles.generalParams.dinamicRange_dB))

%Setting initial time limit
handles.tmin=min(handles.generalParams.timeBase);
handles.tmax=max(handles.generalParams.timeBase);
set(handles.editStartTime, 'String', num2str(handles.tmin))
set(handles.editEndTime, 'String', num2str(handles.tmax))
guidata(hObject, handles);

%Set the max and min value for the selceted measure (default is the first)
[handles.absoluteMinValueH index]=max(-1.*handles.audio.h);
handles.absoluteMinValueH=-1.*handles.absoluteMinValueH;
handles.absoluteMinValueT=handles.generalParams.timeBase(index);
[handles.absoluteMaxValueH index]=max(handles.audio.h);
handles.absoluteMaxValueT=handles.generalParams.timeBase(index);
[handles.absoluteMaxValueHETC index]=max(handles.audio.hETC);
handles.absoluteMaxValueTETC=handles.generalParams.timeBase(index);
handles.detectedDelay=findDelay(handles.audio.stimulus,handles.audio.recordedStimulus,handles.generalParams.sampleRate,'mycorr');
setMinMaxTimeAndValue(hObject, handles)

%Calculating coherence
%Some parameters for calculating coherence
handles.coherenceParameters.nfft=handles.generalParams.linear.nfft;
handles.coherenceParameters.fs=handles.generalParams.sampleRate;
handles.coherence=[];
%populate combobox for the window types and phase rappresentation


set(handles.comboboxPhaseRapp,'String', {'wrapped','unwrapped','group delay'} );

%populate the combobox selector for measure data
set(handles.popupmenuSelectMeasure,'String', handles.audio.description);

%Set the datacursormodel on for this figure
datacursormode(handles.figure1);


handles.checkBoxMeasure=populateMeasure(hObject, eventdata, handles);
%guidata(hObject, handles);
plotMeasure(hObject, eventdata, handles)

%For speed up the algo
handles.response.H=[];
handles.response.f=[];
handles.response.grpDly=[];
handles.response.CONSTQH=[];
handles.response.CONSTQf=[];
handles.response.CONSTQgrpDly=[];
handles.response=calcFFT(handles);
%[handles.response handles.generalParams.defaultKernel handles.generalParams.brownKernel]=calcCONSTQFFT(handles);
%handles.coherence=calcolateCoherence(handles.audio.stimulus,handles.audio.recordedStimulus,handles.coherenceParameters, handles.detectedDelay);   
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_endMeasure wait for user response (see UIRESUME)
 uiwait(handles.figure1);

function setMinMaxTimeAndValue(hObject, handles)

%find index measure...
indexMeasure=get(handles.popupmenuSelectMeasure ,'Value');
index1=find(handles.generalParams.timeBase<=handles.tmin,'1', 'last');
index1=index1(end);
index2=find(handles.generalParams.timeBase>=handles.tmax,'1','first');
index2=index2(1);
indexDetected=find(handles.generalParams.timeBase==handles.detectedDelay(indexMeasure));

[localMinValueH index]=max(-1.*handles.audio.h(index1:index2,indexMeasure));
localMinValueH=-1.*localMinValueH;
localMinValueT=handles.generalParams.timeBase(index1+index-1);
[localMaxValueH index]=max(handles.audio.h(index1:index2,indexMeasure));
localMaxValueT=handles.generalParams.timeBase(index1+index-1);
[localMaxValueHETC index]=max(handles.audio.hETC(index1:index2,indexMeasure));
localMaxValueTETC=handles.generalParams.timeBase(index1+index-1);

set(handles.editPositionDetectedTime,'String', num2str(handles.detectedDelay(indexMeasure), '%6.6f' ));

if get(handles.checkboxETC,'Value')
    set(handles.editPositionMinValue,'String','' );
    set(handles.editPositionMaxValue,'String', num2str(handles.absoluteMaxValueHETC(indexMeasure), '%6.6f' ));
    set(handles.editPositionMaxTime,'String', num2str(handles.absoluteMaxValueTETC(indexMeasure) , '%6.6f'));
    set(handles.editPositionMinTime,'String', '' );
    set(handles.editLocalPositionMaxTime,'String', num2str(localMaxValueTETC , '%6.6f'));
    set(handles.editLocalPositionMinTime,'String', '');
    set(handles.editLocalPositionMinValue,'String', '');
    set(handles.editLocalPositionMaxValue,'String', num2str(localMaxValueHETC, '%6.6f' ));
    set(handles.editPositionDetectedValue,'String', num2str( handles.audio.hETC(indexDetected, indexMeasure) , '%6.6f' ));
else
    set(handles.editPositionMinValue,'String', num2str(handles.absoluteMinValueH(indexMeasure) , '%6.6f'));
    set(handles.editPositionMaxValue,'String', num2str(handles.absoluteMaxValueH(indexMeasure), '%6.6f' ));
    set(handles.editPositionMaxTime,'String', num2str(handles.absoluteMaxValueT(indexMeasure) , '%6.6f'));
    set(handles.editPositionMinTime,'String', num2str(handles.absoluteMinValueT(indexMeasure) , '%6.6f'));
    set(handles.editLocalPositionMaxTime,'String', num2str(localMaxValueT, '%6.6f' ));
    set(handles.editLocalPositionMinTime,'String', num2str(localMinValueT, '%6.6f' ));
    set(handles.editLocalPositionMinValue,'String', num2str(localMinValueH , '%6.6f'));
    set(handles.editLocalPositionMaxValue,'String', num2str(localMaxValueH , '%6.6f' ));
    set(handles.editPositionDetectedValue,'String', num2str( handles.audio.h(indexDetected, indexMeasure) , '%6.6f' ));
end
guidata(hObject, handles);
 
function color=getColor(index)
    color=['b' 'g' 'y' 'r' 'c' 'm' 'k'];
    if (index==length(color))
        color=color(length(color));
    else
        color=color(mod(index, length(color)));
    end

    
 
function checkBoxMeasure=populateMeasure(hObject, eventdata, handles)
[l ch]=size(handles.audio.recordedStimulus);
%data for rendering checkboxes
xpos=2;
width=120;
height=20;
totHeight=228;

if ch < 10
   stepy=20; 
else
   stepy=totHeight/ch;
end

%create check box for every measure
for n=1:ch
    checkBoxMeasure(n)=uicontrol(handles.uipanelMeasure ,'Style','checkbox',...
                'String',[ handles.audio.description(n) ],...
                'FontSize', 8, ...
                'Value',1,...
                'Tag', [ 'checkboxMeas' num2str(n)] , ...
                'ForegroundColor' ,   getColor(n) ,...
                'Callback', @checkboxMeasure_Callback, ...
                'Position',[ xpos totHeight-(n-1)*stepy width height]);
            
    mydata = guidata(checkBoxMeasure(n));
    mydata.handles=handles;
    guidata(checkBoxMeasure(n),mydata);
    
    %set(checkBoxMeasure(n),'handles',handles);
end          

function plotMeasure(hObject, eventdata, handles)

[l ch]=size(handles.audio.recordedStimulus);
index1=find(handles.generalParams.timeBase<=handles.tmin,'1', 'last');
index1=index1(end);
index2=find(handles.generalParams.timeBase>=handles.tmax,'1','first');
index2=index2(1);
tbase=handles.generalParams.timeBase(index1:index2);
ymax=0;
ymin=0;

selectedMeasure=get(handles.uipanelMeasure,'Children');
for n=1:length(selectedMeasure)
    index(n)=sscanf(char(get(selectedMeasure(n),'Tag')) ,'checkboxMeas%d');
end
cla(handles.axes1,'reset')
cla(handles.axes2,'reset')
nDrawed=0;
for n=1:ch
    if (n == 1 ) 
        set(handles.axes1, 'NextPlot', 'replace');
        set(handles.axes2, 'NextPlot', 'replace');       
    else
        set(handles.axes1, 'NextPlot', 'add');
        set(handles.axes2, 'NextPlot', 'add');
    end
    ind=index(n);
    if (get(selectedMeasure(n), 'Value'))     
        plot(handles.axes1,handles.generalParams.timeBase, handles.audio.recordedStimulus(:,ind), getColor(ind));
        if get(handles.checkboxETC,'Value')
            plot(handles.axes2,tbase, handles.audio.hETC(index1:index2,ind), getColor(ind));  
            tymax=max(handles.audio.hETC(index1:index2,ind));
            tymin=min(handles.audio.hETC(index1:index2,ind));
        else
            plot(handles.axes2,tbase, handles.audio.h(index1:index2,ind), getColor(ind));  
            tymax=max(handles.audio.h(index1:index2,ind));
            tymin=min(handles.audio.h(index1:index2,ind));
        end
        grid(handles.axes2, 'on');
        if tymax > ymax
            ymax=tymax;
        end
        if tymin <  ymin
            ymin=tymin;
        end
        nDrawed=nDrawed+1;
    end
end

%data for axes
if nDrawed > 0
    if ymax==ymin
        ymax=1.1*(ymax+0.1);
        ymin=1.1*ymin;
    else
        ymax=1.1*ymax;
        ymin=1.1*ymin;
    end
    ylim(handles.axes2, [ymin ymax]);
    ylim(handles.axes1, [-1.1 1.1]);
end

tmin=min(handles.generalParams.timeBase);
tmax=max(handles.generalParams.timeBase);
xlim(handles.axes1, [tmin tmax]);
xlabel(handles.axes1, 'times (s)')
ylabel(handles.axes1, 'Amplitude')
xlim(handles.axes2, [handles.tmin handles.tmax]);
xlabel(handles.axes2, 'times (s)')
ylabel(handles.axes2, 'Amplitude')
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_endMeasure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isstruct(handles)
    varargout{1} = handles.output;
    varargout{2} = handles.status;
    varargout{3} = handles.audio;
    varargout{4} = handles.generalParams;
    varargout{5} = [handles.pathFileName  handles.fileName];
    uiresume(handles.figure1)
else 
    varargout{1} = [];
    varargout{2} = 'cancelled';
    varargout{3} = [];
    varargout{4} = [];
    varargout{5} = [];
end

function checkboxMeasure_Callback(hObject,eventdata)
handles=guidata(hObject);
plotMeasure(hObject, eventdata, handles)

handles.fftFigure
if ishandle(handles.fftFigure)
    plotFFT(hObject, eventdata, handles);
end

function coherence=calcolateCoherence(x,y,coherenceParameters,dly)
disp('calcolateCoherence: called')
[l ch]=size(y);
for n=1:ch
    if nargin < 4
        [coherence(:,n).C coherence(:,n).f]=RESP_calcolateCoherence(x,y(:,n),coherenceParameters);    
    else
        [coherence(:,n).C coherence(:,n).f]=RESP_calcolateCoherence(x,y(:,n),coherenceParameters,dly(n));
    end
end  

function dly=findDelay(x,y,f,method)
[l ch]=size(y);
for n=1:ch
    dly(:,n)=RESP_findDelay(x,y(:,n),f,method);
end  
% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set(handles.editPathFilename, 'String' , handles.pathFileName);
%set(handles.editFileMeasureName, 'String', handles.fileName);
handles.fileName=get(handles.editFileMeasureName,'String');
nameFile=[handles.pathFileName  handles.fileName];
saveFile=true;
exist(nameFile,'file')
if  exist(nameFile,'file')
    retval = questdlg(['File ' handles.fileName ' exists. Do you want overwrite?'],'WARNING!!!!!!!!','Yes','No','No');
    if ~strcmp(retval,'Yes')
        saveFile=false;
    end
end

if saveFile
    handles.status='success';
    GUI_endMeasure_OutputFcn(handles, eventdata, handles) 
end

% --- Executes on button press in pushbuttonDiscard2.
function pushbuttonDiscard_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDiscard2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

retval = questdlg(['Do you want discard measure?'],'WARNING!!!!!!!!','Yes','No','No');
if strcmp(retval,'Yes')
    handles.status='discard';
    GUI_endMeasure_OutputFcn(handles, eventdata, handles) 
end

function editSavePath_Callback(hObject, eventdata, handles)
% hObject    handle to editSavePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSavePath as text
%        str2double(get(hObject,'String')) returns contents of editSavePath as a double


% --- Executes during object creation, after setting all properties.
function editSavePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSavePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonChangePath.
function pushbuttonChangePath_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonChangePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% [handles.fileName handles.pathfileName ] = uiputfile({'*.meas','All measure files';  },'Save measure ', [handles.pathfileName  handles.fileName]);
% set(handles.editSavePath, 'String' , [handles.pathfileName  handles.fileName]);

handles.pathFilename = uigetdir(handles.pathFileName,'Select a dir...');
set(handles.editPathFilename, 'String' , handles.pathFileName);
guidata(hObject, handles);

% --- Executes on button press in pushbuttonDisplayFFT.
function pushbuttonDisplayFFT_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDisplayFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Verify if it's a valid handles. If newFFTPlot is signed open a new figure,
%else close current figure
if ~isempty(handles.fftFigure) && ishandle (handles.fftFigure) && ~handles.newFFTPlot
    close(handles.fftFigure) 
    handles.fftFigure=[];
else 
    %new figure, in this way remove the handle to the current figure
    handles.fftFigure=[];
end
set(handles.checkboxNewFFTPlot ,'Value', 0 )
handles.newFFTPlot=false;
handles.fftFigure=plotFFT(hObject, eventdata, handles);
guidata(hObject, handles);


%call this function if you want recalc just the fft with constant Q
function [response defaultKernel brownKernel]=calcCONSTQFFT(handles)
disp('calcCONSTQFFT called');
defaultKernel=handles.generalParams.defaultKernel;
brownKernel=handles.generalParams.brownKernel;


isBrown=false;
if (strcmp('brownconstq',handles.generalParams.algorithm))
    isBrown=true;
end
percOverlap=[];
winlen=[];
average=[];
if (isBrown)
    percOverlap=handles.generalParams.constqbrown.percentOverlap;
    average=handles.generalParams.constqbrown.average;
    if isempty(brownKernel)
        disp('calcCONSTQFFT: recalc brown constq') 
        %(sr, 'bpo', bpo, 'namefftwin',nameFftWin, 'winmaxlen',
        %winMaxLen,'msgbox',true,'algorithm','brown','constwinlen',BROWNWINDOWSLENGTH);
        cqkernel=CONSTQ_getKernel(handles.generalParams.sampleRate, ...
            'bpo',handles.generalParams.constqbrown.bpo,...
            'namefftwin', handles.generalParams.constqbrown.fftWin,...
            'winmaxlen', handles.generalParams.constqbrown.winMaxLen, ...
            'constwinlen', handles.generalParams.constqbrown.constWinLen, ...
            'algorithm', 'brown',...
            'msgbox' , true);
    else
        disp('calcCONSTQFFT: don''t need to recalc brown constq')
        cqkernel=brownKernel;
    end
elseif (~isBrown) 
    percOverlap=handles.generalParams.constq.percentOverlap;
    winlen=handles.generalParams.constq.winlen;
    average=handles.generalParams.constq.average;
    if isempty(defaultKernel) 
        disp('calcCONSTQFFT: recalc default constq')
        %(sr, 'bpo', bpo, 'namefftwin',nameFftWin, 'winmaxlen',
        %winMaxLen,'msgbox',true,'algorithm','brown','constwinlen',BROWNWINDOWSLENGTH);
        cqkernel=CONSTQ_getKernel(handles.generalParams.sampleRate, ...
            'bpo',handles.generalParams.constq.bpo,...
            'namefftwin', handles.generalParams.constq.fftWin,...
            'algorithm', 'default',...
            'msgbox' , true);
    else
        disp('calcCONSTQFFT: don''t need to recalc default constq')
        cqkernel=defaultKernel;
    end
else
    warning('calcCONSTQFFT: non dovrebbe mai passare di qua!!');
end
[l ch]=size(handles.audio.recordedStimulus);
response=handles.response;
response.CONSTQH=[];
response.CONSTQf=[];
response.CONSTQgrpDly=[];


index1=find(handles.generalParams.timeBase<=handles.tmin,'1', 'last');
index1=index1(end);
index2=find(handles.generalParams.timeBase>=handles.tmax,'1','first');
index2=index2(1);

for n=1:ch      
        [response.CONSTQH(:,n) response.CONSTQf response.CONSTQgrpDly(:,n)]=RESP_calcolateFourierIR_CONSTQ(handles.audio.h(index1:index2,n), ... 
                                                                            cqkernel,...
                                                                          	average,...
                                                                            winlen,...
                                                                            percOverlap/100);                                                                                                                                                         
end

if isBrown
    handles.generalParams.brownKernel=cqkernel;
else
    handles.generalParams.defaultKernel=cqkernel;
end
    


%call this function if you want recalc just the fft
function response=calcFFT(handles)
%Chiede in ingrsso Handles
%Ritorna, a seconda del caso una terna trasformata,freq,grp dly, CONSTQ o
%scala lineare

disp('calcFFT called');
[l ch]=size(handles.audio.recordedStimulus);
response=handles.response;

response.H=[];
response.f=[];
response.grpDly=[];
    
index1=find(handles.generalParams.timeBase<=handles.tmin,'1', 'last');
index1=index1(end);
index2=find(handles.generalParams.timeBase>=handles.tmax,'1','first');
index2=index2(1);
for n=1:ch   
            %TODO: da recps recupero una versione a fase minima di h...
             %potrebbe essere un'idea però tutta da verificare....
%             [hh tmpH]=rceps(handles.audio.h(index1:index2,n));
%             tmpH=win.*tmpH;
            %tmpH=handles.audio.h(index1:index2,n);
          % RESP_calcolateFourierIR(h,fs, average, NFFT, winname, lenwin, noverlap)
            [response.H(:,n) response.f response.grpDly(:,n)]=RESP_calcolateFourierIR( handles.audio.h(index1:index2,n), ...
                                                      handles.generalParams.sampleRate, ...
                                                      handles.generalParams.linear.average, ...
                                                      handles.generalParams.linear.nfft,...
                                                      handles.generalParams.linear.fftWin,...
                                                      handles.generalParams.linear.winlen,...
                                                      handles.generalParams.linear.percentOverlap/100);      

             
             %response.H(:,n)=response.H(:,n)*exp(-1i*handles.detectedDelay(n));
end


function hFig=plotFFT(hObject, eventdata, handles)
constQ=false; %returns toggle state of checkboxConstQ
if strcmp('defaultconstq',handles.generalParams.algorithm) 
    disp('plotFFT: default constq')
    constQ=true;
    constqParams=handles.generalParams.constq;
elseif strcmp('brownconstq',handles.generalParams.algorithm)
    disp('plotFFT: brown constq')
    constqParams=handles.generalParams.constqbrown;
    constQ=true;
else
    disp('plotFFT: linear fft')
end
coherence=get(handles.checkboxCoherence,'Value'); %returns toggle state of checkboxCoherence


[l ch]=size(handles.audio.recordedStimulus);
if     isempty(handles.response) || (~constQ && (~isfield(handles.response,'H')       || isempty(handles.response.H)) )
        disp('plotFFT: going to call calcFFT')
        handles.response=calcFFT(handles);
elseif isempty(handles.response) || (constQ  && (~isfield(handles.response,'CONSTQH') || isempty(handles.response.CONSTQH)) )
        disp('plotFFT: going to call calcCONSTQFFT')
        handles.response=calcCONSTQFFT(handles);
else 
        disp('plotFFT: nothing to recalc')
end
%If i'm here with a ref for a figure i want to update the plot, then i
%close the plot for drawing a new one (an update procedure could be better
%but more complicated.
fftFigureOldPosition=[];
if ~isempty(handles.fftFigure) && ishandle (handles.fftFigure) 
    fftFigureOldPosition=get(handles.fftFigure,'Position');
    if ~handles.newFFTPlot
        close(handles.fftFigure) ;
    end
end
guidata(hObject, handles);

%disp(['plotFFT: coherence flag is: ' num2str(coherence) ' isempty(handles.coherence) is: ' num2str(isempty(handles.coherence))])
if coherence && isempty(handles.coherence)
    disp('plotFFT: going to call calcolateCoherence')
    handles.coherence=calcolateCoherence(handles.audio.stimulus,handles.audio.recordedStimulus,handles.coherenceParameters, handles.detectedDelay); 
end
    

%indexCh, the index of the channel selected for displaying the fft
selectedMeasure=get(handles.uipanelMeasure,'Children');
for n=1:length(selectedMeasure)
    indexCh(n)=sscanf(char(get(selectedMeasure(n),'Tag')) ,'checkboxMeas%d');
end



hFig=[];
labl={};
handles.smooth=str2double(get(handles.editSmooth,'String'));
if constQ
    tit=[handles.generalParams.name ' Time interval [' num2str(handles.tmin) ':' num2str(handles.tmax) '] sec. fs=' ...
         num2str(handles.generalParams.sampleRate) ' algo: ' handles.generalParams.algorithm ' bpo=' num2str(constqParams.bpo) ' ' constqParams.fftWin ' win,  average ' constqParams.average];
     if strcmp('brownconstq',handles.generalParams.algorithm)
         if isempty(constqParams.constWinLen)
            tit=[tit 'winMaxLen=' num2str(constqParams.winMaxLen)];
         else
            tit=[tit 'constWinLen=' num2str(constqParams.constWinLen)];
         end
     else
         tit=[tit ''];
     end
else
    tit=[handles.generalParams.name ' t=[' num2str(handles.tmin) ':' num2str(handles.tmax) '] sec. fs=' ...
         num2str(handles.generalParams.sampleRate) ' algo:' handles.generalParams.algorithm ' ' handles.generalParams.linear.fftWin ' win,  average ' handles.generalParams.linear.average];
end

if coherence 
    Hmax=0;
    Hmin=0;

    for n=1:ch
            if n==1;
                if constQ
                    Hmax=max(abs(handles.response.CONSTQH(:,n)));
                    Hmin=min(abs(handles.response.CONSTQH(:,n)));
                else
                    Hmax=max(abs(handles.response.H(:,n)));
                    Hmin=min(abs(handles.response.H(:,n)));
                end
            else   
                if constQ
                    tMax=max(abs(handles.response.CONSTQH(:,n)));
                    tMin=min(abs(handles.response.CONSTQH(:,n)));
                else
                    tMax=max(abs(handles.response.H(:,n)));
                    tMin=min(abs(handles.response.H(:,n)));
                   
                end
                 Hmax=max(Hmax,tMax);
                Hmin=min(Hmin,tMin);
            end

    end

    Hmax=20*log10(abs(Hmax));
    Hmin=20*log10(abs(Hmin));
end
contents = get(handles.comboboxPhaseRapp,'String');
graphType={'magnitude' , contents{get(handles.comboboxPhaseRapp,'Value')} } ; 

for n=1:ch
    
    if (get(selectedMeasure(n), 'Value'))  
        if isempty (labl)
            labl={ char(handles.audio.description{n}) } ;            
        else
            labl={ char(labl) , char(handles.audio.description{n}) } ;
        end
        disp(['plotFFT: ' char(handles.audio.description{n}) ])
        if coherence 
            txt=[ char(handles.audio.description{n}) ' cohr.' ];
            labl={ char(labl) ,  txt } ;
            Cxy=UTIL_rescaleCoherence(handles.coherence(:,n),[Hmin Hmax]);
            if constQ
                CxyQ=UTIL_coherenceLinearFREQToLog(Cxy , handles.response.CONSTQf);
            end
        end
        if isempty(hFig) || ~ishandle (hFig)
            if constQ
                if coherence 
                 hFig=DISP_fourierResponseCONSTQ(handles.response.CONSTQf, handles.response.CONSTQH(:,n), handles.response.CONSTQgrpDly(:,n),...
                    'Smooth', handles.smooth, ...
                    'TitleString' ,  tit, ...
                    'GraphType' , graphType, ...
                    'Coherence',  CxyQ, ...
                    'Color', getColor(n) ); 
                else
                 hFig=DISP_fourierResponseCONSTQ(handles.response.CONSTQf, handles.response.CONSTQH(:,n), handles.response.CONSTQgrpDly(:,n),...
                    'Smooth', handles.smooth, ...
                    'TitleString' ,  tit, ...
                    'GraphType' , graphType, ...
                    'Color', getColor(n) ); 
                end
            else
                if coherence 
                    hFig=DISP_fourierResponse(handles.response.f , handles.response.H(:,n) , handles.response.grpDly(:,n),...
                        'Color', getColor(n) , ...
                        'Smooth', handles.smooth, ...
                        'TitleString' ,  tit, ...
                        'Coherence',  Cxy, ...
                        'GraphType' , graphType);
                else
                    hFig=DISP_fourierResponse(handles.response.f , handles.response.H(:,n) , handles.response.grpDly(:,n),...
                        'Color', getColor(n) , ...
                        'Smooth', handles.smooth, ...
                        'TitleString' ,  tit, ...
                        'GraphType' , graphType);
                end
            end
        else
            if constQ
                if coherence 
                 hFig=DISP_fourierResponseCONSTQ(handles.response.CONSTQf, handles.response.CONSTQH(:,n), handles.response.CONSTQgrpDly(:,n),...
                    'Color', getColor(n), ...
                    'Smooth', handles.smooth, ...
                    'TitleString' ,  tit, ...
                    'GraphType' , graphType, ...
                    'Coherence',  CxyQ, ...
                    'Figure', hFig);
                else
                 hFig=DISP_fourierResponseCONSTQ(handles.response.CONSTQf, handles.response.CONSTQH(:,n), handles.response.CONSTQgrpDly(:,n),...
                    'Color', getColor(n), ...
                    'Smooth', handles.smooth, ...
                    'TitleString' ,  tit, ...
                    'GraphType' , graphType, ...
                    'Figure', hFig);
                end
            else
                 if coherence 
                    hFig=DISP_fourierResponse(handles.response.f , handles.response.H(:,n) , handles.response.grpDly(:,n),...
                        'Color', getColor(n) , ...
                        'Smooth', handles.smooth, ...
                        'TitleString' ,  tit, ...
                        'Coherence',    Cxy  , ...
                        'GraphType' , graphType, ...
                        'Figure', hFig );
                else
                    hFig=DISP_fourierResponse(handles.response.f , handles.response.H(:,n) , handles.response.grpDly(:,n),...
                        'Color', getColor(n) , ...
                        'Smooth', handles.smooth, ...
                        'TitleString' ,  tit, ...
                        'GraphType' , graphType, ...
                        'Figure', hFig );
                 end                    
            end
        end
    end
end 

%reposition figure
if ~isempty(fftFigureOldPosition) 
    set(handles.fftFigure,'Position',fftFigureOldPosition);
end
guidata(hObject, handles);

%ACCROCHISSIMO!!!! Per aggiungere degli assi alla figura. TODO: non
%funziona una cipaa!!!
if ~isempty(hFig) 
    chAxes=get(hFig,'Child');
    if ~isempty(chAxes) 
        legend(chAxes(1),labl,'FontSize',8)
    end
end

if handles.newFFTPlot
    hFig=handles.fftFigure;
end
set(handles.checkboxNewFFTPlot ,'Value', 0 )
handles.newFFTPlot=false;


% --- Executes on button press in checkboxCoherence.
function checkboxCoherence_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxCoherence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if get(hObject,'Value') 
%     handles.coherence=calcolateCoherence(handles.audio.stimulus,handles.audio.recordedStimulus,handles.coherenceParameters);   
% end

if ishandle (handles.fftFigure)
    plotFFT(hObject, eventdata, handles);
end
guidata(hObject, handles);

function editEndTime_Callback(hObject, eventdata, handles)
% hObject    handle to editEndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEndTime as text
handles.tmax=str2double(get(hObject,'String')); %returns contents of editEndTime as a double
setMinMaxTimeAndValue(hObject, handles)
plotMeasure(hObject, eventdata, handles)
handles.response.CONSTQH=[];%Impose recalc in the next plot
handles.response.H=[];%Impose recalc in the next plot
if ishandle (handles.fftFigure)
    plotFFT(hObject, eventdata, handles);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editEndTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStartTime_Callback(hObject, eventdata, handles)
% hObject    handle to editStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartTime as text
handles.tmin=str2double(get(hObject,'String')); %returns contents of editStartTime as a double
setMinMaxTimeAndValue(hObject, handles)
plotMeasure(hObject, eventdata, handles)
handles.response.CONSTQH=[];%Impose recalc in the next plot
handles.response.H=[];%Impose recalc in the next plot
if ishandle (handles.fftFigure)
    plotFFT(hObject, eventdata, handles);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editStartTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkboxETC.
function checkboxETC_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxETC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setMinMaxTimeAndValue(hObject, handles)
plotMeasure(hObject, eventdata, handles)


% --- Executes on selection change in popupmenuDynaRange.
function popupmenuDynaRange_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuDynaRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuDynaRange contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuDynaRange


% --- Executes during object creation, after setting all properties.
function popupmenuDynaRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuDynaRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDynaRange_Callback(hObject, eventdata, handles)
% hObject    handle to editDynaRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[l ch]=size(handles.audio.recordedStimulus);
handles.generalParams.dinamicRange_dB=str2double(get(hObject,'String'));
for n=1:ch
    handles.audio.h(:,n)=RESP_getIR(handles.audio.stimulus, ...
                                 handles.audio.recordedStimulus(:,n), ...
                                 handles.generalParams.dinamicRange_dB);    
    handles.audio.hETC(:,n)=20*log10(abs(hilbert(handles.audio.h(:,n))));        
end
plotMeasure(hObject, eventdata, handles)
handles.response.CONSTQH=[];%Impose recalc in the next plot
handles.response.H=[];%Impose recalc in the next plot
if ishandle (handles.fftFigure)
    plotFFT(hObject, eventdata, handles);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editDynaRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDynaRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxNewFFTPlot.
function checkboxNewFFTPlot_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxNewFFTPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxNewFFTPlot
handles.newFFTPlot=get(hObject,'Value');
guidata(hObject, handles);



function editSmooth_Callback(hObject, eventdata, handles)
% hObject    handle to editSmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSmooth as text
if ishandle (handles.fftFigure)
    handles.smooth=str2double(get(hObject,'String'));
    plotFFT(hObject, eventdata, handles);
end
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function editSmooth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function editPathFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)



function editFileName_Callback(hObject, eventdata, handles)
% hObject    handle to editFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFileName as text
%        str2double(get(hObject,'String')) returns contents of editFileName as a double
handles.fileName=get(hObject,'String');
set(handles.editFileName, 'String', handles.fileName);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editFileMeasureName_Callback(hObject, eventdata, handles)
% hObject    handle to editFileMeasureName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFileMeasureName as text
%        str2double(get(hObject,'String')) returns contents of editFileMeasureName as a double


% --- Executes during object creation, after setting all properties.
function editFileMeasureName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFileMeasureName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPathFilename_Callback(hObject, eventdata, handles)
% hObject    handle to editPathFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPathFilename as text
%        str2double(get(hObject,'String')) returns contents of editPathFilename as a double

handles.pathFileName=get(hObject,'String');
guidata(hObject, handles);




function editPositionMaxTime_Callback(hObject, eventdata, handles)
% hObject    handle to editPositionMaxTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPositionMaxTime as text
%        str2double(get(hObject,'String')) returns contents of editPositionMaxTime as a double


% --- Executes during object creation, after setting all properties.
function editPositionMaxTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPositionMaxTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPositionMaxValue_Callback(hObject, eventdata, handles)
% hObject    handle to editPositionMaxValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPositionMaxValue as text
%        str2double(get(hObject,'String')) returns contents of editPositionMaxValue as a double


% --- Executes during object creation, after setting all properties.
function editPositionMaxValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPositionMaxValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPositionMinTime_Callback(hObject, eventdata, handles)
% hObject    handle to editPositionMinTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPositionMinTime as text
%        str2double(get(hObject,'String')) returns contents of editPositionMinTime as a double


% --- Executes during object creation, after setting all properties.
function editPositionMinTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPositionMinTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPositionMinValue_Callback(hObject, eventdata, handles)
% hObject    handle to editPositionMinValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPositionMinValue as text
%        str2double(get(hObject,'String')) returns contents of editPositionMinValue as a double


% --- Executes during object creation, after setting all properties.
function editPositionMinValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPositionMinValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLocalPositionMaxTime_Callback(hObject, eventdata, handles)
% hObject    handle to editLocalPositionMaxTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLocalPositionMaxTime as text
%        str2double(get(hObject,'String')) returns contents of editLocalPositionMaxTime as a double


% --- Executes during object creation, after setting all properties.
function editLocalPositionMaxTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLocalPositionMaxTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLocalPositionMaxValue_Callback(hObject, eventdata, handles)
% hObject    handle to editLocalPositionMaxValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLocalPositionMaxValue as text
%        str2double(get(hObject,'String')) returns contents of editLocalPositionMaxValue as a double


% --- Executes during object creation, after setting all properties.
function editLocalPositionMaxValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLocalPositionMaxValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLocalPositionMinTime_Callback(hObject, eventdata, handles)
% hObject    handle to editLocalPositionMinTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLocalPositionMinTime as text
%        str2double(get(hObject,'String')) returns contents of editLocalPositionMinTime as a double


% --- Executes during object creation, after setting all properties.
function editLocalPositionMinTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLocalPositionMinTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLocalPositionMinValue_Callback(hObject, eventdata, handles)
% hObject    handle to editLocalPositionMinValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLocalPositionMinValue as text
%        str2double(get(hObject,'String')) returns contents of editLocalPositionMinValue as a double


% --- Executes during object creation, after setting all properties.
function editLocalPositionMinValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLocalPositionMinValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuSelectMeasure.
function popupmenuSelectMeasure_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSelectMeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuSelectMeasure contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSelectMeasure
setMinMaxTimeAndValue(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuSelectMeasure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSelectMeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in comboboxPhaseRapp.
function comboboxPhaseRapp_Callback(hObject, eventdata, handles)
% hObject    handle to comboboxPhaseRapp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ishandle (handles.fftFigure)   
    plotFFT(hObject, eventdata, handles);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function comboboxPhaseRapp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboboxPhaseRapp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuFFTType.
function popupmenuFFTType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuFFTType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

olgAlgo=handles.generalParams.algorithm;
contents = get(hObject,'String');
handles.generalParams.algorithm=contents{get(hObject,'Value')};
disp(['popupmenuFFTType_Callback: select algo ' handles.generalParams.algorithm])
if ~strcmp(olgAlgo,handles.generalParams.algorithm)
%     if strcmp('linear',handles.generalParams.algorithm)
%         handles.response=calcFFT(handles);
%     else 
%         handles.response=calcCONSTQFFT(handles);
%     end
    if strcmp('defaultconstq',handles.generalParams.algorithm)
        handles.response.CONSTQH=[];
    elseif strcmp('brownconstq',handles.generalParams.algorithm)
        handles.response.CONSTQH=[];
    elseif ~strcmp('linear',handles.generalParams.algorithm)
        warning('popupmenuFFTType_Callback: unrecognizes algorithm');
    end
    guidata(hObject, handles);
    if ishandle (handles.fftFigure)   
        plotFFT(hObject, eventdata, handles);
    end
end

% --- Executes during object creation, after setting all properties.
function popupmenuFFTType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuFFTType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonFFTParams.
function pushbuttonFFTParams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFFTParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
algo=handles.generalParams.algorithm;
if (strcmp(algo,'linear'))
    oldParams=handles.generalParams.linear;
    [h newParams]=GUI_linearFFTOption(oldParams);
    if ~isempty(h) && ishandle(h)
        close(h);
        if isempty(newParams)
            handles.generalParams.linear=oldParams;
        else
            handles.generalParams.linear=newParams;
            handles.response.H=[];%Impose recalc in the next plot
            if ishandle (handles.fftFigure)
                plotFFT(hObject, eventdata, handles);
            end
        end
    end
  %Memorizza vecchia struttura dati linear
  %chiama GUI con vecchia struttura dati,
  %se differenze tra nuova e vecchia chiama...
elseif (strcmp(algo,'defaultconstq'))
    oldParams=handles.generalParams.constq;
    [h newParams]=GUI_constqOption(oldParams);
    if ~isempty(h) && ishandle(h)
        close(h);
        if isempty(newParams)
            handles.generalParams.constq=oldParams;
        else
            handles.generalParams.constq=newParams;
            handles.generalParams.defaultKernel=[];
            handles.response.CONSTQH=[];%Impose recalc in the next plot
            if ishandle (handles.fftFigure)
                plotFFT(hObject, eventdata, handles);
            end
        end
    end
elseif (strcmp(algo,'brownconstq'))
    oldParams=handles.generalParams.constqbrown;
    [h newParams]=GUI_constqBrownOption(oldParams);
    if ~isempty(h) && ishandle(h)
        close(h);
        if isempty(newParams)
            handles.generalParams.constqbrown=oldParams;
        else
            handles.generalParams.constqbrown=newParams;
            handles.generalParams.brownKernel=[];
            handles.response.CONSTQH=[];%Impose recalc in the next plot
            if ishandle (handles.fftFigure)
                plotFFT(hObject, eventdata, handles);
            end
        end
    end
else
    warning('pushbuttonFFTParams_Callback: non dovrei mai essere qui!!')
end
guidata(hObject, handles);



function editPositionDetectedTime_Callback(hObject, eventdata, handles)
% hObject    handle to editPositionDetectedTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPositionDetectedTime as text
%        str2double(get(hObject,'String')) returns contents of editPositionDetectedTime as a double


% --- Executes during object creation, after setting all properties.
function editPositionDetectedTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPositionDetectedTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPositionDetectedValue_Callback(hObject, eventdata, handles)
% hObject    handle to editPositionDetectedValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPositionDetectedValue as text
%        str2double(get(hObject,'String')) returns contents of editPositionDetectedValue as a double


% --- Executes during object creation, after setting all properties.
function editPositionDetectedValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPositionDetectedValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
