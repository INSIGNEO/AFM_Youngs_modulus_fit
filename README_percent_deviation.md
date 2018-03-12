The sample size analysis has been changed to repeat the Monte Carlo for 100 times to achieve better consistency of results

#### Sample size considerations
A Monte Carlo analysis is performed by AFM3_samplesize.m on the Young's modulus averaged per cell.
This analysis allows for calculating the minimum sample size needed to obtain a reliable average population value (i.e. a value that remains constant to the addition of further input).
This code does the following:
* takes as _input_ the Young's modulus values for increasing indentation depths averaged per cell (e.g. if 15 force-spectroscopy curves were obtained for a given cell, this will correspond to one line of _input_ for this step; this line will be calculated as the average value of the 15 curves for each indentation depth),
* calculates a median value across all indentation depths,
* calculates the percentage error on the median for samples of increasing size,
* returns as err10_percentdev (_output_) the number of cells needed if accepting a maximum percent deviation of 10% on the average population Young's modulus over 100 repetitions of the Monte Carlo analysis (the percent deviation is defined as std/mean)

##### AFM3_samplesize.m
This algorithm calculates the sample size needed to obtain a reliable Young's modulus median value for the cell population.
It takes as input the matrix DATA containing the Young's modulus averaged per cell for all indentation depths (i.e. each row represents one cell, each column one indentation depth).

1. calculate the median across indentation depths for each cell
2. FOR 100 repetitions: randomize cell acquisition order
3. FOR 100 repetitions: compute average for population of increasing size (for each step: sample has an additional cell - picked randomly from the list, compute average)
4. average population average over all repetitions for each sample size
5. calculate percent deviation (100*std/mean) and return sample size for 10% percent deviation (err10_percentdev)
