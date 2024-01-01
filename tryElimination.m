function [G,D,antsV,errorEliminated,resd1] = tryElimination(satIDs0,posS0,t0,posS10,velS10,fc10,stdtoa0,stdfoa0)
noOfChannels=length(satIDs0);
errorEliminated = false;

G=[];
D=[];
resd1=0;
for i=1:noOfChannels
    sel=ones(1,noOfChannels,'logical');
    sel(i)=false;
%     satIDs = satIDs0(sel);
    posS = posS0(:,sel);t=t0(sel);posS1=posS10(:,sel);velS1=velS10(:,sel);fc1=fc10(sel);stdtoa=stdtoa0(sel);stdfoa=stdfoa0(sel);
%     noOfSats=length(satIDs);
    if noOfChannels>3
        G=firstGuess(posS,t);
        G(5)=mean(fc1);
        for j=1:15
            %     [posS1,dt2]=actualtof2(posS,G(1:3));
            [F,D]=FDcreator2(posS,t,posS1,velS1,fc1,G,stdtoa,stdfoa,noOfChannels-1);
            %     [F,D]=FDcreator3(posS1,velS1,fc1,G);
            %     [F,D]=FDcreator1(posS,t,G);
            del=D\F;
%             [del,~,resd]=lscov(D,F);
            del(4)=del(4)*1e-3;
            G=G-del;
        end
        resd = norm(F);
        resd1=norm(F(end-noOfChannels+2:end));
        if resd <200
            errorEliminated=true;            
            antsV=sel;
            %recompute
            adjvar=resd1/0.45;
            adjvar=1;
            for j=1:15
                %     [posS1,dt2]=actualtof2(posS,G(1:3));
                [F,D]=FDcreator2(posS,t,posS1,velS1,fc1,G,stdtoa,adjvar*stdfoa,noOfChannels-1);
                %     [F,D]=FDcreator3(posS1,velS1,fc1,G);
                %     [F,D]=FDcreator1(posS,t,G);
                del=D\F;
                %             [del,~,resd]=lscov(D,F);
                del(4)=del(4)*1e-3;
                G=G-del;
            end
            resd = norm(F);
            %
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
tg=G(4);
R=sqrt(sum((xyz-posS).^2));
F=(R-LIGHTSPEED*(t-tg))';
D=zeros(length(t),4);
D(:,1:3)=((1./R).*(xyz-posS))';
D(:,4)=1e-3*LIGHTSPEED;
end

function [F,D] = FDcreator1(posS,t,G)
global LIGHTSPEED;
xyz=G(1:3);
tg=G(4);
R=sqrt(sum((xyz-posS).^2));
R(end+1)=sqrt(sum(xyz.^2));
f=1/298.257223560;
a=6378.137;
sinth2=(xyz(3))^2/(R(end)^2);
lrad=a*(1-f*sinth2);
obs_range=[LIGHTSPEED*(t-tg) lrad];
F=(R-obs_range)';
D=zeros(length(t)+1,4);
D(1:length(t),1:3)=((1./R(1:length(t))).*(xyz-posS))';
D(1+length(t),1:3)=((1./R(1+length(t))).*xyz)';
D(1:length(t),4)=1e-3*LIGHTSPEED;
end

function [F,D] = FDcreator2(posS,t,posS1,velS1,freq,G,stdtoa,stdfoa,noOfSats)
if noOfSats == 3
    [F1,D1]=FDcreator1(posS,t,G(1:4));
    stdtoa=[stdtoa;0.5];
else
    [F1,D1]=FDcreator(posS,t,G(1:4));
end
[F2,D2]=FDcreator3(posS1,velS1,freq,G([1,2,3,5]));
F=[F1./stdtoa;F2./stdfoa];
D=zeros(length(F),5);
D(1:length(F1),1:4)=D1./stdtoa;
D(length(F1)+1:length(F),[1:3,5])=D2./stdfoa;
end

function [F,D] = FDcreator3(posS,velS,freq,G)
global LIGHTSPEED;
noOfSat=length(freq);
F=zeros(noOfSat,1);
xyz=G(1:3);
fg=G(4);
dxyz=posS-xyz;
dr=sqrt(sum(dxyz.^2));
uvw=dxyz./dr;
vcomp=sum(uvw.*velS);
wvlen = LIGHTSPEED./freq;
fd=freq-fg;
F(1:noOfSat)=(vcomp+wvlen.*fd)';

D=zeros(noOfSat,4);
D(:,1:3) = ((1./dr).*(-velS+uvw.*vcomp))';
D(:,4) = -wvlen';
end

function [G] = firstGuess(pos,t)
%FIRSTGUESS Summary of this function goes here
%   Detailed explanation goes here
EARTHCENTER=[1000;6000;1000];
dt=tof(pos,EARTHCENTER);
G=[EARTHCENTER;mean(t-dt)];
end

function dt=tof(pos1,pos2)
global LIGHTSPEED;
d=sqrt(sum((pos1-pos2).^2));
dt=d/LIGHTSPEED;
end

