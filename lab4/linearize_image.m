function [linearImage] = linearize_image(inputImage,exposure,cameraResponse)
%LINEARIZE_IMAGE Summary of this function goes here

linearImage = exp(cameraResponse(inputImage) - ln(exposure));
end