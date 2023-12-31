%##########################################################################
%###########             Single recording                 #################
%###########    micro-Doppler spectrogram computation     #################
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

%% Clean and Close Workspace
clc;        % Clear command window
clear;      % Remove all variables from workspace
close all;  % Close all figure windows

%% Load Data
load('ex_rangeTimeMap', 'rt_matrix', 'T', 'fs_slow', 'Rmin', 'Rmax', 'NTS', 'NScans');

%% Plot Range-Time Matrix
figure(1);
imagesc([0 T], [Rmin Rmax], 10*log10(abs(rt_matrix).^2));
colormap jet;
colorbar;
ylabel('Range (m)');
xlabel('Time (s)');
axis xy;
adjustPlotColorLimits(gca, [-60 -10]);

%% Convert Range-Time Matrix to Complex Form
[rt_matrix_compl] = fct_rt_matrix_real_to_complex(rt_matrix);

%% Plot Complex Range-Time Matrix
figure(2);
imagesc([0 T], [Rmin Rmax], 10*log10(abs(rt_matrix_compl).^2));
colormap jet;
colorbar;
ylabel('Range (m)');
xlabel('Time (s)');
axis xy;
adjustPlotColorLimits(gca, [-60 -10]);

%% Define STFT Parameters
win_size = 64;       % Window size (approx. 0.5 to 1 sec)
hop      = 4;        % Hop size (window_size - window_overlap)
nfft     = 2 * win_size; % Number of FFT points (at least 2x window size)
fs       = fs_slow;  % Sampling frequency

%% Compute and Plot Micro-Doppler Spectrogram
[mD_matrix, f, t] = fct_stft_pulson_radar(rt_matrix_compl, hann(win_size), hop, nfft, fs);
figure(3);
imagesc(t, f, 10*log10(abs(mD_matrix).^2));
colormap jet;
colorbar;
ylabel('Doppler (Hz)');
xlabel('Time (s)');
axis xy;
adjustPlotColorLimits(gca, [-60 -10]);

%% Helper Function to Adjust Plot Color Limits
function adjustPlotColorLimits(ax, dynamicRange)
    clim = get(ax, 'CLim');
    set(ax, 'CLim', clim(2) + dynamicRange);
end
