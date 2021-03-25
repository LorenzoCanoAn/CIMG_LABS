%% PARAMETERS
inputFolder = "data/chapel/";

%% LOADING
loadManager = imgScanner(inputFolder);


%% HDR IMAGING

    %% Lienarize images
    [~, nImages] = size(loadManager.img);

    [g] = get_cameraResponse(loadManager.img, nImages, loadManager.obt, 0.1, 20);
    linearImg = linearize_image(loadManager, g);
    linearImage = hdrRadiance(loadManager, g);
    imshow(linearImage)
    
    %% Obtain radiance map
    
%% GLOBAL TONE MAPPING

%% Local tone mapping

%% Trial with own pictures