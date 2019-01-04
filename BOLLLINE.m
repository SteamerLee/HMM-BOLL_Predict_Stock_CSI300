%Author: Samuel Li
%Date: 2017-2018
%data period: 2010.04.16--2013.12.31
function [flag1]=BOLLLINE()
%--------------------布林线分析函数-----------------------------
%参数flag1输出为以布林线规则，在某分钟是否突破上、下轨线的指令矩阵。
load ('..\IF1MIN.mat');
%请把此目录设为数据存放所在的目录
fee=0.15/10000;%手续费
Open=data(:,1);%开盘价
High=data(:,2);%最高价
Low=data(:,3);%最低价
Close=data(:,4);%收盘价
Vol=data(:,5);%成交量
Openint=data(:,6);%持仓量
minline=20;%取x分钟作时间窗口用作判断
minlinep=minline+1;	%预测的当前分钟
flag1=[];%判断信号
MB=[];%中轨线
MBSTD=[];UP=[];DN=[];bper=[];%中轨线标准差,上轨线,下轨线,b%；
MB(1:minline,1)=0; MBSTD(1:minline,1)=0; UP(1:minline,1)=0; DN(1:minline,1)=0; bper(1:minline,1)=0.5;%初始化，开始的前minline个时间窗口的值都设为0
%BOLL线中轨线，上下轨线计算
  for i=(minlinep):242720		
    istart=i-minline;  iend=i-1;	%定义参考的时间窗口第一个与最后一个坐标
    MB(i,1)=(sum(Close(istart:iend,1))).*0.05;%中轨线，以时间窗口内的分钟的收盘价来计算；
    MBRANGE=Close(istart:iend,1);
    MBSTD(i,1)=std(MBRANGE,1,1);%标准差 
    UP(i,1)=MB(i,1)+(MBSTD(i,1).*2);%上轨线,缺省值为2，中轨线加减2倍标准差
    DN(i,1)=MB(i,1)-(MBSTD(i,1).*2);%下轨线
	bper(i,1)=((Close(iend,1)-DN(i,1))./(UP(i,1)-DN(i,1)));%b percentage	
  end	%将回测数据的分钟数的b%全部算出
  for i=1:242720
     if bper(i,1)>=0.9        %以标志flag1为判断b percentage 在BOLL线中所处位置，是否达到判断条件；
	    flag1(i,1)=1;		 %以超过0.9看作越过接近上轨线，标志位为1；
       elseif bper(i,1)<=(-0.1)   %在-0.1以下的看作越过下轨线，置0；
	    flag1(i,1)=0;         
	   else
	    flag1(i,1)=0.5;          %在0.1到0.9之间的为无警报，置0.5；	包括前minline个窗口b%被初始化为0,也代表无警报，不操作。 
	 end                           
  end	%求出回测数据每分钟是否应给出相应信号的状态
  
 figure(1);
 plot(time(:,1),UP(:,1),'-y',time(:,1),DN(:,1),'-b',time(:,1),Close(:,1),'-g',time(:,1),MB(:,1),'-r');
 xlabel('Time(2010.04.16--2013.12.31)');
 ylabel('IF300');