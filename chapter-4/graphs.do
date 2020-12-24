
////////////////////////////////////////////////////////////////////////////////
///////////////////////////IOPK with EU-SILC - Graphs///////////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir/IOPK-output"

set scheme s1mono
colorpalette cblind, select(3/8) nograph
global c1 `r(p6)'
global c2 `r(p5)'
global c3 `r(p4)'
global c4 `r(p3)'
global c5 `r(p2)'
global c6 `r(p1)'

***********************************Scatters*************************************

foreach kvar in $kvars {
	use "$maindir/IOPK-data/IOPK_`kvar'", clear

    local upr .06
    local scale .65

    if "`kvar'" == "dynkinc" {
        local msg1 = "(a) Dynastic"
        local msg2 = "(b) Dynastic"
    }
    else {
        local msg1 = "(c) Dynastic + meritocratic"
        local msg2 = "(d) Dynastic + meritocratic"
    }

	preserve
	keep if year == 2004

	reg eabt_b eabt_k, vce(cluster country)
	matrix b = r(table)
	local beta : display %5.4f b[1,1]

	twoway (scatter eabt_b eabt_k, color(black) msymbol(d)) ///
	       (lfit eabt_b eabt_k, color("$c1") range(0 `upr')) ///
		   (function y=x, lpattern(dash) color("$c2") range(0 `upr')), ///
		   plotregion(margin(b=0)) scale(`scale') subtitle("`msg1', 2004") ///
		   note("Regression coefficient: `beta'", size(medsmall) ring(0) position(4) bmargin(medium)) ///
		   yti("Baseline circumstances") xti("Capital circumstances") legend(off) ///
		   yscale(r(0 `upr')) ylabel(0(.02)`upr') xscale(r(0 `upr')) xlabel(0(.02)`upr') ///
		   name(scatter_04_`kvar', replace) nodraw
	restore

	preserve
	keep if year == 2010

	reg eabt_b eabt_k, vce(cluster country)
	matrix b = r(table)
	local beta : display %5.4f b[1,1]

	twoway (scatter eabt_b eabt_k, color(black) msymbol(d)) ///
	       (lfit eabt_b eabt_k, color("$c1") range(0 `upr')) ///
		   (function y=x, lpattern(dash) color("$c2") range(0 `upr')), ///
		   plotregion(margin(b=0)) scale(`scale') subtitle("`msg2', 2010") ///
		   note("Regression coefficient: `beta'", size(medsmall) ring(0) position(4) bmargin(medium)) ///
		   yti("Baseline circumstances") xti("Capital circumstances") ///
		   legend(rows(2) order(3 "Perfect data adjusment" 2 "Actual data adjusment") size(vsmall) symxsize(*0.3)) ///
		   yscale(r(0 `upr')) ylabel(0(.02)`upr') xscale(r(0 `upr')) xlabel(0(.02)`upr') ///
		   name(scatter_10_`kvar', replace) nodraw
	restore

	if "`kvar'" == "dynkinc" {

		preserve
		keep if country == "Croatia"
		keep if year == 2009
		keep country country_short mld
		tempfile mld1
		save `mld1'
		restore

		preserve
		keep if country == "Bulgaria" | country == "Malta" | country == "Romania" | ///
		   country == "Switzerland"
		keep if year == 2006
		keep country country_short mld
		tempfile mld2
		save `mld2'
		restore

		preserve
		keep if country == "Cyprus" | country == "CzechRepublic" | country == "Germany" | ///
		   country == "Hungary" | country == "Latvia" | country == "Lithuania" | ///
		   country == "Netherlands" | country == "Poland" | country == "Slovakia" | ///
		   country == "Slovenia" | country == "UnitedKingdom"
		keep if year == 2004
		keep country country_short mld
		tempfile mld3
		save `mld3'
		restore

		preserve
		keep if year == 2003
		keep country country_short mld
		append using `mld1' `mld2' `mld3'
		tempfile mld
		save `mld'
		restore

		preserve
		keep if country == "Iceland" | country == "Switzerland"
		keep if year == 2015
		keep country country_short eabt_k eabtR_k
		tempfile eabt
		save `eabt'
		restore

		keep if year == 2016
		keep country country_short eabt_k eabtR_k
		append using `eabt'
		merge 1:1 country using `mld', nogen

		qui pwcorr eabt_k mld
		local cor : display %5.4f r(rho)
		local scale .7

		twoway (lfit eabt_k mld, color("$c1")) ///
			(scatter eabt_k mld, color(black) msymbol(d) mlabel(country_short)), ///
			legend(off) ///
			subtitle("(a) Income inequality and absolute IOP") ///
			plotregion(margin(b=0)) scale(`scale') ///
			note("Pairwise correlation: `cor'", size(medsmall) ring(0) position(4) bmargin(medium)) ///
			yti("Absolute IOP, 2016 (or last year available)") xti("Income inequality, 2003 (or first year available)") ///
			yscale(r(0 .06)) ylabel(0(.02).06) xscale(r(.1 .3)) xlabel(.1(.05).3) ///
			name(gatsby_abs_`kvar', replace) nodraw

		qui pwcorr eabtR_k mld
		local cor : display %5.4f r(rho)

		twoway (lfit eabtR_k mld, color("$c1")) ///
			(scatter eabtR_k mld, color(black) msymbol(d) mlabel(country_short)), ///
			legend(off) ///
			subtitle("(b) Income inequality and relative IOP") ///
			plotregion(margin(b=0)) scale(`scale') ///
			note("Pairwise correlation: `cor'", size(medsmall) ring(0) position(4) bmargin(medium)) ///
			yti("Relative IOP, 2016 (or last year available)") xti("Income inequality, 2003 (or first year available)") ///
			yscale(r(0 .3)) ylabel(0(.1).3) xscale(r(.1 .3)) xlabel(.1(.05).3) ///
			name(gatsby_rel_`kvar', replace) nodraw
	}
}

grc1leg2 scatter_04_dynkinc scatter_10_dynkinc ///
 		 scatter_04_kinc scatter_10_kinc, ///
	col(2) legendfrom(scatter_10_dynkinc) name(scatters, replace)
graph display scatters, ysize(20) xsize(18)
graph export iopk_scatters.png, replace width(3000)

graph combine gatsby_abs_dynkinc gatsby_rel_dynkinc, ///
	col(1) name(gatsby, replace)
graph display gatsby, ysize(20) xsize(15)
graph export iopk_gatsby_dynkinc.png, replace width(3000)

**********************************Evolution*************************************

use "$maindir/IOPK-data/IOPK_dynkinc", clear

local countrieshigh Austria Bulgaria Cyprus ///
 	Estonia Germany Iceland Ireland Latvia Luxembourg ///
	Malta Netherlands Norway Portugal Romania Switzerland ///
	UnitedKingdom
local countrieslow Belgium Croatia CzechRepublic Denmark Finland France ///
	Greece Hungary Italy Lithuania Poland Slovakia ///
	Slovenia Spain Sweden

local graphslist
local upr .07
local scale .8

foreach country in `countrieshigh' {
    preserve
    quietly keep if country == "`country'"
    twoway (rarea eabtUL_k eabtLL_k year, astyle(ci)) ///
        (rcap eabtUL_b eabtLL_b year, color("$c2")) ///
        (scatter eabt_b year, msymbol(p) color("$c2")) ///
        (line eabt_k year, color("$c1") lpattern(solid)), ///
        title(`country', color(black)) yti("") xti("") ///
        plotregion(m(b=0)) ylabel(0(.02)`upr', grid) yscale(r(0 `upr')) ///
        xlabel(2003(4)2016) ///
        scale(`scale') ///
        legend(off) name(g`country', replace) nodraw
    local graphslist "`graphslist' g`country'"
    restore
}
graph combine `graphslist', col(4) ysize(19) xsize(20)
graph export iopk_evoabs_dynkinc_high.png, replace width(5000)

local graphslist
local upr .035
foreach country in `countrieslow' {
    preserve
    quietly keep if country == "`country'"
    twoway (rarea eabtUL_k eabtLL_k year, astyle(ci)) ///
        (rcap eabtUL_b eabtLL_b year, color("$c2")) ///
        (scatter eabt_b year, msymbol(p) color("$c2")) ///
        (line eabt_k year, color("$c1") lpattern(solid)), ///
        title(`country', color(black)) yti("") xti("") ///
        plotregion(m(b=0)) ylabel(0(.01)`upr', grid) yscale(r(0 `upr')) ///
        xlabel(2003(4)2016) ///
        scale(`scale') ///
        legend(off) name(g`country', replace) nodraw
    local graphslist "`graphslist' g`country'"
    restore
}
graph combine `graphslist', col(4) ysize(19) xsize(20)
graph export iopk_evoabs_dynkinc_low.png, replace width(5000)

local graphslist
local upr .3
foreach country in `countrieshigh' {
    preserve
    quietly keep if country == "`country'"
    twoway (rarea eabtRUL_k eabtRLL_k year, astyle(ci)) ///
        (rcap eabtRUL_b eabtRLL_b year, color("$c2")) ///
        (scatter eabtR_b year, msymbol(p) color("$c2")) ///
        (line eabtR_k year, color("$c1") lpattern(solid)), ///
        title(`country', color(black)) yti("") xti("") ///
        plotregion(m(b=0)) ylabel(0(.1)`upr', grid) yscale(r(0 `upr')) ///
        xlabel(2003(4)2016) ///
        scale(`scale') ///
        legend(off) name(g`country', replace) nodraw
    local graphslist "`graphslist' g`country'"
    restore
}
graph combine `graphslist', col(4) ysize(19) xsize(20)
graph export iopk_evorel_dynkinc_high.png, replace width(5000)

local graphslist
local upr .2
foreach country in `countrieslow' {
    preserve
    quietly keep if country == "`country'"
    twoway (rarea eabtRUL_k eabtRLL_k year, astyle(ci)) ///
        (rcap eabtRUL_b eabtRLL_b year, color("$c2")) ///
        (scatter eabtR_b year, msymbol(p) color("$c2")) ///
        (line eabtR_k year, color("$c1") lpattern(solid)), ///
        title(`country', color(black)) yti("") xti("") ///
        plotregion(m(b=0)) ylabel(0(.1)`upr', grid) yscale(r(0 `upr')) ///
        xlabel(2003(4)2016) ///
        scale(`scale') ///
        legend(off) name(g`country', replace) nodraw
    local graphslist "`graphslist' g`country'"
    restore
}
graph combine `graphslist', col(4) ysize(19) xsize(20)
graph export iopk_evorel_dynkinc_low.png, replace width(5000)
