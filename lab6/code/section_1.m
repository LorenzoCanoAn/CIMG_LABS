%% PARAMETERS
global params
global data
global rec
params.data.folder = "../data";
params.data.file = "Z_d=0.5_l=[1x1]_s=[256x256].hdf5";
params.data.path = fullfile(params.data.folder,params.data.file);
params.rec.disc_env_size = [1,1,1]*16;
params.saveFolder = "../images_";
load("volshow_config.mat");
mkdir(params.saveFolder);
files = dir(params.data.folder);
files = files(3:end)';
for file = files
    %% LOAD DATA
    params.data.path = fullfile(params.data.folder,file.name);
    data = load_hdf5_dataset(params.data.path);
    [~,o_filename,~] = fileparts(file.name);
    disp(o_filename);
    wxd = [8, 16, 32];
    for volSize = wxd
        disp(volSize)
        params.rec.disc_env_size = [1,1,1]*volSize;
        
        %% RECONSTRUCTION
        tic
        if data.isConfocal
            confocal_rec_fast()
        else
            normal_rec_fast() 
        end
        toc
        %% Laplacian filter
        f_lap = fspecial('lap');
        G_lap = imfilter(rec.G,-f_lap,'symmetric');
        
        volshow(rec.G, volshow_config);
        filename = strcat(o_filename,"_",num2str(volSize),"_nf",".jpg");
        filename = fullfile(params.saveFolder,filename);
        imwrite(getframe(gcf).cdata, filename)
        close all;
        volshow(G_lap,volshow_config);
        filename = strcat(o_filename,"_",num2str(volSize),"_f",".jpg");
        filename = fullfile(params.saveFolder,filename);
        imwrite(getframe(gcf).cdata, filename)
        close all;
    end
end

%% Functions

function vox_coords = gen_voxel_coords()
    global params
    global data
    n_steps = params.rec.disc_env_size(1);
    step_size = data.volumeSize / n_steps;
    
    x_0 = data.volumePosition(1) - step_size*(0.5+n_steps/2);
    y_0 = data.volumePosition(2) - step_size*(0.5+n_steps/2);
    z_0 = data.volumePosition(3) - step_size*(0.5+n_steps/2);
    
    vox_coords = zeros([n_steps,n_steps,n_steps,3]);
    for i = 1:n_steps
        for j = 1:n_steps
            for k = 1:n_steps
                vox_coords(i,j,k,1) = x_0 + i*step_size;
                vox_coords(i,j,k,2) = y_0 + j*step_size;
                vox_coords(i,j,k,3) = z_0 + k*step_size;
            end
        end
    end
end

function normal_rec_fast()

global params
global rec
global data

rec.G = zeros(params.rec.disc_env_size);
rec.G_c = gen_voxel_coords();
s_s = size(data.spadPositions);
nsp = s_s(1)*s_s(2);
l_s = size(data.laserPositions);
nlp = l_s(1)*l_s(2);

d1s = sqrt(sum(reshape(data.laserPositions - reshape(data.laserOrigin, 1,1,3),1,[],3).^2,3));
d4s = sqrt(sum(reshape(data.spadPositions - reshape(data.spadOrigin, 1,1,3),1,[],3).^2,3));



for i_v = 1:params.rec.disc_env_size(1) % loop over x
    for j_v = 1:params.rec.disc_env_size(1) % loop over y
        for k_v = 1:params.rec.disc_env_size(1) % loop over z
            x_v = reshape(rec.G_c(i_v,j_v,k_v,:),[1,1,3]);
            
            d2s = sqrt(sum(reshape(data.laserPositions - x_v,1,[],3).^2,3));
            d3s = sqrt(sum(reshape(data.spadPositions - x_v,1,[],3).^2,3));
            
            d12s = d1s+d2s;
            d34s = d3s+d4s;
            t = zeros(1,nsp*nlp);
            for n = 1:nsp
                t((1+(n-1)*nlp):(n*nlp))=ones(1,nlp)*d34s(n)+d12s;
            end
            t = uint32((t-data.t0)/data.deltaT);
            access_index = uint32(1:(nlp*nsp));
            access_index = access_index + uint32(t-1) * (nlp*nsp);
            rec.G(i_v,j_v,k_v) = sum(data.data(access_index),'all');
        end
    end
end

end

function confocal_rec_fast()
global params
global rec
global data

rec.G = zeros(params.rec.disc_env_size);
rec.G_c = gen_voxel_coords();
s_s = size(data.spadPositions);
nsp = s_s(1)*s_s(2);

d1s = sqrt(sum(reshape(data.laserPositions - reshape(data.laserOrigin, 1,1,3),1,[],3).^2,3));
d4s = sqrt(sum(reshape(data.spadPositions - reshape(data.spadOrigin, 1,1,3),1,[],3).^2,3));

for i_v = 1:params.rec.disc_env_size(1) % loop over x
    for j_v = 1:params.rec.disc_env_size(2) % loop over y
        for k_v = 1:params.rec.disc_env_size(3) % loop over z
            x_v = reshape(rec.G_c(i_v,j_v,k_v,:),[1,1,3]);    
            
            d2s = sqrt(sum(reshape(data.spadPositions - x_v,1,[],3).^2,3));
            d3s = d2s;
            
            t = d1s + d2s + d3s + d4s;

            t = uint32((t-data.t0)/data.deltaT);
            access_index = uint32(1:(nsp));
            access_index = access_index + uint32(t-1) * (nsp);
            rec.G(i_v,j_v,k_v) = sum(data.data(access_index),'all');

        end
    end
end

end

function confocal_rec()
global params
global rec
global data

rec.G = zeros(params.rec.disc_env_size);
rec.G_c = gen_voxel_coords();
n_p_ls = size(data.spadPositions);            

for i_v = 1:params.rec.disc_env_size(1) % loop over x
    for j_v = 1:params.rec.disc_env_size(2) % loop over y
        for k_v = 1:params.rec.disc_env_size(3) % loop over z
            x_v = reshape(rec.G_c(i_v,j_v,k_v,:),[3,1]);    
            
            for i_ls = 1:n_p_ls (1)
                for j_ls = 1:n_p_ls (2)
                            x_ls = reshape(data.spadPositions(i_ls,j_ls,:),[3,1]);
                            
                            d1 = sqrt(sum((data.laserOrigin - x_ls).^2));
                            d2 = sqrt(sum((x_ls-x_v).^2));
                            d3 = d2;
                            d4 = sqrt(sum((x_ls - data.spadOrigin).^2));
                            t = (d1+d2+d3+d4);
                            
                            t = uint32((t - data.t0)/data.deltaT);
                            rec.G(i_v,j_v,k_v) = rec.G(i_v,j_v,k_v) + data.data(i_ls,j_ls,t);
                end
            end
        end
    end
end

end

function normal_rec()

global params
global rec
global data

rec.G = zeros(params.rec.disc_env_size);
rec.G_c = gen_voxel_coords();
s_p_s = size(data.spadPositions);
l_p_s = size(data.laserPositions);

for i_v = 1:params.rec.disc_env_size(1) % loop over x
    for j_v = 1:params.rec.disc_env_size(1) % loop over y
        for k_v = 1:params.rec.disc_env_size(1) % loop over z
            
            x_v = reshape(rec.G_c(i_v,j_v,k_v,:),[3,1]);
            
            for i_l = 1:l_p_s(1)
                for j_l = 1:l_p_s(2)
                    x_l = reshape(data.laserPositions(i_l,j_l,:),[1,1,3]);
                    for i_s = 1:s_p_s(1)
                        for j_s = 1:s_p_s(2)
                            x_s = reshape(data.spadPositions(i_s,j_s,:),[3,1]);
                            d1 = sqrt(sum((data.laserOrigin - x_l).^2));
                            d2 = sqrt(sum((x_l-x_v).^2));
                            d3 = sqrt(sum((x_v - x_s).^2));
                            d4 = sqrt(sum((x_s - data.spadOrigin).^2));
                            t = (d1+d2+d3+d4);
                            
                            t = uint32((t - data.t0)/data.deltaT);
                            rec.G(i_v,j_v,k_v) = rec.G(i_v,j_v,k_v) + data.data(i_l,j_l,i_s,j_s,t);
                        end
                    end
                end
            end
        end
    end
end

end

function rec_norm_mod()

global params
global rec
global data

rec.G = zeros(params.rec.disc_env_size);
rec.G_c = gen_voxel_coords();
s_p_s = size(data.spadPositions);
l_p_s = size(data.laserPositions);

for i_v = 1:params.rec.disc_env_size(1) % loop over x
    for j_v = 1:params.rec.disc_env_size(1) % loop over y
        for k_v = 1:params.rec.disc_env_size(1) % loop over z
            
            x_v = reshape(rec.G_c(i_v,j_v,k_v,:),[3,1]);
            
            for i_l = 1:l_p_s(1)
                for j_l = 1:l_p_s(2)
                    x_l = reshape(data.laserPositions(i_l,j_l,:),[3,1]);
                    for i_s = 1:s_p_s(1)
                        for j_s = 1:s_p_s(2)
                            x_s = reshape(data.spadPositions(i_s,j_s,:),[3,1]);
                            d1 = sqrt(sum((data.laserOrigin - x_l).^2));
                            d2 = sqrt(sum((x_l-x_v).^2));
                            d3 = sqrt(sum((x_v - x_s).^2));
                            d4 = sqrt(sum((x_s - data.spadOrigin).^2));
                            t = (d1+d2+d3+d4);
                            
                            t = uint32((t - data.t0)/data.deltaT);
                            rec.G(i_v,j_v,k_v) = rec.G(i_v,j_v,k_v) + data.data(i_l,j_l,i_s,j_s,t);
                        end
                    end
                end
            end
        end
    end
end

end
