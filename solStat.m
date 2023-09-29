function [PrLocS,PrLocM,prc5km,prc10km,predAcc]=solStat(id,bID,noP,noB,locerr,EHE,toa1,toa2)
    %single burst
    idx=strcmp(id,bID) & noP>2 & noB == 1;
    noOfSol = sum(idx);
    PrLocS = noOfSol/1728;
    prc5km=sum(locerr(idx)<5)/noOfSol;
    p1 = sum(locerr(idx)<EHE(idx))/noOfSol;
    p2 = sum(locerr(idx)<0.1*EHE(idx))/noOfSol;
    p3 = sum(locerr(idx)>2*EHE(idx))/noOfSol;
    predAcc = [p1,p2,p3];
    %multi burst
    idx=strcmp(id,bID) & noB > 1;
    PrLocM=sum(idx)/133;
    prc10km = sum(locerr(idx)<10)/sum(idx);
end