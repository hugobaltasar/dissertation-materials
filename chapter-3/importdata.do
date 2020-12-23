
////////////////////////////////////////////////////////////////////////////////
/////////////////////////InAgg with EU-SILC - Data import///////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir"
capture mkdir ./InAgg-data/
cd ./InAgg-data/

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

	************************************D-file**************************************

	import delimited "$datadir/`country_short'/2011/UDB_c`country_short'11D.csv", clear

	keep db010 db020 db030 db040 db090 db100
	ren db010 year
	la var year "Year of the survey"
	ren db020 country
	la var country "Country"
	ren db030 hid
	la var hid "Household ID"
	ren db040 hregion
	la var hregion "Region (NUTS 1 or 2)"
	ren db090 hw
	la var hw "Household cross-sectional weight"
	ren db100 hurb
	la var hurb "Degree of urbanisation"

	tempfile eusilc2011_`country'_d
	save `eusilc2011_`country'_d'

	************************************H-file**************************************

	import delimited "$datadir/`country_short'/2011/UDB_c`country_short'11H.csv", clear

	keep hb010 hb020 hb030 hb080 hb090 hx040 hx050 hx090 hy010 hy020 hy025 ///
		 hy030g hy040g hy050g hy060g hy070g hy080g hy090g hy100g hy110g hy120g hy130g hy140g ///
		 hy030n hy040n hy050n hy060n hy070n hy080n hy090n hy100n hy110n hy120n hy130n hy140n
	ren hb010 year
	la var year "Year of the survey"
	ren hb020 country
	la var country "Country"
	ren hb030 hid
	la var hid "Household ID"
	ren hb080 prespons1
	la var prespons1 "Person 1 responsible for the accommodation"
	ren hb090 prespons2
	la var prespons2 "Person 2 responsible for the accommodation"
	ren hy010 hytotalg
	la var hytotalg "Total gross household income"
	ren hy020 hytotaln
	la var hytotaln "Total disposable household income"
	ren hy025 hnonresponse
	la var hnonresponse "Within-household non-response inflation factor"
	ren hy030g hyimptg
	la var hyimptg "Imputed rent (Gross)"
	ren hy030n hyimptn
	la var hyimptn "Imputed rent (Net)"
	ren hy040g hyproprentalg
	la var hyproprentalg "Income from rental of a property or land (Gross)"
	ren hy040n hyproprentaln
	la var hyproprentaln "Income from rental of a property or land (Net)"
	ren hy050g hyfamallowsg
	la var hyfamallowsg "Family/Children related allowances (Gross)"
	ren hy050n hyfamallowsn
	la var hyfamallowsn "Family/Children related allowances (Net)"
	ren hy060g hysocexclug
	la var hysocexclug "Social exclusion not elsewhere classified (Gross)"
	ren hy060n hysocexclun
	la var hysocexclun "Social exclusion not elsewhere classified (Net)"
	ren hy070g hyhouseallowsg
	la var hyhouseallowsg "Housing allowances (Gross)"
	ren hy070n hyhouseallowsn
	la var hyhouseallowsn "Housing allowances (Net)"
	ren hy080g hyintrhshtransfreceg
	la var hyintrhshtransfreceg "Regular inter-household cash transfer received (Gross)"
	ren hy080n hyintrhshtransfrecen
	la var hyintrhshtransfrecen "Regular inter-household cash transfer received (Net)"
	ren hy090g hykrentg
	la var hykrentg "Interest, dividends, profit from capital investments (Gross)"
	ren hy090n hykrentn
	la var hykrentn "Interest, dividends, profit from capital investments (Net)"
	ren hy100g hyrepaymortgageg
	la var hyrepaymortgageg "Interest repayments on mortgage (Gross)"
	ren hy100n hyrepaymortgagen
	la var hyrepaymortgagen "Interest repayments on mortgage (Net)"
	ren hy110g hyincome16g
	la var hyincome16g "Income received by people aged under 16 (Gross)"
	ren hy110n hyincome16n
	la var hyincome16n "Income received by people aged under 16 (Net)"
	ren hy120g hytaxeswealthg
	la var hytaxeswealthg "Regular taxes on wealth (Gross)"
	ren hy120n hytaxeswealthn
	la var hytaxeswealthn "Regular taxes on wealth (Net)"
	ren hy130g hyinterhshtransfpaidg
	la var hyinterhshtransfpaidg "Regular inter-household cash transfer paid (Gross)"
	ren hy130n hyinterhshtransfpaidn
	la var hyinterhshtransfpaidn "Regular inter-household cash transfer paid (Net)"
	ren hy140g hytaxincomeg
	la var hytaxincomeg "Tax on income and social contributions (Gross)"
	ren hy140n hytaxincomen
	la var hytaxincomen "Tax on income and social contributions (Net)"
	ren hx040 hsize
	la var hsize "Household size"
	ren hx050 hesize
	la var hesize "Equivalised household size"
	ren hx090 hytotalen
	la var hytotalen "Equivalised disposable household income"

	tempfile eusilc2011_`country'_h
	save `eusilc2011_`country'_h'

	************************************R-file**************************************

	import delimited "$datadir/`country_short'/2011/UDB_c`country_short'11R.csv", clear

	keep rb010 rb020 rb030 rb050 rb090 rb240 rx020 rx030
	ren rb010 year
	la var year "Year of the survey"
	ren rb020 country
	la var country "Country"
	ren rb030 pid
	la var pid "Personal ID"
	ren rb050 pcsw
	la var pcsw "Personal cross-sectional weight"
	ren rb090 psex
	la var psex "Sex"
	ren rb240 pspouseid
	la var pspouseid "Spouse/partner ID"
	ren rx020 pageend
	la var pageend "Age at the end of the income reference period"
	ren rx030 hid
	la var hid "Household ID"

	tempfile eusilc2011_`country'_r
	save `eusilc2011_`country'_r'

	************************************P-file**************************************

	import delimited "$datadir/`country_short'/2011/UDB_c`country_short'11P.csv", clear

	keep pb010 pb020 pb030 pb040 pb150 pb200 pb210 pl040 pl050 pl073 pl074 pl075 pl076 pl120 pe040 px030 ///
		 pt005 pt010 pt060 pt070 pt090 pt100 pt110 pt120 pt150 pt180 pt190 pt200 ///
		 py010g py020g py021g py030g py031g py035g py050g py080g py090g py100g py110g py120g py130g py140g ///
		 py010n py020n py035n py050n py080n py090n py100n py110n py120n py130n py140n
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
	ren pb200 pconsunion
	la var pconsunion "Consensual Union"
	ren pb210 pcountrybirth
	la var pcountrybirth "Country of birth"
	ren pl040 pemplystatus
	la var pemplystatus "Status in employment"
	ren pl050 poccup
	la var poccup "Occupation (ISCO-88 (COM))"
	ren pl073 pmthftjobemp
	la var pmthftjobemp "Number of months spent at full-time work as employee"
	ren pl074 pmthptjobemp
	la var pmthptjobemp "Number of months spent at part-time work as employee"
	ren pl075 pmthftjobself
	la var pmthftjobself "Number of months spent at full-time work as self-employed (inc. family worker)"
	ren pl076 pmthptjobself
	la var pmthptjobself "Number of months spent at part-time work as self-employed (inc. family worker)"
	ren pl120 preasonpt
	la var preasonpt "Reason for working less than 30 hours"
	ren pe040 pedulevel
	la var pedulevel "Highest ISCED level attained"
	ren px030 hid
	la var hid "Household ID"
	ren pt005 picsw
	la var picsw "Personal intergenerational cross-sectional weight"
	ren pt010 pprespar
	la var pprespar "Presence of parents"
	ren pt060 pcntryfath
	la var pcntryfath "Country of birth of the father"
	ren pt070 pctzenfath
	la var pctzenfath "Citizenship of the father"
	ren pt090 pcntrymoth
	la var pcntrymoth "Country of birth of the mother"
	ren pt100 pctzenmoth
	la var pctzenmoth "Citizenship of the mother"
	ren pt110 pedufather
	la var pedufather "Highest level of education attained by father"
	ren pt120 pedumother
	la var pedumother "Highest level of education attained by mother"
	ren pt150 poccufather
	la var poccufather "Main occupation of the father ISCO-08(COM)"
	ren pt180 poccumother
	la var poccumother "Main occupation of the mother ISCO-08(COM)"
	ren pt190 pfinprobsteen
	la var pfinprobsteen "Financial problems in household when young teenager/situation of the household"
	ren pt200 pabilityteen
	la var pabilityteen "Ability to make ends meet"
	ren py010g pyemplcashg
	la var pyemplcashg "Employee cash or near cash income (Gross)"
	ren py020g pyemplncashg
	la var pyemplncashg "Non-Cash employee income (Gross)"
	ren py021g pycompanycarg
	la var pycompanycarg "Company car (Gross)"
	ren py030g pyemplysoccontrg
	la var pyemplysoccontrg "Employer's social insurance contribution (Gross)"
	ren py031g pyopemplysoccontrg
	la var pyopemplysoccontrg "Optional employer's social insurance contributions (Gross)"
	ren py035g py_privpensg
	la var py_privpensg "Contributions to individual private pension plans (Gross)"
	ren py050g pyselfemplg
	la var pyselfemplg "Cash benefits or losses from self-employment (Gross)"
	ren py080g pyindprivpensg
	la var pyindprivpensg "Pension from individual private plans (Gross)"
	ren py090g pyunmplbeng
	la var pyunmplbeng "Unemployment benefits (Gross)"
	ren py100g pyoldbeng
	la var pyoldbeng "Old-age benefits (Gross)"
	ren py110g pysurvbeng
	la var pysurvbeng "Survivor benefits (Gross)"
	ren py120g pysickbeng
	la var pysickbeng "Sickness benefits (Gross)"
	ren py130g pydisabbeng
	la var pydisabbeng "Disability benefits (Gross)"
	ren py140g pyeduallowg
	la var pyeduallowg "Education-related allowances (Gross)"
	ren py010n pyemplcashn
	la var pyemplcashn "Employee cash or near cash income (Net)"
	ren py020n pyemplncashn
	la var pyemplncashn "Non-Cash employee income (Net)"
	ren py035n py_privpensn
	la var py_privpensn "Contributions to individual private pension plans (Net)"
	ren py050n pyselfempln
	la var pyselfempln "Cash benefits or losses from self-employment (Net)"
	ren py080n pyindprivpensn
	la var pyindprivpensn "Pension from individual private plans (Net)"
	ren py090n pyunmplbenn
	la var pyunmplbenn "Unemployment benefits (Net)"
	ren py100n pyoldbenn
	la var pyoldbenn "Old-age benefits (Net)"
	ren py110n pysurvbenn
	la var pysurvbenn "Survivor benefits (Net)"
	ren py120n pysickbenn
	la var pysickbenn "Sickness benefits (Net)"
	ren py130n pydisabbenn
	la var pydisabbenn "Disability benefits (Net)"
	ren py140n pyeduallown
	la var pyeduallown "Education-related allowances (Net)"

	tempfile eusilc2011_`country'_p
	save `eusilc2011_`country'_p'

	***********************************Merging**************************************

	use `eusilc2011_`country'_h', clear
	merge 1:1 country hid using `eusilc2011_`country'_d', nogen
	tempfile eusilc2011_`country'_dh
	save `eusilc2011_`country'_dh'

	use `eusilc2011_`country'_p', clear
	merge 1:1 country pid using `eusilc2011_`country'_r', nogen

	merge m:1 country hid using `eusilc2011_`country'_dh', nogen

	sort country pid
	compress
	save eusilc2011_`country', replace
}
