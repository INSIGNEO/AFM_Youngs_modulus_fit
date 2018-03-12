% this algorithm calculates the sample size needed to obtain a reliable
% Young's modulus median value for the cell population

% it takes as input the matrix DATA containing the Young's modulus per cell
% for all indentation depths (e.g. MLO_nucleus_Ecell.txt)

% it returns as output the sample size in number of cells needed if accepting a maximum percent deviation of 10%
% (err10_percentdev)

% 1_ calculate the median across indentation depths for each cell
sizeDATA = size(DATA,1);
DATA_med = zeros(size(DATA,1),1);
for i = 1: size(DATA,1)
    DATA_med(i,1) = median(DATA(i,:))/1000; %[kPa]
end

% initialise vectors
rep = 100; % number of repetitions for the Monte Carlo analysis
average_sample = zeros(size(DATA,1),rep);
err_perc_average = zeros(size(DATA,1),rep);

for q = 1:rep

    % 2_ randomise DATA_med
    a = size(DATA_med,2);
    b = size(DATA_med,1);
    random = ceil(a + (b-a).*rand(sizeDATA,1));
    DATA_med_rand = DATA_med(random);

    % 3_ for each step: sample has an additional cell, compute average
    for j = 1:size(DATA_med,1)
        % randomoly select j cells for the sample at this step
        random_j = ceil(a + (b-a).*rand(j,1));
        sample_j = DATA_med_rand(random_j);
        average_sample(j,q) = median(sample_j);
    end

end

% 4_ average of repetitions for each sample size
mean_samplesize = zeros(b,1);
std_samplesize = zeros(b,1);
for i = 1:b
    mean_samplesize(i,1) = mean(average_sample(i,:));
    std_samplesize(i,1) = std(average_sample(i,:));
end

% 5_ calculate percent deviation and find sample size for 10% percent dev
percent_deviation = 100*std_samplesize./mean_samplesize;
find10_percentdev = find(percent_deviation > 10);
err10_percentdev = find10_percentdev(end);
