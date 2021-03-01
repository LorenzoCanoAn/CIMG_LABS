% this script has test cases to help you test my_imfilter() which you will
% write. You should verify that you get reasonable output here before using
% your filtering to construct a hybrid image in proj1.m. The outputs are
% all saved and you can include them in your writeup. You can add calls to
% imfilter() if you want to check that my_imfilter() is doing something
% similar.
close all

picture_name = 'einstein';
picture_format = '.bmp';

%% Setup
test_image = im2single(imread(strcat('../data/', picture_name, picture_format)));
test_image = imresize(test_image, 0.7, 'bilinear'); %resizing to speed up testing
figure(1)
imshow(test_image)

%% Identify filter
%This filter should do nothing regardless of the padding method you use.
identity_filter = [0,0,0; 0,1,0; 0,0,0];

identity_image  = my_imfilter(test_image, identity_filter);

figure(2); imshow(identity_image);
mkdir(strcat('../data/', picture_name));
imwrite(identity_image, strcat('../data/', picture_name, '/identity_image.jpg'), 'quality', 95);

%% Small blur with a box filter
%This filter should remove some high frequencies
blur_filter = ones(5,5);

%make the filter sum to 1
blur_filter = blur_filter/25;

blur_image = my_imfilter(test_image, blur_filter);

figure(3); imshow(blur_image);
imwrite(blur_image, strcat('../data/', picture_name, '/blur_image.jpg'), 'quality', 95);


%% Large blur
%Create a large gaussian kernel, rememver the function fspecial
large_1d_blur_filter = fspecial('gaussian', [31 31], 4);

large_blur_image = my_imfilter(test_image, large_1d_blur_filter);

figure(4); imshow(large_blur_image);
imwrite(large_blur_image, strcat('../data/', picture_name, '/large_blur_image.jpg'), 'quality', 95);

%If you created a large 2D filter [X, X], you may feel that execution is slow.
%Gaussian blurs are separable and blur sequentially in each direction.
%Which means that you could create a Gaussian filter with size [X, 1] or [1, X] 
%(the X you chose before) blur the image with my_imfilter, transpose the kernel
%and, blur again with my_imfilter and the transposed kernel to get the final image. 
%This should be faster to run and will give you an equivalent result.

%% Oriented filter (Sobel Operator)
sobel_filter = [1,0,-1;2,0,-1;1,0,-1]; %should respond to horizontal gradients

sobel_image = my_imfilter(test_image, sobel_filter);

%0.5 added because the output image is centered around zero otherwise and mostly black
figure(5); imshow(sobel_image + 0.5);
imwrite(sobel_image + 0.5, strcat('../data/', picture_name, '/sobel_image.jpg'), 'quality', 95);


%% High pass filter (Discrete Laplacian)
laplacian_filter = fspecial('laplacian',0.5);

laplacian_image = my_imfilter(test_image, laplacian_filter);

%0.5 added because the output image is centered around zero otherwise and mostly black
figure(6); imshow(laplacian_image + 0.5);
imwrite(laplacian_image + 0.5, strcat('../data/', picture_name, '/laplacian_image.jpg'), 'quality', 95);

%% High pass "filter" alternative, use the low frequency content
high_pass_image = test_image - blur_image;

figure(7); imshow(high_pass_image + 0.5);
imwrite(high_pass_image + 0.5, strcat('../data/', picture_name, '/high_pass_image.jpg'), 'quality', 95);

%by James Hays