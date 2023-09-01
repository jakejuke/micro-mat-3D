# About Data

Some example data files are provided here.

# Data Structure

Generally, there are two arrays for each data set:
1. a cell array containing labelled 3D data and
2. a structure array containing info and grain stats.


## Labelled 3D Data (Cell Arrays)

Labelled grain data is stored cell arrays, the length of which is equal to the number of time steps (e.g. if there are four measurements, the cell array will have a length of 4).

Each cell contains a 3D matrix with dimensions of the sample volume. For the Black Hole, the dimensions are 321 rows x 321 columns x 531 slices. To access slice 250 of the 2nd measurement use this notation:

`full3Ds{2}(:,:,250)`

![Black Hole bh cell array full3Ds](/assets/images/bh_example_full3Ds.png)

## Grain and Time Step Info (Structure Arrays)

Info about the grains is stored in a structure.



# Test image

Can I insert images here?

![Test image](/assets/images/quadratics.png)
