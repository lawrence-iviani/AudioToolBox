function varargout = GUI_DUALCHANNELFFT_FFTAnalyzerParams_export(varargin)
% GUI_DUALCHANNELFFT_FFTAnalyzerParams_export M-file for GUI_DUALCHANNELFFT_FFTAnalyzerParams_export.fig
%      GUI_DUALCHANNELFFT_FFTAnalyzerParams_export, by itself, creates a new GUI_DUALCHANNELFFT_FFTAnalyzerParams_export or raises the existing
%      singleton*.
%
%      H = GUI_DUALCHANNELFFT_FFTAnalyzerParams_export returns the handle to a new GUI_DUALCHANNELFFT_FFTAnalyzerParams_export or the handle to
%      the existing singleton*.
%
%      GUI_DUALCHANNELFFT_FFTAnalyzerParams_export('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DUALCHANNELFFT_FFTAnalyzerParams_export.M with the given input arguments.
%
%      GUI_DUALCHANNELFFT_FFTAnalyzerParams_export('Property','Value',...) creates a new GUI_DUALCHANNELFFT_FFTAnalyzerParams_export or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_DUALCHANNELFFT_FFTAnalyzerParams_export_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_DUALCHANNELFFT_FFTAnalyzerParams_export_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_DUALCHANNELFFT_FFTAnalyzerParams_export

% Last Modified by GUIDE v2.5 16-Jan-2011 22:10:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_DUALCHANNELFFT_FFTAnalyzerParams_export_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_DUALCHANNELFFT_FFTAnalyzerParams_export_OutputFcn, ...
                   'gui_LayoutFcn',  @GUI_DUALCHANNELFFT_FFTAnalyzerParams_export_LayoutFcn, ...
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


% --- Executes just before GUI_DUALCHANNELFFT_FFTAnalyzerParams_export is made visible.
function GUI_DUALCHANNELFFT_FFTAnalyzerParams_export_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_DUALCHANNELFFT_FFTAnalyzerParams_export (see VARARGIN)

% Choose default command line output for GUI_DUALCHANNELFFT_FFTAnalyzerParams_export
handles.output = hObject;
handles.changed=false;
if nargin == 4 && ~isempty(varargin{1})
    handles.params = varargin{1};
else 
    handles.params=DUALCHANNELFFT_analyzerDefaultParams( 'FFT', 44100 );
end
handles.params
%Settinf fmin e fmax
set(handles.editFreqMin,'String', num2str(handles.params.fmin));
set(handles.editFreqMax,'String', num2str(handles.params.fmax));


%Setting the NFFT value
handles.NFFTReference=[512 1024 2048 4096 8192 16384 32768];
set(handles.popupmenuNFFT,'String', num2cell(handles.NFFTReference));
indFFT=find(handles.NFFTReference==handles.params.NFFT);
if indFFT
    set(handles.popupmenuNFFT,'Value', indFFT);  
else
    set(handles.popupmenuNFFT,'Value', 4); 
end

% handles.winlenReference=[-1 512 1024 2048 4096 8192 16384 32768];
% set(handles.popupmenuWinLen,'String', num2cell(handles.winlenReference));
%%If isempty winlen transform in -1, jut for compatubility with the gui,
%in the output function -1 meand null value
% if isempty(handles.params.winlen) 
%     handles.params.winlen=-1;
% end
% indWinLen=find(handles.winlenReference==handles.params.winlen);
% if indWinLen
%     set(handles.popupmenuWinLen,'Value', indWinLen);  
% else
%     set(handles.popupmenuWinLen,'Value', 1); 
% end


handles.percentOverlapReference=[-1 0 25 50 75]; 
set(handles.popupmenuPercentOverlap,'String', num2cell(handles.percentOverlapReference));


%%If isempty noverlap transform in -1, jut for compatubility with the gui,
%in the output function -1 meand null value
if isempty(handles.params.percentOverlap) 
    handles.params.percentOverlap=-1;
end
indPercentOverlap=find(handles.percentOverlapReference==handles.params.percentOverlap);
if indPercentOverlap
    set(handles.popupmenuPercentOverlap,'Value', indPercentOverlap);  
else
    set(handles.popupmenuPercentOverlap,'Value', 1); 
end


%populate combobox for the window types 
set(handles.popupmenuWindow,'String',UTIL_getWindow())
contents = get(handles.popupmenuWindow,'String');
indWin=1;
for n=1:length(contents)
    if strcmp(contents(n),handles.params.win)
        indWin=n;
        break;
    end
end
set(handles.popupmenuWindow,'Value', indWin); 


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_DUALCHANNELFFT_FFTAnalyzerParams_export wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_DUALCHANNELFFT_FFTAnalyzerParams_export_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isstruct(handles)
    varargout{1} = handles.output;
    if handles.changed
        if handles.params.percentOverlap==-1
            handles.params.percentOverlap=[];
        end
        %if handles.params.winlen==-1
        %    handles.params.winlen=[];
        %end
        varargout{2} = handles.params;
    else
        varargout{2} = [];
    end
    uiresume(handles.figure1)
else 
    varargout{1} = [];
    varargout{2} = [];
end

% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_DUALCHANNELFFT_FFTAnalyzerParams_export_OutputFcn(handles, eventdata, handles); 

% --- Executes on selection change in popupmenuPercentOverlap.
function popupmenuPercentOverlap_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPercentOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String') ;
handles.params.percentOverlap=str2num(contents{get(hObject,'Value')});
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuPercentOverlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuPercentOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuWinLen.
function popupmenuWinLen_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuWinLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuWinLen contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuWinLen
contents = get(hObject,'String') ;
handles.params.winlen=str2num(contents{get(hObject,'Value')});
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuWinLen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuWinLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuWindow.
function popupmenuWindow_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String') ;
handles.params.win=contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuNFFT.
function popupmenuNFFT_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuNFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String') ;
handles.params.NFFT=str2num(contents{get(hObject,'Value')});
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuNFFT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuNFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function popupmenuNFFT_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuNFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editFreqMin_Callback(hObject, eventdata, handles)
% hObject    handle to editFreqMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFreqMin as text
%        str2double(get(hObject,'String')) returns contents of editFreqMin as a double
contents = get(hObject,'String') ;
handles.params.fmin=str2double(contents{get(hObject,'Value')});
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editFreqMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFreqMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFreqMax_Callback(hObject, eventdata, handles)
% hObject    handle to editFreqMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String') ;
handles.params.fmax=str2double(contents{get(hObject,'Value')});
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editFreqMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFreqMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over popupmenuNFFT.


function popupmenuNFFT_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuNFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Creates and returns a handle to the GUI figure. 
function h1 = GUI_DUALCHANNELFFT_FFTAnalyzerParams_export_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end

appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', [], ...
    'taginfo', struct(...
    'figure', 2, ...
    'text', 11, ...
    'pushbutton', 2, ...
    'popupmenu', 6, ...
    'uipanel', 2, ...
    'edit', 3), ...
    'override', 0, ...
    'release', 13, ...
    'resize', 'none', ...
    'accessibility', 'callback', ...
    'mfile', 1, ...
    'callbacks', 1, ...
    'singleton', 1, ...
    'syscolorfig', 1, ...
    'blocking', 0, ...
    'lastSavedFile', '/media/mydata/matlab/AudioMeasureToolbox/GUI/GUI_DUALCHANNELFFT_FFTAnalyzerParams_export.m', ...
    'lastFilename', '/media/mydata/matlab/AudioMeasureToolbox/GUI/GUI_DUALCHANNELFFT_FFTAnalyzerParams.fig');
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'figure1');

h1 = figure(...
'Units','characters',...
'PaperUnits','centimeters',...
'Color',[0.701960784313725 0.701960784313725 0.701960784313725],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'MenuBar','none',...
'Name','GUI_DUALCHANNELFFT_FFTGeneratorParams',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'PaperSize',[20.98404194812 29.67743169791],...
'PaperType','A4',...
'Position',[103.666666666667 31.9333333333333 74.5 29.5333333333333],...
'Resize','off',...
'HandleVisibility','callback',...
'Tag','figure1',...
'UserData',[],...
'Visible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text1';

h2 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[13.3333333333333 20.8 18.1666666666667 2],...
'String','Number of bins',...
'Style','text',...
'Tag','text1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text2';

h3 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[16.5 17.1333333333333 11.8333333333333 1.66666666666667],...
'String','Window',...
'Style','text',...
'Tag','text2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text4';

h4 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[16.5 12.8666666666667 13.5 2],...
'String','Window length',...
'Style','text',...
'Tag','text4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text5';

h5 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[18 8.6 11.8333333333333 1.66666666666667],...
'String','% overlap',...
'Style','text',...
'Tag','text5',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbuttonOK';

h6 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)GUI_linearFFTOption('pushbuttonOK_Callback',hObject,eventdata,guidata(hObject)),...
'CData',[],...
'Position',[28.5714285714286 0.857142857142857 14.1428571428571 2.14285714285714],...
'String','OK',...
'Tag','pushbuttonOK',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popupmenuPercentOverlap';

h7 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)GUI_linearFFTOption('popupmenuPercentOverlap_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[33.1666666666667 8.6 21.5 1.73333333333333],...
'String',{  'Pop-up Menu' },...
'Style','popupmenu',...
'TooltipString','-1, internal choice',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)GUI_linearFFTOption('popupmenuPercentOverlap_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popupmenuPercentOverlap');

appdata = [];
appdata.lastValidTag = 'popupmenuWinLen';

h8 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)GUI_linearFFTOption('popupmenuWinLen_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[33.1666666666667 12.8 21.5 1.73333333333333],...
'String',{  'Pop-up Menu' },...
'Style','popupmenu',...
'TooltipString','-1, internal choice',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)GUI_linearFFTOption('popupmenuWinLen_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popupmenuWinLen');

appdata = [];
appdata.lastValidTag = 'popupmenuWindow';

h9 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)GUI_linearFFTOption('popupmenuWindow_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[33.1666666666667 17.0666666666667 21.5 1.73333333333333],...
'String',{  'Pop-up Menu' },...
'Style','popupmenu',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)GUI_linearFFTOption('popupmenuWindow_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popupmenuWindow');

appdata = [];
appdata.lastValidTag = 'popupmenuNFFT';

h10 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)GUI_DUALCHANNELFFT_FFTAnalyzerParams_export('popupmenuNFFT_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[33.1666666666667 20.8 21.5 2],...
'String',{  'Pop-up Menu' },...
'Style','popupmenu',...
'Value',1,...
'ButtonDownFcn',@(hObject,eventdata)GUI_DUALCHANNELFFT_FFTAnalyzerParams_export('popupmenuNFFT_ButtonDownFcn',hObject,eventdata,guidata(hObject)),...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)GUI_linearFFTOption('popupmenuNFFT_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'DeleteFcn',@(hObject,eventdata)GUI_linearFFTOption('popupmenuNFFT_DeleteFcn',hObject,eventdata,guidata(hObject)),...
'Tag','popupmenuNFFT');

appdata = [];
appdata.lastValidTag = 'uipanel1';

h11 = uipanel(...
'Parent',h1,...
'Units','characters',...
'BorderType','beveledout',...
'Title',blanks(0),...
'Tag','uipanel1',...
'Clipping','on',...
'Position',[1.28571428571429 25.2142857142857 71.5714285714286 3.42857142857143],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text6';

h12 = uicontrol(...
'Parent',h11,...
'Units','characters',...
'Position',[8.42857142857143 0.571428571428573 51.8571428571428 1.78571428571429],...
'String','FFT anal parameters',...
'Style','text',...
'Tag','text6',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text7';

h13 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[13 5.53333333333333 11.8333333333333 1.66666666666667],...
'String','fmin',...
'Style','text',...
'Tag','text7',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text8';

h14 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[37.1666666666667 5.53333333333333 11.8333333333333 1.66666666666667],...
'String','fmax',...
'Style','text',...
'Tag','text8',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'editFreqMin';

h15 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)GUI_DUALCHANNELFFT_FFTGeneratorParams('editFreqMin_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[22.8333333333333 6.13333333333333 9.66666666666667 1.46666666666667],...
'String',{  'Edit Text' },...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)GUI_DUALCHANNELFFT_FFTGeneratorParams('editFreqMin_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','editFreqMin');

appdata = [];
appdata.lastValidTag = 'editFreqMax';

h16 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)GUI_DUALCHANNELFFT_FFTGeneratorParams('editFreqMax_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[46 6.2 9.66666666666667 1.46666666666667],...
'String',{  'Edit Text' },...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)GUI_DUALCHANNELFFT_FFTGeneratorParams('editFreqMax_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','editFreqMax');

appdata = [];
appdata.lastValidTag = 'text9';

h17 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[32.1666666666667 5.53333333333333 5.83333333333333 1.66666666666667],...
'String','Hz',...
'Style','text',...
'Tag','text9',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text10';

h18 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[55.5 5.53333333333333 5.83333333333333 1.66666666666667],...
'String','Hz',...
'Style','text',...
'Tag','text10',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_1';

h19 = uimenu(...
'Parent',h1,...
'Callback',@(hObject,eventdata)GUI_DUALCHANNELFFT_FFTAnalyzerParams_export('Untitled_1_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Untitled 1',...
'Tag','Untitled_1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );


hsingleton = h1;


% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   if isa(createfcn,'function_handle')
       createfcn(hObject, eventdata);
   else
       eval(createfcn);
   end
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
    'gui_Singleton'
    'gui_OpeningFcn'
    'gui_OutputFcn'
    'gui_LayoutFcn'
    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error('MATLAB:gui_mainfcn:FieldNotFound', 'Could not find field %s in the gui_State struct in GUI M-file %s', gui_StateFields{i}, gui_Mfile);
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % GUI_DUALCHANNELFFT_FFTANALYZERPARAMS_EXPORT
    % create the GUI only if we are not in the process of loading it
    % already
    gui_Create = true;
elseif local_isInvokeActiveXCallback(gui_State, varargin{:})
    % GUI_DUALCHANNELFFT_FFTANALYZERPARAMS_EXPORT(ACTIVEX,...)
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif local_isInvokeHGCallback(gui_State, varargin{:})
    % GUI_DUALCHANNELFFT_FFTANALYZERPARAMS_EXPORT('CALLBACK',hObject,eventData,handles,...)
    gui_Create = false;
else
    % GUI_DUALCHANNELFFT_FFTANALYZERPARAMS_EXPORT(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = true;
end

if ~gui_Create
    % In design time, we need to mark all components possibly created in
    % the coming callback evaluation as non-serializable. This way, they
    % will not be brought into GUIDE and not be saved in the figure file
    % when running/saving the GUI from GUIDE.
    designEval = false;
    if (numargin>1 && ishghandle(varargin{2}))
        fig = varargin{2};
        while ~isempty(fig) && ~isa(handle(fig),'figure')
            fig = get(fig,'parent');
        end
        
        designEval = isappdata(0,'CreatingGUIDEFigure') || isprop(fig,'__GUIDEFigure');
    end
        
    if designEval
        beforeChildren = findall(fig);
    end
    
    % evaluate the callback now
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else       
        feval(varargin{:});
    end
    
    % Set serializable of objects created in the above callback to off in
    % design time. Need to check whether figure handle is still valid in
    % case the figure is deleted during the callback dispatching.
    if designEval && ishandle(fig)
        set(setdiff(findall(fig),beforeChildren), 'Serializable','off');
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end

    % Check user passing 'visible' P/V pair first so that its value can be
    % used by oepnfig to prevent flickering
    gui_Visible = 'auto';
    gui_VisibleInput = '';
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        % Recognize 'visible' P/V pair
        len1 = min(length('visible'),length(varargin{index}));
        len2 = min(length('off'),length(varargin{index+1}));
        if ischar(varargin{index+1}) && strncmpi(varargin{index},'visible',len1) && len2 > 1
            if strncmpi(varargin{index+1},'off',len2)
                gui_Visible = 'invisible';
                gui_VisibleInput = 'off';
            elseif strncmpi(varargin{index+1},'on',len2)
                gui_Visible = 'visible';
                gui_VisibleInput = 'on';
            end
        end
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.

    
    % Do feval on layout code in m-file if it exists
    gui_Exported = ~isempty(gui_State.gui_LayoutFcn);
    % this application data is used to indicate the running mode of a GUIDE
    % GUI to distinguish it from the design mode of the GUI in GUIDE. it is
    % only used by actxproxy at this time.   
    setappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]),1);
    if gui_Exported
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);

        % make figure invisible here so that the visibility of figure is
        % consistent in OpeningFcn in the exported GUI case
        if isempty(gui_VisibleInput)
            gui_VisibleInput = get(gui_hFigure,'Visible');
        end
        set(gui_hFigure,'Visible','off')

        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen');
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        end
    end
    if isappdata(0, genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]))
        rmappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]));
    end

    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    % Singleton setting in the GUI M-file takes priority if different
    gui_Options.singleton = gui_State.gui_Singleton;

    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end

    % Apply input P/V pairs other than 'visible'
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        len1 = min(length('visible'),length(varargin{index}));
        if ~strncmpi(varargin{index},'visible',len1)
            try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
        end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end

    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});

    if isscalar(gui_hFigure) && ishandle(gui_hFigure)
        % Handle the default callbacks of predefined toolbar tools in this
        % GUI, if any
        guidemfile('restoreToolbarToolPredefinedCallback',gui_hFigure); 
        
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);

        % Call openfig again to pick up the saved visibility or apply the
        % one passed in from the P/V pairs
        if ~gui_Exported
            gui_hFigure = local_openfig(gui_State.gui_Name, 'reuse',gui_Visible);
        elseif ~isempty(gui_VisibleInput)
            set(gui_hFigure,'Visible',gui_VisibleInput);
        end
        if strcmpi(get(gui_hFigure, 'Visible'), 'on')
            figure(gui_hFigure);
            
            if gui_Options.singleton
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        if isappdata(gui_hFigure,'InGUIInitialization')
            rmappdata(gui_hFigure,'InGUIInitialization');
        end

        % If handle visibility is set to 'callback', turn it on until
        % finished with OutputFcn
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end

    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end

    if isscalar(gui_hFigure) && ishandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end

function gui_hFigure = local_openfig(name, singleton, visible)

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
if nargin('openfig') == 2
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
else
    gui_hFigure = openfig(name, singleton, visible);
end

function result = local_isInvokeActiveXCallback(gui_State, varargin)

try
    result = ispc && iscom(varargin{1}) ...
             && isequal(varargin{1},gcbo);
catch
    result = false;
end

function result = local_isInvokeHGCallback(gui_State, varargin)

try
    fhandle = functions(gui_State.gui_Callback);
    result = ~isempty(findstr(gui_State.gui_Name,fhandle.file)) || ...
             (ischar(varargin{1}) ...
             && isequal(ishandle(varargin{2}), 1) ...
             && (~isempty(strfind(varargin{1},[get(varargin{2}, 'Tag'), '_'])) || ...
                ~isempty(strfind(varargin{1}, '_CreateFcn'))) );
catch
    result = false;
end


