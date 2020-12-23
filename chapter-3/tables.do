
////////////////////////////////////////////////////////////////////////////////
///////////////////////////InAgg with EU-SILC - Tables//////////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir"
capture mkdir ./InAgg-output/
cd ./InAgg-output/

*heckman correction example*
use "$maindir/InAgg-data/InAgg", clear

eststo clear
heckman lnwage c.pageend c.pageend#c.pageend i.edulevel i.occulevel, ///
	twostep ///
	select(intoemplmnt = i.female i.couple i.female#i.couple ///
		i.children i.female#i.children i.immigrant) ///
	mills(imrml)
estadd scalar Ncens e(N_cens)
mat b = e(b)
local names: colfullnames b
local names: subinstr local names "mills:lambda" "lnwage:lambda"
mat colnames b = `names'
erepost b = b, rename
est sto ml

la var pageend "Age"
la def edulevel 2 "\ \ Secondary" 3 "\ \ Tertiary or more"
la val edulevel edulevel
la def occulevel 2 "\ \ Skilled worker" 3 "\ \ Professional"
la val occulevel occulevel
la def female 1 "Female"
la val female female
la def couple 1 "Couple"
la val couple couple
la def children 1 "Children"
la val children children
la def immigrant 1 "Immigrant status"
la val immigrant immigrant

esttab ml using InAgg_selection.tex, replace ///
	cells(b(star fmt(4)) se(par)) ///
	stat(N Ncens, fmt(%12.0fc) labels("Observations" "Censored values")) ///
	starlevels(* 0.01) collabels(none) eqlabels(none) interaction(" $\times$ ") ///
	refcat(2.edulevel "\textit{Personal education}" ///
		2.occulevel "\textit{Personal occupation}", nolabel) ///
	varlabels("lambda" "IMR" "_cons" "Constant") ///
	unstack label nobaselevels nonumber nomtitles fragment ///
	nolines prefoot(\midrule)

qui reg imrml c.pageend c.pageend#c.pageend i.edulevel i.occulevel
local r2 : display %5.4f `e(r2)'
di "R2 is `r2'"

*summary statistics*
local countries Austria Belgium Bulgaria Croatia Cyprus ///
    CzechRepublic Denmark Estonia Finland France Germany ///
    Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
    Luxembourg Malta Netherlands Norway Poland Portugal ///
    Romania Slovakia Slovenia Spain Sweden Switzerland ///
    UnitedKingdom // 31 countries

foreach aggregate in $aggregates {

    preserve
    keep if aggregate == "`aggregate'"

    gen `aggregate'_fg1N = .
    gen `aggregate'_mean = .
    gen `aggregate'_sd = .
    gen `aggregate'_femshare = .
    gen `aggregate'_immshare = .
    gen `aggregate'_edupa1share = .
    gen `aggregate'_edupa2share = .
    gen `aggregate'_edupa3share = .
    gen `aggregate'_occupa1share = .
    gen `aggregate'_occupa2share = .
    gen `aggregate'_occupa3share = .

    foreach country in `countries' {
        qui sum fg1N if country == "`country'", meanonly
        replace `aggregate'_fg1N = r(mean) if country == "`country'"

        if "`aggregate'" == "wage_e" | "`aggregate'" == "wage_se" {
            qui sum wage if country == "`country'" [w=pcsw]
        }
        else {
            qui sum pcdhi if country == "`country'" [w=hw]
        }
    	replace `aggregate'_mean = r(mean) if country == "`country'"
    	replace `aggregate'_sd = r(sd) if country == "`country'"

    	qui tab female if country == "`country'", matcell(freq)
    	local N = r(N)
    	replace `aggregate'_femshare = (freq[2,1]/`N') * 100 if country == "`country'"

    	qui tab immigrant if country == "`country'", matcell(freq)
    	local N = r(N)
    	replace `aggregate'_immshare = (freq[2,1]/`N') * 100 if country == "`country'"

    	qui tab eduparents if country == "`country'", matcell(freq)
    	local N = r(N)
    	replace `aggregate'_edupa1share = (freq[1,1]/`N') * 100 if country == "`country'"
    	replace `aggregate'_edupa2share = (freq[2,1]/`N') * 100 if country == "`country'"
    	replace `aggregate'_edupa3share = (freq[3,1]/`N') * 100 if country == "`country'"

    	qui tab occuparents if country == "`country'", matcell(freq)
    	local N = r(N)
    	if "`country'" == "Sweden" {
    		replace `aggregate'_occupa1share = 0  if country == "`country'"
    		replace `aggregate'_occupa2share = 0  if country == "`country'"
    		replace `aggregate'_occupa3share = 0  if country == "`country'"
    	}
    	else {
    		replace `aggregate'_occupa1share = (freq[1,1]/`N') * 100 if country == "`country'"
    		replace `aggregate'_occupa2share = (freq[2,1]/`N') * 100 if country == "`country'"
    		replace `aggregate'_occupa3share = (freq[3,1]/`N') * 100 if country == "`country'"
    	}
    }

    collapse (firstnm) `aggregate'*, by(country country_short) fast

    la var `aggregate'_fg1N "\addl \ \textit{Sample size}"
    la var `aggregate'_mean "\ \ \ Average"
    la var `aggregate'_sd "\ \ \ Standard deviation"
    la var `aggregate'_femshare "\ \ \ Female"
    la var `aggregate'_immshare "\ \ \ Immigrant status"
    la var `aggregate'_edupa1share "\ \ \ Primary or less"
    la var `aggregate'_edupa2share "\ \ \ Secondary"
    la var `aggregate'_edupa3share "\ \ \ Tertiary or more"
    la var `aggregate'_occupa1share "\ \ \ Elementary"
    la var `aggregate'_occupa2share "\ \ \ Skilled workers"
    la var `aggregate'_occupa3share "\ \ \ Professionals"

    tempfile InAgg_`aggregate'
    save `InAgg_`aggregate''
    restore
}

use `InAgg_head', clear
append using `InAgg_wage_e'
append using `InAgg_wage_se'
append using `InAgg_pcdhi'

encode country_short, g(countryid)
preserve
keep if countryid < 11

eststo clear
bys country_short: eststo: quietly estpost summarize ///
    pcdhi_fg1N pcdhi_mean pcdhi_sd pcdhi_femshare pcdhi_immshare pcdhi_edupa1share pcdhi_edupa2share ///
    pcdhi_edupa3share pcdhi_occupa1share pcdhi_occupa2share pcdhi_occupa3share ///
    head_fg1N head_mean head_sd head_femshare head_immshare head_edupa1share head_edupa2share ///
    head_edupa3share head_occupa1share head_occupa2share head_occupa3share
esttab using InAgg_summA_pcdhi.tex, replace cells(mean(fmt(%9.0fc %9.2fc %9.2fc %9.2fc %9.2fc %9.2fc ///
	%9.2fc %9.2fc %9.2fc %9.2fc %9.2fc %9.0fc %9.2fc))) f label nodepvar noobs ///
    collabels(none) nonumber refcat(head_fg1N "\rule{0pt}{4ex}{\normalsize$ y^{HE}$}" head_mean "\ \textit{Outcome}" ///
    head_femshare "\ \textit{Demography}" head_edupa1share "\ \textit{Parental education}" ///
    head_occupa1share "\ \textit{Parental occupation}" pcdhi_fg1N "\rule{0pt}{4ex}{\normalsize$ y^{H}$}" ///
    pcdhi_mean "\ \textit{Outcome}" pcdhi_femshare  "\ \textit{Demography}" pcdhi_edupa1share ///
    "\ \textit{Parental education}" pcdhi_occupa1share "\ \textit{Parental occupation}", nolabel)

eststo clear
bys country_short: eststo: quietly estpost summarize ///
    wage_e_fg1N wage_e_mean wage_e_sd wage_e_femshare wage_e_immshare wage_e_edupa1share wage_e_edupa2share ///
    wage_e_edupa3share wage_e_occupa1share wage_e_occupa2share wage_e_occupa3share ///
    wage_se_fg1N wage_se_mean wage_se_sd wage_se_femshare wage_se_immshare wage_se_edupa1share wage_se_edupa2share ///
    wage_se_edupa3share wage_se_occupa1share wage_se_occupa2share wage_se_occupa3share
esttab using InAgg_summA_wage.tex, replace cells(mean(fmt(%9.0fc %9.2fc %9.2fc %9.2fc %9.2fc %9.2fc ///
	%9.2fc %9.2fc %9.2fc %9.2fc %9.2fc %9.0fc %9.2fc))) f label nodepvar noobs ///
    collabels(none) nonumber refcat(wage_e_fg1N "\rule{0pt}{4ex}{\normalsize$ y^{W}$}" wage_e_mean "\ \textit{Outcome}" ///
    wage_e_femshare  "\ \textit{Demography}" wage_e_edupa1share "\ \textit{Parental education}" ///
    wage_e_occupa1share "\ \textit{Parental occupation}" wage_se_fg1N "\rule{0pt}{4ex}{\normalsize$ y^{SW}$}" ///
    wage_se_mean "\ \textit{Outcome}" wage_se_femshare  "\ \textit{Demography}" wage_se_edupa1share ///
    "\ \textit{Parental education}" wage_se_occupa1share "\ \textit{Parental occupation}", nolabel)
restore

preserve
keep if countryid >= 11 & countryid < 21

eststo clear
bys country_short: eststo: quietly estpost summarize ///
    pcdhi_fg1N pcdhi_mean pcdhi_sd pcdhi_femshare pcdhi_immshare pcdhi_edupa1share pcdhi_edupa2share ///
    pcdhi_edupa3share pcdhi_occupa1share pcdhi_occupa2share pcdhi_occupa3share ///
    head_fg1N head_mean head_sd head_femshare head_immshare head_edupa1share head_edupa2share ///
    head_edupa3share head_occupa1share head_occupa2share head_occupa3share
esttab using InAgg_summB_pcdhi.tex, replace cells(mean(fmt(%9.0fc %9.2fc %9.2fc %9.2fc %9.2fc %9.2fc ///
	%9.2fc %9.2fc %9.2fc %9.2fc %9.2fc %9.0fc %9.2fc))) f label nodepvar noobs ///
    collabels(none) nonumber refcat(head_fg1N "\rule{0pt}{4ex}{\normalsize$ y^{HE}$}" head_mean "\ \textit{Outcome}" ///
    head_femshare "\ \textit{Demography}" head_edupa1share "\ \textit{Parental education}" ///
    head_occupa1share "\ \textit{Parental occupation}" pcdhi_fg1N "\rule{0pt}{4ex}{\normalsize$ y^{H}$}" ///
    pcdhi_mean "\ \textit{Outcome}" pcdhi_femshare  "\ \textit{Demography}" pcdhi_edupa1share ///
    "\ \textit{Parental education}" pcdhi_occupa1share "\ \textit{Parental occupation}", nolabel)

eststo clear
bys country_short: eststo: quietly estpost summarize ///
    wage_e_fg1N wage_e_mean wage_e_sd wage_e_femshare wage_e_immshare wage_e_edupa1share wage_e_edupa2share ///
    wage_e_edupa3share wage_e_occupa1share wage_e_occupa2share wage_e_occupa3share ///
    wage_se_fg1N wage_se_mean wage_se_sd wage_se_femshare wage_se_immshare wage_se_edupa1share wage_se_edupa2share ///
    wage_se_edupa3share wage_se_occupa1share wage_se_occupa2share wage_se_occupa3share
esttab using InAgg_summB_wage.tex, replace cells(mean(fmt(%9.0fc %9.2fc %9.2fc %9.2fc %9.2fc %9.2fc ///
	%9.2fc %9.2fc %9.2fc %9.2fc %9.2fc %9.0fc %9.2fc))) f label nodepvar noobs ///
    collabels(none) nonumber refcat(wage_e_fg1N "\rule{0pt}{4ex}{\normalsize$ y^{W}$}" wage_e_mean "\ \textit{Outcome}" ///
    wage_e_femshare  "\ \textit{Demography}" wage_e_edupa1share "\ \textit{Parental education}" ///
    wage_e_occupa1share "\ \textit{Parental occupation}" wage_se_fg1N "\rule{0pt}{4ex}{\normalsize$ y^{SW}$}" ///
    wage_se_mean "\ \textit{Outcome}" wage_se_femshare  "\ \textit{Demography}" wage_se_edupa1share ///
    "\ \textit{Parental education}" wage_se_occupa1share "\ \textit{Parental occupation}", nolabel)
restore

preserve
keep if countryid >= 21

eststo clear
bys country_short: eststo: quietly estpost summarize ///
    pcdhi_fg1N pcdhi_mean pcdhi_sd pcdhi_femshare pcdhi_immshare pcdhi_edupa1share pcdhi_edupa2share ///
    pcdhi_edupa3share pcdhi_occupa1share pcdhi_occupa2share pcdhi_occupa3share ///
    head_fg1N head_mean head_sd head_femshare head_immshare head_edupa1share head_edupa2share ///
    head_edupa3share head_occupa1share head_occupa2share head_occupa3share
esttab using InAgg_summC_pcdhi.tex, replace cells(mean(fmt(%9.0fc %9.2fc %9.2fc %9.2fc %9.2fc %9.2fc ///
	%9.2fc %9.2fc %9.2fc %9.2fc %9.2fc %9.0fc %9.2fc))) f label nodepvar noobs ///
    collabels(none) nonumber refcat(head_fg1N "\rule{0pt}{4ex}{\normalsize$ y^{HE}$}" head_mean "\ \textit{Outcome}" ///
    head_femshare "\ \textit{Demography}" head_edupa1share "\ \textit{Parental education}" ///
    head_occupa1share "\ \textit{Parental occupation}" pcdhi_fg1N "\rule{0pt}{4ex}{\normalsize$ y^{H}$}" ///
    pcdhi_mean "\ \textit{Outcome}" pcdhi_femshare  "\ \textit{Demography}" pcdhi_edupa1share ///
    "\ \textit{Parental education}" pcdhi_occupa1share "\ \textit{Parental occupation}", nolabel)

eststo clear
bys country_short: eststo: quietly estpost summarize ///
    wage_e_fg1N wage_e_mean wage_e_sd wage_e_femshare wage_e_immshare wage_e_edupa1share wage_e_edupa2share ///
    wage_e_edupa3share wage_e_occupa1share wage_e_occupa2share wage_e_occupa3share ///
    wage_se_fg1N wage_se_mean wage_se_sd wage_se_femshare wage_se_immshare wage_se_edupa1share wage_se_edupa2share ///
    wage_se_edupa3share wage_se_occupa1share wage_se_occupa2share wage_se_occupa3share
esttab using InAgg_summC_wage.tex, replace cells(mean(fmt(%9.0fc %9.2fc %9.2fc %9.2fc %9.2fc %9.2fc ///
	%9.2fc %9.2fc %9.2fc %9.2fc %9.2fc %9.0fc %9.2fc))) f label nodepvar noobs ///
    collabels(none) nonumber refcat(wage_e_fg1N "\rule{0pt}{4ex}{\normalsize$ y^{W}$}" wage_e_mean "\ \textit{Outcome}" ///
    wage_e_femshare  "\ \textit{Demography}" wage_e_edupa1share "\ \textit{Parental education}" ///
    wage_e_occupa1share "\ \textit{Parental occupation}" wage_se_fg1N "\rule{0pt}{4ex}{\normalsize$ y^{SW}$}" ///
    wage_se_mean "\ \textit{Outcome}" wage_se_femshare  "\ \textit{Demography}" wage_se_edupa1share ///
    "\ \textit{Parental education}" wage_se_occupa1share "\ \textit{Parental occupation}", nolabel)
restore

*hsh heterogeneity*
use "$maindir/InAgg-data/InAgg", clear

collapse (firstnm) homocouples genderhomo originhomo eduparhomo occuparhomo ///
    hhomogeneity4 hhomogeneity3 hhomogeneity2, by(country) fast

capture rm InAgg_hetero.tex

foreach country in `countries' {

    capture matrix drop hetero_`country'

    sum homocouples if country == "`country'", meanonly
    local homocouples = r(mean)
    sum genderhomo if country == "`country'", meanonly
    local genderhomo = r(mean)
    sum originhomo if country == "`country'", meanonly
    local originhomo = r(mean)
    sum eduparhomo if country == "`country'", meanonly
    local eduparhomo = r(mean)
    sum occuparhomo if country == "`country'", meanonly
    local occuparhomo = r(mean)
    sum hhomogeneity4 if country == "`country'", meanonly
    local hhomogeneity4 = r(mean)
    sum hhomogeneity3 if country == "`country'", meanonly
    local hhomogeneity3 = r(mean)
    sum hhomogeneity2 if country == "`country'", meanonly
    local hhomogeneity2 = r(mean)

    matrix hetero_`country' = (`genderhomo',`originhomo',`eduparhomo',`occuparhomo', ///
        `hhomogeneity4',`hhomogeneity3',`hhomogeneity2')

    if "`country'" == "CzechRepublic" {
        matrix rownames hetero_`country' = "Czech R."
    }
    else if "`country'" == "UnitedKingdom" {
        matrix rownames hetero_`country' = "United K."
    }
    else {
        matrix rownames hetero_`country' = "`country'"
    }

    esttab matrix(hetero_`country', fmt(%4.2f)) using InAgg_hetero.tex, append ///
        nomtitles booktabs f collabels(none) nolines
}
drop if country == "Denmark" | country == "Finland" | country == "Iceland" | ///
   country == "Netherlands" | country == "Norway" | country == "Slovenia" | ///
   country == "Sweden" // in these countries only one member per hsh has parental info

sum genderhomo, meanonly
local genderhomo = r(mean)
sum originhomo, meanonly
local originhomo = r(mean)
sum eduparhomo, meanonly
local eduparhomo = r(mean)
sum occuparhomo, meanonly
local occuparhomo = r(mean)
sum hhomogeneity4, meanonly
local hhomogeneity4 = r(mean)
sum hhomogeneity3, meanonly
local hhomogeneity3 = r(mean)
sum hhomogeneity2, meanonly
local hhomogeneity2 = r(mean)

matrix hetero_av = (`genderhomo',`originhomo',`eduparhomo',`occuparhomo', ///
    `hhomogeneity4',`hhomogeneity3',`hhomogeneity2')

matrix rownames hetero_av = "\emph{Average}"

esttab matrix(hetero_av, fmt(%4.2f)) using InAgg_hetero.tex, append ///
	nomtitles booktabs f collabels(none) nolines

*mean shapleys*
use "$maindir/InAgg-data/InAgg", clear

preserve
drop if country == "Sweden" // has only three circumstances
collapse (firstnm) shapley*, by(country aggregate) fast

foreach num of numlist 1/4 {
	bys agg: egen mshapley`num' = mean(shapley`num')
}

egen totalmabs = rowtotal(m*)
gen relmshapley1 = mshapley1/totalmabs
gen relmshapley2 = mshapley2/totalmabs
gen relmshapley3 = mshapley3/totalmabs
gen relmshapley4 = mshapley4/totalmabs
egen totalmrel = rowtotal(r*)

local mshapleys mshapley1 mshapley2 mshapley3 mshapley4 totalmabs
local relmshapleys relmshapley1 relmshapley2 relmshapley3 relmshapley4 totalmrel

foreach aggregate in $aggregates {
    foreach mshapley in `mshapleys' {
        sum `mshapley' if aggregate == "`aggregate'", meanonly
        local `mshapley'_`aggregate' = r(mean)
    }
}
foreach aggregate in $aggregates {
    foreach relmshapley in `relmshapleys' {
        sum `relmshapley' if aggregate == "`aggregate'", meanonly
        local `relmshapley'_`aggregate' = r(mean) * 100
    }
}

matrix mshapleys = (`mshapley1_pcdhi',`mshapley1_head',`mshapley1_wage_e',`mshapley1_wage_se' \ ///
                   `mshapley2_pcdhi',`mshapley2_head',`mshapley2_wage_e',`mshapley2_wage_se' \ ///
                   `mshapley3_pcdhi',`mshapley3_head',`mshapley3_wage_e',`mshapley3_wage_se' \ ///
                   `mshapley4_pcdhi',`mshapley4_head',`mshapley4_wage_e',`mshapley4_wage_se' \ ///
                   `totalmabs_pcdhi',`totalmabs_head',`totalmabs_wage_e',`totalmabs_wage_se')
matrix relmshapleys = (`relmshapley1_pcdhi',`relmshapley1_head',`relmshapley1_wage_e',`relmshapley1_wage_se' \ ///
                      `relmshapley2_pcdhi',`relmshapley2_head',`relmshapley2_wage_e',`relmshapley2_wage_se' \ ///
                      `relmshapley3_pcdhi',`relmshapley3_head',`relmshapley3_wage_e',`relmshapley3_wage_se' \ ///
                      `relmshapley4_pcdhi',`relmshapley4_head',`relmshapley4_wage_e',`relmshapley4_wage_se' \ ///
                      `totalmrel_pcdhi',`totalmrel_head',`totalmrel_wage_e',`totalmrel_wage_se')

matrix rownames mshapleys = "Gender" "Immigrant status" "Parental education" ///
    "Parental occupation" "\emph{Total}"
matrix rownames relmshapleys = "\addl Gender (\%)" "Immigrant status (\%)" ///
    "Parental education (\%)" "Parental occupation (\%)" "\emph{Total}"

esttab matrix(mshapleys, fmt(%5.4f)) using InAgg_mshapleys.tex, replace ///
    nomtitles booktabs collabels(none) f nolines
esttab matrix(relmshapleys, fmt(%3.1f)) using InAgg_mshapleys.tex, append ///
    nomtitles booktabs collabels(none) f nolines
restore

*IOP*
collapse (firstnm) fg1*, by(country aggregate) fast

capture rm InAgg_iopabs.tex
capture rm InAgg_ioprel.tex

foreach country in `countries' {

    foreach aggregate in $aggregates {
        sum fg1a if country == "`country'" & aggregate == "`aggregate'", meanonly
        local fg1a_`aggregate' = r(mean)
        sum fg1aSE if country == "`country'" & aggregate == "`aggregate'", meanonly
        local fg1aSE_`aggregate' = r(mean)
        sum fg1r if country == "`country'" & aggregate == "`aggregate'", meanonly
        local fg1r_`aggregate' = r(mean)
    }

    matrix abs_`country'= (`fg1a_pcdhi',`fg1a_head',`fg1a_wage_e',`fg1a_wage_se')
    matrix absSE_`country'= (`fg1aSE_pcdhi',`fg1aSE_head',`fg1aSE_wage_e',`fg1aSE_wage_se')
    matrix rel_`country'= (`fg1r_pcdhi',`fg1r_head',`fg1r_wage_e',`fg1r_wage_se')

    if "`country'" == "CzechRepublic" {
        matrix rownames abs_`country' = "Czech R."
        matrix rownames rel_`country' = "Czech R."
    }
    else if "`country'" == "UnitedKingdom" {
        matrix rownames abs_`country' = "United K."
        matrix rownames rel_`country' = "United K."
    }
    else {
        matrix rownames abs_`country' = "`country'"
        matrix rownames rel_`country' = "`country'"
    }

    esttab matrix(abs_`country', fmt(%6.5f)) using InAgg_iopabs.tex, append ///
        nomtitles booktabs f collabels(none) nolines
    esttab matrix(absSE_`country', fmt(%6.5f)) using InAgg_iopabs.tex, append ///
        nomtitles booktabs f collabels(none) nolines
    esttab matrix(rel_`country', fmt(%6.5f)) using InAgg_ioprel.tex, append ///
        nomtitles booktabs f collabels(none) nolines
}
