function varargout = TCP_server(varargin)


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TCP_server_OpeningFcn, ...
                   'gui_OutputFcn',  @TCP_server_OutputFcn, ...
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


% --- Executes just before TCP_server is made visible.
function TCP_server_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TCP_server (see VARARGIN)

% Choose default command line output for TCP_server
handles.output = hObject;

global start;
start=0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TCP_server wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TCP_server_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.server_receive;





% --- Executes on button press in open.
function open_Callback(hObject, eventdata, handles)
% hObject    handle to open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global t start;
if start==0
    start=1; 
    ip=get(handles.ip,'string');
    port=str2num(get(handles.port,'string'));
    set(hObject,'string','等待链接');
    set(handles.biaoji,'BackgroundColor',[1,0.843,0]);
    t = tcpip(ip ,port,'NetworkRole', 'server');
    set(t,'BytesAvailableFcnMode','byte');
    set(t,'BytesAvailableFcncount',1);
    set(t,'BytesAvailableFcn',{@mycom,handles});
    pause(0.1);
    try
       %连接
        fopen(t);
        set(hObject,'string','关闭端口')
        set(handles.biaoji,'BackgroundColor',[0,1,0])
     catch
        msgbox('打开失败');
     end
else           %%端口处于打开状态
   start=0;
   set(hObject,'string','打开端口')
   set(handles.biaoji,'BackgroundColor',[1,0,0]);
   fclose(t);
end



function mycom(hObject,eventdata,handles)
global t
n = get(t,'BytesAvailable');
%set(handles.server_receive,'string','');
str=get(handles.server_receive,'string');
if n
    a = fread(t,n,'uint8');
    str=[str,num2str(a')];
set(handles.server_receive,'string',str);
    set(handles.server_receive,'userdata',a');
end



% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 set(handles.server_receive,'string','');