clear
for di=1:1

    RxSite=lla2ecef([13.036,77.5124,930])'*1e-3;%Bangalore
    REFID='9C62EE2962AF260';%{'9C62EE2962AF260','3EFC000002FFBFF','3ADEA2223F81FE0','9A22EE29629E2A0','B5FE18FED639240','9C6000000000001','9C7FEC2AACD3590'};
    %     REFID1=;
    dt=datetime(2023,12,20+di-1)
    otherID=true;
    % REFID='347C000000FFBFF';
    % TxSite=lla2ecef([24.431,54.448,5])'*1e-3;%UAE;BRT=50;
    % FoT=406.043000e6;

    clpath=pwd;%'C:\Users\Istrac\Downloads\18.05.23\Loc_Est\LE';
    if ~exist('initialized','var')
        addpath([clpath,'\sgp4']);
        addpath([clpath,'\propagator']);
        javaclasspath([clpath,'\javaclasses']);
        initialized = true;
        doy=day(dt,'dayofyear');
        misSIDs=readrinex(['Ephemeris\BRDC00IGS_R_2023',num2str(doy,'%03d'),'0000_01D_MN.rnx']);
    end
    warning('off','MATLAB:nearlySingularMatrix')
    warning('off','MATLAB:rankDeficientMatrix')
    warning('off','MATLAB:hex2dec:InputExceedsFlintmax')
    if exist('rx','var')
        %     rx.close()
        wrt.close()
        wrtB.close()
        wrtS.close()
        pause(1)
    end
    fileID=fopen(['BeaconData\beacondata_LE_',datestr(dt,'yyyy_mm_dd'),'.txt']);%%
    load('prns.mat')
    present_hour = 0;
    prev_hour = 0;
    present_day=0;
    prev_day=0;
    msgnoB=1;
    msgnoS=1;
    %%% readtle();
    % rx=javaObject('Receiver','127.0.0.1',6006);
    wrt=javaObject('Archiver',string(clpath));
    wrtB=javaObject('Archiver',string(strcat(clpath,'\commissioning\Bdata')));
    wrtS=javaObject('Archiver',string(strcat(clpath,'\commissioning\Sdata')));
    initializeRecord();
    snameindex=[24,45,66,87,108,129,150]+1;
    count=0;count1=0;
    bm=zeros(7,1728);
    TOAs=NaT(1,1728);
    j=1;
    while(1)
        %     ca=native2unicode(rx.receive());
        ca=fgetl(fileID);%%
        if isempty(ca)
            %         'not connected'
            %         pause(1)
            continue;
        end
        if ~ischar(ca)%%
            break;%end of file%%
        end%%
        %     str=string(ca');
        str=string(ca);%%
        ss=split(str,',');
        antmarks=str2double(ss(13:19));
        snames=ss(snameindex);
        ants=find(antmarks==1 & ~strcmp(snames,'DEFAULT') & ~strcmp(snames,'0'));
        nos = length(ants);
        msgs = cell(1,nos);
        brates= cell(1,nos);
        toas = repmat(NaT,1,nos);
        tmstamps = cell(1,nos);
        foas = zeros(1,nos);
        CNRs = zeros(1,nos);
        SIDs = zeros(1,nos);
        pdf1errs=cell(1,nos);
        pdf2errs=cell(1,nos);
        for i=1:nos
            chn=ants(i);
            ii=2+chn*21; %%itwas 22

            sname = char(ss(ii+2));
            sid=getSID(sname,prns);
            SIDs(i)=sid;
            tmstamps{i} = char(ss(ii+3));
            brates{i} = char(ss(ii+4));
            id=char(ss(ii+7));
            otherID=~any(strcmp(id,REFID)) ;
            if otherID
                break;
            end
            msg=char(ss(ii+8));
            msgs{i}=msg;
            CNRs(i)=str2double(ss(ii+9));
            foa=str2double(ss(ii+10));
            if sid==419
                foas(i)=foa+10.1;
            elseif sid == 502
                foas(i)=foa+13.5;
            else
                foas(i)=foa+12.6;
            end

            pdf1errs{i}=char(ss(ii+11));
            pdf2errs{i}=char(ss(ii+12));
            toa = ss(ii+13:ii+20);
            if isempty(toa(8))
                otherID=true;
                break;
            end
            if strcmp(toa(3),'24')
                otherID=true;
                break;
            end
            TOA=[num2str(str2double(toa(1))+2000),'-',num2str(str2double(toa(2)),'%03d'),' ',num2str(str2double(toa(3)),'%02d'),':',num2str(str2double(toa(4)),'%02d'),':',num2str(str2double(toa(5)),'%02d'),':',num2str(str2double(toa(6)),'%03d'),num2str(str2double(toa(7)),'%03d'),num2str(str2double(toa(8)),'%03d')];
            toas(i) = datetime(TOA,'InputFormat','uuuu-DDD HH:mm:ss:SSSSSSSSS');
            present_hour = str2double(toa(3));
            present_day = str2double(toa(2));
            if present_hour ~= prev_hour
                readtle(toas(i));
                prev_hour = present_hour;
            end
        end
        if present_day ~= prev_day
            msgno=0;
            wrt.makenewfile(string(datetime([char(toa(1)),'-',char(toa(2))],'InputFormat','uuuu-DDD','format','yy_MM_dd')));
            wrtB.makenewfile(string(datetime([char(toa(1)),'-',char(toa(2))],'InputFormat','uuuu-DDD','format','yy_MM_dd')));
            wrtS.makenewfile(string(datetime([char(toa(1)),'-',char(toa(2))],'InputFormat','uuuu-DDD','format','yy_MM_dd')));
            prev_day = present_day;
        end

        if otherID
            continue;
        end
        if nos>0
            bm(ants,j)=SIDs';
            TOAs(j)=toas(1);
            j=j+1;
        end
        if nos>0

            for k=1:length(misSIDs)
                delmark=SIDs==misSIDs(k);
                if any(delmark)
                    if nos==3
                        count=count+1;
                    end
                    nos=nos-1;
                    toas(delmark)=[];
                    foas(delmark)=[];
                    CNRs(delmark)=[];
                    ants(delmark)=[];
                    SIDs(delmark)=[];
                end
            end



            %         foa_m = foas+53.1311e3+1544.1e6-1e5;
            %         foa_m(SIDs>500)=foa_m(SIDs>500)+8e5;
            %         [TOT_e,FOA_e]=TRxOperation1(SIDs,toas,FoT,TxSite,RxSite);
            %         ferr=foa_m-FOA_e;
            %
            %         if any(abs(ferr)>1)
            %             count1=count1+1;
            %             tr=mean(TOT_e(abs(ferr)<1));
            %             t1=TOT_e(abs(ferr)>1);
            %             terr=1e6*seconds(tr-t1);
            %         end
            [loc,err,antsV,sInfo]=computeLocation(toas, foas, CNRs, SIDs);
            if ~isempty(loc)
                if ~isreal(err.EHE)
                    continue;
                end
            end
            msgno=msgno+1;
            msgno
            %         if strcmp(id,'3ADEA2223F81FE0')
            %             distance(loc.lat,loc.lon,24.431,54.448,referenceEllipsoid('WGS84'))*1e-3
            %             fhf=0;
            %         end

            if length(antsV)>1 && ~all(antsV)
                %purge
                if length(antsV)==3
                    count=count+1;
                end
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
    end
    % rx.close()
    wrt.close()
    wrtB.close()
    wrtS.close()
    clear
end
generateReport1

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

