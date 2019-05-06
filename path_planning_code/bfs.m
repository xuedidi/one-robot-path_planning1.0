%clc;
%clear;
%close all;
function bfs(handles,map2,start_node,dest_node)
%  uicontrol('Style','pushbutton','String','again', 'FontSize',12, ...
%        'Position', [1 1 60 40], 'Callback','bfs');
%% set up color map for display 
cmap = [1 1 1; ...%  1 - white - 空地
        0 0 0; ...% 2 - black - 障碍 
        1 0 0; ...% 3 - red - 已搜索过的地方
        0 0 1; ...% 4 - blue - 下次搜索备选中心 
        0 1 0; ...% 5 - green - 起始点
        1 1 0;...% 6 - yellow -  到目标点的路径 
       1 0 1];% 7 - -  目标点 
colormap(cmap); 
map1 = map2;
%wallpercent=0.4;
% % 设置障障碍 
%map1(ceil(10^2.*rand(floor(10*10*wallpercent),1))) =2;
%  map(ceil(10.*rand),ceil(10.*rand)) = 5; % 起始点
%map(ceil(10.*rand),ceil(10.*rand)) = 6; % 目标点
% %% 建立地图
nrows = 11; 
ncols = 11;  
% % 对于每个格单元，这个数组保存其父节点的索引。 
parent = zeros(nrows,ncols);
array=start_node;
% % 主循环
% tic
axes(handles);%将handles设置为当前句柄
 while ~isempty(array) 
  % 画出现状图
  map1(start_node) = 5;
  map1(dest_node) = 7;
  image(handles,1.5, 1.5, map1); 
  grid on; 
  set(gca,'gridline','-','gridcolor','r','linewidth',2);
  set(gca,'xtick',1:1:12,'ytick',1:1:12);
  axis image; 
  title('基于{ \color{red}BFS} 算法的路径规划 ','fontsize',16)
  drawnow; 
  
   current=array(1);
   array(1)=[];
   if ((current == dest_node) ) %搜索到目标点或者全部搜索完，结束循环。
         break; 
   end; 
  map1(current) = 3; %将当前颜色标为红色。
  
 [i, j] = ind2sub(size(map1), current); %返回当前位置的坐标
 neighbor = [  
            i,j+1;... 
            i+1,j;... 
            i-1,j;... 
             i,j-1]; %确定当前位置的上下左右区域。     
 %neighbor1 = [ 
    %    i-1,j-1;...
     %   i+1,j+1;...
      %  i-1,j+1;...
       %  i+1,j-1]; %确定当前位置的对角区域。      
 outRangetest = (neighbor(:,1)<1) + (neighbor(:,1)>nrows) +...
                    (neighbor(:,2)<1) + (neighbor(:,2)>ncols ); %判断下一次搜索的区域是否超出限制。   
 % outRangetest1 = (neighbor1(:,1)<1) + (neighbor1(:,1)>nrows) +...
     %                (neighbor1(:,2)<1) + (neighbor1(:,2)>ncols ); %判断下一次搜索的区域是否超出限制。        
 locate = outRangetest>0; %返回超限点的行数。
  % locate1 = find(outRangetest1>0); %返回超限点的行数。
 neighbor(locate,:)=[]; %在下一次搜索区域里去掉超限点，删除某一行。
 neighborIndex = sub2ind(size(map1),neighbor(:,1),neighbor(:,2)); %返回下次搜索区域的索引号。
  % neighbor1(locate1,:)=[]; %在下一次搜索区域里去掉超限点，删除某一行。
   % neighborIndex1 = sub2ind(size(map1),neighbor1(:,1),neighbor1(:,2)); %返回下次搜索区域的索引号。

 for i=1:length(neighborIndex) 
 if (map1(neighborIndex(i))~=2) && (map1(neighborIndex(i))~=3 && map1(neighborIndex(i))~= 5) 
     map1(neighborIndex(i)) = 4; %如果下次搜索的点不是障碍，不是起点，没有搜索过就标为蓝色。
     if(isempty(find(array==neighborIndex(i), 1)))
      array=[array;neighborIndex(i)];
      parent(neighborIndex(i)) = current;
     end
  end 
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
                set(gca,'gridline','-','gridcolor','r','linewidth',2);
                set(gca,'xtick',1:1:12,'ytick',1:1:12);
              grid on; 
              axis image; 
  title('基于{ \color{red}BFS} 算法的路径规划 ','fontsize',16);
  drawnow;
        end  
end        
%title('基于{ \color{red}BFS} 算法的路径规划 ','fontsize',16)
toc
