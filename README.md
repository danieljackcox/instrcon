# instrcon (UNFINISHED)
Libraries/classes for Matlab instrument control and measurement. Provided with example measurement scripts.

Measurement devices are represented by device driver files, which are Matlab objects that expose common functions (such as setvoltage, readvoltage, etc.). The specific code needed to change (in this example) voltage on a device is held within these driver files.

Higher level functions use these driver files to implement more complex operations used in measurement (i.e. safe voltage ramping, frequency sweeps, etc.).

A common bootstrap object provides functions that are required to 'bootstrap' the system and read settings, for example storing the location of temperature logs or opening devices and passing the correct driver object on.

# Supported devices
* Standard Research Systems SR830 Lock-in Amplifier
* HP/Agilent/Keysight 33120A 15 MHz Function/arbitrary Waveform Generator
* HP/Agilent/Keysight 34401A Digital multimeter
* Keithley 2400 Sourcemeter
* Keithley 2450 Sourcemeter
