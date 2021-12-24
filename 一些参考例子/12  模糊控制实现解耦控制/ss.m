%% 学习目标：模糊控制实现解耦控制
clear all
clc
%初始化
p1=0.5;q1=0.5;p2=0.5;q2=0.5;
p3=0.5;q3=0.5;p4=0.95;q4=0.5;
p5=0.95;q5=0.5;p6=0.95;q6=0.5;
p7=0.5;q7=0.5;p8=0.95;q8=0.5;
p9=0.5;q9=0.5;p10=0.95;q10=0.5;

p11=0.95;q11=0.5;p12=0.95;q12=0.5;
p13=0.65;q13=0.05;
%隶属函数型神经网的中心值、尺度因子和权向量初始化部分
a10=[-2 0 2];a11=[-2 0 2];a20=[-2 0 2];a21=[-2 0 2];
b10=[1.5 1.5 1.5];b11=[1.5 1.5 1.5];
b20=[1.5 1.5 1.5];b21=[1.5 1.5 1.5];
v0=[-1 -0.5 -0.5;-0.5 0 0.5;0.5 0.5 1];
v1=[-1 -0.5 -0.5;-0.5 0 0.5;0.5 0.5 1];
%系统部分的初值
yp0=0;yp1=0;
ep0=0;ep1=0;
up0=1.05;up1=1.39;x1=0.12;x2=0.24;
y0=0;y1=0;
u1=0;e0=0;e1=0;sp=10;
k=1;se=0.02;sd=0.02;su=0.0522;
%开始
kp=0.284;ki=0.03;kd=0.626;
p12=0.5;q12=0.5;p22=0.5;q22=0.5;
p32=0.5;q32=0.5;p42=0.95;q42=0.5;
p52=0.95;q52=0.5;p62=0.95;q62=0.5;
p72=0.5;q72=0.5;p82=0.95;q82=0.5;
p92=0.5;q92=0.5;p102=0.95;q102=0.5;
p112=0.95;q112=0.5;p122=0.95;q122=0.5;
p132=0.65;q132=0.05;
%系统部分的初值
yp02=0;yp12=0;ep02=0;ep12=0;
up02=1.05;up12=1.39;x12=0.12;x22=0.24;
y02=0;y12=0;u12=0;e02=0;e12=0;sp2=5;
k=1;se2=0.02;sd2=0.02;su2=0.0522;
kp2=0.284;ki2=0.03;kd2=0.626;
%子系统1(SUB1)的J循环开始  
for J=1:50
   ep1=10-yp1;
   pid=kp*(ep1-ep0)+ki*ep1;
   up2=up1+pid;
   yp2=0.5*yp1+2.5*up2+2.5*up1; 
   yp(:,J)=yp2;
   up0=up1;
   up1=up2;
   ep0=ep1; 
   yp0=yp1;
   yp1=yp2;
end  
time=[1:1:50];
n=0.28*rand(size(time)); %产生的SUB1随机噪声
n1=0.3*rand(size(time));%产生的SUB2随机噪声
while(k<=50)
   %function deal with
 for(T=1:20)
   X1=x1*se;
   X2=x2*sd;
   
  if(X1<=-2)
     X1=-2;
  elseif(X1>=2)
     X1=2;
  end
  if(X2<=-2)
     X2=-2;
  elseif(X2>=2)
     X2=2;
  end

% FNN隐含层输出
for i=1:3
   for j=1:3
         A=[(X1-a11(:,i))/b11(:,i)].^2;
         B=[(X2-a21(:,j))/b21(:,j)].^2;
         h(i,j)=exp(-(A+B)/2);
   end
end   
%输出
sum=0;
for i=1:3
   for j=1:3
      sum=sum+h(i,j)*v1(i,j);
   end
end
ot=sum;cu=su*ot;u2=u1+cu;disp(u2);
if(u2<0)
u2=0;
elseif(u2>=1)
 u2=1;
end
y2=0.5*y1+2.5*u2+2.5*u1+n1(:,k)+0.01*y12; 
%+n1(:,k)+0.01*y12表示随机噪声和子系统间的相互耦合
disp(['the output y number is' int2str(T)]);
disp(y2);
Y(:,k)=y2;E=0.5*(sp-y2).^2;e2=sp-y2;

Es(:,k)=e2;
x1=e2;x2=e2-e1;e0=e1;e1=e2;
delot=(sp-y2)*2.5*su;

for i=1:3
   for j=1:3
      dv=v1(i,j)-v0(i,j);
      v2=v1(i,j)+p13*delot+q13*dv;
      v3(i,j)=v2;
   end
end

%更新中心值与权矩阵
  s1=0;
  for j=1:3
   s1=s1+v1(1,j)*h(1,j);
  end
  pa11=s1;
  a110=a10(:,1);  a111=a11(:,1);    
  dela11=pa11*(X1-a111)/b11(:,1).^2;
  da11=a111-a110;a112=a111+p1*dela11+q1*da11;
  a10(:,1)=a111;a11(:,1)=a112;
%a12
   s2=0;
   for j=1:3
   s2=s2+v1(2,j)*h(2,j);
   end
   pa12=s2;
   a120=a10(:,2);a121=a11(:,2);    
   dela12=pa12*(X1-a121)/b11(:,2).^2;
   da12=a121-a120;a122=a121+p2*dela12+q2*da12;
   a10(:,2)=a121;a11(:,2)=a122;
  %a13
   s3=0;
   for j=1:3
   s3=s3+v1(3,j)*h(3,j);
   end
   pa13=s3;a130=a10(:,3);a131=a11(:,3);    
   dela13=pa13*(X1-a131)/b11(:,3).^2;
   da13=a131-a130;a132=a131+p3*dela13+q3*da13;
   a10(:,3)=a131;a11(:,3)=a132;
% b11
   pb11=pa11;b110=b10(:,1);b111=b11(:,1);    
   delb11=pb11*[(X1-a111)].^2/b111.^3;
   db11=b111-b110;
   b112=b111+p4*delb11+q4*db11;
   b10(:,1)=b111;b11(:,1)=b112;
%b12
   pb12=pa12;b120=b10(:,2);b121=b11(:,2);    
   delb12=pb12*[(X1-a121)].^2/b121.^3;
   db12=b121-b120;b122=b121+p5*delb12+q5*db12;
   b10(:,2)=b121;b11(:,2)=b122;
%b13
   pb13=pa13;b130=b10(:,3);b131=b11(:,3);  
   delb13=pb13*[(X1-a131)].^2/b131.^3;
   db13=b131-b130;
   b132=b131+p6*delb13+q6*db13;
   b10(:,3)=b131;b11(:,3)=b132;
%a21
    s4=0;
for i=1:3
    s4=s4+v1(i,1)*h(i,1);
end
    pa21=s4;a210=a20(:,1);a211=a21(:,1);    
    dela21=pa21*(X2-a211)/b21(:,1).^2;
    da21=a211-a210;
    a212=a211+p7*dela21+q7*da21;
    a20(:,1)=a211;a21(:,1)=a212;
%a22
    s5=0;
for i=1:3
    s5=s5+v1(i,2)*h(i,2);
end
    pa22=s5;a220=a20(:,2);a221=a21(:,2);    
    dela22=pa22*(X2-a221)/b21(:,2).^2;
    da22=a221-a220;
    a222=a221+p8*dela22+q8*da22;
    a20(:,2)=a221;a21(:,2)=a222;
%a23  
     s6=0;
 for i=1:3
     s6=s6+v1(i,3)*h(i,3);
 end
    pa23=s6;
    a230=a20(:,3);a231=a21(:,3);    
    dela23=pa23*(X2-a231)/b21(:,3).^2;
    da23=a231-a230;
    a232=a231+p9*dela23+q3*da23;
    a20(:,3)=a231;a21(:,3)=a232;
%b21
   pb21=pa21;
   b210=b20(:,1);b211=b21(:,1);    
   delb21=pb21*[(X2-a211)].^2/b211.^3;
   db21=b211-b210;
   b212=b211+p10*delb21+q10*db21;
   b20(:,1)=b211;b21(:,1)=b212;
%b22
   pb22=pa22;
   b220=b20(:,2);b221=b21(:,2);    
   delb22=pb22*[(X2-a221)].^2/b221.^3;
   db22=b221-b220;
   b222=b221+p11*delb22+q11*db22;
   b20(:,2)=b221;b21(:,2)=b222;
%b23
   pb23=pa23;
   b230=b20(:,3);b231=b21(:,3);    
   delb23=pb23*[(X2-a231)].^2/b231.^3;
   db23=b231-b230;
   b232=b231+p12*delb23+q12*db23;
   b20(:,3)=b231;b21(:,3)=b232;
   v0=v1;v1=v3;
   if(abs(e1)<0.00015)
      break;
   end
  
end 
y0=y1;y1=y2;u0=u1;u1=u2;

%权向量初始化部分
a102=[-2 0 2];a112=[-2 0 2];% FNN隐层的权值阵
a202=[-2 0 2];a212=[-2 0 2];
b102=[1.5 1.5 1.5];b112=[1.5 1.5 1.5];% 尺度因子
b202=[1.5 1.5 1.5];b212=[1.5 1.5 1.5];
v02=[-1 -0.5 -0.5;-0.5 0 0.5;0.5 0.5 1];% FNN输出层权值阵
v12=[-1 -0.5 -0.5;-0.5 0 0.5;0.5 0.5 1];
%子系统2(SUB2)的J循环开始 
for J=1:100
   ep2=5-yp12;
   pid2=kp2*(ep12-ep02)+ki2*ep12;
   up22=up12+pid2;
   yp22=0.5*yp12+1.25*up22+1.25*up12; 
   yp2(:,J)=yp22;
   up02=up12;up12=up22;ep02=ep12;yp02=yp12;
   yp12=yp22;
end   
%while(k<=250)
   %处理权矩阵
for(T=1:20)
   X12=x12*se2;X22=x22*sd2;
   
   
  if(X12<=-2)
     X12=-2;
  elseif(X12>=2)
     X12=2;
  end
  if(X22<=-2)
     X22=-2;
  elseif(X22>=2)
     X22=2;
  end

%FNN隐含层输出  
for i=1:3
   for j=1:3
         A=[(X12-a112(:,i))/b112(:,i)].^2;
         B=[(X22-a212(:,j))/b212(:,j)].^2;
         h(i,j)=exp(-(A+B)/2);
   end
end   
%输出
sum2=0;
for i=1:3
   for j=1:3
      sum2=sum2+h(i,j)*v12(i,j);
   end
end
ot=sum2;cu=su2*ot;u22=u12+cu;
disp(u22);
if(u22<0)
u22=0;
elseif(u22>=1)
 u22=1;
end

 y22=0.5*y12+1.25*u22+1.25*u12+n(:,k)+0.01*y1;
 %+n(:,k)+0.01*y1表示随机噪声和子系统间的相互耦合

disp(['the output y2 number is' int2str(T)]);
disp(y22);Y2(:,k)=y22;E2=0.5*(sp2-y22).^2;e22=sp2-y22;

E22(:,k)=e22;x12=e22;x22=e22-e12;e02=e12;e12=e22;
delot=(sp2-y22)*1.25*su2;

for i=1:3
   for j=1:3
      dv=v12(i,j)-v02(i,j);
      v22=v12(i,j)+p132*delot+q132*dv;
      v32(i,j)=v22;
   end
end


  s12=0;
  for j=1:3
   s12=s12+v12(1,j)*h(1,j);
  end
  pa112=s12;
  a1102=a102(:,1);a1112=a112(:,1);    
  dela112=pa112*(X12-a1112)/b112(:,1).^2;
  da112=a1112-a1102;a1122=a1112+p12*dela112+q12*da112;
  a102(:,1)=a1112;a112(:,1)=a1122;
%a12
   s22=0;
   for j=1:3
   s22=s22+v12(2,j)*h(2,j);
   end
   pa122=s22;
   a1202=a102(:,2);a1212=a112(:,2);    
   dela122=pa122*(X12-a121)/b112(:,2).^2;
   da122=a1212-a1202;
   a1222=a1212+p22*dela122+q22*da122;
   a102(:,2)=a1212;a112(:,2)=a1222;
  %a13
   s32=0;
   for j=1:3
   s32=s32+v12(3,j)*h(3,j);
   end
   pa132=s32;
   a1302=a102(:,3);a1312=a112(:,3);    
   dela132=pa132*(X12-a1312)/b112(:,3).^2;
   da132=a1312-a1302;
   a1322=a1312+p32*dela132+q32*da132;
   a102(:,3)=a1312;a112(:,3)=a1322;
% b11
   pb112=pa112;
   b1102=b102(:,1);b1112=b112(:,1);    
   delb112=pb112*[(X12-a111)].^2/b1112.^3;
   db112=b1112-b1102;
   b1122=b1112+p42*delb112+q42*db112;
   b102(:,1)=b1112;b112(:,1)=b1122;
%b12
   pb122=pa122;
   b1202=b102(:,2);b1212=b112(:,2);    
   delb122=pb122*[(X12-a1212)].^2/b1212.^3;
   db122=b1212-b1202;
   b1222=b1212+p52*delb122+q52*db122;
   b102(:,2)=b1212;b112(:,2)=b1222;
%b13
   pb132=pa132;
   b1302=b102(:,3);b1312=b112(:,3);    
   delb132=pb132*[(X12-a1312)].^2/b1312.^3;
   db132=b1312-b1302;
   b1322=b1312+p62*delb132+q62*db132;
   b102(:,3)=b1312;b112(:,3)=b1322;
%a21
    s42=0;
for i=1:3
    s42=s42+v12(i,1)*h(i,1);
end
    pa212=s42;
    a2102=a202(:,1);a2112=a212(:,1);    
    dela212=pa212*(X22-a2112)/b212(:,1).^2;
    da212=a2112-a2102;
    a2122=a2112+p72*dela212+q72*da212;
    a202(:,1)=a2112;a212(:,1)=a2122;
%a22
    s52=0;
for i=1:3
    s52=s52+v12(i,2)*h(i,2);
end
    pa222=s52;
    a2202=a202(:,2);a2212=a212(:,2);    
    dela222=pa222*(X22-a2212)/b212(:,2).^2;
    da222=a2212-a2202;
    a2222=a2212+p82*dela222+q82*da222;
    a202(:,2)=a2212;a212(:,2)=a2222;
%a23  
     s62=0;
 for i=1:3
     s62=s62+v1(i,3)*h(i,3);
 end
    pa232=s62;
    a2302=a202(:,3);a2312=a212(:,3);    
    dela232=pa232*(X22-a2312)/b212(:,3).^2;
    da232=a2312-a2302;
    a2322=a2312+p92*dela232+q32*da232;
    a202(:,3)=a2312;a212(:,3)=a2322;
%b21
   pb212=pa212;
   b2102=b202(:,1);b2112=b212(:,1);    
   delb212=pb212*[(X22-a2112)].^2/b2112.^3;
   db212=b2112-b2102;
   b2122=b2112+p102*delb212+q102*db212;
   b202(:,1)=b2112;b212(:,1)=b2122;
%b22
   pb222=pa222;
   b2202=b202(:,2);b2212=b212(:,2);    
   delb222=pb222*[(X22-a2212)].^2/b2212.^3;
   db222=b2212-b2202;
   b2222=b2212+p112*delb222+q112*db222;
   b202(:,2)=b2212;b212(:,2)=b2222;
%b23
   pb232=pa232;
   b2302=b202(:,3);b2312=b212(:,3);    
   delb232=pb232*[(X22-a2312)].^2/b2312.^3;
   db232=b2312-b2302;
   b2322=b2312+p122*delb232+q122*db232;
   b202(:,3)=b2312;b212(:,3)=b2322;
   v02=v12;v12=v32;
   if(abs(e12)<0.00015)
      break;
   end
end   
   
if(abs(e1)<=eps & abs(e)<=eps)
      break;
else
      k=k+1;
end
   y02=y12;y12=y22;u02=u12;u12=u22;
end
L=k-1; n2=n;
%L=k;
m=1:L;
R=ones(size(m));
sp=R*10;sp2=R*5;
a11  %子系统1运行结果中心值和尺度因子和权值阵
b11  %子系统1运行尺度因子
v1   %子系统1运行权值阵
a112  %子系统2运行结果中心值和尺度因子和权值阵
b112  %子系统2运行尺度因子
v2   %子系统2运行权值阵
figure(1)
plot(m,sp,'k', m,Y,'rx',m,sp2,'k', m,Y2,'bx',m,Es,'r',m,E22,'b');
legend('sp1:子系统1的输入','Y:子系统1的耦合结果','sp2:子系统2的输入',...
    'Y2:子系统2的耦合结果','Es:子系统1的误差','E22:子系统2的误差' ); 
%图标炷 
title('模糊神经网络FNN对相邻耦合子系统的解耦结果'),
xlabel('k'),
ylabel('yp,y and sp2,y2')
figure(2)
plot(m,n1,'k',m,n2,'r');
legend('n1:子系统1的噪声','n2:子系统2的噪声' ); %图标炷    
xlabel('k'),
ylabel('随机噪声')  
%%   大仙QQ：1960009019
%%   在线教育微信公众号：大仙一品堂