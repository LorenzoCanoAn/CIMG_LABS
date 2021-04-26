folders = dir("../data/Section1_SeveralCaptures");
folders = folders(3:end);

for folder = folders'
    disp(fullfile(folder.folder,folder.name))
    images = imgScanner(fullfile(folder.folder,folder.name));
end