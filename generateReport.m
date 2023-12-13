clear
close all
import mlreportgen.report.*
import mlreportgen.dom.* 

R1=Report('India Beacon Statistics','docx');
open(R1)
tp1 = TitlePage();
tp1.Title = 'INDIA BEACON';
tp1.Author = 'ISTRAC';
add(R1,tp1)
toc1=TableOfContents;
add(R1,toc1)

R2=Report('UAE Beacon Statistics','docx');
open(R2)
tp2 = TitlePage();
tp2.Title = 'UAE BEACON';
tp2.Author = 'ISTRAC';
add(R2,tp2)
toc2=TableOfContents;
add(R2,toc2)

R3=Report('Singapore Beacon Statistics','docx');
open(R3)
tp3 = TitlePage();
tp3.Title = 'Singapore BEACON';
tp3.Author = 'ISTRAC';
add(R3,tp3)
toc3=TableOfContents;
add(R3,toc3)

startDate = datetime('4-Dec-2023');
noOfDays = 1;
bstat = cell(5,3,noOfDays);
for dno= 1:noOfDays
    coldate = startDate+(dno-1)
    
    %%
    filename = ['commissioning\Bdata\Log\','sit_',num2str(coldate.Year-2000),'_',num2str(coldate.Month,'%02d'),'_',num2str(coldate.Day,'%02d'),'.txt'];
    
    fbias=-13;   
    
    fileID=fopen(filename);
    dataarr=textscan(fileID,'%s%[^\n\r]','Delimiter','');
    fclose(fileID);
    lines=dataarr{1};
    clear dataarr   
    noOfLines = floor(length(lines)/1);
    
    bID_b = cell(1,noOfLines);
    msg = cell(1,noOfLines);
    foa = zeros(1,noOfLines);
    foff = zeros(1,noOfLines);
    toa= repmat(datetime,1,noOfLines);
    toff = zeros(1,noOfLines);
    CNR = zeros(1,noOfLines);
    antNo=zeros(1,noOfLines);
    SIDa = zeros(1,noOfLines);
    pXYZ= zeros(3,noOfLines);
    vXYZ = zeros(3,noOfLines);
    err1 = zeros(1,noOfLines);
    err2 = zeros(1,noOfLines);
    
    for i=1:noOfLines
        fields = split(lines{i},',');
        msg{i}=fields{2};
        bID_b{i}=fields{3};
        foa(i) = str2double(fields{5})-fbias;
        foff(i) = str2double(fields{6});
        toa(i) = datetime(fields{7},'InputFormat','yyyy-MM-dd HH:mm:ss.SSSSSSSSS');
        toff(i) = str2double(fields{8});
        CNR(i) = str2double(fields{9});
        antNo(i) = str2double(fields{11})-419500;
        SIDa(i) = str2double(fields{12});
        pXYZ(:,i) = str2double(fields(13:15));
        vXYZ(:,i) = str2double(fields(16:18));
        err1(i) = str2double(fields{19});
        err2(2) = str2double(fields{20});
    end
    %%
    filename = ['commissioning\Sdata\Log\','sit_',num2str(coldate.Year-2000),'_',num2str(coldate.Month,'%02d'),'_',num2str(coldate.Day,'%02d'),'.txt'];
    fileID=fopen(filename);
    dataarr=textscan(fileID,'%s%[^\n\r]','Delimiter','');
    lines=dataarr{1};
    clear dataarr
    noOfLines = floor(length(lines)/1);
    avtoa1=repmat(datetime,1,noOfLines);
    avtoa2=repmat(datetime,1,noOfLines);
    bID_s = cell(1,noOfLines);
    ft = zeros(1,noOfLines);
    noB = zeros(1,noOfLines);
    noP = zeros(1,noOfLines);
    noS = zeros(1,noOfLines);
    JDOP = zeros(1,noOfLines);
    EHE = zeros(1,noOfLines);
    solMethod = zeros(1,noOfLines);
    lat = zeros(1,noOfLines);
    lon = zeros(1,noOfLines);
    alt = zeros(1,noOfLines);
    locerr = zeros(1,noOfLines);
    for i=1:noOfLines
        fields = split(lines{i},',');
        avtoa1(i)=datetime(['20',fields{3}],'InputFormat','uuuu DDD HHmm ss.SS');
        avtoa2(i)=datetime(['20',fields{4}],'InputFormat','uuuu DDD HHmm ss.SS');
        bID_s{i} = fields{6};
        ft(i) = str2double(fields{7});
        noB(i) = str2double(fields{9});
        noP(i) = str2double(fields{12});
        noS(i) = str2double(fields{13});
        JDOP(i) = str2double(fields{15});
        EHE(i) = str2double(fields{16});
        if contains(fields{17},'Average')
            solMethod(i) = 1;
        else
            solMethod(i) = 2;
        end
        lat(i) = str2double(fields{18});
        lon(i) = str2double(fields{19});
        alt(i) = str2double(fields{20});
        locerr(i) = str2double(fields{21});
    end
    %% 
    coldate.Format='dd-MMM-yy';
    
%     ID = '9C6000000000001';%France
%     pos=[43.56,1.48,214];BRT=50;
%     refFreq = 406.022000e6;
%     initializeRecord();
%     addpath([pwd,'\sgp4']);
%     readtle(toa(1));
%     
%     [Hb,detstat]=analyzeBdata1(msg,ID,pos,refFreq,BRT,bID_b,foa,foff,toa,CNR,antNo,SIDa,pXYZ,vXYZ);  
%     [PrLoc,accPerc,predAcc,noOfSamples,Hs]=solStat(ID,bID_s,noP,noB,lat,lon,locerr,EHE,solMethod,avtoa1,avtoa2,BRT,pos(1:2));
%     bstat{1,2,dno}= detstat; bstat{2,2,dno}=PrLoc ;bstat{3,2,dno}= accPerc;bstat{4,2,dno}= predAcc;bstat{5,2,dno}= noOfSamples;
    
    ID='347C000000FFBFF';%india
%     ID='34707564BF81FE0';%india
    pos=[13.036,77.5124,930];BRT=50;
%     pos=[13.723,80.324,0];BRT=50;
    refFreq = 406.064000e6;
%     refFreq = 406.039958e6;
    [Hb,detstat]=analyzeBdata(ID,pos,refFreq,BRT,bID_b,foa,foff,toa,CNR,antNo,SIDa,pXYZ,vXYZ);  
    [PrLoc,accPerc,predAcc,noOfSamples,Hs]=solStat(ID,bID_s,noP,noB,lat,lon,locerr,EHE,solMethod,avtoa1,avtoa2,BRT,pos(1:2));
     bstat{1,1,dno}= detstat; bstat{2,1,dno}=PrLoc ;bstat{3,1,dno}= accPerc;bstat{4,1,dno}= predAcc;bstat{5,1,dno}= noOfSamples;
    
    ch=Chapter(char(coldate));    
    s1=Section('Probability of Detection');
    add(s1,Figure(Hb(26)))
    add(ch,s1)
    s2=Section('CNR and look angles');
    for kk=5:11
        add(s2,Figure(Hb(kk)))
    end    
    add(ch,s2)
    s3=Section('FOA error');
    for kk=1:4
        add(s3,Figure(Hb(kk)))
    end
    add(ch,s3)
    s4=Section('FDOA error');
    for kk = 13:2:25
        add(s4,Figure(Hb(kk)))
    end  
    add(ch,s4)
    s5=Section('TDOA error');
    for kk = 12:2:24
        add(s5,Figure(Hb(kk)))
    end  
    add(ch,s5)
    
    s6=Section('Probability of Location');
    add(s6,Figure(Hs(2)))
    add(ch,s6)
    s7=Section('Solution Accuracy and Error Prediction Accuracy');
    add(s7,Figure(Hs(1)))
    add(ch,s7)
    s8=Section('Location Error Cumulative Distribution');
    add(s8,Figure(Hs(3)))
    add(s8,Figure(Hs(4)))
    add(ch,s8)
    s9=Section('Scatter Plot');
    add(s9,Figure(Hs(5)))
    add(s9,Figure(Hs(6)))
    add(ch,s9)
    
    add(R1,ch)    
    close(Hb)
    close(Hs)
    
    
    ID = '3ADEA2223F81FE0';%uae
    pos=[24.431,54.448,5];BRT=50;
    refFreq = 406.043000e6;
    [Hb,detstat]=analyzeBdata(ID,pos,refFreq,BRT,bID_b,foa,foff,toa,CNR,antNo,SIDa,pXYZ,vXYZ);  
    [PrLoc,accPerc,predAcc,noOfSamples,Hs]=solStat(ID,bID_s,noP,noB,lat,lon,locerr,EHE,solMethod,avtoa1,avtoa2,BRT,pos(1:2));
    bstat{1,2,dno}= detstat; bstat{2,2,dno}=PrLoc ;bstat{3,2,dno}= accPerc;bstat{4,2,dno}= predAcc;bstat{5,2,dno}= noOfSamples;
    
    ch=Chapter(char(coldate));    
    s1=Section('Probability of Detection');
    add(s1,Figure(Hb(26)))
    add(ch,s1)
    s2=Section('CNR and look angles');
    for kk=5:11
        add(s2,Figure(Hb(kk)))
    end    
    add(ch,s2)
    s3=Section('FOA error');
    for kk=1:4
        add(s3,Figure(Hb(kk)))
    end
    add(ch,s3)
    s4=Section('FDOA error');
    for kk = 13:2:25
        add(s4,Figure(Hb(kk)))
    end  
    add(ch,s4)
    s5=Section('TDOA error');
    for kk = 12:2:24
        add(s5,Figure(Hb(kk)))
    end  
    add(ch,s5)
    s6=Section('Probability of Location');
    add(s6,Figure(Hs(2)))
    add(ch,s6)
    s7=Section('Solution Accuracy and Error Prediction Accuracy');
    add(s7,Figure(Hs(1)))
    add(ch,s7)
    s8=Section('Location Error Cumulative Distribution');
    add(s8,Figure(Hs(3)))
    add(s8,Figure(Hs(4)))
    add(ch,s8)
    s9=Section('Scatter Plot');
    add(s9,Figure(Hs(5)))
    add(s9,Figure(Hs(6)))
    add(ch,s9)
    
    add(R2,ch)    
    close(Hb)
    close(Hs)
    
    ID = '467C000002FFBFF';%Singapore
    pos=[1.3771,103.9881,10];BRT=50;
    refFreq = 406.064000e6;
    [Hb,detstat]=analyzeBdata(ID,pos,refFreq,BRT,bID_b,foa,foff,toa,CNR,antNo,SIDa,pXYZ,vXYZ);  
    [PrLoc,accPerc,predAcc,noOfSamples,Hs]=solStat(ID,bID_s,noP,noB,lat,lon,locerr,EHE,solMethod,avtoa1,avtoa2,BRT,pos(1:2));
    bstat{1,3,dno}= detstat; bstat{2,3,dno}=PrLoc ;bstat{3,3,dno}= accPerc;bstat{4,3,dno}= predAcc;bstat{5,3,dno}= noOfSamples;
    
    ch=Chapter(char(coldate));    
    s1=Section('Probability of Detection');
    add(s1,Figure(Hb(26)))
    add(ch,s1)
    s2=Section('CNR and look angles');
    for kk=5:11
        add(s2,Figure(Hb(kk)))
    end    
    add(ch,s2)
    s3=Section('FOA error');
    for kk=1:4
        add(s3,Figure(Hb(kk)))
    end
    add(ch,s3)
    s4=Section('FDOA error');
    for kk = 13:2:25
        add(s4,Figure(Hb(kk)))
    end  
    add(ch,s4)
    s5=Section('TDOA error');
    for kk = 12:2:24
        add(s5,Figure(Hb(kk)))
    end  
    add(ch,s5)
    s6=Section('Probability of Location');
    add(s6,Figure(Hs(2)))
    add(ch,s6)
    s7=Section('Solution Accuracy and Error Prediction Accuracy');
    add(s7,Figure(Hs(1)))
    add(ch,s7)
    s8=Section('Location Error Cumulative Distribution');
    add(s8,Figure(Hs(3)))
    add(s8,Figure(Hs(4)))
    add(ch,s8)
    s9=Section('Scatter Plot');
    add(s9,Figure(Hs(5)))
    add(s9,Figure(Hs(6)))
    add(ch,s9)
    
    add(R3,ch)    
    close(Hb)
    close(Hs)

end

cc(1,1:12)={'Date';'Detection Prob';'Loc Prob(Single)';'Loc Prob(Multi)';'AE<5km(single)';'AE<10km(single)';'AE<5km(Multi)';'AE<10km(Multi)';'AE/EHE<0.1';'AE/EHE<1';'AE/EHE>2';'Anomaly'};

j=1;
a=0;b=0;c=0;d=0;e=0;
for dno= 1:noOfDays
    coldate = startDate+(dno-1);
    coldate.Format='dd-MMM-yy';
    cc(1+dno,1)={char(coldate)};
    noOfSamples = bstat{5,j,dno};
    detstat=bstat{1,j,dno};
    a=a+detstat*noOfSamples(2);
    PrLoc=bstat{2,j,dno};
    b=b+PrLoc.*noOfSamples;
    accPerc=bstat{3,j,dno};
    c=c+accPerc.*noOfSamples;
    predAcc=bstat{4,j,dno};
    d=d+predAcc.*noOfSamples;
    e= e+noOfSamples;
    cc(1+dno,2)={num2str(detstat,'%05.3f')};
    cc(1+dno,3)={num2str(PrLoc(1),'%04.2f')};
    cc(1+dno,4)={num2str(PrLoc(2),'%04.2f')};
    cc(1+dno,5)={num2str(accPerc(1,1),'%04.2f')};
    cc(1+dno,6)={num2str(accPerc(1,2),'%04.2f')};
    cc(1+dno,7)={num2str(accPerc(2,1),'%04.2f')};
    cc(1+dno,8)={num2str(accPerc(2,2),'%04.2f')};
    cc(1+dno,9)={num2str(predAcc(1,2),'%04.2f')};
    cc(1+dno,10)={num2str(predAcc(1,1),'%04.2f')};
    cc(1+dno,11)={num2str(predAcc(1,3),'%04.2f')};
    cc(1+dno,12)={'-'};
end
totalSamples = e;
a=a/totalSamples(2);
b=b./totalSamples;
c=c./totalSamples;
d=d./totalSamples;

cc(2+dno,1)={'Overall'};
cc(2+dno,2)={num2str(a,'%05.3f')};
cc(2+dno,3)={num2str(b(1),'%04.2f')};
cc(2+dno,4)={num2str(b(2),'%04.2f')};
cc(2+dno,5)={num2str(c(1,1),'%04.2f')};
cc(2+dno,6)={num2str(c(1,2),'%04.2f')};
cc(2+dno,7)={num2str(c(2,1),'%04.2f')};
cc(2+dno,8)={num2str(c(2,2),'%04.2f')};
cc(2+dno,9)={num2str(d(1,2),'%04.2f')};
cc(2+dno,10)={num2str(d(1,1),'%04.2f')};
cc(2+dno,11)={num2str(d(1,3),'%04.2f')};
cc(2+dno,12)={'-'};

tb0=BaseTable(cc);
ch0=Chapter('Summary');
s00=Section('At a glance');
add(s00,tb0)
add(ch0,s00)
add(R1,ch0)
close(R1)

j=2;
a=0;b=0;c=0;d=0;e=0;
for dno= 1:noOfDays
    coldate = startDate+(dno-1);
    coldate.Format='dd-MMM-yy';
    cc(1+dno,1)={char(coldate)};
    noOfSamples = bstat{5,j,dno};
    detstat=bstat{1,j,dno};
    a=a+detstat*noOfSamples(2);
    PrLoc=bstat{2,j,dno};
    b=b+PrLoc.*noOfSamples;
    accPerc=bstat{3,j,dno};
    c=c+accPerc.*noOfSamples;
    predAcc=bstat{4,j,dno};
    d=d+predAcc.*noOfSamples;
    e= e+noOfSamples;
    cc(1+dno,2)={num2str(detstat,'%05.3f')};
    cc(1+dno,3)={num2str(PrLoc(1),'%04.2f')};
    cc(1+dno,4)={num2str(PrLoc(2),'%04.2f')};
    cc(1+dno,5)={num2str(accPerc(1,1),'%04.2f')};
    cc(1+dno,6)={num2str(accPerc(1,2),'%04.2f')};
    cc(1+dno,7)={num2str(accPerc(2,1),'%04.2f')};
    cc(1+dno,8)={num2str(accPerc(2,2),'%04.2f')};
    cc(1+dno,9)={num2str(predAcc(1,2),'%04.2f')};
    cc(1+dno,10)={num2str(predAcc(1,1),'%04.2f')};
    cc(1+dno,11)={num2str(predAcc(1,3),'%04.2f')};
    cc(1+dno,12)={'-'};
end
totalSamples = e;
a=a/totalSamples(2);
b=b./totalSamples;
c=c./totalSamples;
d=d./totalSamples;

cc(2+dno,1)={'Overall'};
cc(2+dno,2)={num2str(a,'%05.3f')};
cc(2+dno,3)={num2str(b(1),'%04.2f')};
cc(2+dno,4)={num2str(b(2),'%04.2f')};
cc(2+dno,5)={num2str(c(1,1),'%04.2f')};
cc(2+dno,6)={num2str(c(1,2),'%04.2f')};
cc(2+dno,7)={num2str(c(2,1),'%04.2f')};
cc(2+dno,8)={num2str(c(2,2),'%04.2f')};
cc(2+dno,9)={num2str(d(1,2),'%04.2f')};
cc(2+dno,10)={num2str(d(1,1),'%04.2f')};
cc(2+dno,11)={num2str(d(1,3),'%04.2f')};
cc(2+dno,12)={'-'};

tb0=BaseTable(cc);
ch0=Chapter('Summary');
s00=Section('At a glance');
add(s00,tb0)
add(ch0,s00)
add(R2,ch0)
close(R2)

j=3;
a=0;b=0;c=0;d=0;e=0;
for dno= 1:noOfDays
    coldate = startDate+(dno-1);
    coldate.Format='dd-MMM-yy';
    cc(1+dno,1)={char(coldate)};
    noOfSamples = bstat{5,j,dno};
    detstat=bstat{1,j,dno};
    a=a+detstat*noOfSamples(2);
    PrLoc=bstat{2,j,dno};
    b=b+PrLoc.*noOfSamples;
    accPerc=bstat{3,j,dno};
    c=c+accPerc.*noOfSamples;
    predAcc=bstat{4,j,dno};
    d=d+predAcc.*noOfSamples;
    e= e+noOfSamples;
    cc(1+dno,2)={num2str(detstat,'%05.3f')};
    cc(1+dno,3)={num2str(PrLoc(1),'%04.2f')};
    cc(1+dno,4)={num2str(PrLoc(2),'%04.2f')};
    cc(1+dno,5)={num2str(accPerc(1,1),'%04.2f')};
    cc(1+dno,6)={num2str(accPerc(1,2),'%04.2f')};
    cc(1+dno,7)={num2str(accPerc(2,1),'%04.2f')};
    cc(1+dno,8)={num2str(accPerc(2,2),'%04.2f')};
    cc(1+dno,9)={num2str(predAcc(1,2),'%04.2f')};
    cc(1+dno,10)={num2str(predAcc(1,1),'%04.2f')};
    cc(1+dno,11)={num2str(predAcc(1,3),'%04.2f')};
    cc(1+dno,12)={'-'};
end
totalSamples = e;
a=a/totalSamples(2);
b=b./totalSamples;
c=c./totalSamples;
d=d./totalSamples;

cc(2+dno,1)={'Overall'};
cc(2+dno,2)={num2str(a,'%05.3f')};
cc(2+dno,3)={num2str(b(1),'%04.2f')};
cc(2+dno,4)={num2str(b(2),'%04.2f')};
cc(2+dno,5)={num2str(c(1,1),'%04.2f')};
cc(2+dno,6)={num2str(c(1,2),'%04.2f')};
cc(2+dno,7)={num2str(c(2,1),'%04.2f')};
cc(2+dno,8)={num2str(c(2,2),'%04.2f')};
cc(2+dno,9)={num2str(d(1,2),'%04.2f')};
cc(2+dno,10)={num2str(d(1,1),'%04.2f')};
cc(2+dno,11)={num2str(d(1,3),'%04.2f')};
cc(2+dno,12)={'-'};

tb0=BaseTable(cc);
ch0=Chapter('Summary');
s00=Section('At a glance');
add(s00,tb0)
add(ch0,s00)
add(R3,ch0)
close(R3)

rptview(R1)
rptview(R2)
rptview(R3)