function varargout = JtweakOptions(varargin)
% JTWEAKOPTIONS MATLAB code for JtweakOptions.fig
%      JTWEAKOPTIONS, by itself, creates a new JTWEAKOPTIONS or raises the existing
%      singleton*.
%
%      H = JTWEAKOPTIONS returns the handle to a new JTWEAKOPTIONS or the handle to
%      the existing singleton*.
%
%      JTWEAKOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JTWEAKOPTIONS.M with the given input arguments.
%
%      JTWEAKOPTIONS('Property','Value',...) creates a new JTWEAKOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before JtweakOptions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to JtweakOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help JtweakOptions

% Last Modified by GUIDE v2.5 18-May-2016 15:02:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @JtweakOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @JtweakOptions_OutputFcn, ...
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


% --- Executes just before JtweakOptions is made visible.
function JtweakOptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to JtweakOptions (see VARARGIN)

% Choose default command line output for JtweakOptions


handles.output = hObject;
handles.fan_surfaces = varargin{1};
surface_names = fieldnames(handles.fan_surfaces);
surface_options = ['Choose surface'; surface_names];
set(handles.fan_surface_chooser,'String', surface_options)
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes JtweakOptions wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = JtweakOptions_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in fan_surface_chooser.
function fan_surface_chooser_Callback(hObject, eventdata, handles)
% hObject    handle to fan_surface_chooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fan_surface_chooser contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fan_surface_chooser


% --- Executes during object creation, after setting all properties.
function fan_surface_chooser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fan_surface_chooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in process_btn.
function process_btn_Callback(hObject, eventdata, handles)
% hObject    handle to process_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(handles.fan_surface_chooser, 'String');
val = get(handles.fan_surface_chooser,'Value');
if strcmp(str{val}, 'Choose surface') < 1
    surface = handles.fan_surfaces.(str{val});
    if length(surface) == 3
        Jtweaker(surface{1}, surface{2}, str{val}, surface{3})
    else
        Jtweaker(surface{1}, surface{2}, str{val})
    end
end
