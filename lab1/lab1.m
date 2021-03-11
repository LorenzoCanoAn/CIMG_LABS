
%% Parameters
image_name = "IMG_0596";
image_ext = ".CR2";
image_path = "src_imgs";
PLOT = 0;

% Denoising
meank = ones(3,3)/9;                    % Kernel for mean filtering
gausk = fspecial('gaussian', [3 3], 4); % Kernel for gaussian filtering
medik = [3,3];                          % Size of median filtering

% Color Correction
saturation_increase = 1.3;
brightness_increase = 1.0;

% Tone Balancing
gamma = 1.9;
alpha = 0.1;

% Saving
save_path = "saved_imgs";
format = 'jpeg';
%% Raw image conversion
fprintf("BEGIN image conversion\n")
tic


if image_ext == ".CR2"
    cr2_file = strcat(image_name,".CR2");
    raw_path = strcat(image_path,"/",cr2_file);
    command = strcat("dcraw -4 -D -T ", raw_path);
    system(command);
    tiff_file = strcat(image_name,".tiff");
    tiff_path = strcat(image_path,"/",tiff_file);
end

fprintf(strcat("END image conversion, T=",num2str(toc)," s\n\n"))

%% Load image into matlab
fprintf("BEGIN image loading\n")
tic

RAW_image = imread(tiff_path);
[height,width] = size(RAW_image);

fprintf(strcat("END image loading, T=",num2str(toc)," s\n\n"))

%% Linearization
fprintf("BEGIN linearization\n")
tic

linear_image = double(double(RAW_image)-1023)/(15600-1023);
linear_image(linear_image<0) = 0;
linear_image(linear_image>1) = 1;

fprintf(strcat("END image linearization, T=",num2str(toc)," s\n\n"))

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

fprintf(strcat("END demosaicing, T=",num2str(toc)," s\n\n"))

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
    figure; imshow(WB_nni_gw); title("NNI, gray world"); %#ok<*UNRCH>
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

fprintf(strcat("END white balancing, T=",num2str(toc)," s\n\n"))

%% Denoising
fprintf("BEGIN denoising \n")
tic

DN_nni_gw_mean = imfilter(WB_nni_gw, meank);
DN_nni_gw_gaus = imfilter(WB_nni_gw, gausk);
DN_nni_gw_medi = mymedfil(WB_nni_gw, medik);

DN_nni_ww_mean = imfilter(WB_nni_ww, meank);
DN_nni_ww_gaus = imfilter(WB_nni_ww, gausk);
DN_nni_ww_medi = mymedfil(WB_nni_ww, medik);

DN_nni_mb_mean = imfilter(WB_nni_mb, meank);
DN_nni_mb_gaus = imfilter(WB_nni_mb, gausk);
DN_nni_mb_medi = mymedfil(WB_nni_mb, medik);


DN_bil_gw_mean = imfilter(WB_bil_gw, meank);
DN_bil_gw_gaus = imfilter(WB_bil_gw, gausk);
DN_bil_gw_medi = mymedfil(WB_bil_gw, medik);

DN_bil_ww_mean = imfilter(WB_bil_ww, meank);
DN_bil_ww_gaus = imfilter(WB_bil_ww, gausk);
DN_bil_ww_medi = mymedfil(WB_bil_ww, medik);

DN_bil_mb_mean = imfilter(WB_bil_mb, meank);
DN_bil_mb_gaus = imfilter(WB_bil_mb, gausk);
DN_bil_mb_medi = mymedfil(WB_bil_mb, medik);

fprintf(strcat("END denoising, T=",num2str(toc)," s\n\n"))

%% Color balance
fprintf("BEGIN color balance\n")
tic

CB_nni_gw_mean = increase_saturation(DN_nni_gw_mean,saturation_increase, brightness_increase);
CB_nni_gw_gaus = increase_saturation(DN_nni_gw_gaus,saturation_increase, brightness_increase);
CB_nni_gw_medi = increase_saturation(DN_nni_gw_medi,saturation_increase, brightness_increase);
CB_nni_ww_mean = increase_saturation(DN_nni_ww_mean,saturation_increase, brightness_increase);
CB_nni_ww_gaus = increase_saturation(DN_nni_ww_gaus,saturation_increase, brightness_increase);
CB_nni_ww_medi = increase_saturation(DN_nni_ww_medi,saturation_increase, brightness_increase);
CB_nni_mb_mean = increase_saturation(DN_nni_mb_mean,saturation_increase, brightness_increase);
CB_nni_mb_gaus = increase_saturation(DN_nni_mb_gaus,saturation_increase, brightness_increase);
CB_nni_mb_medi = increase_saturation(DN_nni_mb_medi,saturation_increase, brightness_increase);
CB_bil_gw_mean = increase_saturation(DN_bil_gw_mean,saturation_increase, brightness_increase);
CB_bil_gw_gaus = increase_saturation(DN_bil_gw_gaus,saturation_increase, brightness_increase);
CB_bil_gw_medi = increase_saturation(DN_bil_gw_medi,saturation_increase, brightness_increase);
CB_bil_ww_mean = increase_saturation(DN_bil_ww_mean,saturation_increase, brightness_increase);
CB_bil_ww_gaus = increase_saturation(DN_bil_ww_gaus,saturation_increase, brightness_increase);
CB_bil_ww_medi = increase_saturation(DN_bil_ww_medi,saturation_increase, brightness_increase);
CB_bil_mb_mean = increase_saturation(DN_bil_mb_mean,saturation_increase, brightness_increase);
CB_bil_mb_gaus = increase_saturation(DN_bil_mb_gaus,saturation_increase, brightness_increase);
CB_bil_mb_medi = increase_saturation(DN_bil_mb_medi,saturation_increase, brightness_increase);

fprintf(strcat("END color balance, T=",num2str(toc)," s\n\n"))

%% Tone reproduction
fprintf("BEGIN tone reproduction\n")
tic

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
TR_bil_mb_gaus = gamma_correction(CB_bil_mb_gaus*(2^alpha), gamma);
TR_bil_mb_medi = gamma_correction(CB_bil_mb_medi*2^alpha, gamma);

fprintf(strcat("END tone reproduction, T=",num2str(toc)," s\n\n"))

%% Compression
fprintf("BEGIN compression and saving\n")
tic

if ~exist(save_path, 'dir')
       mkdir(save_path)
end
 
imwrite(TR_nni_gw_mean,strcat(save_path,'/TR_nni_gw_mean.',format),format)
imwrite(TR_nni_gw_gaus,strcat(save_path,'/TR_nni_gw_gaus.',format),format)
imwrite(TR_nni_gw_medi,strcat(save_path,'/TR_nni_gw_medi.',format),format)
imwrite(TR_nni_ww_mean,strcat(save_path,'/TR_nni_ww_mean.',format),format)
imwrite(TR_nni_ww_gaus,strcat(save_path,'/TR_nni_ww_gaus.',format),format)
imwrite(TR_nni_ww_medi,strcat(save_path,'/TR_nni_ww_medi.',format),format)
imwrite(TR_nni_mb_mean,strcat(save_path,'/TR_nni_mb_mean.',format),format)
imwrite(TR_nni_mb_gaus,strcat(save_path,'/TR_nni_mb_gaus.',format),format)
imwrite(TR_nni_mb_medi,strcat(save_path,'/TR_nni_mb_medi.',format),format)
imwrite(TR_bil_gw_mean,strcat(save_path,'/TR_bil_gw_mean.',format),format)
imwrite(TR_bil_gw_gaus,strcat(save_path,'/TR_bil_gw_gaus.',format),format)
imwrite(TR_bil_gw_medi,strcat(save_path,'/TR_bil_gw_medi.',format),format)
imwrite(TR_bil_ww_mean,strcat(save_path,'/TR_bil_ww_mean.',format),format)
imwrite(TR_bil_ww_gaus,strcat(save_path,'/TR_bil_ww_gaus.',format),format)
imwrite(TR_bil_ww_medi,strcat(save_path,'/TR_bil_ww_medi.',format),format)
imwrite(TR_bil_mb_mean,strcat(save_path,'/TR_bil_mb_mean.',format),format)
imwrite(TR_bil_mb_gaus,strcat(save_path,'/TR_bil_mb_gaus.',format),format)
imwrite(TR_bil_mb_medi,strcat(save_path,'/TR_bil_mb_medi.',format),format)

fprintf(strcat("END compression and saving, T=",num2str(toc)," s\n\n"))


%% compression

res = [];
qualityFactor = 10:10:100;

for i=1:10
    name =strcat(int2str(i),'compression.jpeg');
    imwrite(TR_bil_mb_gaus,name,'quality',qualityFactor(i));
    c = im2double(imread(name));
    res = [res ssim(TR_bil_mb_gaus,c)];
end
%%

figure;
plot(a,res);
set(gca, 'XDir','reverse');
ylabel("SSIM val");
xlabel("% Compression");



%% FUNCTIONS
function rgb_filtered = mymedfil(image, kernel)

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

function y = gamma_correction(x, gamma)

gamma = cast(1/gamma,'like',x);
a     = cast(1.055,'like',x);
b     = cast(-0.055,'like',x);
c     = cast(12.92,'like',x);
d     = cast(0.0031308,'like',x);

y = zeros(size(x),'like',x);

in_sign = -2 * (x < 0) + 1;
x = abs(x);

lin_range = (x < d);
gamma_range = ~lin_range;

y(gamma_range) = a * exp(gamma .* log(x(gamma_range))) + b;
y(lin_range) = c * x(lin_range);

y = y .* in_sign;

end

function saturated = increase_saturation(image, factor_s, factor_b)

hsv = rgb2hsv(image);
hsv(:,:,2) = hsv(:,:,2) * factor_s;
hsv(:,:,3) = hsv(:,:,3) * factor_b;
saturated = hsv2rgb(hsv);

end