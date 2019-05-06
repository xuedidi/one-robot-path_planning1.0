# one-robot-path_planning1.0
该项目基于matlab的GUI编写了单机器人的多任务路径规划系统，模拟WMS仓库系统通过TCP通信发送给机器人系统，机器人系统进行任务分配和路径规划



## description
    
   GUI是整个系统的所有的GUI界面，其中Init.m用做系统的登录界面，robotallocation.m是系统1的主界面，TCP_server是系统的通信界面
   
   image包含系统所用到的相关资源
   
   path_planning_code包括路径规划的算法
   
   task_allocation——code 包括任务分配算法