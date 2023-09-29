function analyzeBdata(ID,pos,refFreq,BRT,bID,foa,toa,CNR,antNo,SIDa,pXYZ,vXYZ)
% close all

load('clrs.mat','clrs')

lat0 = 13.036;
lon0= 77.5124;
h0 = 930;
LUTxyz=lla2ecef([lat0,lon0,h0])'*1e-3;

refLoc=lla2ecef(pos)'*1e-3;

idmatch = strcmp(bID,ID);
toaB=toa(idmatch);
foaB=foa(idmatch);
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
    ylabel(['FOA error(Hz) ch',num2str(i)])
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
        title(['chanel ',num2str(i)]) 
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
h1=figure('Name','TDOA error -various pairs');
h2=figure('Name','FDOA error -various pairs');title('FDOA error -various pairs')
for i=1:7
    for j=i+1:7
        [tderr,fderr,t]=findTDOA(ttB,ftB,chns,i,j);
        if k==8
            k=1;
            h1=figure('Name','TDOA error -various pairs');
            h2=figure('Name','FDOA error -various pairs');
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


end

