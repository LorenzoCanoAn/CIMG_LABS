function [w] = weight_pixel(z)
    z_avg = 1/2 *(255+0);
    if z <= z_avg
        w = z;
    else
        w = 255-z;
    end
    % w = 1;
end

