%% Import data from text file.

% clear
close all
%%
colDate=[11,8,2023];
% bID='3476759F3F81FE0';%India
% refLoc=[13.036,77.511, 1e3];BRT=50;

% bID='9C6000000000001';%France
% refLoc=[43.5605,1.4808];BRT=30;

% bID ='9C62BE29630F1C0';%Reunion QMS
% refLoc=[-20.9088888,55.51361,95];BRT=50;

% bID='9C7FEC2AACD3590';%always on  Kerguelen
% refLoc=[-49.3515,70.256,80];BRT=30;

% bID='9C62BE29630F1D0';%France
% refLoc=[43.5605,1.4808];

% bID='CF62BE29630F0C0';%not always on Kerguelen
% refLoc=[-49.3515,70.256,80];BRT=150;

% bID = '9C62EE2962AC3C0';%Reunion-Cal-1
% refLoc=[-20.9088888,55.513616,95];BRT=150;

% bID = '9C62EE2962AF260';%Reunion-Cal-2
% refLoc=[-20.9088888,55.513616,95];BRT=150;

% bID = '3ADE22223F81FE0';%uae
% refLoc=[24.431,54.448,5];BRT=50;

% bID = '467C000002FFBFF';%singapore
% refLoc=[1.3771,103.9881,10];BRT=50;

% bID = '2DC843E88EFFBFF';
% refLoc=[15.6481,32.5769]; BRT=50;

%refXYZ=lla2ecef(refLoc);
%% Initialize variables.
% path='C:\Users\Istrac\Documents\endurance_test\';
path='';
datestr=strcat(num2str(colDate(3)),'_',num2str(colDate(2),"%02u"),'_',num2str(colDate(1),"%02u"));
filename = strcat(path,'beacondata_DRX_',datestr,'.txt');
delimiter = ',';
% 
% outfolder=strcat(path,'beacondata_DRX_',num2str(colDate(3)),'_',num2str(colDate(2),"%02u"),'_',num2str(colDate(1),"%02u"),'\',bID,'\');
% mkdir(outfolder);
infilename=strcat('gnss_',datestr,'.txt');
infile = fopen(infilename, 'r');
x=0;
while true
    x=x+1;
    if length(fgets(infile))<2
        break;
    end
end
global list;
fclose(infile);
list=cell(1,x);
infile = fopen(infilename, 'r');
for i=1:x
    list{i}=fgets(infile);
end
fclose(infile);
%% Format for each line of text:
%   column1: categorical (%C)
%	column2: double (%f)
%   column3: categorical (%C)
%	column4: categorical (%C)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: categorical (%C)
%   column9: categorical (%C)
%	column10: double (%f)
%   column11: double (%f)
%	column12: text (%s)
%   column13: categorical (%C)
%	column14: categorical (%C)
%   column15: double (%f)
%	column16: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%C%f%C%s%f%f%f%C%C%f%f%s%C%C%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
chns=dataArray{2};
satnames=dataArray{4};
pdf1s=dataArray{6};
pdf2s=dataArray{7};
datas=dataArray{9};
CNRs=dataArray{10};
FOAs=dataArray{11};
TOAs=dataArray{12};
countrys=dataArray{13};
IDs=dataArray{14};
lats=dataArray{15};
lons=dataArray{16};
S=dataArray{17};
azs=dataArray{18};
els=dataArray{19};
arr = 1:length(IDs)-1;
boarders = IDs(1:end-1) ~= IDs(2:end);
st=[1,arr(boarders)+1];
en=[arr(boarders),length(IDs)];
%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;
%%
tic

for i=1:length(st)
    ID = IDs(st(i));
    noOfSats = en(i) - st(i)+1;
    tgroups = cell(7,1);
    fgroups = zeros(7,1);
    CNRgroups = zeros(7,1);
    satgroups = cell(7,1);
    chn = chns(st(i):en(i));
    nos=0;
    for j=1:noOfSats
        sname = char(satnames(st(i)+j-1));
        if ~strcmp(sname,'DEFAULT')
            ind=chn(j);
            tgroups{ind} = TOAs(st(i)+j-1);
            fgroups(ind) = FOAs(st(i)+j-1);
            CNRgroups(ind) = CNRs(st(i)+j-1);
            satgroups{ind} = sname; 
            nos=nos+1;
        end
    end
    
    if  nos>=3 
        i
        [lat,lon,ht,ehe]=tdoa3(tgroups, fgroups, CNRgroups, satgroups);       
    end    
end
toc
LErate_s=sum(~isnan(lat))/length(det);
NoOfInvalidLocs=sum(det>=3)-sum(~isnan(lat));
h7=figure;
edges=0:0.2:20;
derr=edges(1:end-1)+0.1;
h=histogram(disterror(~isnan(disterror)),[edges Inf],'Normalization','cdf');
pvals=h.Values;
dd=100*h.Values;
plot(derr,dd(1:end-1))
hold on
plot(derr,90*ones(size(derr)))
ylim([0 100])
xlim([0 20]);
grid on
text(20,dd(end-1),num2str(dd(end-1)))
xlabel('error(km)')
ylabel('cumulative percentage')
title(strcat('single burst location accuracy (',num2str(sum(~isnan(lat))),' locations)'))
for kk=1:length(pvals)-1
    if pvals(kk)>0.90
        break;
    end    
end
if pvals(kk)>0.90
    %interpolate between kk and kk-1
    val=edges(kk-1)+(0.9-pvals(kk-1))*((edges(kk)-edges(kk-1))/(pvals(kk)-pvals(kk-1)));
    rad90=num2str(val,'%2.1f');
else
    rad90='>20';
end
lat1=zeros(1,length(det)-12);
lon1=zeros(size(lat1));
disterror1=NaN(size(lat1));
noOfwnd=floor(length(det)/12);
cnt=0;
for i=1:12:noOfwnd*12
    arr=i:i+11;
    arr1=arr(~isnan(lat(arr)));
    if ~isempty(arr1)
        cnt=cnt+1;
    end
end
LErate_s1=cnt/noOfwnd;
for i=1:length(det)-12
    noOfsimdet=det(i);
    if noOfsimdet >=4
        arr=i:i+11;
        arr1=arr(~isnan(lat(arr)));
        latcut=lat(arr1);
        loncut=lon(arr1);
        lat1(i)=median(latcut);
        lon1(i)=median(loncut);
        disterror1(i) = distance(lat1(i),lon1(i),refLoc(1),refLoc(2),referenceEllipsoid('WGS84'))*1e-3;
    else
        lat1(i)=NaN;
        lon1(i)=NaN;
    end
end

h8=figure;
h=histogram(disterror1(~isnan(disterror1)),[edges Inf],'Normalization','cdf');
pvals=h.Values;
dd=100*h.Values;
plot(derr,dd(1:end-1))
hold on
plot(derr,95*ones(size(derr)))
plot(derr,98*ones(size(derr)))
ylim([0 100])
xlim([0 20]);
grid on
text(20,dd(end-1),num2str(dd(end-1)))
xlabel('error(km)')
ylabel('cumulative percentage')
title(strcat('Multi burst location accuracy (10 min window)'))
for kk=1:length(pvals)-1
    if pvals(kk)>0.95
        break;
    end    
end
if pvals(kk)>0.95
    %interpolate between kk and kk-1
    val=edges(kk-1)+(0.95-pvals(kk-1))*((edges(kk)-edges(kk-1))/(pvals(kk)-pvals(kk-1)));
    rad95=num2str(val,'%2.1f');
else
    rad95='>20';
end
for kk=1:length(pvals)-1
    if pvals(kk)>0.98
        break;
    end    
end
if pvals(kk)>0.98
    %interpolate between kk and kk-1
    val=edges(kk-1)+(0.98-pvals(kk-1))*((edges(kk)-edges(kk-1))/(pvals(kk)-pvals(kk-1)));
    rad98=num2str(val,'%2.1f');
else
    rad98='>20';
end
%%
% scatter plots
h9=figure;
scatter(lat,lon,5)
xlabel('latitiude')
ylabel('longitude')
hold on
scatter(refLoc(1),refLoc(2),'*')
axis equal
%draw contours
xscale=pi*6400*cos(refLoc(1)*pi/180)/180;
yscale=pi*6400/180;

r=5;
x=zeros(1,360/5+1);
y=zeros(1,360/5+1);
for a=0:5:360
    xcomp=r*cos(a*pi/180);
    ycomp=r*sin(a*pi/180);
    latd=xcomp/xscale;
    lond=ycomp/yscale;
    x(a/5+1)=refLoc(1)+latd;
    y(a/5+1)=refLoc(2)+lond;
end
p5=plot(x,y);
x5=x;
y5=y;
r=10;
x=zeros(1,360/5+1);
y=zeros(1,360/5+1);
for a=0:5:360
    xcomp=r*cos(a*pi/180);
    ycomp=r*sin(a*pi/180);
    latd=xcomp/xscale;
    lond=ycomp/yscale;
    x(a/5+1)=refLoc(1)+latd;
    y(a/5+1)=refLoc(2)+lond;
end
p10=plot(x,y);
x10=x;
y10=y;

r=20;
x=zeros(1,360/5+1);
y=zeros(1,360/5+1);
for a=0:5:360
    xcomp=r*cos(a*pi/180);
    ycomp=r*sin(a*pi/180);
    latd=xcomp/xscale;
    lond=ycomp/yscale;
    x(a/5+1)=refLoc(1)+latd;
    y(a/5+1)=refLoc(2)+lond;
end
p20=plot(x,y);
x20=x;
y20=y;
legend([p5 p10 p20],{'5 km','10 km','20 km'})

h11=figure;
scatter(lat1,lon1,5)
xlabel('latitiude')
ylabel('longitude')
hold on
scatter(refLoc(1),refLoc(2),'*')
axis equal
p5=plot(x5,y5);
p10=plot(x10,y10);
p20=plot(x20,y20);
legend([p5 p10 p20],{'5 km','10 km','20 km'})

%%
h12=figure;
edges=0:0.05:3;
derr=edges(1:end-1)+0.05;
ndisterror=disterror./ehe;
h=histogram(ndisterror(~isnan(ndisterror)),[edges Inf],'Normalization','cdf');
pvals=h.Values;
dd=100*h.Values;
plot(derr,dd(1:end-1))
hold on
plot(derr,15*ones(size(derr)))
plot(derr,93*ones(size(derr)))
plot(derr,97*ones(size(derr)))
plot(derr,99*ones(size(derr)))
plot([0.1 0.1],[0 100])
plot([1 1],[0 100])
plot([2 2],[0 100])
ylim([0 100])
xlim([0 3]);
grid on
text(3,dd(end-1),num2str(dd(end-1)))
xlabel('actual error normalized by predicted error')
ylabel('cumulative percentage')
title(strcat('error prediction accuracy (',num2str(sum(~isnan(lat))),' locations)'))

indx=round((0.1)/0.05);
if indx<=length(pvals)
    acc10=num2str(pvals(indx),'%1.2f');
else
    acc10='1';
end
indx=round(1/0.05);
if indx<=length(pvals)
    acc100=num2str(pvals(indx),'%1.2f');
else
    acc100='1';
end
indx=round(2/0.05);
if indx<=length(pvals)
    acc200=num2str(1-pvals(indx),'%1.2f');
else
    acc200='0';
end
%%
str='UAE\';
saveas(h1,strcat(str,'det.png'),'png') 
saveas(h2,strcat(str,'1burst_acc.png'),'png') 
saveas(h3,strcat(str,'10min_acc_median.png'),'png') 
% offdist=distance(lat,lon,43.5605,1.4808,referenceEllipsoid('WGS84'))/1e3
% actualxyz=lla2ecef([8.52,76.89,0]);
% dr=sqrt(sum((xyz-repmat(actualxyz,4,1)).^2,2));
% extoa=tau+dr/3e8;
% et=extoa-t;
% et=1e6*(et-mean(et));


    
    