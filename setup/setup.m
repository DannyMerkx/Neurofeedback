function varargout = setup(varargin)
% SETUP MATLAB code for setup.fig
%      SETUP, by itself, creates a new SETUP or raises the existing
%      singleton*.
%
%      H = SETUP returns the handle to a new SETUP or the handle to
%      the existing singleton*.
%
%      SETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETUP.M with the given input arguments.
%
%      SETUP('Property','Value',...) creates a new SETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setup

% Last Modified by GUIDE v2.5 28-Dec-2016 23:08:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setup_OpeningFcn, ...
                   'gui_OutputFcn',  @setup_OutputFcn, ...
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


% --- Executes just before setup is made visible.
function setup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setup (see VARARGIN)

% Choose default command line output for setup
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setup wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global games_number games_path current_game run_game;
games_number = 4;
games_path = ['..\stimulus0';...
              '..\stimulus1';...
              '..\stimulus2';...
              '..\stimulus2'];
current_game = 1;
run_game = [1 1 1 1];
load('setup.mat');
if run_game(1),
    set(handles.t_run_current_game, 'Value', 1);
end

global game_title trial_duration number_of_trial_sets trials_in_set show_instr warnings;
global fbDuration random_trial cueDuration;
game_title = 'Game 0: Learn/recall imagine movements';            
trial_duration = 10; % s
number_of_trial_sets = 2;
trials_in_set = 2;
show_instr = 1; % shows insturction to a user if necessary
warnings = 0; % switch off warnings if necessary          
fbDuration = 2; % !!! Former promptDuration                        
random_trial = 1; % DO NOT CHANGE
cueDuration = 2;  % DO NOT CHANGE
set(handles.t_warnings, 'String', 'Turn on MATLAB warnings during run');
loaddata(handles);
updateData(handles);

% --- Outputs from this function are returned to the command line.
function varargout = setup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in t_save.
function t_save_Callback(hObject, eventdata, handles)
% hObject    handle to t_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% save two files: run gam and parameters
savedata(handles);

% --- Executes on button press in t_next_game.
function t_next_game_Callback(hObject, eventdata, handles)
% hObject    handle to t_next_game (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global games_number current_game games_path;
savedata(handles);

current_game = current_game + 1;
if current_game>games_number, current_game=games_number; end
loaddata(handles);
updateData(handles);


% save two files: run gam and parameters

% --- Executes on button press in t_previous_game.
function t_previous_game_Callback(hObject, eventdata, handles)
% hObject    handle to t_previous_game (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global current_game;
savedata(handles);
current_game = current_game - 1;
if current_game<1, current_game=1; end
loaddata(handles);
updateData(handles);

% save two files: run gam and parameters


% --- Executes on button press in t_run.
function t_run_Callback(hObject, eventdata, handles)
% hObject    handle to t_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in t_run_current_game.
function t_run_current_game_Callback(hObject, eventdata, handles)
% hObject    handle to t_run_current_game (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of t_run_current_game
global current_game run_game;
if get(hObject,'Value'),
    hide_controls(handles, 'on');
    run_game(current_game) = 1;    
else
    hide_controls(handles, 'off');
    run_game(current_game) = 0;    
end
    


function t_trials_in_set_Callback(hObject, eventdata, handles)
% hObject    handle to t_trials_in_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_trials_in_set as text
%        str2double(get(hObject,'String')) returns contents of t_trials_in_set as a double


% --- Executes during object creation, after setting all properties.
function t_trials_in_set_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_trials_in_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function t_trial_duration_Callback(hObject, eventdata, handles)
% hObject    handle to t_trial_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_trial_duration as text
%        str2double(get(hObject,'String')) returns contents of t_trial_duration as a double


% --- Executes during object creation, after setting all properties.
function t_trial_duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_trial_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function t_number_of_trial_sets_Callback(hObject, eventdata, handles)
% hObject    handle to t_number_of_trial_sets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_number_of_trial_sets as text
%        str2double(get(hObject,'String')) returns contents of t_number_of_trial_sets as a double


% --- Executes during object creation, after setting all properties.
function t_number_of_trial_sets_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_number_of_trial_sets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in t_random_trial.
function t_random_trial_Callback(hObject, eventdata, handles)
% hObject    handle to t_random_trial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of t_random_trial


% --- Executes on button press in t_warnings.
function t_warnings_Callback(hObject, eventdata, handles)
% hObject    handle to t_warnings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of t_warnings



function t_fbDuration_Callback(hObject, eventdata, handles)
% hObject    handle to t_fbDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_fbDuration as text
%        str2double(get(hObject,'String')) returns contents of t_fbDuration as a double


% --- Executes during object creation, after setting all properties.
function t_fbDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_fbDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function t_cueDuration_Callback(hObject, eventdata, handles)
% hObject    handle to t_cueDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_cueDuration as text
%        str2double(get(hObject,'String')) returns contents of t_cueDuration as a double


% --- Executes during object creation, after setting all properties.
function t_cueDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_cueDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in t_show_instr.
function t_show_instr_Callback(hObject, eventdata, handles)
% hObject    handle to t_show_instr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of t_show_instr


% --- Executes on button press in t_instr_editor.
function t_instr_editor_Callback(hObject, eventdata, handles)
% hObject    handle to t_instr_editor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global games_path current_game;
system(['%systemroot%\notepad ' games_path(current_game,:) '\insturtions.txt']);

% function that refresh the filds in the form from the workspace data
function updateData(handles)
global current_game run_game games_number;
% turn off unnecessary controls
switch current_game
    case 1
        %
        %random_trial = 1; % DO NOT CHANGE
        %cueDuration = 2;  % DO NOT CHANGE
        set(handles.t_random_trial, 'Visible', 'off');
        set(handles.t_cueDuration, 'Visible', 'off');
        set(handles.text6, 'Visible', 'off');
    case 2
        %cueDuration = 2;  % DO NOT CHANGE 
        set(handles.t_cueDuration, 'Visible', 'off');
        set(handles.text6, 'Visible', 'off');
        set(handles.t_random_trial, 'Visible', 'on');
    otherwise %game 2/3
        set(handles.t_random_trial, 'Visible', 'on');
        set(handles.t_cueDuration, 'Visible', 'on');
        set(handles.text6, 'Visible', 'on');
end

if run_game(current_game) == 1,
    hide_controls(handles, 'on');    
else
    hide_controls(handles, 'off');    
end

if current_game==games_number,
    set(handles.t_next_game, 'Enable', 'off');
else
    set(handles.t_next_game, 'Enable', 'on');
end

if current_game==1,
    set(handles.t_previous_game, 'Enable', 'off');
else
    set(handles.t_previous_game, 'Enable', 'on');
end

set(handles.t_run_current_game, 'Value', run_game(current_game));


% function hides or show controls for the 'run this game...' tick
function hide_controls(handles, val)
% val = on or off
global run_game current_game;
set(handles.t_random_trial, 'Enable', val);
set(handles.t_cueDuration, 'Enable', val);
set(handles.t_fbDuration, 'Enable', val);
set(handles.t_warnings, 'Enable', val);
set(handles.t_show_instr, 'Enable', val);
set(handles.t_trials_in_set, 'Enable', val);
set(handles.t_number_of_trial_sets, 'Enable', val);
set(handles.t_trial_duration, 'Enable', val);
set(handles.t_cueDuration, 'Enable', val);
set(handles.t_instr_editor, 'Enable', val);
set(handles.text2, 'Enable', val);
set(handles.text3, 'Enable', val);
set(handles.text4, 'Enable', val);
set(handles.text5, 'Enable', val);
set(handles.text6, 'Enable', val);


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global games_number games_path run_game;
for in = 1:games_number
    if run_game(in),
        currentFolder = pwd;
        cd(games_path(in,:));
        switch in
            case 1
                try run stimulus0; end
            case 2
                try run stimulus1; end
            case 3
                try run stimulus2(0); end
            case 4
                try run stimulus2(1); end
        end        
        cd(currentFolder);
    end
end

% load parameters of the current game
function loaddata(handles)
global current_game games_path;
global game_title trial_duration number_of_trial_sets trials_in_set show_instr warnings;
global fbDuration random_trial cueDuration;

switch current_game
    case 3
        load([games_path(current_game,:) '\parameters2.mat']);
    case 4
        load([games_path(current_game,:) '\parameters3.mat']);
    otherwise
        load([games_path(current_game,:) '\parameters.mat']);
end

% load data from globals to form
set(handles.t_game_title, 'String', game_title);
set(handles.t_number_of_trial_sets, 'String', number_of_trial_sets);
set(handles.t_trials_in_set, 'String', trials_in_set);
set(handles.t_show_instr, 'Value', show_instr);
set(handles.t_warnings, 'Value', warnings);
set(handles.t_fbDuration, 'String', fbDuration);
set(handles.t_cueDuration, 'Value', cueDuration);
set(handles.t_trial_duration, 'String', trial_duration);
set(handles.t_random_trial, 'Value', random_trial);



% saved parameters of the current game
function savedata(handles)

% TODO parameters from form to globals
global game_title trial_duration number_of_trial_sets trials_in_set show_instr warnings;
global fbDuration random_trial cueDuration;

game_title = get(handles.t_game_title,'String');
number_of_trial_sets = str2double( get(handles.t_number_of_trial_sets,'String') );
trials_in_set = str2double( get(handles.t_trials_in_set,'String') );
show_instr = get(handles.t_show_instr, 'Value');
warnings = get(handles.t_warnings, 'Value');
fbDuration = str2double( get(handles.t_fbDuration,'String') );
cueDuration = str2double( get(handles.t_cueDuration,'String') );
trial_duration = str2double(get(handles.t_trial_duration,'String') );
random_trial = get(handles.t_random_trial, 'Value');



global current_game games_path run_game;
switch current_game
    case 3
        filename = '\parameters2.mat';
    case 4

        filename = '\parameters3.mat';
    otherwise
        filename = '\parameters.mat';
end
save([games_path(current_game,:) filename],'game_title','trial_duration',...
    'number_of_trial_sets', 'trials_in_set', 'show_instr', 'warnings', 'random_trial', ...
    'fbDuration', 'cueDuration');

save('setup.mat', 'run_game');
