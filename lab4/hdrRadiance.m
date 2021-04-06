function hdr = hdrRadiance(loadManager ,g,w)   
    row = 716;
    col = 502;
    channels = 3;
    number = 16;
    ln_E = zeros(row,col,channels);
    ln_t = log(loadManager.obt);
    for channel = 1:3
        for i = 1:row
            for j = 1:col
               lnE = 0.0;
               W = 0.0;
               for n = 1:number
                   Z = double(loadManager.img{n}(i,j,channel)+1);
                   t_g = double(g{channel}(Z));
                   t_w = double(w(Z));
                   tln_t = ln_t(n);
                   
                   lnE = lnE + t_w * (t_g-tln_t);
                   W = W + t_w;
               end
               ln_E(i,j,channel) = lnE/W;
            end        
        end
    end
    
    hdr = exp(ln_E);
end
