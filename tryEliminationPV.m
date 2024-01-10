function [G,D,antsV,errorEliminated] = tryEliminationPV(satIDs0,posS0,t0,posS10,velS10,fc10,stdtoa0,stdfoa0)
noOfChannels=length(satIDs0);
errorEliminated = false;

G=[];
D=[];
for i=1:noOfChannels
    sel=ones(1,noOfChannels,'logical');
    sel(i)=false;
%     satIDs = satIDs0(sel);
    posS = posS0(:,sel);t=t0(sel);posS1=posS10(:,sel);velS1=velS10(:,sel);fc1=fc10(sel);stdtoa=stdtoa0(sel);stdfoa=stdfoa0(sel);
%     noOfSats=length(satIDs);
    if noOfChannels>4
        G=firstGuess(posS,t,fc1);
        for j=1:15
            %     [posS1,dt2]=actualtof2(posS,G(1:3));
            [F,D]=FDcreator2(posS,t,posS1,velS1,fc1,G,stdtoa,stdfoa,noOfChannels-1);
            %     [F,D]=FDcreator3(posS1,velS1,fc1,G);
            %     [F,D]=FDcreator1(posS,t,G);
            del=D\F;
%             [del,~,resd]=lscov(D,F);
            del(7)=del(7)*1e-3;
            G=G-del;
        end
        resd = norm(F);
        if resd <10
            errorEliminated=true;            
            antsV=sel;
            break;
        end
    end
    if ~errorEliminated
        antsV = zeros(1,noOfChannels,'logical');
    end
end
end

function [F,D] = FDcreator(posS,t,G)
global LIGHTSPEED;
xyz=G(1:3);
tg=G(7);
R=sqrt(sum((xyz-posS).^2));
F=(R-LIGHTSPEED*(t-tg))';
D=zeros(length(t),8);
D(:,1:3)=((1./R).*(xyz-posS))';
D(:,7)=1e-3*LIGHTSPEED;
end

function [F,D] = FDcreator1(posS,t,G)
global LIGHTSPEED;
xyz=G(1:3);
tg=G(7);
R=sqrt(sum((xyz-posS).^2));
R(end+1)=sqrt(sum(xyz.^2));
f=1/298.257223560;
a=6378.137;
sinth2=(xyz(3))^2/(R(end)^2);
lrad=a*(1-f*sinth2);
obs_range=[LIGHTSPEED*(t-tg) lrad];
F=(R-obs_range)';
D=zeros(length(t)+1,8);
D(1:length(t),1:3)=((1./R(1:length(t))).*(xyz-posS))';
D(1+length(t),1:3)=((1./R(1+length(t))).*xyz)';
D(1:length(t),7)=1e-3*LIGHTSPEED;
end

function [F,D] = FDcreator2(posS,t,posS1,velS1,freq,G,stdtoa,stdfoa,noOfSats)
if noOfSats >= 4
    [F1,D1]=FDcreator1(posS,t,G);
    stdtoa=[stdtoa;0.5];
else
    [F1,D1]=FDcreator(posS,t,G);
end
[F2,D2]=FDcreator3(posS1,velS1,freq,G);
F=[F1./stdtoa;F2./stdfoa];
D=zeros(length(F),8);
D(1:length(F1),:)=D1./stdtoa;
D(length(F1)+1:length(F),:)=D2./stdfoa;
end

function [F,D] = FDcreator3(posS,velS,freq,G)
global LIGHTSPEED;
noOfSat=length(freq);
F=zeros(noOfSat,1);
xyz=G(1:3);
vxyz=G(4:6);
fg=G(8);
dxyz=posS-xyz;
dr=sqrt(sum(dxyz.^2));
uvw=dxyz./dr;
relVel=velS-vxyz;
vcomp=sum(uvw.*relVel);
wvlen = LIGHTSPEED./freq;
fd=freq-fg;
F(1:noOfSat)=(vcomp+wvlen.*fd)';

D=zeros(noOfSat,8);
D(:,1:3) = ((1./dr).*(-relVel+uvw.*vcomp))';
D(:,4:6) = -uvw';
D(:,8) = -wvlen';
end

function [G] = firstGuess(pos,t,f)
%FIRSTGUESS Summary of this function goes here
%   Detailed explanation goes here
EARTHCENTER=[1000;6000;1000];
STATIONARY=[0;0;0];
dt=tof(pos,EARTHCENTER);
G=[EARTHCENTER;STATIONARY;mean(t-dt);mean(f)];
end

function dt=tof(pos1,pos2)
global LIGHTSPEED;
d=sqrt(sum((pos1-pos2).^2));
dt=d/LIGHTSPEED;
end

