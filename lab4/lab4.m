%% PARAMETERS
inputFolder = "data/chapel/";
addpath("./rgb_hsl")

%% LOADING
loadManager = imgScanner(inputFolder);

%% Weighting function
w = ones(1,256);
for i = 1:256
    w(i) = weight_pixel(i);
end

%% Trial with own pictures
inputFolder = "data/casaC/";
addpath("./rgb_hsl")

% LOADING
loadManager = imgScanner(inputFolder);

% Weighting function
w = ones(1,256);
for i = 1:256
    w(i) = weight_pixel(i);
end

%
hdr(loadManager,w);    

%% HDR IMAGING
function hdr(loadManager,w)

    %% Lienarize images
    [~, nImages] = size(loadManager.img);
    [g] = get_cameraResponse(loadManager.img, nImages, loadManager.obt,w, 20, 200);
    figure;
    plot(g{1},'Color','r');
    hold on
    plot(g{2},'Color','g');
    plot(g{3},'Color','b');
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
    imshow(lin2rgb(globalTone));
    title("Global tone mapping");

%% LOCAL TONE MAPPING
    sigmas=0.4;sigmar=10;dr=3;
    localTone = local_tone_mapping(radianceMap,sigmas,sigmar,dr);
    figure;
    %imshow(imadjust(localTone,[],[],0.5));
    imshow(lin2rgb(localTone));
    title("Local tone mapping");
    
end

