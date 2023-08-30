# micro-mat-3D

Functions and scripts for analyzing the *Micro*structure of *Mat*erials in *3D*

This repository contains scripts and functions (mostly MATLAB) that can be used to analyze and view 3D microstructural data. Much of the original code was written to analyze 3DXRD datasets that were recorded at SPring-8. This is why the prefix 'sp8' is used throughout the code. :)

## Quick Start

Download this repository and unzip it

Start MATLAB, navigate to the repository and run `addmicromatfuns.m`

Import 3D data, from measurement or simulation
(There is also some data for testing in the *data* directory)

The data needs to be in the form:
- a cell that contains one or more 3D matrices with unique grain labels (full3Ds)
- a struct that stores info for each grain (fullGTs)

Initial Analysis
- sp8_cleandata: fills any holes and determines basic grain parameters (e.g. gradius)
- sp8_gbVoxelList: finds all GB voxels
- sp8_gbAreaMat: takes voxel list and returns GB areas for all neighbors of every grain

**Most useful functions**

- imagesp8
- sp8_findgrain
- sp8_showGrains3D


## Data Structure




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

