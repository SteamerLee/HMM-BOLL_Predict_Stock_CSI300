%Author: Samuel Li
%Date: 2017-2018
%data period: 2010.04.16--2013.12.31
function [flag2] = HMMLINE()
%-------------------HMM Function------------------%
%参数flag1输出为以HMM为基础，判断当前状态的信号
%HMM模型设隐含状态2个(z1,z2)，观测状态为2个(x1,x2)；
load ('..\IF1MIN.mat');
%请把此目录设为数据存放所在的目录
fee=0.15/10000;%手续费
Open=data(:,1);%开盘价
High=data(:,2);%最高价
Low=data(:,3);%最低价
Close=data(:,4);%收盘价
Vol=data(:,5);%成交量
Openint=data(:,6);%持仓量
minline=80;%取x分钟作时间窗口用作判断
minlinep=minline+1;	%预测的当前分钟
testl=242720;	%回测历史时期长度
flag2=[];%交易信号
flag2(1:minline,1) = 0.5;%初始化，前x分钟无警报
Observation=[];spreadseq=[];seq=[];
spread = Open - Close;	%计算每分钟开盘价与收盘价之差，隐含状态
Observation = ((High+Low)./2) - Close;%观测状态
for x = 1 : testl
	if Observation(x,1) < 0
		spreadseq(x,1) = 1;	%观测数值小于0，观测序列中观测状态设为1
	else
		spreadseq(x,1) = 2; %观测数值大于或等于0，观测序列中观测状态设为2
	end	
	if spread(x,1) < 0
		spread1seq(x,1) = 1;	%开盘价小于收盘价，当前分钟指数上升，隐含状态设为1
	else
		spread1seq(x,1) = 2; %开盘价大于等于收盘价，当前分钟指数下跌或不变，隐含状态设为2
	end
end
for i = (minlinep):testl
	istart = i-minline; iend = i-1; 
	seqstates(1:(minline-1),1) = spread1seq((istart+1):iend,1);%标定训练隐含状态序列
	seqest(1:(minline-1),1) = spreadseq(istart:(iend-1),1);%标定训练观测状态序列
	seq(1:minline,1) = spreadseq(istart:iend,1);%标定预测问题中的观测序列
	[ESTTRAN,ESTEMIT] = hmmestimate(seqest,seqstates);%学习问题中监督方法求解
	ESTSTATES = hmmviterbi(seq,ESTTRAN,ESTEMIT);%预测问题中Viterbi算法求解
	if ESTSTATES(end,1) == 1
		flag2(i,1) = 1;	%隐含状态为1时预测上升
	else
		flag2(i,1) = 0; %隐含状态为3时预测下跌
	end
end
%-----画预测隐含状态图-----
 x1=0;
 x2=0;
  for i=1:testl	
		if flag2(i,1) == 1
			x1=x1+1;
			Close1(x1,1) = Close(i,1);
			time1(x1,1) = time(i,1);
		else
			x2=x2+1;
			Close2(x2,1) = Close(i,1);
			time2(x2,1) = time(i,1);
		end
  end
  h1=figure(3);  
	plot(time1(:,1),Close1(:,1),'LineStyle','none','color','r','MarkerSize',2,'Marker','o');
  hold on;
    plot(time2(:,1),Close2(:,1),'LineStyle','none','color','b','Marker','o','MarkerSize',2);
  hold on;
  xlabel('Time(2010.04.16--2013.12.31)');
  ylabel('Transaction Signal');
  legend('Up Signal','Down Signal');
  