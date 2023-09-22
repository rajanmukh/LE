%% Import data from text file.
coldate=[7,7,23];

%% Initialize variables.
filename = ['sit_',num2str(coldate(3)),'_',num2str(coldate(2),'%02d'),'_',num2str(coldate(1),'%02d'),'.txt'];
id='347C000000FFBFF';
bloc=[13.0342,77.5124];
% bdata=extractBetween("FFFE2FCE3000000000000DBD0Exxxxxxxxxx",7,26);
% bloc=[43.5605,1.4808];
% bdata=extractBetween("FFFE2F4E3FF6155669AC86E79580",7,26);
% bloc=[-49.3515,70.256];
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

while i<=length(lines)
    if startsWith(lines(i),"/145/")
        temp1=split(lines(i+2),'/');
        d20=extractBetween(temp1(4),7,26);
        if strcmp(d20,bdata)
            %read toa
            readtoa=temp1(2);
            yy=str2double(extractBefore(readtoa,3));
            ddd=str2double(extractBetween(readtoa,4,7));
            hh=str2double(extractBetween(readtoa,8,9));
            mm=str2double(extractBetween(readtoa,10,11));
            ss=str2double(extractAfter(readtoa,12));
            TOA_LE(j)=[ddd hh mm ss]*mult;
            %read location
            temp2=split(lines(i+3),'/');
            lat(j)=str2double(temp2(3));
            lon(j)=str2double(temp2(4));
            offdist(j)=distance(lat(j),lon(j),bloc(1),bloc(2),referenceEllipsoid('WGS84'))/1e3;
            j=j+1;
            %
            
        end
        i=i+9;
    elseif startsWith(lines(i),"/142/")
        i=i+8;
    else
        i=i+1;
    end
end
TOA_LE(j:end)=[];
lat(j:end)=[];
lon(j:end)=[];
offdist(j:end)=[];
% offdist=distance(lat,lon,13.0342,77.5124,referenceEllipsoid('WGS84'))/1e3

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

