function archiveBdata(msgno,tmstamps,id,msgs,CNRs,SIDs,pdf1errs,pdf2errs,brates,ants,sInfo,wHnd)
% msgno is a serial no
% tmstamps is the datetime array of the packet logging time of various channels
% id is the common 15HEXID derived from the HEX messages(decoded form)
% msgs is the array of 36HEX representation of the message packets received through various channels(undecoded form)
% CNRs is the array of CNR values for various channels
% SIDs is an array containing SatelliteIDs for various antenna channels
% pdf1errs is an array containing no of errors ocurred in PDF-1 field of various packets
% pdf2errs is an array containing no of errors ocurred in PDF-2 field of various packets
% brates is an array containing the estimated bitrates of various packets
% ants is the indices of the detected antenna channels(1 to 7)
% sInfo is a structure containing some additional parameters that is
% computed during solution process(other than loc and err) and will be
% useful for filling up some fields of BeaconBurstData and Solution  data
% for commissioning purpose
% wHnd is the filewriter handle for archiving the data in a text file
LUTID='4195';
fields=cell(1,20);
for i=1:length(ants)
    fields{1}=[num2str(msgno),','];
    hexmsg=msgs{i};
    if length(hexmsg)<36
        hexmsg=['00000000',hexmsg];
    end
    fields{2} =[hexmsg,','];
    fields{3} =[id,','];
    fields{4} = [tmstamps{i},','];
    fields{5} = [num2str(sInfo.upFOA(i),'%013.3f'),','];
    fields{6} = [num2str(sInfo.foff(i),'%+010.3f'),','];
    upTOA = sInfo.upTOA(i);
    upTOA.Format = 'yyyy-MM-dd HH:mm:ss.SSSSSSSSS';
    fields{7} = [char(upTOA),','];
    fields{8} = [num2str(sInfo.toff(i),'%011.9f'),','];
    fields{9} = [num2str(CNRs(i),'%04.1f'),','];
    fields{10} = [brates{i},','];
    fields{11} = [strcat(LUTID,'0',num2str(ants(i))),','];
    fields{12} = [num2str(SIDs(i)),','];
    pxyz=sInfo.satPos(:,i);
    fields{13} = [num2str(pxyz(1),'%+011.4f'),','];
    fields{14} = [num2str(pxyz(2),'%+011.4f'),','];
    fields{15} = [num2str(pxyz(3),'%+011.4f'),','];
    vxyz=sInfo.satVel(:,i);
    fields{16} = [num2str(vxyz(1),'%+011.6f'),','];
    fields{17} = [num2str(vxyz(2),'%+011.6f'),','];
    fields{18} = [num2str(vxyz(3),'%+011.6f'),','];
    fields{19} = [pdf1errs{i},','];
    fields{20} = pdf2errs{i};
    
    wHnd.write(strcat(fields{1:20}));
    msgno=msgno+1;
end
end

