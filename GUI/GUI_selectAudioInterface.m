function varargout = GUI_selectAudioInterface(varargin)
% GUI_SELECTAUDIOINTERFACE M-file for GUI_selectAudioInterface.fig
%      GUI_SELECTAUDIOINTERFACE, by itself, creates a new GUI_SELECTAUDIOINTERFACE or raises the existing
%      singleton*.
%
%      H = GUI_SELECTAUDIOINTERFACE returns the handle to a new GUI_SELECTAUDIOINTERFACE or the handle to
%      the existing singleton*.
%
%      GUI_SELECTAUDIOINTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_SELECTAUDIOINTERFACE.M with the given input arguments.
%
%      GUI_SELECTAUDIOINTERFACE('Property','Value',...) creates a new GUI_SELECTAUDIOINTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_selectAudioInterface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_selectAudioInterface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_selectAudioInterface

% Last Modified by GUIDE v2.5 19-Oct-2010 15:56:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_selectAudioInterface_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_selectAudioInterface_OutputFcn, ...
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


% --- Executes just before GUI_selectAudioInterface is made visible.
function GUI_selectAudioInterface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_selectAudioInterface (see VARARGIN)

% Choose default command line output for GUI_selectAudioInterface
handles.output = hObject;
handles.operation= 'Selection incomplete';
handles.measureParam=[];

if (nargin==6)
    handles.sampleRate=varargin{1};
    handles.audioDevs=varargin{2};
    handles.previousAudioDev=varargin{3};
else
    GUI_newMeasure_OutputFcn(hObject, eventdata, handles) ;
end

handles.SRList=[22050 44100 48000 88200 96000];
[handles.chIN handles.chOUT]=populateChannels(hObject, eventdata, handles);
[handles.validInputDevID handles.validOutputDevID]=populateComboBox(hObject, eventdata, handles);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_selectAudioInterface wait for user response (see UIRESUME)
uiwait(handles.figure1);





function [chIN chOUT]=populateChannels(hObject, eventdata, handles)
chIN=[];
chOUT=[];    

for l=1:length(handles.previousAudioDev.playDevice.channels)
    chOUT(l).chID=handles.previousAudioDev.playDevice.channels(l);
    chOUT(l).chDescr=char(handles.previousAudioDev.playDevice.channelsDescription(l));
end
handles.chOUT=chOUT;

for l=1:length(handles.previousAudioDev.recDevice.channels)
    chIN(l).chID=handles.previousAudioDev.recDevice.channels(l);
    chIN(l).chDescr=char(handles.previousAudioDev.recDevice.channelsDescription(l));
end
handles.chIN=chIN;

guidata(hObject, handles);
listboxOutputChannel_Callback(hObject, eventdata, handles)
listboxInputChannel_Callback(hObject, eventdata, handles)

function [validInputDevID validOutputDevID]=populateComboBox(hObject, eventdata, handles)

%COMBO SAMPLERATE
tSel=2;
for n=1:length(handles.SRList)
    item{n}=num2str(handles.SRList(n));
    if handles.SRList(n)==handles.sampleRate
        tSel=n;
    end
end
set(handles.popupmenuSR, 'String', item); 
set(handles.popupmenuSR,'Value',tSel);

%INPUT DEVICE
n=1;
tSel=1;
itemIn{1}='No devices';
for k=1:length(handles.audioDevs)
    if(handles.audioDevs(k).inputChans)
        itemIn{n}=[ num2str(handles.audioDevs(k).deviceID) ' - ' handles.audioDevs(k).name];
        validInputDevID(n)=k-1;
        if handles.audioDevs(k).deviceID==handles.previousAudioDev.playDevice.ID
            %disp(['sel input handles.audioDevs(k).deviceID=' num2str(handles.audioDevs(k).deviceID) ' handles.previousAudioDev.playDevice.ID=' num2str(handles.previousAudioDev.playDevice.ID) ])
            %disp(['sel input n=' num2str(n) ' k=' num2str(k) ])
            tSel=n;
        end
        n=n+1;
    end
end
% disp(['Valid input id are ' num2str(validInputDevID)])
% disp(['tSel=' num2str(tSel)])
% disp(['prevID=' num2str(handles.previousAudioDev.playDevice.ID) ' actualID=' num2str(validInputDevID(tSel))])

set(handles.popupmenuInputDevID , 'String', itemIn);
set(handles.popupmenuInputDevID,'Value',tSel);

%OUTPUT DEVICE
n=1;
tSel=1;
itemOut{1}='No devices';
for k=1:length(handles.audioDevs)
    if(handles.audioDevs(k).outputChans)
        itemOut{n}=[ num2str(handles.audioDevs(k).deviceID) ' - ' handles.audioDevs(k).name];
        validOutputDevID(n)=k-1;
        if handles.audioDevs(k).deviceID==handles.previousAudioDev.recDevice.ID
            %disp(['sel output n=' num2str(n) ' k=' num2str(k) ])
            tSel=n;
        end
        n=n+1;
    end
end
% disp(['Valid output id are ' num2str(validOutputDevID)])
% disp(['tSel=' num2str(tSel)])
% disp(['prevID=' num2str(handles.previousAudioDev.recDevice.ID) ' actualID=' num2str(validOutputDevID(tSel))])

set(handles.popupmenuOutputDevID , 'String', itemOut);
set(handles.popupmenuOutputDevID,'Value',tSel);
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = GUI_selectAudioInterface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isstruct(handles)
    varargout{1} = handles.output;
    varargout{2} = handles.operation;
    varargout{3} = handles.audioDevice;
    varargout{4} = handles.sampleRate;
    uiresume(handles.figure1)
else 
    varargout{1} = [];
    varargout{2} = 'Selection incomplete';
    varargout{3} = [];
    varargout{4} = [];
end

% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%Retrieving sr
nSR=get(handles.popupmenuSR,'Value');
handles.sampleRate=handles.SRList(nSR);

%Retrieving audio I/O data
n=get(handles.popupmenuInputDevID,'Value');
if isempty(n)
    handles.audioDevice.recDevice.ID = -1;
    handles.audioDevice.recDevice.data = [];
else
    handles.audioDevice.recDevice.ID=handles.validInputDevID(n);
    handles.audioDevice.recDevice.data = handles.audioDevs([handles.audioDevs.deviceID] == handles.audioDevice.recDevice.ID);
end
handles.audioDevice.recDevice.channels=[];
handles.audioDevice.recDevice.channelsDescription={};
for n=1:length(handles.chIN)
    handles.audioDevice.recDevice.channels(n)=handles.chIN(n).chID;
    handles.audioDevice.recDevice.channelsDescription{n}=handles.chIN(n).chDescr;
end

n=get(handles.popupmenuOutputDevID,'Value');
if isempty(n)
    handles.audioDevice.playDevice.ID = -1;
    handles.audioDevice.playDevice.data = [];
else
    handles.audioDevice.playDevice.ID=handles.validOutputDevID(n);
    handles.audioDevice.playDevice.data = handles.audioDevs([handles.audioDevs.deviceID] == handles.audioDevice.playDevice.ID);
end
handles.audioDevice.playDevice.channels=[];
handles.audioDevice.playDevice.channelsDescription={};
for n=1:length(handles.chOUT)
    handles.audioDevice.playDevice.channels(n)=handles.chOUT(n).chID;
    handles.audioDevice.playDevice.channelsDescription{n}=handles.chOUT(n).chDescr;
end

handles.operation = 'success';
GUI_selectAudioInterface_OutputFcn(hObject, eventdata, handles) ;
guidata(hObject, handles);



% --- Executes on selection change in listboxOutputChannel.
function listboxOutputChannel_Callback(hObject, eventdata, handles)
% hObject    handle to listboxOutputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isstruct(handles.chOUT)
    for n=1:length(handles.chOUT)
        item{n}=['Ch.' num2str(handles.chOUT(n).chID)  ' ' handles.chOUT(n).chDescr];
    end
else
    item{1}='No channels selected';
end
set(handles.listboxOutputChannel, 'String', item);   
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listboxOutputChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxOutputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listboxOutputChannel.
function listboxInputChannel_Callback(hObject, eventdata, handles)
% hObject    handle to listboxOutputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isstruct(handles.chIN)
    for n=1:length(handles.chIN)
        item{n}=['Ch.' num2str(handles.chIN(n).chID)  ' ' handles.chIN(n).chDescr];
    end
else
    item{1}='No channels selected';
end
set(handles.listboxInputChannel, 'String', item);   
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listboxInputChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxOutputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonAddOutputChannel.
function pushbuttonAddOutputChannel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddOutputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n=get(handles.popupmenuOutputDevID,'Value');
temp.ID=handles.validOutputDevID(n);
temp.devs=handles.audioDevs;
[hadd channel]=GUI_addChannel(temp,'output');
if ishandle(hadd)
    close(hadd);
end
if isstruct(channel)
    if isstruct(handles.chOUT)
        l=length(handles.chOUT);
        finded=false;
        for n=1:l 
            if channel.ID==handles.chOUT(n).chID
                finded=true;
            end
        end
        if not(finded)
            handles.chOUT(l+1).chID=channel.ID;
            handles.chOUT(l+1).chDescr=channel.descr;
        end
    else
        handles.chOUT(1).chID=channel.ID;
        handles.chOUT(1).chDescr=channel.descr;
    end
    
else
    
end

guidata(hObject, handles);
listboxOutputChannel_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes on button press in pushbuttonDelOutputChannel.
function pushbuttonDelOutputChannel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDelOutputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index=get(handles.listboxOutputChannel, 'Value');
newchOUT=[];
k=1;
if isstruct(handles.chOUT)
    for n=1:length(handles.chOUT)
        if n==index
            %do nothing
        else
            newchOUT(k).chID=handles.chOUT(n).chID;
            newchOUT(k).chDescr=handles.chOUT(n).chDescr;
            k=k+1;
        end
    end
 %   index=index-1;
end
set(handles.listboxOutputChannel, 'Value', 1);
handles.chOUT=newchOUT;
guidata(hObject, handles);
listboxOutputChannel_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes on selection change in popupmenuOutputDevID.
function popupmenuOutputDevID_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuOutputDevID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.chOUT=[];
guidata(hObject, handles);
listboxOutputChannel_Callback(hObject, eventdata, handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function popupmenuOutputDevID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuOutputDevID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbuttonAddInputChannel.
function pushbuttonAddInputChannel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddInputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n=get(handles.popupmenuInputDevID,'Value');
temp.ID=handles.validInputDevID(n);
temp.devs=handles.audioDevs;

[hadd channel]=GUI_addChannel(temp,'input');
if ishandle(hadd)
    close(hadd);
end
if isstruct(channel)
    if isstruct(handles.chIN)
        l=length(handles.chIN);
        finded=false;
        for n=1:l 
            if channel.ID==handles.chIN(n).chID
                finded=true;
            end
        end
        if not(finded)
            handles.chIN(l+1).chID=channel.ID;
            handles.chIN(l+1).chDescr=channel.descr;
        end
    else
        handles.chIN(1).chID=channel.ID;
        handles.chIN(1).chDescr=channel.descr;
    end
    
else
    
end

guidata(hObject, handles);
listboxInputChannel_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes on button press in pushbuttonDelInputChannel.
function pushbuttonDelInputChannel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDelInputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index=get(handles.listboxInputChannel, 'Value');
newchIN=[];
k=1;
if isstruct(handles.chIN)
    for n=1:length(handles.chIN)
        if n==index
            %do nothing
        else
            newchIN(k).chID=handles.chIN(n).chID;
            newchIN(k).chDescr=handles.chIN(n).chDescr;
            k=k+1;
        end
    end
 %   index=index-1;
end
set(handles.listboxInputChannel, 'Value', 1);
handles.chIN=newchIN;
guidata(hObject, handles);
listboxInputChannel_Callback(hObject, eventdata, handles);
guidata(hObject, handles);



% --- Executes on selection change in popupmenuInputDevID.
function popupmenuInputDevID_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuInputDevID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.chIN=[];
guidata(hObject, handles);
listboxInputChannel_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuInputDevID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuInputDevID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuSR.
function popupmenuSR_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSR contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSR


% --- Executes during object creation, after setting all properties.
function popupmenuSR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function popupmenuOutputDevID_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuOutputDevID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
