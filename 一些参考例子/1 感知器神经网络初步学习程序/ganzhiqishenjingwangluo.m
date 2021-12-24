
%%   学习目标：从学习第一个最简单的神经网络案例开启学习之路
%%   感知器神经网络   用于点的分类

clear all;
close all;
P=[0 0 1 1;0 1 0 1];                         %输入向量
T=[0 1 1 1];                                 %目标向量
net=newp(minmax(P),1,'hardlim','learnp');    %建立感知器神经网络
net=train(net,P,T);                          %对网络进行训练
Y=sim(net,P);                                %对网络进行仿真
plotpv(P,T);                                 %绘制感知器的输入向量和目标向量，绘制样本点
plotpc(net.iw{1,1},net.b{1});                %在感知器向量图中绘制分界线

