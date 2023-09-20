function [loc,err,sInfo] = computeMultiBurstSolution(locs,errs,CNRs,sInfos)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

noB=length(locs);
lats=zeros(1,noB);
lons=zeros(1,noB);
alts=zeros(1,noB);
EHEs=zeros(1,noB);
elParams=zeros(noB,3);
cnrs=zeros(1,noB);
fts=zeros(1,noB);
jdops=zeros(1,noB);
for i=1:noB
    loc1=locs{i};
    lats(i)=loc1.lat;
    lons(i)=loc1.lon;
    alts(i)=loc1.alt;
    err1=errs{i};
    EHEs(i)=err1.EHE;
    elParam1=err1.ellipse;
    elParams(i,:)=elParam1;
    cnrs(i)=CNRs(i);
    fts(i)=sInfos{i}.ft;
    jdops(i)=sInfos{i}.jdop;
end
wts = 10.^(cnrs/20);
nf=1/sum(wts);
loc.lat = nf*sum(lats.*wts);
loc.lon = nf*sum(lons.*wts);
loc.alt = nf*sum(alts.*wts);
err.EHE = sqrt(sum((EHEs.*wts).^2)/sum(wts)^2);
sInfo.ft = nf*sum(fts.*wts);
sInfo.jdop = sqrt(sum((jdops.*wts).^2)/sum(wts)^2);
err.ellipse=zeros(1,3);
err.ellipse(1:2)=sqrt(sum((elParams(:,1:2).*wts').^2)./sum(wts)^2);
for i=1:noB
    if elParams(i,3)>270
        elParams(i,3)=elParams(i,3)-360;
    end
end
err.ellipse(3) = nf*sum(elParams(:,3).*wts');
if err.ellipse(3)<0
    err.ellipse(3) = err.ellipse(3)+360;
end
sInfo.solMethodology = 'P3D-Average';

end