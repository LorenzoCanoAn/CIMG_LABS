folders = dir("../data/Section1_SeveralCaptures");
folders = folders(3:end);
b = 0.1;

for folder = folders'
    disp(fullfile(folder.folder,folder.name))
    images = imgScanner(fullfile(folder.folder,folder.name));
    [Lmax, Lmin] = get_max_min(images);
    
    c = (1+b)/2;
    Lg = (Lmax-Lmin/b)/(c-c/b);
    Ld = Lmax-c*Lg;
    
    figure;
    montage({Lmax,Lg,Ld});
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