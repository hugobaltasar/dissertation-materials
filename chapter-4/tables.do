
////////////////////////////////////////////////////////////////////////////////
///////////////////////////IOPK with EU-SILC - Tables///////////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir"
capture mkdir ./IOPK-output/
cd ./IOPK-output/

local countries Austria Belgium Bulgaria Croatia Cyprus ///
	CzechRepublic Denmark Estonia Finland France Germany ///
	Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
	Luxembourg Malta Netherlands Norway Poland Portugal ///
	Romania Slovakia Slovenia Spain Sweden Switzerland ///
	UnitedKingdom // 31 countries

foreach kvar in $kvars {
	use "$maindir/IOPK-data/IOPK_`kvar'", clear

	*tables of IOPK*
	capture rm iopk_levelsabs_`kvar'.tex
	capture rm iopk_levelsrel_`kvar'.tex

	foreach country in `countries' {

		capture matrix drop iopk_`country'
		capture matrix drop iopkse_`country'
		capture matrix drop ioprk_`country'

		local years 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016
		foreach year in `years' {
			sum eabt_k if country == "`country'" & year == `year', meanonly
			local iopk_`year' = r(mean)
			sum eabtSE_k if country == "`country'" & year == `year', meanonly
			local iopkse_`year' = r(mean)
		}

		local years 2004 2010
		foreach year in `years' {
			sum eabt_b if country == "`country'" & year == `year', meanonly
			local iop_`year' = r(mean)
			sum eabtSE_b if country == "`country'" & year == `year', meanonly
			local iopse_`year' = r(mean)
		}

		local years 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016
		foreach year in `years' {
			sum eabtR_k if country == "`country'" & year == `year', meanonly
			local ioprk_`year' = r(mean)
		}

		local years 2004 2010
		foreach year in `years' {
			sum eabtR_b if country == "`country'" & year == `year', meanonly
			local iopr_`year' = r(mean)
		}

		matrix iopk_`country' = (`iopk_2003',`iop_2004',`iopk_2004',`iopk_2005', ///
		                              `iopk_2006',`iopk_2007',`iopk_2008',`iopk_2009', ///
                                      `iop_2010',`iopk_2010',`iopk_2011',`iopk_2012', ///
                                      `iopk_2013',`iopk_2014',`iopk_2015',`iopk_2016')
		/*matrix iopkse_`country' = (`iopkse_2003',`iopse_2004',`iopkse_2004',`iopkse_2005', ///
		                                `iopkse_2006',`iopkse_2007',`iopkse_2008',`iopkse_2009', ///
                                        `iopse_2010',`iopkse_2010',`iopkse_2011',`iopkse_2012', ///
                                        `iopkse_2013',`iopkse_2014',`iopkse_2015',`iopkse_2016')*/
		matrix ioprk_`country' = (`ioprk_2003',`iopr_2004',`ioprk_2004',`ioprk_2005', ///
		                              `ioprk_2006',`ioprk_2007',`ioprk_2008',`ioprk_2009', ///
                                      `iopr_2010',`ioprk_2010',`ioprk_2011',`ioprk_2012', ///
                                      `ioprk_2013',`ioprk_2014',`ioprk_2015',`ioprk_2016')

		if "`country'" == "CzechRepublic" {
		  matrix rownames iopk_`country' = "Czech R."
		  matrix rownames ioprk_`country' = "Czech R."
		}
		else if "`country'" == "UnitedKingdom" {
		  matrix rownames iopk_`country' = "United K."
		  matrix rownames ioprk_`country' = "United K."
		}
		else {
		  matrix rownames iopk_`country' = "`country'"
		  matrix rownames ioprk_`country' = "`country'"
		}

		esttab matrix(iopk_`country', fmt(%5.4f)) using iopk_levelsabs_`kvar'.tex, append ///
			nomtitles booktabs collabels(none) nolines f
		/*esttab matrix(iopkse_`country', fmt(%4.4f)) using iopk_`kvar'.tex, par append ///
			nomtitles booktabs collabels(none) f*/
		esttab matrix(ioprk_`country', fmt(%5.4f)) using iopk_levelsrel_`kvar'.tex, append ///
			nomtitles booktabs collabels(none) nolines f
	}

	*IOPK compare*
	local years 2004 2010
	foreach year in `years' {
	    preserve
	    keep if year == `year'
	    sum eabt_b, meanonly
	    local `kvar'_meanb_`year' = r(mean)
	    sum eabt_k, meanonly
	    local `kvar'_meank_`year' = r(mean)
	    local `kvar'_meansratio_`year' = ``kvar'_meanb_`year''/``kvar'_meank_`year''
	    pwcorr eabt_b eabt_k, listwise
	    local `kvar'_corr_`year' = r(rho)
	    spearman eabt_b eabt_k
	    local `kvar'_rk_`year' = r(rho)
	    sum eabtSE_b, meanonly
	    local `kvar'_SEb_`year' = r(mean)
	    sum eabtSE_k, meanonly
	    local `kvar'_SEk_`year' = r(mean)
	    local `kvar'_SEratio_`year' = ``kvar'_SEb_`year''/``kvar'_SEk_`year''
	    restore
	}
}

matrix iopkcompare = (`dynkinc_meanb_2004',`dynkinc_meanb_2010',`kinc_meanb_2004',`kinc_meanb_2010' \ ///
					  `dynkinc_meank_2004',`dynkinc_meank_2010',`kinc_meank_2004',`kinc_meank_2010' \ ///
					  `dynkinc_meansratio_2004',`dynkinc_meansratio_2010',`kinc_meansratio_2004',`kinc_meansratio_2010' \ ///
					  `dynkinc_SEb_2004',`dynkinc_SEb_2010',`kinc_SEb_2004',`kinc_SEb_2010' \ ///
					  `dynkinc_SEk_2004',`dynkinc_SEk_2010',`kinc_SEk_2004',`kinc_SEk_2010' \ ///
					  `dynkinc_SEratio_2004',`dynkinc_SEratio_2010',`kinc_SEratio_2004',`kinc_SEratio_2010' \ ///
					  `dynkinc_corr_2004',`dynkinc_corr_2010',`kinc_corr_2004',`kinc_corr_2010' \ ///
					  `dynkinc_rk_2004',`dynkinc_rk_2010',`kinc_rk_2004',`kinc_rk_2010')

matrix rownames iopkcompare = "Average baseline IOP" "Average capital IOP" "Ratio of averages" ///
							  "\addl Average baseline SE" "Average capital SE" "Ratio of average SEs" ///
							  "\addl Pairwise correlation" "Rank correlation"

esttab matrix(iopkcompare, fmt(%6.5f)) using iopk_compare.tex, replace ///
	nomtitles booktabs collabels(none) f nolines
