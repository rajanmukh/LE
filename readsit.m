tic
%% Import data from text file.
coldate=[7,7,23];
dec1 = comm.BCHDecoder(82,61);
warning('off','MATLAB:datetime:FormatConflict_Dy')
%% Initialize variables.
filename = ['Log\','sit_',num2str(coldate(3)),'_',num2str(coldate(2),'%02d'),'_',num2str(coldate(1),'%02d'),'.txt'];
% ID='3476759F3F81FE0';
% bloc=[13.036,77.5124];
ID='3ADE22223F81FE0';
bloc=[24.431,54.448];
fileID=fopen(filename);
dataarr=textscan(fileID,'%s%[^\n\r]','Delimiter','');
lines=dataarr{1};
clear dataarr
n1=0;
n2=0;
i=1;
while i<=length(lines)
    if startsWith(lines{i},'/145/')  
        n1=n1+1;
        i=i+9;
    elseif startsWith(lines{i},'/142/')
        n2=n2+1;
        i=i+8;
    else
        i=i+1;
    end
end
n=n1+n2;
id=cell(1,n);
noB=zeros(1,n);
avtoa1=repmat(datetime,1,n);
avtoa2=repmat(datetime,1,n);
noChns=zeros(1,n);
lat=zeros(1,n);
lon=zeros(1,n);
EHE=zeros(1,n);
i=1;
j=1;
while i<=length(lines)
    if startsWith(lines{i},'/145/')
        line3 = split(lines{i+1},'/');
        avtoa1(j) = datetime(line3{4},'InputFormat','yy DDD HHmm ss.SS');
        line4=split(lines{i+2},'/');
        avtoa2(j) = datetime(line4{2},'InputFormat','yy DDD HHmm ss.SS');
        noB(j) = str2double(line4{3});
        id{j}=decodeMsg(line4{4},dec1)'; 
        line5 = split(lines{i+3},'/');
        lat(j) = str2double(line5{3});
        lon(j) = str2double(line5{4});
        EHE(j) = str2double(line5{6});
        line6 = split(lines{i+4},'/');
        noChns(j)=str2double(line6{4});

        i=i+9;
        j=j+1;
    elseif startsWith(lines{i},"/142/")
        ine3 = split(lines{i+1},'/');
        avtoa1(j) = datetime(line3{4},'InputFormat','yy DDD HHmm ss.SS');
        line4=split(lines{i+2},'/');
        avtoa2(j) = datetime(line4{2},'InputFormat','yy DDD HHmm ss.SS');
        noB(j) = 1;
        id{j}=decodeMsg(line4{4},dec1)'; 
        line5 = split(lines{i+3},'/');
        noChns(j)=str2double(line5{4});
        i=i+8;
        j=j+1;
    else
        i=i+1;
    end
end
idmatch=strcmp(id,ID);
d=zeros(1,n);
d(idmatch) = distance(lat(idmatch),lon(idmatch),bloc(1),bloc(2),referenceEllipsoid("wgs84"))*1e-3;
toc
sel=zeros(7,n,'logical');

singleBurst = (noB == 1);

for i=1:7
    sel(i,:) = idmatch & singleBurst & (noChns==i);
end
% stem(avtoa1(sel),noChns(sel))
hold on
for i=2:7
    %stem(avtoa1(sel(i,:)),d(sel(i,:)))
    scatter(lat(sel(i,:)),lon(sel(i,:)))
end
legend({'2','3','4','5','6','7'})
