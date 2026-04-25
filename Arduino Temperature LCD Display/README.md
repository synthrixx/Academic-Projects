# Arduino Temperature Monitoring System with LCD

## Overview

This project is an Arduino-based embedded system simulation designed in Tinkercad.  
The system measures the ambient temperature using an analog temperature sensor and displays the calculated temperature value on a 16x2 LCD screen.

The project demonstrates basic embedded system concepts such as analog sensor reading, ADC conversion, temperature calculation, LCD interfacing, and real-time data display.

The circuit was built and tested in Tinkercad Circuits, and the program was written in Arduino C/C++ using text-based coding.

## Project Purpose

The main purpose of this project is to design a simple temperature monitoring system using Arduino.  
The Arduino reads the analog output voltage of the temperature sensor, converts this value into temperature in Celsius, and continuously updates the LCD display.

This type of system represents a basic example of an embedded system because it collects data from a sensor, processes the data using a microcontroller, and gives an output through a display.

## Features

- Reads analog temperature sensor data
- Converts raw ADC values into voltage
- Calculates temperature in Celsius
- Displays temperature on a 16x2 LCD screen
- Updates the displayed value continuously
- Simulated using Tinkercad Circuits
- Uses the `LiquidCrystal` library for LCD control

## Tools and Components Used

### Hardware / Simulation Components

- Arduino Uno
- TMP36 temperature sensor
- 16x2 LCD display
- Potentiometer for LCD contrast adjustment
- Breadboard
- Jumper wires
- Tinkercad Circuits

### Software

- Arduino C/C++
- Tinkercad Circuits
- LiquidCrystal library

## Circuit Description

The temperature sensor is connected to the analog input pin A0 of the Arduino.  
The sensor produces an analog voltage depending on the measured temperature.

The Arduino reads this analog voltage using the `analogRead()` function. Since Arduino Uno has a 10-bit ADC, the analog input value is represented between 0 and 1023.

The 16x2 LCD is connected to the Arduino using digital pins.  
The `LiquidCrystal` library is used to control the LCD and print the temperature value.

A potentiometer is used to adjust the contrast of the LCD screen so that the displayed text can be clearly seen.

## Pin Connections

| Component | Arduino Pin |
|---|---|
| Temperature Sensor Output | A0 |
| LCD RS | D12 |
| LCD Enable | D11 |
| LCD D4 | D5 |
| LCD D5 | D4 |
| LCD D6 | D3 |
| LCD D7 | D2 |
| LCD VCC | 5V |
| LCD GND | GND |

## Working Principle

The Arduino reads the analog value from the temperature sensor:

```cpp
int read = analogRead(A0);
```

Then, the raw ADC value is converted into voltage in milivolts using the map() function:

```cpp
long voltage = map(read,0,1023,0,5000);
```

For a TMP36-type temperature sensor, the output voltage has a 500 mV offset.  
Therefore, the temperature in Celsius is calculated as:

```cpp
float true_temperature = (voltage - 500) / 10.0;
```

To make the output easier to read, the temperature value is rounded to nearest integer:

```cpp
int temperature = round(true_temperature);
```

Finally, the calculated temperature is displayed on the LCD:

```cpp
lcd.setCursor(0,0);
lcd.print("Temperature: ");

lcd.setCursor(0,1);
lcd.print(temperature);
lcd.print(" C degrees");
```

The display is updated every 1000 milliseconds - or, equivalently 1 seconds:

```cpp
delay(1000);
```

## Code Structure

The program consists of two main parts:

### 1. Setup Function

In the `setup()` function, the LCD is initialized as a 16-column and 2-row display.

```cpp
void setup() {
  lcd.begin(16, 2);
}
```

### 2. Loop Function

In the `loop()` function:

1. The analog temperature sensor value is read.
2. The raw ADC value is converted into millivolts using map().
3. The voltage is converted into temperature in Celsius.
4. The temperature value is rounded to the nearest integer.
5. The LCD is cleared and updated with the new temperature value.
6. The system waits for 1000 ms before updating again.

## Files

| File | Description |
|---|---|
| `Arduino_Project_Code.txt` | Arduino source code |
| `Project_Result.JPG` | Screenshot of the working Tinkercad simulation |
| `Assignment.pdf` | Assignment description |
| `Tinkercad-link.html` | Shareable Tinkercad simulation link |
| `README.md` | Project documentation |

## Simulation Result

The simulation successfully displays the measured temperature value on the LCD screen.

In the sample output, the LCD shows:

```text
Temperature:
25 C degrees
```

This confirms that the Arduino reads the sensor value correctly, processes the analog input, calculates the temperature, and displays the result on the LCD.

## How to Run the Project

1. Open the Tinkercad project link.
2. Start the simulation.
3. Observe the temperature value displayed on the LCD.
4. Change the temperature sensor value in Tinkercad.
5. The LCD will update the displayed temperature automatically.

## What I Learned

Through this project, I practiced:

- Basic embedded system design
- Arduino programming
- Analog sensor interfacing
- ADC value conversion
- Temperature calculation from sensor voltage
- LCD display control
- Using the LiquidCrystal library
- Circuit simulation with Tinkercad
- Real-time data display in embedded systems

## Possible Improvements

This project can be improved by adding:

- Temperature warning messages
- LED indicators for temperature levels
- Buzzer alarm for high temperature
- Celsius/Fahrenheit conversion
- Data logging
- More accurate sensor calibration

## Author

Zekiye Ayperi Tatar  
Electronics and Communications Engineering  
Izmir Institute of Technology
