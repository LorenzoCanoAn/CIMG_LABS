#LAB 6

This is the 6th Assignment from Computational Image Course

The algorithm has been optimized so that it only needs to loop over the three dimensions of the discretized volume.
The script makes a lot of use of global variables to avoid having to pass a lot of data to the functions.


## Set Up

Use section 1 file to recreate the final results of the assignment.

Previous execution of the section1.m file, the following variables must be set: 

#5 params.data.folder --> The container folder where the data has been placed.
#6 volshow_conf_path --> The relative path to the volshow config file (the name of the file must be included)

## Dataset nomenclature

confocal data has c=[NxN] in the filename instead of l=[NxN]_s=[MxM]


## Launch

The execution of the file will loop over every sample placed at the folder path settled at the previous section.
This will create three different voxel size versions of the scenario (8 , 16, 32).


##Time consumption:
8 Voxels --> Elapsed time is 0.842385 seconds.
16 Voxels --> Elapsed time is 6.743650 seconds.
32 Voxels -->Elapsed time is 53.607872 seconds.