function varargout = robotallocation1(varargin)
% Begin initialization code - DO NOT EDIT
global count picture_disp ;
count=1;
picture_disp=0;
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @robotallocation1_OpeningFcn, ...
                   'gui_OutputFcn',  @robotallocation1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
 %ischar判断给定数组是否是字符数组
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});%分别取得figure和包含的控件的CreateFcn回调函数，创建各个控件。
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end
%调用figure及各控件的CreateFcn函数创建完各控件后，
%下一步的任务就是要显示figure以及各控件。
%这时，程序会调用其OpeningFcn函数，用户如果想初始化各控件的数值以及和figure相关联的handles结构的数值，代码就可以放在这里。注意：要调用guidata(hObject,handles);函数保存所做的修改。
% --- Executes just before robotallocation1 is made visible.
function robotallocation1_OpeningFcn(hObject, eventdata, handles,varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to robotallocation1 (see VARARGIN)

% Choose default command line output for robotallocation1
global n display receive_task player ;
n=11;
display=0;
receive_task=[];
[y,Fs] = audioread('任务提示.mp3');
 player = audioplayer(y,Fs);  % 建立音乐播放器
 t2 = timer('Period',1, 'timerfcn', {@disptime, handles}, 'ExecutionMode', 'fixedSpacing');
 start(t2);
%handles.output=hObject;是matlab guide自动加上的，
%目的是把该GUI figure的句柄当作输出参数传递出去。
%handles.output是matlab guide自动添加到handles结构中的变量，用来传递输出参数，
%我们可以修改这个变量名，如：用handles.myoutput代替，只是要和OutputFcn中的varargout{1}=handles.output;名字相对应就可以。
handles.output = hObject;

% Update handles structure
%  实现的是把指定的 handles 变量内容储存到当前figure(hObject)窗口 所开辟的某个存储变量
%handles可以是普通变量，也可以是结构体。hObject是当前窗口句柄或者当前窗口内控件句柄。
guidata(hObject, handles);
% handles = GUIDATA(hObject) 。把之前存储的内容赋值给变量handles。
title_img = imread('1.png');
axes(handles.img1);
imshow(title_img);

% UIWAIT makes robotallocation1 wait for user response (see UIRESUME)
%如果我们在OpeningFcn的最后没有调用uiwait(handles.figure1)，
%则程序立马调用OutputFcn，并返回，这时程序的输出参数就是figure的句柄，
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = robotallocation1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end
function disptime(hObject,eventdata,handles)
    set(handles.time,'string',datestr(now,13));
end

% --- Executes on button press in path_planning.
function path_planning_Callback(hObject, eventdata, handles)
% hObject    handle to path_planning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
map2=get(handles.init_map,'userdata');
task=get(handles.task_allocation,'userdata');
if(isempty(map2)||isempty(task))
    msgbox('请先初始化地图并分配任务','消息');
    return
 end
global stop;
stop=0;
start_node=find(map2==5);
robotallocation2(handles,map2,task,start_node,eventdata)
set(handles.task_allocation,'userdata',[]);
end

function robotallocation2(handles,map2,task,start_node,eventdata)
a=1;
global n;
global stop;
path=get(handles.path_planning_type,'value'); 
begin=start_node;
global data
data =cell(1,5);
data{1,1}=1;
while(~isempty(task))
    if stop
        init_map_Callback(handles.init_map, eventdata, handles);
        set(handles.edit1,'string','任务已重置');
        return
    end
    goal_node=sub2ind([n,n],task(1,1),task(1,2));
    task_x=num2str(task(1,1));
    task_y=num2str(task(1,2));
    data{1,4}=strcat('[',task_x,',',task_y,']');
        switch path
             case 1
                 bfs(handles.img,map2,start_node,goal_node)%BFS
             case 2
                  DFS(handles.img,map2,start_node,goal_node)%DFS
             case 3
                  dijkstra2(handles.img,map2,start_node,goal_node,handles);%dijkstra进行路径规划
             case 4
                  ASTAR2(handles.img,map2,start_node,goal_node) ;                                %Astar
        end
    if(start_node==begin)
       map2(start_node)=1;
    end
    data{1,3}=1;
    str=sprintf('任务%d已完成',a);
    set(handles.edit1,'string',str);
    start_node=sub2ind([n,n],task(1,1),task(1,2));
    task(1,:)=[];
    a=a+1;
    pause(1)
end
ASTAR2(handles.img,map2,start_node,begin);
init_map_Callback(handles.init_map, eventdata, handles);
set(handles.edit1,'string','已完成任务回到起点');
end


function DFS(handles,map2,start_node,dest_node)
%  uicontrol('Style','pushbutton','String','again', 'FontSize',12, ...
%        'Position', [1 1 60 40], 'Callback','DFS(handles)');
%% set up color map for display 
cmap = [1 1 1; ...%  1 - white - 空地
        0 0 0; ...% 2 - black - 障碍 
        1 0 0; ...% 3 - red - 已搜索过的地方
        0 0 1; ...% 4 - blue - 下次搜索备选中心 
        0 1 0; ...% 5 - green - 起始点
        1 1 0;...% 6 - yellow -  到目标点的路径 
       1 0 1];% 7 - -  目标点 
colormap(cmap);  
%wallpercent=0.4;
% % 设置障障碍 
%map1(ceil(10^2.*rand(floor(10*10*wallpercent),1))) =2;
%  map(ceil(10.*rand),ceil(10.*rand)) = 5; % 起始点
%map(ceil(10.*rand),ceil(10.*rand)) = 6; % 目标点
% %% 建立地图
nrows = 11; 
ncols = 11; 
map1=map2;
% % 对于每个格单元，这个数组保存其父节点的索引。 
parent = zeros(nrows,ncols);
array=start_node;
axes(handles);%将handles设置为当前句柄
% % 主循环
tic
 while ~isempty(array) 
  % 画出现状图
  map1(start_node) = 5;
  map1(dest_node) = 7;
  image(handles,1.5, 1.5, map1); 
  grid on;  
  set(gca,'gridline','-','gridcolor','r','linewidth',2);
  set(gca,'xtick',1:1:12,'ytick',1:1:12);
  axis image; 
  title('基于{ \color{red}DFS} 算法的路径规划 ','fontsize',16)
  drawnow; 
   current=array(end);
cout=0;
   if ((current == dest_node) ) %搜索到目标点或者全部搜索完，结束循环。
         break; 
   end; 
  map1(current) = 3; %将当前颜色标为红色。
  
 [i, j] = ind2sub(size(map1), current); %返回当前位置的坐标
 neighbor = [ 
            i+1,j;... 
            i-1,j;...  
            i,j+1;... 
            
             i,j-1]; %确定当前位置的上下左右区域。     
 %neighbor1 = [ 
    %    i-1,j-1;...
     %   i+1,j+1;...
      %  i-1,j+1;...
       %  i+1,j-1]; %确定当前位置的对角区域。      
 outRangetest = (neighbor(:,1)<1) + (neighbor(:,1)>nrows) +...
                    (neighbor(:,2)<1) + (neighbor(:,2)>ncols ); %判断下一次搜索的区域是否超出限制。         
 locate = outRangetest>0; %返回超限点的行数。
 neighbor(locate,:)=[]; %在下一次搜索区域里去掉超限点，删除某一行。
 neighborIndex = sub2ind(size(map1),neighbor(:,1),neighbor(:,2)); %返回下次搜索区域的索引号。
 if(~isempty(neighborIndex) )
     for i=1:length(neighborIndex) 
      if (map1(neighborIndex(i))~=2) && (map1(neighborIndex(i))~=3 && map1(neighborIndex(i))~= 5) 
         map1(neighborIndex(i)) = 4; %如果下次搜索的点不是障碍，不是起点，没有搜索过就标为蓝色。
         if(isempty(find(array==neighborIndex(i), 1)))
              array=[array;neighborIndex(i)];
              parent(neighborIndex(i)) = current;
              break;
         end
      else
          cout=cout+1;
          if(cout==length(neighborIndex))
              array(end)=[];
          end
      end 
     end 
 else
     array(end)=[];
 end
 end
 

if (current ~= dest_node) 
    route = [];
else
    %提取路线坐标
  route =dest_node ;
  while (parent(route(1)) ~= 0) 
         route = [parent(route(1)), route];     
   end 
%  动态显示出路线 
        for k = 2:length(route) - 1 
              map1(route(k)) = 6; 
               image(1.5, 1.5, map1);
              grid on; 
               set(gca,'gridline','-','gridcolor','r','linewidth',2);
              set(gca,'xtick',1:1:12,'ytick',1:1:12);
              axis image; 
              title('基于{ \color{red}DFS} 算法的路径规划 ','fontsize',16)
              drawnow;
        end
      %  
end        

end

function dijkstra2(handles,map2,start_node,dest_node,handles1)
% uicontrol('Style','pushbutton','String','again', 'FontSize',12, ...
 %      'Position', [1 1 60 40], 'Callback','dijkstra1');
 global data;
%% set up color map for display 
cmap = [1 1 1; ...%  1 - white - 空地
        0 0 0; ...% 2 - black - 障碍 
        1 0 0; ...% 3 - red - 已搜索过的地方
        0 0 1; ...% 4 - blue - 下次搜索备选中心 
        0 1 0; ...% 5 - green - 起始点
        1 1 0;...% 6 - yellow -  到目标点的路径 
       1 0 1];% 7 - -  目标点 
colormap(cmap); 
map1=map2;
nrows = 11; 
ncols = 11;  
%start_node = sub2ind(size(map1), start); 
%dest_node = sub2ind(size(map1),goal);           
% % 距离数组初始化
distanceFromStart = Inf(nrows,ncols);  
distanceFromStart(start_node) = 0; 
%distanceFromgoal = Inf(nrows,ncols);  
%distanceFromgoal(dest_node) = 0; 
% % 对于每个格单元，这个数组保存其父节点的索引。 
parent = zeros(nrows,ncols); 
a=[];
% % 主循环
%writerObj = VideoWriter('Dijkstra.avi');
%open(writerObj);
tic
axes(handles);%将handles设置为当前句柄
 while true 
  % 画出现状图
  map1(start_node) = 5;
  map1(dest_node) = 7; 
  image(1.5, 1.5, map1); %该函数用于显示图像image（x,y,c)c中的每一个元素指明了图像块的颜色，x,y指明像素中心的位置
  grid on
  set(gca,'gridline','-','gridcolor','r','linewidth',2);
  set(gca,'xtick',1:1:12,'ytick',1:1:12);
  axis image; 
  title('基于{ \color{red}Dijkstra} 算法的路径规划 ','fontsize',16)
  drawnow;%刷新屏幕，把每一步结果都显示出来 
   % 找到距离起始点最近的节点
  [min_dist, current] = min(distanceFromStart(:)); %返回当前距离数组(距离起点）的最小值和最小值的位置索引。
  %[min_dist1, current1] = min(distanceFromgoal(:)); %返回当前距离数组（距离目标点）的最小值和最小值的位置索引。
   if ((current == dest_node) || isinf(min_dist)) %搜索到目标点或者全部搜索完，结束循环。
         break; 
   end; 
 map1(current) = 3; %将当前颜色标为红色。
distanceFromStart(current) = Inf;  %当前区域在距离数组中设置为无穷，表示已搜索。
%distanceFromgoal(current1) = Inf;  %当前区域在距离数组中设置为无穷，表示已搜索。
 [i, j] = ind2sub(size(distanceFromStart), current); %返回当前位置的坐标
 %[i1, j1] = ind2sub(size(distanceFromgoal), current1); %返回当前位置的坐标
 neighbor = [ 
            i,j+1;... 
            i-1,j;... 
            i+1,j;... 
            
             i,j-1]; %确定当前位置的上下左右区域。
 outRangetest = (neighbor(:,1)<1) + (neighbor(:,1)>nrows) +...
                    (neighbor(:,2)<1) + (neighbor(:,2)>ncols ); %判断下一次搜索的区域是否超出限制。   
 locate = outRangetest>0; %返回超限点的行数。
   %locate1 = find(outRangetest1>0); %返回超限点的行数。
 %locate2 = find(outRangetest2>0); %返回超限点的行数。
 neighbor(locate,:)=[]; %在下一次搜索区域里去掉超限点，删除某一行。
 neighborIndex = sub2ind(size(map1),neighbor(:,1),neighbor(:,2)); %返回下次搜索区域的索引号。
 for i=1:length(neighborIndex) 
 if (map1(neighborIndex(i))~=2) && (map1(neighborIndex(i))~=3 && map1(neighborIndex(i))~= 5) 
     map1(neighborIndex(i)) = 4; %如果下次搜索的点不是障碍，不是起点，没有搜索过就标为蓝色。
     if((neighborIndex(i)+1==current)||(neighborIndex(i)-1==current))
        if distanceFromStart(neighborIndex(i))> min_dist + 1  
          distanceFromStart(neighborIndex(i)) = min_dist+1; 
             parent(neighborIndex(i)) = current; %如果在距离数组里。       
        end 
     else
         if distanceFromStart(neighborIndex(i))> min_dist + 1  
          distanceFromStart(neighborIndex(i)) = min_dist+1; 
             parent(neighborIndex(i)) = current; %如果在距离数组里。 
         end
     end
  end 
 end 
 end
if (isinf(distanceFromStart(dest_node))) 
    route = [];
else
    %提取路线坐标
  route =dest_node ;
  while (parent(route(1)) ~= 0) 
         route = [parent(route(1)), route];     
  end 
%  动态显示出路线 
        for k = 2:length(route) - 1 
            if(map1(route(k))==2)
                
                break;
            else
                map1(route(k)) = 6; 
            end
                [x,y]=ind2sub([11,11],route(k));
                data{1,2}=num2str(x);
                position_y=num2str(y);
                data{1,2}=strcat('[',data{1,2},',',position_y,']');
                data{1,5}='move';
                set(handles1.mydata,'Data',data);
               image(1.5, 1.5, map1);
                set(gca,'gridline','-','gridcolor','r','linewidth',2);
               set(gca,'xtick',1:1:12,'ytick',1:1:12);
              grid on; 
              axis image;
              title('基于{ \color{red}Dijkstra} 算法的路径规划 ','fontsize',16)
              drawnow
        end  
end
% 
end


% --- Executes on button press in task_allocation.
function task_allocation_Callback(hObject, eventdata, handles)
% hObject    handle to task_allocation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global n receive_task ;
map2=get(handles.init_map,'userdata');
if(isempty(map2))
    msgbox('请先初始化地图','消息');
    return
end
original_task=receive_task;
%  task=randperm(4,1)+23;
%  task=[task,randperm(4,1)+28,randperm(4,1)+34,randperm(4,1)+39,...
%      randperm(4,1)+56,randperm(4,1)+61,randperm(4,1)+67,randperm(4,1)+72,...
%      randperm(4,1)+89,randperm(4,1)+94,randperm(4,1)+100,randperm(4,1)+105];
if ~isempty(original_task)    
      robot=[2,4];
     count=length(original_task);  
     type=get(handles.allocation_type,'value');
     switch type
         case 1
             [~,~,s]=task1(n,original_task',count,2,robot');%顺序分配
         case 2
              [~,~,s]=task7(n,original_task',count,2,robot');%顺序分配
         case 3
             [~,~,s]= task6(n,original_task',count,2,robot' ,0.1);%拍卖法进行任务分配
     end
        for i=1:size(s{1},1)
            map2(s{1}(i,1),s{1}(i,2))=7;
        end
        picture=image(handles.img,1.5, 1.5, map2);
        grid on
        set(gca,'gridline','-','gridcolor','r','linewidth',2);
        set(gca,'xtick',1:1:12,'ytick',1:1:12);
        axis image; 
        set(hObject,'userdata',s{1});
        handles.picture=picture;
        guidata(hObject,handles);
else
    msgbox('当前不存在任务');
end
end
% --------------------------------------------------------------------
function connect_Callback(hObject, eventdata, handles)
% hObject    handle to connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[~,task_handles]=TCP_server;
 
handles.task=task_handles;
guidata(handles.init_map,handles);
t1 = timer('Period',2, 'timerfcn', {@taskDisp, handles}, 'ExecutionMode', 'fixedSpacing');
 start(t1);
end


function taskDisp(hObject,eventdata,handles)
global receive_task player
      if ~isempty(get(handles.task,'userdata'))
           [y,Fs] = audioread('任务提示.mp3');
           player = audioplayer(y,Fs);  % 建立音乐播放器
           play(player);  % 播放音乐
           pause(2);
           receive_task=get(handles.task,'userdata');
           set(handles.task,'userdata',[]);
      else
          receive_task=[];
      end
          
end

% --- Executes on button press in init_map.
function init_map_Callback(hObject, eventdata, handles)
global display picture_disp
% hObject    handle to init_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cmap = [1 1 1; ...%  1 - white - 空地
        0 0 0; ...% 2 - black - 障碍 
        1 0 0; ...% 3 - red - 已搜索过的地方
        0 0 1; ...% 4 - blue - 下次搜索备选中心 
        0 1 0; ...% 5 - green - 起始点
        1 1 0;...% 6 - yellow -  到目标点的路径 
       1 0 1];% 7 - -  目标点 
colormap(cmap); 
    map2 = zeros(11); 
    map2(2:5, 3:4) = 2;
    map2(2:5,6:7 ) = 2;
    map2(2:5,9:10 ) = 2; 
    map2(7:10, 3:4) = 2;
    map2(7:10,6:7 ) = 2;
    map2(7:10,9:10 ) = 2;
    start_node=str2num(get(handles.edit4,'string'));
    if size(start_node,2)>1
        msgbox('目前不支持多个机器人','初始化');
        return;
    end
    if size(start_node,2)==0
        msgbox('请先输入起点','初始化');
        return;
    end
    map2(start_node)=5;
    picture=image(handles.img,1.5, 1.5, map2); %该函数用于显示图像image（x,y,c)c中的每一个元素指明了图像块的颜色，x,y指明像素中心的位置
    picture_disp=1;
    if display==0
        set(handles.img,'visible','off')
    end
    if strcmp('off',get(handles.img,'visible'))
        set(picture,'visible','off')
        set(handles.img,'visible','off')
    end
    axes(handles.img);
    grid on;
    set(gca,'gridline','-','gridcolor','r','linewidth',2);
    set(gca,'xtick',1:1:12,'ytick',1:1:12);
    axis image; 
     data=cell(1,5);
     data{1,1}=1;
     [x,y]=ind2sub([11,11],start_node);
     data{1,2}=num2str(x);
     position_y=num2str(y);
     data{1,2}=strcat(data{1,2},',',position_y);
     data{1,3}='0';
     data{1,4}='0';
     data{1,5}='IDLE';
    set(handles.mydata,'Data',data)
    set(hObject,'userdata',map2);
    handles.picture=picture;
    guidata(hObject,handles);
end

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button=questdlg('是否确认关闭','关闭确认','是','否','是');
if strcmp(button,'是')
    close(gcf)
   %delete(hObject);
else
    return;
end
end



% --- Executes during object creation, after setting all properties.
function allocation_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to allocation_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% ispc用来判断当前的电脑系统是否是windows系统，是返回1，不是返回0
% isequal判断矩阵(数组)内容是否相等
%CreateFcn 是在控件对象创建的时候发生(一般为初始化样式，颜色，初始值等)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in path_planning_type.
function path_planning_type_Callback(hObject, eventdata, handles)
% hObject    handle to path_planning_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns path_planning_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from path_planning_type
end

% --- Executes during object creation, after setting all properties.
function path_planning_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to path_planning_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function task_allocation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in restart.
function restart_Callback(hObject, eventdata, handles)
% hObject    handle to restart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stop;
stop=1-stop;
end


% --- Executes on key press with focus on edit4 and none of its controls.
function edit4_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'string','');
end



% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8
set(handles.figure1,'color','cyan');
end

% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9
set(handles.figure1,'color',[0.8,0.8,0.8]);
end



% --------------------------------------------------------------------
function robotfigure_Callback(hObject, eventdata, handles)
% hObject    handle to robotfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global display 
    if display==0
        display=1;
        set(handles.img,'visible','on');
         set(handles.picture,'visible','on');
    else
        display=0;
        set(handles.img,'visible','off');
        set(handles.picture,'visible','off');
    end
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
    if ~isempty(timerfind)
       stop(timerfind);
       delete(timerfind);
    end
end


% --------------------------------------------------------------------
function car_state1_Callback(hObject, eventdata, handles)
% hObject    handle to car_state1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uitable= data;
handles.mydata=uitable;
guidata(hObject,handles);
end
