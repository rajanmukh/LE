coldate=[23,9,23];
filename = ['commissioning\Sdata\Log\','sit_',num2str(coldate(3)),'_',num2str(coldate(2),'%02d'),'_',num2str(coldate(1),'%02d'),'.txt'];
fileID=fopen(filename);
dataarr=textscan(fileID,'%s%[^\n\r]','Delimiter','');
lines=dataarr{1};
clear dataarr
noOfLines = length(lines);
avtoa1=repmat(datetime,1,noOfLines);
avtoa2=repmat(datetime,1,noOfLines);
bID = cell(1,noOfLines);
ft = zeros(1,noOfLines);
noB = zeros(1,noOfLines);
noP = zeros(1,noOfLines);
noS = zeros(1,noOfLines);
JDOP = zeros(1,noOfLines);
EHE = zeros(1,noOfLines);
solMethod = zeros(1,noOfLines);
lat = zeros(1,noOfLines);
lon = zeros(1,noOfLines);
alt = zeros(1,noOfLines);
locerr = zeros(1,noOfLines);
for i=1:noOfLines
    fields = split(lines{i},',');
    avtoa1(i)=datetime(['20',fields{3}],'InputFormat','uuuu DDD HHmm ss.SS');
    avtoa2(i)=datetime(['20',fields{4}],'InputFormat','uuuu DDD HHmm ss.SS');
    bID{i} = fields{6};
    ft(i) = str2double(fields{7});
    noB(i) = str2double(fields{9});
    noP(i) = str2double(fields{12});
    noS(i) = str2double(fields{13});
    JDOP(i) = str2double(fields{15});
    EHE(i) = str2double(fields{16});
    if contains(fields{17},'Average')
        solMethod(i) = 1;
    else
        solMethod(i) = 2;
    end
    lat(i) = str2double(fields{18});
    lon(i) = str2double(fields{19});
    alt(i) = str2double(fields{20});
    locerr(i) = str2double(fields{21});
end
close all
ID = '347C000000FFBFF'; BRT = 50;refLoc=[13.036,77.511];%india
% ID = '3ADEA2223F81FE0';BRT = 50;%uae
% ID = '467C000002FFBFF'; BRT = 50;%singapore
[PrLoc,accPerc,predAcc,H]=solStat(ID,bID,noP,noB,lat,lon,locerr,EHE,solMethod,avtoa1,avtoa2,BRT,refLoc);

