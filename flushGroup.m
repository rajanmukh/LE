function [msgno,msgnoS] = flushGroup(currTime,msgno1,wrt,msgnoS1,wrtS)
%SENDMULTIBURST Summary of this function goes here
%   Detailed explanation goes here
global groupTOA;
global bWrt;
global groupbuffer;
global idlist;
global msglist;
msgno=msgno1;
msgnoS=msgnoS1;
for i=1:100
    noB=bWrt(i);

    lagSeconds=seconds(currTime - groupTOA(i));
    if lagSeconds > 560
        if noB > 1
            %count the total no of packet in all the burst having
            %individual location solution
            noPs=zeros(1,noB);
            validInd=zeros(1,noB,'logical');
            for j=1:noB
                noOfPacket=length(groupbuffer{4,j,i});
                noPs(j)=noOfPacket;
                loc1=groupbuffer{6,j,i};
                if ~isempty(loc1)
                    validInd(j)=true;
                end
            end
            loc=[];
            noOfLocs=sum(validInd);
            if false%noB >= noOfLocs
                %Global Method
                noB=bWrt(i);
                noP=sum(noPs);
                if noP>=3
                    toas=repmat(datetime,1,noP);
                    foas=zeros(1,noP);
                    CNRs=zeros(1,noP);
                    SIDs=zeros(1,noP);
                    Ants=zeros(1,noP);
                    idx=1;
                    for j=1:noB
                        noOfPacket=noPs(j);
                        toas(idx:idx+noOfPacket-1) = groupbuffer{1,j,i};
                        foas(idx:idx+noOfPacket-1) = groupbuffer{2,j,i};
                        CNRs(idx:idx+noOfPacket-1) = groupbuffer{3,j,i};
                        SIDs(idx:idx+noOfPacket-1) = groupbuffer{4,j,i};
                        Ants(idx:idx+noOfPacket-1) = groupbuffer{5,j,i};
                        idx=idx+noOfPacket;
                    end
                    uSIDs=unique(SIDs);
                    if length(uSIDs)>=3
                        [loc,err,sInfo]=computeMultiBurstSolution2(toas,foas,CNRs,SIDs,noPs);
                        toa1 = mean(sInfo.upTOA(1:noPs(1)));
                        toa2 = mean(sInfo.upTOA(end-noPs(noB)+1:end));
                    end
                end
            end

            if isempty(loc)
                %Average method
                noB=noOfLocs;%redefined
                if noB>1
                    validnoPs=noPs(validInd);
                    noP=sum(validnoPs);
                    validLocs=groupbuffer(6,validInd,i);
                    validErrs=groupbuffer(7,validInd,i);
                    validsInfos=groupbuffer(8,validInd,i);
                    validCNRgroups=groupbuffer(3,validInd,i);
                    validSIDgroups=groupbuffer(4,validInd,i);
                    validAntgroups=groupbuffer(5,validInd,i);
                    CNRs=zeros(1,noB);
                    SIDs=zeros(1,noP);
                    Ants=zeros(1,noP);
                    idx=1;
                    for j=1:noB
                        CNRs(j)= 10*log10(mean(10.^((validCNRgroups{j})/10)));
                        noOfPacket=validnoPs(j);
                        SIDs(idx:idx+noOfPacket-1) = validSIDgroups{j};
                        Ants(idx:idx+noOfPacket-1) = validAntgroups{j};
                        idx=idx+noOfPacket;
                    end
                    toa1=mean(validsInfos{1}.upTOA);
                    toa2=mean(validsInfos{end}.upTOA);
                    [loc,err,sInfo]=computeMultiBurstSolution(validLocs,validErrs,CNRs,validsInfos);
                end
            end

            if ~isempty(loc)

                [uSIDs,ia,~]=unique(SIDs);
                uAnts=Ants(ia);
                noS=length(uSIDs);
                id=idlist{i};
                msg=msglist{i};
                str=sit145(msgno,msg,toa1,toa2,noB,CNRs,uSIDs,uAnts,loc,err);
                wrt.write(str);
                msgno=msgno+1;

                archiveSdata(msgnoS,msg,id,toa1,toa2,uSIDs,uAnts,loc,err,sInfo,noB,noP,noS,wrtS)
                msgnoS=msgnoS+1;
            end
        end
        bWrt(i)=0;%mark as empty
    end
end
end