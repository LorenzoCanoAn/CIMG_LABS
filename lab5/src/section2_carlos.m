data_folder = "../data/Section2_SingleCapture";
files = dir(data_folder);
files = files(3:end);
global params
params.kernel = ones(1,10)/10;
params.c1 = 0.8;
params.c2 = 0.1;
params.c3 = 0.1;


for file = files'
    image = im2double(imread(fullfile(file.folder,file.name)));

    hsv_image = rgb2hsv(image);

    convImage = conv2(hsv_image(:,:,3),params.kernel,'same');

    i_max = hsv_image(:,:,3) > convImage;
    i_min = ~i_max ;

    Lmin = image.*(i_min);
    Lmax = image.*(i_max);

    figure();
    imshow(Lmin);
    figure;
    imshow(Lmax);

    Lmin = special_interpolation(Lmin,i_min);
    Lmax = special_interpolation(Lmax,i_max);


    b=0.8;
    c = (1+b)/2;
    Lg = (Lmax-Lmin/b)/(c-c/b);
    Ld = Lmax-c*Lg;

    figure;
    montage({Lmax,Lmin,Lg,Ld},'BorderSize',[0 0],'Size',[2 2]);
    figure;
    imshow(Lg+Ld);
end
% Interpolate Lmin and Lmax



function interpolated = special_interpolation(image,bool_image)
    global params
    interpolated = image;
    [p_i,p_j] = find(~bool_image);

    [n_pixels,~] = size(p_i);
    tic
    for i = 1:n_pixels
            level_1 = find_level(image,bool_image,p_i(i),p_j(i));
            interpolated(p_i(i),p_j(i),:)=(level_1(1,:)*params.c1 +level_1(2,:)*params.c2 + level_1(3,:)*params.c3);
    end
    disp(toc)
end


function l1=find_level(image,bool_mask,i_0,j_0)
[height,width] = size(bool_mask);

count = [0 0 0];
l = zeros(3,3);

% Upper pixel
level = 1;
for i = i_0:-1:max(i_0-10,1)
    if bool_mask(i,j_0)
        count(level) = count(level) + 1;
        l(level,:) = l(level) + image(i,j_0,:);
        level= level +1;
        if level == 3
            break
        end
    end
end

level = 1;
% Lower pixel
for i =  i_0:min(i_0+10,height)
    if bool_mask(i,j_0)
        count(level) = count(level) + 1;
        l(level,:) = l(level) + image(i,j_0,:);
        level= level +1;
        if level == 3
            break
        end
    end
end
level = 1;
% Left pixel
for j = j_0:-1:max(1,j_0-10)
    if bool_mask(i_0,j)
        count(level) = count(level) + 1;
        l(level,:) = l(level) + image(i_0,j,:);
        level= level +1;
        if level == 3
            break
        end
    end
end
level = 1;
% Right pixel
for j = j_0:min(width,j_0+10)
    if bool_mask(i_0,j)
        count(level) = count(level) + 1;
        l(level,:) = l(level) + image(i_0,j,:);
        level= level +1;
        if level == 3
            break
        end
    end
end
level = 2;
%upper right
for n = 1:10
    i = i_0+n;
    j = j_0+n;
     if(i >= height || j >= width)
        break
    end
    if bool_mask(i,j)
        count(level) = count(level) + 1;
        l(level,:) = l(level) + image(i,j,:);
        level= level +1;
        if level == 4
            break
        end
    end
end
level = 2;
%upper left
for n = 1:10
    i = i_0-n;
    j = j_0+n;
     if(i <= 0 || j >= width)
        break
    end
    if bool_mask(i,j)
        count(level) = count(level) + 1;
        l(level,:) = l(level) + image(i,j,:);
        level= level +1;
        if level == 4
            break
        end
    end
end
level = 2;
%lower right
for n = 1:10
    i = i_0+n;
    j = j_0-n;
    if(i >= height || j <= 0)
        break
    end
    if bool_mask(i,j)
        count(level) = count(level) + 1;
        l(level,:) = l(level) + image(i,j,:);
        level= level +1;
        if level == 4
            break
        end
    end
end
level = 2;
%lower left
for n = 1:10
    i = i_0-n;
    j = j_0-n;
     if(i <= 0 || j <= 0)
        break
    end
    if bool_mask(i,j)
        count(level) = count(level) + 1;
        l(level,:) = l(level) + image(i,j,:);
        level= level +1;
        if level == 4
            break
        end
    end
end
l1 = l./count';

end
