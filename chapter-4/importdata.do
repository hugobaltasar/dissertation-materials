
////////////////////////////////////////////////////////////////////////////////
/////////////////////////IOPK with EU-SILC - Data import////////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir"
capture mkdir ./IOPK-data/
cd ./IOPK-data/

local countries Austria Belgium Bulgaria Switzerland ///
	Cyprus CzechRepublic Germany Denmark Estonia Greece ///
	Spain Finland France Croatia Hungary Ireland ///
	Iceland Italy Lithuania Luxembourg Latvia Malta ///
	Netherlands Norway Poland Portugal Romania Sweden ///
	Slovenia Slovakia UnitedKingdom // 31 countries
local countries_short ///
	AT BE BG CH CY CZ ///
	DE DK EE EL ES FI ///
	FR HR HU IE IS IT ///
	LT LU LV MT NL NO ///
	PL PT RO SE SI SK ///
	UK // 31 countries

local n : word count `countries'
forvalues i = 1/`n' {
	local country : word `i' of `countries'
	local country_short : word `i' of `countries_short'

	if "`country'" == "Austria" | "`country'" == "Belgium" | ///
	   "`country'" == "Denmark" | "`country'" == "Estonia" | ///
	   "`country'" == "Greece" | "`country'" == "Spain" | ///
	   "`country'" == "Finland" | "`country'" == "France" | ///
	   "`country'" == "Ireland" | "`country'" == "Italy" | ///
	   "`country'" == "Luxembourg" | "`country'" == "Norway" | ///
	   "`country'" == "Portugal" | "`country'" == "Sweden" {
    	local years 04 05 06 07 08 09 10 11 12 13 14 15 16 17
	}
	if "`country'" == "Iceland" {
		local years 04 05 06 07 08 09 10 11 12 13 14 15 16
	}
	if "`country'" == "Cyprus" | "`country'" == "CzechRepublic" | ///
		"`country'" == "Germany" | "`country'" == "Hungary" | ///
		"`country'" == "Latvia" | "`country'" == "Lithuania" | ///
		"`country'" == "Netherlands" | "`country'" == "Poland" | ///
		"`country'" == "Slovenia" | "`country'" == "Slovakia" | ///
		"`country'" == "UnitedKingdom" {
			local years 05 06 07 08 09 10 11 12 13 14 15 16 17
	}
	if "`country'" == "Bulgaria" |  "`country'" == "Malta" | ///
			"`country'" == "Romania" {
			local years 07 08 09 10 11 12 13 14 15 16 17
	}
	if "`country'" == "Switzerland" {
		local years 07 08 09 10 11 12 13 14 15 16
	}
	if "`country'" == "Croatia" {
		local years 10 11 12 13 14 15 16 17
	}

	foreach year in `years' {
		************************************D-file**************************************

		if "`country'" == "Greece" & `year' >= 04 & `year' <= 07 {
			import delimited "$datadir/`country_short'/20`year'/UDB_cGR`year'D.csv", clear
		}
		else {
			import delimited "$datadir/`country_short'/20`year'/UDB_c`country_short'`year'D.csv", clear
		}

		keep db010 db020 db030 db040 db100
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

		tempfile eusilc20`year'_`country'_d
		save `eusilc20`year'_`country'_d'

		************************************H-file**************************************

		if "`country'" == "Greece" & `year' >= 04 & `year' <= 07 {
			import delimited "$datadir/`country_short'/20`year'/UDB_cGR`year'H.csv", clear
		}
		else {
			import delimited "$datadir/`country_short'/20`year'/UDB_c`country_short'`year'H.csv", clear
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

		if "`country'" == "Greece" & `year' >= 04 & `year' <= 07 {
			import delimited "$datadir/`country_short'/20`year'/UDB_cGR`year'R.csv", clear
		}
		else {
			import delimited "$datadir/`country_short'/20`year'/UDB_c`country_short'`year'R.csv", clear
		}

		keep rb010 rb020 rb030 rb050 rb080 rb090 rb240 rx020 rx030
		ren rb010 year
		la var year "Year of the survey"
		ren rb020 country
		la var country "Country"
		ren rb030 pid
		la var pid "Personal ID"
		ren rb050 pcsw
		la var pcsw "Personal cross-sectional weight"
		ren rb080 pbirthyear
		la var pbirthyear "Year of birth"
		ren rb090 psex
		la var psex "Sex"
		ren rb240 ppartner
		la var ppartner "Spouse/partner ID"
		ren rx020 pageend
		la var pageend "Age at the end of the income reference period"
		ren rx030 hid
		la var hid "Household ID"

		tempfile eusilc20`year'_`country'_r
		save `eusilc20`year'_`country'_r'

		************************************P-file**************************************

		if "`country'" == "Greece" & `year' >= 04 & `year' <= 07 {
			import delimited "$datadir/`country_short'/20`year'/UDB_cGR`year'P.csv", clear
		}
		else if "`country'" == "Italy" & `year' == 10 {
			import delimited "$datadir/`country_short'/20`year'/UDB_c`country_short'`year'P_release_17-09.csv", clear
		}
		else {
			import delimited "$datadir/`country_short'/20`year'/UDB_c`country_short'`year'P.csv", clear
		}

		// in '09 vars pl070 and pl073 change
		// in '12 var pl050 changes to pl051

		if `year' == 05 {
			keep pb010 pb020 pb030 pb040 pb150 pb210 pl040 pl050 pl070 pl072 pe040 px030 ///
			     pm040 pm050 pm070 pm090 ///
			     py010g py010n py020g py020n py050g py050n
		}
		else if `year' == 04 | `year' >= 06 & `year' < 09 {
			keep pb010 pb020 pb030 pb040 pb150 pb210 pl040 pl050 pl070 pl072 pe040 px030 ///
			     py010g py010n py020g py020n py050g py050n
		}
		else if `year' >= 09 & `year' < 11 {
			keep pb010 pb020 pb030 pb040 pb150 pb210 pl040 pl050 pl073 pl074 pl075 pl076 pe040 px030 ///
			     py010g py010n py020g py020n py050g py050n
		}
		else if `year' == 11 {
			keep pb010 pb020 pb030 pb040 pb150 pb210 pl040 pl050 pl073 pl074 pl075 pl076 pe040 px030 ///
			     pt110 pt120 pt150 pt180 ///
			     py010g py010n py020g py020n py050g py050n
		}
		else if `year' >= 12 {
			keep pb010 pb020 pb030 pb040 pb150 pb210 pl040 pl051 pl073 pl074 pl075 pl076 pe040 px030 ///
			     py010g py010n py020g py020n py050g py050n
		}
		ren pb010 year
		la var year "Year of the survey"
		ren pb020 country
		la var country "Country"
		ren pb030 pid
		la var pid "Personal ID"
		ren pb040 pcsw
		la var pcsw "Personal cross-sectional weight"
		ren pb150 psex
		la var psex "Sex"
		ren pb210 pcountrybirth
		la var pcountrybirth "Country of birth"
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
		if `year' < 09 {
			ren pl070 pmthftjob
			la var pmthftjob "Number of months spent at full-time work"
			ren pl072 pmthptjob
			la var pmthptjob "Number of months spent at part-time work"
		}
		else {
			ren pl073 pmthftjobemp
			la var pmthftjobemp "Number of months spent at full-time work as employee"
			ren pl074 pmthptjobemp
			la var pmthptjobemp "Number of months spent at part-time work as employee"
			ren pl075 pmthftjobself
			la var pmthftjobself "Number of months spent at full-time work as self-employed (inc. family worker)"
			ren pl076 pmthptjobself
			la var pmthptjobself "Number of months spent at part-time work as self-employed (inc. family worker)"
		}
		ren pe040 pedulevel
		la var pedulevel "Highest ISCED level attained"
		ren px030 hid
		la var hid "Household ID"
		if `year' == 05 {
			ren pm040 pedufather
			la var pedufather "Highest level of education attained by father"
			ren pm050 pedumother
			la var pedumother "Highest level of education attained by mother"
			ren pm070 poccufather
			la var poccufather "Main occupation of father (ISCO-88(COM))"
			ren pm090 poccumother
			la var poccumother "Main occupation of mother (ISCO-88(COM))"
		}
		if `year' == 11 {
			ren pt110 pedufather
			la var pedufather "Highest level of education attained by father"
			ren pt120 pedumother
			la var pedumother "Highest level of education attained by mother"
			ren pt150 poccufather
			la var poccufather "Main occupation of the father ISCO-08(COM)"
			ren pt180 poccumother
			la var poccumother "Main occupation of the mother ISCO-08(COM)"
		}
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
		merge 1:1 country hid using `eusilc20`year'_`country'_d', nogen
		tempfile eusilc20`year'_`country'_dh
		save `eusilc20`year'_`country'_dh'

		use `eusilc20`year'_`country'_p', clear
		merge 1:1 country pid using `eusilc20`year'_`country'_r', nogen

		merge m:1 country hid using `eusilc20`year'_`country'_dh', nogen

		sort country year pid
		compress
		save eusilc20`year'_`country', replace
	}
}
