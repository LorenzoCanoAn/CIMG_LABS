function [g, lE] = get_cameraResponse(images, nImages, exposures, lambda, downSampling)

if ~exist("downSampling",'var')
    downSampling = 20;
else
    if downSampling < 1
        downSampling = 1;
    end
end

[height, width] = size(images{1});
samplesPerImage = floor(height * width / downSampling);
pixelsPerImage = height * width;
indices = 1:downSampling:pixelsPerImage;
Z = zeros(samplesPerImage,nImages);

for j = 1:nImages
    for i = indices
        Z(i,j) = images{j}(i);
    end
end

B = log(exposures);

[g, lE] = gsolve(Z, B, lambda, weight_pixel);

end

