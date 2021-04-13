function [Ld] = global_tone_mapping(Lw, delta, a, Lwhite)

%% Default value for parameters
if ~exist("delta","var")
    delta = 0.001;
end
if ~exist("a","var")
    a = 0.25;
end
if ~exist("Lwhite","var")
    Lwhite = inf;
end

%% Obtain luminance
hsv_space = rgb2hsv(Lw);
luminance = hsv_space(:,:,3);

%% Reduce contrast of the luminance
Lwavg = exp(mean(log(delta+luminance),'all'));
L = a/Lwavg * luminance;
L = L.*(1+L/Lwhite^2)./(1+L);

%% Apply new luminance to image
hsv_space(:,:,3)=L;
Ld = hsv2rgb(hsv_space);
Ld(Ld>1)=1;

end

