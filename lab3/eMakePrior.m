function prior = eMakePrior(hei, wid);
%A simple code to compute averaged power spectrum
%Input:  the prior size, and a set of images
%Output:  the expected/averaged power spectrum
	F02 = 0;
	count = 0;

	for ii = 1:7
		strImg = ['./priors/', num2str(ii), '.jpg'];
		f0 = im2double(imread(strImg));
		[heiL, widL] = size(f0);

		for ii = 1:round(hei/2):heiL-hei
		    for jj = 1:round(wid/2):widL-wid
		        F0 = fft2(f0(ii:ii+hei-1, jj:jj+wid-1));
		        F02 = F02+F0.*conj(F0);
		        count = count+1;
		    end;
		end;
	end;
	prior = F02/count;

