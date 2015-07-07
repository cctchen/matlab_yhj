clear;

FUC=1.073;
INTERCEPT=-1024.3;
SLOP=1.2882;
loca=0;
Pthreshold=0;
mu=0.3;
%pixel_A = 0.048828^2;
%Pixel_scale=0.048828;
datapath='D:\work\mechanical\project_for_graduate\matlab\mycode\data\';

[TMP,CSV_NAME]=xlsread([datapath,'hipdata_0629.csv'],'D:D');
CSV_CSA=xlsread([datapath 'hipdata_0629.csv'],'FP:FP');
CSMI_inplane=xlsread([datapath, 'hipdata_0629.csv'],'FX:FX');
SM_inplane=xlsread([datapath 'hipdata_0629.csv'],'GA:GA');
[status,list]=system(['dir ' datapath '*FN.dcm /S/B']);

filelist = strsplit(list);
[file_temp,filenumber] = size(filelist);


for i=1:filenumber
    tf=strcmp(filelist{i},'');
    %if file name is not empty, copy filelist to filelist_aftercheck,
    %0 means not empty
    if 0==tf
        filelist_aftercheck{i}=filelist{i};
        %check if file name order mach filelist
        fnm=findstr(CSV_NAME{i},filelist{i});
        fn_isempty=isempty(fnm);
        if 1 == fnm
            msgbox('File name not match!');
            return;
        end
    end
end
[file_temp,filenumber]=size(filelist_aftercheck);

for FN=1:filenumber
    filecontent = dicomread(filelist_aftercheck{FN});
    [psize_y,psize_x]=size(filecontent);
    EA(FN)=0;
    EA_p(FN)=0;
    GA(FN)=0;
    pix_num(FN)=0;
    tmp_rou=0;
    for i=1:psize_y
        for j=1:psize_x
            pixel(i,j) = filecontent(i,j);
            if(pixel(i,j) > Pthreshold)
                pix_num(FN)=pix_num(FN)+1;
                rou(i,j)=(double(FUC)*(double(pixel(i,j))-double(INTERCEPT)))/double(SLOP);%mg/cm3
                E(i,j)=double(10.5)*(double((1e-3))*double(rou(i,j)))^2.57;
                tmp_rou=tmp_rou+rou(i,j);
            else    %element less than threshold assign to 0
                pixel(i,j)=0;
            end
        end
    end
    
    [range_x,range_y]=find(pixel > Pthreshold);%find the max distance to neutral axis
    min_x(FN)=min(range_x);
    max_x(FN)=max(range_x);
    min_y(FN)=min(range_y);
    max_y(FN)=max(range_y);
    ave_rou(FN)=tmp_rou/pix_num(FN);
    Pixel_scale(FN)=sqrt(CSV_CSA(FN)/pix_num(FN));

   % tmp_rou_p=0; %projection
    project_y=sum(pixel,2); %projection along row direction
    for i=1:psize_y
        if(project_y(i) > Pthreshold)
            rou_p(i,FN)=(double(FUC)*(double(project_y(i))-double(INTERCEPT)))/double(SLOP);%mg/cm3 ????????
            E_p(i,FN)=double(29.8)*(double((1e-3))*double(rou_p(i,FN)))^1.56; %the relation between E and areal BMD
            %tmp_rou_p=tmp_rou_p+rou_p(i);
        end
    end

  
    
    for i=1:psize_y
        for j=1:psize_x
            if(pixel(i,j) > Pthreshold)
                EA(FN)=EA(FN) + double(double(E(i,j))*double(Pixel_scale(FN)^2));
             end
        end
    end
        
    GA(FN)=EA(FN)/(2*(1+mu));
    EA=EA';
    GA=GA';
    
    for i=1:psize_y
        if(project_y(i) > Pthreshold)
            EA_p(FN)=EA_p(FN) + double(double(E_p(i,FN))*double(Pixel_scale(FN)^2));
         end
    end
    GA_p(FN)=EA_p(FN)/(2*(1+mu));
    EA_p=EA_p';
    GA_p=GA_p';
    
    
    loca=0;
    Minimum=1e20;

    for banl=2:(psize_y-1)
        up=0;
        down=0;
        for i=1:(banl-1)
            for x=1:psize_x
                if(double(pixel(i,x))> Pthreshold)
                    up = (double(up) + double(double(E(i,x))*double(Pixel_scale(FN)^2)));
                end
            end
        end
        for i=banl:psize_y
            for x=1:psize_x
                if(double(pixel(i,x))> Pthreshold)
                    down=(double(down) + double(double(E(i,x))*double(Pixel_scale(FN)^2)));
                end
            end
        end
        diff=(up-down);
        diff_abs=abs(diff);

        if (diff_abs<Minimum)
            Minimum=diff_abs;
            Minimum_sign=diff;
            loca=banl;
        end
    end
    ban_axis(FN)=loca;
    d2top(FN)=ban_axis(FN)-min_y(FN)-0.5;
    d2bottom(FN)=max_y(FN)-ban_axis(FN)+0.5;   
    d_max(FN)=max(d2top(FN),d2bottom(FN));
    
    EI_up=0;
    I_up=0;
    for row=1:(ban_axis(FN)-1)
        for i=1:psize_x
            if(pixel(row,i)>Pthreshold)
                EI_up=double(EI_up)+double(10.5)*((double((1e-3))*double(rou(row,i)))^2.57)*((((ban_axis(FN)-row)-1)*Pixel_scale(FN) + Pixel_scale(FN)/2)^2)*(Pixel_scale(FN)^2);
                I_up=double(I_up)+double(((((ban_axis(FN)-row)-1)*Pixel_scale(FN) + Pixel_scale(FN)/2)^2)*(Pixel_scale(FN)^2));
            end
        end
    end

    EI_down=0;
    I_down=0;
    for row=ban_axis(FN):psize_y
        for i=1:psize_x
            if(pixel(row,i)>Pthreshold)
                EI_down=double(EI_down)+double(10.5)*((double((1e-3))*double(rou(row,i)))^2.57)*((((row-ban_axis(FN))+1)*Pixel_scale(FN) - Pixel_scale(FN)/2)^2)*(Pixel_scale(FN)^2);
                I_down=double(I_down)+double(((((row-ban_axis(FN))+1)*Pixel_scale(FN) - Pixel_scale(FN)/2)^2)*(Pixel_scale(FN)^2));
            end
        end
    end

    EI(FN)=EI_up+EI_down;
    I(FN)=I_up+I_down;
    Z_y(FN)=I(FN)/(d_max(FN)*Pixel_scale(FN));
    
    EI_p_up=0;
    I_p_up=0;
    for row=1:(ban_axis(FN)-1)
        if(project_y(row)>Pthreshold)
                EI_p_up=double(EI_p_up)+double(29.8)*((double((1e-3))*double(rou_p(row)))^1.56)*((((ban_axis(FN)-row)-1)*Pixel_scale(FN) + Pixel_scale(FN)/2)^2)*(Pixel_scale(FN)^2);
                I_p_up=double(I_p_up)+double(((((ban_axis(FN)-row)-1)*Pixel_scale(FN) + Pixel_scale(FN)/2)^2)*(Pixel_scale(FN)^2));
          end
     end
    

    EI_p_down=0;
    I_p_down=0;
    for row=ban_axis(FN):psize_y
        if(project_y(row)>Pthreshold)
                EI_p_down=double(EI_p_down)+double(29.8)*((double((1e-3))*double(rou_p(row)))^1.56)*((((row-ban_axis(FN))+1)*Pixel_scale(FN) - Pixel_scale(FN)/2)^2)*(Pixel_scale(FN)^2);
                I_p_down=double(I_p_down)+double(((((row-ban_axis(FN))+1)*Pixel_scale(FN) - Pixel_scale(FN)/2)^2)*(Pixel_scale(FN)^2));
         end
    end
    EI_p(FN)=EI_p_up+EI_p_down;
    I_p(FN)=I_p_up+I_p_down;
    Z_p_y(FN)=I_p(FN)/(d_max(FN)*Pixel_scale(FN));
      
 end
ave_rou=ave_rou';
EI=EI';
I=I';
Z_y=Z_y';
ban_axis(FN)=ban_axis(FN)';
[r1,p1]=corr(CSMI_inplane,EI)
[r2,p2]=corr(CSMI_inplane,I)
[r3,p3]=corr(CSMI_inplane,EA)
[r4,p4]=corr(CSMI_inplane,GA)
[r5,p5]=corr(SM_inplane,Z_y)
[r6,p6]=corr(EA_p,EA)
[r7,p7]=corr(EI_p,EI)
[r8,p8]=corr(I_p,I)






