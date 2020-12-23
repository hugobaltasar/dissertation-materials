
////////////////////////////////////////////////////////////////////////////////
///////////////////////////////InAgg with EU-SILC///////////////////////////////
////////////////////////////////////////////////////////////////////////////////

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

*Income aggregates*
global aggregates pcdhi head wage_e wage_se

foreach dofile of newlist programs importdata estimations tables graphs ///
    robustness {
        cd "$codedir"
        do `dofile'
}
