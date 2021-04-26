function hsv = hsl2hsv(hsl_in)
    H = hsl_in(:,:,1);
    L = hsl_in(:,:,3);
    Sl = hsl_in(:,:,2);

    V = L + Sl.*min(L,1-L);

    Sv = 2*(1-L./V);
    Sv(V==0) = 0;
    
    hsv = [H, Sv, V];
    hsv=reshape(hsv, size(hsl_in));
end