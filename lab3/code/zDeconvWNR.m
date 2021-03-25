function f0 = zDeconvWNR(f, k, C)
% This is the Weiner deconvolution algorithm using 1/f law
% f: defocused image
% k: defocus kernel
% C: sigma^2/A
	[hei, wid] = size(f);

	k = zPSFPad(k, hei, wid);
	k = fft2(fftshift(k));

	f0 = abs(ifft2((fft2(f).*conj(k))./(k.*conj(k) + C)));

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

function outK = zPSFPad(inK, hei, wid);
% This function is to zeropadding the psf
	[shei, swid] = size(inK);
	outK = zeros(hei, wid);
	outK(floor(end/2-shei/2)+1:floor(end/2-shei/2)+shei, floor(end/2-swid/2)+1:floor(end/2-swid/2)+swid) = inK;
