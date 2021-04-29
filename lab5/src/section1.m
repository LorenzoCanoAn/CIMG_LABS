clear params
folders = dir("../data/Section1_SeveralCaptures");
base_save_folder = "../results/sec1/";
mkdir(base_save_folder);
folders = folders(3:end);
global params
params.b = 0.001;

for folder = folders(1)'
    save_folder = strcat(base_save_folder,folder.name);
    mkdir(save_folder);
    disp(fullfile(folder.folder,folder.name))
    images = folder_scanner(fullfile(folder.folder,folder.name));
    [Lmax, Lmin] = get_max_min(images);
    [Lg,Ld] = decompose(Lmin,Lmax);
    imwrite(Lmax,strcat(save_folder,"/Lmax.jpg"));
    imwrite(Lmin,strcat(save_folder,"/Lmin.jpg"));
    imwrite(Lg,strcat(save_folder,"/Lg.jpg"));
    imwrite(Ld,strcat(save_folder,"/Ld.jpg"));
    figure;
    montage({Lg,Ld});
end

function [Lg,Ld] = decompose(Lmin,Lmax)
    global params
    b = params.b;
    c = (1+b)/2;
    Lg = (Lmax-Lmin/b)/(c-c/b);
    Ld = Lmax-c*Lg;
end
% function [Lg,Ld] = decompose(Lmin,Lmax)
%     global params
%     b = params.b;
%     c = (1+b)/2;
%     Lg = (Lmax*b-Lmin)/(c-b*c);
%     Ld = Lmax-c*Lg;
% end
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
% Obtain images inside directory and 
ls = dir(rel);
ls = ls(3:end);
names = {ls.name};

temp = imread(fullfile(rel,names{1}));
s = size(temp);
s = [s length(names)];
result = zeros (s);

for i = 1 : length(names)
    result(:,:,:,i) = rgb2hsv(imread(fullfile(rel,names{i})));
end

end
