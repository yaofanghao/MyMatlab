function y=wtfusion(x1,x2,N,wname)

%函数功能：
%     函数x=wtfusion(x1,x2,N,wname)将两幅原图像x1,x2进行基于小波变换的图像融合，得到融合后的图像y
%     近似分量采用加权平均的融合规则，各细节分量采用基于区域特性量测的融合规则
%输入参数：
%     x1----输入原图像1
%     x2----输入原图像2
%     N----小波分解的层数
%     wname----小波基函数
%输出参数：
%     y----原图像融合后得到的图像
%-----------------------------------------------------------------%

x1=double(x1);                   %将uint8的图像数据类型转换成double型进行数据处理
x2=double(x2);

 %将原图像x1,x2分别进行N层小波分解，wname为小波基函数，
 %C为各层分解系数,S为各层分解系数长度,也就是大小.
 %C的结构:c=[A(N)|H(N)|V(N)|D(N)|H(N-1)|V(N-1)|D(N-1)|H(N-2)|V(N-2)|D(N-2)|...|H(1)|V(1)|D(1)]
 %A(N)代表第N层低频系数,H(N)|V(N)|D(N)代表第N层高频系数,分别是水平,垂直,对角高频
 %S(N+2行2列)的结构是储存各层分解系数长度的,即第一行是A(N)的长度（其实是A(N)的原矩阵的行数和列数）,
 %第二行是H(N)|V(N)|D(N)|的长度,第三行是H(N-1)|V(N-1)|D(N-1)的长度,
 %倒数第二行是H(1)|V(1)|D(1)长度,最后一行是X的长度(大小)

[C1,S1]=wavedec2(x1,N,wname); 
[C2,S2]=wavedec2(x2,N,wname);  

A1=appcoef2(C1,S1,wname,N);            %提取出小波分解的近似分量
A2=appcoef2(C2,S2,wname,N);
A=0.5*A1+0.5*A2;                       %近似分量的融合规则采用加权平均的方法

%仿照matlab中近似分量和细节分量的存储方式，把融合后的近似分量和细节分量转成行向量，然后存入向量C中
%这样做是为了方便重构原图像

a=reshape(A,1,S1(1,1)*S1(1,2));        %将A转换成行向量
C=a;

for i=N:-1:1                           %循环从第N层到第1层    
    [H1,V1,D1]=detcoef2('all',C1,S1,i);    %提取出小波分解的各层细节分量
    [H2,V2,D2]=detcoef2('all',C2,S2,i);
    H=f(H1,H2);                            %各层细节分量的融合规则采用基于区域特性量测的融合规则
    V=f(V1,V2);
    D=f(D1,D2);
    h=reshape(H,1,S1(N+2-i,1)*S1(N+2-i,2));%分别将融合后的细节分量转成行向量，并存入行向量C中
    v=reshape(V,1,S1(N+2-i,1)*S1(N+2-i,2));
    d=reshape(D,1,S1(N+2-i,1)*S1(N+2-i,2));
    C=[C,h,v,d];
end

S=S1;
y=waverec2(C,S,wname);      %重构原图像
figure;imshow(uint8(y));title('基于小波变换的融合图像')
end

function y=f(x1,x2)

%函数功能：
%       y=f(x1,x2)将两幅原图像x1和x2基于区域特性量测的融合规则进行融合,得到融合后的图像y
%       首先计算两幅图像的匹配度，若匹配度大于阈值，说明两幅图像对应局部能量较接近，
%       因此采用加权平均的融合方法；若匹配度小于阈值，说明两幅图像对应局部能量相差较大，
%       因此选取局部区域能量较大的小波系数作为融合图像的小波系数
%输入参数：
%      x1----输入原图像1
%      x2----输入原图像2
%输出参数：
%      y----融合后的图像
%------------------------------------------------------------%

w=1/16*[1 2 1;2 4 2;1 2 1];   %权系数
E1=conv2(x1.^2,w,'same');     %分别计算两幅图像相应分解层上对应局部区域的“能量”
E2=conv2(x2.^2,w,'same');
M=2*conv2(x1.*x2,w,'same')./(E1+E2);%计算两幅图像对应局部区域的匹配度
T=0.7;                              %定义匹配阈值
Wmin=1/2-1/2*((1-M)/(1-T));
Wmax=1-Wmin;
[m,n]=size(M);

for i=1:m
    for j=1:n
        if M(i,j)<T                %如果匹配度小于匹配阈值，说明两幅图像对应局部区域能量距离较远；
            if E1(i,j)>=E2(i,j)    %那么就直接选取区域能量较大的小波系数
                y(i,j)=x1(i,j);
            else
                y(i,j)=x2(i,j);
            end
        else                       %如果匹配度大于匹配阈值，说明两幅图像对应局部区域能量比较接近；
            if E1(i,j)>=E2(i,j)    %那么就采用加权的融合算法
                y(i,j)=Wmax(i,j)*x1(i,j)+Wmin(i,j)*x2(i,j);
            else
                y(i,j)=Wmin(i,j)*x1(i,j)+Wmax(i,j)*x2(i,j);
            end
        end
    end
end

end