function [loc,err,sInfo] = computeMultiBurstSolution2(toas,foas,cnrs,satIDs,noPs)
loc=[];
err=[];
sInfo=[];
noB = length(noPs);
%constant
%station location
BANGALORE=1e3*[1.344164600515364   6.068648167092199   1.429495327500622]';
% STATIONARY=[0,0,0]';
f_list=[1544.1e6,1544.9e6,1544.21e6];
noOfChns=length(satIDs);
cflag=floor(satIDs/100)-3;
freq_trns=f_list(cflag) - 406.05e6;
fc = foas+53.1311e3+f_list(cflag)-1e5;
t0=split2fields(toas);
% [toa,d,date,fc,freq_trns]=readSatParamsSGP(datetoa,foa,satIDs);
[stdtoa,stdfoa]=estimateMeasError(cnrs);
t1=addSeconds(t0,0.16);
[posS,velS,dt]=actualtof(t1,satIDs,BANGALORE,'downlink');
sInfo.upTOA = toas - dt/86400;
t=t0.s-dt;%onboard transmit/receive time
t2=addSeconds(t0,0.08);
[posS1,velS1,~]=actualtof(t2,satIDs,BANGALORE,'downlink');%for doppler calculation
fd=getDoppler(posS1,velS1,BANGALORE,fc);
fc1=fc-fd-freq_trns;
uSIDs = unique(satIDs);
noOfSats=length(uSIDs);
if noOfSats>=3    
    G=firstGuess(posS,t,fc1,noPs);
    for i=1:15
        %     [posS1,dt2]=actualtof2(posS,G(1:3));
        [F,D]=FDcreator2(posS,t,posS1,velS1,fc1,G,stdtoa,stdfoa,noOfSats,noPs);
        %     [F,D]=FDcreator3(posS1,velS1,fc1,G);
        %     [F,D]=FDcreator1(posS,t,G);
        del=D\F;
%         [del,~,resd]=lscov(D,F);
        del(3+1:3+noB)=del(3+1:3+noB)*1e-3;
        G=G-del;
    end
    resd = norm(F);
    if resd>100
        errorDetected=true;        
        %try to identify wrong channel
%         [~,tryOrder] = sort(abs(F(1:noOfChns)),'descend');
        [G,D,antsV,errorEliminated] = tryElimination2(satIDs,posS,t,posS1,velS1,fc1,stdtoa,stdfoa,noPs);        
        
    else
        errorDetected=false;
    end
    if ~errorDetected || (errorDetected && errorEliminated)
        location_est=G(1:3);
        % t(:)=G(4);
        [posS2,velS2,~]=actualtof(t2,satIDs,location_est,'uplink');
        fd1 = getDoppler(posS2,velS2,location_est,fc1);
        ft=fc1-fd1;
        llaPos=ecef2lla(1e3*G(1:3)');
        loc.lat=llaPos(1);
        loc.lon=llaPos(2);
        loc.alt=llaPos(3)/1e3;
        [jdop,elp]=computeDOP(D,loc.lat*pi/180,loc.lon*pi/180);
        err.EHE = 2.5*jdop;
        err.ellipse=elp;
        if errorDetected
            stdtoa = stdtoa(antsV);
            ft = ft(antsV);
            noOfSats = noOfSats-1;
        end
        sigt=median(stdtoa);
        sInfo.jdop=jdop/sigt;
        sInfo.ft=mean(ft);
        if noOfSats == 3
            sInfo.solMethodology = 'P2Dd-Global';
        else
            sInfo.solMethodology = 'P3D-Global';
        end
        
    end
end
end


function [pos,vel]=getSatPosVel(toa,satIDs)
global jd2000;
global list;
UT1_UTC=-0.06;
TT_UTC=69.2;
noOfSats = length(satIDs);
pos = zeros(3,noOfSats);
vel = zeros(3,noOfSats);
for i=1:noOfSats
    satrec=list{satIDs(i)-400};
    epochDay=satrec.epochdays;
    ts = toa.s(i);
    d = toa.d(i);
    cdate = toa.date(i);
    tsince=(ts-(epochDay-floor(epochDay))*86400)/60 +(d-floor(epochDay))*1440;
    [~, pos1, vel1] = sgp4 (satrec,  tsince);
    jd=(ts/86400)+juliandate(cdate);
    jd_UT1 = jd + UT1_UTC/86400;
    jd_TT  = jd + TT_UTC/86400;
    ttt = (jd_TT-jd2000)/36525;
    [pos(:,i),vel(:,i),~]=teme2ecef(pos1',vel1',[0,0,0]',ttt,jd_UT1,0,0,0,2);
end
end

function [pos]=adjustRotation(xyz,dt)
omega_dot_earth = 7.2921151467e-5; %(rad/sec)
ths=omega_dot_earth*dt;
pos=zeros(size(xyz));
for i=1:length(dt)
    th=ths(i);
    R=[cos(th) sin(th) 0; -sin(th) cos(th) 0;0 0 1];
    pos(:,i)=R*xyz(:,i);
end
end

function dt=tof(pos1,pos2)
global LIGHTSPEED;
d=sqrt(sum((pos1-pos2).^2));
dt=d/LIGHTSPEED;
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

function[posS,velS,dt]= actualtof(t,sids,place,journey)
dt=0;
for i=1:3
    if strcmp(journey,'downlink')
        [posS,velS]=getSatPosVel(addSeconds(t,-dt),sids);
    else
        [posS,velS]=getSatPosVel(addSeconds(t,dt),sids);
    end
    dt=tof(posS,place);
end
end

function [posS,dt]=actualtof2(posS,place)
for j=1:3
    dt=tof(posS,place);
    [posS] = adjustRotation(posS,-dt);
end
end

function fd=getDoppler(posS,velS,place,freq)
global LIGHTSPEED;
wvnum = freq/LIGHTSPEED;
dxyz=posS-place;
dr=sqrt(sum(dxyz.^2));
uvw=dxyz./dr;
vcomp=sum(uvw.*velS);
fd=-vcomp.*wvnum;
end

function [JDOP,elpse] = computeDOP(D,lat,lon)
R=[-sin(lon) cos(lon) 0;-sin(lat)*cos(lon) -sin(lat)*sin(lon) cos(lat);cos(lat)*cos(lon) cos(lat)*sin(lon) sin(lat)];
P = inv(D'*D);
Q=R*P(1:3,1:3)*R';
JDOP=sqrt(Q(1,1)+Q(2,2));
[V,D]=eig(Q(1:2,1:2));
[ab,ind]=sort(sqrt(diag(D)),'descend');
maxind=ind(1);
A=atan(V(2,maxind)/V(1,maxind))*180/pi;
if A<0
    A=360+A;
end
elpse=[1.4*ab(1),1.4*ab(2),A];
end

function [terrstd,ferrstd] = estimateMeasError(cbn0)
terrstd=0.3*(15*2.^((-cbn0+35)/6))';
ferrstd=0.7e-3*(0.2*2.^((-cbn0+35)/6)+1)';
end

function t=split2fields(toa)
t.d=day(toa,'dayofyear');
t.s=3600*toa.Hour+60*toa.Minute+toa.Second;
t.date=datetime(toa.Year,toa.Month,toa.Day);
end

function t1 = addSeconds(t,s)
t1=t;
t1.s=t.s+ s;
end
