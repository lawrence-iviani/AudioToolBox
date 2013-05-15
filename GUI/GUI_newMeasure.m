function varargout = GUI_newMeasure(varargin)
% GUI_NEWMEASURE M-file for GUI_newMeasure.fig
%      GUI_NEWMEASURE, by itself, creates a new GUI_NEWMEASURE or raises the existing
%      singleton*.
%
%      H = GUI_NEWMEASURE returns the handle to a new GUI_NEWMEASURE or the handle to
%      the existing singleton*.
%
%      GUI_NEWMEASURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_NEWMEASURE.M with the given input arguments.
%
%      GUI_NEWMEASURE('Property','Value',...) creates a new GUI_NEWMEASURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_newMeasure_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_newMeasure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_newMeasure

% Last Modified by GUIDE v2.5 22-May-2010 10:10:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_newMeasure_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_newMeasure_OutputFcn, ...
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


% --- Executes just before GUI_newMeasure is made visible.
function GUI_newMeasure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_newMeasure (see VARARGIN)

% Init output parameter
handles.output = hObject;
handles.operation= 'GUI_newMeasure: Selection incomplete';
handles.measureParam=[];

if (nargin==7)
    handles.generalParams=varargin{1};
    handles.audioDevs=varargin{4};
    handles.previousAudioDev=varargin{2};
    handles.sweepExcitationParameters=varargin{3};
else
    GUI_newMeasure_OutputFcn(hObject, eventdata, handles) ;
end

handles.SRList=[22050 44100 48000 88200 96000];
[handles.chIN handles.chOUT]=populateChannels(hObject, eventdata, handles);
[handles.validInputDevID handles.validOutputDevID]=populateComboBox(hObject, eventdata, handles);
populateFields(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_newMeasure wait for user response (see UIRESUME)
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
    if handles.SRList(n)==handles.generalParams.sampleRate
        tSel=n;
    end
end
set(handles.popupmenuSR, 'String', item); 
set(handles.popupmenuSR,'Value',tSel);

%INPUT DEVICE
n=1;
tSel=1;
validInputDevID(1)=-1;

itemIn{1}='';
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
%  disp(['Valid input id are ' num2str(validInputDevID)])
%  disp(['tSel=' num2str(tSel)])
%  disp(['prevID=' num2str(handles.previousAudioDev.playDevice.ID) ' actualID=' num2str(validInputDevID(tSel))])


set(handles.popupmenuInputDevID , 'String', itemIn);
set(handles.popupmenuInputDevID,'Value',tSel);

%OUTPUT DEVICE
n=1;
tSel=1;
validOutputDevID(1)=-1;

itemOut{1}='';
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

function populateFields(hObject, eventdata, handles)
%Populate description
set(handles.editMeasureTitle,'String', handles.generalParams.name);
set(handles.editMeasureDescr ,'String', handles.generalParams.description);
set(handles.editNumberRipetitions ,'String', num2str(handles.generalParams.numberRipetitions));
set(handles.checkboxMedia ,'Value', handles.generalParams.calculateMedia);
set(handles.editSineSweepStartFreq,'String', num2str(handles.sweepExcitationParameters.f1));
set(handles.editSineSweepStopFreq ,'String', num2str(handles.sweepExcitationParameters.f2));
set(handles.editSineSweepDuration,'String', num2str(handles.sweepExcitationParameters.duration));
set(handles.editSineSweepFadein,'String', num2str(handles.sweepExcitationParameters.fadeIn));
set(handles.editSineSweepFadeout,'String', num2str(handles.sweepExcitationParameters.fadeOut));
set(handles.editSineSweepPresilence,'String', num2str(handles.sweepExcitationParameters.presilence));
set(handles.editSineSweepPostsilence,'String', num2str(handles.sweepExcitationParameters.postsilence));
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_newMeasure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

if isstruct(handles)
    varargout{1} = handles.output;
    varargout{2} = handles.operation;
    varargout{3} = handles.measureParam;
    uiresume(handles.figure1)
else 
    varargout{1} = [];
    varargout{2} = 'GUI_newMeasure: Selection incomplete';
    varargout{3} = [];
end


% --- Executes on button press in buttonStart.
function buttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%Retrieving sr
nSR=get(handles.popupmenuSR,'Value');
handles.measureParam.generalParams.sampleRate=handles.SRList(nSR);

%Copy data for prepare exit
%Retrieving fields
handles.measureParam.generalParams.name=get(handles.editMeasureTitle,'String');
handles.measureParam.generalParams.description=get(handles.editMeasureDescr,'String');
handles.measureParam.generalParams.numberRipetitions=str2double(get(handles.editNumberRipetitions ,'String'));
handles.measureParam.generalParams.calculateMedia=get(handles.checkboxMedia ,'Value');
handles.measureParam.sweepExcitationParameters.f1=str2double(get(handles.editSineSweepStartFreq,'String'));
handles.measureParam.sweepExcitationParameters.f2=str2double(get(handles.editSineSweepStopFreq,'String'));
handles.measureParam.sweepExcitationParameters.duration=str2double(get(handles.editSineSweepDuration,'String'));
handles.measureParam.sweepExcitationParameters.fadeIn=str2double(get(handles.editSineSweepFadein,'String'));
handles.measureParam.sweepExcitationParameters.fadeOut=str2double(get(handles.editSineSweepFadeout,'String'));
handles.measureParam.sweepExcitationParameters.presilence=str2double(get(handles.editSineSweepPresilence,'String'));
handles.measureParam.sweepExcitationParameters.postsilence=str2double(get(handles.editSineSweepPostsilence,'String'));
handles.measureParam.sweepExcitationParameters.fs=handles.SRList(nSR);



%Retrieving audio I/O data
n=get(handles.popupmenuInputDevID,'Value');
if isempty(n)
    handles.measureParam.audioDevice.recDevice.ID = -1;
    handles.measureParam.audioDevice.recDevice.data = [];
else
    handles.measureParam.audioDevice.recDevice.ID=handles.validInputDevID(n);

    handles.measureParam.audioDevice.recDevice.data = handles.audioDevs([handles.audioDevs.deviceID] == handles.measureParam.audioDevice.recDevice.ID);
end
handles.measureParam.audioDevice.recDevice.channels=[];
handles.measureParam.audioDevice.recDevice.channelsDescription={};
for n=1:length(handles.chIN)
    handles.measureParam.audioDevice.recDevice.channels(n)=handles.chIN(n).chID;
    handles.measureParam.audioDevice.recDevice.channelsDescription{n}=handles.chIN(n).chDescr;
end


n=get(handles.popupmenuOutputDevID,'Value');
if isempty(n)
    handles.measureParam.audioDevice.playDevice.ID = -1;
    handles.measureParam.audioDevice.playDevice.data = [];
else
    handles.measureParam.audioDevice.playDevice.ID=handles.validOutputDevID(n);
    handles.measureParam.audioDevice.playDevice.data = handles.audioDevs([handles.audioDevs.deviceID] == handles.measureParam.audioDevice.playDevice.ID);
end
handles.measureParam.audioDevice.playDevice.channels=[];
handles.measureParam.audioDevice.playDevice.channelsDescription={};
for n=1:length(handles.chOUT)
    handles.measureParam.audioDevice.playDevice.channels(n)=handles.chOUT(n).chID;
    handles.measureParam.audioDevice.playDevice.channelsDescription{n}=handles.chOUT(n).chDescr;
end






handles.operation = 'success';
GUI_newMeasure_OutputFcn(hObject, eventdata, handles) ;
guidata(hObject, handles);



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


% --- Executes on selection change in listboxOutputChannel.
function listboxOutputChannel_Callback(hObject, eventdata, handles)
% hObject    handle to listboxOutputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxOutputChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxOutputChannel
if isstruct(handles.chOUT)
    for n=1:length(handles.chOUT)
        item{n}=['Ch.' num2str(handles.chOUT(n).chID)  ' ' handles.chOUT(n).chDescr];
    end
else
    item{1}='No channels selected';
end
set(handles.listboxOutputChannel, 'String', item);   
guidata(hObject, handles);


% --- Executes on selection change in listboxInputChannel.
function listboxInputChannel_Callback(hObject, eventdata, handles)
% hObject    handle to listboxInputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxInputChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxInputChannel
if isstruct(handles.chIN)
    for n=1:length(handles.chIN)
        item{n}=['Ch.' num2str(handles.chIN(n).chID)  ' ' handles.chIN(n).chDescr];
    end
else
    item{1}='No channels selected';
end
set(handles.listboxInputChannel, 'String', item);   
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

% Hints: contents = get(hObject,'String') returns popupmenuInputDevID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuInputDevID
handles.chIN=[];
guidata(hObject, handles);
listboxInputChannel_Callback(hObject, eventdata, handles);
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




% --- Executes on selection change in popupmenuSR.
function popupmenuSR_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuSR contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSR

function editMeasureDescr_Callback(hObject, eventdata, handles)
% hObject    handle to editMeasureDescr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMeasureDescr as text
%        str2double(get(hObject,'String')) returns contents of editMeasureDescr as a double

function editMeasureTitle_Callback(hObject, eventdata, handles)
% hObject    handle to editMeasureTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMeasureTitle as text
%        str2double(get(hObject,'String')) returns contents of editMeasureTitle as a double

function editSineSweepStartFreq_Callback(hObject, eventdata, handles)
% hObject    handle to editSineSweepStartFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSineSweepStartFreq as text
%        str2double(get(hObject,'String')) returns contents of editSineSweepStartFreq as a double


function editSineSweepStopFreq_Callback(hObject, eventdata, handles)
% hObject    handle to editSineSweepStopFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSineSweepStopFreq as text
%        str2double(get(hObject,'String')) returns contents of editSineSweepStopFreq as a double

function editSineSweepDuration_Callback(hObject, eventdata, handles)
% hObject    handle to editSineSweepDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSineSweepDuration as text
%        str2double(get(hObject,'String')) returns contents of editSineSweepDuration as a double


function editSineSweepPostsilence_Callback(hObject, eventdata, handles)
% hObject    handle to editSineSweepPostsilence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSineSweepPostsilence as text
%        str2double(get(hObject,'String')) returns contents of editSineSweepPostsilence as a double

% --- Executes on selection change in listboxOutputChannelDescr.
function listboxOutputChannelDescr_Callback(hObject, eventdata, handles)
% hObject    handle to listboxOutputChannelDescr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxOutputChannelDescr contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxOutputChannelDescr



function editSineSweepFadein_Callback(hObject, eventdata, handles)
% hObject    handle to editSineSweepFadein (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSineSweepFadein as text
%        str2double(get(hObject,'String')) returns contents of editSineSweepFadein as a double


% --- Executes during object creation, after setting all properties.
function editSineSweepFadein_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSineSweepFadein (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSineSweepFadeout_Callback(hObject, eventdata, handles)
% hObject    handle to editSineSweepFadeout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSineSweepFadeout as text
%        str2double(get(hObject,'String')) returns contents of editSineSweepFadeout as a double





% Hints: contents = get(hObject,'String') returns popupmenuOutputDevID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuOutputDevID
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


% --- Executes during object creation, after setting all properties.
function editMeasureDescr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMeasureDescr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editMeasureTitle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMeasureTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editSineSweepStartFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSineSweepStartFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editSineSweepStopFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSineSweepStopFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editSineSweepDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSineSweepDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function editSineSweepFadeout_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSineSweepFadeout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSineSweepPresilence_Callback(hObject, eventdata, handles)
% hObject    handle to editSineSweepPresilence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSineSweepPresilence as text
%        str2double(get(hObject,'String')) returns contents of editSineSweepPresilence as a double


% --- Executes during object creation, after setting all properties.
function editSineSweepPresilence_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSineSweepPresilence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function editSineSweepPostsilence_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSineSweepPostsilence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function listboxOutputChannelDescr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxOutputChannelDescr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listboxInputChannelDescr.
function listboxInputChannelDescr_Callback(hObject, eventdata, handles)
% hObject    handle to listboxInputChannelDescr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxInputChannelDescr contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxInputChannelDescr



% --- Executes during object creation, after setting all properties.
function listboxInputChannelDescr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxInputChannelDescr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




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


% --- Executes on button press in pushbuttonAddOutputChannel.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddOutputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function listboxInputChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxInputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonAddInputChannel.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddInputChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editNumberRipetitions_Callback(hObject, eventdata, handles)
% hObject    handle to editNumberRipetitions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumberRipetitions as text
%        str2double(get(hObject,'String')) returns contents of editNumberRipetitions as a double


% --- Executes during object creation, after setting all properties.
function editNumberRipetitions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumberRipetitions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxMedia.
function checkboxMedia_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxMedia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxMedia


