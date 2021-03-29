%% PARAMETERS
inputFolder = "data/chapel/";

%% LOADING
loadManager = imgScanner(inputFolder);

%% HDR IMAGING
    %% Lienarize images
    [~, nImages] = size(loadManager.img);
    [g] = get_cameraResponse(loadManager.img, nImages, loadManager.obt, 20, 20);

    
    %% Obtain radiance map
    radianceMap = hdrRadiance(loadManager, g);
    figure;
    imshow(radianceMap)
    title("Radiance map");
    
%% GLOBAL TONE MAPPING
    im1 = global_tone_mapping(radianceMap,0.00001,0.18,2);
    figure;
    imshow(im1);
    title("Global tone mapping");
    
%% LOCAL TONE MAPPING
    
%% Trial with own pictures