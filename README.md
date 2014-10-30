brain_image_processing
======================

Video processing pipeline for Dulac lab

Project is all about converting existing workstation-based GUI code to
cluster-based batch processing code that runs under SLURM on Odyssey, our cluster
at HU FAS RC.

*Parts/Steps of the workflow*

1. Downsample the image with an ImageJ macro using a fast Fourier transform with
   high-pass and low-pass parameters
   
2. 


*Approach*

1. Convert the GUI-based macro to a Fiji headless macro. Really, I'd like to move this
   over to MATLAB, but I'd like to keep the processing parts as similar as possible
   for now. (Mantra: optimize later...)

2. ...


10/30/14, rmf
