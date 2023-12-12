function [anomalyRate,idlist,counts,anomalousIndices] = detectAnomaly(bID,foa,ID,freq)
load('bdatabase.mat','BeaconID')
msgind=abs(foa-freq)<2e3;
ids=bID(msgind);
idlist=categories(categorical(ids));
noOfIds=length(idlist);
counts=zeros(1,noOfIds);
for i=1:noOfIds
    id=idlist{i};
    inds=strcmp(ids,id);
    counts(i)=sum(inds);
end

anomalousIndices = ones(1,length(idlist),'logical');
for i=1:size(BeaconID,1)
    id1=BeaconID(i,:);
    idx1=find(strcmp(idlist,id1),1);
    if idx1>0
        anomalousIndices(idx1)=false;
    end
end
totalDetection = length(ids);
idx0=find(strcmp(idlist,ID),1);
anomalousIndices(idx0)=false;
noOfAnomaly = totalDetection - sum(counts(~anomalousIndices));
anomalyRate = noOfAnomaly/totalDetection;
end