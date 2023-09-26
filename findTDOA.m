function [terr,ferr,t] = findTDOA(ttB,ftB,chns,i,j)
pair12=chns(:,i) & chns(:,j);
sel1=chns(pair12,i);
sel2=chns(pair12,j);
ferr=ftB(sel1)-ftB(sel2);
terr=1e6*seconds(ttB(sel1)-ttB(sel2));
t=ttB(sel1);
end

