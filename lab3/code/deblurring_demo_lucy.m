LUCY = 1;
WIENER = 1;
noises = [0.005, 0.01, 0.05, 0.1];
iters  = [1, 2, 5, 10, 20, 50];
for sigma = noises
    for iter = iters
        % Read data
        aperture = imread('apertures/circular.bmp');
        image = imread('images/penguins.jpg');
        image = image(:,:,1);
        
        % Noise level (gaussian noise)
        % sigma = 0.005;
        % Blur size
        blurSize = 7;
        
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
        
        % Apply blur
        f1 = zDefocused(f0, k1, sigma);
        
        % Recover
        if WIENER
            f0_hat = zDeconvWNR(f1, k1, C);
            figure;
            subplot_tight(1,3,1, 0.0)
            imshow(f0);
            title('Focused');
            subplot_tight(1,3,2, 0.0)
            imshow(f1);
            title('Defocused');
            subplot_tight(1,3,3, 0.0)
            imshow(f0_hat);
            title('Recovered');
            filename = strcat("results/WNR_s",num2str(sigma)," b",num2str(blurSize),".png");
            saveas(gcf,filename,"png");
            close all
        end
        if LUCY
            f0_hat = deconvlucy(f1, k1, iter);
            figure;
            subplot_tight(1,3,1, 0.0)
            imshow(f0);
            title('Focused');
            subplot_tight(1,3,2, 0.0)
            imshow(f1);
            title('Defocused');
            subplot_tight(1,3,3, 0.0)
            imshow(f0_hat);
            title('Recovered');
            filename = strcat("results/LUCY_s",num2str(sigma)," ","n",num2str(iter)," b",num2str(blurSize),".png");
            saveas(gcf,filename,"png");
            close all
            
        end
    end
end