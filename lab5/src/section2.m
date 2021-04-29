data_folder = "../data/Section2_SingleCapture";
files = dir(data_folder);
global params
params.c1 = 0.8;
params.c2 = 0.1;
params.c3 = 0.1;
params.b = 0.4;
params.radius = 10;
params.limit = 20;

for n_file = 3
    %% Load image Lmin_i
%     file = files(n_file);
%     image = double(imread(fullfile(file.folder,file.name)))/255.0;
%     
%     %% Get Lmin and Lmax
%     [Lmin, Lmax] = get_Lmin_Lmax(image);
%     imwrite(Lmin,   strcat("../results/sec2/g",num2str(n_file),"_lmin.jpg"))
%     imwrite(Lmax,   strcat("../results/sec2/g",num2str(n_file),"_lmax.jpg"))
    
    %% First version of interpolatio
%     Lmin_i = interpolation_whole_pixel(Lmin);
%     imshow(Lmin_i);
%     Lmax_i = interpolation_whole_pixel(Lmax);
%     [Lg,Ld] = decompose(Lmin_i,Lmax_i);
%     
%     figure;
%     montage({Lmin,Lmax,Ld,...
%         Lmin_i,Lmax_i,Lg});
% 
%     imwrite(Lmax_i, strcat("../results/sec2/it",num2str(n_file),"_lmax_i.jpg"))
%     imwrite(Lmin_i, strcat("../results/sec2/it",num2str(n_file),"_lmin_i.jpg"))
%     imwrite(Ld,     strcat("../results/sec2/it",num2str(n_file),"_ld.jpg"))
%     imwrite(Lg,     strcat("../results/sec2/it",num2str(n_file),"_lg.jpg"))

    %% Second version of interpolation
    Lmin_i = interpolation_per_channel(Lmin);
    Lmax_i = interpolation_per_channel(Lmax);

    [Lg,Ld] = decompose(Lmin_i,Lmax_i);
    
    
    imshow(cat(2,Ld,Lg));
    
    imwrite(Lmax_i, strcat("../results/sec2/ic",num2str(n_file),"_lmax_i.jpg"))
    imwrite(Lmin_i, strcat("../results/sec2/ic",num2str(n_file),"_lmin_i.jpg"))
    imwrite(Ld,     strcat("../results/sec2/ic",num2str(n_file),"_ld.jpg"))
    imwrite(Lg,     strcat("../results/sec2/ic",num2str(n_file),"_lg.jpg"))
    
end

function [Lg,Ld] = decompose(Lmin,Lmax)
    global params
    b = params.b;
    c = (1+b)/2;
    Lg = (Lmax-Lmin/b)/(c-c/b);
    Ld = Lmax-c*Lg;
end

function [Lmin, Lmax] = get_Lmin_Lmax(image)
global params
Lmin = zeros(size(image));
Lmax = zeros(size(image));
for ch = 1:3
    brightness = image(:,:,ch);
    [height,width] = size(brightness);
    stack = zeros(height,width,10);
    i = 0;
    for shift = (-params.radius):(params.radius)
        i = i+1;
        stack(:,:,i)=imtranslate(brightness,[shift,0]);
    end
    
    sum_image = sum(double(stack ~= 0),3);
    meanImage = sum(stack,3);
    meanImage = meanImage./sum_image;
    
    
    i_max = brightness > meanImage;
    i_min = ~i_max;
    Lmin(:,:,ch) = brightness.*double(i_min);
    Lmax(:,:,ch) = brightness.*double(i_max);
end
end

function interpolated = interpolation_whole_pixel(image)
global params
[height, width, ~] = size(image);
dirs = [-1,-1,-1,0,1,1, 1, 0;...
    -1, 0, 1,1,1,0,-1,-1];

ls = uint8([2,1,2,1,2,1,2,1;...
    3,2,3,2,3,2,3,2]);



pixels_to_change = double(sum(uint8(image == 0),3)==0);


clean_image = image .* double(pixels_to_change);
interpolated = clean_image;
bool_image = pixels_to_change ~= 0;
[p_i,p_j] = find(pixels_to_change==0);

[n_pixels,~] = size(p_i);

for n = 1:n_pixels %% loop over empty pixels
    cumul_l = zeros(1,1,3,3);
    count = zeros(1,3);
    i_0 = p_i(n);
    j_0 = p_j(n);
    for d = 1:8 % loop over directions
        delta_i = dirs(1,d);
        delta_j = dirs(2,d);
        b = 0;
        t = 0;
        while b < 2 % go along direction
            t = t + 1;
            i = i_0 + delta_i*t;
            j = j_0 + delta_j*t;
            if i <=0 || i > height || j <= 0 || j> width || t > params.limit
                break
            end
            if bool_image(i,j)
                b = b+1;
                cumul_l(:,:,:,ls(b,d)) = cumul_l(:,:,:,ls(b,d)) + double(clean_image(i,j,:));
                count(ls(b,d)) = count(ls(b,d))+1.0;
            end
        end
    end
    interpolated(i_0,j_0,:)=    cumul_l(:,:,:,1)*params.c1/count(1)+...
        cumul_l(:,:,:,2)*params.c2/count(2)+...
        cumul_l(:,:,:,3)*params.c3/count(3);
    
end
end

function interpolated = interpolation_per_channel(image)
global params
[height, width, ch] = size(image);
dirs = [-1,-1,-1,0,1,1, 1, 0;...
    -1, 0, 1,1,1,0,-1,-1];

ls = uint8([2,1,2,1,2,1,2,1;...
    3,2,3,2,3,2,3,2]);
interpolated = image;

for nch = 1:ch
    pixels_to_change = image(:,:,nch) == 0;
    [p_i,p_j] = find(pixels_to_change);

    [n_pixels,~] = size(p_i);

    for n = 1:n_pixels %% loop over empty pixels
        cumul_l = zeros(1,3);
        count = zeros(1,3);
        i_0 = p_i(n);
        j_0 = p_j(n);
        for d = 1:8 % loop over directions
            delta_i = dirs(1,d);
            delta_j = dirs(2,d);
            b = 0;
            t = 0;
            while b < 2 % go along direction
                t = t + 1;
                i = i_0 + delta_i*t;
                j = j_0 + delta_j*t;
                if i <=0 || i > height || j <= 0 || j> width || t > params.limit
                    break
                end
                if ~pixels_to_change(i,j)
                    b = b+1;
                    cumul_l(1,ls(b,d)) = cumul_l(1,ls(b,d)) + double(image(i,j,nch));
                    count(ls(b,d)) = count(ls(b,d))+1.0;
                end
            end
        end
        interpolated(i_0,j_0,nch)=    cumul_l(1,1)*params.c1/count(1)+...
                                    cumul_l(1,2)*params.c2/count(2)+...
                                    cumul_l(1,3)*params.c3/count(3);

    end
end
end