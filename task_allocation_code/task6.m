function [time,sum_cost,s]=task6(n,rand_task,count,robot_count,robot ,percentage) %n矩阵大小  rand_task随机任务 
%count 任务数量  robot_count 机器人个数  robot机器人位置
[robotx,roboty]=ind2sub([n,n],robot);
robotd=[robotx,roboty];
[taskx,tasky]=ind2sub([n,n],rand_task);
task=[taskx,tasky];
sum_cost=0;
s_cost=zeros(robot_count,1);
%set(gca,'YDir','normal');
grid on; 
tic
j2=1;
% s=ones(0,0,5);
% for i=1:5
%     eval(['s',num2str(i),'=','s(:,:,i)']);
% end
s=cell(robot_count,1);
m=cell(robot_count,1);
fact=cell(robot_count,1);
for i=1:robot_count
    s{i}=[];
end
cost=zeros(robot_count,1);
cost_t=zeros(robot_count,1);
tic
time=0;
 while j2<=count
    [e,~]=size(task);
    for i=1:robot_count
       m{i}=[];
    end
    for i=1:robot_count
      fact{i}=[];
    end
    a=inf(robot_count,1);
    j=1;
 while j<=e
     for i=1:robot_count
        if(isempty(s{i}))
             if abs(robotd(i,1)-task(j,1))+abs(robotd(i,2)-task(j,2)) <time
                 cost(i)=(abs(robotd(i,1)-task(j,1))+abs(robotd(i,2)-task(j,2)))*percentage;
                 cost_t(i)=abs(robotd(i,1)-task(j,1))+abs(robotd(i,2)-task(j,2));
             else
                cost(i)= abs(robotd(i,1)-task(j,1))+abs(robotd(i,2)-task(j,2))-(1-percentage)*time;
                %  cost_t(i)=(1-percentage)*(abs(robotd(i,1)-task(j,1)-time)+abs(robotd(i,2)-task(j,2)))+(abs(robotd(i,1)-task(j,1))+abs(robotd(i,2)-task(j,2)))*percentage;
                cost_t(i)= abs(robotd(i,1)-task(j,1))+abs(robotd(i,2)-task(j,2));
             end;
        elseif(abs(s{i}(end,1)-task(j,1))+abs(s{i}(end,2)-task(j,2)))+s_cost(i)<time
             cost(i)=(abs(s{i}(end,1)-task(j,1))+abs(s{i}(end,2)-task(j,2)))*percentage;
              cost_t(i)=abs(s{i}(end,1)-task(j,1))+abs(s{i}(end,2)-task(j,2));
           %  cost_t(i)=(1-percentage)*(abs(s{i}(end,1)-task(j,1))+abs(s{i}(end,2)-task(j,2)))+(abs(s{i}(end,1)-task(j,1))+abs(s{i}(end,2)-task(j,2)))*percentage;
        elseif (abs(s{i}(end,1)-task(j,1))+abs(s{i}(end,2)-task(j,2)))+s_cost(i)>time
             cost(i)=abs(s{i}(end,1)-task(j,1))+abs(s{i}(end,2)-task(j,2))-(1-percentage)*(time-s_cost(i));
            cost_t(i)=abs(s{i}(end,1)-task(j,1))+abs(s{i}(end,2)-task(j,2));
        end
        m{i}=[m{i};cost(i)];
        fact{i}=[fact{i};cost_t(i)];
       % h1=find(m{i}==0);
        %q1=length(h1);
     end
     j=j+1;
  %    save('B:\新建文件夹\路径规划算法\任务分配算法\m.txt','m','-ascii');
 end
%  for i=1:robot_count
%      fpd=fopen('B:\新建文件夹\路径规划算法\任务分配算法\fact.txt','a');
%      fprintf(fpd,'%f\n',fact{i});
%      fclose(fpd);
%  end
%   q4=[q1;q2;q3];
%   [x4,y4]=max(q4);
    for i=1:robot_count
        a(i)=min(m{i});
    end
    [x,y]=min(a);
    fp=fopen('B:\新建文件夹\路径规划算法\任务分配算法\x6.txt','a');
    fprintf(fp,'%f\n',x);
    fclose(fp);
    for i=1:robot_count
        if(y==i)
            d=find(m{i}==x);
            s{i}=[s{i};task(d(1),:)];
            task(d(1),:)=[];
             s_cost(i)=s_cost(i)+fact{i}(d(1));
             sum_cost=sum_cost+fact{i}(d(1)); 
             break   
        end 
    end
    j2=j2+1; 
    time=max(s_cost);
 end
 toc;