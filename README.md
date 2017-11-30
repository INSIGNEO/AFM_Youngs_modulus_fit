# AFM_Youngs_modulus_fit
Matlab coding for AFM raw data post-processing > Hertz model to obtain cell Young's modulus for increasing indentation depths

This repository contains Matlab codes to process Atomic Force Microscopy raw force spectroscopy data obtained on cells with a spherical indenter

All codes were tested on Matlab R2016a version

#### Raw data
The raw data are force-spectroscopy .txt files from AFM experiments. They contain four columns: cantilever height [m], cantilever vertical deflection [N], series time [s], segment time [s].
All the experiments in this context were carried out with a Nanowizard 3 microscope from JPK. The built-in software provide .txt files in this form (comments are preceded by #)

#### Pre-processed data
Raw data (_input_) are processed individually with the Matlab code AFM1_contactpoint.m.
This code is needed to:
* fit the contact point with the ratio-of-variance method (see [Gavara N. 2016](https://www.nature.com/articles/srep21267)),
* ask the user if happy with the contact point fitting,
* correct the drift between extend and retract baselines,
* correct for tip-sample separation.
Pre-processed data are obtained as _output_.

#### Young's modulus fitting
Pre-processed data are fitted individually with the Hertz model for a spherical indenter over a half space for increasing indentation depths.
This is achieved with the Matlab code AFM2_youngmodulus.m.
This code does the following:
* takes as _input_ the pre-processed data,
* calculates the Young's modulus for increasing indentation depths by Hertz fitting (through the function createFitHertz.m),
* gives as _output_ a summary .xslx or .csv file containing the Young's modulus for each indentation depth for each file.

#### Sample size considerations
A Monte Carlo analysis is performed by AFM3_samplesize.m on the Young's modulus averaged per cell.
This analysis allows for calculating the minimum sample size needed to obtain a reliable average population value (i.e. a value that remains constant to the addition of further input).
This code does the following:
* takes as _input_ the Young's modulus values for increasing indentation depths averaged per cell (e.g. if 15 force-spectroscopy curves were obtained for a given cell, this will correspond to one line of _input_ for this step; this line will be calculated as the average value of the 15 curves for each indentation depth),
* calculates a median value across all indentation depths,
* calculates the percentage error on the median for samples of increasing size,
* returns as err5 and err10 (_output_) the number of cell needed if accepting a maximum percentage error of 5% and 10% respectively on the average population Young's modulus.

#### Detailed code description
##### AFM1_contactpoint.m
This algorithm takes raw file from AFM microscope (.txt) as input and fit the contact point, correct retract drift and tip-sample separation.
New .txt files are saved as output in a folder of choice containing cantilever height, vertical deflection, time and segment.

1. _INPUT_ - information about the performed AFM experiment need to be entered by the user (spring constant of the cantilever used, input folder and Matlab working folder)
2. open input folder and list file names for next step
3. FOR cycle which opens one file at the time from the input folder and perform post-processing steps
    1. open file
    2. save data from file into arrays
    3. fit contact point on extend curve
    4. plot data after fitting the CP for user verification
    5. save pre-processed file as .txt files in the output folder

##### AFM2_youngmodulus.m
This algorithm fits the Hertz model for a spherical indenter on a half space for increasing indentation depths.
It takes the files saved with AFM1_contactpoint.m as input and give as output the Young's modulus for each indentation depth for each file (saved as .xslx or .csv file).

1. _INPUT_ - information about the performed AFM experiment need to be entered by the user (indenter radius, input folder and Matlab working folder)
2. open input folder and list file names for next step
3. initialize output arrays
4. FOR cycle which opens one file at the time and perform post-processing steps
    1. open file
    2. save data from file into arrays
    3. find Young's modulus for increasing indentation depths (calls createFitHertz.m)
    4. save output for opened file
5. save summary output file for all files

##### AFM3_samplesize.m
This algorithm calculates the sample size needed to obtain a reliable Young's modulus median value for the cell population.
It takes as input the matrix DATA containing the Young's modulus averaged per cell for all indentation depths (i.e. each row represents one cell, each column one indentation depth).

1. calculate the median across indentation depths for each cell
2. randomize cell acquisition order
3. compute average for population of increasing size (for each step: sample has an additional cell - picked randomly from the list, compute average)
4. compute instant percentage error
5. return sample sizes for 10% (err10) and 5% percentage error (err5)
