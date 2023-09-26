function [chns1,t] = findGroupsInBdata(toaB,antB,BRT)
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
mfnd=max(chns,[],2);
compactor=(mfnd>0);
chns1=chns(compactor,:);
t=toaB(compactor);
end

