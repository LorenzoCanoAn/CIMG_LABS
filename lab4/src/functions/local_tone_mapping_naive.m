function [I] = local_tone_mapping_naive(Lw, dR)
% This function just applies the contrast reduction opperator of the local
% tone mapping function, but it applies it to the luminance as it is, so
% the base and the detail layers are not separated.

if ~exist("dR","var")
    dR = 5;
end
mkdir("lm");

%% Obtain intensity
hsv_space = rgb2hsv(Lw);
luminance = hsv_space(:,:,3);
log_luminance = log(luminance);

%% Apply contrast reduction to the intensity.
o = max(log_luminance,[],'all');
s = dR/(o-min(log_luminance,[],'all'));
log_luminance_corr = (log_luminance - o)*s;
corr_luminance = exp(log_luminance_corr);

filename=strcat("naiveLuminance_dr",num2str(dR));
imwrite(imadjust(corr_luminance,[],[],0.5),strcat("lm/",filename,".jpg"))

%% Recombine luminance with colors
hsv_space(:,:,3)=corr_luminance;
I = hsv2rgb(hsv_space);

filename=strcat("NAIVE_dr",num2str(dR));
imwrite(imadjust(I,[],[],0.5),strcat("lm/",filename,".jpg"))
end

