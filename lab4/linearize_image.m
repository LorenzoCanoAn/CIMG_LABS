function [linearImage] = linearize_image(loadManager,cameraResponse)
%LINEARIZE_IMAGE Summary of this function goes here
[~,nImg] = size(loadManager.img);
linearImage = cell(1,nImg);
for i = 1:nImg
    for channel = 1:3
        
        hola = cameraResponse{channel}(floor(loadManager.img{i}(:,:,channel)+1));
        adios = log(loadManager.obt(i));
        
        linearImage{i}(:,:,channel) =  hola - adios;

    end
end

