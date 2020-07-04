function varargout = string_pulling_behavior_analytics(varargin)
% STRING_PULLING_BEHAVIOR_ANALYTICS MATLAB code for string_pulling_behavior_analytics.fig
%      STRING_PULLING_BEHAVIOR_ANALYTICS, by itself, creates a new STRING_PULLING_BEHAVIOR_ANALYTICS or raises the existing
%      singleton*.
%
%      H = STRING_PULLING_BEHAVIOR_ANALYTICS returns the handle to a new STRING_PULLING_BEHAVIOR_ANALYTICS or the handle to
%      the existing singleton*.
%
%      STRING_PULLING_BEHAVIOR_ANALYTICS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STRING_PULLING_BEHAVIOR_ANALYTICS.M with the given input arguments.
%
%      STRING_PULLING_BEHAVIOR_ANALYTICS('Property','Value',...) creates a new STRING_PULLING_BEHAVIOR_ANALYTICS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before string_pulling_behavior_analytics_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to string_pulling_behavior_analytics_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help string_pulling_behavior_analytics

% Last Modified by GUIDE v2.5 18-Jun-2020 12:23:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @string_pulling_behavior_analytics_OpeningFcn, ...
                   'gui_OutputFcn',  @string_pulling_behavior_analytics_OutputFcn, ...
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

% --- Executes just before string_pulling_behavior_analytics is made visible.
function string_pulling_behavior_analytics_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to string_pulling_behavior_analytics (see VARARGIN)

% Choose default command line output for string_pulling_behavior_analytics
handles.output = hObject;
% handles.d = varargin{1};
% handles.md = varargin{2};
addpath(genpath(pwd));
enable_disable_1(handles,2,0);
set(handles.pushbutton_fileOpen,'visible','on');
displayMessage(handles,sprintf('Welcome to String Pulling Behavioral Analytics'),{'FontSize',12});
screenSizeJ = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
screenSize = [1 1 screenSizeJ.getWidth screenSizeJ.getHeight];
if screenSize(3) < 1920 || screenSize(4) < 1080
    answers = {'Proceed Anyways','Quit'};
    [choice] = bttnChoiceDialog(answers,'Please Select', 1, 'Graphical User Interface requires 1920x1080 screen resolution. Buttons might not be visible', [1 2],[round(screenSize(3)/2) round(screenSize(4)/2) screenSize(3)-100 200]);
    if choice == 2
%     uiwait(msgbox('Graphical User Interface requires 1920x1080 screen resolution','Please change screen resolution','error','modal'));
        closereq;
        return;
    end
end
set(handles.figure1,'Units','Pixels');
mainWindowSize = get(handles.figure1,'Position');
left = 1;
bottom = screenSize(4) - mainWindowSize(4) - 10;
set(handles.figure1,'Position',[left bottom mainWindowSize(3) mainWindowSize(4)]);
n = 0;
% display('I was here');
set(hObject,'CloseRequestFcn',@(hObject, event) main_interface_CloseFcn(event, handles));
% guidata(hObject, handles);
% handles.closeFigure = true;

% UIWAIT makes string_pulling_behavior_analytics wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function varargout = main_interface_CloseFcn(eventdata, handles) 
try
    stop(handles.timer_video_loader);
    delete(handles.timer_video_loader);
catch
end
whs = get(handles.pushbutton_close_extra_windows,'userdata');
for ii = 1:length(whs)
    try
        close(whs{ii});
    catch
    end
end

try
    close(figure(100));
catch
end

closereq;
clear global

% --- Outputs from this function are returned to the command line.
function varargout = string_pulling_behavior_analytics_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% stop(handles.timer_video_loader);
% delete(handles.timer_video_loader);
if isfield(handles,'output')
    varargout{1} = handles.output;
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% stop(handles.timer_video_loader)
value = round(get(hObject,'Value'));
set(hObject,'userdata',value);
displayFrames(handles,value);
fn = get(handles.figure1,'userdata');
set(handles.text_selected_frame,'String',sprintf('(%d)',fn));
n = 0;

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function timerFuncStarter(event, handles)
start(timerfind('Name','SP_video_loader_starter'));

function timerFunc(event, handles)
global frameNumber;
global frameTimes;
global frames;
global v;
loaded = get(handles.text_fileName,'userdata');
if ~loaded
    if frameNumber < handles.d.number_of_frames
        if hasFrame(v)
            frameNumber = frameNumber + 1;
            frames{frameNumber} = readFrame(v);
            frameTimes(frameNumber) = v.CurrentTime;
        end
        set(handles.text_fileName,'String',sprintf('File: %s ... loading frame %d/%d',handles.d.file_name,frameNumber,handles.d.number_of_frames));
    else
        disp('Loading of file complete');
        displayMessage(handles,'Loading of file complete');
        set(handles.text_fileName,'String',sprintf('File: %s',handles.d.file_name));
        stop(timerfind('Name','SP_video_loader'));
        set(handles.text_fileName,'userdata',1);
    end
end

% --- Executes on button press in pushbutton_zoom_window.
function pushbutton_zoom_window_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_zoom_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if strcmp(get(handles.timer_video_loader,'Running'),'on')
%     stop(handles.timer_video_loader);
% end
% fn = round(get(handles.slider1,'Value'));
fn = get(handles.figure1,'userdata');
data = get_data(handles);
hf = figure(10);
set(hf,'WindowStyle','modal');
imshow(data.frames{fn});
axis equal; axis off;
try
    hrect = imrect(gca);
    set(hf,'WindowStyle','normal');
catch
    return;
end
if isempty(hrect)
    displayFrames(handles,fn);
    return;
end
pos = round(hrect.getPosition);
close(hf);
left = pos(1);
if left <= 0
    left = 1;
end
top = pos(2);
if top <= 0
    top = 1;
end
right = pos(1)+pos(3);
if right > data.video_object.Width
    right = data.video_object.Width;
end
bottom = pos(2) + pos(4);
if bottom > data.video_object.Height
    bottom = data.video_object.Height;
end
setParameter(handles,'Zoom Window',[left top right bottom]);
% handles.md.resultsMF.zoomWindow = [left top right bottom];
zw1 = [left top right bottom];
set(handles.text_zoom_window,'String',sprintf('[%d %d %d %d]',zw1(1),zw1(2),zw1(4),zw1(3)),'userdata',zw1);
zw = [left top right-left+1 bottom-top+1];
set(handles.text_zoomWindowSize,'String',sprintf('[%d %d %d %d]',zw(1),zw(2),zw(4),zw(3)),'userdata',zw);
pushbutton_disp_update_Callback(handles.pushbutton_disp_update, eventdata, handles)
% displayFrames(handles,fn);

% --- Executes when selected cell(s) is changed in epochs.
function epochs_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to epochs (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
% stop(handles.timer_video_loader);
data = get(hObject,'Data');
md = get_meta_data(handles);
if ~isempty(eventdata.Indices)
    fn = data{eventdata.Indices(1),eventdata.Indices(2)};
    if ~isempty(fn)
        if eventdata.Indices(2) == 2
            fn = fn - md.disp.numFrames + 1;
        end
        try
            displayFrames(handles,fn);
        catch
        end
    end
    set(handles.epochs,'userdata',eventdata.Indices);
end

% --------------------------------------------------------------------
function epochs_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to epochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n=0;

% --- Executes on key press with focus on epochs and none of its controls.
function epochs_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to epochs (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.Key,'return')
    pause(0.1);
    data = get(handles.epochs,'Data');
    estarts = cell2mat(data(:,1));
    eends = cell2mat(data(:,2));
    epochs{2} = eends;
    epochs{1} = estarts;
    setParameter(handles,'Epochs',epochs);
end

% --- Executes on key release with focus on figure1 or any of its controls.
function figure1_WindowKeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)
if strcmp(eventdata.Key,'page-down')
    
end

if strcmp(eventdata.Key,'page-up')
    
end
dispFigureWindowKeyReleaseFcn(eventdata,handles);
% 
% if strcmp(eventdata.Key,'escape') && isempty(eventdata.Modifier)
%     set(handles.text_processing,'userdata',0);
%     set_processing_mode_gui(handles,0);
% end

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in pushbutton_selectHandColor.
function pushbutton_selectHandColor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectHandColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    selectColors(handles,'Hands');
catch
    figure(10);close(gcf);
    if get(handles.checkbox_rethrow_matlab_errors,'Value')
        rethrow(lasterror);
    end
end
return;
global frames;
colorVals = getParameter(handles,'Hands Color');
% colorVals_bd = getParameter(handles,'Hands Color Backward Difference');
if ~isempty(colorVals)
    opts.Interpreter = 'tex';opts.Default = 'Yes';
    quest = 'Add to existing colors?';
    answer = questdlg(quest,'Please select',...
                      'Yes','No',opts);
    if strcmp(answer,'Yes')
        existCols = 1;
    else
        existCols = 0;
    end
else
    existCols = 0;
end
if existCols
    [sfn,efn] = getFrameNums(handles);
    if isnan(sfn) || isnan(efn)
        displayMessage(handles,'Select a valid frame range');
        return;
    end
    thisFrame = frames{sfn};
    colorVals = [colorVals;selectPixelsAndGetHSV_1(thisFrame,20,handles,'Right or Left or both Hands')];
%     thisFrame = frames{sfn}-frames{sfn-1};
%     temp = selectPixelsAndGetHSV_1(thisFrame,20,handles,'Right or Left or both Hand');
%     colorVals_bd = [colorVals_bd;temp];
else  
    [sfn,efn] = getFrameNums(handles);
    if isnan(sfn) || isnan(efn)
        displayMessage(handles,'Select a valid frame range');
        return;
    end
    fns = randi([sfn efn],1,3);
%     fns_bd = randi([sfn efn],1,5);
    colorVals = [];
    areas = [];
    for ii = 1:length(fns)
        fn = fns(ii);
        thisFrame = frames{fn};
        temp = selectPixelsAndGetHSV_1(thisFrame,20,handles,'Right Hand');
        colorVals = [colorVals;temp];
        areas = [areas size(temp,1)];
    end
    for ii = 1:length(fns)
        fn = fns(ii);
        thisFrame = frames{fn};
        temp = selectPixelsAndGetHSV_1(thisFrame,20,handles,'Left Hand');
        colorVals = [colorVals;temp];
        areas = [areas size(temp,1)];
    end
%     for ii = 1:length(fns_bd)
%         fn = fns_bd(ii);
%         thisFrame = frames{fn}-frames{fn-1};
%         temp = selectPixelsAndGetHSV_1(thisFrame,20,handles,'Right or Left or both Hand');
%         colorVals_bd = [colorVals_bd;temp];
%         
%     end
end
hf = figure(10);
close(hf);
uColorVals = unique(colorVals,'rows');
% uColorVals_bd = unique(colorVals_bd,'rows');
% uCV = findValsAroundMean(uColorVals(:,1:3),[3 100]);
setParameter(handles,'Hands Color',uColorVals);pause(0.3);
% setParameter(handles,'Hands Color Backward Difference',uColorVals_bd);
checkStatusOfColors(handles);
if exist('areas','var')
    aThresh = 2*max(areas);
    setParameter(handles,'Touching Hands Area',aThresh);
end

% --- Executes on button press in pushbutton_selectFurColor.
function pushbutton_selectFurColor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectFurColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% selectAndStoreColors(handles,2);
try
    selectColors(handles,'Fur');
catch
    figure(10);close(gcf);
    if get(handles.checkbox_rethrow_matlab_errors,'Value')
        rethrow(lasterror);
    end
end
cF = getColors(handles,'Fur',4:6,0);
d = mean(cF - [255 255 255]);
if d(1) < -128 && d(2) < -128 && d(3) < -128
    setParameter(handles,'Mouse Color','Black');
else
    setParameter(handles,'Mouse Color','White');
end
return;
global frames;
colorVals = getParameter(handles,'Fur Color');
if ~isempty(colorVals)
    opts.Interpreter = 'tex';opts.Default = 'Yes';
    quest = 'Add to existing colors?';
    answer = questdlg(quest,'Please select',...
                      'Yes','No',opts);
    if strcmp(answer,'Yes')
        existCols = 1;
    else
        existCols = 0;
    end
else
    existCols = 0;
end
if existCols
    [sfn,efn] = getFrameNums(handles);
    if isnan(sfn) || isnan(efn)
        displayMessage(handles,'Select a valid frame range');
        return;
    end
    thisFrame = frames{sfn};
    colorVals = [colorVals;selectPixelsAndGetHSV_1(thisFrame,20,handles,'Fur')];
else    
    [sfn,efn] = getFrameNums(handles);
    if isnan(sfn) || isnan(efn)
        displayMessage(handles,'Select a valid frame range');
        return;
    end
    fns = randi([sfn efn],1,5);
    colorVals = [];
    for ii = 1:length(fns)
        fn = fns(ii);
        thisFrame = frames{fn};
        colorVals = [colorVals;selectPixelsAndGetHSV_1(thisFrame,20,handles,'Fur')];
    end
end
uColorVals = unique(colorVals,'rows');
% uCV = findValsAroundMean(uColorVals(:,1:3),[3 100]);
setParameter(handles,'Fur Color',uColorVals);
checkStatusOfColors(handles);
figure(10);close(gcf);

% --- Executes on button press in pushbutton_selectStringColor.
function pushbutton_selectStringColor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectStringColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    selectColors(handles,'String');
catch
    figure(10);close(gcf);
    if get(handles.checkbox_rethrow_matlab_errors,'Value')
        rethrow(lasterror);
    end
end
return;
global frames;
colorVals = getParameter(handles,'String Color');
if ~isempty(colorVals)
    opts.Interpreter = 'tex';opts.Default = 'Yes';
    quest = 'Add to existing colors?';
    answer = questdlg(quest,'Please select',...
                      'Yes','No',opts);
    if strcmp(answer,'Yes')
        existCols = 1;
    else
        existCols = 0;
    end
else
    existCols = 0;
end
if existCols
    [sfn,efn] = getFrameNums(handles);
    if isnan(sfn) || isnan(efn)
        displayMessage(handles,'Select a valid frame range');
        return;
    end
    thisFrame = frames{sfn};
    colorVals = [colorVals;selectPixelsAndGetHSV_1(thisFrame,20,handles,'String')];
else    
    [sfn,efn] = getFrameNums(handles);
    if isnan(sfn) || isnan(efn)
        displayMessage(handles,'Select a valid frame range');
        return;
    end
    fns = randi([sfn efn],1,5);
    colorVals = [];
    for ii = 1:length(fns)
        fn = fns(ii);
        thisFrame = frames{fn};
        colorVals = [colorVals;selectPixelsAndGetHSV_1(thisFrame,20,handles,'String')];
    end
end
uColorVals = unique(colorVals,'rows');
% uCV = findValsAroundMean(uColorVals(:,1:3),[3 100]);
setParameter(handles,'String Color',uColorVals);
checkStatusOfColors(handles);
figure(10);close(gcf);

% --- Executes on button press in pushbutton_help.
function pushbutton_help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileName = fullfile(pwd,'Help//Help Doc.htm');
web(fileName);

% --- Executes on button press in pushbutton_resetZoom.
function pushbutton_resetZoom_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_resetZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% stop(handles.timer_video_loader)
md = get_meta_data(handles);
setParameter(handles,'Zoom Window',[1 1 md.frame_size(2) md.frame_size(1)]);
value = round(get(handles.slider1,'Value'));
% displayFrames(handles,value);
pushbutton_disp_update_Callback(handles.pushbutton_disp_update, eventdata, handles)

% --- Executes on button press in pushbutton_manuallyTag.
function pushbutton_manuallyTag_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_manuallyTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fn = get(handles.figure1,'userdata');
manuallyTag(handles,fn);

% --- Executes on button press in pushbutton_about.
function pushbutton_about_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
About

% --- Executes on button press in checkbox_displayHandTags.
function checkbox_displayHandTags_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayHandTags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayHandTags

% --- Executes on button press in checkbox_displayBodyAxis.
function checkbox_displayBodyAxis_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayBodyAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayBodyAxis

% --- Executes on button press in checkbox_displayEarTags.
function checkbox_displayEarTags_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayEarTags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayEarTags

% --- Executes on button press in pushbutton_plotSelectedEpoch.
function pushbutton_plotSelectedEpoch_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plotSelectedEpoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plotSelectedEpoch(handles);

% --- Executes on button press in pushbutton_userPlot.
function pushbutton_userPlot_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_userPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userPlot(handles);

% --- Executes on button press in pushbutton_userProcess.
function pushbutton_userProcess_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_userProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userProcess(handles);
% function findAllMasks(handles,startFrame,endFrame)
% global frames;
% zw = getParameter(handles,'Zoom Window');
% totalFrames = endFrame - startFrame + 1;
% h = waitbar(1/totalFrames,'Processing frames');
% for fni = 1:totalFrames
%     fn = startFrame-1+fni;
%     if ~get(hObject,'userdata')
%         break;
%     end
%     fn
%     thisFrame = frames{fn};
%     thisFrame = thisFrame(zw(2):zw(4),zw(1):zw(3),:);
%     tic
%     tMasks = find_masks(handles,thisFrame);
%     thisT = toc;
%     masksM(:,:,fn) = tMasks.Im;
%     masksH(:,:,fn) = tMasks.Ih;
%     masksS(:,:,fn) = tMasks.Is;
%     timeRemaining = ((thisT * (totalFrames - fni))/60);
%     waitbar(fni/totalFrames,h,sprintf('Processing frames %d/%d... time remaining %.2f minutes',fni,totalFrames,timeRemaining));
% end
% close(h);
% if fni == totalFrames
%     handles.md.preprocessMF.masksM = masksM;
%     handles.md.preprocessMF.masksH = masksH;
%     handles.md.preprocessMF.masksS = masksS;
%     handles.masksM = masksM;
%     handles.masksH = masksH;
%     handles.masksS = masksS;
%     guidata(handles.figure1,handles);
% end

% --- Executes on button press in pushbutton_selectRtEarColor.
function pushbutton_selectRtEarColor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectRtEarColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% selectAndStoreColors(handles,4);
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
fns = randi([sfn efn],1,5);
global frames;
colorVals = [];
for ii = 1:length(fns)
    fn = fns(ii);
    thisFrame = frames{fn};
    colorVals = [colorVals;selectPixelsAndGetHSV_1(thisFrame,20,handles,'Right Ear')];
end
uColorVals = unique(colorVals,'rows');
% uCV = findValsAroundMean(uColorVals(:,1:3),[3 100]);
setParameter(handles,'Right Ear Color',uColorVals);
checkStatusOfColors(handles);

function edit_earMaskTol_Callback(hObject, eventdata, handles)
% hObject    handle to edit_earMaskTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_earMaskTol as text
%        str2double(get(hObject,'String')) returns contents of edit_earMaskTol as a double

% --- Executes during object creation, after setting all properties.
function edit_earMaskTol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_earMaskTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_displayTags.
function checkbox_displayTags_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayTags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayTags

fn = round(get(handles.slider1,'Value'));
displayFrames(handles,fn);

% --- Executes on button press in checkbox_scaleBar.
function checkbox_scaleBar_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_scaleBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_scaleBar
if get(hObject,'Value')
    fn = round(get(handles.slider1,'Value'));
    displayFrames(handles,fn);
end

% --- Executes on button press in pushbutton_measure.
function pushbutton_measure_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_measure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if strcmp(get(handles.timer_video_loader,'Running'),'on')
%     stop(handles.timer_video_loader);
% end
fn = round(get(handles.slider1,'Value'));
frames = get_frames(handles);
hf = figure(10);
set(hf,'WindowStyle','modal');
imshow(frames{fn});
axis equal; axis off;
tdx = 20;
tdy = 20;
text(tdx,tdy,sprintf('Draw a line on an object(by clicking and dragging)'));
hline = imline(gca);
set(hf,'WindowStyle','normal');
if isempty(hline)
    displayFrames(handles,fn);
    return;
end
pos = round(hline.getPosition);
close(hf);
% left = pos(1,1);
% right = pos(2,1);
diffP = diff(pos,1,1);
% numPixels = right - left;
numPixels = sqrt(sum(diffP.^2));
scale = getParameter(handles,'Scale');
display([numPixels scale * numPixels]);
displayFrames(handles,fn);
set(handles.figure1,'userdata',fn);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text_hand.
function text_hand_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text_hand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if get(hObject,'userdata')
%     set(hObject,'userdata',0);
%     set(handles.edit_handMaskTol,'String',num2str(handles.md.resultsMF.colorTol(1,1)));
% else
%     set(hObject,'userdata',1);
%     set(handles.edit_handMaskTol,'String',num2str(handles.md.resultsMF.colorTol(2,1)));
% end
% fn = get(handles.figure1,'userdata');
% displayMasks(handles,fn);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text_ear.
function text_ear_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text_ear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if get(hObject,'userdata')
%     set(hObject,'userdata',0);
%     set(handles.edit_earMaskTol,'String',num2str(handles.md.resultsMF.colorTol(1,4)));
% else
%     set(hObject,'userdata',1);
%     set(handles.edit_earMaskTol,'String',num2str(handles.md.resultsMF.colorTol(2,4)));
% end
% fn = get(handles.figure1,'userdata');
% displayMasks(handles,fn);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text_string.
function text_string_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if get(hObject,'userdata')
%     set(hObject,'userdata',0);
%     set(handles.edit_stringMaskTol,'String',num2str(handles.md.resultsMF.colorTol(1,3)));
% else
%     set(hObject,'userdata',1);
%     set(handles.edit_stringMaskTol,'String',num2str(handles.md.resultsMF.colorTol(2,3)));
% end
% fn = get(handles.figure1,'userdata');
% displayMasks(handles,fn);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text_fur.
function text_fur_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text_fur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if get(hObject,'userdata')
%     set(hObject,'userdata',0);
%     set(handles.edit_mouseMaskTol,'String',num2str(handles.md.resultsMF.colorTol(1,2)));
% else
%     set(hObject,'userdata',1);
%     set(handles.edit_mouseMaskTol,'String',num2str(handles.md.resultsMF.colorTol(2,2)));
% end
% fn = get(handles.figure1,'userdata');
% displayMasks(handles,fn);

% --- Executes on button press in pushbutton_fastPlay.
function pushbutton_fastPlay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fastPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Visible','Off');
set(handles.pushbutton_stopPlay,'userdata',0,'Visible','On');
fn = round(get(handles.slider1,'Value'));
h = figure(1001);clf;
ha = axes;
md = get_meta_data(handles);
numFrames = fn+md.disp.numFrames-1;%(handles.d.number_of_frames-1);
try
for ii = fn:numFrames
    if get(handles.pushbutton_stopPlay,'userdata')
        break;
    end
    displayFrameWithTags(handles,ii,ha);
    pause(0.1);
end
catch
    rethrow(lasterror);
end
% displayMasks(handles,fn);
set(handles.pushbutton_stopPlay,'Visible','Off');
set(hObject,'Visible','On');
close(h);

% --- Executes on button press in pushbutton_exportToExcel.
function pushbutton_exportToExcel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_exportToExcel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Please wait ... writing to excel file');
data = get(handles.epochs,'Data');
currentSelection = get(handles.epochs,'userdata');
if isempty(currentSelection)
    displayMessage(handles,'Please select an epoch first');
    return;
end
fn = data{currentSelection};
if isempty(fn)
    return;
end
startEnd = cell2mat(data(currentSelection(1),:));
sfn = startEnd(1);
numFrames = startEnd(2)-startEnd(1)+1;
efn = sfn+numFrames-1;

handles.md = get_meta_data(handles);
handles.d = get_data(handles);
frames = handles.d.frames;
times = handles.d.frame_times;

try
    out = get_all_params(handles,sfn,efn,0);
catch
    props = {'FontSize',11,'ForegroundColor','r'};displayMessage(handles,'An error occured while fetching data',props);
    close_extra_windows(handles);
    rethrow(lasterror);
    return;
end
enable_disable(handles,0);
set(handles.pushbutton_stop_processing,'visible','on');
tFN = sprintf('XL_frame%d_frame%d.xls',sfn,efn);
fileName = fullfile(handles.md.processed_data_folder,tFN);
props = {'FontSize',11,'ForegroundColor','b'};displayMessage(handles,'Preparing data',props);
fieldNames = fields(out);
colNum = 1;headings = []; dataT = [];
headings{colNum} = 'Frame Number';
dataT(:,colNum) = out.fns;
colNum = colNum + 1;
headings{colNum} = 'Frame Time';
dataT(:,colNum) = out.times;
for ii = 3:length(fieldNames)
    cmdTxt = sprintf('thisField = out.%s;',fieldNames{ii});
    eval(cmdTxt);
    subFieldNames = fields(thisField);
    for jj = 1:length(subFieldNames)
        cmdTxt = sprintf('thisField1 = thisField.%s;',subFieldNames{jj});
        eval(cmdTxt);
        if isstruct(thisField1)
            continue;
        end
        if size(thisField1,2) == 1
            colNum = colNum + 1;
            headings{colNum} = sprintf('%s_%s',fieldNames{ii},subFieldNames{jj});
            dataT(:,colNum) = thisField1;
        end
        if size(thisField1,2) == 2
            colNum = colNum + 1;
            headings{colNum} = sprintf('%s_%s_X',fieldNames{ii},subFieldNames{jj});
            dataT(:,colNum) = thisField1(:,1);
            colNum = colNum + 1;
            headings{colNum} = sprintf('%s_%s_Y',fieldNames{ii},subFieldNames{jj});
            dataT(:,colNum) = thisField1(:,2);
        end
    end
end
displayMessage(handles,'Writing to Excel file ... plz wait',props);
pause(0.1);
temp1 = xlsColNum2Str(1); temp2 = xlsColNum2Str(length(headings));
rnge = sprintf('%s1:%s1',temp1{1},temp2{1});
xlswrite(fileName,headings,1,rnge);
xlswrite(fileName,dataT,1,sprintf('%s2:%s%d',temp1{1},temp2{1},size(dataT,1)+1));
disp('Complete!');
props = {'FontSize',12,'ForegroundColor','r'};
displayMessage(handles,sprintf('Hurray !!! Done writing to Excel file ... %s',tFN),props);
winopen(handles.md.processed_data_folder);
enable_disable(handles,1);
set(handles.pushbutton_stop_processing,'visible','off');

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text_folderName.
function text_folderName_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text_folderName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.d = get_meta_data(handles);
winopen(handles.d.file_path);

function uipanel4_ButtonDownFcn(event,handles)
n = 0;

% --- Executes on button press in checkbox_framesDifference.
function checkbox_framesDifference_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_framesDifference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_framesDifference
fn = round(get(handles.slider1,'Value'));
displayFrames(handles,fn);

% --- Executes on button press in pushbutton_selectHandColorDiff.
function pushbutton_selectHandColorDiff_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectHandColorDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectAndStoreColors(handles,101);

% --- Executes on button press in pushbutton_selectStringColorDiff.
function pushbutton_selectStringColorDiff_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectStringColorDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectAndStoreColors(handles,102);

% --- Executes on button press in pushbutton_selectHandMinusStringColorDiff.
function pushbutton_selectHandMinusStringColorDiff_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectHandMinusStringColorDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectAndStoreColors(handles,103);

% --- Executes on button press in pushbutton_selectColorsInDiffHelp.
function pushbutton_selectColorsInDiffHelp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectColorsInDiffHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in uibuttongroup2.
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup2 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkbox_framesDifference,'Value')
    fn = round(get(handles.slider1,'Value'));
    displayFrames(handles,fn);
end


% --- Executes on button press in pushbutton_find_masks.
function pushbutton_find_masks_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_find_masks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if ~strcmp(get(handles.text_fileName,'String'),sprintf('File: %s',handles.d.file_name))
%     displayMessageBlinking(handles,'Please wait for completion of file loading',{'ForegroundColor','r'},3);
%     return;
% end
ok = checkStatusOfSteps(handles);
if ~ok
    return;
end
framesToProcess = get(handles.uibuttongroup_framesToProcess,'userdata');
objectToProcess = get(handles.uibuttongroup_objectToProcess,'userdata');
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
set_processing_mode_gui(handles,1);
try
    switch objectToProcess
        case 1
            find_masks(handles,'body',sfn,efn);
        case 2
            find_masks(handles,'ears',sfn,efn);
        case 3
            find_masks(handles,'hands',sfn,efn);
%             find_masks(handles,'hands_bd',sfn,efn);
        case 4
            find_masks(handles,'nose',sfn,efn);
        case 5
            find_masks(handles,'string',sfn,efn);
        case 6
            find_masks(handles,'all',sfn,efn);
    end
catch
    fn = get(handles.pushbutton_stop_processing,'userdata');
    props = {'FontSize',12,'ForegroundColor','r'};
    displayMessage(handles,sprintf('Sorry :-( ... error occurred in frame %d',fn),props);
    rethrow(lasterror);
end
set_processing_mode_gui(handles,0);
switch framesToProcess
    case 1
        displayMasks(handles,sfn);
end
set_focus_display_window(handles);


% --- Executes on button press in checkbox_useKnnMasks.
function checkbox_useKnnMasks_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_useKnnMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_useKnnMasks


% --- Executes on button press in pushbutton_makeVideoWithTags.
function pushbutton_makeVideoWithTags_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_makeVideoWithTags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.epochs,'Data');
currentSelection = get(handles.epochs,'userdata');
if isempty(currentSelection)
    displayMessageBlinking(handles,'Please select an epoch',{},4);
end
fn = data{currentSelection};
if isempty(fn)
    return;
end
startEnd = cell2mat(data(currentSelection(1),:));
sfn = startEnd(1);
efn = startEnd(2);
numFrames = startEnd(2)-startEnd(1)+1;

opts.Interpreter = 'tex';
opts.Default = 'No';
% Use the TeX interpreter to format the question
quest = sprintf('Do you want to proceed with %d frames, it might take a while',numFrames);
answer = questdlg(quest,'Please select',...
                  'Yes','No',opts);
if strcmp(answer,'No')
    return;
end

frames = get_frames(handles);
handles.d = get_data(handles);
times = handles.d.frame_times;
handles.md = get_meta_data(handles);
fileName = [handles.md.processed_data_folder sprintf('/video_%d_%d',sfn,efn)];
out = get_all_params(handles,sfn,efn,2);
fns = sfn:efn;
thisTimes = times(fns);
% 
% ff = makeFigureRowsCols(104,[22 3.5 1.5 3.5],'RowsCols',[1 1],...
%     'spaceRowsCols',[0.03 0.0225],'rightUpShifts',[0.12 0.3],'widthHeightAdjustment',...
%     [-150 -400]);
% gg = 1;
% set(gcf,'color','w');
figure(22);clf;
zw = getParameter(handles,'Zoom Window');
scale = getParameter(handles,'Scale');
% zw = zw1 + [150 150 -300 0];
aC = out.body.fit;
xrs = out.right_hand.centroid(:,1);
yrs = out.right_hand.centroid(:,2);
xls = out.left_hand.centroid(:,1);
yls = out.left_hand.centroid(:,2);
totalFrames = length(xrs);

if ~get(handles.checkbox_labeled_video_only_frames,'Value')
    figure(22);clf;
    pv = axes('Position',[0.01 0.25 0.2 0.55]);
    pheight = 0.09;
    spBetRows = 0.06+pheight;
    ypos = 0.1:spBetRows:1;
    % ypos = fliplr(ypos);
    for ii = 1:6
        pls(ii) = axes('Position',[0.29 ypos(ii) 0.69 pheight]);
    end
else
    figure(22);clf;
end
nans = NaN(1,length(fns));

v = VideoWriter(fileName,'MPEG-4');
open(v);
indF = find(fns == 412);
dispProps = get(handles.pushbutton_select_annotation_colors,'userdata');
autoManualCharacters = 'BENH';
for ii = 1:length(fns)
    fn = fns(ii);
    frame = frames{fn};
    if ~get(handles.checkbox_labeled_video_only_frames,'Value')
        axes(pv);
    end
    cla
    imagesc(frame);
    axis equal;
    axis off;
    hold on;
    C = aC(ii);
    plot(C.Major_axis_xs,C.Major_axis_ys,dispProps.bodyEllipse_color);
    plot(C.Minor_axis_xs,C.Minor_axis_ys,dispProps.bodyEllipse_color);
    plot(C.Ellipse_xs,C.Ellipse_ys,dispProps.bodyEllipse_color);
    point = out.right_hand.centroid(ii,:);
    plot(point(1),point(2),sprintf('.%s',dispProps.rightHand_dot_color),'MarkerSize',20);
    
    point = out.left_hand.centroid(ii,:);
    plot(point(1),point(2),sprintf('.%s',dispProps.leftHand_dot_color),'MarkerSize',20);
    
    point = out.nose.centroid(ii,:);
    plot(point(1),point(2),sprintf('*%s',dispProps.nose_dot_color),'MarkerSize',10);
    
    point = out.right_ear.centroid(ii,:);
    plot(point(1),point(2),sprintf('.%s',dispProps.rightEar_dot_color),'MarkerSize',20);
    point1 = point;
    
    point = out.left_ear.centroid(ii,:);
    plot(point(1),point(2),sprintf('.%s',dispProps.leftEar_dot_color),'MarkerSize',20);
    point2 = point;
    
%     plot([point1(1) point2(1)],[point1(2) point2(2)],'r','linewidth',2);
    
    pxls = out.right_hand.boundary_pixels(ii).ps;
    [rr,cc] = ind2sub(handles.md.frame_size,pxls);
    plot(cc,rr,dispProps.rightHand_line_color,'linewidth',2);
    pxls = out.left_hand.boundary_pixels(ii).ps;
    [rr,cc] = ind2sub(handles.md.frame_size,pxls);
    plot(cc,rr,dispProps.leftHand_line_color,'linewidth',2);
    pxls = out.right_ear.boundary_pixels(ii).ps;
    [rr,cc] = ind2sub(handles.md.frame_size,pxls);
    plot(cc,rr,dispProps.rightEar_line_color,'linewidth',2);
    pxls = out.left_ear.boundary_pixels(ii).ps;
    [rr,cc] = ind2sub(handles.md.frame_size,pxls);
    plot(cc,rr,dispProps.leftEar_line_color,'linewidth',2);
    xlim([zw(1)-50 zw(3)+50]);
    ylim([zw(2)-50 zw(4)]);
%     text(zw(1) + 15,zw(2) + 15,sprintf('Frame - %d, Time - %.3f secs',fn,thisTimes(ii)),'FontSize',11,'color',...
%         dispProps.TaggedVideo_Frame_Text_Color,'FontWeight','Normal');
 
    amcInds = [out.body.manual(ii),out.right_ear.manual(ii),out.nose.manual(ii),out.right_hand.manual(ii)];
    amcInds(isnan(amcInds)) = 0;
    autoManualText = autoManualCharacters(logical(amcInds));
    text(zw(1) + 15,zw(2) + 35,autoManualText,'FontSize',11,'color',dispProps.TaggedVideo_AutoManual_Text_Color,'FontWeight','Normal');
    
    if get(handles.checkbox_labeled_video_only_frames,'Value')
        Fr = getframe(gcf);
        writeVideo(v,Fr);
        pause(0.1);
        continue;
    end
    var = nans; tvar = out.body.length*scale; mtvar = min(tvar); Mtvar = max(tvar); dV = (Mtvar - mtvar)/10;
    mtvar = mtvar - dV; Mtvar = Mtvar + dV;
    var(1:ii) = out.body.length(1:ii)*scale;
    axes(pls(6));cla;
    plot(var,'g');
    ylim([mtvar Mtvar]);xlim([1 totalFrames]);set(gca,'XTickLabel',[],'FontSize',11,'FontWeight','Bold','TickDir','out');
    ylabel('mm');title('Body Length');box off;
%     ylims = ylim;text(10,ylims(2),'Body Length');
    
    var = nans; tvar = out.body.angle; mtvar = min(tvar); Mtvar = max(tvar); dV = (Mtvar - mtvar)/10;
    mtvar = mtvar - dV; Mtvar = Mtvar + dV;
    var(1:ii) = out.body.angle(1:ii);
    axes(pls(5));cla;
    plot(var,'g');
    ylim([mtvar Mtvar]);xlim([1 totalFrames]);set(gca,'XTickLabel',[],'FontSize',11,'FontWeight','Bold','TickDir','out');
    ylabel('Deg');title('Body Angle');box off;
%     ylims = ylim;text(10,ylims(2),'Body Angle');
    
    var = nans; tvar = out.head.roll; mtvar = min(tvar); Mtvar = max(tvar); dV = (Mtvar - mtvar)/10;
    mtvar = mtvar - dV; Mtvar = Mtvar + dV;
    var(1:ii) = out.head.roll(1:ii);
    if sum(isnan(var)) < length(var)
        axes(pls(4));cla;
        plot(var,'b');
        ylim([mtvar Mtvar]);xlim([1 totalFrames]);set(gca,'XTickLabel',[],'FontSize',11,'FontWeight','Bold','TickDir','out');
        ylabel('Deg');title('Head Roll Angle');box off;
    end
%     ylims = ylim;text(10,ylims(2),'Head Roll Angle');

    
    var = nans; tvar = out.head.yaw; mtvar = min(tvar); Mtvar = max(tvar); dV = (Mtvar - mtvar)/10;
    mtvar = mtvar - dV; Mtvar = Mtvar + dV;
    var(1:ii) = out.head.yaw(1:ii);
    if sum(isnan(var)) < length(var)
        axes(pls(3));cla;
        plot(var,'b');
        if Mtvar > 0
            ylim([-Mtvar Mtvar]);
        else
            ylim([Mtvar -Mtvar]);
        end
        xlim([1 totalFrames]);set(gca,'XTickLabel',[],'FontSize',11,'FontWeight','Bold','TickDir','out');
        ylabel('Arb.');title('Head Yaw');box off;
    end
%     ylims = ylim;text(10,ylims(2),'Head Yaw');
    
    var = nans; tvar = (xls)*scale; mtvar = min(tvar); Mtvar = max(tvar); dV = (Mtvar - mtvar)/10;
    mtvar = mtvar - dV; Mtvar = Mtvar + dV;
    var(1:ii) = (xls(1:ii))*scale;
    axes(pls(2));cla;
    plot(var,'m');hold on;
    var(1:ii) = (xrs(1:ii))*scale;
    plot(var,'c');
    ylim([mtvar Mtvar]);xlim([1 totalFrames]);set(gca,'XTickLabel',[],'FontSize',11,'FontWeight','Bold','TickDir','out');
    ylabel('mm');title('Hands X');box off;
%     ylims = ylim;text(10,ylims(2),'Hands X');
    
    var = nans; tvar = (yls)*scale; mtvar = min(tvar); Mtvar = max(tvar); dV = (Mtvar - mtvar)/10;
    mtvar = mtvar - dV; Mtvar = Mtvar + dV;
    var(1:ii) = (yls(1:ii))*scale;
    axes(pls(1));cla;
    plot(var,'m');hold on;
    var(1:ii) = (yrs(1:ii))*scale;
    plot(var,'c');
    ylim([mtvar Mtvar]);xlim([1 totalFrames]);
    ylabel('mm');title('Hands Y');xlabel('Frames');box off;
    set(gca,'FontSize',11,'FontWeight','Bold','TickDir','out');
%     ylims = ylim;text(10,ylims(2),'Hands Y');
    
    Fr = getframe(gcf);
    writeVideo(v,Fr);
    pause(0.1);

    n = 0;
end
close(v);
display('Done making video');


% --- Executes on button press in pushbutton_setTouchingHandsThreshold.
function pushbutton_setTouchingHandsThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setTouchingHandsThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fn = get(handles.figure1,'userdata');
try
    sarea = setTouchingHandsThreshold(handles,fn);
    % sarea = sarea - (sarea/3);
    setParameter(handles,'Touching Hands Area',sarea);
    set(handles.text_touchingHandsArea,'String',{'Touching Hands Area',sprintf('%d Pixels',sarea)});
catch
    displayMessageBlinking(handles,'Touching hands area threshold was not changed',{'ForegroundColor','r'},3);
end


% --- Executes on button press in checkbox_displayMasks.
function checkbox_displayMasks_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayMasks
displayMessageBlinking(handles,'Please wait ... ',{'FontSize',14},2);
displayMessage(handles,'Please wait',{'FontSize',14});
value = round(get(handles.slider1,'Value'));
displayFrames(handles,value);
displayMessage(handles,'',{'FontSize',10});


% --- Executes on button press in pushbutton_find_object.
function pushbutton_find_object_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_find_object (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ok = checkStatusOfSteps(handles);
if ~ok
    return;
end
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
set_processing_mode_gui(handles,1);
objectToProcess = get(handles.uibuttongroup_objectToProcess,'userdata');
objectMap = {'body','ears','hands','nose','string'};
find_object(handles,sfn,efn,objectMap{objectToProcess});
% try
%     switch objectToProcess
%         case 1
%             findBody(handles,sfn,efn);
%         case 2
%             findEars(handles,sfn,efn);
%         case 3
%             findHands(handles,sfn,efn);
%         case 4
%             findNose(handles,sfn,efn);
%         case 5
%             findString(handles,sfn,efn);
%         case 6
%             findBody(handles,sfn,efn);
%             findEars(handles,sfn,efn);
%             findHands(handles,sfn,efn);
%             findNose(handles,sfn,efn);
% %             findString(handles,sfn,efn);
%     end
% catch
%     fn = get(handles.pushbutton_stop_processing,'userdata');
%     props = {'FontSize',12,'ForegroundColor','r'};
%     displayMessage(handles,sprintf('Sorry ... :-( ... error occurred in frame %d ... use manual tagging',fn),props);
%     enable_disable(handles,1);
%     set(handles.pushbutton_stop_processing,'visible','off');
%     rethrow(lasterror);
% end
set_processing_mode_gui(handles,0);
set_focus_display_window(handles);

% --- Executes on button press in pushbutton_erase.
function pushbutton_erase_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_erase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ok = checkStatusOfSteps(handles);
if ~ok
    return;
end
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
enable_disable(handles,0);
set(handles.pushbutton_stop_processing,'visible','on');
objectToProcess = get(handles.uibuttongroup_objectToProcess,'userdata');
objectMap = {'body','ears','hands','nose','string'};
try
    erase_object(handles,sfn,efn,objectMap{objectToProcess});
catch
    displayMessage(handles,sprintf('Error occurred',get(handles.pushbutton_stop_processing,'userdata')));
end
enable_disable(handles,1);
set(handles.pushbutton_stop_processing,'visible','off');


function edit_numberOfClusters_Callback(hObject, eventdata, handles)
% hObject    handle to edit_numberOfClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_numberOfClusters as text
%        str2double(get(hObject,'String')) returns contents of edit_numberOfClusters as a double
nClus = getParameter(handles,'Number of Color Clusters');
nnClus = str2double(get(hObject,'String'));
if isempty(nnClus)
    set(hObject,'String',num2str(nClus));
else
    setParameter(handles,'Number of Color Clusters',nnClus);
end

% --- Executes during object creation, after setting all properties.
function edit_numberOfClusters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_numberOfClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton_manual.
function pushbutton_manual_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ok = checkStatusOfSteps(handles);
if ~ok
    return;
end
sfn = get(handles.figure1,'userdata');
efn = sfn;
objectToProcess = get(handles.uibuttongroup_objectToProcess,'userdata');
switch objectToProcess
    case 1
        manuallyTagBody(handles,sfn);
    case 2
        manuallyTagEars(handles,sfn);
    case 3
        manuallyTagHands(handles,sfn);
    case 4
        manuallyTagNose(handles,sfn);
end
axes(handles.axes_main);cla;set(handles.axes_main,'visible','off');

% --- Executes when selected object is changed in uibuttongroup_framesToProcess.
function uibuttongroup_framesToProcess_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup_framesToProcess 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
values = {'Selected Frame','Frames in Display Window','Epoch','Range'};
thisVal = get(hObject,'String');
indexC = strfind(values,thisVal);
tag = find(not(cellfun('isempty', indexC)));
set(handles.uibuttongroup_framesToProcess,'userdata',tag);


% --- Executes when selected object is changed in uibuttongroup_objectToProcess.
function uibuttongroup_objectToProcess_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup_objectToProcess 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
values = {'Body','Ears','Hands','Nose','String','All'};
panels = {'uipanel_body','uipanel_ears','uipanel_hands_identification_parameters','uipanel_nose','',''};

indexC = strfind(values,eventdata.OldValue.String);
tag = find(not(cellfun('isempty', indexC)));
if ~isempty(panels{tag})
    cmdTxt = sprintf('set(handles.%s,''Visible'',''Off'');',panels{tag});eval(cmdTxt);
end

thisVal = get(hObject,'String');
indexC = strfind(values,thisVal);
tag = find(not(cellfun('isempty', indexC)));
set(handles.uibuttongroup_objectToProcess,'userdata',tag);
if ~isempty(panels{tag})
    cmdTxt = sprintf('set(handles.%s,''Visible'',''On'');',panels{tag});eval(cmdTxt);
    cmdTxt = sprintf('set(handles.%s,''Title'',''%s Settings'');',panels{tag},values{tag});eval(cmdTxt);
end





% --- Executes on button press in checkbox_over_write.
function checkbox_over_write_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_over_write (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_over_write
% get(hObject,'Value')
if get(hObject,'Value')
    set(hObject,'ForegroundColor','r');
    set(handles.checkbox_over_write_2,'Value',1);set(handles.checkbox_over_write_2,'ForegroundColor','r');
else
    set(hObject,'ForegroundColor','b');
    set(handles.checkbox_over_write_2,'Value',0);set(handles.checkbox_over_write_2,'ForegroundColor','b');
end

% --- Executes on button press in pushbutton_epoch_add_row.
function pushbutton_epoch_add_row_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_epoch_add_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.epochs,'Data');
nrows = size(data,1);
data(nrows+1,1) = {[]};
data(nrows+1,2) = {[]};
set(handles.epochs,'Data',data);
setParameter(handles,'Epochs',data);

    
% --- Executes on button press in pushbutton_epoch_delete_row.
function pushbutton_epoch_delete_row_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_epoch_delete_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.epochs,'Data');
nrows = size(data,1);
selRow = get(handles.epochs,'UserData');
data(selRow(1),:) = [];
set(handles.epochs,'Data',data);
setParameter(handles,'Epochs',data);


% --------------------------------------------------------------------
function uipanel_messages_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel_messages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% enable_disable(handles,1);
if get(handles.text_processing,'userdata') == 0
    enable_disable(handles,1);
end
props = {'FontSize',9,'ForegroundColor','b'};displayMessage(handles,sprintf(''),props);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text_processing.
function text_processing_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text_processing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
md = get_meta_data(handles);
if isempty(md)
    set(handles.figure1, 'PaperPositionMode', 'auto')
    filename = fullfile(pwd,'Help','GitHub_Wiki_Resources','gui.png');
    saveas(handles.figure1,filename);
else
    filename = fullfile(pwd,'Help','GitHub_Wiki_Resources','gui.png');
    saveas(handles.figure1,filename);
    filename = fullfile(pwd,'Help','GitHub_Wiki_Resources','dispw.png');
    saveas(md.disp.ff.hf,filename);
end
if get(hObject,'userdata') == 0
    enable_disable(handles,1);
end
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,sprintf(''),props);
clc


% --- Executes on button press in pushbutton_stop_processing.
function pushbutton_stop_processing_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop_processing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.text_processing,'userdata',0);
set_processing_mode_gui(handles,0);


% --- Executes on slider movement.
function slider_HM_Callback(hObject, eventdata, handles)
% hObject    handle to slider_HM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.edit_handMaskTol,'String',num2str(val));
if ~get(handles.text_hand,'userdata')
    handles.md.resultsMF.colorTol(1,1) = val;
else
    handles.md.resultsMF.colorTol(2,1) = val;
end
fn = get(handles.figure1,'userdata');
displayMasks(handles,fn);

% --- Executes during object creation, after setting all properties.
function slider_HM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_HM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_handMaskTol_Callback(hObject, eventdata, handles)
% hObject    handle to edit_handMaskTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_handMaskTol as text
%        str2double(get(hObject,'String')) returns contents of edit_handMaskTol as a double


% --- Executes during object creation, after setting all properties.
function edit_handMaskTol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_handMaskTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_SM_Callback(hObject, eventdata, handles)
% hObject    handle to slider_SM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.edit_stringMaskTol,'String',num2str(val));
if ~get(handles.text_string,'userdata')
    handles.md.resultsMF.colorTol(1,3) = val;
else
    handles.md.resultsMF.colorTol(2,3) = val;
end
fn = get(handles.figure1,'userdata');
displayMasks(handles,fn);

% --- Executes during object creation, after setting all properties.
function slider_SM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_SM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_stringMaskTol_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stringMaskTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stringMaskTol as text
%        str2double(get(hObject,'String')) returns contents of edit_stringMaskTol as a double


% --- Executes during object creation, after setting all properties.
function edit_stringMaskTol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stringMaskTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_MM_Callback(hObject, eventdata, handles)
% hObject    handle to slider_MM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.edit_mouseMaskTol,'String',num2str(val));
fn = get(handles.figure1,'userdata');
displayMaskFur(handles,fn);

% --- Executes during object creation, after setting all properties.
function slider_MM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_MM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_mouseMaskTol_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mouseMaskTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mouseMaskTol as text
%        str2double(get(hObject,'String')) returns contents of edit_mouseMaskTol as a double


% --- Executes during object creation, after setting all properties.
function edit_mouseMaskTol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mouseMaskTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_EM_Callback(hObject, eventdata, handles)
% hObject    handle to slider_EM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.edit_earMaskTol,'String',num2str(val));
if ~get(handles.text_ear,'userdata')
    handles.md.resultsMF.colorTol(1,4) = val;
else
    handles.md.resultsMF.colorTol(2,4) = val;
end
fn = get(handles.figure1,'userdata');
displayMaskFur(handles,fn);

% --- Executes during object creation, after setting all properties.
function slider_EM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_EM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox_Reduce_Image_Size.
function checkbox_Reduce_Image_Size_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Reduce_Image_Size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_Reduce_Image_Size
% if get(handles.checkbox_Reduce_Image_Size,'Value')
%     set(handles.uipanel_view_and_refine_masks,'Visible','On');
%     set(handles.pushbutton_find_masks,'Visible','Off');
% else
%     set(handles.uipanel_view_and_refine_masks,'Visible','Off');
%     set(handles.pushbutton_find_masks,'Visible','On');
% end


% --- Executes on button press in pushbutton_exit.
function pushbutton_exit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);

% --- Executes on slider movement.
function slider_numberOfClusters_Callback(hObject, eventdata, handles)
% hObject    handle to slider_numberOfClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
set(handles.edit_numberOfClusters,'String',num2str(val));
setParameter(handles,'Number of Color Clusters',val);


% --- Executes during object creation, after setting all properties.
function slider_numberOfClusters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_numberOfClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_fileOpen.
function pushbutton_fileOpen_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fileOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject,'String'),'Stop Loading')
    set(hObject,'userdata',1,'String','Select a Video File');
    return;
end
% load data
[success,data] = load_data(handles);
if ~success
    return;
end
set(handles.text_fileName,'userdata',data.file_name);
set(handles.text_folderName,'userdata',data.file_path);
set(handles.text_data,'userdata',data);

% load meta data
[success,meta_data] = load_meta_data(handles);
if ~success
    return;
end
set(handles.text_params,'userdata',meta_data.params);
disp = initializeDisplayWindow (handles);
meta_data.disp = disp;
meta_data.file_name  = data.file_name;
meta_data.file_path = data.file_path;
meta_data.frame_times  = data.frame_times;
meta_data.number_of_frames = data.number_of_frames;
meta_data.frame_size = data.frame_size;
set_meta_data(handles,meta_data);

% load processed data
try
    [success,processed_data] = load_processed_data(handles);
catch
    success = 0;
end
if ~success
    return;
end
set_processed_data(handles,processed_data);

initializeDisplay (handles);
set(handles.text_meta_data,'userdata',meta_data);
enable_disable_1(handles,2,1);
set(handles.pushbutton_fileOpen,'visible','off');
displayFrames(handles,1);
set(disp.ff.hf,'Units','pixels');
displayWindowSize = get(disp.ff.hf,'Position');
mainWindowSize = get(handles.figure1,'Position');
screenSize = get(0,'ScreenSize');
left = mainWindowSize(1) + mainWindowSize(3)+10;
bottom = floor(mainWindowSize(2) - (mainWindowSize(2)/4));
width = screenSize(3) - left - 10;
height = screenSize(4) - bottom - 100;
set(disp.ff.hf,'Position',[left bottom width height]);
whs{1} = disp.ff.hf;
set(handles.pushbutton_close_extra_windows,'userdata',whs);
set(disp.ff.hf,'visible','on');


% --- Executes on button press in checkbox_overwriteMasks.
function checkbox_overwriteMasks_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_overwriteMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_overwriteMasks


% --- Executes on button press in pushbutton_saveMasks.
function pushbutton_saveMasks_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global masks;
fileName = sprintf('masks.mat');
fullfileName = fullfile(handles.md.processedDataFolder,fileName);
tic
save(fullfileName, '-struct', 'masks','-v7.3');
displayMessage(handles,sprintf('Saved !!! -- time taken = %.3f mins',toc/60));
set(handles.pushbutton_saveMasks,'Enable','Off');



function edit_go_to_frame_Callback(hObject, eventdata, handles)
% hObject    handle to edit_go_to_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_go_to_frame as text
%        str2double(get(hObject,'String')) returns contents of edit_go_to_frame as a double
% val = get(handles.edit_go_to_frame,'String');
% fn = str2num(val);
% displayFrames(handles,fn);

% --- Executes during object creation, after setting all properties.
function edit_go_to_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_go_to_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_displayAreas.
function checkbox_displayAreas_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayAreas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayAreas
value = round(get(handles.slider1,'Value'));
displayFrames(handles,value);


% --- Executes on button press in pushbutton_stopPlay.
function pushbutton_stopPlay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stopPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton_stopPlay,'userdata',1,'Visible','Off');
set(handles.pushbutton_fastPlay,'Visible','On');


% --- Executes on button press in pushbutton_findMouse.
function pushbutton_findMouse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_findMouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if ~strcmp(get(handles.text_fileName,'String'),sprintf('File: %s',handles.d.file_name))
%     displayMessageBlinking(handles,'Please wait for completion of file loading',{'ForegroundColor','r','FontSize',12},3);
%     return;
% end
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
frameNums = getAllEpochFrameNums(handles);
if isempty(frameNums)
    displayMessageBlinking(handles,'Fill in epochs table correctly',{'ForegroundColor','r','FontSize',12},2);
    return;
end
enable_disable(handles,0);
try
    choices = {'Fully Automatic','Semi-automatic Blob Method'};
    choice = generalGUIForSelection(choices,1);
%     if ~get(handles.checkbox_find_zoom_auto,'Value')
    if choice == 2
        findBody_Coarse(handles,frameNums);
    else
        find_auto_zoom(handles,frameNums);
    end
catch
    displayMessageBlinking(handles,'Window closed or error occurred ... repeat process',{'ForegroundColor','r','FontSize',12},3);
end
enable_disable(handles,1);


% --- Executes on button press in checkbox_updateDisplay.
function checkbox_updateDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_updateDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_updateDisplay


% --- Executes on button press in pushbutton_selectLtEarColor.
function pushbutton_selectLtEarColor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectLtEarColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
fns = randi([sfn efn],1,5);
global frames;
colorVals = [];
for ii = 1:length(fns)
    fn = fns(ii);
    thisFrame = frames{fn};
    colorVals = [colorVals;selectPixelsAndGetHSV_1(thisFrame,20,handles,'Left Ear')];
end
uColorVals = unique(colorVals,'rows');
% uCV = findValsAroundMean(uColorVals(:,1:3),[3 100]);
setParameter(handles,'Left Ear Color',uColorVals);
checkStatusOfColors(handles);


% --- Executes on button press in pushbutton_refreshDisplay.
function pushbutton_refreshDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_refreshDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = round(get(handles.slider1,'Value'));
displayFrames(handles,value);
% pushbutton_disp_update_Callback(handles.pushbutton_disp_update, eventdata, handles);

function edit_MSER_Threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MSER_Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MSER_Threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_MSER_Threshold as a double
val = str2double(get(hObject,'String'));
setParameter(handles,'MSER Threshold',val);

% --- Executes during object creation, after setting all properties.
function edit_MSER_Threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MSER_Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_EucledianDistance_Callback(hObject, eventdata, handles)
% hObject    handle to edit_EucledianDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_EucledianDistance as text
%        str2double(get(hObject,'String')) returns contents of edit_EucledianDistance as a double
val = str2double(get(hObject,'String'));
setParameter(handles,'Eucledian Distance Threshold',val);

% --- Executes during object creation, after setting all properties.
function edit_EucledianDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_EucledianDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_userMSERMethod.
function checkbox_userMSERMethod_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_userMSERMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_userMSERMethod


% --- Executes on button press in checkbox_useHandsColorMask.
function checkbox_useHandsColorMask_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_useHandsColorMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_useHandsColorMask


% --- Executes on button press in pushbutton_ears.
function pushbutton_ears_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ears (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    selectColors(handles,'Ears');
catch
    figure(10);close(gcf);
    if get(handles.checkbox_rethrow_matlab_errors,'Value')
        rethrow(lasterror);
    end
end
return;
global frames;
colorVals = getParameter(handles,'Ears Color');
if ~isempty(colorVals)
    opts.Interpreter = 'tex';opts.Default = 'Yes';
    quest = 'Add to existing colors?';
    answer = questdlg(quest,'Please select',...
                      'Yes','No',opts);
    if strcmp(answer,'Yes')
        existCols = 1;
    else
        existCols = 0;
    end
else
    existCols = 0;
end
if existCols
    [sfn,efn] = getFrameNums(handles);
    if isnan(sfn) || isnan(efn)
        displayMessage(handles,'Select a valid frame range');
        return;
    end
    thisFrame = frames{sfn};
    colorVals = [colorVals;selectPixelsAndGetHSV_1(thisFrame,20,handles,'Right or Left Ear')];
else    
    [sfn,efn] = getFrameNums(handles);
    if isnan(sfn) || isnan(efn)
        displayMessage(handles,'Select a valid frame range');
        return;
    end
    fns = randi([sfn efn],1,3)
    colorVals = [];
    for ii = 1:length(fns)
        fn = fns(ii);
        thisFrame = frames{fn};
        colorVals = [colorVals;selectPixelsAndGetHSV_1(thisFrame,20,handles,'Right Ear')];
    end
    for ii = 1:length(fns)
        fn = fns(ii);
        thisFrame = frames{fn};
        colorVals = [colorVals;selectPixelsAndGetHSV_1(thisFrame,20,handles,'Left Ear')];
    end
end
uColorVals = unique(colorVals,'rows');
% uCV = findValsAroundMean(uColorVals(:,1:3),[3 100]);
setParameter(handles,'Ears Color',uColorVals);
checkStatusOfColors(handles);
figure(10);close(gcf);


% --- Executes on button press in pushbutton_selectNoseColors.
function pushbutton_selectNoseColors_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectNoseColors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    selectColors(handles,'Nose');
catch
    figure(10);close(gcf);
    if get(handles.checkbox_rethrow_matlab_errors,'Value')
        rethrow(lasterror);
    end
end
return;
global frames;
colorVals = getParameter(handles,'Nose Color');
if ~isempty(colorVals)
    opts.Interpreter = 'tex';opts.Default = 'Yes';
    quest = 'Add to existing colors?';
    answer = questdlg(quest,'Please select',...
                      'Yes','No',opts);
    if strcmp(answer,'Yes')
        existCols = 1;
    else
        existCols = 0;
    end
else
    existCols = 0;
end
if existCols
    [sfn,efn] = getFrameNums(handles);
    if isnan(sfn) || isnan(efn)
        displayMessage(handles,'Select a valid frame range');
        return;
    end
    thisFrame = frames{sfn};
    colorVals = [colorVals;selectPixelsAndGetHSV_1(thisFrame,20,handles,'Nose')];
else    
    [sfn,efn] = getFrameNums(handles);
    if isnan(sfn) || isnan(efn)
        displayMessage(handles,'Select a valid frame range');
        return;
    end
    fns = randi([sfn efn],1,5);
    colorVals = [];
    for ii = 1:length(fns)
        fn = fns(ii);
        thisFrame = frames{fn};
        colorVals = [colorVals;selectPixelsAndGetHSV_1(thisFrame,20,handles,'Nose')];
    end
end
uColorVals = unique(colorVals,'rows');
% uCV = findValsAroundMean(uColorVals(:,1:3),[3 100]);
setParameter(handles,'Nose Color',uColorVals);
checkStatusOfColors(handles);
figure(10);close(gcf);


% --- Executes on button press in pushbutton_showMask.
function pushbutton_showMask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_showMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
if sfn == efn
    displayMasks(handles,sfn);
end


% --- Executes on button press in checkbox_saveOnTheGo.
function checkbox_saveOnTheGo_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_saveOnTheGo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_saveOnTheGo
if strcmp(get(handles.pushbutton_saveData,'Enable'),'On')
    pause(0.3);
    pushbutton_saveData_Callback([],[],handles);
end
if get(hObject,'Value') 
    set(handles.pushbutton_saveData,'Enable','Off');
end

% --- Executes on button press in pushbutton_saveData.
function pushbutton_saveData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayMessageBlinking(handles,sprintf('Saving data ... please wait'),{'ForegroundColor','r'},2);
save_R_P_RDLC(handles);
displayMessage(handles,sprintf('Done saving'));
set(handles.pushbutton_saveData,'Enable','Off');


% --- Executes on button press in pushbutton_backgroundColor.
function pushbutton_backgroundColor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_backgroundColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    selectColors(handles,'Background');
catch
    figure(10);close(gcf);
    if get(handles.checkbox_rethrow_matlab_errors,'Value')
        rethrow(lasterror);
    end
end

% --- Executes on button press in checkbox_displayCMasks.
function checkbox_displayCMasks_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayCMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayCMasks
displayMessageBlinking(handles,'Please wait ... ',{'FontSize',14},2);
displayMessage(handles,'Please wait',{'FontSize',14});
value = round(get(handles.slider1,'Value'));
displayFrames(handles,value);
displayMessage(handles,'',{'FontSize',10});


function edit_fromFrame_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fromFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fromFrame as text
%        str2double(get(hObject,'String')) returns contents of edit_fromFrame as a double
set(handles.radiobutton_frameRange,'Value',1);
uibuttongroup_framesToProcess_SelectionChangedFcn(handles.uiuibuttongroup_framesToProcess, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function edit_fromFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fromFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_toFrame_Callback(hObject, eventdata, handles)
% hObject    handle to edit_toFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_toFrame as text
%        str2double(get(hObject,'String')) returns contents of edit_toFrame as a double
set(handles.radiobutton_frameRange,'Value',1);
uibuttongroup_framesToProcess_SelectionChangedFcn(handles.uiuibuttongroup_framesToProcess, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function edit_toFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_toFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dispRows_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dispRows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dispRows as text
%        str2double(get(hObject,'String')) returns contents of edit_dispRows as a double
% handles = initializeDisplayWindow (handles);
% guidata(handles.figure1,handles);
% d = handles.d;
% fn = round(get(handles.slider1,'Value'));
% set(handles.slider1,'value',fn, 'min',1, 'max',d.number_of_frames,'SliderStep', [1/d.number_of_frames , handles.disp.numFrames/d.number_of_frames],'userdata',1);
% displayFrames(handles,fn);


% --- Executes during object creation, after setting all properties.
function edit_dispRows_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dispRows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dispCols_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dispCols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dispCols as text
%        str2double(get(hObject,'String')) returns contents of edit_dispCols as a double


% --- Executes during object creation, after setting all properties.
function edit_dispCols_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dispCols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_process_nose_string.
function pushbutton_process_nose_string_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_process_nose_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ok = checkStatusOfSteps(handles);
if ~ok
    return;
end
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
enable_disable(handles,0);
set(handles.pushbutton_stop_processing,'visible','on');
frameNums = sfn:efn;
handles.md = get_meta_data(handles);
[present,LiaR,LiaP] = checkIfDataPresent(handles,frameNums,'nose');
[globalR,~,globalRDLCS] = get_R_P_RDLC(handles);
noseVals = globalR(LiaR,:);
[presentdlc,LiaRdlc] = checkIfDataPresent_DLC(handles,frameNums,'nose');
if presentdlc
    noseVals_dlc = globalRDLCS(LiaRdlc,:);
end
zw = getParameter(handles,'Auto Zoom Window');
for ii = 1:length(frameNums)
    tic
    if strcmp(get(handles.pushbutton_stop_processing,'visible'),'off')
        axes(handles.axes_main);cla;set(handles.axes_main,'visible','off');
        break;
    end
    fn = frameNums(ii);
    centroid = noseVals(noseVals(:,1)==fn,3:4) - [zw(1) zw(2)];
    mask = get_mask(handles,fn,5);
    d(ii) = NoseStrDist(centroid,mask);
    if presentdlc
        centroid_dlc = noseVals_dlc(noseVals_dlc(:,1)==fn,3:4) - [zw(1) zw(2)];
        d_dlc(ii) = NoseStrDist(centroid_dlc,mask);
    else
        d_dlc(ii) = NaN;
    end
    timeRemaining = getTimeRemaining(length(frameNums),ii);
    if ii > 1
        displayMessage(handles,sprintf('Finding %s ... Processing frame %d - %d/%d ... time remaining %s','nose-string distance',fn+1,ii+1,length(frameNums),timeRemaining));
    end
end
fileName = fullfile(handles.md.processed_data_folder,'nose_string_distance.mat');
save(fileName,'d');
fileName = fullfile(handles.md.processed_data_folder,'nose_string_distance_DLC.mat');
d = d_dlc;
save(fileName,'d');
displayMessage(handles,'Done !!!');
enable_disable(handles,1);
set(handles.pushbutton_stop_processing,'visible','off');


% --- Executes on button press in pushbutton_disp_update.
function pushbutton_disp_update_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_disp_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayMessage(handles,'Please wait I am updating display window');
disp = initializeDisplayWindow (handles);
md = get_meta_data(handles);
md.disp = disp;
set_meta_data(handles,md);
fn = round(get(handles.slider1,'Value'));
set(handles.slider1,'value',fn, 'min',1, 'max',md.number_of_frames,'SliderStep', [1/md.number_of_frames , md.disp.numFrames/md.number_of_frames],'userdata',1);
displayFrames(handles,fn);
displayMessage(handles,'Display window updated');

% --- Executes on button press in pushbutton_disp_go.
function pushbutton_disp_go_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_disp_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.edit_go_to_frame,'String');
try
    fn = str2num(val);
    displayFrames(handles,fn);
catch
end


% --- Executes on button press in pushbutton_post_processing_load_DLC_data.
function pushbutton_post_processing_load_DLC_data_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_post_processing_load_DLC_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[R,P,globalRDLCS] = get_R_P_RDLC(handles);;
ind = generalGUIForSelection({'Hands - Separately Found', 'Ears - Separately Found', 'Nose - Separately Found','All Found Together'},1);
if ind == 0
    return;
end
handles.d = get_data(handles);
[fileName,path] = uigetfile('*.csv');
if isempty(strfind(fileName,handles.d.file_name(1:end-4)))
    displayMessage(handles,'Looks like you picked the wrong file');
    answer = questdlg('Filenames do not match ... Would you like to continue?','Looks like you picked the wrong file');
    if strcmp(answer,'No')
        return;
    end
end
fileName = fullfile(path,fileName);

if ~isempty(globalRDLCS)
    opts.Interpreter = 'tex';opts.Default = 'Yes';
    quest = 'Add to existing data?';
    answer = questdlg(quest,'Please select',...
                      'Yes','No','Cancel',opts);
  if strcmp(answer,'Cancel')
        return;
    end
    if strcmp(answer,'No')
        globalRDLCS = [];
    end
end

displayMessage(handles,'Please waiting loading DeepLabCut results');
object = {'Hands','Ears','Nose','All'};
try
    globalRDLCS = [globalRDLCS;loadDLCData(handles,fileName,object{ind})];
catch
    displayMessage(handles,'Error!!! loading DeepLabCut results');
    return;
end 
set_R_P_RDLC(handles,R,P,globalRDLCS,1);
displayMessage(handles,'Done loading DeepLabCut results');


% --- Executes on button press in checkbox_display_DLC_results.
function checkbox_display_DLC_results_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_display_DLC_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_display_DLC_results
if get(handles.checkbox_displayTags,'Value')
    value = round(get(handles.slider1,'Value'));
    displayFrames(handles,value);
end


% --- Executes on button press in checkbox_rethrow_matlab_errors.
function checkbox_rethrow_matlab_errors_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_rethrow_matlab_errors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_rethrow_matlab_errors


% --- Executes on button press in checkbox_draw_region.
function checkbox_draw_region_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_draw_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_draw_region


% --- Executes on button press in pushbutton_epoch_goToFrame.
function pushbutton_epoch_goToFrame_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_epoch_goToFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.epochs,'Data');
currentSelection = get(handles.epochs,'userdata');
fn = data{currentSelection};
displayFrames(handles,fn);


% --- Executes on button press in checkbox_select_auto_zoom_window.
function checkbox_select_auto_zoom_window_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_select_auto_zoom_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_select_auto_zoom_window
zw = getParameter(handles,'Auto Zoom Window');
if ~isempty(zw)
    value = round(get(handles.slider1,'Value'));
%     displayFrames(handles,value);
else
    set(hObject,'Value',0);
end
pushbutton_disp_update_Callback(handles.pushbutton_disp_update, eventdata, handles);


% --- Executes on button press in pushbutton_setScale.
function pushbutton_setScale_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fn = round(get(handles.slider1,'Value'));
frames = get_frames(handles);
hf = figure(10);
set(hf,'WindowStyle','modal');
imshow(frames{fn});
axis equal; axis off;
tdx = 20;
tdy = 20;
text(tdx,tdy,sprintf('Draw a line on an object of known dimension (by clicking and dragging)'));
hline = imline(gca);
set(hf,'WindowStyle','normal');
if isempty(hline)
    displayFrames(handles,fn);
    return;
end
pos = round(hline.getPosition);
close(hf);
prompt = 'Enter length with units';
title = 'Input Length';
dims = 1;
answer = inputdlg(prompt,title,dims,{'5 mm'});
% left = pos(1,1);
% right = pos(2,1);
diffP = diff(pos,1,1);
% numPixels = right - left;
numPixels = sqrt(sum(diffP.^2));
mm = sscanf(answer{1},'%f');
setParameter(handles,'Scale',mm/numPixels);
set(handles.text_scale,'String',{'Scale',sprintf('%.3f',getParameter(handles,'Scale')),'mm/pixels'});
displayFrames(handles,fn);
set(handles.figure1,'userdata',fn);


% --- Executes on button press in pushbutton_measureStringThickness.
function pushbutton_measureStringThickness_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_measureStringThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fn = round(get(handles.slider1,'Value'));
frames = get_frames(handles);
hf = figure(10);
set(hf,'WindowStyle','modal');
imshow(frames{fn});
axis equal; axis off;
tdx = 20;
tdy = 20;
text(tdx,tdy,sprintf('Draw a line on an object(by clicking and dragging)'));
hline = imline(gca);
set(hf,'WindowStyle','normal');
if isempty(hline)
    displayFrames(handles,fn);
    return;
end
pos = round(hline.getPosition);
close(hf);
% left = pos(1,1);
% right = pos(2,1);
diffP = diff(pos,1,1);
% numPixels = right - left;
numPixels = sqrt(sum(diffP.^2));
scale = getParameter(handles,'Scale');
setParameter(handles,'String Thickness in Pixels',numPixels);
display([numPixels scale * numPixels]);
displayFrames(handles,fn);
set(handles.figure1,'userdata',fn);


% --- Executes on button press in pushbutton_find_mouse_string_intersection.
function pushbutton_find_mouse_string_intersection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_find_mouse_string_intersection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ok = checkStatusOfSteps(handles);
% if ~ok
%     return;
% end
% props = {'FontSize',9,'ForegroundColor','b'};
% displayMessage(handles,'',props);
% fn = getSelectedFrame(handles);
% frames = get_frames(handles);
% bb = get_body_box(handles,fn,frames{fn},16);
% thisFrameB = frames{fn}(bb(2):bb(4),bb(1):bb(3),:);
% hb = get_head_box(handles,fn,frames{fn},16);
% thisFrameH = frames{fn}(hb(2):hb(4),hb(1):hb(3),:);
% xBox = get_mouse_string_xBox(handles,fn,thisFrameH,[10,10]);
% thisFrameXB = thisFrameH(xBox(2):xBox(4),xBox(1):xBox(3),:);
% msint = find_mouse_string_intersection(handles,fn);
% hf = figure_window(handles,100);
% figure(hf);subplot 141;
% imagesc(thisFrameB);axis equal;
% title(sprintf('%d - Body Box',fn));
% figure(hf);subplot 142;
% imagesc(thisFrameH);axis equal;
% title('Head Box');
% pause(0.01);
% figure(hf);subplot 143;
% imagesc(thisFrameXB);axis equal;
% title('Mouse-String-X Box');
% pause(0.1);
% figure(hf);subplot 144;
% imagesc(frames{fn});axis equal;
% hold on;
% plot(msint(2),msint(1),'*k','markerSize',10)
% title(sprintf('Mouse-String-X'));
% %     displayFrames(handles,M.dfn,fn);
% zw = hb;
% xlim([zw(1) zw(3)]);
% ylim([zw(2) zw(4)]);
% pause(0.1);

props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
frameNums = getAllEpochFrameNums(handles);
if isempty(frameNums)
    displayMessageBlinking(handles,'Fill in epochs table correctly',{'ForegroundColor','r','FontSize',12},2);
    return;
end
enable_disable(handles,0);
try
    find_all_boxes(handles,frameNums);
catch
    displayMessageBlinking(handles,'Window closed or error occurred ... repeat process',{'ForegroundColor','r','FontSize',12},3);
    enable_disable(handles,1);
    rethrow(lasterror);
end
set_processing_mode_gui(handles,0);


% --- Executes on button press in pushbutton_close_extra_windows.
function pushbutton_close_extra_windows_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_close_extra_windows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close_extra_windows(handles);
try
    close(figure(100));
catch
end


% --- Executes on button press in pushbutton_estimate_motion.
function pushbutton_estimate_motion_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_estimate_motion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_processing_mode_gui(handles,1);
displayMessage(handles,'Please wait ... starting optical flow estimation');
estimate_motion(handles);
set_processing_mode_gui(handles,0);


% --- Executes on button press in pushbutton_motion_plots.
function pushbutton_motion_plots_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_motion_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    motion_plots(handles);
catch
    rethrow(lasterror);
end


function edit_reduce_image_factor_Callback(hObject, eventdata, handles)
% hObject    handle to edit_reduce_image_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_reduce_image_factor as text
%        str2double(get(hObject,'String')) returns contents of edit_reduce_image_factor as a double


% --- Executes during object creation, after setting all properties.
function edit_reduce_image_factor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_reduce_image_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_erase_mask.
function pushbutton_erase_mask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_erase_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ok = checkStatusOfSteps(handles);
if ~ok
    return;
end
framesToProcess = get(handles.uibuttongroup_framesToProcess,'userdata');
objectToProcess = get(handles.uibuttongroup_objectToProcess,'userdata');
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
set_processing_mode_gui(handles,1);
try
    switch objectToProcess
        case 1
            erase_masks(handles,'body',sfn,efn);
        case 2
            erase_masks(handles,'ears',sfn,efn);
        case 3
            erase_masks(handles,'hands',sfn,efn);
%             find_masks(handles,'hands_bd',sfn,efn);
        case 4
            erase_masks(handles,'nose',sfn,efn);
        case 5
            erase_masks(handles,'string',sfn,efn);
        case 6
            erase_masks(handles,'all',sfn,efn);
    end
catch
    fn = get(handles.pushbutton_stop_processing,'userdata');
    props = {'FontSize',12,'ForegroundColor','r'};
    displayMessage(handles,sprintf('Sorry :-( ... error occurred in frame %d',fn),props);
    rethrow(lasterror);
end
set_processing_mode_gui(handles,0);
switch framesToProcess
    case 1
        displayMasks(handles,sfn);
end


% --- Executes on button press in checkbox_find_zoom_auto.
function checkbox_find_zoom_auto_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_find_zoom_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_find_zoom_auto


% --- Executes on button press in pushbutton_find_zoom_play.
function pushbutton_find_zoom_play_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_find_zoom_play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
frameNums = getAllEpochFrameNums(handles);
if isempty(frameNums)
    displayMessageBlinking(handles,'Fill in epochs table correctly',{'ForegroundColor','r','FontSize',12},2);
    return;
end
zw = getParameter(handles,'Auto Zoom Window');
data = get_data(handles);
frames = data.frames;
hf = figure(100);clf;
add_window_handle(handles,hf);
set_processing_mode_gui(handles,1);
for ii = 1:length(frameNums)
    if strcmp(get(handles.pushbutton_stop_processing,'visible'),'off')
        axes(handles.axes_main);cla;set(handles.axes_main,'visible','off');
        break;
    end
    fn = frameNums(ii);
    thisFrame = frames{fn};
    thisFrame = thisFrame(zw(2):zw(4),zw(1):zw(3),:);
    figure(hf);
    imagesc(thisFrame);axis equal;
    axis off;
    title(fn);
    pause(0.1);
end
set_processing_mode_gui(handles,0);


% --- Executes on button press in pushbutton_find_PCs.
function pushbutton_find_PCs_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_find_PCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
enable_disable(handles,0);
set(handles.pushbutton_stop_processing,'visible','on');
frameNums = sfn:efn;
err = 0;
try
    set_processing_mode_gui(handles,1);
    find_PCs(handles,frameNums);
    displayMessage(handles,'Select a valid frame range');
catch
    err = 1;
end
set_processing_mode_gui(handles,2);
if err
    displayMessage(handles,'Sorry! An error occurred. Check Matlab window');
    rethrow(lasterror);
else
    displayMessage(handles,'Done !!!');
end


% --- Executes on button press in pushbutton_open_folder.
function pushbutton_open_folder_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_open_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
md = get_meta_data(handles);
winopen(md.processed_data_folder);


% --- Executes on button press in pushbutton_view_PCs.
function pushbutton_view_PCs_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view_PCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
framesToProcess = get(handles.uibuttongroup_framesToProcess,'userdata');
if framesToProcess ~=3
    displayMessage(handles,'Select an epoch');
    return;
end
pcs = load_pcs(handles)
viewPCs(handles,pcs,'');


function edit_margin_left_Callback(hObject, eventdata, handles)
% hObject    handle to edit_margin_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_margin_left as text
%        str2double(get(hObject,'String')) returns contents of edit_margin_left as a double
tagName = get(hObject,'Tag');
try
    margin = str2double(get(hObject,'String'));
    setParameter(handles,tagName,margin);
catch
    margin = getParameter(handles,tagName);
    set(hObject,'String',num2str(margin))
end


    

% --- Executes during object creation, after setting all properties.
function edit_margin_left_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_margin_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_margin_right_Callback(hObject, eventdata, handles)
% hObject    handle to edit_margin_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_margin_right as text
%        str2double(get(hObject,'String')) returns contents of edit_margin_right as a double
tagName = get(hObject,'Tag');
try
    margin = str2double(get(hObject,'String'));
    setParameter(handles,tagName,margin);
catch
    margin = getParameter(handles,tagName);
    set(hObject,'String',num2str(margin))
end

% --- Executes during object creation, after setting all properties.
function edit_margin_right_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_margin_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_margin_top_Callback(hObject, eventdata, handles)
% hObject    handle to edit_margin_top (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_margin_top as text
%        str2double(get(hObject,'String')) returns contents of edit_margin_top as a double
tagName = get(hObject,'Tag');
try
    margin = str2double(get(hObject,'String'));
    setParameter(handles,tagName,margin);
catch
    margin = getParameter(handles,tagName);
    set(hObject,'String',num2str(margin))
end

% --- Executes during object creation, after setting all properties.
function edit_margin_top_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_margin_top (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_margin_bottom_Callback(hObject, eventdata, handles)
% hObject    handle to edit_margin_bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_margin_bottom as text
%        str2double(get(hObject,'String')) returns contents of edit_margin_bottom as a double
tagName = get(hObject,'Tag');
try
    margin = str2double(get(hObject,'String'));
    setParameter(handles,tagName,margin);
catch
    margin = getParameter(handles,tagName);
    set(hObject,'String',num2str(margin))
end

% --- Executes during object creation, after setting all properties.
function edit_margin_bottom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_margin_bottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_margin_leftH_Callback(hObject, eventdata, handles)
% hObject    handle to edit_margin_leftH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_margin_leftH as text
%        str2double(get(hObject,'String')) returns contents of edit_margin_leftH as a double
tagName = get(hObject,'Tag');
try
    margin = str2double(get(hObject,'String'));
    setParameter(handles,tagName,margin);
catch
    margin = getParameter(handles,tagName);
    set(hObject,'String',num2str(margin))
end

% --- Executes during object creation, after setting all properties.
function edit_margin_leftH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_margin_leftH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_margin_rightH_Callback(hObject, eventdata, handles)
% hObject    handle to edit_margin_rightH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_margin_rightH as text
%        str2double(get(hObject,'String')) returns contents of edit_margin_rightH as a double
tagName = get(hObject,'Tag');
try
    margin = str2double(get(hObject,'String'));
    setParameter(handles,tagName,margin);
catch
    margin = getParameter(handles,tagName);
    set(hObject,'String',num2str(margin))
end

% --- Executes during object creation, after setting all properties.
function edit_margin_rightH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_margin_rightH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_margin_topH_Callback(hObject, eventdata, handles)
% hObject    handle to edit_margin_topH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_margin_topH as text
%        str2double(get(hObject,'String')) returns contents of edit_margin_topH as a double
tagName = get(hObject,'Tag');
try
    margin = str2double(get(hObject,'String'));
    setParameter(handles,tagName,margin);
catch
    margin = getParameter(handles,tagName);
    set(hObject,'String',num2str(margin))
end

% --- Executes during object creation, after setting all properties.
function edit_margin_topH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_margin_topH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_margin_bottomH_Callback(hObject, eventdata, handles)
% hObject    handle to edit_margin_bottomH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_margin_bottomH as text
%        str2double(get(hObject,'String')) returns contents of edit_margin_bottomH as a double
tagName = get(hObject,'Tag');
try
    margin = str2double(get(hObject,'String'));
    setParameter(handles,tagName,margin);
catch
    margin = getParameter(handles,tagName);
    set(hObject,'String',num2str(margin))
end

% --- Executes during object creation, after setting all properties.
function edit_margin_bottomH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_margin_bottomH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_grid_horiz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_grid_horiz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_grid_horiz as text
%        str2double(get(hObject,'String')) returns contents of edit_grid_horiz as a double


% --- Executes during object creation, after setting all properties.
function edit_grid_horiz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_grid_horiz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_grid_vert_Callback(hObject, eventdata, handles)
% hObject    handle to edit_grid_vert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_grid_vert as text
%        str2double(get(hObject,'String')) returns contents of edit_grid_vert as a double


% --- Executes during object creation, after setting all properties.
function edit_grid_vert_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_grid_vert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_grid_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to edit_grid_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_grid_thresh as text
%        str2double(get(hObject,'String')) returns contents of edit_grid_thresh as a double


% --- Executes during object creation, after setting all properties.
function edit_grid_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_grid_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uibuttongroup_select_method_masks.
function uibuttongroup_select_method_masks_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup_select_method_masks 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch eventdata.OldValue.String
    case 'Grid Way'
        set(handles.edit_grid_horiz,'Visible','Off'); set(handles.edit_grid_vert,'Visible','Off'); set(handles.edit_grid_thresh,'Visible','Off');
        set(handles.text_mask_specs_top,'Visible','Off');set(handles.text_mask_specs_bottom,'Visible','Off');
    case 'Range Search'
        set(handles.edit_range_search_radius,'Visible','Off');
    case 'KNN'
        set(handles.edit_KNN_search_number_of_points,'Visible','Off');
end


switch eventdata.NewValue.String
    case 'Grid Way'
        set(handles.text_mask_specs_middle,'String','Vert');set(handles.text_mask_specs_top,'Visible','On');set(handles.text_mask_specs_bottom,'Visible','On');
        set(handles.edit_grid_horiz,'Visible','On'); set(handles.edit_grid_vert,'Visible','On'); set(handles.edit_grid_thresh,'Visible','On');
    case 'Range Search'
        set(handles.edit_range_search_radius,'Visible','On'); set(handles.text_mask_specs_middle,'String','Radius');
    case 'KNN'
        set(handles.text_mask_specs_middle,'String','# of Pts'); set(handles.edit_KNN_search_number_of_points,'Visible','On');
end


function edit_range_search_radius_Callback(hObject, eventdata, handles)
% hObject    handle to edit_range_search_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_range_search_radius as text
%        str2double(get(hObject,'String')) returns contents of edit_range_search_radius as a double
str = get(hObject,'String');
try
    value = str2double(str);
    setParameter(handles,'Range Search Radius',value); 
catch
    displayMessageBlinking(handles,'Please enter numeric value',{'ForegroundColor','r','FontSize',12},2);
end

% --- Executes during object creation, after setting all properties.
function edit_range_search_radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_range_search_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_KNN_search_number_of_points_Callback(hObject, eventdata, handles)
% hObject    handle to edit_KNN_search_number_of_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_KNN_search_number_of_points as text
%        str2double(get(hObject,'String')) returns contents of edit_KNN_search_number_of_points as a double
str = get(hObject,'String');
try
    value = str2double(str);
    setParameter(handles,'KNN Search Number of Points',value);
catch
    displayMessageBlinking(handles,'Please enter numeric value',{'ForegroundColor','r','FontSize',12},2);
end

% --- Executes during object creation, after setting all properties.
function edit_KNN_search_number_of_points_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_KNN_search_number_of_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_auto_zoom_set_manually.
function pushbutton_auto_zoom_set_manually_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_auto_zoom_set_manually (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fn = get(handles.figure1,'userdata');
data = get_data(handles);
hf = figure(10);
set(hf,'WindowStyle','modal');
imshow(data.frames{fn});
axis equal; axis off;
try
    hrect = imrect(gca);
    set(hf,'WindowStyle','normal');
catch
    return;
end
if isempty(hrect)
    displayFrames(handles,fn);
    return;
end
pos = round(hrect.getPosition);
close(hf);
left = pos(1);
if left <= 0
    left = 1;
end
top = pos(2);
if top <= 0
    top = 1;
end
right = pos(1)+pos(3);
if right > data.video_object.Width
    right = data.video_object.Width;
end
bottom = pos(2) + pos(4);
if bottom > data.video_object.Height
    bottom = data.video_object.Height;
end
setParameter(handles,'Auto Zoom Window',[left top right bottom]);
zw = getParameter(handles,'Auto Zoom Window');
% handles.md.resultsMF.zoomWindow = [left top right bottom];
set(handles.text_autoZoomWindow,'String',sprintf('[%d %d %d %d]',zw(1),zw(2),zw(3),zw(4)),'userdata',zw,'ForegroundColor','b');
frames = get_frames(handles);
thisFrame = frames{1}(zw(2):zw(4),zw(1):zw(3),:);
setParameter(handles,'Auto Zoom Window Size',[size(thisFrame,1) size(thisFrame,2)]);
sfn = round(get(handles.slider1,'Value'));
displayFrames(handles,sfn);



% --- Executes on button press in pushbutton_auto_zoom_set_manually.
function pushbutton_auto_zoom_change_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_auto_zoom_set_manually (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zw = getParameter(handles,'Auto Zoom Window');
answer = inputdlg('Please enter left top right bottom (origin is top-left)','Modify zoom window values',1,cellstr(num2str(zw)));
if isempty(answer)
    return;
end
zw = sscanf(answer{1},'%d %d %d %d')';
setParameter(handles,'Auto Zoom Window',zw);
set(handles.text_autoZoomWindow,'String',sprintf('[%d %d %d %d]',zw(1),zw(2),zw(3),zw(4)),'userdata',zw,'ForegroundColor','b');
frames = get_frames(handles);
thisFrame = frames{1}(zw(2):zw(4),zw(1):zw(3),:);
setParameter(handles,'Auto Zoom Window Size',[size(thisFrame,1) size(thisFrame,2)]);
sfn = round(get(handles.slider1,'Value'));
displayFrames(handles,sfn);

% --- Executes on button press in pushbutton_play_head_boxes.
function pushbutton_play_head_boxes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play_head_boxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
frameNums = getAllEpochFrameNums(handles);
if isempty(frameNums)
    displayMessageBlinking(handles,'Fill in epochs table correctly',{'ForegroundColor','r','FontSize',12},2);
    return;
end
hbs = getParameter(handles,'Head Boxes');
data = get_data(handles);
frames = data.frames;
hf = figure(100);clf;
add_window_handle(handles,hf);
set_processing_mode_gui(handles,1);
for ii = 1:2:length(frameNums)
    if strcmp(get(handles.pushbutton_stop_processing,'visible'),'off')
        axes(handles.axes_main);cla;set(handles.axes_main,'visible','off');
        break;
    end
    fn = frameNums(ii);
    thisFrame = frames{fn};
    zw = hbs(hbs(:,1)==fn,2:5);
    thisFrame = thisFrame(zw(2):zw(4),zw(1):zw(3),:);
    figure(hf);
    imagesc(thisFrame);axis equal;
    axis off;
    title(fn);
    pause(0.1);
end
set_processing_mode_gui(handles,0);


% --- Executes on button press in pushbutton_plot_objects_motion.
function pushbutton_plot_objects_motion_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plot_objects_motion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
if ~exist('tag','var')
    tag = generalGUIForSelection({'body','ears','hands','nose','string'},3);
end
if tag == 0
    return;
end
framesToProcess = get(handles.uibuttongroup_framesToProcess,'userdata');
if framesToProcess ~=3
    displayMessage(handles,'Select an epoch');
    return;
end
[sfn,efn] = getFrameNums(handles);
displayMessage(handles,'Please wait ... loading file');
md = get_meta_data(handles);
motion = load_motion(handles);
frameNums = getAllEpochFrameNums(handles);
frameSize = getParameter(handles,'Auto Zoom Window Size');
switch tag
    case 1
        
    case 2
        
    case 3
        for ii = 2:length(frameNums)
            fn = frameNums(ii);
            tMask = get_object_mask(handles,fn,[5 6]); rt = find(tMask(:,:,1)); lt = find(tMask(:,:,2));
            mFrame = abs(motion.vxy(:,:,ii-1));
            mFrame = imresize(mFrame,motion.image_resize_factor,'OutputSize',[frameSize(1) frameSize(2)]);
            rtV(ii-1) = mean(mFrame(rt));
            ltV(ii-1) = mean(mFrame(lt));
        end
    case 4
        
    case 5
        
end
displayMessage(handles,'');



function edit_uipanel_body_smallest_area_Callback(hObject, eventdata, handles)
% hObject    handle to edit_uipanel_body_smallest_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_uipanel_body_smallest_area as text
%        str2double(get(hObject,'String')) returns contents of edit_uipanel_body_smallest_area as a double


% --- Executes during object creation, after setting all properties.
function edit_uipanel_body_smallest_area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_uipanel_body_smallest_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_use_headbox.
function checkbox_use_headbox_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_use_headbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_use_headbox


function edit_expansion_compression_ratio_Callback(hObject, eventdata, handles)
% hObject    handle to edit_expansion_compression_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_expansion_compression_ratio as text
%        str2double(get(hObject,'String')) returns contents of edit_expansion_compression_ratio as a double

% --- Executes during object creation, after setting all properties.
function edit_expansion_compression_ratio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_expansion_compression_ratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_smallest_area_to_neglect_ears_Callback(hObject, eventdata, handles)
% hObject    handle to edit_smallest_area_to_neglect_ears (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_smallest_area_to_neglect_ears as text
%        str2double(get(hObject,'String')) returns contents of edit_smallest_area_to_neglect_ears as a double

% --- Executes during object creation, after setting all properties.
function edit_smallest_area_to_neglect_ears_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_smallest_area_to_neglect_ears (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_use_head_box_nose.
function checkbox_use_head_box_nose_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_use_head_box_nose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_use_head_box_nose

function edit_smallest_area_to_neglect_nose_Callback(hObject, eventdata, handles)
% hObject    handle to edit_smallest_area_to_neglect_nose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_smallest_area_to_neglect_nose as text
%        str2double(get(hObject,'String')) returns contents of edit_smallest_area_to_neglect_nose as a double

% --- Executes during object creation, after setting all properties.
function edit_smallest_area_to_neglect_nose_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_smallest_area_to_neglect_nose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton_current_frame_from.
function pushbutton_current_frame_from_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_current_frame_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentFrame = get(handles.figure1,'userdata');
set(handles.edit_fromFrame,'String',num2str(currentFrame));

% --- Executes on button press in pushbutton_current_frame_to.
function pushbutton_current_frame_to_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_current_frame_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentFrame = get(handles.figure1,'userdata');
set(handles.edit_toFrame,'String',num2str(currentFrame));

% --- Executes on button press in checkbox_use_approximations.
function checkbox_use_approximations_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_use_approximations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_use_approximations

% --- Executes on button press in pushbutton_test_boxes.
function pushbutton_test_boxes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_test_boxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fn = get(handles.figure1,'userdata');
frames = get_frames(handles);
thisFrame = frames{fn};
if get(handles.checkbox_Reduce_Image_Size,'Value')
    try
        image_resize_factor = str2double(get(handles.edit_reduce_image_factor,'String'));
%         thisFrame = imresize(thisFrame,(1/image_resize_factor));
%         thisFrame = imresize(thisFrame,image_resize_factor,'OutputSize',[size(thisFrame,1) size(thisFrame,2)]);
    catch
        displayMessageBlinking(handles,'Enter a number for image resize factor',{'ForegroundColor','r'},2);
        return;
    end
else
    image_resize_factor = 16;
end
hb = get_head_box(handles,fn,thisFrame,image_resize_factor,1);
hf = figure_window(handles,100,{'SameAsDisplayWindow'});
if get(handles.checkbox_updateDisplay,'Value')
    figure(hf);imagesc(thisFrame);axis equal;axis off;title(sprintf('Head Box'));zw = hb;xlim([zw(1) zw(3)]);ylim([zw(2) zw(4)]);pause(0.01);
end

% --- Executes on button press in pushbutton_flip_hands.
function pushbutton_flip_hands_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_flip_hands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fn = get(handles.figure1,'userdata');
[p,LiaR,LiaP] = checkIfDataPresent(handles,fn,'hands');
if ~p && sum(LiaR) == 2
    return;
end
Cs{1} = getRegions(handles,fn,'right hand'); Cs{1}.Hand = 'Left Hand';
Cs{2} = getRegions(handles,fn,'left hand'); Cs{2}.Hand = 'Right Hand';
C(1) = Cs{1}; C(2) = Cs{2};
[globalR,globalP,~] = get_R_P_RDLC(handles);
globalR(LiaR,:) = []; globalP(LiaP,:) = [];
set_R_P_RDLC(handles,globalR,globalP,'',1);
frames = get_frames(handles);
thisFrame = frames{fn};
M = populateM(handles,thisFrame,fn);
saveValsHands(handles,M,fn,C,1);
sfn = round(get(handles.slider1,'Value'));
displayFrames(handles,sfn);
n =0;

% --- Executes on button press in pushbutton_find_ICs.
function pushbutton_find_ICs_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_find_ICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
enable_disable(handles,0);
set(handles.pushbutton_stop_processing,'visible','on');
frameNums = sfn:efn;
err = 0;
try
    set_processing_mode_gui(handles,1);
    temp = find_ICs(handles,frameNums);
catch
    displayMessage(handles,'Select a valid frame range');
    err = 1;
end
set_processing_mode_gui(handles,2);
if err
    displayMessage(handles,'Sorry! An error occurred. Check Matlab window');
    rethrow(lasterror);
else
    displayMessage(handles,'Done !!!');
end

% --- Executes on button press in pushbutton_find_NMFs.
function pushbutton_find_NMFs_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_find_NMFs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
enable_disable(handles,0);
set(handles.pushbutton_stop_processing,'visible','on');
frameNums = sfn:efn;
err = 0;
try
    set_processing_mode_gui(handles,1);
    nfms = find_NMFs(handles,frameNums);
%     displayMessage(handles,'Select a valid frame range');
catch
    err = 1;
end
set_processing_mode_gui(handles,2);
if err
    displayMessage(handles,'Sorry! An error occurred. Check Matlab window');
    rethrow(lasterror);
else
    displayMessage(handles,'Done !!!');
end

function edit_num_components_Callback(hObject, eventdata, handles)
% hObject    handle to edit_num_components (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_num_components as text
%        str2double(get(hObject,'String')) returns contents of edit_num_components as a double

% --- Executes during object creation, after setting all properties.
function edit_num_components_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_num_components (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton_descriptive_statistics.
function pushbutton_descriptive_statistics_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_descriptive_statistics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
enable_disable(handles,0);
set(handles.pushbutton_stop_processing,'visible','on');
frameNums = sfn:efn;
err = 0;
try
    set_processing_mode_gui(handles,1);
    descriptive_statistics(handles,frameNums);
    displayMessage(handles,'Done!!');
catch
    err = 1;
end
set_processing_mode_gui(handles,2);
if err
    displayMessage(handles,'Sorry! An error occurred. Check Matlab window');
    rethrow(lasterror);
else
    displayMessage(handles,'Done !!!');
end

% --- Executes on button press in checkbox_use_spatial_clustering.
function checkbox_use_spatial_clustering_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_use_spatial_clustering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_use_spatial_clustering

% --- Executes on button press in checkbox_combine_regions_across_string.
function checkbox_combine_regions_across_string_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_combine_regions_across_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_combine_regions_across_string

% --- Executes on button press in checkbox_find_within_body_ellipse.
function checkbox_find_within_body_ellipse_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_find_within_body_ellipse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_find_within_body_ellipse

% --- Executes on button press in checkbox_tags_body.
function checkbox_tags_body_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_tags_body (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_tags_body
fn = round(get(handles.slider1,'Value'));
displayFrames(handles,fn);

% --- Executes on button press in checkbox_tags_ears.
function checkbox_tags_ears_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_tags_ears (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_tags_ears
fn = round(get(handles.slider1,'Value'));
displayFrames(handles,fn);

% --- Executes on button press in checkbox_tags_hands.
function checkbox_tags_hands_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_tags_hands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_tags_hands
fn = round(get(handles.slider1,'Value'));
displayFrames(handles,fn);

% --- Executes on button press in checkbox_tags_nose.
function checkbox_tags_nose_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_tags_nose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_tags_nose
fn = round(get(handles.slider1,'Value'));
displayFrames(handles,fn);

% --- Executes on button press in checkbox_use_mouse_string_intx.
function checkbox_use_mouse_string_intx_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_use_mouse_string_intx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_use_mouse_string_intx

% --- Executes on button press in checkbox_draw_region_rectangle.
function checkbox_draw_region_rectangle_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_draw_region_rectangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_draw_region_rectangle

% --- Executes on button press in checkbox_over_write_2.
function checkbox_over_write_2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_over_write_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_over_write_2
if get(hObject,'Value')
    set(hObject,'ForegroundColor','r');
    set(handles.checkbox_over_write,'Value',1);set(handles.checkbox_over_write,'ForegroundColor','r');
else
    set(hObject,'ForegroundColor','b');
    set(handles.checkbox_over_write,'Value',0);set(handles.checkbox_over_write,'ForegroundColor','b');
end

% --- Executes on button press in pushbutton_find_entropy.
function pushbutton_find_entropy_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_find_entropy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
enable_disable(handles,0);
set(handles.pushbutton_stop_processing,'visible','on');
frameNums = sfn:efn;
err = 0;
try
    set_processing_mode_gui(handles,1);
    find_temporal_xics(handles,frameNums);
    displayMessage(handles,'Done!!');
catch
    err = 1;
end
set_processing_mode_gui(handles,2);
if err
    displayMessage(handles,'Sorry! An error occurred. Check Matlab window');
    rethrow(lasterror);
else
    displayMessage(handles,'Done !!!');
end

% --- Executes on button press in pushbutton_descrtiptive_stats_masks.
function pushbutton_descrtiptive_stats_masks_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_descrtiptive_stats_masks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
props = {'FontSize',9,'ForegroundColor','b'};
displayMessage(handles,'',props);
[sfn,efn] = getFrameNums(handles);
if isnan(sfn) || isnan(efn)
    displayMessage(handles,'Select a valid frame range');
    return;
end
enable_disable(handles,0);
set(handles.pushbutton_stop_processing,'visible','on');
frameNums = sfn:efn;
err = 0;
try
    set_processing_mode_gui(handles,1);
    descriptive_statistics_masks(handles,frameNums);
    displayMessage(handles,'Done!!');
catch
    err = 1;
end
set_processing_mode_gui(handles,2);
if err
    displayMessage(handles,'Sorry! An error occurred. Check Matlab window');
    rethrow(lasterror);
else
    displayMessage(handles,'Done !!!');
end

% --- Executes on button press in pushbutton_find_fractal_dimensions.
function pushbutton_find_fractal_dimensions_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_find_fractal_dimensions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
displayMessage(handles,'Finding fractal dimension and entropy');
set_processing_mode_gui(handles,1);
find_fractal_dimensions_and_entropy (handles);
set_processing_mode_gui(handles,2);
displayMessage(handles,'Done!');


% --- Executes on button press in checkbox_imcomplement.
function checkbox_imcomplement_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_imcomplement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_imcomplement
fn = round(get(handles.slider1,'Value'));
displayFrames(handles,fn);

% --- Executes on button press in pushbutton_save_epoch_frames.
function pushbutton_save_epoch_frames_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save_epoch_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton_view_descriptive_statistics.
function pushbutton_view_descriptive_statistics_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view_descriptive_statistics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ds = load_ds(handles);
view_descriptive_statistics(handles,ds,'');

% --- Executes on button press in pushbutton_view_temporal_analysis.
function pushbutton_view_temporal_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view_temporal_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ent = load_entropy(handles);
view_entropy(handles,ent,'');

% --- Executes on button press in pushbutton_view_ICs_minmax.
function pushbutton_view_ICs_minmax_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view_ICs_minmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ics = load_ics(handles);
viewICs_min_max(handles,ics,'');

% --- Executes on button press in checkbox_check_intersection_of_regions.
function checkbox_check_intersection_of_regions_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_check_intersection_of_regions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_check_intersection_of_regions

% --- Executes on button press in pushbutton_select_annotation_colors.
function pushbutton_select_annotation_colors_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_select_annotation_colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dispProps = get(handles.pushbutton_select_annotation_colors,'userdata');
dispProps = genericGUIForChangingPropValues(dispProps,'Change Property Values');
if isstruct(dispProps)
    set(handles.pushbutton_select_annotation_colors,'userdata',dispProps);
    md = get_meta_data(handles);
    fileName = fullfile(md.processed_data_folder,'dispProps.mat');
    save(fileName,'-struct','dispProps');
    refreshDisplay(handles);
end

% --- Executes on button press in checkbox_check_relationship_regions_ears.
function checkbox_check_relationship_regions_ears_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_check_relationship_regions_ears (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_check_relationship_regions_ears

% --- Executes on button press in checkbox_check_relationship_regions_nose.
function checkbox_check_relationship_regions_nose_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_check_relationship_regions_nose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_check_relationship_regions_nose

% --- Executes on button press in checkbox_labeled_video_only_frames.
function checkbox_labeled_video_only_frames_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_labeled_video_only_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_labeled_video_only_frames


% --- Executes on button press in pushbutton_performance_accuracy.
function pushbutton_performance_accuracy_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_performance_accuracy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
[sfn,efn] = getFrameNums(handles);
out = get_all_params(handles,sfn,efn,0);
catch
    displayMessageBlinking(handles,'Couldn''t find ... please check analysis','',5);
    return;
end
fns = sfn:efn;
objects = {'Body','Ears','Nose','Hands'};
for ii = 1:length(fns)
    amcInds(ii,:) = [out.body.manual(ii),out.right_ear.manual(ii),out.nose.manual(ii),out.right_hand.manual(ii)];
end
PAtxt{1,1} = 'Accuracy Results';
for oo = 1:4
    PA(oo) = 100 * sum(amcInds(:,oo) == 0)/(sum(amcInds(:,oo) == 0) + sum(amcInds(:,oo) == 1));
    PAtxt{oo+1,1} = sprintf('%s %d of %d frames = %.2f', objects{oo},sum(amcInds(:,oo) == 0),...
        (sum(amcInds(:,oo) == 0) + sum(amcInds(:,oo) == 1)),PA(oo));
end
f = msgbox(PAtxt,'Click ok','modal');
uiwait(f);


% --- Executes on button press in pushbutton_open_results.
function pushbutton_open_results_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_open_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.epochs,'Data');
currentSelection = get(handles.epochs,'userdata');
if isempty(currentSelection)
    displayMessage(handles,'Please select an epoch first');
    return;
end
fn = data{currentSelection};
if isempty(fn)
    return;
end
startEnd = cell2mat(data(currentSelection(1),:));
sfn = startEnd(1);
numFrames = startEnd(2)-startEnd(1)+1;
efn = sfn+numFrames-1;

handles.md = get_meta_data(handles);
handles.d = get_data(handles);
frames = handles.d.frames;
times = handles.d.frame_times;

try
    out = get_all_params(handles,sfn,efn,0);
catch
    props = {'FontSize',11,'ForegroundColor','r'};displayMessage(handles,'An error occured while fetching data',props);
    close_extra_windows(handles);
    rethrow(lasterror);
    return;
end
fieldNames = fields(out);
colNum = 1;headings = []; dataT = [];
headings{colNum} = 'Frame Number';
dataT(:,colNum) = out.fns;
colNum = colNum + 1;
headings{colNum} = 'Frame Time';
dataT(:,colNum) = out.times;
for ii = 3:length(fieldNames)
    cmdTxt = sprintf('thisField = out.%s;',fieldNames{ii});
    eval(cmdTxt);
    subFieldNames = fields(thisField);
    for jj = 1:length(subFieldNames)
        cmdTxt = sprintf('thisField1 = thisField.%s;',subFieldNames{jj});
        eval(cmdTxt);
        if isstruct(thisField1)
            continue;
        end
        if size(thisField1,2) == 1
            colNum = colNum + 1;
            headings{colNum} = sprintf('%s_%s',fieldNames{ii},subFieldNames{jj});
            dataT(:,colNum) = thisField1;
        end
        if size(thisField1,2) == 2
            colNum = colNum + 1;
            headings{colNum} = sprintf('%s_%s_X',fieldNames{ii},subFieldNames{jj});
            dataT(:,colNum) = thisField1(:,1);
            colNum = colNum + 1;
            headings{colNum} = sprintf('%s_%s_Y',fieldNames{ii},subFieldNames{jj});
            dataT(:,colNum) = thisField1(:,2);
        end
    end
end
dataT = array2table(dataT);
dataT.Properties.VariableNames = headings;
assignin('base','dataT',dataT)
openvar('dataT');


% --- Executes on button press in pushbutton_import_colors.
function pushbutton_import_colors_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_import_colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_colorVar = {'All','String Color','Fur Color','Mouse Color','Ears Color','Nose Color','Hands Color'};
choices = generalGUIForSelection(all_colorVar,1);
if choices == 1
    colorVar = all_colorVar(2:end);
else
    colorVar = all_colorVar(choices);
end
found = 0;
for ii = 1:length(colorVar)
    tC = getParameter(handles,colorVar{ii});
    if ~isempty(tC)
        found = 1;
        break;
    end
end
if found
    answer = questdlg('This will override existing colors for all objects. Are you sure?', ...
        'Please Confirm', ...
        'Yes please','No thank you','No thank you');
    % Handle response
    switch answer
        case 'No thank you'
            return;
    end
end
md = get_meta_data(handles);
fileName = fullfile(md.processed_data_folder,'config.mat');
[~,path] = uigetfile(fileName,'Select Config File from another Processed_Data_Folder');
try
    config = get_config_file(path);
    for ii = 1:length(colorVar)
        tC = getParameter(config,colorVar{ii});
        setParameter(handles,colorVar{ii},tC);
    end
    displayMessage(handles,'Success importing colors!');
    refreshDisplay(handles);
catch
    displayMessage(handles,'Error importing colors ... see Matlab command window for details');
    rethrow(lasterror);
end


% --- Executes on button press in pushbutton_set_head_box_manually.
function pushbutton_set_head_box_manually_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_set_head_box_manually (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fn = get(handles.figure1,'userdata');
data = get_data(handles);
hf = figure(10);
set(hf,'WindowStyle','modal');
imshow(data.frames{fn});
axis equal; axis off;
zw = getParameter(handles,'Zoom Window');
azw = getParameter(handles,'Auto Zoom Window');
if ~isempty(azw) & get(handles.checkbox_select_auto_zoom_window,'Value')
    zw = azw;
end
if ~isempty(zw)
    xlim(gca,[zw(1) zw(3)]);
    ylim(gca,[zw(2) zw(4)]);
else
    xlim(gca,[1 sz(2)]);
    ylim(gca,[1 sz(1)]);
end
try
    hrect = imrect(gca);
    set(hf,'WindowStyle','normal');
catch
    return;
end
if isempty(hrect)
    displayFrames(handles,fn);
    return;
end
pos = round(hrect.getPosition);
close(hf);
left = pos(1);
if left <= 0
    left = 1;
end
top = pos(2);
if top <= 0
    top = 1;
end
right = pos(1)+pos(3);
if right > data.video_object.Width
    right = data.video_object.Width;
end
bottom = pos(2) + pos(4);
if bottom > data.video_object.Height
    bottom = data.video_object.Height;
end

boxes = getParameter(handles,'Head Boxes');
indHeadBox = boxes(:,1) == fn;

headBox = [left,top,right,bottom];

if sum(indHeadBox) > 0
    boxes(indHeadBox,:) = [fn headBox];
else
    boxes = [boxes;[fn headBox]];
end
setParameter(handles,'Head Boxes',boxes);


% --- Executes on button press in pushbutton_plot_body_box.
function pushbutton_plot_body_box_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plot_body_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zw = getParameter(handles,'Auto Zoom Window');
if isempty(zw)
    return;
end
fn = get(handles.figure1,'userdata');
data = get_data(handles);
hf = figure(10);
set(hf,'WindowStyle','modal');
imshow(data.frames{fn});
axis equal; axis off;
xlim(gca,[zw(1) zw(3)]);
ylim(gca,[zw(2) zw(4)]);

% --- Executes on button press in pushbutton_head_box.
function pushbutton_head_box_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_head_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fn = get(handles.figure1,'userdata');
boxes = getParameter(handles,'Head Boxes');
indHeadBox = boxes(:,1) == fn;
if sum(indHeadBox) == 0
    displayMessage(handles,'No head box found');
    return;
end
zw = boxes(indHeadBox,2:5);
data = get_data(handles);
hf = figure(10);
set(hf,'WindowStyle','modal');
imshow(data.frames{fn});
axis equal; axis off;
xlim(gca,[zw(1) zw(3)]);
ylim(gca,[zw(2) zw(4)]);


% --- Executes on button press in pushbutton_keyboard_shortcuts.
function pushbutton_keyboard_shortcuts_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_keyboard_shortcuts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dispProps.Right_Arrow = 'Move selection of frame right';
dispProps.Left_Arrow = 'Move selection of frame left';
dispProps.Up_Arrow = 'Move selection of frame up';
dispProps.Down_Arrow = 'Move selection of frame down';

dispProps.Page_Up = 'Display previous frames';
dispProps.Page_Up = 'Display next frames';

dispProps.s_or_S = 'Select String Object for processing';
dispProps.b_or_B = 'Select Body Object for processing';
dispProps.e_or_E = 'Select Ears Object for processing';
dispProps.n_or_N = 'Select Nose Object for processing';
dispProps.h_or_H = 'Select Hands Object for processing';

dispProps.m_or_M = 'Find Masks';
dispProps.o_or_O = 'Find Objects';

genericGUIForChangingPropValues(dispProps,'Keyboard Shortcuts',0);