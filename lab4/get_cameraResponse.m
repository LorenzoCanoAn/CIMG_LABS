function [G] = get_cameraResponse(images, nImages, exposures, lambda, downSampling)

if ~exist("downSampling",'var')
    downSampling = 20;
else
    if downSampling < 1
        downSampling = 1;
    end
end

[height, width, ~] = size(images{1});
samplesPerImage = max(size(1:downSampling:height)) * max(size(1:downSampling:width));

Z = zeros(samplesPerImage,nImages);

G = cell(1,3);
for channel = 1:3
    for j = 1:nImages
        imagen = images{j}(:,:,channel);
        Z(:,j) = reshape(imagen(1:downSampling:height, 1:downSampling:width).',1,[]);
    end

    B = log(exposures);

    [g, lE] = gsolve(Z, B, lambda); 
    G{channel} = g;
end
end

