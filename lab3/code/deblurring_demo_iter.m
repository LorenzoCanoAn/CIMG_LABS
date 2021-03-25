sigmas = [0.1];
blurs = [3, 5, 10, 20];
i = 0;
figure
for sigma = sigmas
    for blurSize = blurs
        i = i+1;
    % Read data
        aperture = imread('apertures/circular.bmp');
        image = imread('images/penguins.jpg');
        image = image(:,:,1);

        % Noise level (gaussian noise)
        %sigma = 0.005;
        % Blur size
        %blurSize = 14;

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
        f0_hat = zDeconvWNR(f1, k1,C);
        % 
        
        
        subplot_tight(2,2,i)
        imshow(f1);
        title(strcat('Size=',num2str(blurSize)));
      
        
    end
end
filename = strcat("results/sigma_and_size/vary_blur_noise.png");
saveas(gcf,filename,"png");
close all