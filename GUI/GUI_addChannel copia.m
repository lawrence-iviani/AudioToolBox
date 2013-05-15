function varargout = GUI_addChannel(varargin)
% GUI_ADDCHANNEL M-file for GUI_addChannel.fig
%      GUI_ADDCHANNEL, by itself, creates a new GUI_ADDCHANNEL or raises the existing
%      singleton*.
%
%      H = GUI_ADDCHANNEL returns the handle to a new GUI_ADDCHANNEL or the handle to
%      the existing singleton*.
%
%      GUI_ADDCHANNEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_ADDCHANNEL.M with the given input arguments.
%
%      GUI_ADDCHANNEL('Property','Value',...) creates a new GUI_ADDCHANNEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_addChannel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_addChannel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_addChannel

% Last Modified by GUIDE v2.5 23-Apr-2010 10:11:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_addChannel_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_addChannel_OutputFcn, ...
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


% --- Executes just before GUI_addChannel is made visible.
function GUI_addChannel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_addChannel (see VARARGIN)

% Choose default command line output for GUI_addChannel
handles.output = hObject;
if nargin==5
    handles.channel=[];
    handles.devData=varargin{1};
    handles.IOType=varargin{2};
else
    %exit
    GUI_addChannel_OutputFcn(hObject, eventdata, handles);
end

ID=handles.devData.ID+1;
name=[ 'Select ' handles.IOType ' channel for '  handles.devData.devs(ID).name ' ID(' num2str(handles.devData.ID) ')'];
set(handles.textDeviceName,'String', name);

if strcmp(handles.IOType,'input')
    item{1}=['No ' handles.IOType ' channels'];
    for n=1:handles.devData.devs(ID).inputChans 
        item{n}=[handles.IOType ' ' num2str(n)];
    end
    set(handles.editDescription ,'String', 'Channel 1');
    set(handles.popupmenu1, 'String', item);     
elseif strcmp(handles.IOType,'output')
    item{1}=['No ' handles.IOType ' channels'];
    for n=1:handles.devData.devs(ID).outputChans 
        item{n}=[handles.IOType ' ' num2str(n)];
    end
    set(handles.editDescription ,'String', 'Channel 1');
    set(handles.popupmenu1, 'String', item);    
else
    warning('GUI_addChannel: Invalid type of IO');
    GUI_addChannel_OutputFcn(hObject, eventdata, handles);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_addChannel wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_addChannel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isstruct(handles)
    varargout{1} = handles.output;
    varargout{2} = handles.channel;
    uiresume(handles.figure1)
else 
    varargout{1} = [];
    varargout{2} = [];
end

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
handles.channel.ID=get(handles.popupmenu1,'Value');
set(handles.editDescription ,'String', ['Channel ' num2str(handles.channel.ID) ]);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDescription_Callback(hObject, eventdata, handles)
% hObject    handle to editDescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDescription as text
%        str2double(get(hObject,'String')) returns contents of editDescription as a double


% --- Executes during object creation, after setting all properties.
function editDescription_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDescription (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.channel.ID=get(handles.popupmenu1,'Value');
handles.channel.descr=get(handles.editDescription,'String');
GUI_addChannel_OutputFcn(hObject, eventdata, handles) 

% --- Executes on button press in pushbuttonEXIT.
function pushbuttonEXIT_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonEXIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.channel=[];
GUI_addChannel_OutputFcn(hObject, eventdata, handles) 
