function [h,detstat]=analyzeBdata(ID,pos,refFreq,BRT,bID,foa,foff,toa,CNR,antNo,SIDa,pXYZ,vXYZ)
% close all
load('prns.mat','prns')
load('clrs.mat','clrs')

lat0 = 13.036;
lon0= 77.5124;
h0 = 930;
LUTxyz=lla2ecef([lat0,lon0,h0])'*1e-3;

refLoc=lla2ecef(pos)'*1e-3;

idmatch = strcmp(bID,ID);
toaB=toa(idmatch);
foaB=foa(idmatch);
foffB=foff(idmatch);
antB=antNo(idmatch);
SIDb=SIDa(idmatch);
CNRb=CNR(idmatch);
pXYZb=pXYZ(:,idmatch);
vXYZb=vXYZ(:,idmatch);
if sum(idmatch)==0
    'no detection'
    return;
end
[eld,nadd,rd]=getAngles(pXYZb,LUTxyz);
[elu,nadu,ru]=getAngles(pXYZb,refLoc);

fdu = getDoppler(pXYZb,vXYZb,refLoc,foaB);
ftB = foaB - fdu;
dt = tof(pXYZb,refLoc);
ttB = toaB - dt/86400;

h=gobjects(1,26);
h(26)=figure;
noOf10minWnd = round(seconds(toaB(end)-toaB(1))/600);
dh=histogram(toaB,noOf10minWnd);
detstat=sum(dh.Values>0)/noOf10minWnd;
hold on
plot([toaB(1) toaB(end)],[1 1])
xlim([toaB(1),toaB(end)])
text(toaB(end),1,num2str(detstat,'%4.2f'))
ylabel('No of Packets(in 10 min window)')
xlabel('time windows')
for i=1:7
    if mod(i,2)==1
       h(floor(i/2)+1)=figure ; 
    end
    sel=antB==i;
    t1=toaB(sel);
    if isempty(t1)
        continue;
    end
    f1=ftB(sel);
    s1=SIDb(sel);
    fdu1 = fdu(sel);
    fdd1 = foffB(sel);
    inds=s1(1:end-1) ~= s1(2:end);
    en=[find(inds),length(t1)];
    st=[1,en(1:end-1)+1];
    noofSegs1=length(en);
    subplot(2,1,mod(i-1,2)+1)
    ax=gca;
    hold on
    for j=1:noofSegs1
        sel1=st(j):en(j);
        ferr=f1(sel1)-refFreq;   
        satid=s1(st(j));
        pltcolor=clrs(satid,:);
        stem(t1(sel1),ferr,'Marker','.','Color',pltcolor)
        text(t1(sel1(1)),1+mod(j,2),getSatName(satid,prns))
    end   
   
    text(toaB(end),1,['rms= ',num2str(rms(ferr),'%3.1f')])
    ylim([-2 2])
    ylabel(['FOA err(Hz) ',num2str(i)])
    yyaxis right
    plot(t1,fdu1,'LineStyle','--','Color','black','Marker','none')
    plot(t1,fdd1,'LineStyle','-','Color','black','Marker','none')
    ylim([-3e3 3e3])
    ylabel('Doppler(Hz)','Color','black')   
    ax.YColor = 'black';
    xlim([toaB(1),toaB(end)])
end

for i=1:7
    sel=antB==i;
    t1=toaB(sel);
    h(i+4)=figure;
    if isempty(t1)
        plot([toaB(1),toaB(end)],[NaN NaN])
        continue;
    end
    s1=SIDb(sel);
    cnr1=CNRb(sel);
    elu1=elu(sel);
    eld1=eld(sel);
    nadu1=nadu(sel);
    nadd1=nadd(sel);
    ru1=ru(sel);
    rd1=rd(sel);
    
    inds=s1(1:end-1) ~= s1(2:end);
    en=[find(inds),length(t1)];
    st=[1,en(1:end-1)+1];
    noofSegs1=length(en);    
    
    for j=1:noofSegs1        
        sel1=st(j):en(j);
        satid=s1(st(j));
        pltcolor=clrs(satid,:);
        subplot(5,1,1)
        title(['chanel ',num2str(i)]) 
        hold on
        stem(t1(sel1),cnr1(sel1),'Marker','.','Color',pltcolor)
        text(t1(sel1(1)),50+10*mod(j,2),getSatName(satid,prns))
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
h1=figure('Name','TDOA error -various pairs');
h2=figure('Name','FDOA error -various pairs');title('FDOA error -various pairs')
h(12)=h1;
h(13)=h2;
m=0;
for i=1:7
    for j=i+1:7
        [tderr,fderr,t]=findTDOA(ttB,ftB,chns,i,j);
        if k==4
            k=1;
            h1=figure('Name','TDOA error -various pairs');
            h2=figure('Name','FDOA error -various pairs');
            h(14+m)=h1;
            h(15+m)=h2;
            m=m+2;
        end
        figure(h1);
        subplot(3,1,k)
        stem(t,tderr,'Marker','.')
        text(toaB(end),30,['rms= ',num2str(rms(tderr))])
        xlim([toaB(1),toaB(end)]);
        ylim([-50 50])
        ylabel(['TDOA-',num2str(i),num2str(j)])
        figure(h2);
        subplot(3,1,k)
        stem(t,fderr,'Marker','.')
        text(toaB(end),1,['rms= ',num2str(rms(fderr))])
        xlim([toaB(1),toaB(end)]);
        ylim([-1.5 1.5])
        ylabel(['FDOA-',num2str(i),num2str(j)])
        k=k+1;
    end
end   

end

function satname = getSatName(sid,list)
satname='';
d=find(list==sid);
if sid>500
    satname = ['COSMOS 25',num2str(d,'%02d')];
elseif sid>400
    satname = ['GSAT0',num2str(d)];
end
end

