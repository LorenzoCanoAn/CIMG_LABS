function result = imgScanner (rel)
% This function takes a directory as an input. The elements inside the
% directory are expected to be images, where the name of the image is
% expected to be of the form:
% {a}_{b}.{format}. So that a/b is the exposure time of the image. 

% Given that, this function will return an array with the images, and an 
% array with the exposure times, as members of the "result" object.


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