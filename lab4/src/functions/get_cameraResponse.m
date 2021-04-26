function [G] = get_cameraResponse(images, nImages, exposures, w, lambda, downSampling)

if ~exist("downSampling",'var')
    downSampling = 20;
else
    if downSampling < 1
        downSampling = 1;
    end
end

[height, width, ~] = size(imresize(images{1},1/downSampling));
B = log(exposures);
Z = zeros(height*width,nImages);
G = cell(1,3);
for channel = 1:3
    
    for j = 1:nImages
        imagen = imresize(images{j}(:,:,channel),1/downSampling);
        Z(:,j) = reshape(imagen.',1,[]);
    end

    [g, ~] = gsolve(Z, B, w, lambda);
    G{channel} = g;
end
end

