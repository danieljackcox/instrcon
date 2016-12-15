# instrcon
Libraries/classes for Matlab instrument control and measurement. Provided with example measurement scripts.

Measurement devices are represented by device driver files, which are Matlab objects that expose common functions (such as setvoltage, getvoltage, etc.). The specific code needed to change voltage on a device is held within these driver files.

Higher level functions use these driver files to implement more complex operations used in measurement (i.e. safe voltage ramping, frequency sweeps, etc.).

A common object provides functions that are required to 'bootstrap' the system or are instrument agnostic.

# Supported devices
* Standard Research Systems SR830 Lock-in Amplifier
