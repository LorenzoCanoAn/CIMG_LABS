# CImg - Laboratory 1

The following files have been modified in order to recreate the laboratory steps requested.

- lab1.m
- my_imfilter.m

As some convolution operations are requested on this laboratory, Fourier convolutions are used. Which is implemented on **my_imfilter.m**

When using ".CR2" RAW files, they are transformated to TIFF. To do so, dcraw.exe is requested to be in the workspace path.

## Launch 🚀

lab1.m:

Parameters

- General
  - image_name = Image name
  - image_ext = Image extension
  - image_path = Image path
  - PLOT = 0 if no plots requested, 1 otherwise
- Denoising:
  - meank: kernel used in the mean denoising.
  - gausk: kernel to be used in the gaussian denosing.
  - medik: size of the window of the median denoising.
- Color correction:
  - saturation_increase: scale to apply to the saturation channel of the HSV version of the image.
  - brightness_increse: scale to apply to the brightness channel of the HSV version of the image.
- Tone balancing:
  - gamma: gamma exponent of the gamma encoding step.
  - alpha: alpha exponent of the exposure correction step.
- saving:
  - save_pah: path of the folder where to save the final images.
  - format: format in which to encode the final images. Can use any format of the available for the MATLAB's "imwrite" function.

Instructions:

The file contains all the possible combinations of the different approaches to process the image.

To use the different combination, just uncomment de names related with each approach, and the related code lines.
