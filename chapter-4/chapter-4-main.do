
////////////////////////////////////////////////////////////////////////////////
///////////////////////////////IOPK with EU-SILC////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


// WARNING: depending on the number of bootstrap replications and the capacity
// of your computer this do file might take several hours to complete


clear all
set more off
set rmsg on
set seed 1234
set matsize 1000

*Write here the path to the folder where you want the new files to be created*
global maindir ""

*Write here the path to the folder with the do files of this chapter*
global codedir ""

*Write here the path to the folder with the EU-SILC cross-sectional files*
global datadir ""

*Bootstrap repetitions*
global reps 1000

*Measures of capital income*
global kvars kinc dynkinc

foreach dofile of newlist programs importdata algorihthm estimations ///
	tables graphs robustness {
		cd "$codedir"
		do `dofile'
}
