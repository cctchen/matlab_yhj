
    clear;
    global ban_axis_x ban_axis_y;
    
    FUC=1.073;
    INTERCEPT=-1024.3;
    SLOP=1.2882;
    Pthreshold=0;
    mu=0.3;
    %pixel_A = 0.048828^2;
    Pixel_scale=0.048828;
    datapath='D:\work\mechanical\project_for_graduate\matlab\mycode\data\';
    %datapath='D:\CODE\yhjmatlab\matlab_yhj\data\';

    [TMP,CSV_NAME]=xlsread([datapath,'hipdb_0709.csv'],'D:D');
    CSV_CSA=xlsread([datapath 'hipdb_0709.csv'],'FP:FP');
    CSMI_inplane=xlsread([datapath, 'hipdb_0709.csv'],'FX:FX');
    CSMI_outplane=xlsread([datapath 'hipdb_0709.csv'],'FY:FY');
    SM_inplane=xlsread([datapath 'hipdb_0709.csv'],'GA:GA');
    SM_outplane=xlsread([datapath 'hipdb_0709.csv'],'GB:GB');
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
        pixel = dicomread(filelist_aftercheck{FN});
        [psize_y,psize_x]=size(pixel);
        EA(FN)=0;
        GA(FN)=0;
        pix_num(FN)=nnz(pixel>Pthreshold);
        tmp_rou=0;
        for i=1:psize_y
            for j=1:psize_x
                if(pixel(i,j) > Pthreshold)
                    rou(i,j)=(double(FUC)*(double(pixel(i,j))-double(INTERCEPT)))/double(SLOP);%mg/cm3
                    E(i,j)=double(10.5)*(double((1e-3))*double(rou(i,j)))^2.57;
                    EA(FN)=EA(FN) + double(double(E(i,j))*double(Pixel_scale^2));
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
        %ave_rou(FN)=sum(sum(rou))/pix_num(FN);
        %Pixel_scale(FN)=sqrt(CSV_CSA(FN)/pix_num(FN));

        GA(FN)=EA(FN)/(2*(1+mu));

        Neu_x=0;
        Neu_y=0;
        
        %x direction
        Minimum=Inf;
        for banl=2:(psize_y-1)
            up=cal_EA(1,(banl-1),pixel,0,Pthreshold,E,Pixel_scale);
            down=cal_EA(banl,psize_y,pixel,0,Pthreshold,E,Pixel_scale);
            diff_abs=abs((up-down));

            if (diff_abs<Minimum)
                Minimum=diff_abs;
                Neu_x=banl;
            end
        end
     
        ban_axis_x(FN)=Neu_x;
        d2top(FN)=ban_axis_x(FN)-min_y(FN)-0.5;
        d2bottom(FN)=max_y(FN)-ban_axis_x(FN)+0.5;   
        dx_max(FN)=max(d2top(FN),d2bottom(FN));

        EI_up=0;
        I_up=0;
        for row=1:(ban_axis_x(FN)-1)
            for i=1:psize_x
                if(pixel(row,i)>Pthreshold)
                    EI_up=double(EI_up)+double(10.5)*((double((1e-3))*double(rou(row,i)))^2.57)*((((ban_axis_x(FN)-row)-1)*Pixel_scale + Pixel_scale/2)^2)*(Pixel_scale^2);
                    I_up=double(I_up)+double(((((ban_axis_x(FN)-row)-1)*Pixel_scale + Pixel_scale/2)^2)*(Pixel_scale^2));
                end
            end
        end

        EI_down=0;
        I_down=0;
        for row=ban_axis_x(FN):psize_y
            for i=1:psize_x
                if(pixel(row,i)>Pthreshold)
                    EI_down=double(EI_down)+double(10.5)*((double((1e-3))*double(rou(row,i)))^2.57)*((((row-ban_axis_x(FN))+1)*Pixel_scale - Pixel_scale/2)^2)*(Pixel_scale^2);
                    I_down=double(I_down)+double(((((row-ban_axis_x(FN))+1)*Pixel_scale - Pixel_scale/2)^2)*(Pixel_scale^2));
                end
            end
        end

    
        %y direction
        Minimum=Inf;
        for banl=2:(psize_x-1)
            left=cal_EA(1,(banl-1),pixel,1,Pthreshold,E,Pixel_scale);
            right=cal_EA(banl,psize_y,pixel,1,Pthreshold,E,Pixel_scale);
            diff_abs=abs((left-right));

            if (diff_abs<Minimum)
                Minimum=diff_abs;
                Neu_y=banl;
            end
        end     

        ban_axis_y(FN)=Neu_y;
        d2left(FN)=ban_axis_y(FN)-min_y(FN)-0.5;
        d2right(FN)=max_y(FN)-ban_axis_y(FN)+0.5;   
        dy_max(FN)=max(d2left(FN),d2right(FN));

        EI_left=0;
        I_left=0;
        for col=1:(ban_axis_y(FN)-1)
            for i=1:psize_y
                if(pixel(i,col)>Pthreshold)
                    EI_left=double(EI_left)+double(10.5)*((double((1e-3))*double(rou(i,col)))^2.57)*((((ban_axis_y(FN)-col)-1)*Pixel_scale + Pixel_scale/2)^2)*(Pixel_scale^2);
                    I_left=double(I_left)+double(((((ban_axis_y(FN)-col)-1)*Pixel_scale + Pixel_scale/2)^2)*(Pixel_scale^2));
                end
            end
        end

        EI_right=0;
        I_right=0;
        for col=ban_axis_y(FN):psize_x
            for i=1:psize_y
                if(pixel(i,col)>Pthreshold)
                    EI_right=double(EI_right)+double(10.5)*((double((1e-3))*double(rou(i,col)))^2.57)*((((col-ban_axis_y(FN))+1)*Pixel_scale - Pixel_scale/2)^2)*(Pixel_scale^2);
                    I_right=double(I_right)+double(((((col-ban_axis_y(FN))+1)*Pixel_scale - Pixel_scale/2)^2)*(Pixel_scale^2));
                end
            end
        end

        EI_y(FN)=EI_left+EI_right;
        I_y(FN)=I_left+I_right;
        Z_y(FN)=I_y(FN)/(dy_max(FN)*Pixel_scale);
   
    end
    ave_rou=ave_rou';
    EI_x=EI_x';
    EI_y=EI_y';
    I_x=I_x';
    I_y=I_y';
    Z_x=Z_x';
    Z_y=Z_y';
    EA=EA';
    GA=GA';

    ban_axis_x(FN)=ban_axis_x(FN)';
    [r_EIx,p_EIx]=corr(CSMI_inplane,EI_x)
    [r_EIy,p_EIy]=corr( CSMI_outplane,EI_y)
    [r_Zx,p_Zx]=corr(SM_inplane,Z_x)
    [r_Zy,p_Zy]=corr(SM_outplane,Z_y)
    [r_Ix,p_Ix]=corr(CSMI_inplane,I_x)
    [r_Iy,p_Iy]=corr( CSMI_outplane,I_y)
    [r_EA,p_EA]=corr(CSV_CSA,EA)
    
    










