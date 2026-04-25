# Wien Bridge & Schmitt Trigger Oscillators

## Overview

This project focuses on the design, analysis, and LTspice simulation of two oscillator circuits:

1. Wien Bridge Oscillator  
2. Schmitt Trigger Oscillator  

The project was completed as part of the EE313 Electronics II course. The main objective was to derive the theoretical design equations, calculate the required component values, simulate the circuits in LTspice, and compare the analytical expectations with simulation results.

The Wien Bridge oscillator was designed for sinusoidal oscillation around 16 kHz, while the Schmitt Trigger oscillator was designed to generate a square-wave output with a 1 kHz oscillation frequency.

---

## Project Objectives

- Derive the oscillation frequency of the Wien Bridge oscillator
- Determine the resistor values required for the desired oscillation frequency
- Apply the Barkhausen criterion to find the oscillation condition
- Simulate the Wien Bridge oscillator using the AD795 op-amp model in LTspice
- Investigate how the oscillation frequency changes with resistor variation
- Design a Schmitt Trigger oscillator with a specified capacitor voltage amplitude
- Calculate the resistor values required for 1 kHz oscillation
- Simulate and observe the waveforms of `vn`, `vp`, and `vo`
- Compare theoretical calculations with simulation results

---

## Tools Used

- LTspice
- MATLAB
- AD795 operational amplifier model
- Transient analysis
- Parameter sweep analysis
- SPICE measurement commands
- Oscillator theory
- Barkhausen criterion

---

## Part I - Wien Bridge Oscillator

## Circuit Description

The Wien Bridge oscillator is an RC-based sinusoidal oscillator. It uses a frequency-selective feedback network together with a non-inverting amplifier.

The feedback network consists of:

- A series RC branch
- A parallel RC branch

The amplifier gain is adjusted so that the circuit satisfies the oscillation condition.

---

## Wien Bridge Oscillation Frequency

For the general Wien Bridge oscillator, the oscillation frequency can be written in terms of the RC network as:

\[
f_0 = \frac{1}{2\pi \sqrt{R_1 R_2 C_1 C_2}}
\]

For the special case where:

\[
R_1 = R_2 = R
\]

and

\[
C_1 = C_2 = C
\]

the equation becomes:

\[
f_0 = \frac{1}{2\pi RC}
\]

---

## Design Conditions

The assignment required an oscillation frequency of approximately 16 kHz with:

| Component | Value |
|---|---:|
| C1 | 1 nF |
| C2 | 1 nF |

Using the oscillation frequency equation, the calculated resistor value was approximately:

\[
R_1 = R_2 \approx 9.95 \, k\Omega
\]

For practical implementation, the resistor values were selected as:

| Component | Value |
|---|---:|
| R1 | 10 kΩ |
| R2 | 10 kΩ |

This gives an oscillation frequency close to the target value.

---

## Barkhausen Criterion

For sustained oscillation, the Barkhausen criterion must be satisfied:

\[
A(j\omega_0)\beta(j\omega_0) = 1
\]

and the total phase shift around the loop must be:

\[
0^\circ \quad \text{or} \quad 360^\circ
\]

For the Wien Bridge oscillator, the feedback factor becomes approximately:

\[
\beta(j\omega_0) = \frac{1}{3}
\]

Therefore, the amplifier gain must be:

\[
A(j\omega_0) = 3
\]

For a non-inverting amplifier:

\[
A = 1 + \frac{R_3}{R_4}
\]

The assignment gave:

| Component | Value |
|---|---:|
| R4 | 10 kΩ |

To obtain a gain of 3:

\[
1 + \frac{R_3}{R_4} = 3
\]

\[
R_3 = 2R_4
\]

Therefore:

\[
R_3 = 20 \, k\Omega
\]

---

## Wien Bridge LTspice Simulation

The Wien Bridge oscillator was simulated in LTspice using the AD795 op-amp model and ±12 V power supplies.

The main component values used in the simulation were:

| Component | Value |
|---|---:|
| R1 | 10 kΩ |
| R2 | stepped from 10 kΩ to 15 kΩ |
| R3 | 20 kΩ |
| R4 | 10 kΩ |
| C1 | 1 nF |
| C2 | 1 nF |
| Op-amp | AD795 |
| Supply voltage | ±12 V |

The output node was labeled as:

```text
Vo
```

---

## Wien Bridge SPICE Directives

The following SPICE directives were used:

```spice
.step param R2val 10k 15k 0.5k

.tran 0 60m 0 0.2u

.meas tran Tper TRIG V(vo) VAL=0 RISE=1 TD=40m TARG V(vo) VAL=0 RISE=2 TD=40m
.meas tran Fosc PARAM '1/Tper'

.ic V(vo)=1m
```

### Explanation

| Directive | Purpose |
|---|---|
| `.step param R2val 10k 15k 0.5k` | Runs the simulation for different R2 values |
| `.tran 0 60m 0 0.2u` | Performs transient analysis for 60 ms |
| `.meas tran Tper ...` | Measures the oscillation period |
| `.meas tran Fosc PARAM '1/Tper'` | Calculates oscillation frequency |
| `.ic V(vo)=1m` | Provides an initial disturbance to start oscillation |

The measured oscillation frequencies were obtained from the SPICE Error Log.

---

## Wien Bridge Simulation Results

The resistor R2 was varied from 10 kΩ to 15 kΩ, and the measured oscillation frequency was compared with the calculated theoretical value.

| R2 (kΩ) | Measured Frequency (kHz) | Calculated Frequency (kHz) | % Error |
|---:|---:|---:|---:|
| 10.0 | 15.110 | 15.915 | 5.061 |
| 10.5 | 14.616 | 15.532 | 5.897 |
| 11.0 | 14.231 | 15.175 | 6.220 |
| 11.5 | 13.861 | 14.841 | 6.605 |
| 12.0 | 13.508 | 14.529 | 7.026 |
| 12.5 | 13.172 | 14.235 | 7.469 |
| 13.0 | 12.853 | 13.959 | 7.922 |
| 13.5 | 12.550 | 13.698 | 8.380 |
| 14.0 | 12.262 | 13.451 | 8.840 |
| 14.5 | 11.989 | 13.217 | 9.292 |
| 15.0 | 11.728 | 12.995 | 9.750 |

The results show that the oscillation frequency decreases as R2 increases. This agrees with the theoretical relationship:

\[
f_0 \propto \frac{1}{\sqrt{R_2}}
\]

The measured values are slightly lower than the calculated values because the theoretical formula assumes ideal circuit behavior, while the LTspice simulation uses a non-ideal op-amp model.

---

## Part II - Schmitt Trigger Oscillator

## Circuit Description

The Schmitt Trigger oscillator is a switching-type oscillator. Unlike the Wien Bridge oscillator, it does not generate a sine wave. Instead, it produces a square-wave output.

The circuit operation is based on:

- Positive feedback
- Hysteresis
- Capacitor charging and discharging
- Switching thresholds

The output voltage `vo` switches between high and low saturation levels, while the capacitor voltage `vn` charges and discharges between threshold voltages.

---

## Schmitt Trigger Design Conditions

The assignment required:

| Requirement | Value |
|---|---:|
| Peak-to-peak amplitude of `vn` | 4 V |
| Output voltage assumption | -10 V to +10 V |
| Oscillation frequency | 1 kHz |
| C1 | 10 nF |
| R2 | 10 kΩ |

Since the peak-to-peak amplitude of `vn` is 4 V:

\[
V_{n,p-p} = 4V
\]

The threshold voltage is:

\[
V_T = 2V
\]

---

## Threshold Voltage Calculation

The positive feedback divider sets the threshold voltage:

\[
V_T = \frac{R_3}{R_2 + R_3} V_o
\]

Using:

\[
V_T = 2V
\]

\[
V_o = 10V
\]

\[
R_2 = 10k\Omega
\]

we get:

\[
2 = \frac{R_3}{10k + R_3} \times 10
\]

Solving this equation gives:

\[
R_3 = 2.5k\Omega
\]

---

## Period and Frequency Calculation

The period of the Schmitt Trigger oscillator can be expressed as:

\[
T = 2R_1C_1 \ln \left( \frac{10 + V_T}{10 - V_T} \right)
\]

For:

\[
f = 1kHz
\]

\[
T = 1ms
\]

\[
V_T = 2V
\]

\[
C_1 = 10nF
\]

the calculated value of R1 is:

\[
R_1 = 123.32k\Omega
\]

---

## Schmitt Trigger LTspice Simulation

The Schmitt Trigger oscillator was simulated in LTspice using the AD795 op-amp model and ±12 V supplies.

The component values used in the simulation were:

| Component | Value |
|---|---:|
| R1 | 123.32 kΩ |
| R2 | 10 kΩ |
| R3 | 2.5 kΩ |
| C1 | 10 nF |
| Op-amp | AD795 |
| Supply voltage | ±12 V |

The important nodes are:

| Node | Description |
|---|---|
| `Vo` | Output voltage |
| `Vn` | Capacitor voltage at the inverting input |
| `Vp` | Threshold voltage at the non-inverting input |

The transient simulation command was:

```spice
.tran 10m
```

---

## Schmitt Trigger Simulation Results

The simulation produces three main waveforms:

| Signal | Expected Behavior |
|---|---|
| `vo` | Square wave output |
| `vp` | Positive and negative threshold levels |
| `vn` | Capacitor charging and discharging waveform |

The output `vo` switches between positive and negative voltage levels. The voltage `vp` changes according to the output state because it is generated by the positive feedback divider. The capacitor voltage `vn` charges and discharges until it reaches the switching thresholds. When `vn` reaches the threshold, the op-amp output switches and the charging direction reverses.

---

## Project Files

| File / Folder | Description |
|---|---|
| `Assignment.pdf` | Homework description and design requirements |
| `Wien Bridge & Schmitt Trigger Oscillators.pdf` | Final report including theory, calculations, simulations, plots, and commentary |
| `README.md` | Project documentation |
| `Wien_Bridge_graphic.m` | MATLAB script used to compare measured and calculated Wien Bridge oscillation frequencies |
| `Calculations/` | Hand calculations for the Wien Bridge and Schmitt Trigger oscillators |
| `Figures/` | Simulation results and MATLAB frequency comparison plots |
| `Schematics/` | Circuit schematic images |
| `Simulations/Wien_Bridge_Sim.asc` | LTspice simulation file for the Wien Bridge oscillator |
| `Simulations/Schmitt_Trigger_Sim.asc` | LTspice simulation file for the Schmitt Trigger oscillator |

---

## Repository Structure

```text
Wien Bridge & Schmitt Trigger Oscillators/
│
├── Assignment.pdf
├── Wien Bridge & Schmitt Trigger Oscillators.pdf
├── README.md
├── Wien_Bridge_graphic.m
│
├── Calculations/
│   ├── Wien Bridge Calculations.JPG
│   └── Schmitt Trigger Calculations.JPG
│
├── Figures/
│   ├── Wien Bridge oscillation frequency.png
│   ├── Wien Bridge sim results.JPG
│   ├── Schmitt Trigger - Vn plot.JPG
│   ├── Schmitt Trigger - Vp plot.JPG
│   └── Schmitt Trigger - Vo plot.JPG
│
├── Schematics/
│   ├── Wien Bridge Oscillator Schematic.JPG
│   └── Schmitt Trigger Oscillator Schematic.JPG
│
└── Simulations/
    ├── Wien_Bridge_Sim.asc
    └── Schmitt_Trigger_Sim.asc
```

---

## How to Run the Simulations

### Wien Bridge Oscillator

1. Open LTspice.
2. Go to the `Simulations/` folder.
3. Open:

```text
Wien_Bridge_Sim.asc
```

4. Run the simulation.
5. Plot the output voltage:

```spice
V(vo)
```

6. Open the SPICE Error Log to see the measured oscillation frequency values for each R2 step.
7. To compare the measured and calculated frequency values, open MATLAB and run:

```matlab
Wien_Bridge_graphic
```

---

### Schmitt Trigger Oscillator

1. Open LTspice.
2. Go to the `Simulations/` folder.
3. Open:

```text
Schmitt_Trigger_Sim.asc
```

4. Run the transient simulation.
5. Plot the following node voltages:

```spice
V(vo)
V(vn)
V(vp)
```

6. Observe the square-wave output and the capacitor charging/discharging behavior.

---

## Practical Limitations

The simulation results are close to the theoretical expectations, but exact agreement is not expected because:

- The theoretical equations assume ideal op-amp behavior.
- The AD795 op-amp model is non-ideal.
- The output voltage may not switch exactly between -10 V and +10 V.
- Slew rate and bandwidth limitations can affect high-frequency behavior.
- Oscillation amplitude can be affected by saturation and clipping.
- Simulation timestep can influence the accuracy of measured oscillation frequency.
- Component value approximations slightly shift the expected frequency.

---

## What I Learned

Through this project, I practiced:

- Deriving oscillator frequency equations
- Applying the Barkhausen criterion
- Designing a Wien Bridge oscillator
- Understanding positive feedback and hysteresis
- Designing a Schmitt Trigger oscillator
- Calculating threshold voltages
- Expressing oscillator period using capacitor charging equations
- Simulating oscillator circuits in LTspice
- Using SPICE measurement commands
- Running parameter sweeps
- Comparing theoretical and simulated results
- Using MATLAB to visualize frequency variation

---

## Conclusion

In this project, two oscillator circuits were designed, analyzed, and simulated. The Wien Bridge oscillator generated a sinusoidal output, and the Schmitt Trigger oscillator generated a square-wave output.

For the Wien Bridge oscillator, the required oscillation condition was obtained using the Barkhausen criterion. The simulation results showed that increasing R2 decreases the oscillation frequency, which agrees with the theoretical frequency equation.

For the Schmitt Trigger oscillator, the threshold voltage and oscillation period were calculated using the capacitor charging behavior. The simulation results showed the expected square-wave output and capacitor voltage waveform.

Overall, the project demonstrates how theoretical oscillator design can be verified using LTspice simulations and how non-ideal circuit behavior can cause small differences between analytical and simulated results.

---

## Author

Zekiye Ayperi TATAR  
Department of Electrical and Electronics Engineering  
Izmir Institute of Technology