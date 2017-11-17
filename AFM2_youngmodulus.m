% this algorithm fits the Hertz model for a spherical indenter on a half space for increasing indentation depths
% it takes the files saved with AFM1_contactpoint.m as input and 
% give as output the Young's modulus for each indentation depth for each
% file (saved as .xslx file)

% call the function createFitHertz.m for fitting

% 0_ INPUT
% here information about the data/experiment need to be entered
input_folder = 'D:\SHEFFIELD\WORK\AFM\output'; % where are the data files with CP fitted
indenter_radius = 3000; % spherical indenter used for experiments: radius in [nm]
% where are the files going to be saved?
output_folder = 'D:\SHEFFIELD\WORK\AFM\output\young'; % name folder
mkdir(output_folder);   % create folder
% what is the working folder for Matlab?
working_folder = 'D:\SHEFFIELD\WORK\Matlab';

% 1_ open folder and list files
data_folder = cd (input_folder);
D = dir('*.txt');	% make a file list (D) of the (.txt) data in data_folder
[~,index] = sortrows({D.date}.'); D = D(index); clear index     % order data by acquisition time
D_cell = struct2cell(D); D_cell_filename = D_cell(1,:)';	% create cell array of strings with file-names

% 2_ output arrays initialisation
young = zeros(size(D_cell_filename,1),20);      % Young's modulus
R2_young = zeros(size(D_cell_filename,1),20);   % R^2 coefficient as index of goodness-of-fit

% 3_ FOR cycle which opens one file at the time and perform post-processing steps
for i = 1:size(D_cell_filename,1) 
    
    % 3a_ open file
    cd (input_folder);
    myfilename = D_cell_filename{i};
    fileID = fopen(myfilename);
    C = textscan(fileID, '%f%f%f%f', 'CommentStyle', '#');	% raw files contain 4 columns
    mydata = cell2mat(C);	% save data of file(i) into matrix mydata
    fclose(fileID);
    cd (working_folder)
    
    % 3b_ save data from file into arrays
    height = mydata(:,1);	% cantilever height [nm]
    force = mydata(:,2);	% vertical deflection [nN]
    series = mydata(:,3);       % time [s]
    segment = mydata(:,4);      % time for extend/retract [s]
    
    segment_start = zeros(4,1);
    jj = 1;
    for ii = 1:length(segment)-1
        if segment(ii)-segment(ii+1) > 0.1
            segment_start(jj,1) = (ii+1);	% index of [segment] change from extend to retract
            jj = jj+1;
        end
    end
    
    % extend (E) data
    force_E = force(1:segment_start(1)-1);
    height_E = height(1:segment_start(1)-1);
    series_E = series(1:segment_start(1)-1);
    segment_E = segment(1:segment_start(1)-1);
    % retract (R) data
    force_R = force(segment_start(1):end);
    height_R = height(segment_start(1):end);
    series_R = series(segment_start(1):end);
    segment_R = segment(segment_start(1):end);
    
    % 3c_ find Young's modulus for increasing indentation dephts
    
    % consider indentation region only
    indentation = find (height_E < 0);
    height_ind = abs(height_E(indentation));    % change sign - positive indentation
    force_ind = force_E(indentation);
    
    % set intervals of [100nm] of indentation deths
    lim_interval = 0;
    j=1;
    for k = 100:100:max(height_ind)
        interval = find(height_ind < k);
        lim_interval(j) = interval(end);
        j = j+1;
    end
    lim_interval(j) = size(height_ind,1);
    
    % fit Hertz model on indentation depth intervals
    E_indentation = zeros(1,size(100:100:max(height_ind),2));
    R2_indentation = zeros(1,size(100:100:max(height_ind),2));
    jjj = 1;
    for iii = 1:size(lim_interval,2)
    
        height_ind_interval = height_ind(1:lim_interval(iii));
        force_ind_interval = force_ind(1:lim_interval(iii));
                
        [fitHertz_interval, gof_interval] = createFitHertz(height_ind_interval, force_ind_interval);
        fitHertz_interval_coeff = coeffvalues(fitHertz_interval);   % fitting coefficients
        
        gof_interval_cell = struct2cell(gof_interval);	% gof include: SSE, Rsquare, dfe, adjRsquare, RMSE
        gof_interval_number = cell2mat(gof_interval_cell);	% transform gof in vector
        E_interval = ((9*fitHertz_interval_coeff)/(16*(indenter_radius^(1/2))))*10^9;	% from fit coeff to E (*10^9 to account for units)
        
        E_indentation(1,jjj) = E_interval;
        R2_indentation(1,jjj) = gof_interval_number(2);
        jjj = jjj+1;
        
    end  
    
    % 3d_ save in output arrays [young]
    young(i,1:length(E_indentation)) = E_indentation;       % Young's modulus [Pa]
    R2_young(i,1:length(R2_indentation)) = R2_indentation;	% fitting R^2 (coeff of determination)
    
end

% SAVE
cd(output_folder);
filename1 = 'young_indentation.xlsx';
xlswrite(filename1,young)
filename2 = 'R2_indentation.xlsx';
xlswrite(filename2,R2_young)

