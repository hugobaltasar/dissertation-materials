
////////////////////////////////////////////////////////////////////////////////
/////////////////////////Longitudinal-IOP with EU-SILC//////////////////////////
////////////////////////////////////////////////////////////////////////////////


// NOTICE: you must run this file after `chapter-4-main`, since it will make use
// of the files produced by the algorithm from chapter 4. Additionally, if 
// global macros have been cleared after running `chapter-4-main`, you will have
// to manually set the path to the files produced by the algorithm from 
// chapter 4 in the `algorithm` do file of this chapter


clear
set more off
set rmsg on
set seed 1234
set matsize 1000

*Write here the path to the folder where you want the new files to be created*
global maindir ""

*Write here the path to the folder with the do files of this chapter*
global codedir ""

*Write here the path to the folder with the EU-SILC longitudinal files*
global datadir ""

*Bootstrap repetitions*
global reps 1000

foreach dofile of newlist programs importdata algorithm kincsvar estimations ///
	tables graphs {
		cd "$codedir"
		do `dofile'
}
