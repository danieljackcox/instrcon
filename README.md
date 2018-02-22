# instrcon (UNFINISHED)
Libraries/classes for Matlab instrument control and measurement. Provided with example measurement scripts.

Measurement devices are represented by device driver files, which are Matlab objects that expose common functions (such as setoutputvoltage, setinputvoltage, etc.). The specific code needed to change (in this example) voltage on a device is held within these driver files.

Higher level functions use these driver files to implement more complex operations used in measurement (i.e. safe voltage ramping, frequency sweeps, etc.).


# Supported devices
* Standard Research Systems SR830 Lock-in Amplifier
* HP/Agilent/Keysight 33120A 15 MHz Function/Arbitrary Waveform Generator
* HP/Agilent/Keysight 34401A Digital multimeter
* Keithley 2400 Sourcemeter
* Keithley 2450 Sourcemeter
* Agilent 33522A 30 MHz Function/Arbitrary Waveform Generator
* Tenma 72-2550 power supply
* HP8656B signal generator
* Keysight 33510/33511B function generators
* Agilent N9310A signal generator
* Agilent 33509B function generator

# TODO
* Write first prototype script
* Write test scripts to test small parts of the system
* Update K2400 files to work
* Check that A33522A actually works
* Update main documentation (this)
* Check for any left over 'n.b.' comments in code and fix issues
* Test HP8656B frequency generator
* Add other agilent/keysight devices
* In general retest every instrument because they probably dont work anymore
* on HP8656B and AN9310A the frequency and amplitude commands include units, expand support so user can input any unit they want
* Check AN9310A IDN response
* Temperature measurement


# Contents
[Organisation](#Organisation)


# Organisation

Files are organised into subdirectories depending on their type. There are three subdirectories, `/drivers`, `/scripts`, and `/functions`.  

'Driver' files are matlab objects that represent physical measurement devices and are organised into the `/drivers`
folder. All instrument drivers should be named after the model of the device, e.g. `SR830.m`.  

High-level functions that operate on devices to perform a more complicated set of actions then can done with single SCPI functions live in the `/functions` folder. Each type of instrument (e.g. a voltage source) has a corresponding virtual hardware object that implements the higher level functions (e.g. a voltage sweepeer) and defines the minimum set of methods (functions) an instrument driver should implement. The virtual hardware object for a voltage source is located in `voltagesource.m`. An example of a function is a voltage sweeper that uses `getoutputvoltage`/`setoutputvoltage` functions exposed by the driver to safely sweep voltages.  

Full measurement scripts are in the `/scripts` folder.

# Drivers

Driver files contain the actual SCPI commands sent to the device under use, they expose these commands (which vary with most devices) via standard functions, they are named using the model number of the device (which due to matlab reasons must begin with a letter), for example `SR830.m` or `HP34401A.m` which contain the objects SR830 and HP34401A that operate the Stanford Research Systems SR830 lock-in amplifier and the HP/Agilent/Keysight 34401A digital multimeter respectively.


## Example

A short example of a driver is below, this implements setting the AC excitation amplitude for an SR830 lock-in amplifier.

	classdef SR830 < voltagesource
	
	    methods

        
        	function obj = SR830(instr)
        		obj.instr = instr;
       	 end
        
        
        
        	function setexcitation(this, excitation)

        		fprintf(this.instr, 'SLVL %f', excitation);

        	end
        
        
        
        	function output = getexcitation(this)

        		fprintf(this.instr, 'SLVL?');
          	output = fscanf(this.instr, '%f');

        	end
		end
	end
	
	
There are several important parts here, first is the object class definition  

	classdef SR830 < voltagesource

This tells matlab that we want to create a new class called SR830 (the model of the device) and that it should inherit the `voltagesource` class which allows SR830 to access all functions held in the `voltagesource` class, these are higher-level functions such as voltage sweep. The filename must be the same as the class name.  

Next is the `methods` declaration which simply tells matlab we will define our functions here.

After `methods` our functions can be written, the first of which *must always* be the creation method, which is automatically called every time an object of this class is created (i.e. when the instrument is connected to and opened).

	function obj = SR830(instr)
    	obj.instr = instr;
	end
The creation method must be a function with the same name as the class (SR830) and should return an object. Other commands that you want run during the instrument connection can be placed here, for example a command to record the current settings of the device or to set it up for measurement.  
In this code the creation object accepts the variable `instr` which is a matlab GPIB/VISA instrument object, the function must contain the line `obj.instr = instr;` which simply passes this GPIB/VISA object and makes it part of the SR830 object. 

After the creation method we can define our own functions, the first of these is `setexcitation` which will set the RMS voltage level of the device.

	function setexcitation(this, excitation)

    	fprintf(this.instr, 'SLVL %f', excitation);

    end
This particular function has no return variable since we are only setting the excitation level and not asking the device for anything, *ALL* functions in the driver files take at least one input, `this` which is the live SR830 object. A second input is given here `excitation` which is the desired voltage.

	fprintf(this.instr, 'SLVL %f', excitation);
This line prints the AC excitation command together with the desired voltage to the GPIB/VISA object which is located at `this.instr`. Matlab handles all lower-level code of actually communicating with the device.  


Finally we implement a function `getexcitation` that expects some output from the device.

	function output = getexcitation(this)

		fprintf(this.instr, 'SLVL?');
		output = fscanf(this.instr, '%f');
			
	end
Since the function needs no input we implement it only expecting the class handle passed on.

The first line of the function sends an SCPI command to the device `SLVL?` which a query asking the device about the current RMS voltage level of the AC excitation. In return the devices sends a string containing the current set voltage. Matlab handles the details of GPIB polling so simply scanning the GPIB object at `this.instr` will return the value. Since we know the value returned is a float then we assign directly in the `fscanf` command.
Output is assigned the value returned and since output is in the function definition then ourput is returned to the caller.



