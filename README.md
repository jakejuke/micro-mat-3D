# micro-mat-3D

Microstructure of Materials in 3D

This repository contains scripts and functions (mostly in MATLAB) used to analyze and view 3D microstructural data. Much of the original code was written to analyze 3DXRD datasets that were recorded at SPring-8. This is why the prefix 'sp8' is used throughout the code.

## Workflow

Import 3D data, measurement or simulation.
The data needs to be in the form:
- a cell that contains one or more 3D matrices with unique grain labels (full3Ds)
- a struct that stores info for each grain (fullGTs)

Initial Analysis
- sp8_cleandata: fills any holes and determines basic grain parameters (e.g. gradius)
- sp8_gbVoxelList: finds all GB voxels
- sp8_gbAreaMat: takes voxel list and returns GB areas for all neighbors of every grain


# Repository Structure

### data
Contains example datasets

### exchange
Functions barrowed from the [Matlab File Exchange](https://de.mathworks.com/matlabcentral/fileexchange/)

### fun3d
Functions to analyze and displace 3D microstructures

### misc
Miscellaneous functions for plotting, saving, etc.

### misor
Functions for calculating orientations and misorientations

### sp8_scripts
Some scripts used to analyze SPring-8 datasets

### xtras
Extra code snippets that could be useful

