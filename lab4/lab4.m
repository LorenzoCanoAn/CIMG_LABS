%% PARAMETERS
inputFolder = "data/chapel/";

%% LOADING
loadManager = imgScanner(inputFolder);

%% Weighting function
w = ones(1,256);
for i = 1:256
    w(i) = weight_pixel(i);
end

%% HDR IMAGING
    %% Lienarize images
    [~, nImages] = size(loadManager.img);
    [g] = get_cameraResponse(loadManager.img, nImages, loadManager.obt,w, 20, 20);
    
    %% Obtain radiance map
    radianceMap = hdrRadiance(loadManager, g,w);
    figure;
    xyz_image = rgb2xyz(radianceMap);
    imagesc(xyz_image(:,:,2));
    title("Radiance map");


%% GLOBAL TONE MAPPING
    globalTone = global_tone_mapping(radianceMap,0.00005,0.5);
    figure;
    imshow(imadjust(globalTone,[],[],0.5));
    title("Global tone mapping");

%% LOCAL TONE MAPPING
    sigmas=0.4;sigmar=10;dr=3;
    localTone = local_tone_mapping(radianceMap,sigmas,sigmar,dr);
    figure;
    %imshow(imadjust(localTone,[],[],0.5));
    imshow(lin2rgb(localTone));
    title("Local tone mapping");
    
%% Trial with own pictures