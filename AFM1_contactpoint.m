% this algorithm takes raw file from AFM microscope (.txt) and fit the
% contact point, correct retract drift and tip-sample separation

% new .txt files are saved as outcomes in a folder of choice containing
% cantilever height, vertical deflection, time and segment

% 0_ INPUT
% here information about the experiment need to be entered
input_folder = 'D:\SHEFFIELD\WORK\AFM'; % where are raw data files
k = 0.2;    % spring constant of cantilever used in [nN/nm]
% where are the files going to be saved?
output_folder = 'D:\SHEFFIELD\WORK\AFM\output'; % name folder
mkdir(output_folder);   % create folder
% what is the working folder for Matlab?
working_folder = 'D:\SHEFFIELD\WORK\Matlab';

% 1_ open folder and list files
data_folder = cd (input_folder);
D = dir('*.txt');	% make a file list (D) of the (.txt) data in data_folder
[~,index] = sortrows({D.date}.'); D = D(index); clear index     % order data by acquisition time
D_cell = struct2cell(D); D_cell_filename = D_cell(1,:)';	% create cell array of strings with file-names

% 2_ FOR cycle which opens one file at the time and perform post-processing steps
for i = 1:size(D_cell_filename,1)   % open file (name order)
              
    % 2a_ open file
    cd (input_folder);
    myfilename = D_cell_filename{i};
    fileID = fopen(myfilename);
    C = textscan(fileID, '%f%f%f%f', 'CommentStyle', '#');	% raw files contain 4 columns
    mydata = cell2mat(C);	% save data of file(i) into matrix mydata
    fclose(fileID);
    cd (working_folder)
    
    % 2b_ save data from file into arrays
    height = mydata(:,1)*1E9;	% cantilever height [nm]
    force = mydata(:,2)*1E9;	% vertical deflection [nN]
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
    
    % 2_c fit contact point on extend with ratio-of-variance method, see [Gavara et al., 2016]
        
    % two lines are fitted starting from the two ends of the force-spectroscopy curve
    % (cantilever height vs. vertical deflection) to obtain a guess on where to start looking for the contact point
    nn1 = 100;
    nn2 = 200;
    h_range1 = height_E(end-nn1:end);
    f_range1 = force_E(end-nn1:end);
    h_range2 = height_E(1:nn2);
    f_range2 = force_E(1:nn2);
    fit_1 = fit(h_range1, f_range1, 'poly1');
    fit_1coeff = coeffvalues(fit_1);
    fit_2 = fit(h_range2, f_range2, 'poly1');
    fit_2coeff = coeffvalues(fit_2);
    hP = (fit_2coeff(1,2)-fit_1coeff(1,2))/(fit_1coeff(1,1)-fit_2coeff(1,1)); % crossing point of fit lines (height)
    hP_height_index = find(height_E <= hP);
    
    % ratio-of-variance (RoV) method
    d = force_E/k;
    window_data = 100;  % window size
    ROV = zeros(length(d)-2*window_data,1);
    jj = 1;
    for ii = 1+window_data : (length(height_E))-window_data
        ROV(jj,1) = var(d(ii+1:ii+window_data))/var(d(ii-window_data:ii-1));    % calculate RoV
        jj = jj+1;
    end
    ROV_norm = ROV/max(ROV);    % normalise Rov
    CP_ROV_value = find(ROV_norm == 1);	% find max index in ROV vector, i.e. contact point (CP) index
    CP_ROV_index = CP_ROV_value + window_data; % index in respect to the height_E, force_E vectors
    CP_height = height_E(CP_ROV_index); 
    CP_force = force_E(CP_ROV_index);
    
    % 2d_ plot data after fitting the CP for user verification
    figure('OuterPosition',[560 450 550 510])
    plot(height_E, force_E, height_R, force_R, CP_height, CP_force, 'ko')
    hold on
    a = size(height_E,1);
    b = repmat(CP_force, a, 1);
    plot(height_E, b, 'k--')
    xlabel('Height [nm]')
    ylabel('Force [pN]')
    grid on
    prompt1 = {'Press 1 if you want to manually correct the contact point, 0 if you want to discard the curve'};
    dlg_title1 = 'Data analysis';
    num_lines1 = 1;
    Q1 = inputdlg(prompt1,dlg_title1,num_lines1);
    [question] = str2double(Q1{1});  
    
    if question == 0    % discard datafile
        close
        continue
    elseif question == 1    % manual selection
        user_input = ginput(1);
        CP_height = user_input(1);
        CP_force = user_input(2);
        close
    else
        close
    end
    
    % 2e_ save arrays for output
    % extend (E)
    force_E_new = (force_E - CP_force);
    height_E_new = (height_E - CP_height) + force_E_new/k;	% tip-sample separation correction
        
    % retract (R) 
    force_R_new = (force_R - CP_force);
    height_R_new = (height_R - CP_height) + force_R_new/k;  % tip-sample separation correction
    % drift correction (extend and retract baseline to match)
    nn = 100;
    force_R_drift = mean(force_R_new(end-nn:end));
    force_E_drift = mean(force_E_new(1:nn));
    drift = force_E_drift - force_R_drift;
    height_R_new_drift = height_R_new;
    force_R_new_drift = force_R_new + drift;
    
    % save
    height_save = [height_E_new; height_R_new_drift];
    force_save = [force_E_new; force_R_new_drift];
    series_save = [series_E; series_R];
    segment_save = [segment_E; segment_R];
    data  = [height_save, force_save, series_save, segment_save];
    cd(output_folder);
    myfilename1 = sprintf('Data%d.txt', i);
    save (myfilename1, 'data', '-ascii');
   
end