%% PARAMETERS
inputFolder = "data/chapel/";

%% LOADING
loadManager = imgScanner(inputFolder);


%% HDR IMAGING

    %% Lienarize images
    [~, nImages] = size(loadManager.img);
    [g, lE] = get_cameraResponse(loadManager.img, nImages, loadManager.obt, 1, 20);
    plot(g);
    
    
    
    %% Obtain radiance map
    
%% GLOBAL TONE MAPPING

%% Local tone mapping


%% Trial with own pictures