function hsl = hsv2hsl(hsv_in)
    H = hsv_in(:,:,1);
    V = hsv_in(:,:,3);
    Sv = hsv_in(:,:,2);
    
    
    L = V.*(1-Sv/2);

    Sl = (V-L)./min(L,1-L);
    Sl(or(L==0,L==1)) = 0;
    
    hsl = [H, Sl, L];
    hsl=reshape(hsl, size(hsv_in));
end