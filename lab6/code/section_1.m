%% PARAMETERS
global params
global data
global rec
params.exCon.load_data = false;
params.exCon.load_volshowConfig = false;
params.data.folder = "../data";
params.data.file = "Z_d=0.5_l=[1x1]_s=[256x256].hdf5";
params.data.path = fullfile(params.data.folder,params.data.file);
params.rec.disc_env_size = [1,1,1]*16;
params.c = 299792458.0;
%% LOAD DATA
if params.exCon.load_volshowConfig
    load("volshow_config.mat");
end
if params.exCon.load_data
    data = load_hdf5_dataset(params.data.path);
end
%% RECONSTRUCTION

rec.G = zeros(params.rec.disc_env_size);
rec.G_c = gen_voxel_coords();

for i_v = 1:params.rec.disc_env_size(1) % loop over x
    for j_v = 1:params.rec.disc_env_size(1) % loop over y
        for k_v = 1:params.rec.disc_env_size(1) % loop over z
            s_p_s = size(data.spadPositions);
            l_p_s = size(data.laserPositions);
            
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

%% Laplacian filter
f_lap = fspecial('lap');
G_lap = imfilter(rec.G,-f_lap,'symmetric');


volshow(rec.G, volshow_config);
figure;
volshow(G_lap,volshow_config);


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
