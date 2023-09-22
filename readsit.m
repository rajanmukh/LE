%% Import data from text file.
coldate=[7,7,23];
dec1 = comm.BCHDecoder(82,61);
%% Initialize variables.
filename = ['sit_',num2str(coldate(3)),'_',num2str(coldate(2),'%02d'),'_',num2str(coldate(1),'%02d'),'.txt'];
ID='3476759F3F81FE0';
bloc=[13.0342,77.5124];
delimiter = {''};

%% Format for each line of text:
%   column1: categorical (%C)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%[^\n\r]';

%% Open the text file.
fileID = fopen(['Log\',filename],'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
%% Close the text file.
fclose(fileID);

lines=dataArray{1};
clearvars filename delimiter formatSpec fileID dataArray ans;
i=1;
j=1;
mult=[86400 3600 60 1]';
TOA_LE=zeros(1,10000);
lat=zeros(1,10000);
lon=zeros(1,10000);
offdist=zeros(1,10000);
n1=0;
n2=0;

while i<=length(lines)
    if startsWith(lines(i),"/145/")
%         line4=split(lines(i+2),'/');
%         noB = str2double(line4(3));
%         id=decodeMsg(char(line4(4)),dec1);   
        n1=n1+1;
        i=i+9;
    elseif startsWith(lines(i),"/142/")
        n2=n2+1;
        i=i+8;
    else
        i=i+1;
    end
end
n=n1+n2;
id=char(zeros(15,n));
noB=zeros(1,n);
avtoa1=repmat(datetime,n);
avtoa2=repmat(datetime,n);
noChns=zeros(1,n);

i=1;
j=1;
while i<=length(lines)
    if startsWith(lines(i),"/145/")
        line4=split(lines(i+2),'/');
        noB(j) = str2double(line4(3));
        id(:,j)=decodeMsg(char(line4(4)),dec1)';  
        line6 = split(lines(i+4),'/');
        noChns(j)=str2double(line6(4));
        i=i+9;
        j=j+1;
    elseif startsWith(lines(i),"/142/")
        line4=split(lines(i+2),'/');
        noB(j) = 1;
        id(:,j)=decodeMsg(char(line4(4)),dec1)'; 
        line5 = split(lines(i+3),'/');
        noChns(j)=str2double(line5(4));
        i=i+8;
        j=j+1;
    else
        i=i+1;
    end
end

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.
edges=0:1:20;
% edges=0:1:20;
close all
figure
h1=histogram(offdist(offdist<=20),edges,'Normalization','pdf');
plot(h1.Values,'d-')
figure
h2=histogram(offdist(offdist<=20),edges,'Normalization','cdf');
plot(h2.Values,'d-')
% heatscatter(lat(offdist<20)', lon(offdist<20)', 'D:\mat_work\mat_work\meolut_array', 'dd.png')

twindows=TOA_LE(1):1200:TOA_LE(end);
inds=zeros(1,length(twindows));
j=1;
for i=1:length(TOA_LE)
    if TOA_LE(i)>=twindows(j)
        inds(j)=i;
        j=j+1;
    end
end

for i=1:length(twindows)-1
    lat20avg=mean(lat(inds(i):inds(i+1)-1));
    lon20avg=mean(lon(inds(i):inds(i+1)-1));
    
end


