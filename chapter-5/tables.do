
////////////////////////////////////////////////////////////////////////////////
/////////////////////Longitudinal-IOP with EU-SILC - Tables/////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir/Longitudinal-IOP-output/"

local countries Austria Belgium Bulgaria Croatia Cyprus ///
	CzechRepublic Denmark Estonia Finland France ///
	Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
	Luxembourg Malta Netherlands Norway Poland Portugal ///
	Romania Slovakia Slovenia Spain Sweden Switzerland ///
	UnitedKingdom // 30 countries

use "$maindir/Longitudinal-IOP-data/Longitudinal-IOP_dynkinc", clear

capture rm long_levelsabs.tex
capture rm long_levelsrel.tex
capture rm long_samples.tex

foreach country in `countries' {

	*IOP*
	capture matrix drop long_`country'
	capture matrix drop longse_`country'
	capture matrix drop longr_`country'

	local years 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016
	foreach year in `years' {
		qui sum eabt if country == "`country'" & year == `year', meanonly
		local long_`year' = r(mean)
		/*qui sum eabtSE if country == "`country'" & year == `year', meanonly
		local longse_`year' = r(mean)*/
		qui sum eabtR if country == "`country'" & year == `year', meanonly
		local longr_`year' = r(mean)
	}

	matrix long_`country' = (`long_2006',`long_2007',`long_2008',`long_2009', ///
        `long_2010',`long_2011',`long_2012', ///
        `long_2013',`long_2014',`long_2015',`long_2016')
	/*matrix longse_`country' = (`longse_2006',`longse_2007',`longse_2008',`longse_2009', ///
        `longse_2010',`longse_2011',`longse_2012', ///
        `longse_2013',`longse_2014',`longse_2015',`longse_2016')*/
	matrix longr_`country' = (`longr_2006',`longr_2007',`longr_2008',`longr_2009', ///
        `longr_2010',`longr_2011',`longr_2012', ///
        `longr_2013',`longr_2014',`longr_2015',`longr_2016')

	if "`country'" == "CzechRepublic" {
	  matrix rownames long_`country' = "Czech R."
	  matrix rownames longr_`country' = "Czech R."
	}
	else if "`country'" == "UnitedKingdom" {
	  matrix rownames long_`country' = "United K."
	  matrix rownames longr_`country' = "United K."
	}
	else {
	  matrix rownames long_`country' = "`country'"
	  matrix rownames longr_`country' = "`country'"
	}

	esttab matrix(long_`country', fmt(%5.4f)) using long_levelsabs.tex, append ///
		nomtitles booktabs collabels(none) nolines f
	/*esttab matrix(longse_`country', fmt(%5.4f)) using long_levelsabs.tex, append ///
		nomtitles booktabs collabels(none) f nolines*/
	esttab matrix(longr_`country', fmt(%5.4f)) using long_levelsrel.tex, append ///
		nomtitles booktabs collabels(none) nolines f

	*sample sizes*
	capture matrix drop sample_`country'

	foreach year in `years' {
		qui sum eabtN if country == "`country'" & year == `year', meanonly
		local sample_`year' = r(mean)
	}

	matrix sample_`country' = (`sample_2006',`sample_2007',`sample_2008',`sample_2009', ///
	    `sample_2010',`sample_2011',`sample_2012', ///
	    `sample_2013',`sample_2014',`sample_2015',`sample_2016')

	if "`country'" == "CzechRepublic" {
	  matrix rownames sample_`country' = "Czech R."
	}
	else if "`country'" == "UnitedKingdom" {
	  matrix rownames sample_`country' = "United K."
	}
	else {
	  matrix rownames sample_`country' = "`country'"
	}

	esttab matrix(sample_`country', fmt(%9.0fc)) using long_samples.tex, append ///
		nomtitles booktabs collabels(none) nolines f
}
