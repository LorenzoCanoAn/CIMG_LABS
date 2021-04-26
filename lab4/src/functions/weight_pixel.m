function [w] = weight_pixel(z)
    z_avg = 1/2 *(256);
    if z <= z_avg
        w = z;
    else
        w = 256-z;
    end
end

