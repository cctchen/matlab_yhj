%variable difination
FUC=1.073;
INTERCEPT=-1024.6;
SLOP=1.2926;
loca=0;
CSA=19.586; %cm2;
Hscale=sqrt(CSA/pix_num)
format long
%Read pixel value,calculate rou & E matrix
pix_num=0;
pixel_sum=0;
rou_sum=0;
ave_rou=245.1
for i=1:192
    for j=1:192
        pixel(i,j) = X(i,j,1);
        if(pixel(i,j)>0)
            pix_num=pix_num+1;
            pixel_sum=double(pixel_sum)+double(pixel(i,j));
        end
    end
end
pix_num
loca=0;
min=1e20;

ave_pix=double(pixel_sum)/double(pix_num);

for i=1:192
    for j=1:192
        rou(i,j)=double(ave_rou)*double(pixel(i,j))/double(ave_pix);
        E(i,j)=double(10.5)*double(rou(i,j))^2.57;
    end
end

%Search balance line
for banl=2:191
    up=0;
    down=0;
    %calculate EA above balance line
    
    for i=1:(banl-1)
        for x=1:192
            if(double(pixel(i,x))>0)
                %temp=pixel(i,x);
                up = (double(up) + double(double(E(i,x))*double(Hscale^2)));
            end
        end
    end
    %calculate EA below balance line
    for i=banl:192
        for x=1:192
            if(double(pixel(i,x))>0)
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
EI_up=0;
for row=1:(loca-1)
    for i=1:192
        if(y(row,i)>0)
            EI_up=double(EI_up)+double(10.5)*((double(rou(row,i)))^2.57)*((((loca-row)-1)*Hscale + Hscale/2)^2)*(Hscale^2);
        end
    end
end

EI_down=0;
for row=loca:192
    for i=1:192
        if(y(row,i)>0)
            EI_down=double(EI_down)+double(10.5)*((double(rou(row,i)))^2.57)*((((loca-row)-1)*Hscale + Hscale/2)^2)*(Hscale^2);
        end
    end
end

EI=EI_up+EI_down;
EI










