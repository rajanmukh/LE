function [G,D,antsV,errorEliminated] = tryElimination2(satIDs0,posS0,t0,posS10,velS10,fc10,stdtoa0,stdfoa0,noPs0)
noB = length(noPs0);
inds = [0 cumsum(noPs0)];
uSID = unique(satIDs0);
errorEliminated = false;
G=[];
D=[];
noOfSats=length(uSID);

for i=1:noOfSats
    sel=satIDs0 ~=uSID(i);
    posS = posS0(:,sel);t=t0(sel);posS1=posS10(:,sel);velS1=velS10(:,sel);fc1=fc10(sel);
    stdtoa=stdtoa0(sel);stdfoa=stdfoa0(sel);    
    if noOfSats>3
        noPs = zeros(size(noPs0));
        for j=1:noB
            noPs(j)=sum(sel(inds(j)+1:inds(j+1)));
        end
        noPs = noPs(noPs~=0);
        noB = length(noPs);
        G=firstGuess(posS,t,fc1,noPs);
        
        for j=1:15
            %     [posS1,dt2]=actualtof2(posS,G(1:3));
            [F,D]=FDcreator2(posS,t,posS1,velS1,fc1,G,stdtoa,stdfoa,noOfSats-1,noPs);
            %     [F,D]=FDcreator3(posS1,velS1,fc1,G);
            %     [F,D]=FDcreator1(posS,t,G);
            del=D\F;
%             [del,~,resd]=lscov(D,F);
            del(3+1:3+noB)=del(3+1:3+noB)*1e-3;
            G=G-del;
        end
        resd = norm(F);
        if resd <100
            errorEliminated=true; 
            antsV=sel;
            break;
        end        
    end
end
if ~errorEliminated    
    antsV=zeros(size(satIDs0),'logical');
end
end

function [F,D] = FDcreator(posS,t,G,noPs)
global LIGHTSPEED;
noB=length(noPs);
noOfPackets=length(t);
obs_range = zeros(1,noOfPackets);
D=zeros(noOfPackets,3+noB);
xyz=G(1:3);
R=sqrt(sum((xyz-posS).^2));
idx=1;
for i=1:noB
    noOfPacket=noPs(i);
    tg=G(3+i);
    selection=idx:idx+noOfPacket-1;
    obs_range(selection)=LIGHTSPEED*(t(selection)-tg);
    D(selection,1:3)=((1./R(selection)).*(xyz-posS(:,selection)))';
    D(selection,3+i)=1e-3*LIGHTSPEED;
    idx=idx+noOfPacket;
end
F=(R-obs_range)';
end

function [F,D] = FDcreator1(posS,t,G,noPs)
global LIGHTSPEED;
noB=length(noPs);
noOfPackets=length(t);
obs_range = zeros(1,noOfPackets+1);
D=zeros(noOfPackets+1,3+noB);
xyz=G(1:3);
R=sqrt(sum((xyz-posS).^2));
R(end+1)=sqrt(sum(xyz.^2));
f=1/298.257223560;
a=6378.137;
sinth2=(xyz(3))^2/(R(end)^2);
lrad=a*(1-f*sinth2);
idx=1;
for i=1:noB
    noOfPacket=noPs(i);
    tg=G(3+i);
    selection=idx:idx+noOfPacket-1;
    obs_range(selection)=LIGHTSPEED*(t(selection)-tg);
    D(selection,1:3)=((1./R(selection)).*(xyz-posS(:,selection)))';
    D(selection,3+i)=1e-3*LIGHTSPEED;
    idx=idx+noOfPacket;
end
obs_range(end)=lrad;
D(noOfPackets+1,1:3)=((1./R(end)).*xyz)';
F=(R-obs_range)';
end

function [F,D] = FDcreator2(posS,t,posS1,velS1,freq,G,stdtoa,stdfoa,noOfSats,noPs)
noB=length(noPs);
if noOfSats == 3
    [F1,D1]=FDcreator1(posS,t,G,noPs);
    stdtoa=[stdtoa;0.5];
else
    [F1,D1]=FDcreator(posS,t,G,noPs);
end
[F2,D2]=FDcreator3(posS1,velS1,freq,G,noPs);
F=[F1./stdtoa;F2./stdfoa];
D=zeros(length(F),2*noB+3);
D(1:length(F1),1:3+noB)=D1./stdtoa;
scaledD2=D2./stdfoa;
D(length(F1)+1:length(F),1:3)=scaledD2(:,1:3);
D(length(F1)+1:length(F),3+noB+1:3+2*noB)=scaledD2(:,4:3+noB);
end

function [F,D] = FDcreator3(posS,velS,freq,G,noPs)
global LIGHTSPEED;
noB=length(noPs);
noOfPackets=length(freq);
F=zeros(noOfPackets,1);
D=zeros(noOfPackets,3+noB);
xyz=G(1:3);
idx=1;
for i=1:noB
    noOfPacket=noPs(i);
    fg=G(3+noB+i);
    selection=idx:idx+noOfPacket-1;
    dxyz=posS(:,selection)-xyz;
    dr=sqrt(sum(dxyz.^2));
    uvw=dxyz./dr;
    vcomp=sum(uvw.*velS(:,selection));
    wvlen = LIGHTSPEED./freq(selection);
    fd=freq(selection)-fg;
    F(selection)=(vcomp+wvlen.*fd)';
    D(selection,1:3) = ((1./dr).*(-velS(:,selection)+uvw.*vcomp))';
    D(selection,3+i) = -wvlen';
    idx=idx+noOfPacket;
end
end

function [G] = firstGuess(pos,t,f,noPs)
%FIRSTGUESS Summary of this function goes here
%   Detailed explanation goes here
EARTHCENTER=[1000;6000;1000];
dt=tof(pos,EARTHCENTER);
t1=t-dt;
noB=length(noPs);
noOfUnknowns=3+2*noB;
G=zeros(noOfUnknowns,1);
G(1:3)=EARTHCENTER;
idx=1;
for i=1:noB
    noOfPacket=noPs(i);
    G(3+i)=mean(t1(idx:idx+noOfPacket-1));
    G(3+noB+i)=mean(f(idx:idx+noOfPacket-1));
    idx=idx+noOfPacket;
end
end


function dt=tof(pos1,pos2)
global LIGHTSPEED;
d=sqrt(sum((pos1-pos2).^2));
dt=d/LIGHTSPEED;
end

