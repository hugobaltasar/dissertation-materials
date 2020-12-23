
////////////////////////////////////////////////////////////////////////////////
///////////////////////////InAgg with EU-SILC - Graphs//////////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir/InAgg-output/"

use "$maindir/InAgg-data/InAgg", clear

replace country = "United K." if country == "UnitedKingdom"
replace country = "Czech R." if country == "CzechRepublic"

set scheme s1mono

colorpalette cblind, select(3/8) nograph
global c1 `r(p6)'
global c2 `r(p5)'
global c3 `r(p4)'
global c4 `r(p3)'
global c5 `r(p2)'
global c6 `r(p1)'

gen order = agg == "pcdhi"
replace order = 2 if agg == "head"
replace order = 3 if agg == "wage_e"
replace order = 4 if agg == "wage_se"

*********************************Shapleys***********************************

preserve
collapse (firstnm) shapley* order, by(country aggregate) fast

egen totalabs = rowtotal(shapley*)
gen relshapley1 = shapley1/totalabs
gen relshapley2 = shapley2/totalabs
gen relshapley3 = shapley3/totalabs
gen relshapley4 = shapley4/totalabs

gen cgroup = 1 if country == "Bulgaria" | country == "Croatia" | ///
				  country == "Czech R." | country == "Estonia" | ///
				  country == "Hungary"	| country == "Latvia" | ///
				  country == "Lithuania" | country == "Poland" | ///
				  country == "Romania" | country == "Slovakia" | ///
				  country == "Slovenia"
replace cgroup = 2 if country == "Denmark" | country == "Finland" | ///
					  country == "Iceland" | country == "Norway" | ///
					  country == "Sweden"
replace cgroup = 3 if country == "Cyprus" | country == "Greece" | ///
					  country == "Italy" | country == "Malta" | ///
					  country == "Portugal" | country == "Spain"
replace cgroup = 4 if country == "Austria" | country == "Belgium" | ///
					  country == "France" | country == "Germany" | ///
					  country == "Ireland" | country == "Luxembourg" | ///
					  country == "Netherlands" | country == "Switzerland" | ///
					  country == "United K."

la def cgroup 1 "Eastern" 2 "Nordic" 3 "Southern" 4 "Western"
la val cgroup cgroup

*By country*
foreach agg in $aggregates {
	if "`agg'" == "pcdhi" {
		local symbol "{it:y{sup:H}}"
		local letter1 "a"
		local letter2 "b"
		local upr .04
	}
	else if "`agg'" == "head" {
		local symbol "{it:y{sup:HE}}"
		local letter1 "c"
		local letter2 "d"
		local upr .04
	}
	else if "`agg'" == "wage_e" {
		local symbol "{it:y{sup:W}}"
		local letter1 "a"
		local letter2 "b"
		local upr .06
	}
	else {
		local symbol "{it:y{sup:SW}}"
		local letter1 "c"
		local letter2 "d"
		local upr .06
	}
	graph hbar shapley* if aggregate == "`agg'", ///
		over(country, ///
			label(labsize(small))) ///
		over(cgroup, ///
			label(angle(90) ///
			labsize(medsmall))) ///
		ylabel(0(.01)`upr', ///
			grid) ///
		yscale(r(0 `upr')) ///
		nofill ///
		stack ///
		scale(.6) ///
		subtitle("(`letter1') `symbol' - Absolute contribution") ///
		yti("IOP") ///
		plotregion(margin(small)) ///
		bar(1, color("$c1") lcolor(black) lwidth(vthin)) ///
		bar(2, color("$c2") lcolor(black) lwidth(vthin)) ///
		bar(3, color("$c3") lcolor(black) lwidth(vthin)) ///
		bar(4, color("$c4") lcolor(black) lwidth(vthin)) ///
		legend(rows(2) ///
			lab(1 "Gender") lab(2 "Immigrant status") ///
			lab(3 "Parental education") lab(4 "Parental occupation") ///
			size(*0.5) ///
			symxsize(*0.3)) ///
		name(shapleys_byc_abs_`agg', replace) ///
		nodraw
	graph hbar rel* if aggregate == "`agg'", ///
		over(country, ///
			label(labsize(small))) ///
		over(cgroup, ///
			relabel(1 " " 2 " " 3 " " 4 " ") ///
			label(angle(90) ///
			labsize(medsmall))) ///
		nofill ///
		percent ///
		stack ///
		scale(.6) ///
		subtitle("(`letter2') `symbol' - Relative contribution") ///
		ylabel(0(25)100) ///
		yti("% of total IOP") ///
		plotregion(margin(small)) ///
		bar(1, color("$c1") lcolor(black) lwidth(vthin)) ///
		bar(2, color("$c2") lcolor(black) lwidth(vthin)) ///
		bar(3, color("$c3") lcolor(black) lwidth(vthin)) ///
		bar(4, color("$c4") lcolor(black) lwidth(vthin)) ///
		name(shapleys_byc_rel_`agg', replace) ///
		nodraw
}

grc1leg2 shapleys_byc_abs_pcdhi shapleys_byc_rel_pcdhi ///
	shapleys_byc_abs_head shapleys_byc_rel_head, ///
	row(2) ///
	legendfrom(shapleys_byc_abs_pcdhi) ///
	name(shapleys_byc_pcdhi, replace)
graph display shapleys_byc_pcdhi, ysize(20) xsize(15)
graph export InAgg_shapleys_byc_pcdhi.png, replace width(3000)

grc1leg2 shapleys_byc_abs_wage_e shapleys_byc_rel_wage_e ///
	shapleys_byc_abs_wage_se shapleys_byc_rel_wage_se, ///
	row(2) ///
	legendfrom(shapleys_byc_abs_wage_e) ///
	name(shapleys_byc_wage, replace)
graph display shapleys_byc_wage, ysize(20) xsize(15)
graph export InAgg_shapleys_byc_wage.png, replace width(3000)

*Average across countries*
drop if country == "Sweden" // has only three circumstances

foreach num of numlist 1/4 {
	bys agg: egen mshapley`num' = mean(shapley`num')
}

egen totalmabs = rowtotal(m*)
gen relmshapley1 = mshapley1/totalmabs
gen relmshapley2 = mshapley2/totalmabs
gen relmshapley3 = mshapley3/totalmabs
gen relmshapley4 = mshapley4/totalmabs

graph hbar mshapley*, ///
	over(aggregate, ///
		sort(order) ///
		relabel(2 "{it:y{sup:H}} " ///
				1 "{it:y{sup:HE}} " ///
				3 "{it:y{sup:W}} " ///
				4 "{it:y{sup:SW}} ") ///
		label(labsize(medlarge))) ///
	stack ///
	subtitle("(a) Absolute contribution", size(medlarge)) ///
	yti("IOP", size(medium)) ///
	plotregion(margin(small)) ///
	ylabel(0(.01).03) ///
	bar(1, color("$c1") lcolor(black) lwidth(vthin)) ///
	bar(2, color("$c2") lcolor(black) lwidth(vthin)) ///
	bar(3, color("$c3") lcolor(black) lwidth(vthin)) ///
	bar(4, color("$c4") lcolor(black) lwidth(vthin)) ///
	legend(rows(2) ///
		lab(1 "Gender") lab(2 "Immigrant status") ///
		lab(3 "Parental education") lab(4 "Parental occupation") ///
		size(small) ///
		symxsize(*0.4)) ///
	name(InAgg_shapleys_abs, replace) ///
	nodraw
graph hbar relm*, ///
	over(aggregate, ///
		sort(order) ///
		relabel(2 "    " 1 "    " 3 "    " 4 "    ")) ///
	percent ///
	stack ///
	subtitle("(b) Relative contribution", size(medlarge)) ///
	yti("% of total IOP", size(medium)) ///
	plotregion(margin(small)) ///
	ylabel(0(25)100) ///
	bar(1, color("$c1") lcolor(black) lwidth(vthin)) ///
	bar(2, color("$c2") lcolor(black) lwidth(vthin)) ///
	bar(3, color("$c3") lcolor(black) lwidth(vthin)) ///
	bar(4, color("$c4") lcolor(black) lwidth(vthin)) ///
	name(InAgg_shapleys_rel, replace) ///
	nodraw
restore

grc1leg2 InAgg_shapleys_abs InAgg_shapleys_rel, ///
	row(1) ///
	legendfrom(InAgg_shapleys_abs) ///
	name(InAgg_shapleys, replace)
graph display InAgg_shapleys, ysize(12) xsize(20)
graph export InAgg_shapleys.png, replace width(3000)

**********************************Bars*************************************

collapse (firstnm) fg1a fg1aLL fg1aUL fg1r country_short order, by(country aggregate) fast

gen aggcountry=order if country=="Sweden" & order==1
replace aggcountry=order+4 if country=="Sweden" & order==2
replace aggcountry=order+8 if country=="Sweden" & order==3
replace aggcountry=order+12 if country=="Sweden" & order==4

replace aggcountry=order+22 if country=="Iceland" & order==1
replace aggcountry=order+26 if country=="Iceland" & order==2
replace aggcountry=order+30 if country=="Iceland" & order==3
replace aggcountry=order+34 if country=="Iceland" & order==4

replace aggcountry=order+44 if country=="Norway" & order==1
replace aggcountry=order+48 if country=="Norway" & order==2
replace aggcountry=order+52 if country=="Norway" & order==3
replace aggcountry=order+56 if country=="Norway" & order==4

replace aggcountry=order+66 if country=="Denmark" & order==1
replace aggcountry=order+70 if country=="Denmark" & order==2
replace aggcountry=order+74 if country=="Denmark" & order==3
replace aggcountry=order+78 if country=="Denmark" & order==4

replace aggcountry=order+88 if country=="Netherlands" & order==1
replace aggcountry=order+92 if country=="Netherlands" & order==2
replace aggcountry=order+96 if country=="Netherlands" & order==3
replace aggcountry=order+100 if country=="Netherlands" & order==4

replace aggcountry=order+110 if country=="Finland" & order==1
replace aggcountry=order+114 if country=="Finland" & order==2
replace aggcountry=order+118 if country=="Finland" & order==3
replace aggcountry=order+122 if country=="Finland" & order==4

replace aggcountry=order+132 if country=="Germany" & order==1
replace aggcountry=order+136 if country=="Germany" & order==2
replace aggcountry=order+140 if country=="Germany" & order==3
replace aggcountry=order+144 if country=="Germany" & order==4

replace aggcountry=order+154 if country=="Slovakia" & order==1
replace aggcountry=order+158 if country=="Slovakia" & order==2
replace aggcountry=order+162 if country=="Slovakia" & order==3
replace aggcountry=order+166 if country=="Slovakia" & order==4

replace aggcountry=order+176 if country=="Lithuania" & order==1
replace aggcountry=order+180 if country=="Lithuania" & order==2
replace aggcountry=order+184 if country=="Lithuania" & order==3
replace aggcountry=order+188 if country=="Lithuania" & order==4

replace aggcountry=order+198 if country=="Czech R." & order==1
replace aggcountry=order+202 if country=="Czech R." & order==2
replace aggcountry=order+206 if country=="Czech R." & order==3
replace aggcountry=order+210 if country=="Czech R." & order==4

replace aggcountry=order+220 if country=="Slovenia" & order==1
replace aggcountry=order+224 if country=="Slovenia" & order==2
replace aggcountry=order+228 if country=="Slovenia" & order==3
replace aggcountry=order+232 if country=="Slovenia" & order==4

replace aggcountry=order+242 if country=="Switzerland" & order==1
replace aggcountry=order+246 if country=="Switzerland" & order==2
replace aggcountry=order+250 if country=="Switzerland" & order==3
replace aggcountry=order+254 if country=="Switzerland" & order==4

replace aggcountry=order+264 if country=="Belgium" & order==1
replace aggcountry=order+268 if country=="Belgium" & order==2
replace aggcountry=order+272 if country=="Belgium" & order==3
replace aggcountry=order+276 if country=="Belgium" & order==4

replace aggcountry=order+286 if country=="Malta" & order==1
replace aggcountry=order+290 if country=="Malta" & order==2
replace aggcountry=order+294 if country=="Malta" & order==3
replace aggcountry=order+298 if country=="Malta" & order==4

replace aggcountry=order+308 if country=="Cyprus" & order==1
replace aggcountry=order+312 if country=="Cyprus" & order==2
replace aggcountry=order+316 if country=="Cyprus" & order==3
replace aggcountry=order+320 if country=="Cyprus" & order==4

replace aggcountry=order+330 if country=="France" & order==1
replace aggcountry=order+334 if country=="France" & order==2
replace aggcountry=order+338 if country=="France" & order==3
replace aggcountry=order+342 if country=="France" & order==4

replace aggcountry=order+352 if country=="United K." & order==1
replace aggcountry=order+356 if country=="United K." & order==2
replace aggcountry=order+360 if country=="United K." & order==3
replace aggcountry=order+364 if country=="United K." & order==4

replace aggcountry=order+374 if country=="Estonia" & order==1
replace aggcountry=order+378 if country=="Estonia" & order==2
replace aggcountry=order+382 if country=="Estonia" & order==3
replace aggcountry=order+386 if country=="Estonia" & order==4

replace aggcountry=order+396 if country=="Croatia" & order==1
replace aggcountry=order+400 if country=="Croatia" & order==2
replace aggcountry=order+404 if country=="Croatia" & order==3
replace aggcountry=order+408 if country=="Croatia" & order==4

replace aggcountry=order+418 if country=="Austria" & order==1
replace aggcountry=order+422 if country=="Austria" & order==2
replace aggcountry=order+426 if country=="Austria" & order==3
replace aggcountry=order+430 if country=="Austria" & order==4

replace aggcountry=order+440 if country=="Ireland" & order==1
replace aggcountry=order+444 if country=="Ireland" & order==2
replace aggcountry=order+448 if country=="Ireland" & order==3
replace aggcountry=order+452 if country=="Ireland" & order==4

replace aggcountry=order+462 if country=="Latvia" & order==1
replace aggcountry=order+466 if country=="Latvia" & order==2
replace aggcountry=order+470 if country=="Latvia" & order==3
replace aggcountry=order+474 if country=="Latvia" & order==4

replace aggcountry=order+484 if country=="Poland" & order==1
replace aggcountry=order+488 if country=="Poland" & order==2
replace aggcountry=order+492 if country=="Poland" & order==3
replace aggcountry=order+496 if country=="Poland" & order==4

replace aggcountry=order+506 if country=="Italy" & order==1
replace aggcountry=order+510 if country=="Italy" & order==2
replace aggcountry=order+514 if country=="Italy" & order==3
replace aggcountry=order+518 if country=="Italy" & order==4

replace aggcountry=order+528 if country=="Hungary" & order==1
replace aggcountry=order+532 if country=="Hungary" & order==2
replace aggcountry=order+536 if country=="Hungary" & order==3
replace aggcountry=order+540 if country=="Hungary" & order==4

replace aggcountry=order+550 if country=="Portugal" & order==1
replace aggcountry=order+554 if country=="Portugal" & order==2
replace aggcountry=order+558 if country=="Portugal" & order==3
replace aggcountry=order+562 if country=="Portugal" & order==4

replace aggcountry=order+572 if country=="Spain" & order==1
replace aggcountry=order+576 if country=="Spain" & order==2
replace aggcountry=order+580 if country=="Spain" & order==3
replace aggcountry=order+584 if country=="Spain" & order==4

replace aggcountry=order+594 if country=="Romania" & order==1
replace aggcountry=order+598 if country=="Romania" & order==2
replace aggcountry=order+602 if country=="Romania" & order==3
replace aggcountry=order+606 if country=="Romania" & order==4

replace aggcountry=order+616 if country=="Greece" & order==1
replace aggcountry=order+620 if country=="Greece" & order==2
replace aggcountry=order+624 if country=="Greece" & order==3
replace aggcountry=order+628 if country=="Greece" & order==4

replace aggcountry=order+638 if country=="Bulgaria" & order==1
replace aggcountry=order+642 if country=="Bulgaria" & order==2
replace aggcountry=order+646 if country=="Bulgaria" & order==3
replace aggcountry=order+650 if country=="Bulgaria" & order==4

replace aggcountry=order+660 if country=="Luxembourg" & order==1
replace aggcountry=order+664 if country=="Luxembourg" & order==2
replace aggcountry=order+668 if country=="Luxembourg" & order==3
replace aggcountry=order+672 if country=="Luxembourg" & order==4

graph twoway ///
	(bar fg1a aggcountry if order==1, color("$c1") barw(5) lcolor(black) lwidth(vthin)) ///
	(bar fg1a aggcountry if order==2, color("$c2") barw(5) lcolor(black) lwidth(vthin)) ///
	(bar fg1a aggcountry if order==3, color("$c3") barw(5) lcolor(black) lwidth(vthin)) ///
	(bar fg1a aggcountry if order==4, color("$c4") barw(5) lcolor(black) lwidth(vthin)) ///
	(rcap fg1aUL fg1aLL aggcountry, color("black") lwidth(thin)), ///
	plotregion(margin(b=0)) ///
	scale(.7) ///
	yti("IOP") ///
	xti("") ///
	ylabel(0(.02).08, ///
		grid) ///
	xlabel(9 "Sweden " ///
	       31 "Iceland " ///
	       53 "Norway " ///
	       75 "Denmark " ///
	       97 "Netherlands " ///
	       119 "Finland " ///
	       141 "Germany " ///
	       163 "Slovakia " ///
	       185 "Lithuania " ///
	       207 "Czech R. " ///
	       229 "Slovenia " ///
	       251 "Switzerland " ///
	       273 "Belgium " ///
	       295 "Malta " ///
	       317 "Cyprus " ///
	       339 "France " ///
	       361 "United K. " ///
	       383 "Estonia " ///
	       405 "Croatia " ///
	       427 "Austria " ///
	       449 "Ireland " ///
	       471 "Latvia " ///
	       493 "Poland " ///
	       515 "Italy " ///
	       537 "Hungary " ///
	       559 "Portugal " ///
	       581 "Spain " ///
	       603 "Romania " ///
	       625 "Greece " ///
	       647 "Bulgaria " ///
	       669 "Luxembourg ", ///
		   angle(55) ///
		   labsize(small)) ///
   legend(rows(1) ///
		order(1 "{it:y{sup:H}}" ///
			2 "{it:y{sup:HE}}" ///
			3 "{it:y{sup:W}}" ///
			4 "{it:y{sup:SW}}" ///
			5 "95% CI") ///
			ring(0) ///
			position(11) ///
			bmargin(medium)) ///
	ysize(12) xsize(20)
graph export InAgg_bars_abs.png, width(5000) replace

**********************************Ranks*************************************

keep country country_short aggregate fg1a fg1r
rename (fg1a fg1r) (fg1a_ fg1r_)
reshape wide fg1a fg1r, i(country country_short) j(aggregate) string

foreach est of newlist fg1a fg1r {
	if "`est'" == "fg1a" {
		local name abs
	}
	else {
		local name rel
	}
	preserve
	sort `est'_wage_e
	gen id_wage_e = _n
	sort `est'_wage_se
	gen id_wage_se = _n
	sort `est'_head
	gen id_head = _n
	sort `est'_pcdhi
	gen id_pcdhi = _n

	spearman id_pcdhi id_head
	local cor : display %5.4f r(rho)

	twoway (scatter id_pcdhi id_head, color("$c1") mlabel(country_short) mlabcolor(black) msymbol(d) mlabpos(9)) ///
		(function y=x, lpattern(dash) color("$c2") range(0 31)), ///
		plotregion(margin(b=0)) scale(.6) subtitle("(a) {it:y{sup:H}} against {it:y{sup:HE}}", size(medlarge)) ///
		note("Rank correlation: `cor'", size(medsmall) ring(0) position(4) bmargin(medium)) ///
		yti("{it:y{sup:H}} rank", size(medium)) xti("{it:y{sup:HE}} rank", size(medium)) legend(off) nodraw ///
		ylabel(0(5)31) xlabel(0(5)31) name(`est'_rank_pcdhihead_10, replace)

	spearman id_pcdhi id_wage_se
	local cor : display %5.4f r(rho)

	twoway (scatter id_pcdhi id_wage_se, color("$c1") mlabel(country_short) mlabcolor(black) msymbol(d) mlabpos(9)) ///
		(function y=x, lpattern(dash) color("$c2") range(0 31)), ///
		plotregion(margin(b=0)) scale(.6) subtitle("(b) {it:y{sup:H}} against {it:y{sup:SW}}", size(medlarge)) ///
		note("Rank correlation: `cor'", size(medsmall) ring(0) position(4) bmargin(medium)) ///
		yti("{it:y{sup:H}} rank", size(medium)) xti("{it:y{sup:SW}} rank", size(medium)) legend(off) nodraw ///
		ylabel(0(5)31) xlabel(0(5)31) name(`est'_rank_pcdhiwage_se_10, replace)

	spearman id_head id_wage_se
	local cor : display %5.4f r(rho)

	twoway (scatter id_head id_wage_se, color("$c1") mlabel(country_short) mlabcolor(black) msymbol(d) mlabpos(9)) ///
		(function y=x, lpattern(dash) color("$c2") range(0 31)), ///
		plotregion(margin(b=0)) scale(.6) subtitle("(c) {it:y{sup:HE}} against {it:y{sup:SW}}", size(medlarge)) ///
		note("Rank correlation: `cor'", size(medsmall) ring(0) position(4) bmargin(medium)) ///
		yti("{it:y{sup:HE}} rank", size(medium)) xti("{it:y{sup:SW}} rank", size(medium)) legend(off) nodraw ///
		ylabel(0(5)31) xlabel(0(5)31) name(`est'_rank_headwage_se_10, replace)

	spearman id_wage_e id_wage_se
	local cor : display %5.4f r(rho)

	twoway (scatter id_wage_e id_wage_se, color("$c1") mlabel(country_short) mlabcolor(black) msymbol(d) mlabpos(9)) ///
		(function y=x, lpattern(dash) color("$c2") range(0 31)), ///
		plotregion(margin(b=0)) scale(.6) subtitle("(d) {it:y{sup:W}} against {it:y{sup:SW}}", size(medlarge)) ///
		note("Rank correlation: `cor'", size(medsmall) ring(0) position(4) bmargin(medium)) ///
		yti("{it:y{sup:W}} rank", size(medium)) xti("{it:y{sup:SW}} rank", size(medium)) legend(off) nodraw ///
		ylabel(0(5)31) xlabel(0(5)31) name(`est'_rank_wage_ewage_se_10, replace)

	graph combine `est'_rank_pcdhihead_10 `est'_rank_pcdhiwage_se_10 ///
				  `est'_rank_headwage_se_10 `est'_rank_wage_ewage_se_10, ///
				  col(2) ysize(20) xsize(20)
	graph export InAgg_ranks_`name'.png, replace width(3000)
	restore
}
