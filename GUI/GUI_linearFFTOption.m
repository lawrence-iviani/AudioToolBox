function varargout = GUI_linearFFTOption(varargin)
% GUI_LINEARFFTOPTION M-file for GUI_linearFFTOption.fig
%      GUI_LINEARFFTOPTION, by itself, creates a new GUI_LINEARFFTOPTION or raises the existing
%      singleton*.
%
%      H = GUI_LINEARFFTOPTION returns the handle to a new GUI_LINEARFFTOPTION or the handle to
%      the existing singleton*.
%
%      GUI_LINEARFFTOPTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_LINEARFFTOPTION.M with the given input arguments.
%
%      GUI_LINEARFFTOPTION('Property','Value',...) creates a new GUI_LINEARFFTOPTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_linearFFTOption_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_linearFFTOption_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_linearFFTOption

% Last Modified by GUIDE v2.5 26-Sep-2010 16:40:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_linearFFTOption_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_linearFFTOption_OutputFcn, ...
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


% --- Executes just before GUI_linearFFTOption is made visible.
function GUI_linearFFTOption_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_linearFFTOption (see VARARGIN)

% Choose default command line output for GUI_linearFFTOption
handles.output = hObject;
handles.changed=false;
if nargin == 4 && ~isempty(varargin{1})
    handles.params = varargin{1};
else
    %Default parameters
    handles.changed=true;
    handles.params.nfft=8192;
    handles.params.fftWin='rectangular';
    handles.params.average='vectorial';
    handles.params.winlen=[];
    handles.params.percentOverlap=[];
end

%Setting the NFFT value
handles.nfftReference=[512 1024 2048 4096 8192 16384 32768];
set(handles.popupmenuNFFT,'String', num2cell(handles.nfftReference));
indFFT=find(handles.nfftReference==handles.params.nfft);
if indFFT
    set(handles.popupmenuNFFT,'Value', indFFT);  
else
    set(handles.popupmenuNFFT,'Value', 4); 
end
handles.winlenReference=[-1 512 1024 2048 4096 8192 16384 32768];
set(handles.popupmenuWinLen,'String', num2cell(handles.winlenReference));


%%If isempty winlen transform in -1, jut for compatubility with the gui,
%in the output function -1 meand null value
if isempty(handles.params.winlen) 
    handles.params.winlen=-1;
end
indWinLen=find(handles.winlenReference==handles.params.winlen);
if indWinLen
    set(handles.popupmenuWinLen,'Value', indWinLen);  
else
    set(handles.popupmenuWinLen,'Value', 1); 
end
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
    if strcmp(contents(n),handles.params.fftWin)
        indWin=n;
        break;
    end
end
set(handles.popupmenuWindow,'Value', indWin); 

%populate combobox for the average type

set(handles.popupmenuAverage,'String',{'vectorial','rms'})
contents = get(handles.popupmenuAverage,'String');
indAvg=1;
for n=1:length(contents)
    if strcmp(contents(n),handles.params.average)
        indAvg=n;
        break;
    end
end
set(handles.popupmenuAverage,'Value', indAvg); 


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_linearFFTOption wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_linearFFTOption_OutputFcn(hObject, eventdata, handles) 
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
        if handles.params.winlen==-1
            handles.params.winlen=[];
        end
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
GUI_linearFFTOption_OutputFcn(handles, eventdata, handles); 

% --- Executes on selection change in popupmenuPercentOverlap.
function popupmenuPercentOverlap_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPercentOverlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String') ;
if contents{get(hObject,'Value')} ~= handles.params.percentOverlap
    handles.changed=true;
    handles.params.percentOverlap=str2num(contents{get(hObject,'Value')});
end
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
if contents{get(hObject,'Value')} ~= handles.params.winlen
    handles.changed=true;
    handles.params.winlen=str2num(contents{get(hObject,'Value')});
end
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


% --- Executes on selection change in popupmenuAverage.
function popupmenuAverage_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String') ;
if  ~strcmp(contents{get(hObject,'Value')}, handles.params.average )
    handles.changed=true;
    handles.params.average=contents{get(hObject,'Value')};
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuAverage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuAverage (see GCBO)
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
if  ~strcmp(contents{get(hObject,'Value')}, handles.params.fftWin )
    handles.changed=true;
    handles.params.fftWin=contents{get(hObject,'Value')};
end
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
if contents{get(hObject,'Value')} ~= handles.params.nfft
    handles.changed=true;
    handles.params.nfft=str2num(contents{get(hObject,'Value')});
end
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
