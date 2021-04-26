function [I] = local_tone_mapping(Lw, filter_radius, filter_sigma, dR)
% This function implements the local tone mapping described in the paper
% from Fredo Durand and Julie Dorsey.
%% Default values for the parameters
if ~exist("filter_radius","var")
    imageSize = size(Lw);
    filter_radius = ceil(sqrt(imageSize(1)*imageSize(2))*0.02);
end
if ~exist("filter_sigma","var")
    filter_sigma = 0.4;
end
if ~exist("dR","var")
    dR = 5;
end
mkdir("lm");

%% Obtain luminance.
hsv_space = rgb2hsv(Lw);
luminance = hsv_space(:,:,3);

filename=strcat("luminance_s",num2str(filter_radius),"r",num2str(filter_sigma),"dr",num2str(dR));
imwrite(luminance,strcat("lm/",filename,".jpg"));

log_luminance = log(luminance);

%% Obtaining the base and detail layer with bilateral filtering.
log_base = imbilatfilt(log_luminance, filter_radius, filter_sigma);
log_detail = log_luminance - log_base;

filename=strcat("base_s",num2str(filter_radius),"r",num2str(filter_sigma),"dr",num2str(dR));
imwrite(exp(log_base),strcat("lm/",filename,".jpg"));

filename=strcat("detail_s",num2str(filter_radius),"r",num2str(filter_sigma),"dr",num2str(dR));
imwrite(exp(log_detail),strcat("lm/",filename,".jpg"));

%% Apply contrast reduction to the base layer.
o = max(log_base,[],'all');
s = dR/(o-min(log_base,[],'all'));
log_base_corr = (log_base - o)*s;

filename=strcat("correctedBase_s",num2str(filter_radius),"r",num2str(filter_sigma),"dr",num2str(dR));
imwrite(exp(log_base_corr),strcat("lm/",filename,".jpg"));

%% Recombine the "corrected" base layer with the detail layer.
corr_luminance = exp(log_base_corr + log_detail);

filename=strcat("corrLum_s",num2str(filter_radius),"r",num2str(filter_sigma),"dr",num2str(dR));
imwrite(corr_luminance,strcat("lm/",filename,".jpg"));

%% Add the new luminance to the colors and return to RGB space.
hsv_space(:,:,3)=corr_luminance;
final_filename=strcat("final_s",num2str(filter_radius),"r",num2str(filter_sigma),"dr",num2str(dR));
I = hsv2rgb(hsv_space);
imwrite(imadjust(I,[],[],0.5),strcat("lm/",final_filename,".jpg"))
end

