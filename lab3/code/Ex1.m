%% PARAMETERS

% Read data
aperture = imread('apertures/zhou.bmp');
image = imread('images/penguins.jpg');

% Noise level (gaussian noise)
sigma = 0.001;
% Blur size
blurSize = [3 7 14 20];
idxBlur = 4;


%% MAIN

f0_hat = zeros(size(image));
for i = 1:3
  f0_hat(:,:,i) = deconvx(image(:,:,i),aperture,sigma,blurSize(idxBlur),i);
end

figure;
imshow(f0_hat);

%% function
function f0_hat = deconvx (image, aperture, sigma, blurSize,i)

disp(['Noise= ', num2str(sigma), ' Blur= ', num2str(blurSize)]);

% Normalization
temp = fspecial('disk', blurSize);
flow = max(temp(:));

f0 = im2double(image);
[h, w, ~] = size(f0);

% Prior matrix: 1/f law
AStar = eMakePrior(h, w)+0.00000001;
C = sigma.^2*h*w./AStar;

% Pattern
k1 = im2double(imresize(aperture, [2*blurSize+1, 2*blurSize+1], 'nearest'));
k1 = k1*(flow/max(k1(:)));
k1P = zPSFPad(k1, max(h, w), max(h, w));

% Apply blur
f1 = zDefocused(f0, k1, sigma);

% Recover
f0_hat = zDeconvWNR(f1, k1, C);

    if i==1
        figure;
        subplot_tight(1,3,1, 0.0)
        imshow(f0);
        title('Focused');
        subplot_tight(1,3,2, 0.0)
        imshow(f1);
        title('Defocused');
        subplot_tight(1,3,3, 0.0)
        imshow(f0_hat);
        title('Recovered');
        figure;
        k1P = zPSFPad(k1, max(h, w), max(h, w));
        imagesc(k1P);
        title('PSF');
    end 
end


function outK = zPSFPad(inK, hei, wid)
% This function is to zeropadding the psf
[shei, swid] = size(inK);
outK = zeros(hei, wid);
outK(floor(end/2-shei/2)+1:floor(end/2-shei/2)+shei, floor(end/2-swid/2)+1:floor(end/2-swid/2)+swid) = inK;
end
