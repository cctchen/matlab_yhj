clear; clc; close all;

FUC=1.073;
INTERCEPT=-1024.3;
SLOP=1.2882;
loca=0;
Pthreshold=50;
mu=0.3;
pixel_A = (0.48828*0.001)^2;
pixel_scale=0.48828*0.001;
%CSA=9.892; %cm2;
path = 'D:\work\mechanical\project_for_graduate\matlab\mycode\data\';
[TMP,CSV_NAME]=xlsread([path '\hipdata_0629.csv'],'D:D');
CSV_CSA=xlsread([path '\hipdata_0629.csv'],'FP:FP');
CSMI_inplane=xlsread([path '\hipdata_0629.csv'],'FX:FX');
CSMI_outplane=xlsread([path '\hipdata_0629.csv'],'FY:FY');
SM_inplane=xlsread([path '\hipdata_0629.csv'],'GA:GA');
[status,list]=system(['dir ' path '*FN.dcm /S/B']);

filelist = strsplit(list);
filelist(strcmp(filelist,''))=[];

[file_temp,filenumber]=size(filelist);

EA(filenumber)=0;
GA(filenumber)=0;
EIx(filenumber)=0;
EIy(filenumber)=0;

for FN=1:filenumber
    pixel = dicomread(filelist{FN});

    rou=(double(FUC).*(double(pixel)))./double(SLOP);
    E=double(10.5).*(double((1e-3)).*double(rou)).^2.57.*1.0e9;
   
    EA(FN)=sum(sum(double(E).*pixel_A));
    GA(FN)=EA(FN)./(2*(1+mu));
    
    [nn,mm] = find(pixel>0);
    %pixel(nn,mm) = pixel(mm,nn) + 1024;% wrong!!!! add into none o??????
    x_c = (max(nn) + min(nn))/2.;
    y_c = (max(mm) + min(mm))/2.;
    [pp,qq] = size(pixel);
    [coord_x,coord_y] = meshgrid(1:pp,1:qq);
    pixel_x = E.*((double(coord_x)' - x_c).*pixel_scale).^2.*pixel_A;
    pixel_y = E.*((double(coord_y)' - y_c).*pixel_scale).^2.*pixel_A;
    EIx(FN) = sum(sum(pixel_x));
    EIy(FN) = sum(sum(pixel_y));
 end

[r1,p1]=corr(CSMI_inplane,EIx')
[r2,p2]=corr(CSMI_outplane,EIy')
[r3,p3]=corr(CSV_CSA,EA')
[r4,p4]=corr(CSV_CSA,GA')






