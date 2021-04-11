function [Ld] = global_tone_mapping(Lw, delta, a, Lwhite)

%% Check parameters
if ~exist("delta","var")
    delta = 0.001;
end
if ~exist("a","var")
    a = 0.25;
end
if ~exist("Lwhite","var")
    Lwhite = inf;
end

%% Obtain intensity
hsv_space = rgb2hsv(Lw);

luminancy = hsv_space(:,:,3);

%% Reduce contrast of intensity

Lwavg = exp(mean(log(delta+luminancy),'all'));
L = a/Lwavg * luminancy;
L = L.*(1+L/Lwhite^2)./(1+L);

hsv_space(:,:,3)=L;
%% Apply new contrast to image

Ld = hsv2rgb(hsv_space);
Ld(Ld>1)=1;
end

