function result = imgScanner (rel)

    % Dir read
    ls = dir(rel);
    ls = ls(3:end);
   
    % Name and obturation 
    names = {ls.name}; 
    str = split(names,".");
    str = split(str(:,:,1),"_");

    result.obt = [];
    result.img = {};
    
    for i = 1 : length(str)
        result.obt = [result.obt str2double(str(1,i,1))/str2double(str(1,i,2))];
        result.img{end+1} = imread(rel+names(i));
    end
    
end