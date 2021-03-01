function output = my_imfilter(image, filter)
%%
% This function is intended to behave like the built in function imfilter()
% See 'help imfilter' or 'help conv2'. While terms like "filtering" and
% "convolution" might be used interchangeably, and they are indeed nearly
% the same thing, there is a difference:
% from 'help filter2'
%    2-D correlation is related to 2-D convolution by a 180 degree rotation
%    of the filter matrix.

% Your function should work for color images.

% Your function should work for filters of any width and height
% combination, as long as the width and height are odd (e.g. 1, 7, 9).

% Boundary handling can be tricky. 
% If you look at 'help conv2' and 'help imfilter' you see that they have
% several options to deal with boundaries.

% % Uncomment if you want to simply call imfilter so you can see the desired
% % behavior. When you write your actual solution, you can't use imfilter,
% % filter2, conv2, etc. Simply loop over all the pixels and do the actual
% % computation. It might be slow.

% output = imfilter(image, filter);

%%

%%
% FILL THIS WITH YOUR CODE
%%
[img_height, img_width, ~] = size(image);
[filter_height, filter_width, ~] = size(filter);

fft_image = fft2(image,img_height+filter_height,img_width+filter_width);
fft_kernel = fft2(filter,img_height+filter_height,img_width+filter_width);
output = ifft2(fft_image .* fft_kernel);
h_shift = (filter_width-1)/2+1;
v_shift = (filter_height-1)/2+1;
output = output(v_shift:(v_shift+img_height-1),h_shift:(h_shift+img_width-1),:);
end