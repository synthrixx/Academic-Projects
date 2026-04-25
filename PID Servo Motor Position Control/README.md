# PID Servo Motor Position Control

## Overview

This project focuses on the modeling, simulation, and PID control of a servo motor position control system using MATLAB and Simulink.

The main objective is to control the angular position of a servo motor and make the motor reach a desired reference position of:

\[
\theta_{desired} = \pi \, \text{rad}
\]

which corresponds to 180 degrees.

The servo motor was modeled using a second-order differential equation. A PID controller was then added to the closed-loop system to improve the transient response, reduce steady-state error, and make the motor position settle around the desired reference value.

This project was completed as part of the CENG424 Embedded Computer Systems course.

---

## Project Objectives

- Model a servo motor position control system in Simulink
- Represent the motor dynamics using differential equations
- Design a PID controller for position control
- Tune the PID controller using Simulink tools
- Simulate the closed-loop system response
- Evaluate position accuracy and response time
- Analyze rise time, settling time, overshoot, and steady-state error

---

## Tools Used

- MATLAB
- Simulink
- PID Controller block
- Scope block
- Gain, Sum, Constant, and Integrator blocks
- MATLAB parameter script

---

## System Description

The system consists of a servo motor controlling the position of a rotating arm. The input of the system is the control signal voltage \(u(t)\), and the output is the angular position \(\theta(t)\).

The servo motor dynamics are described by the following second-order differential equation:

\[
J\frac{d^2\theta(t)}{dt^2} + B\frac{d\theta(t)}{dt} = K_t u(t)
\]

where:

| Symbol | Description | Unit |
|---|---|---|
| \(\theta(t)\) | Angular position of the motor | rad |
| \(u(t)\) | Input control signal | V |
| \(J\) | Moment of inertia | kg·m² |
| \(B\) | Damping coefficient | N·m·s/rad |
| \(K_t\) | Torque constant | N·m/A |

---

## System Parameters

The following parameter values were used:

| Parameter | Symbol | Value | Unit |
|---|---|---:|---|
| Moment of inertia | J | 0.005 | kg·m² |
| Damping coefficient | B | 0.6 | N·m·s/rad |
| Torque constant | Kt | 0.08 | N·m/A |
| Desired position | θdesired | π | rad |
| Initial position | θ(0) | 0 | rad |

The calculated gain values are:

| Gain | Formula | Value |
|---|---|---:|
| Kdc | Kt / J | 16 |
| Bdc | B / J | 120 |

---

## Mathematical Model

Starting from the servo motor equation:

\[
J\ddot{\theta}(t) + B\dot{\theta}(t) = K_t u(t)
\]

the equation can be rearranged as:

\[
\ddot{\theta}(t) = \frac{K_t}{J}u(t) - \frac{B}{J}\dot{\theta}(t)
\]

Using the given numerical values:

\[
\ddot{\theta}(t) = 16u(t) - 120\dot{\theta}(t)
\]

This equation was implemented in Simulink using Gain, Sum, and Integrator blocks.

---

## Transfer Function

The transfer function of the servo motor from input voltage \(u(t)\) to angular position \(\theta(t)\) is:

\[
\frac{\Theta(s)}{U(s)} = \frac{K_t}{Js^2 + Bs}
\]

Substituting the given values:

\[
\frac{\Theta(s)}{U(s)} = \frac{0.08}{0.005s^2 + 0.6s}
\]

Dividing by 0.005:

\[
\frac{\Theta(s)}{U(s)} = \frac{16}{s^2 + 120s}
\]

---

## Simulink Model

The servo motor position control system was implemented as a closed-loop feedback system.

The Simulink model includes:

- Constant reference input for \(\theta_{desired} = \pi\)
- Error calculation block
- PID Controller block
- Gain block for \(K_t/J = 16\)
- Gain block for \(B/J = 120\)
- Sum block for acceleration calculation
- Two integrator blocks:
  - First integrator obtains angular velocity \(\dot{\theta}(t)\)
  - Second integrator obtains angular position \(\theta(t)\)
- Feedback path from output position to the error calculation block
- Scope block for observing the output response

The general closed-loop structure is:

```text
Reference Position → Error Calculation → PID Controller → Servo Motor Model → Angular Position Output
                                      ↑                                      |
                                      |______________________________________|
```

---

## PID Controller Design

The PID controller was used to control the motor position according to the position error:

\[
e(t) = \theta_{desired} - \theta(t)
\]

The controller generates the control signal \(u(t)\), which is applied to the servo motor model.

The PID controller improves the system response by:

| PID Term | Effect |
|---|---|
| Proportional term | Speeds up the response and reacts to present error |
| Integral term | Reduces or eliminates steady-state error |
| Derivative term | Improves damping and reduces excessive oscillation |

The PID controller was tuned in Simulink to obtain a fast response, limited overshoot, and nearly zero steady-state error.

---

## MATLAB Parameter Script

The project includes a MATLAB script named:

```text
parameters.m
```

The script defines the system parameters:

```matlab
J = 0.005;
B = 0.6;
kt = 0.08;
theta_desired = pi;
theta_initial = 0;

K_dc = kt / J;
B_dc = B / J;
```

These values are used by the Simulink model during simulation.

---

## Simulation Results

The system was simulated for 0.5 seconds, which was long enough to observe both the transient response and steady-state behavior.

The output position starts from 0 rad and rises rapidly toward the desired value of:

\[
\pi \approx 3.1416 \, \text{rad}
\]

The response shows a small overshoot at the beginning and then settles close to the reference value.

---

## Performance Summary

| Metric | Approximate Value | Comment |
|---|---:|---|
| Rise time | 0.01-0.02 s | The output reaches the target very quickly |
| Peak value | 3.42 rad | Maximum output value reached |
| Overshoot | 8.9% | Small overshoot before settling |
| Settling time | 0.15-0.20 s | Output becomes stable in a short time |
| Steady-state value | ≈ π rad | Final value is close to the reference |
| Steady-state error | ≈ 0 rad | No significant residual error |

---

## Result Evaluation

### Position Accuracy

The system reaches the desired angular position of approximately \(\pi\) radians. The final value stays very close to the reference input, which means that the steady-state error is approximately zero.

### Response Time

The response is fast. The motor reaches the target position in a short time, and the output settles in approximately 0.15-0.20 seconds.

### Overshoot

The system has a small overshoot. The peak value is approximately 3.42 rad, corresponding to an overshoot of about 8.9%. This overshoot is acceptable for this simulation, but it could be further reduced by tuning the PID controller more conservatively.

### Stability

The closed-loop system is stable. After the initial transient response, the output settles around the desired position instead of oscillating continuously or diverging.

---

## Project Files

| File | Description |
|---|---|
| `Assignment.pdf` | Homework description and project requirements |
| `PID_Report.pdf` | Final report including modeling, Simulink design, simulation results, and performance evaluation |
| `README.md` | Project documentation |
| `parameters.m` | MATLAB script containing system parameters |
| `PID_Servo_design.slx` | Simulink model of the PID-controlled servo motor system |
| `Simulink_Model.JPG` | Screenshot of the Simulink block diagram |
| `Simulink_Scope.JPG` | Scope output showing the angular position response |

---

## Repository Structure

```text
PID Servo Motor Position Control/
│
├── Assignment.pdf
├── PID_Report.pdf
├── README.md
├── parameters.m
├── PID_Servo_design.slx
├── Simulink_Model.JPG
└── Simulink_Scope.JPG
```

---

## How to Run the Project

1. Open MATLAB.
2. Open the project folder.
3. Run the parameter script:

```matlab
parameters
```

4. Open the Simulink model:

```matlab
open_system('PID_Servo_design.slx')
```

5. Run the Simulink simulation.
6. Open the Scope block to observe the angular position response.
7. Check whether the output reaches and settles around:

```matlab
pi
```

---

## Expected Output

The expected output is a position response where:

- The motor starts from 0 rad.
- The position increases rapidly toward \(\pi\) rad.
- A small overshoot occurs.
- The response settles around \(\pi\) rad.
- The steady-state error is approximately zero.

---

## Practical Limitations

Although the simulation results are satisfactory, several practical limitations should be considered:

- The model is simplified and does not include all real servo motor nonlinearities.
- Real motors may have saturation limits.
- Friction, backlash, and load changes are not fully modeled.
- Sensor noise is not included in the simulation.
- The PID controller was tuned for the given parameters and may need retuning for a different motor.
- A real embedded implementation would require sampling time selection and discrete-time control.
- Excessive control effort may occur if PID gains are too aggressive.

---

## What I Learned

Through this project, I practiced:

- Modeling a physical system using differential equations
- Converting a second-order system into a Simulink block diagram
- Using Gain, Sum, Constant, and Integrator blocks
- Creating a closed-loop feedback control system
- Designing and tuning a PID controller
- Simulating a servo motor position control system
- Evaluating transient response behavior
- Interpreting rise time, overshoot, settling time, and steady-state error
- Understanding how PID control improves system performance

---

## Conclusion

In this project, a PID-controlled servo motor position control system was successfully modeled and simulated using MATLAB and Simulink.

The servo motor dynamics were represented using a second-order differential equation. The equation was rearranged and implemented in Simulink using basic mathematical blocks. A PID controller was then added to create a closed-loop position control system.

The simulation results showed that the motor reaches the desired reference position of \(\pi\) radians with fast response, limited overshoot, and almost zero steady-state error.

Overall, this project demonstrates the practical use of PID control for servo motor position tracking and shows how Simulink can be used to model, simulate, and evaluate closed-loop control systems.

---

## Author

Zekiye Ayperi TATAR  
Department of Computer Engineering  
Izmir Institute of Technology