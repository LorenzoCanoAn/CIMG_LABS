data_folder = "../data/Section2_SingleCapture";
files = dir(data_folder);
files = files(4:end);
global params
params.kernel = ones(1,10)/10;
params.c1 = 0.8;
params.c2 = 0.1;
params.c3 = 0.1;

for file = files'
    image = imread(fullfile(file.folder,file.name));
    % Get Lmin and Lmax
    [Lmin,Lmax] = get_Lmin_Lmax(image);
    % Interpolate Lmin and Lmax
    
end



function [Lmin, Lmax] = get_Lmin_Lmax(image)

global params
hsv_image = rgb2hsv(image);

convImage = conv2(hsv_image(:,:,3),params.kernel,'same');
i_max = hsv_image(:,:,3) > convImage;
i_min = ~i_max;

Lmin = image.*uint8(i_min);
Lmax = image.*uint8(i_max);

Lmin_i = special_interpolation(Lmin,i_min);

end

function interpolated = special_interpolation(image,bool_image)
interpolated = image;
[p_i,p_j] = find(~bool_image);

[n_pixels,~] = size(p_i);
tic
for i = 1:n_pixels
    level_1 = find_level_1(image,bool_image,p_i(i),p_j(i));
%     level_2 = find_level_1(image,bool_image,p_i(i),p_j(i));
%     level_3 = find_level_1(image,bool_image,p_i(i),p_j(i));
    interpolated(p_i(i),p_j(i),:)=level_1;
end
disp(toc)
end

function l1=find_level_1(image,bool_mask,i_0,j_0)
[height,width] = size(bool_mask);
count = 0;
l1 = uint8(zeros(1,1,3));
% Upper pixel
for n = 1:10
    i = i_0 - n;
    if i <= 0
        break
    end
    if bool_mask(i,j_0)
        count = count + 1;
        l1 = l1 + image(i,j_0,:);
        break
    end
end
% Lower pixel
for n = 1:10
    i = i_0 + n;
    if i > height
        break
    end
    if bool_mask(i,j_0)
        count = count + 1;
        l1 = l1 + image(i,j_0,:);
        break
    end
end
% Left pixel
for n = 1:10
    j = j_0 - n;
    if j <= 0
        break
    end
    if bool_mask(i_0,j)
        count = count + 1;
        l1 = l1 + image(i_0,j,:);
        break
    end
end
% Right pixel
for n = 1:10
    j = j_0 + n;
    if j >= width
        break
    end
    if bool_mask(i_0,j)
        count = count + 1;
        l1 = l1 + image(i_0,j,:);
        break
    end
end
l1 = l1/count;
end
function l2=find_level_2(image,bool_mask,i_0,j_0)
l2=0;
end
function l3=find_level_3(image,bool_mask,i_0,j_0)
l3=0;
end