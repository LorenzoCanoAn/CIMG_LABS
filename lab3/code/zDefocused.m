function f = zDefocused(f0, k, sigma, flag)
% This function is to simulate the defocus
	if nargin<4
		flag = 0;
	end;

	[hei, wid] = size(f0);

	if flag==1 %Assume the defocus is circular convolution
		k = zPSFPad(k, hei, wid);
		k = fft2(fftshift(k));
		f = abs(ifft2(fft2(f0).*k)) + randn(hei, wid)*sigma;
	else %Not make that assumption. But in this case, because of the boundary effects, the "effective" noise level is very high.
		k = fliplr(flipud(k));
		f = imfilter(f0, k) + randn(hei, wid)*sigma;
end;
