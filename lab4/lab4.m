%% PARAMETERS
inputFolder = "data/chapel/";

%% LOADING
loadManager = imgScanner(inputFolder);

%% HDR IMAGING
    %% Lienarize images
%     [~, nImages] = size(loadManager.img);
%     [g] = get_cameraResponse(loadManager.img, nImages, loadManager.obt, 20, 20);

    %% Obtain radiance map
%     radianceMap = hdrRadiance(loadManager, g);
%     figure;
%     imshow(radianceMap)
%     title("Radiance map");

%% GLOBAL TONE MAPPING
%     globalTone = global_tone_mapping(radianceMap,0.00001,0.18,2);
%     figure;
%     imshow(globalTone);
%     title("Global tone mapping");

%% LOCAL TONE MAPPING
    localTone = local_tone_mapping(radianceMap,0.00002);
    figure;
    imshow(localTone);
    title("Local tone mapping");
    
%% Trial with own pictures