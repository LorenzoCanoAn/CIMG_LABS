addpath("./functions/rgb_hsl");
addpath("./functions");
%% PARAMETERS
inputFolder = "data/chapel/";

%% LOADING
loadManager = imgScanner(inputFolder);

%% Weighting function
w = ones(1,256);
for i = 1:256
    w(i) = weight_pixel(i);
end

%% Lienarize images
lambda=20;
downSampling=200;

[~, nImages] = size(loadManager.img);
[g] = get_cameraResponse(loadManager.img, nImages, loadManager.obt,w, lambda, downSampling);
figure; hold on
plot(g{1},'Color','r');
plot(g{2},'Color','g');
plot(g{3},'Color','b');

%% Obtain radiance map
radianceMap = hdrRadiance(loadManager, g,w);
figure;
xyz_image = rgb2hsv(radianceMap);
imagesc(xyz_image(:,:,3));
title("Radiance map");

%% GLOBAL TONE MAPPING
delta=0.002;
a=0.18;
L_white=inf;

globalTone = global_tone_mapping(radianceMap,delta,a,L_white);
figure;
imshow(imadjust(globalTone,[],[],0.5));
filename=strcat("l_d",num2str(delta),"a",num2str(a),"l",num2str(L_white),".jpg");
imwrite(imadjust(globalTone,[],[],0.5),strcat("gm/",filename));
title("Global tone mapping");

%% LOCAL TONE MAPPING
filter_sigma=2.0;filter_radius=20;dR=3;
localTone = local_tone_mapping(radianceMap,filter_sigma,filter_radius,dR);
figure;
imshow(imadjust(localTone,[],[],0.45));
title("Local tone mapping");

    % This function is only for showing what happens with no bilateral
    % filtering
locNav = local_tone_mapping_naive(radianceMap,dR);
figure;
imshow(imadjust(locNav,[],[],0.45));
title("Local tone mapping naive");


