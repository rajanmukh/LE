function readrinex(filename)
%READRINEX Summary of this function goes here
%   Detailed explanation goes here
global ephdata;
global eph_GLO;
ephdata=cell(1,36);
eph_GLO=cell(1,25);
info = rinexread(filename);
data=info.Galileo;
for i=1:36
    idx1=data.SatelliteID==i;
    data1=data(idx1,:);
    len=size(data1,1);
    if len>0
        idx2=data1.Time(1:end-1)~=data1.Time(2:end);        
        ephdata{i}=data1(idx2,:);
    end
end
fide = fopen(filename);
NAVDATA = textscan(fide,'%s','Delimiter','\n');   NAVDATA = NAVDATA{1};
fclose(fide);
% choose read-in function depending on RINEX version
rversion = str2double(NAVDATA{1}(1));
[~,~,~,~,data,~,~]=read_nav_multi(NAVDATA,18);
for i=1:36
    idx1=data(1,:)==i;
    data1=data(:,idx1);        
    eph_GLO{i}=data1;
end
end

