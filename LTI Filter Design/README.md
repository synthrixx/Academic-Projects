# LTI Filter Design for Frequency Component Selection

## Overview

This project focuses on the design and simulation of continuous-time Linear Time-Invariant (LTI) filter systems for a composite sinusoidal input signal.

The given input signal is composed of three sinusoidal frequency components:

\[
x(t) = \sin(2\pi f_1t) + \sin(2\pi f_2t) + \sin(2\pi f_3t)
\]

where:

- \( f_1 = 500 \, \text{Hz} \)
- \( f_2 = 2 \, \text{kHz} \)
- \( f_3 = 10 \, \text{kHz} \)

The main objective is to design three separate LTI systems such that each system approximately extracts one desired frequency component while attenuating the other two components.

The target outputs are:

\[
y_1(t) \approx \sin(2\pi f_1t)
\]

\[
y_2(t) \approx \sin(2\pi f_2t)
\]

\[
y_3(t) \approx \sin(2\pi f_3t)
\]

To achieve this goal, three active filter circuits were designed and simulated using LTspice.

---

## Project Objectives

- Design an LTI system to isolate the 500 Hz component
- Design an LTI system to isolate the 2 kHz component
- Design an LTI system to isolate the 10 kHz component
- Select appropriate filter types according to the desired frequency regions
- Perform analytical calculations for the filter component values
- Simulate the designed circuits using LTspice
- Analyze filter behavior using Bode plots
- Discuss the assumptions and practical limitations of the designed systems

---

## Tools Used

- LTspice
- Active filter design
- Butterworth filter theory
- Bode plot analysis
- Frequency-domain simulation
- AC sweep analysis
- LM741 operational amplifier model

---

## Input Signal

The input signal contains three frequency components:

| Component | Frequency | Description |
|---|---:|---|
| \( f_1 \) | 500 Hz | Low-frequency component |
| \( f_2 \) | 2 kHz | Mid-frequency component |
| \( f_3 \) | 10 kHz | High-frequency component |

Since the three frequencies are located in clearly different frequency regions, different filter types were selected for each target component.

---

## Filter Design Strategy

Three filters were designed:

| Target Frequency | Desired Output | Selected Filter Type |
|---:|---|---|
| 500 Hz | \( y_1(t) \) | Low-pass filter |
| 2 kHz | \( y_2(t) \) | Band-pass filter |
| 10 kHz | \( y_3(t) \) | High-pass filter |

The low-pass filter was used to extract the lowest-frequency component, the high-pass filter was used to extract the highest-frequency component, and the band-pass filter was used to extract the middle-frequency component.

---

## 1. Low-Pass Filter Design

A two-pole active low-pass Butterworth filter was designed to pass the 500 Hz component and attenuate the 2 kHz and 10 kHz components.

The design criterion was that the loss at 500 Hz should be less than 1 dB. This means that the desired 500 Hz component should remain mostly preserved at the output.

From the Butterworth magnitude response, the cutoff frequency condition was selected to satisfy this requirement. A cutoff frequency around 723 Hz was obtained using the selected component values.

The LTspice simulation uses the following component values:

| Component | Value |
|---|---:|
| R1 | 22 kΩ |
| R2 | 22 kΩ |
| C3 | 14.14 nF |
| C4 | 7.07 nF |

The low-pass filter output is taken from the node labeled `vo`.

### Expected Behavior

- The 500 Hz component should pass with small attenuation.
- The 2 kHz component should be significantly attenuated.
- The 10 kHz component should be strongly attenuated.

---

## 2. High-Pass Filter Design

A two-pole active high-pass Butterworth filter was designed to pass the 10 kHz component and attenuate the 500 Hz and 2 kHz components.

The cutoff frequency was selected near 10 kHz. Since a Butterworth filter has approximately -3 dB gain at the cutoff frequency, some attenuation at 10 kHz is expected. However, the lower-frequency components should be much more strongly attenuated.

The LTspice simulation uses the following component values:

| Component | Value |
|---|---:|
| C1 | 1 nF |
| C2 | 1 nF |
| R3 | 11.3 kΩ |
| R4 | 22.5 kΩ |

The high-pass filter output is taken from the node labeled `vo`.

### Expected Behavior

- The 10 kHz component should pass through the filter.
- The 500 Hz component should be strongly attenuated.
- The 2 kHz component should also be attenuated.

---

## 3. Band-Pass Filter Design

An active band-pass filter was designed to isolate the 2 kHz component from the composite input signal.

The band-pass circuit uses three operational amplifier stages. The output nodes are labeled as:

| Node | Meaning |
|---|---|
| `vo1` | Main band-pass output |
| `vo2` | Buffered stage output |
| `vo3` | Final amplifier stage output |

For the band-pass analysis, the main output is taken from `vo1`.

The LTspice simulation uses the following component values:

| Component | Value |
|---|---:|
| R1 | 79.5 kΩ |
| R2 | 7.9 kΩ |
| R3 | 7.9 kΩ |
| R4 | 79.5 kΩ |
| R5 | 10 kΩ |
| R6 | 10 kΩ |
| C1 | 10 nF |
| C2 | 10 nF |

R5 and R6 were selected as equal values in order to keep the final inverting amplifier stage at approximately unity gain. This prevents unintended amplification of the filtered signal.

### Expected Behavior

- The 2 kHz component should pass through the filter.
- The 500 Hz component should be attenuated.
- The 10 kHz component should also be attenuated.

---

## LTspice Simulation

Each filter circuit was implemented and simulated in LTspice.

The AC sweep directive used in the simulations is:

```spice
.ac dec 200 1 200k
```

This performs an AC small-signal frequency sweep from 1 Hz to 200 kHz with 200 points per decade.

For each filter, the transfer function was observed using:

```spice
V(vo) / V(vi)
```

For the band-pass filter, the main output node was `vo1`, so the transfer function was observed using:

```spice
V(vo1) / V(vi)
```

The Bode plots were used to verify whether the desired frequency component was passed and the unwanted components were attenuated.

---

## Simulation Results

The simulation results confirm that the selected filter types are appropriate for the given signal.

### Low-Pass Filter Result

The low-pass filter passes the 500 Hz component while attenuating the higher-frequency components. The Bode plot shows that the gain remains relatively high around 500 Hz and decreases as frequency increases.

### High-Pass Filter Result

The high-pass filter passes the 10 kHz component while attenuating the lower-frequency components. The Bode plot shows strong attenuation at 500 Hz and 2 kHz, while the response increases toward the high-frequency region.

### Band-Pass Filter Result

The band-pass filter passes the frequency region around 2 kHz. The Bode plot confirms that the filter response is concentrated around the middle-frequency component, while the lower and higher components are attenuated.

---

## Project Files

| File / Folder | Description |
|---|---|
| `Assignment.pdf` | Homework description and design requirements |
| `LTI Filter Design.pdf` | Final report including objective, method, calculations, schematics, Bode plots, and commentary |
| `README.md` | Project documentation |
| `Calculations/` | Hand calculations for low-pass, high-pass, and band-pass filter designs |
| `Schematics/` | Circuit schematic images for the three filters |
| `Figures/` | Bode plot results obtained from LTspice simulations |
| `Simulations/Low-Pass Filter sim.asc` | LTspice simulation file for the low-pass filter |
| `Simulations/High-Pass Filter sim.asc` | LTspice simulation file for the high-pass filter |
| `Simulations/Bandpass Filter sim.asc` | LTspice simulation file for the band-pass filter |

---

## Repository Structure

```text
LTI Filter Design/
│
├── Assignment.pdf
├── LTI Filter Design.pdf
├── README.md
│
├── Calculations/
│   ├── Low-Pass Filter Calculations.JPG
│   ├── High-Pass Filter Calculations.JPG
│   └── Bandpass Filter Calculations.JPG
│
├── Figures/
│   ├── Low-Pass Filter - Bode Plot.JPG
│   ├── High-Pass Filter - Bode Plot.JPG
│   └── Bandpass Filter - Bode Plot.JPG
│
├── Schematics/
│   ├── Low-Pass Filter schematic.JPG
│   ├── High-Pass Filter schematic.JPG
│   └── Bandpass Filter schematic.JPG
│
└── Simulations/
    ├── Low-Pass Filter sim.asc
    ├── High-Pass Filter sim.asc
    └── Bandpass Filter sim.asc
```

---

## How to Run the Simulations

1. Open LTspice.
2. Go to the `Simulations/` folder.
3. Open one of the following files:
   - `Low-Pass Filter sim.asc`
   - `High-Pass Filter sim.asc`
   - `Bandpass Filter sim.asc`
4. Run the simulation.
5. In the waveform viewer, plot the transfer function.

For the low-pass and high-pass filters:

```spice
V(vo)/V(vi)
```

For the band-pass filter:

```spice
V(vo1)/V(vi)
```

6. Observe the magnitude and phase response from the Bode plot.
7. Check whether the desired frequency component is passed and the unwanted components are attenuated.

---

## Practical Limitations

Although the designed filters successfully isolate the desired frequency regions in simulation, practical limitations should be considered:

- The filters have finite order, so unwanted frequency components are attenuated but not completely removed.
- The Butterworth response gives a smooth passband but does not have the sharpest possible transition region.
- The 10 kHz component lies near the high-pass cutoff frequency, so some attenuation is expected.
- Real operational amplifiers have non-ideal behavior such as limited bandwidth, slew rate, and input/output constraints.
- The LM741 op-amp model may not represent an ideal op-amp at all frequencies.
- Component tolerances in a real circuit would slightly shift the cutoff frequencies.
- In real hardware, resistor and capacitor tolerances would affect the exact cutoff and center frequencies.

---

## What I Learned

Through this project, I gained practical experience in:

- Designing LTI systems for frequency selection
- Selecting proper filter types according to target frequency components
- Applying Butterworth filter theory
- Calculating active filter component values
- Building active filter circuits in LTspice
- Running AC sweep simulations
- Interpreting Bode plots
- Comparing analytical expectations with simulation results
- Understanding practical limitations of real filter circuits

---

## Conclusion

In this project, three different LTI filter systems were designed to isolate the three sinusoidal components of a composite input signal. A low-pass filter was designed for the 500 Hz component, a band-pass filter was designed for the 2 kHz component, and a high-pass filter was designed for the 10 kHz component.

The LTspice simulations showed that each filter approximately passes the desired frequency component while attenuating the other two components. The results demonstrate the importance of selecting the correct filter type and cutoff frequency according to the desired frequency range.

Overall, the project shows how LTI systems can be used for frequency-selective signal processing and how theoretical filter design can be verified using circuit simulation tools.

---

## Author

Zekiye Ayperi TATAR  
Department of Electrical and Electronics Engineering  
Izmir Institute of Technology