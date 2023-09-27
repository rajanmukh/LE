function add2group(id,msg,toas,foas,CNRs,SIDs,ants,loc,err,sInfo)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global groupbuffer;
global groupID;
global groupTOA;
global bWrt;
global idlist;
global msglist;
global fsynctype;
%search in the existing groupbuffer one by one(first look at toa then
hexID=hex2dec(id);
if msg(5)=='2'
    type=1; % Op
else
    type=2; % Test
end

matchfound = false;
for i=1:100
    bnum = bWrt(i);
    if bnum >0 %not empty     
        if hexID == groupID(i)
            if type==fsynctype(i)
                %addto the existing group
                matchfound = true;                
                if bnum < 25 % this resticts the array size to 25
                    bnum=bnum+1;
                end
                groupbuffer{1,bnum,i}=toas;
                groupbuffer{2,bnum,i}=foas;
                groupbuffer{3,bnum,i}=CNRs;
                groupbuffer{4,bnum,i}=SIDs;
                groupbuffer{5,bnum,i}=ants;
                groupbuffer{6,bnum,i}=loc;
                groupbuffer{7,bnum,i}=err;
                groupbuffer{8,bnum,i}=sInfo;
                bWrt(i)=bnum;
                break;
            end
        end
    end
end
% if no group found then create a fresh group
if ~matchfound    
    for i=1:100
        bnum = bWrt(i);
        if bnum == 0 %freshgroup
            groupTOA(i)=toas(1);
            groupID(i)=hexID;
            fsynctype(i)=type;
            bnum=1;            
            groupbuffer{1,bnum,i}=toas;
            groupbuffer{2,bnum,i}=foas;
            groupbuffer{3,bnum,i}=CNRs;
            groupbuffer{4,bnum,i}=SIDs;
            groupbuffer{5,bnum,i}=ants;
            groupbuffer{6,bnum,i}=loc;
            groupbuffer{7,bnum,i}=err;
            groupbuffer{8,bnum,i}=sInfo;
            bWrt(i)=1;
            idlist{i}=id;
            msglist{i}=msg;
            break;
        end        
    end
end
end


