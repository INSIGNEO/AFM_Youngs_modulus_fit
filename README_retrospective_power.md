A retrospective estimation approach was employed to quantify the number of cells to be tested in order to achieve a reliable measurement of the population average stiffness.
To this aim, the convergence effective modulus was computed for each sample size.

For each sample size N up to the number of cells tested in each sample, N cells are randomly chosen (draw D) from the list with a bootstrap approach (with replacement) and their instant average modulus is calculated.
The average modulus for the D-th draw is used to calculate a cumulative modulus by using all the previous draws and computing a cumulative average and standard deviation.
Draws are continued until convergence of the cumulative average and std is reached.

The convergence threshold is set to the percentage error of the cumulative average and std for subsequent draws being lower than 1% for 50 subsequent draws.

#### Sample size considerations
A retrospective power analysis is performed by AFM3_samplesize.m on the effective modulus averaged per cell.
This analysis allows for calculating the minimum sample size needed to obtain a reliable average population value (i.e. a value that remains constant to the addition of further input).
This code does the following:
* takes as _input_ the Young's modulus values for maximum indentation averaged per cell (e.g. if 15 force-spectroscopy curves were obtained for a given cell, this will correspond to one line of _input_ for this step; this line will be calculated as the average value of the 15 curves),
* for increasing sample sizes, calculate the effective modulus at convergence (mean and std),
* returns as CV the coefficient of variation for each sample size calculated as std/mean.

##### AFM3_samplesize.m
This algorithm calculates the sample size needed to obtain a reliable effective modulus value for the cell population by retrospective power analysis.
It takes as input the matrix DATA containing the Young's modulus averaged per cell for all indentation depths (i.e. each row represents one cell, each column one indentation depth), but only considers the maximum indentation depth.

1. get the maximum indentation data
2. calculate the effective modulus at convergence for increasing sample sizes (WHILE loop for each sample size N until the convergence threshold is reached)
    2. draw N cells with replacement (bootstrap)
    3. calculate average for the N cells (instant effective modulus)
    4. calculate average effective modulus for subsequent draws (cumulative effective modulus)
    5. calculate percentage errors
    6. check convergence vector
3. save effective modulus at convergence for each sample size (average and dispersion)
4. return the coefficient of variation (CV) for each sample size using the effective modulus at convergence
