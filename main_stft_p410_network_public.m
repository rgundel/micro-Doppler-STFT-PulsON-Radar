%##########################################################################
%###########    micro-Doppler spectrogram computation     #################
%###########     of the public dataset of TU Delft        #################
%########### pulsON P410 radar from TimeDomain (Humatics) #################
%##########################################################################
%
%--------------------------------------
% Author:       Ronny (Gerhard) Guendel
% Written by:   Microwave Sensing, Signals and Systems (MS3)
% University:   TU Delft
% Email:        r.guendel@icloud.com
% Created:      11/08/2023
% Updated:      11/08/2023

% Description:
% This example script computes a micro-Doppler spectrogram from a real or a
% complex range-time matrix of the pulsON P410 radar from TimeDomain (Humatics).

%% clean and close workspace
clc; clear; close all;

%% for the matlab file *.mat
[file,path] = uigetfile('M:\ewi\me\MS3\Ronny Guendel\PulsON_Data\MonostaticDataExtension\Ronny2nd\MAT_data_aligned\001_mon_wal_Ro2.mat');%  ('*.mat');
data = load([path,file]);

%% extracting the rangemaps and the labels
rm  = data.hil_resha_aligned;
labels = data.lbl_out;


%% Providing the [range bins x slowtime samples x radarnodes]
[NTS,NScans,KK] = size(rm);  % Range map vector [rangebins x slowtime samples x five radars]
fprintf('The slowtime bins are: \t%i \nthe range bins are: \t%i\nthe radar nodes are: \t%i\n', NScans,NTS,KK')

%% Initialize parameters
ts = 0.0082; % sample time in sec
fs_slow = 1/ts;
Rmin = 1; % min range in m
Rmax = Rmin + 4.8; % max range in m
T = ts*NScans;

%% Plot the corresponding range mapswith samples
figure(1);
for k = 1:KK
    subplot(KK+1,1,k);
    imagesc([0 T], [Rmin Rmax],20*log10(abs(rm(:,:,k)))); axis xy
    clim = get(gca,'CLim');
    set(gca,'CLim',clim(2) + [-60 -10]);
    colormap('jet'); axis xy; colorbar('east');
    xlabel("slowtime (sec)"); ylabel("range (m)");
end

%% Providing the labels
time_samples = linspace(0,ts*length(labels),length(labels));
subplot(KK+1,1,KK+1);
plot(time_samples,labels,'red');
xlim([-inf inf]);
ylim([-1 10]);
xlabel("slowtime (sec)"); ylabel("Classes");
drawnow;
fprintf("the classes are:\n" + ...
    "1 Walking\n" + ...
    "2 Nothing (stationary)\n" + ...
    "3 Sitting down\n" + ...
    "4 Standing up from sitting\n" + ...
    "5 Bending from Sitting\n" + ...
    "6 Bending from Standing\n" + ...
    "7 Falling from Walking\n" + ...
    "8 Standing up from the ground\n" + ...
    "9 Falling from Standing\n");

%% STFT parameters
win_size= 128;           % good sizes are about 0.5 to 1sec
hop     = 4;            % hop size is equivalent to (window_size-window_overl)
nfft    = 2*win_size;   % nfft points should be at least 2 times the win_size
fs      = fs_slow;


%% For loop for the micro_Doppler compuation
for k = 1:KK
    rt_matrix = rm(:,:,k);

    %% Compute the complex range time matrix using pcode fuction
    if isreal(rt_matrix)
        [rt_matrix_compl] = fct_rt_matrix_real_to_complex(rt_matrix);
    else
        rt_matrix_compl = rt_matrix;
    end

    %% compute the micro Doppler spectra using pcode STFT fuction
    [mD_matrix,f,t] = fct_stft_pulson_radar(rt_matrix_compl, hann(win_size), hop, nfft, fs);

    %% show the micro-Doppler spectrogram
    figure(2);
    subplot(KK+1,1,k);
    imagesc(t,f, 10*log10(abs(mD_matrix).^2));
    axis xy;
    ylabel('Doppler (Hz)');
    xlabel('Time (s)');
    colormap jet;
    colorbar;
    clim = get(gca,'CLim');
    set(gca,'CLim',clim(2) + [-60 -10]);
end
%% Providing the labels
time_samples = linspace(0,ts*length(labels),length(labels));
subplot(KK+1,1,KK+1);
plot(time_samples,labels,'red');
xlim([-inf inf]);
ylim([-1 10]);
xlabel("slowtime (sec)"); ylabel("Classes");
drawnow;
