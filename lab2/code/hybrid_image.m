% Before trying to construct hybrid images, it is suggested that you
% implement my_imfilter.m and then debug it using proj1_test_filtering.m

% Debugging tip: You can split your MATLAB code into cells using "%%"
% comments. The cell containing the cursor has a light yellow background,
% and you can press Ctrl+Enter to run just the code in that cell. This is
% useful when projects get more complex and slow to rerun from scratch

close all; % closes all figures

image_path = "..\data\";
img_1_name = "perrete.jpg";
img_2_name = "gatete.jpg";


%% Setup
% read images and convert to floating point format.
image1 = im2single(imread(image_path + img_1_name));
image2 = im2single(imread(image_path + img_2_name));

% align the images
[image1, image2] =  align_images(image1, image2);
%%
close all;
imshow(image1);
roi = images.roi.Rectangle(gca);
roi.draw()
i1 = roi.Position(1);
i2 = i1 + roi.Position(3);
j1 = roi.Position(2);
j2 = j1 + roi.Position(4);
crop_image1 = image1(j1:j2,i1:i2,:);
crop_image2 = image2(j1:j2,i1:i2,:);

% Several additional test cases are provided for you, but feel free to make
% your own (you'll need to align the images in a photo editor such as
% Photoshop). The hybrid images will differ depending on which image you
% assign as image1 (which will provide the low frequencies) and which image
% you asign as image2 (which will provide the high frequencies)

%% Filtering and Hybrid Image construction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE BELOW. Use my_imfilter create 'low_frequencies' and
% 'high_frequencies' and then combine them to create 'hybrid_image'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
blur_img_kernel = fspecial('gaussian', [10 10], 4);

%make the filter sum to 1
blur_img_kernel = blur_img_kernel;
blur_image_1 = my_imfilter(crop_image1, blur_img_kernel);
high_frequencies = crop_image1 - blur_image_1;


low_frequencies = my_imfilter(crop_image2, blur_img_kernel);
%%

mean_lf = mean(low_frequencies, 'all');
mean_hf = mean(high_frequencies, 'all');
tmean = (mean_lf+mean_hf)/2;

low_frequencies = low_frequencies*tmean/mean_lf;
high_frequencies = high_frequencies*tmean*0.19/mean_hf;

hybrid_image_res = high_frequencies+low_frequencies;


%% Visualize and save outputs
figure(1); imshow(low_frequencies)
figure(2); imshow(high_frequencies + 0.5);
vis = vis_hybrid_image(hybrid_image_res);
figure(3); imshow(vis);
imwrite(low_frequencies, 'low_frequencies.jpg', 'quality', 95);
imwrite(high_frequencies + 0.5, 'high_frequencies.jpg', 'quality', 95);
imwrite(hybrid_image_res, 'hybrid_image.jpg', 'quality', 95);
imwrite(vis, 'hybrid_image_scales.jpg', 'quality', 95);

%%
