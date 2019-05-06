 function [time,sum_cost,s]=task1(n,rand_task,count,robot_count,robot)%顺序分配时的情况
[robotx,roboty]=ind2sub([n,n],robot);
robotd=[robotx,roboty];
[taskx,tasky]=ind2sub([n,n],rand_task);
task=[taskx,tasky];
cost=zeros(robot_count,1);
s=cell(robot_count,1);
sum_cost=0;
for i=1:robot_count
    s{i}=[];
end
k=1;
tic  
 while k<=count
     for i=1:robot_count
       if(mod(k,robot_count)==i)
        s{i}=[s{i};task(k,:)];
        break;
       elseif(mod(k,robot_count)==0)
         s{robot_count}=[s{robot_count};task(k,:)]; 
         break;
       end
     end
  k=k+1;      
 end
 for i=1:robot_count
  [a1,~]=size(s{i});
  j=1;
  while j<a1 
    cost(i)=cost(i)+abs(s{i}(j,1)-s{i}(j+1,1))+abs(s{i}(j,2)-s{i}(j+1,2)); 
    j=j+1;
  end
  cost(i)=cost(i)+abs(robotd(i,1)-s{i}(1,1))+abs(robotd(i,2)-s{i}(1,2));
 end
 for i=1:robot_count
     sum_cost=sum_cost+cost(i);
 end
 time=max(cost);
 toc;

