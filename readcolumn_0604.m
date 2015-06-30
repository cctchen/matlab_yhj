pix_num=0;
pix_val=0;
for i=1:192
    for j=1:192
        y(i,j) = X(i,j,1);
        if(y(i,j)>0)
            pix_num=pix_num+1;
             temp=y(i,j);
            pix_val=double(pix_val)+double(temp);
        end
    end
end
pix_num
pix_val

%variable difination
a=6.0847;% assum rou and pixel value have the linear relation
b=-344.2230;
CSA=9.892; %cm2;
Hscale=sqrt(CSA/pix_num)
format long
%Read pixel value,calculate rou & E matrix

rou_sum=0;
for i=1:192
    for j=1:192
        pixel(i,j) = X(i,j,1);
        rou(i,j)=a*double(pixel(i,j))+b;%mg/cm3 
        E(i,j)=double(10.5)*double(double((1e-3))*double(rou(i,j)))^2.57;
        if(pixel(i,j)>57)           
            rou_sum=double(rou_sum)+double(rou(i,j));
        end
    end
end
rou_sum
averou=rou_sum/pix_num

%Search balance line
for banl=2:191
    up=0;
    down=0;
    %calculate EA above balance line
    
    for i=1:(banl-1)
        for x=1:192
            if(double(pixel(i,x))>57)
                %temp=pixel(i,x);
                up = (double(up) + double(double(E(i,x))*double(Hscale^2)));
            end
        end
    end
    %calculate EA below balance line
    for i=banl:192
        for x=1:192
            if(double(pixel(i,x))>57)
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
I_up=0;
for row=1:(loca-1)
    for i=1:192
        if(y(row,i)>57)
            EI_up=double(EI_up)+double(10.5)*((double((1e-3))*double(rou(row,i)))^2.57)*((((loca-row)-1)*Hscale + Hscale/2)^2)*(Hscale^2);
            I_up=double(I_up)+double(((((loca-row)-1)*Hscale + Hscale/2)^2)*(Hscale^2));
        end
    end
end

EI_down=0;
I_down=0;
for row=loca:192
    for i=1:192
        if(y(row,i)>57)
            EI_down=double(EI_down)+double(10.5)*((double((1e-3))*double(rou(row,i)))^2.57)*((((loca-row)-1)*Hscale + Hscale/2)^2)*(Hscale^2);
            I_down=double(I_down)+double(((((loca-row)-1)*Hscale + Hscale/2)^2)*(Hscale^2));
        end
    end
end

EI=EI_up+EI_down;
I=I_up+I_down;
I
EI