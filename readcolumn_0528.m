pix_num=0;
for i=1:192
    for j=1:192
        y(i,j) = X(i,j,1);
        if(y(i,j)>0)
            pix_num=pix_num+1;
        end
    end
end
pix_num
loca=0;
min=1e20;

FUC=1.073;
INTERCEPT=-1024.3;
SLOP=1.2882;
loca=0;
CSA=9.892; %cm2;
Hscale=sqrt(CSA/pix_num)

for banl=2:191
    up=0;
    down=0;
    for i=1:(banl-1)
        for x=1:192
            temp=y(i,x);
            up = (up + double(temp));
        end
    end
    for i=banl:192
        for x=1:192
            temp=y(i,x);
            down=(down + double(temp));
        end
    end
    diff=(up-down);
    diff_abs=abs(diff);
    
    if (diff_abs<min)
        min=diff_abs;
        min_sign=diff;
        loca=banl;
    end
end
loca
%ban_val=0;
%for i=1:192
%    ban_val=ban_val+double(y(loca,i));
%end

%ban_adjust=min_sign/ban_val;

%loca_out=loca+ban_adjust;
%loca_out
rou_up=0;
for row=1:(loca-1)
    for i=1:192
        if(y(row,i)>0)
            rou=(double(FUC)*double((256*y(row,i))-double(INTERCEPT))/double(SLOP));%mg/cm3;
            rou_up=double(rou_up)+rou;
        end
    end
end

rou_down=0;
for row=loca:192
    for i=1:192
        if(y(row,i)>0)
            rou=(double(FUC)*double((256*y(row,i))-double(INTERCEPT))/double(SLOP));
            rou_down=double(rou_down)+rou;
        end
    end
end

rou=(rou_up+rou_down)/pix_num;
rou







