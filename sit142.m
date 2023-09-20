function str = sit142(msgno,msg,toa1,toa2,CNRgroups,SIDgroup,ants)
reptfaclity='4195';
msgtt = char(datetime('now','format','yy DDD HHmm'));
line1 = ['/',num2str(msgno,'%05d'),' ','00000','/',reptfaclity,'/',msgtt];
line2='/142/4190/01';
toa1.Format='yy DDD HHmm ss.SS';
avtoa1=char(toa1);
line3=['/',reptfaclity,'/','+99999.9 999.9 +99.99','/',avtoa1];
hexmsg=msg;
if length(hexmsg)<36
    hexmsg=['00000000',hexmsg];
end
toa2.Format='yy DDD HHmm ss.SS';
avtoa2=char(toa2);
line4=['/',avtoa2,'/01/',hexmsg];
avcnr=num2str(mean(CNRgroups),'%05.2f');
nwchns='00';
noOfantChannels=length(ants);
achns=num2str(noOfantChannels,'%02d');
np=achns;
line5=['/',avcnr,'/',nwchns,'/',achns,'/',np];
sidlist=repmat('000 ',1,17);
for i=1:noOfantChannels
    sidlist((i-1)*4+1:i*4-1)=num2str(SIDgroup(i));
end
line6=['/',sidlist];
line7='/LASSIT';
line8='/ENDMSG';
str=[line1 newline line2 newline line3 newline line4 newline line5 newline line6 newline line7 newline line8 newline];
end

