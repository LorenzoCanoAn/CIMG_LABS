function result = imgScanner (rel)
% This function takes a directory as an input. The elements inside the
% directory are expected to be images, where the name of the image is
% expected to be of teh form:
% {a}_{b}.{format}. So that a/b is the exposure time of the image. 

% Given that, this function will return an array with the images, and an 
% array with the exposure times, as members of the "result" object.

%% Obtain elements inside directory
ls = dir(rel);
ls = ls(3:end);
names = {ls.name};

%% Divide the names in the elements indicating exposure time
parsed_names = split(names,".");
parsed_names = split(parsed_names(:,:,1),"_");

result.obt = [];
result.img = {};

for i = 1 : length(parsed_names)
    result.obt = [result.obt str2double(parsed_names(1,i,1))/str2double(parsed_names(1,i,2))];
    result.img{end+1} = imread(rel+names(i));
end

end