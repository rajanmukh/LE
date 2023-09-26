close all
coldate=[7,7,23];
filename = ['commissioning\Bdata\Log\','sit_',num2str(coldate(3)),'_',num2str(coldate(2),'%02d'),'_',num2str(coldate(1),'%02d'),'.txt'];
lat0 = 13.036;
lon0= 77.5124;
h0 = 930;
wgs84 = wgs84Ellipsoid('kilometers');
LUTxyz=lla2ecef([lat0,lon0,h0])'*1e-3;

fbias=-13.5;



fileID=fopen(filename);
dataarr=textscan(fileID,'%s%[^\n\r]','Delimiter','');
lines=dataarr{1};
clear dataarr



noOfLines = length(lines);

bID = cell(1,noOfLines);
msg = cell(1,noOfLines);
foa = zeros(1,noOfLines);
foff = zeros(1,noOfLines);
toa= repmat(datetime,1,noOfLines);
toff = zeros(1,noOfLines);
CNR = zeros(1,noOfLines);
antNo=zeros(1,noOfLines);
SIDa = zeros(1,noOfLines);
pXYZ= zeros(3,noOfLines);
vXYZ = zeros(3,noOfLines);
err1 = zeros(1,noOfLines);
err2 = zeros(1,noOfLines);
fd = zeros(1,noOfLines);
ferror = zeros(1,noOfLines);

for i=1:noOfLines
    fields = split(lines{i},',');
    msg{i}=fields{2};
    bID{i}=fields{3};
    foa(i) = str2double(fields{5})-fbias;
    foff(i) = str2double(fields{6});
    toa(i) = datetime(fields{7},'InputFormat','yyyy-MM-dd HH:mm:ss.SSSSSSSSS');
    toff(i) = str2double(fields{8});
    CNR(i) = str2double(fields{9});
    antNo(i) = str2double(fields{11})-419500;
    SIDa(i) = str2double(fields{12});
    pXYZ(:,i) = str2double(fields(13:15));
    vXYZ(:,i) = str2double(fields(16:18));
    err1(i) = str2double(fields{19});
    err2(2) = str2double(fields{20});
end

%asigning colors to sat
sats=unique(SIDa);
clrs=zeros(510,3);
for i=1:length(sats)
    clrs(sats(i),:)=rand(1,3);
end

% ID='3476759F3F81FE0';%india
% pos=[13.036,77.5124,930];
% refFreq = 406.028000e6;
% ID = '3ADE22223F81FE0';%uae
% pos=[24.431,54.448,5];BRT=50;
% refFreq = 406.043000e6;
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


uSID = unique(SIDb);
a=zeros(1,length(uSID));
for i = 1:length(uSID)
    a(i)=sum(SIDb==uSID(i));
end
% 
% s=zeros(1,length(uSID));
% m=zeros(1,length(uSID));
% hold on
% for i=1:7
%     sel = SIDb==uSID(i);
%     ferr=ftB(sel)-refFreq;
%     stem(toaB(sel),ferr)
%     s(i)=std(ferr);
%     m(i)=mean(ferr);
% end

%determine the groups

noofPackets=length(toaB);
chns=zeros(noofPackets,7);
j=1;
for i=2:noofPackets
    delt=abs(seconds(toaB(i)-toaB(i-1)));
    if delt>1
        j=j+round(delt/BRT);
    end
    chns(j,antB(i))=i;
end
noOfBursts =j;
chns(noOfBursts+1:end,:)=[];

i=2;
j=3;

rcvd=chns(:,i)~=0;
sel11=chns(rcvd,i);
t1=toaB(sel11);
f1=ftB(sel11);
s1=SIDb(sel11);
cnr1=CNRb(sel11);
elu1=elu(sel11);
eld1=eld(sel11);
nadu1=nadu(sel11);
nadd1=nadd(sel11);
ru1=ru(sel11);
rd1=rd(sel11);

rcvd=chns(:,j)~=0;
sel22=chns(rcvd,j);
t2=toaB(sel22);
f2=ftB(sel22);
s2=SIDb(sel22);
cnr2=CNRb(sel22);
elu2=elu(sel22);
eld2=eld(sel22);
nadu2=nadu(sel22);
nadd2=nadd(sel22);
ru2=ru(sel22);
rd2=rd(sel22);

if t1(1)>t2(1)
    x1=t2(1);
else
    x1=t1(1);
end

if t1(end)>t2(end)
    x2=t1(end);
else
    x2=t2(end);
end

pair12=chns(:,i) & chns(:,j);
sel1=chns(pair12,i);
sel2=chns(pair12,j);
ferr12=ftB(sel1)-ftB(sel2);
terr12=1e6*seconds(ttB(sel1)-ttB(sel2));

figure
subplot(4,1,1)
stem(toaB(sel1),terr12)
xlim([x1,x2])
ylabel('TDOA error(us)')

subplot(4,1,2)
stem(toaB(sel1),ferr12)
xlim([x1,x2])
ylabel('FDOA error(Hz)')

subplot(4,1,3)
s11=unique(s1);
noofSegs1=length(s11);
hold on
for i=1:noofSegs1
sel=s1==s11(i);
stem(t1(sel),f1(sel)-refFreq,'Color',clrs(s11(i),:))
end
xlim([x1,x2])
ylabel('FOA error(Hz)')

subplot(4,1,4)
s22=unique(s2);
noofSegs2=length(s22);
hold on
for i=1:noofSegs2
sel=s2==s22(i);
stem(t2(sel),f2(sel)-refFreq,'Color',clrs(s22(i),:))
end
xlim([x1,x2])
ylabel('FOA error(Hz)')

figure
subplot(3,1,1)
hold on
for i=1:noofSegs1
sel=s1==s11(i);
plot(t1(sel),cnr1(sel),'Marker','o','Color',clrs(s11(i),:))
end
xlim([x1,x2])

subplot(3,1,2)
hold on
plot(t1,elu1,'--r');
plot(t1,eld1,'-r');
yyaxis right
hold on
plot(t1,nadu1,'--b');
plot(t1,nadd1,'-b');
xlim([x1,x2])

subplot(3,1,3)
hold on
plot(t1,ru1,'--b');
plot(t1,rd1,'-r');
xlim([x1,x2])

figure
subplot(3,1,1)
hold on
for i=1:noofSegs2
sel=s2==s22(i);
plot(t2(sel),cnr2(sel),'Marker','o','Color',clrs(s22(i),:))
end
xlim([x1,x2])

subplot(3,1,2)
hold on
plot(t2,elu2,'--r');
plot(t2,eld2,'-r');
yyaxis right
hold on
plot(t2,nadu2,'--b');
plot(t2,nadd2,'-b');
xlim([x1,x2])

subplot(3,1,3)
hold on
plot(t2,ru2,'--b');
plot(t2,rd2,'-r');
xlim([x1,x2])














