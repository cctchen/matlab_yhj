function [EA_out]=prog(p_start,p_end,P,DI,Pth,E,Pixel_scale)
    [Py,Px]=size(P);
    EA_0=0;
    for i=p_start:p_end
        for x=1:Px
            if(0==DI)
                if(double(P(i,x))> Pth)
                    EA_0 = (double(EA_0) + double(double(E(i,x))*double(Pixel_scale^2)));
                end
            else
                if(double(P(x,i))> Pth)
                    EA_0 = (double(EA_0) + double(double(E(x,i))*double(Pixel_scale^2)));
                end
            end
        end
    end
    EA_out=EA_0;
end