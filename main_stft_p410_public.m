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

%% clean and close workspace
clc; clear; close all;

%% Load data
load('ex_rangeTimeMap','rt_matrix','T','fs_slow','Rmin','Rmax','NTS','NScans');

%% plot the range time matrix
figure(1);
imagesc([0 T], [Rmin Rmax], 10*log10(abs(rt_matrix).^2));
axis xy;
ylabel('Range (m)');
xlabel('Time (s)');
colormap jet;
colorbar;
clim = get(gca,'CLim');
set(gca,'CLim',clim(2) + [-60 -10]);

%% Compute the complex range time matrix using pcode fuction
[rt_matrix_compl] = fct_rt_matrix_real_to_complex(rt_matrix);

%% plot the complex range time matrix
figure(2);
imagesc([0 T], [Rmin Rmax], 10*log10(abs(rt_matrix_compl).^2));
axis xy;
ylabel('Range (m)');
xlabel('Time (s)');
colormap jet;
colorbar;
clim = get(gca,'CLim');
set(gca,'CLim',clim(2) + [-60 -10]);

%% STFT parameters
win_size= 64;           % good sizes are about 0.5 to 1sec
hop     = 4;            % hop size is equivalent to (window_size-window_overl)
nfft    = 2*win_size;   % nfft points should be at least 2 times the win_size
fs      = fs_slow;

%% compute the micro Doppler spectra using pcode STFT fuction
[mD_matrix,f,t] = fct_stft_pulson_radar(rt_matrix_compl, hann(win_size), hop, nfft, fs);

%% show the micro-Doppler spectrogram
figure(3);
imagesc(t,f, 10*log10(abs(mD_matrix).^2));
axis xy;
ylabel('Doppler (Hz)');
xlabel('Time (s)');
colormap jet;
colorbar;
clim = get(gca,'CLim');
set(gca,'CLim',clim(2) + [-60 -10]);