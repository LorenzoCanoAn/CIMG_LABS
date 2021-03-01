clear all

PLOT = 0;
%% Raw image conversion
fprintf("BEGIN image conversion\n")
tic
image_name = "IMG_0596";
cr2_file = strcat(image_name,".CR2");
raw_folder = "src_imgs";
raw_path = strcat(raw_folder,"/",cr2_file);
command = strcat("dcraw -4 -D -T ", raw_path);
system(command);
tiff_file = strcat(image_name,".tiff");
tiff_path = strcat(raw_folder,"/",tiff_file);
fprintf(strcat("END image conversion, T=",num2str(toc)," s\n"))
%% Load image into matlab
fprintf("BEGIN image loading\n")
tic
RAW_image = imread(tiff_path);
[height,width] = size(RAW_image);
fprintf(strcat("END image loading, T=",num2str(toc)," s\n"))
%% Linearization
fprintf("BEGIN linearization\n")
tic
linear_image = double(double(RAW_image))/15600-1023/15600;
linear_image(linear_image<0) = 0;
linear_image(linear_image>1) = 1;
fprintf(strcat("END image linearization, T=",num2str(toc)," s\n"))

%% Demosaicing
fprintf("BEGIN demosaicing\n")
tic
filter_height = uint16(height / 2);
filter_width = uint16(width / 2);
R_kernel = [1,0;0,0];
G_kernel = [0,1;1,0];
B_kernel = [0,0;0,1];

DM_nni = zeros(height,width,3);
DM_nni(:,:,1) = repmat(R_kernel,[filter_height,filter_width]);
DM_nni(:,:,2) = repmat(G_kernel,[filter_height,filter_width]);
DM_nni(:,:,3) = repmat(B_kernel,[filter_height,filter_width]);
DM_nni = DM_nni.*linear_image;
DM_bil = DM_nni;

% Nearest neighbor
DM_nni(1:2:height,1:2:width,2) = DM_nni(1:2:height,2:2:width,2);
DM_nni(2:2:height,2:2:width,2) = DM_nni(2:2:height,1:2:width,2);
DM_nni(1:2:height,2:2:width,1) = DM_nni(1:2:height,1:2:width,1);
DM_nni(2:2:height,2:2:width,1) = DM_nni(1:2:height,1:2:width,1);
DM_nni(2:2:height,1:2:width,1) = DM_nni(1:2:height,1:2:width,1);
DM_nni(1:2:height,1:2:width,3) = DM_nni(2:2:height,2:2:width,3);
DM_nni(2:2:height,1:2:width,3) = DM_nni(2:2:height,2:2:width,3);
DM_nni(1:2:height,2:2:width,3) = DM_nni(2:2:height,2:2:width,3);

% Bilinear interpolation
w_borders =    [DM_bil(1:2,1:2,:),...
                        DM_bil(1:2,:,:),...
                        DM_bil(1:2,end-1:end,:);...
                        DM_bil(:,1:2,:),...
                        DM_bil,...
                        DM_bil(:,end-1:end,:);...
                        DM_bil(end-1:end,1:2,:),...
                        DM_bil(end-1:end,:,:),...
                        DM_bil(end-1:end,end-1:end,:)];
    % Red channel
DM_bil(2:2:height,1:2:width,1) =   (w_borders((1:2:height)+2     +0,(1:2:width)+2    +0,1) + ...
                                    w_borders((1:2:height)+2     +2,(1:2:width)+2    +0,1))/2;
DM_bil(1:2:height,2:2:width,1) =   (w_borders((1:2:height)+2     +0,(1:2:width)+2    +0,1) + ...
                                    w_borders((1:2:height)+2     +0,(1:2:width)+2    +2,1))/2;
DM_bil(2:2:height,2:2:width,1) =   (w_borders((1:2:height)+2     +0,(1:2:width)+2    +0,1) + ...
                                    w_borders((1:2:height)+2     +2,(1:2:width)+2    +0,1) + ...
                                    w_borders((1:2:height)+2     +0,(1:2:width)+2    +2,1) + ...
                                    w_borders((1:2:height)+2     +2,(1:2:width)+2    +2,1))/4;                                      
     % Blue channel                                 
DM_bil(2:2:height,1:2:width,3) =   (w_borders((1:2:height)+2     +1,(1:2:width)+2    -1,3) + ...
                                    w_borders((1:2:height)+2     +1,(1:2:width)+2    +1,3))/2;
DM_bil(1:2:height,2:2:width,3) =   (w_borders((1:2:height)+2     -1,(1:2:width)+2    +1,3) + ...
                                    w_borders((1:2:height)+2     +1,(1:2:width)+2    +1,3))/2;
DM_bil(1:2:height,1:2:width,3) =   (w_borders((1:2:height)+2     -1,(1:2:width)+2    -1,3) + ...
                                    w_borders((1:2:height)+2     -1,(1:2:width)+2    +1,3) + ...
                                    w_borders((1:2:height)+2     +1,(1:2:width)+2    -1,3) + ...
                                    w_borders((1:2:height)+2     +1,(1:2:width)+2    +1,3))/4;
      % Green channel                                 
DM_bil(1:2:height,1:2:width,2) =   (w_borders((1:2:height)+2     +0,(1:2:width)+2    -1,2) + ...
                                    w_borders((1:2:height)+2     +0,(1:2:width)+2    +1,2) + ...
                                    w_borders((1:2:height)+2     -1,(1:2:width)+2    +0,2) + ...
                                    w_borders((1:2:height)+2     +1,(1:2:width)+2    +0,2))/4;
DM_bil(2:2:height,2:2:width,2) =   (w_borders((1:2:height)+2 +1  +0,(1:2:width)+2 +1 -1,2) + ...
                                    w_borders((1:2:height)+2 +1  +0,(1:2:width)+2 +1 +1,2) + ...
                                    w_borders((1:2:height)+2 +1  -1,(1:2:width)+2 +1 +0,2) + ...
                                    w_borders((1:2:height)+2 +1  +1,(1:2:width)+2 +1 +0,2))/4;
                                
fprintf(strcat("END demosaicing, T=",num2str(toc)," s\n"))

%% White balancing
fprintf("BEGIN white balancing\n")
tic
% Gray world
    
WB_nni_gw = zeros(size(DM_nni));
WB_bil_gw = WB_nni_gw;
r_avg = mean(DM_nni(:,:,1),'all');
g_avg = mean(DM_nni(:,:,2),'all');
b_avg = mean(DM_nni(:,:,3),'all');
WB_nni_gw(:,:,1) = DM_nni(:,:,1)/r_avg*g_avg;
WB_nni_gw(:,:,2) = DM_nni(:,:,2);
WB_nni_gw(:,:,3) = DM_nni(:,:,3)/b_avg*g_avg;
if PLOT
    figure; imshow(WB_nni_gw); title("NNI, gray world");
end
r_avg = mean(DM_bil(:,:,1),'all');
g_avg = mean(DM_bil(:,:,2),'all');
b_avg = mean(DM_bil(:,:,3),'all');
WB_bil_gw(:,:,1) = DM_bil(:,:,1)/r_avg*g_avg;
WB_bil_gw(:,:,2) = DM_bil(:,:,2);
WB_bil_gw(:,:,3) = DM_bil(:,:,3)/b_avg*g_avg;
if PLOT
    figure; imshow(WB_bil_gw); title("Bilinear interpolation, gray world");
end
% White world
     
WB_nni_ww = zeros(size(DM_nni));
WB_bil_ww = WB_nni_ww;
r_max = max(DM_nni(:,:,1),[],'all');
g_max = max(DM_nni(:,:,2),[],'all');
b_max = max(DM_nni(:,:,3),[],'all');
WB_nni_ww(:,:,1) = DM_nni(:,:,1)/r_max*g_max;
WB_nni_ww(:,:,2) = DM_nni(:,:,2);
WB_nni_ww(:,:,3) = DM_nni(:,:,3)/b_max*g_max;
if PLOT
    figure; imshow(WB_nni_ww); title("NNI, white world");
end
r_max = max(DM_bil(:,:,1),[],'all');
g_max = max(DM_bil(:,:,2),[],'all');
b_max = max(DM_bil(:,:,3),[],'all');
WB_bil_ww(:,:,1) = DM_bil(:,:,1)/r_max*g_max;
WB_bil_ww(:,:,2) = DM_bil(:,:,2);
WB_bil_ww(:,:,3) = DM_bil(:,:,3)/b_max*g_max;
if PLOT
    figure; imshow(WB_bil_ww); title("Bilinear interpolation, white world");
end

% Manual white balancing
    
    % Region Selection
    
imgToCrop = DM_nni;
figure_selection = figure;
imshow(imgToCrop, []);
axis on;
title('Original Grayscale Image', 'FontSize', 16);
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
message = sprintf('Left click and hold to begin drawing.\nSimply lift the mouse button to finish');
uiwait(msgbox(message));
hFH = imfreehand(); %#ok<*IMFREEH>
binaryImage = hFH.createMask();
xy = hFH.getPosition;
close(figure_selection);

    % Balancing
    
WB_nni_mb = zeros(size(DM_nni));
WB_bil_mb = WB_nni_mb;
DM_nni_crop = binaryImage .* DM_nni;
r_avg = mean(DM_nni_crop(:,:,1),'all');
g_avg = mean(DM_nni_crop(:,:,2),'all');
b_avg = mean(DM_nni_crop(:,:,3),'all');
WB_nni_mb(:,:,1) = DM_nni(:,:,1)/r_avg*g_avg;
WB_nni_mb(:,:,2) = DM_nni(:,:,2);
WB_nni_mb(:,:,3) = DM_nni(:,:,3)/b_avg*g_avg;
if PLOT
    figure; imshow(WB_nni_mb); title("NNI, manual balancing");
end

DM_bil_crop = binaryImage .* DM_bil;
r_avg = mean(DM_bil_crop(:,:,1),'all');
g_avg = mean(DM_bil_crop(:,:,2),'all');
b_avg = mean(DM_bil_crop(:,:,3),'all');
WB_bil_mb(:,:,1) = DM_bil(:,:,1)/r_avg*g_avg;
WB_bil_mb(:,:,2) = DM_bil(:,:,2);
WB_bil_mb(:,:,3) = DM_bil(:,:,3)/b_avg*g_avg;
if PLOT
    figure; imshow(WB_bil_mb); title("Bilinear interpolation, manual balancing");
end
fprintf(strcat("END white balancing, T=",num2str(toc)," s\n"))

%% Denoising
fprintf("BEGIN denoising \n")
tic
meank = ones(3,3)/9;
gausk = fspecial('gaussian', [3 3], 4);
medik = [3,3];
DN_nni_gw_mean = real(my_imfilter(WB_nni_gw, meank));
DN_nni_gw_gaus = real(my_imfilter(WB_nni_gw, gausk));
DN_nni_gw_medi =  rgb_median(WB_nni_gw, medik);

DN_nni_ww_mean = real(my_imfilter(WB_nni_ww, meank));
DN_nni_ww_gaus = real(my_imfilter(WB_nni_ww, gausk));
DN_nni_ww_medi =  rgb_median(WB_nni_ww, medik);

DN_nni_mb_mean = real(my_imfilter(WB_nni_mb, meank));
DN_nni_mb_gaus = real(my_imfilter(WB_nni_mb, gausk));
DN_nni_mb_medi =  rgb_median(WB_nni_mb, medik);

DN_bil_gw_mean = real(my_imfilter(WB_bil_gw, meank));
DN_bil_gw_gaus = real(my_imfilter(WB_bil_gw, gausk));
DN_bil_gw_medi =  rgb_median(WB_bil_gw, medik);

DN_bil_ww_mean = real(my_imfilter(WB_bil_ww, meank));
DN_bil_ww_gaus = real(my_imfilter(WB_bil_ww, gausk));
DN_bil_ww_medi =  rgb_median(WB_bil_ww, medik);

DN_bil_mb_mean = real(my_imfilter(WB_bil_mb, meank));
DN_bil_mb_gaus = real(my_imfilter(WB_bil_mb, gausk));
DN_bil_mb_medi =  rgb_median(WB_bil_mb, medik);
fprintf(strcat("END denoising, T=",num2str(toc)," s\n"))

%% Color balance
fprintf("BEGIN color balance\n")
tic
saturation_increase = ones(1,1,3);
saturation_increase(1,1,2) = 3;
CB_nni_gw_mean = hsv2rgb(pagemtimes(rgb2hsv(DN_nni_gw_mean),saturation_increase));
CB_nni_gw_gaus = hsv2rgb(pagemtimes(rgb2hsv(DN_nni_gw_gaus),saturation_increase));
CB_nni_gw_medi = hsv2rgb(pagemtimes(rgb2hsv(DN_nni_gw_medi),saturation_increase));
CB_nni_ww_mean = hsv2rgb(pagemtimes(rgb2hsv(DN_nni_ww_mean),saturation_increase));
CB_nni_ww_gaus = hsv2rgb(pagemtimes(rgb2hsv(DN_nni_ww_gaus),saturation_increase));
CB_nni_ww_medi = hsv2rgb(pagemtimes(rgb2hsv(DN_nni_ww_medi),saturation_increase));
CB_nni_mb_mean = hsv2rgb(pagemtimes(rgb2hsv(DN_nni_mb_mean),saturation_increase));
CB_nni_mb_gaus = hsv2rgb(pagemtimes(rgb2hsv(DN_nni_mb_gaus),saturation_increase));
CB_nni_mb_medi = hsv2rgb(pagemtimes(rgb2hsv(DN_nni_mb_medi),saturation_increase));
CB_bil_gw_mean = hsv2rgb(pagemtimes(rgb2hsv(DN_bil_gw_mean),saturation_increase));
CB_bil_gw_gaus = hsv2rgb(pagemtimes(rgb2hsv(DN_bil_gw_gaus),saturation_increase));
CB_bil_gw_medi = hsv2rgb(pagemtimes(rgb2hsv(DN_bil_gw_medi),saturation_increase));
CB_bil_ww_mean = hsv2rgb(pagemtimes(rgb2hsv(DN_bil_ww_mean),saturation_increase));
CB_bil_ww_gaus = hsv2rgb(pagemtimes(rgb2hsv(DN_bil_ww_gaus),saturation_increase));
CB_bil_ww_medi = hsv2rgb(pagemtimes(rgb2hsv(DN_bil_ww_medi),saturation_increase));
CB_bil_mb_mean = hsv2rgb(pagemtimes(rgb2hsv(DN_bil_mb_mean),saturation_increase));
CB_bil_mb_gaus = hsv2rgb(pagemtimes(rgb2hsv(DN_bil_mb_gaus),saturation_increase));
CB_bil_mb_medi = hsv2rgb(pagemtimes(rgb2hsv(DN_bil_mb_medi),saturation_increase));
fprintf(strcat("END color balance, T=",num2str(toc)," s\n"))

%% Tone reproduction
fprintf("BEGIN tone reproduction\n")
tic
gamma = 2.4;
alpha = 0;
TR_nni_gw_mean = gamma_correction(CB_nni_gw_mean*2^alpha, gamma);
TR_nni_gw_gaus = gamma_correction(CB_nni_gw_gaus*2^alpha, gamma);
TR_nni_gw_medi = gamma_correction(CB_nni_gw_medi*2^alpha, gamma);
TR_nni_ww_mean = gamma_correction(CB_nni_ww_mean*2^alpha, gamma);
TR_nni_ww_gaus = gamma_correction(CB_nni_ww_gaus*2^alpha, gamma);
TR_nni_ww_medi = gamma_correction(CB_nni_ww_medi*2^alpha, gamma);
TR_nni_mb_mean = gamma_correction(CB_nni_mb_mean*2^alpha, gamma);
TR_nni_mb_gaus = gamma_correction(CB_nni_mb_gaus*2^alpha, gamma);
TR_nni_mb_medi = gamma_correction(CB_nni_mb_medi*2^alpha, gamma);
TR_bil_gw_mean = gamma_correction(CB_bil_gw_mean*2^alpha, gamma);
TR_bil_gw_gaus = gamma_correction(CB_bil_gw_gaus*2^alpha, gamma);
TR_bil_gw_medi = gamma_correction(CB_bil_gw_medi*2^alpha, gamma);
TR_bil_ww_mean = gamma_correction(CB_bil_ww_mean*2^alpha, gamma);
TR_bil_ww_gaus = gamma_correction(CB_bil_ww_gaus*2^alpha, gamma);
TR_bil_ww_medi = gamma_correction(CB_bil_ww_medi*2^alpha, gamma);
TR_bil_mb_mean = gamma_correction(CB_bil_mb_mean*2^alpha, gamma);
TR_bil_mb_gaus = gamma_correction(CB_bil_mb_gaus*2^alpha, gamma);
TR_bil_mb_medi = gamma_correction(CB_bil_mb_medi*2^alpha, gamma);
fprintf(strcat("END tone reproduction, T=",num2str(toc)," s\n"))

%% FUNCTIONS
function rgb_filtered = rgb_median(image, kernel)
    gray = rgb2gray(image);
    grayf = medfilt2(gray,kernel);
    changed = gray ~= grayf;
    rf = medfilt2(image(:, :, 1), kernel);
    gf = medfilt2(image(:, :, 2), kernel);
    bf = medfilt2(image(:, :, 3), kernel);
    
    rf = image(:,:,1).*~changed + rf .* changed;
    gf = image(:,:,2).*~changed + gf .* changed;
    bf = image(:,:,3).*~changed + bf .* changed;
    
    rgb_filtered = cat(3, rf, gf, bf);
end

function toned_image = gamma_correction(image, gamma)
    under = image <= 0.0031308;
    toned_image = (image .* under) * 12.92;
    toned_image = toned_image + ((1+0.055)*(image).^(1/gamma)-0.055).*~under;
end