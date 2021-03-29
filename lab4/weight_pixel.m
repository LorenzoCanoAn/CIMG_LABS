function [w] = weight_pixel(z)
    z_avg = 1/2 *(256+1);
    if z <= z_avg
        w = z;
    else
        w = 256-z;
    end
%     w = 1;
end

