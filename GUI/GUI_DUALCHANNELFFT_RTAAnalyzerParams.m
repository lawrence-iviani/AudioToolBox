function varargout = GUI_DUALCHANNELFFT_RTAAnalyzerParams(varargin)
% GUI_DUALCHANNELFFT_RTAAnalyzerParams M-file for GUI_DUALCHANNELFFT_RTAAnalyzerParams.fig
%      GUI_DUALCHANNELFFT_RTAAnalyzerParams, by itself, creates a new GUI_DUALCHANNELFFT_RTAAnalyzerParams or raises the existing
%      singleton*.
%
%      H = GUI_DUALCHANNELFFT_RTAAnalyzerParams returns the handle to a new GUI_DUALCHANNELFFT_RTAAnalyzerParams or the handle to
%      the existing singleton*.
%
%      GUI_DUALCHANNELFFT_RTAAnalyzerParams('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DUALCHANNELFFT_RTAAnalyzerParams.M with the given input arguments.
%
%      GUI_DUALCHANNELFFT_RTAAnalyzerParams('Property','Value',...) creates a new GUI_DUALCHANNELFFT_RTAAnalyzerParams or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_DUALCHANNELFFT_RTAAnalyzerParams_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_DUALCHANNELFFT_RTAAnalyzerParams_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_DUALCHANNELFFT_RTAAnalyzerParams

% Last Modified by GUIDE v2.5 16-Jan-2011 23:53:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_DUALCHANNELFFT_RTAAnalyzerParams_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_DUALCHANNELFFT_RTAAnalyzerParams_OutputFcn, ...
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


% --- Executes just before GUI_DUALCHANNELFFT_RTAAnalyzerParams is made visible.
function GUI_DUALCHANNELFFT_RTAAnalyzerParams_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_DUALCHANNELFFT_RTAAnalyzerParams (see VARARGIN)

% Choose default command line output for GUI_DUALCHANNELFFT_RTAAnalyzerParams
handles.output = hObject;
handles.changed=false;
if nargin == 4 && ~isempty(varargin{1})
    handles.params = varargin{1};
else 
     warning('GUI_DUALCHANNELFFT_RTAAnalyzerParams: arbitrary default params. Selecting fs=44100');
    handles.params=DUALCHANNELFFT_analyzerDefaultParams( 'RTA', 44100 );
end
handles.params
%Setting  bandsPerOctave
set(handles.editNBandsPerOctave,'String', num2str(handles.params.bandsPerOctave));


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

% UIWAIT makes GUI_DUALCHANNELFFT_RTAAnalyzerParams wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_DUALCHANNELFFT_RTAAnalyzerParams_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isstruct(handles)
    varargout{1} = handles.output;
        if handles.params.percentOverlap==-1
            handles.params.percentOverlap=[];
        end
        %if handles.params.winlen==-1
        %    handles.params.winlen=[];
        %end
        varargout{2} = handles.params;
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
GUI_DUALCHANNELFFT_RTAAnalyzerParams_OutputFcn(handles, eventdata, handles); 

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
%        str2double(get(hObject,'String')) returns contents of editFreqMin
%        as a double


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



function editNBandsPerOctave_Callback(hObject, eventdata, handles)
% hObject    handle to editNBandsPerOctave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNBandsPerOctave as text
%        str2double(get(hObject,'String')) returns contents of editNBandsPerOctave as a double

handles.params.bandsPerOctave=str2double(get(hObject,'String'));

handles.params.freq=NTH_freq_band(handles.params.bandsPerOctave, handles.params.fmin, 0.88*handles.params.fmax , 0);%Perch� 0.88????
handles.params.filter=[];
for n=1:length(handles.params.freq)
    [b a]=NTH_octdsgn(handles.params.fs,handles.params.freq(n));
    %disp(['DUALCHANNELFFT_analyzerDefaultParams: designing filter (' num2str(n) ') ' num2str(data.freq(n)) ' Hz'])
    handles.params.filter(:,n)=freqz(b,a,handles.params.NFFT*2,handles.params.fs);
end
handles.params
cla(handles.params.axesFreq,'reset')
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editNBandsPerOctave_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNBandsPerOctave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
