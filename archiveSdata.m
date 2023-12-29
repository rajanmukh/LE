function archiveSdata(msgno,msg,id,toa1,toa2,SIDs,ants,loc,err,sInfo,noB,noP,noS,wHnd)
% msgno is a serial no
% msg is the 36HEX representation of one of the message packets received
% through various antenna channels(undecoded form)?? some vagueness
% id is the common 15HEXID derived from the HEX messages(decoded form)
% toas1 is the datetime array of the toas of the first burst
% toas1 is the datetime array of the toas of the last burst burst
% Note for single birst toas1 and toas2 will be identical
% SIDs is an array containing the SatelliteIDs for various antenna channels
% ants is the indices of the detected antenna channels(1 to 7)
% loc is the structure containing the computed lat,lon and altitude
% err is a structure containg EHE and Error ellipse parameters(only EHE field is used in this function)
% sInfo is a structure containing some additional parameters that is
% computed during solution process(other than loc and err) and will be
% useful for filling up some fields of BeaconBurstData and Solution  data
% for commissioning purpose
% noB is no of bursts
% noP is no of packets
% noS is no of satellites
% wHnd is the filewriter handle for archiving the data in a text file
fields=cell(1,27);
LAID=cell(1,2*noS);
SID=cell(1,2*noS);
LUTID='4195';
for i=1:noS
    LAID{2*i-1}=[LUTID,'0',num2str(ants(i)),' '];
    SID{2*i-1}=[num2str(SIDs(i)),' '];
    LAID{2*i}=32;
    SID{2*i}=32;
end
LAID{2*noS}='';
SID{2*noS}='';
LAIDstr=strcat(LAID{1:2*noS});
SIDstr=strcat(SID{1:2*noS});

fields{1}=[num2str(msgno),','];%Solution ID? definition unclear in the doc
fields{2} =[LUTID,','];
toa1.Format='yy DDD HHmm ss.SS';
avtoa1=char(toa1);
fields{3} =[avtoa1,','];
toa2.Format='yy DDD HHmm ss.SS';
avtoa2=char(toa2);
fields{4} = [avtoa2,','];
msgtt = char(datetime('now','format','yyyy-MM-dd HH:mm:ss.SSS'));
fields{5} = [msgtt,','];
fields{6} = [id,','];
fields{7} = [num2str(sInfo.ft,'%12.8f'),','];
hexmsg=msg;
if length(hexmsg)<36
    hexmsg=['00000000',hexmsg];
end
fields{8} = [hexmsg,','];
fields{9} = [num2str(noB),','];%noOfBursts
fields{10} = ['D',','];
fields{11} = [LAIDstr,','];
fields{12} = [num2str(noP,'%02d'),','];%no of packets
fields{13} = [num2str(noS,'%02d'),','];%no of satellites
fields{14} = [SIDstr,','];

fields{15} = [num2str(sInfo.jdop,'%5.2f'),','];
fields{16} = [num2str(err.EHE,'%7.3f'),','];
fields{17} = [sInfo.solMethodology,','];
fields{18} = [num2str(loc.lat,'%+09.5f'),','];
fields{19} = [num2str(loc.lon,'%+010.5f'),','];
if loc.alt <0
    loc.alt = 0;
end
fields{20} = [num2str(loc.alt,'%09.6f'),','];
dist=computeLocError(id,loc);
if dist>=0 % if id is of any reference beacon distance error is obtainable
    fields{21} = [num2str(dist,'%08.3f'),','];
    if noB > 1
        hghgh=0;
    end
else %computeLocError function returns invalid value
    fields{21} = ',';%Location error
end

fields{22} = ['',','];
fields{23} = ['',','];
fields{24} = ['',','];
fields{25} = ['',','];
fields{26} = ['',','];
fields{27} = '';
str=strcat(fields{1:27});
wHnd.write(str);
end

function mag=computeLocError(id,loc)
refIDs={'347C000000FFBFF','3ADEA2223F81FE0','9C62EE2962AF260','9C62EE2962AC3C0','467C000002FFBFF','B5FE18FED639240','3EFC000002FFBFF','9A22BE29630F010','9A22EE29629E2A0','9C62BE29630F1D0','9C6000000000001','9C634E2AB509240','9C7FEC2AACD3590'};% stored IDs
refLat=[13.036,24.431,-20.9088888,-20.9088888,1.3771,35.238833,-29.0465,34.865390123,34.865390123,43.560535214,43.560535214,43.560535214,-49.3515];
refLon=[77.5125,54.448,55.513616,55.513616,103.9881,139.9195,115.3425,33.383751325,33.383751325,1.480896128,1.480896128,1.480896128,70.256];
%india,UAE,Reunion-2,Reunion-1,Singapore,Japan,Australia,Cyprus,Cyprus,France,France,France,Kerguelen    
%search through reference IDs
pos=strcmp(id,refIDs);
if any(pos)
    mag=distance(loc.lat,loc.lon,refLat(pos),refLon(pos),referenceEllipsoid('WGS84'))*1e-3;
else
    mag=-1;
end    
end

