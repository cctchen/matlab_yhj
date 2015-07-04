clear;

FUC=1.073;
INTERCEPT=-1024.3;
SLOP=1.2882;
loca=0;
Pthreshold=50;
mu=0.3;
pixel_A = 0.48828^2;
Pixel_scale=0.48828;
%CSA=9.892; %cm2;

[TMP,CSV_NAME]=xlsread('D:\work\mechanical\project_for_graduate\matlab\mycode\data\hipdata_0629.csv','D:D');
CSV_CSA=xlsread('D:\work\mechanical\project_for_graduate\matlab\mycode\data\hipdata_0629.csv','FP:FP');
CSMI_inplane=xlsread('D:\work\mechanical\project_for_graduate\matlab\mycode\data\hipdata_0629.csv','FX:FX');
SM_inplane=xlsread('D:\work\mechanical\project_for_graduate\matlab\mycode\data\hipdata_0629.csv','GA:GA');
[status,list]=system('dir D:\work\mechanical\project_for_graduate\matlab\mycode\data\*FN.dcm /S/B');

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
    pixel = filecontent;
    [psize_x,psize_y]=size(filecontent);
    EA(FN)=0;
    GA(FN)=0;
    pix_num(FN)=0;
%     for i=1:psize_y
%         for j=1:psize_x
%             pixel(i,j) = filecontent(i,j);
%             if(pixel(i,j) > Pthreshold)
%                 pix_num(FN)=pix_num(FN)+1;
%                 rou(i,j)=(double(FUC)*(double(pixel(i,j))-double(INTERCEPT)))/double(SLOP);%mg/cm3
%                 E(i,j)=double(10.5)*(double((1e-3))*double(rou(i,j)))^2.57;
%              end
%         end
%     end
%rou=(double(FUC).*(double(pixel)-double(INTERCEPT)))./double(SLOP);
rou=(double(FUC).*(double(pixel)))./double(SLOP);
E=double(10.5).*(double((1e-3)).*double(rou)).^2.57;

%    Pixel_scale(FN)=sqrt(CSV_CSA(FN)/pix_num(FN));

%     for i=1:psize_y
%         for j=1:psize_x
%             if(pixel(i,j) > Pthreshold)
%                 EA(FN)=EA(FN) + double(double(E(i,j))*double(Pixel_scale(FN)^2));
%              end
%         end
%     end

EA(FN)=sum(sum(double(E).*pixel_A));

GA=EA./(2*(1+mu));
EA=EA';
GA=GA';
    
    loca=0;
    min=1e20;

    for banl=2:(psize_y-1)
        up=0;
        down=0;
        for i=1:(banl-1)
            for x=1:psize_x
                if(double(pixel(i,x))> Pthreshold)
                    up = (double(up) + double(double(E(i,x))*pixel_A));
                end
            end
        end
        for i=banl:psize_y
            for x=1:psize_x
                if(double(pixel(i,x))> Pthreshold)
                    down=(double(down) + double(double(E(i,x))*pixel_A));
                end
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
    ban_axis(FN)=loca;
    
    
    EI_up=0;
    I_up=0;
    for row=1:(ban_axis(FN)-1)
        for i=1:psize_x
            if(pixel(row,i)>4)
                EI_up=double(EI_up)+double(10.5)*((double((1e-3))*double(rou(row,i)))^2.57)*((((ban_axis(FN)-row)-1)*Pixel_scale + Pixel_scale/2)^2)*(pixel_A);
                I_up=double(I_up)+double(((((ban_axis(FN)-row)-1)*Pixel_scale +  Pixel_scale/2)^2)*(pixel_A));
            end
        end
    end

    EI_down=0;
    I_down=0;
    for row=ban_axis(FN):psize_y
        for i=1:psize_x
            if(pixel(row,i)>4)
                EI_down=double(EI_down)+double(10.5)*((double((1e-3))*double(rou(row,i)))^2.57)*((((ban_axis(FN)-row)-1)*Pixel_scale + Pixel_scale/2)^2)*(pixel_A);
                I_down=double(I_down)+double(((((ban_axis(FN)-row)-1)*Pixel_scale + Pixel_scale/2)^2)*(pixel_A));
            end
        end
    end

    EI(FN)=EI_up+EI_down;
    I(FN)=I_up+I_down;
 end

EI=EI';
I=I';
ban_axis(FN)=ban_axis(FN)';
[r,p]=corr(CSMI_inplane,EI)
[r,p]=corr(CSMI_inplane,I)
[r,p]=corr(CSMI_inplane,EA)
[r,p]=corr(CSMI_inplane,GA)






