% this algorithm calculates the sample size needed to obtain a reliable
% effective modulus median value for the cell population

% it takes as input the matrix DATA containing the effective modulus per cell
% for all indentation depths (e.g. MLO_nucleus_Ecell.txt) but only considers the maximum indentation

% alternatively, if a median value across indentation depths is needed, the following lines can be used:
% calculate the median across indentation depths for each cell
% sizeDATA = size(DATA,1);
% DATA_med = zeros(size(DATA,1),1);
% for i = 1: size(DATA,1)
%     DATA_med(i,1) = median(DATA(i,:))/1000; %[kPa]
% end

% it returns as output the coefficient of variation (CV) for each sample size N

% 1_ get data
DATA_maxind = DATA(:,end);
sizeDATA = size(DATA,1);

% 2_ for increasing sample sizes calculate the effective modulus at convergence
for N = 1:sizeDATA
    
    % 2a_initialise vectors for N
    E_temp = 0;
    E_updatemean = 0;
    E_updatestd = 0;
        
    E_PE = repmat(100, 50, 1);
    E_PE_last50 = E_PE(end-49:end,1);
    count = 1;  
        
    while all(E_PE_last50<1) == 0 % stop the cycle when all elements < 1%
        
        % 2b_ draw N cells
        rand_sample = randsample(sizeDATA,N,'true'); % with replacement
        DATA_temp = DATA_maxind(rand_sample);
        % 2c_ calculate average for the N cells (instant effective modulus)
        E_temp(count,1) = mean(DATA_temp);
        
        % 2d_ calculate average effective modulus for subsequent draws
        E_updatemean(count,1) = mean(E_temp(1:count,1));
        E_updatestd(count,1) = std(E_temp(1:count,1));
        
        % 2e_ calculate percentage errors
        if count == 1
            E_PE(count,1) = 100;
        elseif count == 2
            meanE_PE_start = abs(E_updatemean(count,1)-E_updatemean(count-1,1));
            stdE_PE_start = abs(E_updatestd(count,1)-E_updatestd(count-1,1));
            
            E_PE(count,1) = 100;
        else
            meanE_PE_temp = abs(E_updatemean(count,1)-E_updatemean(count-1,1))/meanE_PE_start*100;
            stdE_PE_temp = abs(E_updatestd(count,1)-E_updatestd(count-1,1))/stdE_PE_start*100;
            
            E_PE(count,1) = max(meanE_PE_temp, stdE_PE_temp);
        end
        
        % 2f_ update count and convergence vector
        count = count+1;
        E_PE_last50 = E_PE(end-49:end,1);
        
    end
    
    % 2g_ save number of draws to reach convergence, average and std for effective modulus
    rep(N,1) = count-1;
    E_N(N,1) = E_updatemean(end,1);
    sigmaE_N(N,1) = E_updatestd(end,1);
    
end

% 3_ calculate the coefficient of variation (CV)
CV = 100.*sigmaE_N./E_N;

