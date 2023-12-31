clear
coldate=[1,10,23];
filename = ['commissioning\Bdata\Log\','sit_',num2str(coldate(3)),'_',num2str(coldate(2),'%02d'),'_',num2str(coldate(1),'%02d'),'.txt'];

fbias=-13;



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
% save('data.mat','msg','bID','foa','foff','toa','toff','CNR','antNo','SIDa','pXYZ','vXYZ','err1','err2')

ID='347C000000FFBFF';%india
pos=[13.036,77.5124,930];BRT=50;
refFreq = 406.028000e6;
% ID = '3ADEA2223F81FE0';%uae
% pos=[24.431,54.448,5];BRT=50;
% refFreq = 406.043000e6;
ID = '467C000002FFBFF';%Singapore
pos=[1.3771,103.9881,10];BRT=50;
refFreq = 406.064000e6;
[anomalyRate,IDs,counts,indices] = detectAnomaly(bID,foa,ID,refFreq);
close all
figure
plot(toa,foa,'Marker','.','LineStyle','none','Color','r')
ylim([406e6 406.1e6])
idmatched=strcmp(bID,ID);
hold on
plot(toa(idmatched),foa(idmatched),'Marker','.','LineStyle','none','Color','b')
plot([toa(1) toa(end)],refFreq-2e3*[1 1],'g')
plot([toa(1) toa(end)],refFreq+2e3*[1 1],'g')
ylabel('FOA(Hz)')
legend({'unknown IDs','own or known IDs'})
figure
stem(counts,'r')
hold on
stem(find(~indices),counts(~indices),'b')
xlabel('index of different beacons within +/- 2kHz band')
ylabel('counts')
legend({'unknown IDs','own or known IDs'})
% ID = '9C6000000000001';%T-cal
% pos=[43.5605,1.4808,214.27];BRT=30;
% refFreq = 406.022000e6;
% ids=hexToBinaryVector(bID);
% id=hexToBinaryVector(ID,60);
% nms=sum(xor(ids,id),2);
% close all
% H=analyzeBdata(ID,pos,refFreq,BRT,bID,foa,foff,toa,CNR,antNo,SIDa,pXYZ,vXYZ);







