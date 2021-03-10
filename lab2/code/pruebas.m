%% Parameters

picture_path = '../data/';
picture_name = 'einstein';
picture_format = '.bmp';

kernel = ones(100,100)*1/10000;



%% Setup
test_image = im2single(imread(strcat(picture_path, picture_name, picture_format)));
test_image = imresize(test_image, 0.7, 'bilinear'); %resizing to speed up testing
figure(1)
imshow(test_image)
% test_image = rgb2gray(test_image);
figure


[height, width, ~] = size(test_image);
fft_image = fft2(test_image);
fft_kernel = fft2(kernel,height,width);

output = ifft2(fft_image .* fft_kernel);

imshow(output);