function [locProb,accPerc,predAcc,H]=solStat(id,bID,noP,noB,lat,lon,locerr,EHE,solMethod,toa1,toa2,BRT,refLoc)
%single burst
idmatch = strcmp(id,bID);
singleBurst = idmatch & noB == 1;
idx1= singleBurst & noP>2;
noOfSolS = sum(idx1);
starttime=toa1(find(idx1,1,"first"));
endtime=toa1(find(idx1,1,"last"));
timespan = seconds(endtime - starttime);
noOfBursts = ceil(timespan/BRT);
PrLocS = noOfSolS/noOfBursts;
prc5kmS=sum(locerr(idx1)<5)/noOfSolS;
prc10kmS=sum(locerr(idx1)<10)/noOfSolS;
r1=locerr(idx1)./EHE(idx1);
p1 = sum(r1<1)/noOfSolS;
po = sum(r1<0.1)/noOfSolS;
pu = sum(r1>2)/noOfSolS;
predAccS = [p1,po,pu];
%multi burst
multiBurst = idmatch & noB > 1;
idx2 = multiBurst;
noOfSolM = sum(idx2);
noOf10minWnd = ceil(timespan/600);
PrLocM=noOfSolM/noOf10minWnd;
prc5kmM = sum(locerr(idx2)<5)/sum(idx2);
prc10kmM = sum(locerr(idx2)<10)/sum(idx2);
r2=locerr(idx2)./EHE(idx2);
p1 = sum(r2<1)/noOfSolM;
po = sum(r2<0.1)/noOfSolM;
pu = sum(r2>2)/noOfSolM;
predAccM = [p1,po,pu];

locProb = [PrLocS;PrLocM];
accPerc = [prc5kmS,prc10kmS;prc5kmM,prc10kmM];
predAcc = [predAccS;predAccM];

H = gobjects(1,6);
H(1)=figure('Name','accuracy');

subplot(4,1,1)
hold on
stem(toa1(idx1),locerr(idx1),'Marker','.')
plot(toa1(idx1),EHE(idx1),'Marker','.')
plot([starttime,endtime],[5,5])
text(endtime,5,num2str(prc5kmS,'%03.2f'))
plot([starttime,endtime],[10,10])
text(endtime,10,num2str(prc10kmS,'%03.2f'))
xlim([starttime,endtime])
ylim([0,20])
legend({'Loc err','EHE'})
ylabel('km')
subplot(4,1,2)
hold on
stem(toa1(idx1),r1,'Marker','.')
plot([starttime,endtime],[0.1,0.1])
plot([starttime,endtime],[1,1])
plot([starttime,endtime],[2,2])
xlim([starttime,endtime])
ylim([0 3]);
ylabel('error/EHE');
text(endtime,0.1,[num2str(predAccS(2),'%03.2f'),' overEstmn'])
text(endtime,2,[num2str(predAccS(3),'%03.2f'),' underEstmn'])
text(endtime,1,num2str(predAccS(1),'%03.2f'))
subplot(4,1,3)
hold on
toa = mean([toa1(idx2);toa2(idx2)]);
idx21 = solMethod(idx2) ==1;
idx22 = solMethod(idx2) ==2;
lerr=locerr(idx2);
stem(toa(idx21),lerr(idx21),'Marker','.','Color',[1 0 1])
stem(toa(idx22),lerr(idx22),'Marker','.','Color',[0 1 1])
plot(toa,EHE(idx2),'Marker','.')
CLEVEL=ones(1,noOfSolM);
plot(toa,5*CLEVEL)
text(endtime,5,num2str(prc5kmM,'%03.2f'))
plot(toa,10*CLEVEL)
text(endtime,10,num2str(prc10kmM,'%03.2f'))
xlim([starttime,endtime])
ylim([0,20])
if any(idx21)
    legend({'Loc err','Loc err','EHE'})
else
    legend({'Loc err','EHE'})
end
ylabel('km')
subplot(4,1,4)
hold on
stem(toa,r2,'Marker','.')
plot([starttime,endtime],[0.1,0.1])
plot([starttime,endtime],[1,1])
plot([starttime,endtime],[2,2])
xlim([starttime,endtime])
ylim([0 3]);
ylabel('error/EHE');
text(endtime,0.1,[num2str(predAccM(2),'%03.2f'),' overEstmn'])
text(endtime,2,[num2str(predAccM(3),'%03.2f'),' underEstmn'])
text(endtime,1,num2str(predAccM(1),'%03.2f'))


H(2)=figure;
subplot(3,1,1)
hold on
for i=2:7
    idx = singleBurst & noP==i;
    t=toa1(idx);
    stem(t,i*ones(size(t)),'Marker','.','Color','b');
    idx = singleBurst & noP>=i;
    noOfdet = sum(idx);
    text(endtime,i,num2str(noOfdet/noOfBursts,'%03.2f'))
end
ylabel('No of Packets(Single Burst)')
plot([starttime,endtime],[3,3],'r');
subplot(3,1,2)
hold on
stem(toa,noB(idx2))
plot([starttime,endtime],[2,2]);
text(endtime,2,num2str(PrLocM,'%03.2f'))
xlim([starttime,endtime])
ylabel('No of Bursts')
subplot(3,1,3)
stem(toa,noP(idx2))
xlim([starttime,endtime])
ylabel('No of Packets(Multi Burst)')
%histograms
H(3)=figure;
edges=0:0.2:20;
derr=edges(1:end-1)+0.1;
h=histogram(locerr(idx1),[edges Inf],'Normalization','cdf');
dd=100*h.Values;
plot(derr,dd(1:end-1))
hold on
plot([5,5],[0,100*prc5kmS])
text(5,100*prc5kmS-2,num2str(100*prc5kmS,'%4.1f'))
plot([10,10],[0,100*prc10kmS])
text(10,100*prc10kmS-2,num2str(100*prc10kmS,'%4.1f'))
ylim([0 100])
xlim([0 20]);
grid on
text(20,dd(end-1),num2str(dd(end-1)))
xlabel('error(km)')
ylabel('cumulative percentage')
title(strcat('single burst location accuracy (',num2str(noOfSolS),' locations)'))

H(4)=figure;
edges=0:0.2:20;
derr=edges(1:end-1)+0.1;
h=histogram(locerr(idx2),[edges Inf],'Normalization','cdf');
dd=100*h.Values;
plot(derr,dd(1:end-1))
hold on
plot([5,5],[0,100*prc5kmM])
text(5,100*prc5kmM-2,num2str(100*prc5kmM,'%4.1f'))
plot([10,10],[0,100*prc10kmM])
text(10,100*prc10kmM-2,num2str(100*prc10kmM,'%4.1f'))
ylim([0 100])
xlim([0 20]);
grid on
text(20,dd(end-1),num2str(dd(end-1)))
xlabel('error(km)')
ylabel('cumulative percentage')
title(strcat('Multi burst location accuracy (',num2str(noOfSolM),' 10-min Windows)'))
H(5)=figure;
scatterplot(lat(idx1),lon(idx1),refLoc)
title('Single Burst solution scatter plot')
H(6)=figure;
scatterplot(lat(idx2),lon(idx2),refLoc)
title('Multi Burst solution scatter plot')
end