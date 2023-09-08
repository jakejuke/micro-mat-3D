# About Data

Some example data files are provided here.

# Data Structure

Generally, there are two arrays for each data set:
1. A **cell array** containing labelled 3D data and
2. A **structure array** containing info and grain stats.


## Labelled 3D Data (Cell Arrays)

Labelled grain data is stored cell arrays, the length of which is equal to the number of time steps (e.g. if there are four measurements, the cell array will have a length of 4).

Each cell contains a 3D matrix with dimensions of the sample volume. For the Black Hole, the dimensions are 321 rows x 321 columns x 531 slices. To save memory, the values in these matrices are set to *uint16* (unsigned 16-bit integer). To access slice 250 of the 2nd measurement use this notation: `full3Ds{2}(:,:,250)`


![Black Hole bh cell array full3Ds](/assets/images/bh_example_full3Ds.png)

View of the cell array *full3Ds* for the Black Hole specimen in Matlab.

## Grain and Time-Step Info (Structure Arrays)

Info about the grains is stored in a structure array. The length of the structure array is equivalent to the number of time steps. A lot of the analysis code can be run without loading the 3D data, because many parameters like grain size, neighbor grains, boundary voxels, etc. are stored in the fields of this structure. To access the grain radii for time step 2, type: `fullGTs(2).gradius`

![Black Hole bh cell array full3Ds](/assets/images/bh_example_fullGTs.png)

View of the structure array *fullGTs* for the Black Hole specimen in Matlab.

### Field descriptions

Hopefully the field names are somewhat self-explanatory, but here is a short list of the more important fields:
- timestep: time step name (char)
- labels: N-by-1 array of unique grain labels (double)
- orient: N-by-3 array of Rodrigues vectors (double)
- centroid: N-by-3 array of x, y, z positions of each grain's center of mass (double)
- gradius: N-by-1 array of grain radii (double)
- time: annealing time (double)
- badGrain: indicates grains that touch the very top/bottom of the sample volume (logical)
- gbArea: N-by-1 array number of boundary voxels (double)
- gbMat: N+1-by-N+1 matrix with shared GB areas (double) **Add more info/image**


# Naming Conventions

| Variable      | Description   |
| ------------- | ------------- |
| full3Ds       | Full 3D Grain Matrices <br /> Cell array with 3D matrices of labelled grains (grain IDs) for each time step |
| fullGTs       | Full Grain Tables <br /> Struct array with info and grain stats for each time step      |
| mtkGTs        | Manually Tracked Grain Tables <br /> Some grains between time steps were not tracked automatically. These I had to track manually and this structure has fields like tkbestg (e.g. track best guess). |
| reg3Ds        | Registered 3D Grain Matrices <br /> This array contains the registered 3D data. Because registration can slightly change the number of voxels assigned to a given grain (interpolation), I did all the analysis on the full3Ds but then used the reg3Ds to make images. |
| utk3Ds        | Untracked 3D Grain Matrices <br /> As the name implies, 3D matrices of untracked grains. These usually appear at the top/bottom of the sample volume. |
| utkGTs        | Untracked Grain Tables <br /> Info and stats for the untracked grains. |
