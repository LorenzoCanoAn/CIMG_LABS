% Read data
aperture = imread('apertures/circular.bmp');
image = imread('images/penguins.jpg');
image = image(:,:,1);

% Noise level (gaussian noise)
sigma = 0.005;
% Blur size
blurSize = 7;

disp(['Noise= ', num2str(sigma), ' Blur= ', num2str(blurSize)]);

% Normalization
temp = fspecial('disk', blurSize);
flow = max(temp(:));

k1 = im2double(imresize(aperture, [2*blurSize+1, 2*blurSize+1], 'nearest'));
k1 = k1*(flow/max(k1(:)));


% process image
f0 = im2double(image);
[h, w, ch] = size(f0);

% Prior matrix: 1/f law
AStar = eMakePrior(h, w)+0.00000001;
C = sigma.^2*h*w./AStar;

% Apply blur
f1 = zDefocused(f0, k1, sigma);

% Padding aperture
k1P = zPSFPad(k1, max(h, w), max(h, w));

% Aperture power spectra
F = fft2(k1P);
F = fftshift(F.*conj(F));

S = log(F);
S_X = S(:,round(length(S)/2)+1);
S_Y = S(round(length(S)/2)+1,:);

figure;
subplot_tight(2,2,1, 0.05)
imagesc(k1P);
axis('image')
axis('off')
title('Aperture');
subplot_tight(2,2,2, 0.05)
imagesc(S);
axis('image')
axis('off')
title('Aperture Frequency');
subplot_tight(2,2,3, 0.05)
plot(linspace(-1, 1, length(S_X)), S_X)
grid('on')
title('Normalized frecuency X');
subplot_tight(2,2,4, 0.05)
plot(linspace(-1, 1, length(S_Y)), S_Y)
grid('on')
title('Normalized frecuency Y');

% Image power spectra
F0 = fft2(f0);
F0 = fftshift(F0.*conj(F0));

F1 = fft2(f1);
F1 = fftshift(F1.*conj(F1));

S0 = log(F0);
S0_X = S0(:,round(length(S0)/2)+1);
S0_Y = S0(round(length(S0)/2)+1,:);

S1 = log(F1);
S1_X = S1(:,round(length(S1)/2)+1);
S1_Y = S1(round(length(S1)/2)+1,:);

figure;
subplot_tight(2,2,1, [0.1 0.05])
plot(linspace(-1, 1, length(S0_X)), S0_X)
grid('on')
title('Original X');
subplot_tight(2,2,2, [0.1 0.05])
plot(linspace(-1, 1, length(S0_Y)), S0_Y)
grid('on')
title('Original Y');
subplot_tight(2,2,3, [0.1 0.05])
plot(linspace(-1, 1, length(S1_X)), S1_X)
grid('on')
title('Defocused X');
subplot_tight(2,2,4, [0.1 0.05])
plot(linspace(-1, 1, length(S1_Y)), S1_Y)
grid('on')
title('Defocused Y');

function outK = zPSFPad(inK, hei, wid)
% This function is to zeropadding the psf
[shei, swid] = size(inK);
outK = zeros(hei, wid);
outK(floor(end/2-shei/2)+1:floor(end/2-shei/2)+shei, floor(end/2-swid/2)+1:floor(end/2-swid/2)+swid) = inK;
end
