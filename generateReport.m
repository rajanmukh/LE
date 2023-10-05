clear
close all
import mlreportgen.report.*
import mlreportgen.dom.* 

R1=Report('India Beacon Statistics','docx');
open(R1)
tp1 = TitlePage();
tp1.Title = 'INDIA';
tp1.Author = 'ISTRAC';
add(R1,tp1)
R2=Report('UAE Beacon Statistics','docx');
open(R2)
tp2 = TitlePage();
tp2.Title = 'UAE';
tp2.Author = 'ISTRAC';
add(R2,tp2)

startDate = datetime('11-Sep-2023');
detstat = zeros(2,2);
for dno= 1:2
    coldate = startDate+(dno-1)
    filename = ['commissioning\Bdata\Log\','sit_',num2str(coldate.Year-2000),'_',num2str(coldate.Month,'%02d'),'_',num2str(coldate.Day,'%02d'),'.txt'];
    
    fbias=-13;   
    
    fileID=fopen(filename);
    dataarr=textscan(fileID,'%s%[^\n\r]','Delimiter','');
    fclose(fileID);
    lines=dataarr{1};
    clear dataarr   
    noOfLines = length(lines);
    
    bID = cell(1,noOfLines);
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
        bID{i}=fields{3};
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
    
    ID='347C000000FFBFF';%india
    pos=[13.036,77.5124,930];BRT=50;
    refFreq = 406.028000e6;
    [H,detstat(1,dno)]=analyzeBdata(ID,pos,refFreq,BRT,bID,foa,foff,toa,CNR,antNo,SIDa,pXYZ,vXYZ);    
    ch1=Chapter(char(coldate));
    s11=Section('Probability of Detection');
    add(s11,Figure(H(15)))
    add(ch1,s11)
    add(R1,ch1)
    
    close(H)
    ID = '3ADEA2223F81FE0';%uae
    pos=[24.431,54.448,5];BRT=50;
    refFreq = 406.043000e6;
    [H,detstat(2,dno)]=analyzeBdata(ID,pos,refFreq,BRT,bID,foa,foff,toa,CNR,antNo,SIDa,pXYZ,vXYZ);    
    ch2=Chapter(char(coldate));
    s21=Section('Probability of Detection');
    add(s21,Figure(H(15)))
    add(ch2,s21)
    add(R2,ch2)    
    close(H)
end
close(R1)
close(R2)
rptview(R1)
rptview(R2)