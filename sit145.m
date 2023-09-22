function str = sit145(msgno,msg,toa1,toa2,noB,CNRgroups,SIDgroup,ants,loc,err)
reptfaclity='4195';
msgtt = char(datetime('now','format','yy DDD HHmm'));
line1 = ['/',num2str(msgno,'%05d'),' ','00000','/',reptfaclity,'/',msgtt];
line2='/145/4190/01';
toa1.Format='yy DDD HHmm ss.SS';
avtoa1=char(toa1);
line3=['/',reptfaclity,'/','+99999.9 999.9 +99.99','/',avtoa1];
hexmsg=msg;
if length(hexmsg)<36
    hexmsg=['00000000',hexmsg];
end
toa2.Format='yy DDD HHmm ss.SS';
avtoa2=char(toa2);
line4=['/',avtoa2,'/',num2str(noB,'%02d'),'/',hexmsg];
latstr=num2str(loc.lat,'%+06.3f');
lonstr=num2str(loc.lon,'%+07.3f');
qf=QF(err.EHE);
line5=['/+419/',latstr,'/',lonstr,'/',num2str(qf,'%03d'),'/',num2str(err.EHE,'%06.2f')];
avcnr=num2str(10*log10(mean(10.^(CNRgroups/10))),'%05.2f');
nwchns='00';
noOfantChannels=length(ants);
achns=num2str(noOfantChannels,'%02d');
if loc.alt <0
    loc.alt = 0;
end
altitude=num2str(loc.alt,'%09.6f');
qi='00';
np=achns;

elpse=[num2str(err.ellipse(3),'%03.0f'),' ',num2str(err.ellipse(1),'%04.1f'),' ',num2str(err.ellipse(2),'%04.1f')];
line6=['/',avcnr,'/',nwchns,'/',achns,'/',altitude,'/',qi,'/',np,'/',elpse];
sidlist=repmat('000 ',1,17);
for i=1:noOfantChannels
    sidlist((i-1)*4+1:i*4-1)=num2str(SIDgroup(i));
end
line7=['/',sidlist];
line8='/LASSIT';
line9='/ENDMSG';
str=[line1 newline line2 newline line3 newline line4 newline line5 newline line6 newline line7 newline line8 newline line9 newline];
end

function qf=QF(ehe)
d=ehe/1.8;
if d>50
    qf=1;
elseif d>20
    qf=2;
elseif d>10
    qf=3;
elseif d>5
    qf=4;
elseif d>2.7
    qf=5;
elseif d>1
    qf=6;
elseif d>0.5
    qf=7;
elseif d>0.25
    qf=8;
else
    qf=9;
end
end


