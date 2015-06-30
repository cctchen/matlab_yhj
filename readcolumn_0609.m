clear;

format long


%path='D:\work\mechanical\project_for_graduate\image\new_analysis\';
%csv_file='HipData.csv';
%fnames=dir(strcat(path,'*.jpg'));
%numfinds=length(fnames);
%vals=cell(1,numfinds);


[TMP,CSV_NAME]=xlsread('D:\work\mechanical\project_for_graduate\image\new_analysis\HipData.csv','C:C');
CSV_BMD=xlsread('D:\work\mechanical\project_for_graduate\image\new_analysis\HipData.csv','J:J');

%CSV_NAME=CSV_NAME(1:end);

[r1,c1]=size(CSV_NAME);
[r2,c2]=size(CSV_BMD);

if r1 ~= r2
    disp('Name and BMD number in CSV file not match!');
    return;
end



[status,list]=system('dir D:\work\mechanical\project_for_graduate\image\new_analysis\*FN.jpg /S/B');

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
        if 1 == fn_isempty
            msgbox(strcat(CSV_NAME{i},' File name not match!'));
            return;
        end
    end
end
[file_temp,filenumber]=size(filelist_aftercheck);

for K=1:filenumber
    [X,map]=imread(filelist_aftercheck{K});
    
    %Read pixel value,calculate rou & E matrix

    pix_num(K)=0;
    pixel_sum(K)=0;

    for i=1:192
        for j=1:192
            pixel(i,j) = X(i,j,1);
            if(pixel(i,j)>0)
                pix_num(K)=pix_num(K)+1;
                pixel_sum(K)=double(pixel_sum(K))+double(pixel(i,j));
            end
        end
    end
    pix_num(K);
    ave_pix(K)=double(pixel_sum(K))/double(pix_num(K));
 
    [jpgpathstr, jpgname, jpgext] = fileparts(filelist_aftercheck{K});
    for j=1:r1
        tf=strcmp(CSV_NAME(j),jpgname);
        if tf == 1
            BMD(K)=CSV_BMD(j);
            break;
        end
    end 
end
ave_pix=ave_pix';







 



    
    

