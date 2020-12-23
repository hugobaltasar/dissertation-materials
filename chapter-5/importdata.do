
////////////////////////////////////////////////////////////////////////////////
///////////////////Longitudinal-IOP with EU-SILC - Data import//////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir"
capture mkdir ./Longitudinal-IOP-data/
cd ./Longitudinal-IOP-data/

local countries Austria Belgium Bulgaria Switzerland ///
	Cyprus CzechRepublic Denmark Estonia Greece ///
	Spain Finland France Croatia Hungary Ireland ///
	Iceland Italy Lithuania Luxembourg Latvia Malta ///
	Netherlands Norway Poland Portugal Romania Sweden ///
	Slovenia Slovakia UnitedKingdom // 30 countries
local countries_short ///
	AT BE BG CH CY CZ ///
	DK EE EL ES FI FR ///
	HR HU IE IS IT LT ///
	LU LV MT NL NO PL ///
	PT RO SE SI SK UK // 30 countries

local n : word count `countries'
forvalues i = 1/`n' {
	local country : word `i' of `countries'
	local country_short : word `i' of `countries_short'

	if "`country'" == "Ireland" {
		local years 07 08 09 12 13 14 15
	}
	else if "`country'" == "Iceland" {
		local years 07 08 09 10 11 12 13 14 15 16
	}
	else if "`country'" == "Slovakia" | "`country'" == "UnitedKingdom" {
		local years 08 09 10 11 12 13 14 15 16
	}
	else if "`country'" == "Bulgaria" | "`country'" == "Malta" {
		local years 09 10 11 12 13 14 15 16 17
	}
	else if "`country'" == "Romania" {
		local years 10 11 12 13 14 15 16 17
	}
	else if "`country'" == "Croatia" {
		local years 13 14 15 16 17
	}
	else if "`country'" == "Switzerland" {
		local years 14 15 16
	}
	else if "`country'" == "Cyprus" | "`country'" == "CzechRepublic" | ///
		"`country'" == "Hungary" | ///
		"`country'" == "Latvia" | "`country'" == "Lithuania" | ///
		"`country'" == "Netherlands" | "`country'" == "Poland" | ///
		"`country'" == "Slovenia" {
			local years 08 09 10 11 12 13 14 15 16 17
	}
	else {
		local years 07 08 09 10 11 12 13 14 15 16 17
	}

	foreach year in `years' {
		************************************D-file**************************************

		if "`country'" == "Greece" & `year' >= 05 & `year' <= 08 {
			import delimited "$datadir/`country_short'/20`year'/UDB_lGR`year'D.csv", clear
		}
		else {
			import delimited "$datadir/`country_short'/20`year'/UDB_l`country_short'`year'D.csv", clear
		}

		keep db010 db020 db030 db040 db100 db110
		ren db010 year
		la var year "Year of the survey"
		ren db020 country
		la var country "Country"
		ren db030 hid
		la var hid "Household ID"
		ren db040 hregion
		la var hregion "Region (NUTS 1 or 2)"
		ren db100 hurb
		la var hurb "Degree of urbanisation"
		ren db110 hlongstat
		la var hlongstat "Household status"

		tempfile eusilc20`year'_`country'_d
		save `eusilc20`year'_`country'_d'

		************************************H-file**************************************

		if "`country'" == "Greece" & `year' >= 05 & `year' <= 08 {
			import delimited "$datadir/`country_short'/20`year'/UDB_lGR`year'H.csv", clear
		}
		else {
			import delimited "$datadir/`country_short'/20`year'/UDB_l`country_short'`year'H.csv", clear
		}

		if `year' < 10 {
			keep hb010 hb020 hb030 hh020 hy040g hy040n hy090g hy090n hy100g hy100n hy120g hy120n hx040
		}
		else {
			keep hb010 hb020 hb030 hh021 hy040g hy040n hy090g hy090n hy100g hy100n hy120g hy120n hx040
		}
		ren hb010 year
		la var year "Year of the survey"
		ren hb020 country
		la var country "Country"
		ren hb030 hid
		la var hid "Household ID"
		if `year' < 10 {
			ren hh020 htenstat
			la var htenstat "Tenure status"
		}
		else {
			ren hh021 htenstat
			la var htenstat "Tenure status"
		}
		ren hy040g hyproprentalg
		la var hyproprentalg "Income from rental of a property or land (Gross)"
		ren hy040n hyproprentaln
		la var hyproprentaln "Income from rental of a property or land (Net)"
		ren hy090g hykrentg
		la var hykrentg "Interest, dividends, profit from capital investments (Gross)"
		ren hy090n hykrentn
		la var hykrentn "Interest, dividends, profit from capital investments (Net)"
		ren hy100g hyintrepmortg
		la var hyintrepmortg "Interest repayments on mortgage (Gross)"
		ren hy100n hyintrepmortn
		la var hyintrepmortn "Interest repayments on mortgage (Net)"
		ren hy120g hywealthtaxg
		la var hywealthtaxg "Regular taxes on wealth (Gross)"
		ren hy120n hywealthtaxn
		la var hywealthtaxn "Regular taxes on wealth (Net)"
		ren hx040 hsize
		la var hsize "Household size"

		tempfile eusilc20`year'_`country'_h
		save `eusilc20`year'_`country'_h'

		************************************R-file**************************************

		if "`country'" == "Greece" & `year' >= 05 & `year' <= 08 {
			import delimited "$datadir/`country_short'/20`year'/UDB_lGR`year'R.csv", clear
		}
		else {
			import delimited "$datadir/`country_short'/20`year'/UDB_l`country_short'`year'R.csv", clear
		}

		keep rb010 rb020 rb030 rb040 rb064 rb080 rx020 rb090 rb170 rb240
		ren rb010 year
		la var year "Year of the survey"
		ren rb020 country
		la var country "Country"
		ren rb030 pid
		la var pid "Personal ID"
		ren rb040 hid
		la var hid "Household ID"
		ren rb064 plw4
		la var plw4 "Longitudinal weight (four-year duration)"
		ren rb080 pbirthyear // Malta has missing values in 'pageend' from 2015 on
		la var pbirthyear "Year of birth"
		ren rx020 pageend
		la var pageend "Age at the end of the income reference period"
		ren rb090 psex
		la var psex "Sex"
		ren rb170 pmainact
		la var pmainact "Main activity status during the income reference period"
		ren rb240 ppartner
		la var ppartner "Spouse/partner ID"

		tempfile eusilc20`year'_`country'_r
		save `eusilc20`year'_`country'_r'

		************************************P-file**************************************

		if "`country'" == "Greece" & `year' >= 05 & `year' <= 08 {
			import delimited "$datadir/`country_short'/20`year'/UDB_lGR`year'P.csv", clear
		}
		else {
			import delimited "$datadir/`country_short'/20`year'/UDB_l`country_short'`year'P.csv", clear
		}

		// in '09 var pl030 changes to pl031
		// in '12 var pl050 changes to pl051

		if `year' >= 07 & `year' < 09 {
			keep pb010 pb020 pb030 pb050 pb150 pl030 pl040 pl050 pe040 px030 ///
			     py010g py010n py020g py020n py050g py050n
		}
		else if `year' >= 09 & `year' < 12 {
			keep pb010 pb020 pb030 pb050 pb150 pl031 pl040 pl050 pe040 px030 ///
			     py010g py010n py020g py020n py050g py050n
		}
		else if `year' >= 12 {
			keep pb010 pb020 pb030 pb050 pb150 pl031 pl040 pl051 pe040 px030 ///
			     py010g py010n py020g py020n py050g py050n
		}
		ren pb010 year
		la var year "Year of the survey"
		ren pb020 country
		la var country "Country"
		ren pb030 pid
		la var pid "Personal ID"
		ren pb050 pbw
		la var pbw "Personal base weight"
		ren pb150 psex
		la var psex "Sex"
		if `year' < 09 {
			ren pl030 pselfstatus
		}
		else {
			ren pl031 pselfstatus
		}
		la var pselfstatus "Self-defined current economic status"
		ren pl040 pemplystatus
		la var pemplystatus "Status in employment"
		if `year' < 12 {
			ren pl050 poccup
			la var poccup "Occupation (ISCO-88 (COM))"
		}
		else {
			ren pl051 poccup
			la var poccup "Occupation (ISCO-08 (COM))"
		}
		ren pe040 pedulevel
		la var pedulevel "Highest ISCED level attained"
		ren px030 hid
		la var hid "Household ID"
		ren py010g pyemplcashg
		la var pyemplcashg "Employee cash or near cash income (Gross)"
		ren py010n pyemplcashn
		la var pyemplcashn "Employee cash or near cash income (Net)"
		ren py020g pyemplncashg
		la var pyemplncashg "Non-Cash employee income (Gross)"
		ren py020n pyemplncashn
		la var pyemplncashn "Non-Cash employee income (Net)"
		ren py050g pyselfemplg
		la var pyselfemplg "Cash benefits or losses from self-employment (Gross)"
		ren py050n pyselfempln
		la var pyselfempln "Cash benefits or losses from self-employment (Net)"

		tempfile eusilc20`year'_`country'_p
		save `eusilc20`year'_`country'_p'

		***********************************Merging**************************************

		use `eusilc20`year'_`country'_h', clear
		merge m:m year hid using `eusilc20`year'_`country'_d', nogen keep(match)
		tempfile eusilc20`year'_`country'_dh
		save `eusilc20`year'_`country'_dh'

		use `eusilc20`year'_`country'_p', clear
		merge m:m year pid hid using `eusilc20`year'_`country'_r', nogen keep(match)

		merge m:m year hid using `eusilc20`year'_`country'_dh', nogen

		sort country year pid
		compress
		save eusilc20`year'_`country', replace
	}
}
