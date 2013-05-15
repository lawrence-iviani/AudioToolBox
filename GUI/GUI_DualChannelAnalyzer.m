function varargout = GUI_DualChannelAnalyzer(varargin)
% GUI_DUALCHANNELANALYZER M-file for GUI_DualChannelAnalyzer.fig
%      GUI_DUALCHANNELANALYZER, by itself, creates a new GUI_DUALCHANNELANALYZER or raises the existing
%      singleton*.
%
%      H = GUI_DUALCHANNELANALYZER returns the handle to a new GUI_DUALCHANNELANALYZER or the handle to
%      the existing singleton*.
%
%      GUI_DUALCHANNELANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DUALCHANNELANALYZER.M with the given input arguments.
%
%      GUI_DUALCHANNELANALYZER('Property','Value',...) creates a new GUI_DUALCHANNELANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_DualChannelAnalyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_DualChannelAnalyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_DualChannelAnalyzer

% Last Modified by GUIDE v2.5 29-Jan-2011 21:48:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_DualChannelAnalyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_DualChannelAnalyzer_OutputFcn, ...
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

% --- Executes just before GUI_DualChannelAnalyzer is made visible.
function GUI_DualChannelAnalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_DualChannelAnalyzer (see VARARGIN)

if nargin == 4
    handles.fs=varargin{1};
   % handles.audioDevice=varargin{4};
else
    handles.fs=44100;
    warning('GUI_DualChannelAnalyzer: sample rate not set, using default sr=44100 Hz');
end

% Choose default command line output for GUI_DualChannelAnalyzer
handles.output = hObject;
handles.data=[];
handles.data.generatorOn=false;
handles.data.analyzerOn=false;

%% Init ui
%SR
set(handles.textFS,'String', num2str(handles.fs))

%generator
handles.data.generatorParams.gain=-12;
selectGen=setGeneratorData(handles);
handles.data.generatorParams=DUALCHANNELFFT_generatorDefaultParams(selectGen);
handles.data.generatorParams.gain=str2double(get(handles.editGeneratorGain,'String')) ;

%Analyzer specific params
selectAnal=setAnalyzerData(handles);
handles.data.analyzerParams=DUALCHANNELFFT_analyzerDefaultParams(selectAnal,handles.fs);

%Analyzer default params
handles.data.analyzerParams.maxAmplitude=20;
handles.data.analyzerParams.minAmplitude=-60;
handles.data.analyzerParams.maxFrequency=handles.fs/2;
handles.data.analyzerParams.minFrequency=20;
handles.data.generalParams.averageAcquisition=true; %Average  during the acquisition.
handles.data.generalParams.winLen=4096; %duration in sample of every acquisition
handles.data.generalParams.nWin=8;%number of  win
setCommonAnalyzerParams(handles);

%Axes
handles.data.analyzerParams.axesTime=handles.axesTime;
handles.data.analyzerParams.axesFreq=handles.axesFreq;
cla(handles.data.analyzerParams.axesTime,'reset')
cla(handles.data.analyzerParams.axesFreq,'reset')

%% Update user data
setappdata(handles.output,'UserData',handles.data);


%% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using GUI_DualChannelAnalyzer.
% if strcmp(get(hObject,'Visible'),'off')
%     plot(rand(5));
% end

% UIWAIT makes GUI_DualChannelAnalyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function setCommonAnalyzerParams(handles)
winlenReference=[ 512 1024 2048 4096 8192 16384 32768];
set(handles.popupmenuWinLen,'String', num2cell(winlenReference));
indWinLen=find(winlenReference==handles.data.generalParams.winLen);
if indWinLen
    set(handles.popupmenuWinLen,'Value', indWinLen);  
else
    set(handles.popupmenuWinLen,'Value', 3); 
end
set(handles.editNAverage,'String',num2str(handles.data.generalParams.nWin))
%set min/max amplitude range
set(handles.editMaxAmplitude,'String', num2str(handles.data.analyzerParams.maxAmplitude));
set(handles.editMinAmplitude,'String', num2str(handles.data.analyzerParams.minAmplitude));
%set min/max frequncy range
set(handles.editMaxFrequency,'String', num2str(handles.data.analyzerParams.maxFrequency));
set(handles.editMinFrequency,'String', num2str(handles.data.analyzerParams.minFrequency));


function name=setGeneratorData(handles)
%set the generator value in the popupmenu and return the name of the
%selected generator

%Set the generator value type
set(handles.popupmenuGeneratorType,'String', {'Pink noise','Tone','Dual Tone'});
set(handles.popupmenuGeneratorType,'Value', 1); 
contents = get(handles.popupmenuGeneratorType,'String');
name=contents{get(handles.popupmenuGeneratorType,'Value')};

%set toggle button to off
set(handles.togglebuttonGeneratorOn,'Value', handles.data.generatorOn);
%set gain
set(handles.editGeneratorGain,'String', num2str(handles.data.generatorParams.gain));



function name=setAnalyzerData(handles)
set(handles.popupmenuAnalyzerType,'String', {'RTA','FFT','Transfer Function'});
set(handles.popupmenuAnalyzerType,'Value', 2); 
contents = get(handles.popupmenuAnalyzerType,'String');
name=contents{get(handles.popupmenuAnalyzerType,'Value')}; 

%set toggle button to off
set(handles.togglebuttonAnalyzerOn,'Value',handles.data.analyzerOn);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_DualChannelAnalyzer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.data;


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double



% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider



% --- Executes on button press in togglebuttonAnalyzerOn.
function togglebuttonAnalyzerOn_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonAnalyzerOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonAnalyzerOn
handles.data.analyzerOn =get(hObject,'Value') ;
if handles.data.analyzerOn
    set(hObject,'BackgroundColor', [0.169 0.506 0.337] )
else
    set(hObject,'BackgroundColor', [0.702 0.702 0.702] )
end
guidata(hObject, handles);
setappdata(handles.output,'UserData',handles.data);


% --- Executes on selection change in popupmenuGeneratorType.
function popupmenuGeneratorType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuGeneratorType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));% returns popupmenuGeneratorType contents as cell array
oldGain=str2double( get(handles.editGeneratorGain,'String') );%Save gain!
handles.data.generatorParams=DUALCHANNELFFT_generatorDefaultParams(contents{get(hObject,'Value')}); %returns selected item from popupmenuGeneratorType
set(handles.editGeneratorGain,'String',num2str(oldGain));%set the old gain 
handles.data.generatorParams.gain=str2double(get(handles.editGeneratorGain,'String')) ;

guidata(hObject, handles);
%Set the real value
setappdata(handles.output,'UserData',handles.data);


% --- Executes on selection change in popupmenuAnalyzerType.
function popupmenuAnalyzerType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuAnalyzerType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuAnalyzerType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuAnalyzerType

contents = cellstr(get(hObject,'String'));% returns popupmenuAnalyzerType contents as cell array
oldAnalyzerParams=handles.data.analyzerParams;
handles.data.analyzerParams=DUALCHANNELFFT_analyzerDefaultParams(contents{get(hObject,'Value')},handles.fs); %returns selected item from popupmenuGeneratorType

%copy old parameters
handles.data.analyzerParams.maxAmplitude=oldAnalyzerParams.maxAmplitude;
handles.data.analyzerParams.minAmplitude=oldAnalyzerParams.minAmplitude;
handles.data.analyzerParams.maxFrequency=oldAnalyzerParams.maxFrequency;
handles.data.analyzerParams.minFrequency=oldAnalyzerParams.minFrequency;
handles.data.analyzerParams.axesTime=handles.axesTime;
handles.data.analyzerParams.axesFreq=handles.axesFreq;

%clear axes
cla(handles.data.analyzerParams.axesTime,'reset')
cla(handles.data.analyzerParams.axesFreq,'reset')
guidata(hObject, handles);
%Set the real value
setappdata(handles.output,'UserData',handles.data);

% --- Executes on button press in togglebuttonGeneratorOn.
function togglebuttonGeneratorOn_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonGeneratorOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%returns toggle state of togglebuttonGeneratorOn
handles.data.generatorOn=get(hObject,'Value') ;
if handles.data.generatorOn
    set(hObject,'BackgroundColor', [0.169 0.506 0.337] )
else
    set(hObject,'BackgroundColor', [0.702 0.702 0.702] )
end
guidata(hObject, handles);
setappdata(handles.output,'UserData',handles.data);

% --- Executes on selection change in popupmenuWinLen.
function popupmenuWinLen_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuWinLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuWinLen contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        popupmenuWinLen,
contents = cellstr(get(hObject,'String'));
handles.data.generalParams.winLen= str2double(contents{get(hObject,'Value')});
guidata(hObject, handles);
setappdata(handles.output,'UserData',handles.data);


% --- Executes on button press in pushbuttonAnalyzerParams.
function pushbuttonAnalyzerParams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAnalyzerParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hGUI=[];
contents = cellstr(get(handles.popupmenuAnalyzerType,'String'));
switch(contents{get(handles.popupmenuAnalyzerType,'Value')})
    case 'FFT'
        [hGUI handles.data.analyzerParams]=GUI_DUALCHANNELFFT_FFTAnalyzerParams(handles.data.analyzerParams);
    case 'RTA'
        [hGUI handles.data.analyzerParams]=GUI_DUALCHANNELFFT_RTAAnalyzerParams(handles.data.analyzerParams);
    otherwise
        warning(['GUI_DualChannelAnalyzer->pushbuttonAnalyzerParams_Callback: ' contents{get(handles.popupmenuAnalyzerType,'Value')} ' is not implemented'])
end
if (~isempty(hGUI) && ishandle(hGUI))
    close(hGUI);
end

guidata(hObject, handles);
setappdata(handles.output,'UserData',handles.data);


% --- Executes on button press in pushbuttonGeneratorParams.
function pushbuttonGeneratorParams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonGeneratorParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.data.generatorParams=GUI_DUALCHANNELFFT_FFTGeneratorParams(handles.data.generatorParams);


contents = cellstr(get(handles.popupmenuGeneratorType,'String'));
switch(contents{get(handles.popupmenuGeneratorType,'Value')})
    case 'Pink noise'
        handles.data.generatorParams=GUI_DUALCHANNELFFT_PinkNoiseGeneratorParams(handles.data.generatorParams);
    case 'Tone'
        handles.data.generatorParams=GUI_DUALCHANNELFFT_ToneGeneratorParams(handles.data.generatorParams);
    case 'Dual Tone'
        handles.data.generatorParams=GUI_DUALCHANNELFFT_DualToneGeneratorParams(handles.data.generatorParams);
    case 'Silence'
        %do nothing
    otherwise
        warning(['GUI_DualChannelAnalyzer->pushbuttonGeneratorParams_Callback: ' contents{get(handles.popupmenuGeneratorType,'Value')} ' is not implemented'])
end
guidata(hObject, handles);
setappdata(handles.output,'UserData',handles.data);

function editNAverage_Callback(hObject, eventdata, handles)
% hObject    handle to editNAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNAverage as text
handles.data.generalParams.nWin=str2double(get(hObject,'String')); %returns contents of editNAverage as a double
guidata(hObject, handles);
setappdata(handles.output,'UserData',handles.data);



function editGeneratorGain_Callback(hObject, eventdata, handles)
% hObject    handle to editGeneratorGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gain=str2double(get(hObject,'String')) ;
%Check if gain > 0 and force to 0
if gain > 0  
    set(hObject,'String','0');
end
handles.data.generatorParams.gain=str2double(get(hObject,'String')) ;
guidata(hObject, handles);
setappdata(handles.output,'UserData',handles.data);

function editMaxFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to editMaxFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

maxFrequency=str2double(get(hObject,'String')) ;
%Check if gain > 0 and force to 0
if maxFrequency > handles.data.analyzerParams.minFrequency
    handles.data.analyzerParams.maxFrequency=maxFrequency;
    guidata(hObject, handles);
    setappdata(handles.output,'UserData',handles.data);
else
    set(hObject,'String',num2str(handles.data.analyzerParams.maxFrequency) );
end


function editMinFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to editMinFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

minFrequency=str2double(get(hObject,'String')) ;
%Check if gain > 0 and force to 0
if minFrequency < handles.data.analyzerParams.maxFrequency
    handles.data.analyzerParams.minFrequency=minFrequency;
    guidata(hObject, handles);
    setappdata(handles.output,'UserData',handles.data);
else
    set(hObject,'String',num2str(handles.data.analyzerParams.minFrequency) );
end


function editMaxAmplitude_Callback(hObject, eventdata, handles)
% hObject    handle to editMaxAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

maxAmplitude=str2double(get(hObject,'String')) ;
%Check if gain > 0 and force to 0
if maxAmplitude > handles.data.analyzerParams.minAmplitude
    handles.data.analyzerParams.maxAmplitude=maxAmplitude;
    guidata(hObject, handles);
    setappdata(handles.output,'UserData',handles.data);
else
    set(hObject,'String',num2str(handles.data.analyzerParams.maxAmplitude) );
end


function editMinAmplitude_Callback(hObject, eventdata, handles)
% hObject    handle to editMinAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

minAmplitude=str2double(get(hObject,'String')) ;
%Check if gain > 0 and force to 0
if minAmplitude < handles.data.analyzerParams.maxAmplitude
    handles.data.analyzerParams.minAmplitude=minAmplitude;
    guidata(hObject, handles);
    setappdata(handles.output,'UserData',handles.data);
else
    set(hObject,'String',num2str(handles.data.analyzerParams.minAmplitude) );
end


% --- Executes during object creation, after setting all properties.
function popupmenuGeneratorType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuGeneratorType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editGeneratorGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGeneratorGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function popupmenuAnalyzerType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuAnalyzerType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes during object creation, after setting all properties.
function editNAverage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNAverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





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


% --- Executes during object creation, after setting all properties.
function editMinAmplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMinAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editMaxAmplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaxAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function editMinFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMinFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function editMaxFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMaxFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
