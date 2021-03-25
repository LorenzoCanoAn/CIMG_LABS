

% Read data
aperture = imread('apertures/zhou.bmp');
image = imread('images/penguins.jpg');
image = image(:,:,1);

% Noise level (gaussian noise)
sigma = 0.005;
% Blur size
blurSize = 14;

disp(['Noise= ', num2str(sigma), ' Blur= ', num2str(blurSize)]);

% Normalization
temp = fspecial('disk', blurSize);
flow = max(temp(:));

f0 = im2double(image);
[h, w, ch] = size(f0);

% Prior matrix: 1/f law
AStar = eMakePrior(h, w)+0.00000001;
C = sigma.^2*h*w./AStar;

% Pattern
k1 = im2double(imresize(aperture, [2*blurSize+1, 2*blurSize+1], 'nearest'));
k1 = k1*(flow/max(k1(:)));

% Apply blur
f1 = zDefocused(f0, k1, sigma);

% Recover
f0_hat = zDeconvWNR(f1, k1, C);
figure;
subplot_tight(1,3,1,[0.0,1])
imshow(f0);
title('Focused');
subplot_tight(1,3,2, 0.0)
imshow(f1);
title('Defocused');
subplot_tight(1,3,3, 0.0)
imshow(f0_hat);
title('Recovered');
