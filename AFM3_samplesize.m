% this algorithm calculates the sample size needed to obtain a reliable
% Young's modulus median value for the cell population

% it takes as input the matrix DATA containing the Young's modulus per cell
% for all indentation depths (e.g. MLO_nucleus_Ecell.txt)

% 1_ calculate the median across indentation depths for each cell
sizeDATA = size(DATA,1);
DATA_med = zeros(size(DATA,1),1);
for i = 1: size(DATA,1)
    DATA_med(i,1) = median(DATA(i,:))/1000; %[kPa]
end

% 2_ randomise DATA_med 
a = size(DATA_med,2);
b = size(DATA_med,1);
random = ceil(a + (b-a).*rand(sizeDATA,1));
DATA_med_rand = DATA_med(random);

% 3_ for each step: sample has an additional cell, compute average 
average_sample = zeros(size(DATA,1),1);
for j = 1:size(DATA_med,1)
    % randomoly select j cells for the sample at this step
    random_j = ceil(a + (b-a).*rand(j,1)); 
    sample_j = DATA_med_rand(random_j);
    average_sample(j,1) = median(sample_j);
    % iqr_sample_i(j,1) = iqr(sample_j);
end

% 4_ compute instant percentage error 
err_perc_average = zeros(size(DATA,1),1);
for k = 2:b
    err_perc_average(k,1) = (abs(average_sample(k)-average_sample(k-1))/average_sample(k))*100;
    % err_perc_iqr(k,1) = (abs(iqr_sample_i(k)-iqr_sample_i(k-1))/iqr_sample_i(k))*100;
end

% 5_ find sample sizes for 10% and 5% percentage error
err_search = smooth(err_perc_average,10);
find10 = find(err_search > 10);
err10 = find10(end);    % sample size with a max error of 10% on the median
find5 = find(err_search > 5);
err5 = find5(end);      % sample size with a max error of 5% on the median

