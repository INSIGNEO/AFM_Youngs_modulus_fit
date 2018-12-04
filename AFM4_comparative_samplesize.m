% this algorithm calculates the sample size needed to obtain
% statistically significant difference between the nucleus and the periphery

% it takes as input the matrix DATA containing the effective modulus per
% cell (nucleus and periphery) for all indentation depths (e.g. MLO_nucleus_Ecell.txt)
% but only considers the maximum indentation

% alternatively, if a median value across indentation depths is needed, the following lines can be used:
% calculate the median across indentation depths for each cell
% sizeDATA = size(DATA,1);
% DATA_med = zeros(size(DATA,1),1);
% for i = 1: size(DATA,1)
%     DATA_med(i,1) = median(DATA(i,:))/1000; %[kPa]
% end

% it returns as output the sample size N required to observe statistical
% difference between the two indenting location (Mann-Whitney test, p<0.01)

% 1_ get data
DATAn_maxind = DATAn(:,end);
DATAp_maxind = DATAp(:,end);
sizeDATA = min(size(DATAn,1), size(DATAp,1));

% 2_ for increasing sample sizes calculate the p-value at convergence
for N = 1:sizeDATA

    % 2a_initialise vectors for N
    p_temp = 0;
    p_updatemean = repmat(100, 50, 1);

    count = 1;

    while mean(p_updatemean) > 0.01

        % 2b_ draw N cells
        rand_sample_n = randsample(sizeDATA,N,'true'); % with replacement
        rand_sample_p = randsample(sizeDATA,N,'true');
        DATAn_temp = DATAn_maxind(rand_sample_n);
        DATAp_temp = DATAp_maxind(rand_sample_n);

        % 2c_ calculate ranksum (Mann-Whitney) p-value for the N cells
        p_temp(count,1) = ranksum(DATAn_temp, DATAp_temp);

        % 2d_ calculate average p-value for subsequent draws
        p_updatemean(count,1) = mean(p_temp(1:count,1));

        % 2e_ update count
        count = count + 1;

        if count > 2000
            break
        end
    end

    % 2g_ save average p-value at convergence
    rep(N,1) = count-1;
    p_N(N,1) = p_updatemean(end,1);

end

% 3_ compute sample size required to observe statistical difference between
% nucleus and periphery (Mann Whitney p-value < 0.01)
find_samplesize = find(p_N<0.01);
sample_size = find_samplesize(1);
