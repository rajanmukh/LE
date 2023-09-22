function [hexID] = decodeMsg(uchexMsg,dec1)
SHORT=0;
LONG=1;

STANDARD=1;
NATIONAL=2;
RLS=3;
ELT=4;

MAP=[0,STANDARD,STANDARD,STANDARD,STANDARD,STANDARD,STANDARD,...
    NATIONAL,ELT,NATIONAL,NATIONAL,STANDARD,RLS,STANDARD,NATIONAL];
if uchexMsg(1) == '0'
    ucmsg=uchexMsg(9:end);
else
    ucmsg=uchexMsg;
end
%extract bits
ucbits = hexToBinaryVector(ucmsg)';

pdf1=step(dec1,ucbits(24+1:24+82))';
binID = pdf1(2:61);
% binID = ucbits(26:85)';
hexID = binaryVectorToHex(binID);
if pdf1(1) == true
    type=LONG;
else
    type=SHORT;
end
if type == SHORT
    if binID(1)==true%user protocol
        pc=binaryVectorToDecimal(binID(12:14));
    end
else %LONG
    if binID(1)==true%user protocol
    else%standard protocol
        pc=binaryVectorToDecimal(binID(12:15));
        if pc>1
            ptype = MAP(pc);
        else
            ptype = STANDARD;%default value for exception
        end
        switch ptype
            case STANDARD
                p1=binaryVectorToHex(binID(1:36));
                p2=binaryVectorToHex([binID(37:39),0]);
                hexID=[p1,p2,'FFBFF'];
            case NATIONAL
                p1=binaryVectorToHex(binID(1:32));
                p2=binaryVectorToHex([binID(33),0,1,1]);
                hexID=[p1,p2,'F81FE0'];
            otherwise
                p1=binaryVectorToHex(binID(1:40));
                p2=binaryVectorToHex([binID(41),0,1,1]);
                hexID=[p1,p2,'FDFF'];
        end
    end
end
end

