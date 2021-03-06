data_folder = "../data/Section3_MobileEnvironment/";
files = dir(data_folder);
files = files(3:end);

b=0.1;
for file = files'
    image = folder_scanner(fullfile(file.folder,file.name));
    % Get Lmin and Lmax
    [Lmax,Lmin] = get_max_min(image);
   

    c = (1+b)/2;
    Lg = (Lmax-Lmin/b)/(c-c/b);
    Ld = Lmax-c*Lg;
    
    figure;
    montage({Lmax,Lg,Ld});
    montage({Lmax,Lmin,Lg,Ld});
end


function [maxImg, minImg] = get_max_min(images)
[~,iMax] = max(images(:,:,3,:),[],4);
[~,iMin] = min(images(:,:,3,:),[],4);
[height,width,channels,~] = size(images);
steps_per_image = height*width*channels;
iMax = reshape(iMax,1,[]);
iMin = reshape(iMin,1,[]);
index_max = 1:(height*width*channels);
index_min = 1:(height*width*channels);
cat_max = [(iMax-1)*steps_per_image,(iMax-1)*steps_per_image,(iMax-1)*steps_per_image];
cat_min = [(iMin-1)*steps_per_image,(iMin-1)*steps_per_image,(iMin-1)*steps_per_image];
index_max = index_max + cat_max;
index_min = index_min + cat_min;

maxImg = images(index_max);
minImg = images(index_min);
maxImg = hsv2rgb(reshape(maxImg,height,width,channels));
minImg = hsv2rgb(reshape(minImg,height,width,channels));

end


function result = folder_scanner (rel)
    %% Obtain elements inside directory
    ls = dir(rel);
    ls = ls(3:end);
    names = {ls.name};

    temp = imread(fullfile(rel,names{1}));
    s = size(temp);
    s = [s length(names)];
    result = zeros (s);

    %% Divide the names in the elements indicating exposure time
    for i = 1 : length(names)
        result(:,:,:,i) = rgb2hsv(imread(fullfile(rel,names{i})));
    end

end

