clpath=pwd;%'C:\Users\Istrac\Downloads\18.05.23\Loc_Est\LE';
if ~exist('initialized','var')
    addpath([clpath,'\sgp4']);
    javaclasspath([clpath,'\javaclasses']);  
    
    initialized = true;
end
warning('off','MATLAB:nearlySingularMatrix')
warning('off','MATLAB:rankDeficientMatrix')
warning('off','MATLAB:hex2dec:InputExceedsFlintmax')
if exist('rx','var')
    rx.close()
    wrt.close()
    wrtB.close()
    wrtS.close()
    pause(1)
end
load('prns.mat')
present_hour = 0;
prev_hour = 0;
present_day=0;
prev_day=0;
msgnoB=1;
msgnoS=1;
% readtle();
rx=javaObject('Receiver','127.0.0.1',6006);
wrt=javaObject('Archiver',string(clpath));
wrtB=javaObject('Archiver',string(strcat(clpath,'\commissioning\Bdata')));
wrtS=javaObject('Archiver',string(strcat(clpath,'\commissioning\Sdata')));
initializeRecord();
ANTS=1:7;
DUMMY=datetime;
while(1)
    ca=native2unicode(rx.receive());
    if isempty(ca)
        'not connected'
        pause(1)
        continue;
    end
    
    str=string(ca');
    ss=split(str,',');
    antmarks=str2double(ss(12:18));
    snames=ss([24,45,66,87,108,129,150]);
    ants=ANTS(antmarks==1 & ~strcmp(snames,'DEFAULT'));
    nos = length(ants);
    msgs = cell(1,nos);
    brates= cell(1,nos);
    toas = repmat(DUMMY,1,nos);
    tmstamps = cell(1,nos);
    foas = zeros(1,nos);
    CNRs = zeros(1,nos);
    SIDs = zeros(1,nos);
    pdf1errs=cell(1,nos);
    pdf2errs=cell(1,nos);
    for i=1:nos
        chn=ants(i);
        ii=22+(chn-1)*21; 
        
        sname = char(ss(ii+2));
        SIDs(i)=getSID(sname,prns);
        tmstamps{i} = char(ss(ii+3));
        brates{i} = char(ss(ii+4));
        id=char(ss(ii+7));
        msg=char(ss(ii+8));
        msgs{i}=msg;
        CNRs(i)=str2double(ss(ii+9));
        foas(i)=str2double(ss(ii+10));
        pdf1errs{i}=char(ss(ii+11));
        pdf2errs{i}=char(ss(ii+12));
        toa = ss(ii+13:ii+20);
        TOA=[num2str(str2double(toa(1))+2000),'-',num2str(str2double(toa(2)),'%03d'),' ',num2str(str2double(toa(3)),'%02d'),':',num2str(str2double(toa(4)),'%02d'),':',num2str(str2double(toa(5)),'%02d'),':',num2str(str2double(toa(6)),'%03d'),num2str(str2double(toa(7)),'%03d'),num2str(str2double(toa(8)),'%03d')];
        toas(i) = datetime(TOA,'InputFormat','uuuu-DDD HH:mm:ss:SSSSSSSSS'); 
        present_hour = str2double(toa(3));
        present_day = str2double(toa(2));
        if present_hour ~= prev_hour
            readtle(toas(i));
        end
        if present_day ~= prev_day
            msgno=0;
            wrt.makenewfile(string(datetime([char(toa(1)),'-',char(toa(2))],'InputFormat','uuuu-DDD','format','yy_MM_dd')));
            wrtB.makenewfile(string(datetime([char(toa(1)),'-',char(toa(2))],'InputFormat','uuuu-DDD','format','yy_MM_dd')));
            wrtS.makenewfile(string(datetime([char(toa(1)),'-',char(toa(2))],'InputFormat','uuuu-DDD','format','yy_MM_dd')));
        end       
    end
    
    if nos>0
        msgno=msgno+1;
        msgno
%         if msgno == 249
        
        [loc,err,antsV,sInfo]=computeLocation(toas, foas, CNRs, SIDs);
        if length(antsV)>1 && ~all(antsV)
            %purge
            msgs = msgs(antsV);
            brates = brates(antsV);
            toas = toas(antsV);
            tmstamps = tmstamps(antsV);
            foas = foas(antsV);
            CNRs = CNRs(antsV);
            SIDs = SIDs(antsV);
            pdf1errs = pdf1errs(antsV);
            pdf2errs = pdf2errs(antsV);
            ants=ants(antsV);
            sInfo=purge(sInfo,antsV);
        end
        if any(antsV)
            mtoa=mean(sInfo.upTOA);
            noP=length(ants);
            if ~isempty(loc) && nos >=2
                noB=1;
                str=sit145(msgno,msg,mtoa,mtoa,noB,CNRs,SIDs,ants,loc,err);               
                % archive solution  data for commissioning purpose
                noS=noP;                
                archiveSdata(msgnoS,msg,id,mtoa,mtoa,SIDs,ants,loc,err,sInfo,noB,noP,noS,wrtS);
                msgnoS = msgnoS + 1;                
            else
                str=sit142(msgno,msg,mtoa,mtoa,CNRs,SIDs,ants);
            end
            wrt.write(str);
            % archive beacon detection data for commissioning purpose
            archiveBdata(msgnoB,tmstamps,id,msgs,CNRs,SIDs,pdf1errs,pdf2errs,brates,ants,sInfo,wrtB);
            msgnoB = msgnoB+noP;  
            %add 2 2nd leve;l groupfor multi Burst computation
            add2group(id,msg,toas,foas,CNRs,SIDs,ants,loc,err,sInfo);
        end
    end
    cTime=datetime(TOA,'InputFormat','uuuu-DDD HH:mm:ss:SSSSSSSSS'); 
    [msgno,msgnoS]=flushGroup(cTime,msgno,wrt,msgnoS,wrtS);    
    prev_hour = present_hour;
    prev_day = present_day;
end
rx.close()
wrt.close()
wrtB.close()
wrtS.close()

function SID=getSID(snm,prnlist)
if snm(1)=='G'
    idx=str2double(extractAfter(snm,5));
elseif snm(1)=='C'
    idx=str2double(extractAfter(snm,9));
else
    idx=2;
end
SID=prnlist(idx);
end
function sInfo1 = purge(sInfo,antsV)
sInfo1=sInfo;
sInfo1.satPos = sInfo.satPos(:,antsV);
sInfo1.satVel = sInfo.satVel(:,antsV);
sInfo1.toff = sInfo.toff(antsV);
sInfo1.upTOA = sInfo.upTOA(antsV);
sInfo1.foff = sInfo.foff(antsV);
sInfo1.upFOA = sInfo.upFOA(antsV);
end

