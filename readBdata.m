
% coldate=[7,7,23];
% filename = ['commissioning\Bdata\Log\','sit_',num2str(coldate(3)),'_',num2str(coldate(2),'%02d'),'_',num2str(coldate(1),'%02d'),'.txt'];
lat0 = 13.036;
lon0= 77.5124;
h0 = 930;
LUTxyz=lla2ecef([lat0,lon0,h0])'*1e-3;
fbias=-13;
load('clrs.mat','clrs')
% wgs84 = wgs84Ellipsoid('kilometers');

% 
% 
% fileID=fopen(filename);
% dataarr=textscan(fileID,'%s%[^\n\r]','Delimiter','');
% lines=dataarr{1};
% clear dataarr
% 
% 
% 
% noOfLines = length(lines);
% 
% bID = cell(1,noOfLines);
% msg = cell(1,noOfLines);
% foa = zeros(1,noOfLines);
% foff = zeros(1,noOfLines);
% toa= repmat(datetime,1,noOfLines);
% toff = zeros(1,noOfLines);
% CNR = zeros(1,noOfLines);
% antNo=zeros(1,noOfLines);
% SIDa = zeros(1,noOfLines);
% pXYZ= zeros(3,noOfLines);
% vXYZ = zeros(3,noOfLines);
% err1 = zeros(1,noOfLines);
% err2 = zeros(1,noOfLines);
% 
% for i=1:noOfLines
%     fields = split(lines{i},',');
%     msg{i}=fields{2};
%     bID{i}=fields{3};
%     foa(i) = str2double(fields{5})-fbias;
%     foff(i) = str2double(fields{6});
%     toa(i) = datetime(fields{7},'InputFormat','yyyy-MM-dd HH:mm:ss.SSSSSSSSS');
%     toff(i) = str2double(fields{8});
%     CNR(i) = str2double(fields{9});
%     antNo(i) = str2double(fields{11})-419500;
%     SIDa(i) = str2double(fields{12});
%     pXYZ(:,i) = str2double(fields(13:15));
%     vXYZ(:,i) = str2double(fields(16:18));
%     err1(i) = str2double(fields{19});
%     err2(2) = str2double(fields{20});
% end
% save('data.mat','msg','bID','foa','foff','toa','toff','CNR','antNo','SIDa','pXYZ','vXYZ','err1','err2')

% close all

% ID='3476759F3F81FE0';%india
% pos=[13.036,77.5124,930];BRT=50;
% refFreq = 406.028000e6;
ID = '3ADE22223F81FE0';%uae
pos=[24.431,54.448,5];BRT=50;
refFreq = 406.043000e6;
ID = '9C6000000000001';%T-cal
pos=[43.5605,1.4808,214.27];BRT=30;
refFreq = 406.022000e6;

refLoc=lla2ecef(pos)'*1e-3;

idmatch = strcmp(bID,ID);
msgB = msg(idmatch);
toaB=toa(idmatch);
foaB=foa(idmatch);
antB=antNo(idmatch);
SIDb=SIDa(idmatch);
CNRb=CNR(idmatch);
pXYZb=pXYZ(:,idmatch);
vXYZb=vXYZ(:,idmatch);
[eld,nadd,rd]=getAngles(pXYZb,LUTxyz);
[elu,nadu,ru]=getAngles(pXYZb,refLoc);

fd1 = getDoppler(pXYZb,vXYZb,refLoc,foaB);
ftB = foaB - fd1;
dt = tof(pXYZb,refLoc);
ttB = toaB - dt/86400;


figure
for i=1:7
    sel=antB==i;
    t1=toaB(sel);
    f1=ftB(sel);
    s1=SIDb(sel);
    
    inds=s1(1:end-1) ~= s1(2:end);
    st=[1,find(inds)+1,length(t1)+1];
    noofSegs1=length(st)-1;
    subplot(7,1,i)
    hold on
    for j=1:noofSegs1
        sel1=st(j):st(j+1)-1;
        ferr=f1(sel1)-refFreq;        
        stem(t1(sel1),ferr,'Marker','.','Color',clrs(s1(st(j)),:))
    end    
    text(toaB(end),1,['rms= ',num2str(rms(ferr))])
    xlim([toaB(1),toaB(end)])
    ylim([-1.5 1.5])
    ylabel('FOA error(Hz)')
end

for i=1:7
    sel=antB==i;
    t1=toaB(sel);
    s1=SIDb(sel);
    cnr1=CNRb(sel);
    elu1=elu(sel);
    eld1=eld(sel);
    nadu1=nadu(sel);
    nadd1=nadd(sel);
    ru1=ru(sel);
    rd1=rd(sel);
    
    inds=s1(1:end-1) ~= s1(2:end);
    st=[1,find(inds)+1,length(t1)+1];
    noofSegs1=length(st)-1;
    figure
    for j=1:noofSegs1        
        sel1=st(j):st(j+1)-1;
        pltcolor=clrs(s1(st(j)),:);
        subplot(5,1,1)
        hold on
        stem(t1(sel1),cnr1(sel1),'Marker','.','Color',pltcolor)
        xlim([toaB(1),toaB(end)])
        ylim([0 50])
        ylabel('CNR(dB)')
        subplot(5,1,2)
        hold on
        plot(t1(sel1),eld1(sel1),'Marker','.','LineStyle','none','Color',pltcolor)
        xlim([toaB(1),toaB(end)])        
        ylim([0 90])
        ylabel('downlink El(deg)')
        
        subplot(5,1,3)
        hold on
        plot(t1(sel1),elu1(sel1),'Marker','.','LineStyle','none','Color',pltcolor)
        xlim([toaB(1),toaB(end)])
        ylim([0 90])
        ylabel('uplink El(deg)')
        subplot(5,1,4)
        hold on
        plot(t1(sel1),nadu1(sel1),'LineStyle','--','Color',pltcolor)
        plot(t1(sel1),nadd1(sel1),'LineStyle','-','Color',pltcolor)
        xlim([toaB(1),toaB(end)])
        ylim([0 20])
        ylabel('off-Nadir(deg)')
        subplot(5,1,5)
        hold on
        plot(t1(sel1),ru1(sel1),'LineStyle','--','Color',pltcolor)
        plot(t1(sel1),rd1(sel1),'LineStyle','-','Color',pltcolor)
        xlim([toaB(1),toaB(end)])
        ylim([0 3e4])
        ylabel('range(km)')
    end
    
end

%determine the groups
[chns,tt]=findGroupsInBdata(toaB,antB,BRT);
k=1;
h1=figure;
h2=figure;
for i=1:7
    for j=i+1:7
        [tderr,fderr,t]=findTDOA(ttB,ftB,chns,i,j);
        if k==8
            k=1;
            h1=figure;
            h2=figure;
        end
        figure(h1);
        subplot(7,1,k)
        stem(t,tderr,'Marker','.')
        text(toaB(end),30,['rms= ',num2str(rms(tderr))])
        xlim([toaB(1),toaB(end)]);
        ylim([-50 50])
        ylabel(['TDOA-',num2str(i),num2str(j)])
        figure(h2);
        subplot(7,1,k)
        stem(t,fderr,'Marker','.')
        text(toaB(end),1,['rms= ',num2str(rms(fderr))])
        xlim([toaB(1),toaB(end)]);
        ylim([-1.5 1.5])
        ylabel(['FDOA-',num2str(i),num2str(j)])
        k=k+1;
    end
end
















