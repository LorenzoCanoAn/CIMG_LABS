function [I] = local_tone_mapping(Lw, sigmas, sigmar, dR)
if ~exist("dR","var")
    dR = 5;
end
% %% EXTRACT BASE LAYER FROM OUR IMAGE
%     %% Obtain intensity
%     hsv_space = rgb2hsv(Lw);
%     log_luminance = log(hsv_space(:,:,3)); % Trabajar en luminancia en escala logaritmica.
%     
%     %% Filtering intensity aith a bilateral filter
%     log_base = imbilatfilt(log_luminance, sigmas, sigmar);
%     log_detail = log_luminance - log_base;
%     
%     
%     %% Apply contrast reduction
%     o = max(log_base,[],'all');
%     s = dR/(o-min(log_base,[],'all'));
%     log_base_corr = (log_base-o)*s;
% %% BRING BACK DETAILS
%     corr_luminance = exp(log_base_corr + log_detail);
% %% COMBINE
%     hsv_space(:,:,3) = corr_luminance;
%     I = hsv2rgb(hsv_space);

% %% EXTRACT BASE LAYER FROM OUR IMAGE
%     %% Obtain intensity
%     log_luminance = log(Lw); % Trabajar en luminancia en escala logaritmica.
%     
%     %% Filtering intensity aith a bilateral filter
%     log_base = imbilatfilt(log_luminance, sigmas, sigmar);
%     log_detail = log_luminance - log_base;
%     
%     
%     %% Apply contrast reduction
%     log_base_corr = zeros(size(log_base));
%     for i = 1:3
%         o = max(log_base(:,:,i),[],'all');
%         s = dR/(o-min(log_base(:,:,i),[],'all'));
%         log_base_corr(:,:,i) = (log_base(:,:,i)-o)*s;
%     end
%     %% BRING BACK DETAILS
%     corr_luminance = exp(log_base_corr + log_detail);
%% COMBINE
    
        %% Obtain intensity

    [R, G, B] = imsplit(Lw);
    luminance = 1/61*(R*20 + G*40 + B);

    %luminance = R * 0.299 + G * 0.587 + B * 0.144;
    log_luminance = log(luminance);
>>>>>>> 57b87be4a076ccb326a241f0d88d01194097a2a9
    %% Filtering intensity aith a bilateral filter
    log_base = imbilatfilt(log_luminance, sigmas, sigmar);
    log_detail = log_luminance - log_base;
    
    
    %% Apply contrast reduction
    o = max(log_base,[],'all');
    s = dR/(o-min(log_base,[],'all'));
    log_base_corr = (log_base - o)*s;
    %% BRING BACK DETAILS
    corr_luminance = exp(log_base_corr + log_detail);
%% COMBINE
    
    I = Lw .* corr_luminance ./ luminance;
end

