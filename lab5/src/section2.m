data_folder = "../data/Section2_SingleCapture";
files = dir(data_folder);
files = files(3:end);

for file = files'
    image = imread(fullfile(file.folder,file.name));
    [Lmin,Lmax] = get_Lmin_Lmax(image);
    
end



function [Lmin, Lmax] = get_Lmin_Lmax(image)
    Lmin = get_Lmin(image);
    Lmax = get_Lmax(image);
end
function Lmin = get_Lmin(image)
    
end

function Lmax = get_Lmax(image)

end