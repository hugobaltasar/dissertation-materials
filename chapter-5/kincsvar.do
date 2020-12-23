
////////////////////////////////////////////////////////////////////////////////
///////////////////Longitudinal-IOP with EU-SILC - Estimations//////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir/Longitudinal-IOP-data"

global years 07 08 09 10 11 12 13 14 15 16 17
foreach year in $years {

    include "$codedir/countrieslist.do"

    foreach country in `countries' {
        use "eusilc20`year'_`country'", clear

        gen country_short = country
        replace country_short = "GR" if country_short == "EL"
        replace country = "`country'"

        qui tab hregion // Germany, the Netherlands, Portugal and Slovenia 2011 have no info on NUTS regions
        if r(N) == 0 {
            replace hregion = 0
        }

        *************************************Gender*************************************

        drop if psex == .
        recode psex (1=0) (2=1)
        rename psex female

        ************************Household composition & couples*************************

        if country == "Malta" & `year' >= 15 | country == "Portugal" & `year' == 08 {
            replace pageend = year - pbirthyear
        }
        // need to run this now to use it when creating dummy for children

        gen couple = ppartner != .

        egen nadults = total(pageend > 17), by(year hid)
        gen children = (hsize - nadults) > 0

        **************************************Age***************************************

        drop if pageend < 30 | pageend > 59

        ***********************************Education************************************

        if `year' < 14 {
            gen edulevel = 1 if pedulevel >= 0 & pedulevel <= 2
            replace edulevel = 2 if pedulevel == 3 | pedulevel == 4
            replace edulevel = 3 if pedulevel == 5 | pedulevel == 6
        }
        else {
            gen edulevel = 1 if pedulevel >= 0 & pedulevel <= 200
            replace edulevel = 2 if pedulevel >= 300 & pedulevel <= 450
            replace edulevel = 3 if pedulevel >= 500 & pedulevel <= 800
        }
        drop if edulevel == .

        ***********************************Occupation***********************************

        if country == "Malta" & year >= 2008 | country == "Slovenia" & year >= 2014 | ///
            country == "Germany" & year >= 2015 { // have different coding in 'poccup'
                gen occulevel = 3 if poccup >= 1 & poccup < 4
                replace occulevel = 2 if poccup >= 4 & poccup < 9
                replace occulevel = 1 if poccup >= 9 & poccup < .
        }
        else {
            gen occulevel = 3 if poccup >= 10 & poccup < 40
            replace occulevel = 2 if poccup >= 40 & poccup < 90
            replace occulevel = 1 if poccup >= 90 & poccup < .
        }

        **************************Full panel cycle individuals**************************

        bys pid: gen periods = _n
        bys pid: egen periodsmax = max(periods)
        drop if periodsmax != 4

        ************************************Incomes*************************************

        *Household pc gross capital income*
        if country == "France" | country == "Greece" | country == "Italy" | ///
           country == "Latvia" | country == "Portugal" | country == "Spain" {
               gen pckinc = (hyproprentaln + hykrentn) / nadults
        }
        else {
            gen pckinc = (hyproprentalg + hykrentg) / nadults
        }
        drop if pckinc >= .

        *Dynastic measure of capital income*
        if (country == "Estonia" & `year' == 08) | (country == "Estonia" & `year' == 12) | ///
            (country == "Iceland") | (country == "Ireland") | ///
            (country == "Luxembourg" & `year' <= 11) | (country == "Malta" & `year' <= 12) | ///
        	(country == "Romania" & `year' <= 11) | (country == "Slovenia" & `year' == 16) {
        		qui reg pckinc pageend c.pageend#c.pageend i.edulevel i.couple [w=pbw]
        		// occulevel not included due to limited amount of observations
        }
        else {
        	qui reg pckinc pageend c.pageend#c.pageend i.edulevel i.occulevel i.couple [w=pbw]
        }
        predict pcdynkinc, residuals
        drop if pcdynkinc >= .

        *Creating cutoffs in the capital income distribution*
        *of the pckinc distribution*
        _pctile pckinc, p(${cutoff1_`country'kinc})
        local pckinccut1 = r(r1)
        _pctile pckinc, p(${cutoff2_`country'kinc})
        local pckinccut2 = r(r1)
        _pctile pckinc, p(${cutoff3_`country'kinc})
        local pckinccut3 = r(r1)
        *of the pcdynkinc distribution*
        _pctile pcdynkinc, p(${cutoff1_`country'dynkinc})
        local pcdynkinccut1 = r(r1)
        _pctile pcdynkinc, p(${cutoff2_`country'dynkinc})
        local pcdynkinccut2 = r(r1)
        _pctile pcdynkinc, p(${cutoff3_`country'dynkinc})
        local pcdynkinccut3 = r(r1)

        *Generating levels of pc gross capital income of households*
        gen kinc = pckinc < `pckinccut1'
        replace kinc = 2 if pckinc >= `pckinccut1' & pckinc < `pckinccut2'
        replace kinc = 3 if pckinc >= `pckinccut2' & pckinc < `pckinccut3'
        replace kinc = 4 if pckinc >= `pckinccut3' & pckinc < .
        *Generating levels of pc dynastic gross capital income of households*
        gen dynkinc = pcdynkinc < `pcdynkinccut1'
        replace dynkinc = 2 if pcdynkinc >= `pcdynkinccut1' & pcdynkinc < `pcdynkinccut2'
        replace dynkinc = 3 if pcdynkinc >= `pcdynkinccut2' & pcdynkinc < `pcdynkinccut3'
        replace dynkinc = 4 if pcdynkinc >= `pcdynkinccut3' & pcdynkinc < .

        by pid: egen highdynkinc = max(dynkinc)
        by pid: egen lowdynkinc = min(dynkinc)
        gen diffdynkinc = highdynkinc - lowdynkinc

        by pid: egen highkinc = max(kinc)
        by pid: egen lowkinc = min(kinc)
        gen diffkinc = highkinc - lowkinc

        keep if year == 20`year'

        keep year country pid hid kinc dynkinc diffdynkinc diffkinc

        tempfile `country'`year'
        save ``country'`year''

    }
}

clear
foreach year in $years {
    include "$codedir/countrieslist.do"
    foreach country in `countries' {
        append using ``country'`year''
    }
}

compress
save Longitudinal-IOP_kincvar, replace

capture mkdir ../Longitudinal-IOP-output/
cd ../Longitudinal-IOP-output/

tab diffdynkinc, matcell(freq)
foreach num of numlist 1(1)4 {
	preserve
	local dyn`num'a : display %9.0f freq[`num',1]
	local dyn`num'b : display %4.2f (freq[`num',1]/r(N)) * 100
	local dynN : display %9.0f r(N)
	restore
}

tab diffkinc, matcell(freq)
foreach num of numlist 1(1)4 {
	preserve
	local kinc`num'a : display %9.0f freq[`num',1]
	local kinc`num'b : display %5.2f (freq[`num',1]/r(N)) * 100
	local kincN : display %9.0f r(N)
	restore
}

matrix kincsvar = (`dyn1a',`dyn1b',`dyn1b',`kinc1a',`kinc1b',`kinc1b' \ ///
	`dyn2a',`dyn2b',`dyn1b'+`dyn2b',`kinc2a',`kinc2b',`kinc1b'+`kinc2b' \ ///
	`dyn3a',`dyn3b',`dyn1b'+`dyn2b'+`dyn3b',`kinc3a',`kinc3b',`kinc1b'+`kinc2b'+`kinc3b' \ ///
	`dyn4a',`dyn4b',`dyn1b'+`dyn2b'+`dyn3b'+`dyn4b',`kinc4a',`kinc4b',`kinc1b'+`kinc2b'+`kinc3b'+`kinc4b' \ ///
	 `dynN',100.00,.,`kincN',100.00,.)

mat rownames kincsvar = "Constant" "One level change" "Two levels change" ///
	"Three levels change" "\addl \textit{Total}"

esttab matrix(kincsvar) using long_kincsvar.tex, replace ///
	nomtitles booktabs collabels(none) nolines f
