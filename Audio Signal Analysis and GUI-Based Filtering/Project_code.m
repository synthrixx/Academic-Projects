clc; close all; clear all;

%% READING THE AUDIO SIGNAL
file = "C_Major_Scale_2_unfiltered.wav";
[x,Fs] = audioread(file);
N = length(x);
t = (0:N-1) / Fs;

% Converting to mono by averaging channels
if size(x,2) > 1
    x = mean(x,2);
end

%% PLOTTING THE AUDIO SIGNAL AND CHOOSING THE SEGMENT INTERVALS
figure;
plot(t, x); grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('Audio Signal Waveform');

% Rougly choosing the start-end points for each segment
% [xb, yb] = ginput(9);    % <-- store clicks in variables
% tb = sort(xb);           % keep only the time (x-axis)
% disp('Chosen boundaries (tb) in seconds:');
% disp(tb);

total_duration = (N / Fs);
note_duration = total_duration / 8;

fprintf('Sampling Frequency of the signal = %.2f Hertz\n', Fs);
fprintf('Total Duration of the signal = %.2f seconds\n', total_duration);
fprintf('Approximate note duration = %.2f seconds\n', note_duration);

% Zooming into a short segment by picking a window that includes note + gap
t1 = 0.5; 
t2 = 1.0;  

figure;
plot(t, x); grid on;
xlim([t1 t2]);
xlabel('Time (s)'); ylabel('Amplitude');
title('Zoomed Time-Domain Segment (Note + Gap)');

note_segments = [0.12 0.61 ; 0.62 1.12 ; 1.13 1.62 ; 1.63 2.12 ; 2.13 2.62 ; 2.63 3.12 ; 3.13 3.62 ; 3.62 4.48];

% Plotting the segmented notes
figure;
for i = 1:size(note_segments,1)
    t1 = note_segments(i,1);
    t2 = note_segments(i,2);

    idx = (t >= t1) & (t < t2);

    subplot(4,2,i);
    plot(t(idx), x(idx)); grid on;
    xlabel('Time (s)'); ylabel('Amp');
    title(sprintf('Note %d', i));
end
sgtitle('Time-Domain Segments for 8 Notes');


%% FFT MAGNITUDE SPECTRUM & FUNDAMENTAL FREQUENCY ESTIMATION
% Frequency range for finding f0 (dominant peak)
fmin = 50;
fmax = 2000;

number_of_notes = size(note_segments,1);
f0 = zeros(number_of_notes,1);

figure;
for i = 1:number_of_notes
    t_start = note_segments(i,1);
    t_end   = note_segments(i,2);

    idx = (t >= t_start) & (t < t_end);
    x_segment = x(idx);
    x_segment = x_segment - mean(x_segment);

    N_fft = length(x_segment);
    f_fft = (-floor(N_fft/2):ceil(N_fft/2)-1) * (Fs/N_fft);

    x_segment = x_segment .* hann(N_fft);

    X_Segment = fftshift(fft(x_segment));
    magnitude_spectrum = abs(X_Segment);

    positive_band = (f_fft >= fmin) & (f_fft <= fmax);
    [~, peak_index] = max(magnitude_spectrum(positive_band));

    f_candidates = f_fft(positive_band);
    f0(i) = f_candidates(peak_index);

    subplot(4,2,i);
    plot(f_fft, magnitude_spectrum); grid on;
    xlim([0 fmax]);
    xlabel('Frequency (Hz)'); ylabel('|X(f)|');
    title(sprintf('Note %d: f0 \\approx %.2f Hz', i, f0(i)));
end
sgtitle('Magnitude Spectra of 8 Notes (FFT + FFTSHIFT)');

fprintf('\nEstimated fundamental frequencies (dominant peak):\n');
for i = 1:number_of_notes
    fprintf('Note %d: %.2f Hz\n', i, f0(i));
end

%% BAND-PASS FILTER DESIGN
target_note_index = 6;
f0_target = f0(target_note_index);
delta_f = 15;
f_passband = [f0_target - delta_f, f0_target + delta_f];

Wn = f_passband / (Fs / 2);
order = 10;

[z,p,k] = butter(order, Wn, "bandpass");
[sos,g] = zp2sos(z,p,k);

x = x(:);
y = g * sosfilt(sos, x);

figure;
subplot(2,1,1);
plot(t, x); grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('Original Recording (Time Domain)');

subplot(2,1,2);
plot(t, y); grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title(sprintf('Filtered Recording (Band-pass %.1f–%.1f Hz)', f_passband(1), f_passband(2)));

y = y(:);

NFFT = 2 ^ nextpow2(length(x));
w = hann(length(x));

X = fftshift(fft(x .* w, NFFT));
Y = fftshift(fft(y .* w, NFFT));
f = (-NFFT/2 : NFFT/2-1) * (Fs / NFFT);

ref = max(abs(X));

figure;
plot(f, abs(X)/ref); hold on;
plot(f, abs(Y)/ref); grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude (normalized to original max)');
title('Magnitude Spectrum: Original vs Filtered');
legend('Original','Filtered');
xlim([f0_target-300, f0_target+300]);


%% SOUND TEST
% disp('Playing ORIGINAL signal...');
% soundsc(x, Fs);
% pause(length(x)/Fs + 1);
% 
% disp('Playing FILTERED signal...');
% soundsc(y, Fs);
% pause(length(y)/Fs + 1);

% % Save filtered audio (WAV) in the current MATLAB folder
% y_save = y / max(abs(y) + eps);
% audiowrite('C_Major_Scale_2_filtered.wav', y_save, Fs);

%% LOW-PASS & HIGH-PASS FILTERS
% Common FFT settings reminders
x = x(:);
NFFT = 2 ^ nextpow2(length(x));
w = hann(length(x));
f = (-NFFT/2 : NFFT/2-1) * (Fs/NFFT);
X = fftshift(fft(x .* w, NFFT));
ref = max(abs(X));

% LOW-PASS
f_cutoff_lp = 370.41;
Wn_lp = f_cutoff_lp / (Fs / 2);

[z_lp,p_lp,k_lp] = butter(order, Wn_lp, 'low');
[sos_lp,g_lp] = zp2sos(z_lp,p_lp,k_lp);

y_lp = g_lp * sosfilt(sos_lp, x);

figure;
subplot(2,1,1);
plot(t, x); grid on;
title('Original Recording (Time Domain)');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(2,1,2);
plot(t, y_lp); grid on;
title(sprintf('Low-pass Filtered (fc = %.1f Hz, order = %d)', f_cutoff_lp, order));
xlabel('Time (s)'); ylabel('Amplitude');

Y_lp = fftshift(fft(y_lp .* w, NFFT));

figure; plot(f, abs(X) / ref); hold on; 
plot(f, abs(Y_lp) / ref); grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude');
title('Magnitude Spectrum: Original vs Filtered');
legend('Original','Low-pass');
xlim([0 1000]); 

% HIGH-PASS
f_cutoff_hp = 370.41;
Wn_hp = f_cutoff_hp / (Fs / 2);

[z_hp,p_hp,k_hp] = butter(order, Wn_hp, 'high');
[sos_hp,g_hp] = zp2sos(z_hp,p_hp,k_hp);

y_hp = g_hp * sosfilt(sos_hp, x);

figure;
subplot(2,1,1);
plot(t, x); grid on;
title('Original Recording (Time Domain)');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(2,1,2);
plot(t, y_hp); grid on;
title(sprintf('High-pass Filtered (fc = %.1f Hz, order = %d)', f_cutoff_hp, order));
xlabel('Time (s)'); ylabel('Amplitude');

Y_hp = fftshift(fft(y_hp .* w, NFFT));

figure; 
plot(f, abs(X) / ref); hold on; 
plot(f, abs(Y_hp) / ref); grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude (normalized to original max)');
title('Magnitude Spectrum: Original vs Filtered');
legend('Original','High-pass');
xlim([0 2000]); 