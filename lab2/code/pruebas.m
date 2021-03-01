picture_name = 'einstein';
picture_format = '.bmp';

%% Setup
test_image = im2single(imread(strcat('../data/', picture_name, picture_format)));
test_image = imresize(test_image, 0.7, 'bilinear'); %resizing to speed up testing
figure(1)
imshow(test_image)
% test_image = rgb2gray(test_image);
figure


kernel = ones(100,100)*1/10000;
[height, width, ~] = size(test_image);
fft_image = fft2(test_image);
fft_kernel = fft2(kernel,height,width);

output = ifft2(fft_image .* fft_kernel);

imshow(output);