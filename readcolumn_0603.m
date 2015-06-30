%variable difination
FUC=1.073;
INTERCEPT=1024.3;
SLOP=1.2882;
loca=0;
CSA=9.892; %cm2;
Hscale=sqrt(CSA/pix_num)
format long
%Read pixel value,calculate rou & E matrix
pix_num=0;
rou_sum=0;

for i=1:192
    for j=1:192
        pixel(i,j) = X(i,j,1);
        rou(i,j)=(double(FUC)*(double(255)*double(pixel(i,j))-double(INTERCEPT)))/double(SLOP);%g/cm3
        E(i,j)=double(10.5)*(double((1e-3))*double(rou(i,j)))^2.57;
        if(pixel(i,j)>4)         
            rou_sum=double(rou_sum)+double(rou(i,j));
        end
    end
end
for i=1:192
    for j=1:192
        pixel(i,j) = X(i,j,1);
        if(pixel(i,j)>0)
            pix_num=pix_num+1;            
        end
    end
end
pix_num
rou_sum
averou=rou_sum/pix_num
loca=0;
min=1e20;

%Search balance line
for banl=2:191
    up=0;
    down=0;
    %calculate EA above balance line
    
    for i=1:(banl-1)
        for x=1:192
            if(double(pixel(i,x))>4)
                %temp=pixel(i,x);
                up = (double(up) + double(double(E(i,x))*double(Hscale^2)));
            end
        end
    end
    %calculate EA below balance line
    for i=banl:192
        for x=1:192
            if(double(pixel(i,x))>4)
                %temp=pixel(i,x);
                down=(double(down) + double(double(E(i,x))*double(Hscale^2)));
            end
        end
    end
    diff=(double(up)-double(down));
    diff_abs=abs(diff);
    %search balance line with minimun difference between up and below EA
    if (diff_abs<min)
        min=diff_abs;
        min_sign=diff;
        loca=banl;
    end
end
loca
%ban_val=0;
%for i=1:192
%    ban_val=ban_val+double(pixel(loca,i));
%end

%ban_adjust=min_sign/ban_val;

%loca_out=loca+ban_adjust;
%loca_out

%rou=double(rou_up)+double(rou_down);

EI_up=0;
I_up=0;
for row=1:(loca-1)
    for i=1:192
        if(y(row,i)>4)
            EI_up=double(EI_up)+double(10.5)*((double((1e-3))*double(rou(row,i)))^2.57)*((((loca-row)-1)*Hscale + Hscale/2)^2)*(Hscale^2);
            I_up=double(I_up)+double(((((loca-row)-1)*Hscale + Hscale/2)^2)*(Hscale^2));
        end
    end
end

EI_down=0;
I_down=0;
for row=loca:192
    for i=1:192
        if(y(row,i)>4)
            EI_down=double(EI_down)+double(10.5)*((double((1e-3))*double(rou(row,i)))^2.57)*((((loca-row)-1)*Hscale + Hscale/2)^2)*(Hscale^2);
            I_down=double(I_down)+double(((((loca-row)-1)*Hscale + Hscale/2)^2)*(Hscale^2));
        end
    end
end

EI=EI_up+EI_down;
I=I_up+I_down;
I
EI







