data_folder = "../data/Section2_SingleCapture";
files = dir(data_folder);
files = files(3:end);
global params
params.kernel = ones(1,10)/10;
params.c1 = 0.8;
params.c2 = 0.1;
params.c3 = 0.1;

for file = files'
    image = imread(fullfile(file.folder,file.name));
    % Get Lmin and Lmax
    [Lmin,Lmax] = get_Lmin_Lmax(image);
    % Interpolate Lmin and Lmax
    
end



function [Lmin, Lmax] = get_Lmin_Lmax(image)

global params
hsv_image = rgb2hsv(image);

convImage = conv2(hsv_image(:,:,3),params.kernel,'same');
i_max = hsv_image(:,:,3) > convImage;
i_min = ~i_max;

Lmin = image.*uint8(i_min);
Lmax = image.*uint8(i_max);

end