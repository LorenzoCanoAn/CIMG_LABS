
%% Raw image conversion

image_name = "IMG_0596";
cr2_file = strcat(image_name,".CR2");
raw_folder = "src_imgs";
raw_path = strcat(raw_folder,"/",cr2_file);
command = strcat("dcraw -4 -D -T ", raw_path);
system(command);
tiff_file = strcat(image_name,".tiff");
tiff_path = strcat(raw_folder,"/",tiff_file);

%% Load image into matlab

RAW_image = imread(tiff_path);
[height,width] = size(RAW_image);

%% Linearization

linear_image = double(double(RAW_image))/15600-1023/15600;
linear_image(linear_image<0) = 0;
linear_image(linear_image>1) = 1;


%% Demosaicing
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

%% White balancing

% Gray world
    
WB_nni_gw = zeros(size(DM_nni));
WB_bil_gw = WB_nni_gw;
r_avg = mean(DM_nni(:,:,1),'all');
g_avg = mean(DM_nni(:,:,2),'all');
b_avg = mean(DM_nni(:,:,3),'all');
WB_nni_gw(:,:,1) = DM_nni(:,:,1)/r_avg*g_avg;
WB_nni_gw(:,:,2) = DM_nni(:,:,2);
WB_nni_gw(:,:,3) = DM_nni(:,:,3)/b_avg*g_avg;
figure; imshow(WB_nni_gw); title("NNI, gray world");

r_avg = mean(DM_bil(:,:,1),'all');
g_avg = mean(DM_bil(:,:,2),'all');
b_avg = mean(DM_bil(:,:,3),'all');
WB_bil_gw(:,:,1) = DM_bil(:,:,1)/r_avg*g_avg;
WB_bil_gw(:,:,2) = DM_bil(:,:,2);
WB_bil_gw(:,:,3) = DM_bil(:,:,3)/b_avg*g_avg;
figure; imshow(WB_bil_gw); title("Bilinear interpolation, gray world");

% White world
     
WB_nni_ww = zeros(size(DM_nni));
WB_bil_ww = WB_nni_ww;
r_max = max(DM_nni(:,:,1),[],'all');
g_max = max(DM_nni(:,:,2),[],'all');
b_max = max(DM_nni(:,:,3),[],'all');
WB_nni_ww(:,:,1) = DM_nni(:,:,1)/r_max*g_max;
WB_nni_ww(:,:,2) = DM_nni(:,:,2);
WB_nni_ww(:,:,3) = DM_nni(:,:,3)/b_max*g_max;
figure; imshow(WB_nni_ww); title("NNI, white world");

r_max = max(DM_bil(:,:,1),[],'all');
g_max = max(DM_bil(:,:,2),[],'all');
b_max = max(DM_bil(:,:,3),[],'all');
WB_bil_ww(:,:,1) = DM_bil(:,:,1)/r_max*g_max;
WB_bil_ww(:,:,2) = DM_bil(:,:,2);
WB_bil_ww(:,:,3) = DM_bil(:,:,3)/b_max*g_max;
figure; imshow(WB_bil_ww); title("Bilinear interpolation, white world");

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
figure; imshow(WB_nni_mb); title("NNI, manual balancing");

DM_bil_crop = binaryImage .* DM_bil;
r_avg = mean(DM_bil_crop(:,:,1),'all');
g_avg = mean(DM_bil_crop(:,:,2),'all');
b_avg = mean(DM_bil_crop(:,:,3),'all');
WB_bil_mb(:,:,1) = DM_bil(:,:,1)/r_avg*g_avg;
WB_bil_mb(:,:,2) = DM_bil(:,:,2);
WB_bil_mb(:,:,3) = DM_bil(:,:,3)/b_avg*g_avg;
figure; imshow(WB_bil_mb); title("Bilinear interpolation, manual balancing");

