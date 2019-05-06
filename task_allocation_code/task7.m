function [time,sum_cost,s]=task7(n,rand_task,count,robot_count,robot) %n矩阵大小  rand_task随机任务 
%count 任务数量  robot_count 机器人个数  robot机器人位置
[robotx,roboty]=ind2sub([n,n],robot);
robotd=[robotx,roboty];
[taskx,tasky]=ind2sub([n,n],rand_task);
task=[taskx,tasky];
s=cell(robot_count,1);%用细胞结构存储每个机器人的任务
m=[];
for i=1:robot_count
    s{i}=[];
end
sum_cost=0;
s_cost=zeros(robot_count,1);
set(gca,'YDir','normal');
tic
j2=1;
cost=zeros(robot_count,1);
tic
 while j2<=count
   m=[];
   j=1;
   for i=1:robot_count
        if(isempty(s{i}))
           cost(i)=abs(robotd(i,1)-task(j,1))+abs(robotd(i,2)-task(j,2));
        else
           cost(i)=abs(s{i}(end,1)-task(j,1))+abs(s{i}(end,2)-task(j,2)); 
        end
        m=[m;cost(i)];
   end
    [x,y]=min(m);
%     fp=fopen('B:\新建文件夹\路径规划算法\任务分配算法\x2.txt','a');
%     fprintf(fp,'%f\n',x);
%     fclose(fp);
    sum_cost=sum_cost+x;
   for i=1:robot_count
       if(y==i)
          
            s{i}=[s{i};task(1,:)];
            task(1,:)=[];
            s_cost(i)=s_cost(i)+x;
       end
   end
    j2=j2+1;
 end
 time=max(s_cost);
 toc
