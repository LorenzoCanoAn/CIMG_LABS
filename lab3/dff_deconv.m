sigma = 0.01;
blurSize = 5;
i = 0;

for aper = {'raskar','Levin','zhou'}
    aper = aper{1};
    for sigma = 1%[0.1,0.01]
        for blurSize = 10%[5,10]
            % Read data
            aperture = imread(strcat('apertures/',aper,'.bmp'));
            image = imread('images/castle.jpg');
            image = image(:,:,1);
            
            disp(['Noise= ', num2str(sigma), ' Blur= ', num2str(blurSize)]);
            
            % Normalization
            temp = fspecial('disk', blurSize);
            flow = max(temp(:));
            
            f0 = im2double(image);
            [h, w, ch] = size(f0);
            
            % Prior matrix: 1/f law
            AStar = eMakePrior(h, w)+0.00000001;
            C = sigma.^2*h*w./AStar;
            
            % Pattern
            k1 = im2double(imresize(aperture, [2*blurSize+1, 2*blurSize+1], 'nearest'));
            k1 = k1*(flow/max(k1(:)));
            min_ = min(k1,[],'all');max_ = max(k1,[],'all');
            figure;
            imshow(k1,[min_,max_]);
            
            % Apply blur
            f1 = zDefocused(f0, k1, sigma);
         
            % Recover
            f0_wnr = zDeconvWNR(f1, k1,C);
            f0_wnrn= deconvwnr(f1,k1);
            f0_luc = deconvlucy(f1,k1,20);
            
            figure('Position', [10 10 900 300]);
            subplot_tight(1,4,1)
            imshow(f1);
            title({strcat('Sigma=',num2str(sigma)),strcat('Size=',num2str(blurSize))});
            subplot_tight(1,4,2)
            imshow(f0_wnr);
            title('Weiner with prior');
            subplot_tight(1,4,3)
            imshow(f0_wnrn);
            title('Weiner no prior');
            subplot_tight(1,4,4)
            imshow(f0_luc);
            title('Lucy');
            
            filename = strcat("results/many/",aper,"_",num2str(sigma),"_b",num2str(blurSize),".png");
            saveas(gcf,filename,"png");
            close all
        end
    end
end
