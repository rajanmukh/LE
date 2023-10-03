function  scatterplot(lat,lon,refLoc)
scatter(lat,lon,5)
xlabel('latitiude')
ylabel('longitude')
hold on
scatter(refLoc(1),refLoc(2),'*')
axis equal
%draw contours
xscale=pi*6400*cos(refLoc(1)*pi/180)/180;
yscale=pi*6400/180;

r=5;
x=zeros(1,360/5+1);
y=zeros(1,360/5+1);
for a=0:5:360
    xcomp=r*cos(a*pi/180);
    ycomp=r*sin(a*pi/180);
    latd=xcomp/xscale;
    lond=ycomp/yscale;
    x(a/5+1)=refLoc(1)+latd;
    y(a/5+1)=refLoc(2)+lond;
end
p5=plot(x,y);
x5=x;
y5=y;
r=10;
x=zeros(1,360/5+1);
y=zeros(1,360/5+1);
for a=0:5:360
    xcomp=r*cos(a*pi/180);
    ycomp=r*sin(a*pi/180);
    latd=xcomp/xscale;
    lond=ycomp/yscale;
    x(a/5+1)=refLoc(1)+latd;
    y(a/5+1)=refLoc(2)+lond;
end
p10=plot(x,y);
x10=x;
y10=y;

r=20;
x=zeros(1,360/5+1);
y=zeros(1,360/5+1);
for a=0:5:360
    xcomp=r*cos(a*pi/180);
    ycomp=r*sin(a*pi/180);
    latd=xcomp/xscale;
    lond=ycomp/yscale;
    x(a/5+1)=refLoc(1)+latd;
    y(a/5+1)=refLoc(2)+lond;
end
p20=plot(x,y);
x20=x;
y20=y;
legend([p5 p10 p20],{'5 km','10 km','20 km'})
end

