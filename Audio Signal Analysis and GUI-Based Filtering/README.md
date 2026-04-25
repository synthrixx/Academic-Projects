# Audio Signal Analysis and GUI-Based Filtering with MATLAB

## Overview

This repository contains an EE331 Signals and Systems final assignment focused on musical note recording, frequency-domain analysis, digital filtering, and GUI-based signal processing in MATLAB.

A C major scale recording containing eight successive piano notes was analyzed in the time and frequency domains. The fundamental frequency of each note was estimated using FFT analysis, compared with theoretical musical note frequencies, and one selected note was isolated using a Butterworth band-pass filter. A MATLAB App Designer GUI was also developed to allow interactive audio loading, filtering, visualization, and playback.

## Assignment Scope

The project addresses the following tasks:

- Record a real audio signal containing at least eight distinct musical notes.
- Load the recorded audio into MATLAB using `audioread`.
- Determine the sampling frequency, total duration, and approximate note duration.
- Segment the recording into eight note regions.
- Analyze each note in the frequency domain using FFT.
- Estimate the fundamental frequency of each note from the dominant spectral peak.
- Compare measured frequencies with theoretical note frequencies.
- Design and apply a digital filter to isolate a selected note.
- Build a MATLAB GUI for loading, plotting, filtering, and playing audio signals.

## Recording Setup

The analyzed audio file is:

```text
C_Major_Scale_2_unfiltered.wav
```

The recording contains a C major scale played on piano. The source audio was played from a YouTube video on an iPad 9th Generation and recorded using an iPhone 13 in a quiet room. The phone was positioned approximately 2 cm away from the tablet speaker.

Audio properties:

| Property | Value |
|---|---:|
| Sampling frequency | 48,000 Hz |
| Total duration | approximately 4.50 s |
| Number of notes | 8 |
| Approximate note duration | approximately 0.56 s |

## Methodology

### 1. Time-Domain Analysis

The original audio signal was converted to mono when necessary and plotted in the time domain. The waveform was inspected to identify note transitions and silent or low-amplitude regions between successive notes.

The signal was manually segmented into eight note intervals corresponding to the C major scale:

```matlab
note_segments = [0.12 0.61;
                 0.62 1.12;
                 1.13 1.62;
                 1.63 2.12;
                 2.13 2.62;
                 2.63 3.12;
                 3.13 3.62;
                 3.62 4.48];
```

### 2. Frequency-Domain Analysis

For each segmented note:

1. The corresponding time-domain samples were extracted.
2. The mean value was removed to reduce DC content.
3. A Hann window was applied to reduce spectral leakage.
4. The FFT was computed and shifted using `fftshift`.
5. The dominant peak in the 50–2000 Hz range was selected as the estimated fundamental frequency.

### 3. Digital Filtering

A Butterworth filter was used because it provides a smooth passband and is simple to implement for this type of assignment.

For the main script, the selected target note is A4. The passband is centered around the measured fundamental frequency of A4:

```matlab
f_passband = [f0_target - 15, f0_target + 15];
```

A 10th-order Butterworth band-pass filter was designed. To improve numerical stability, the filter was implemented using second-order sections with `zp2sos` and applied using `sosfilt`.

The GUI also supports:

- Band-pass filtering by selected note
- Low-pass filtering using a cutoff frequency between selected note pairs
- High-pass filtering using a cutoff frequency between selected note pairs

## Frequency Estimation Results

| Note | Measured Frequency (Hz) | Theoretical Frequency (Hz) | Error (%) |
|---|---:|---:|---:|
| C4 | 261.22 | 261.63 | 0.15 |
| D4 | 294.00 | 293.66 | 0.12 |
| E4 | 330.61 | 329.63 | 0.30 |
| F4 | 348.98 | 349.23 | 0.07 |
| G4 | 391.84 | 392.00 | 0.04 |
| A4 | 440.82 | 440.00 | 0.19 |
| B4 | 493.88 | 493.88 | 0.00 |
| C5 | 523.26 | 523.25 | 0.002 |

The measured frequencies are close to the theoretical values. Small deviations may result from FFT resolution, manual segmentation, background noise, spectral leakage, harmonic content, and slight tuning differences in the audio source.

## GUI Application

The MATLAB App Designer GUI allows the user to:

- Load the audio file
- Display the sampling frequency, total duration, and approximate note duration
- Plot the original time-domain signal
- Plot the original frequency-domain spectrum
- Select the filter type: band-pass, low-pass, or high-pass
- Select the filter order
- Select the target note or cutoff note pair
- Apply the selected filter
- Plot the filtered signal in the time domain
- Plot the filtered signal in the frequency domain
- Play the original and filtered audio signals

## Repository Files

| File | Description |
|---|---|
| `Assignment.pdf` | Original EE331 homework description and requirements |
| `Audio Signal Analysis and GUI-Based Filtering.pdf` | Final project report including method, results, discussion, and references |
| `Project_code.m` | Main MATLAB script for audio loading, segmentation, FFT analysis, frequency estimation, filtering, plotting, and optional audio export |
| `Project_app.mlapp` | MATLAB App Designer GUI file |
| `Project_app_code.m` | Exported MATLAB code version of the GUI |
| `C_Major_Scale_2_unfiltered.wav` | Original recorded C major scale audio file |
| `C_Major_Scale_2_filtered.wav` | Filtered output audio file |
| `README.md` | Project documentation |

## How to Run

### Run the MATLAB script

1. Open MATLAB.
2. Place all project files in the same folder.
3. Open `Project_code.m`.
4. Run the script.

The script will:

- Load `C_Major_Scale_2_unfiltered.wav`
- Plot the full time-domain waveform
- Plot a zoomed time-domain segment
- Segment the eight notes
- Compute and plot FFT spectra
- Estimate the fundamental frequencies
- Apply Butterworth filtering
- Plot original vs. filtered results

### Run the GUI

1. Open MATLAB.
2. Open `Project_app.mlapp` in App Designer.
3. Run the app.
4. Click **Load Audio File**.
5. Select the desired filter type, order, and note/cutoff pair.
6. Click **Apply Filter**.
7. Use **Play Original Audio** and **Play Filtered Audio** to compare the signals.

> Note: The app is currently written to load `C_Major_Scale_2_unfiltered.wav`, so the WAV file should be kept in the same folder as the app.

## Requirements

- MATLAB
- MATLAB App Designer
- Signal Processing Toolbox

Main MATLAB functions used:

- `audioread`
- `audiowrite`
- `fft`
- `fftshift`
- `hann`
- `butter`
- `zp2sos`
- `sosfilt`
- `audioplayer`

## Discussion

The project demonstrates how a real audio signal can be analyzed using fundamental Signals and Systems concepts. The FFT results show that each piano note has a dominant frequency close to its theoretical musical frequency. The Butterworth band-pass filter successfully emphasizes the selected note while attenuating other notes.

However, perfect note isolation is not expected because musical notes contain harmonics, neighboring notes may have overlapping spectral components, and real recordings include environmental noise. A narrower passband improves suppression of other notes, but it may also weaken the desired note if the measured frequency differs slightly from the ideal value.

## Author

Zekiye Ayperi TATAR  
Department of Electrical and Electronics Engineering  
Izmir Institute of Technology