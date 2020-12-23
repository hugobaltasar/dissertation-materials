
////////////////////////////////////////////////////////////////////////////////
/////////////////////////InAgg with EU-SILC - Estimations///////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir/InAgg-data"

local countries Austria Belgium Bulgaria Croatia Cyprus ///
    CzechRepublic Denmark Estonia Finland France Germany ///
    Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
    Luxembourg Malta Netherlands Norway Poland Portugal ///
    Romania Slovakia Slovenia Spain Sweden Switzerland ///
    UnitedKingdom // 31 countries

foreach country in `countries' {
    foreach aggregate in $aggregates {

        use "eusilc2011_`country'", clear

        gen aggregate = "`aggregate'"

        gen country_short = country
        replace country_short = "GR" if country_short == "EL"
        replace country = "`country'"

	qui tab hregion // Germany, the Netherlands, Portugal and Slovenia have no info on NUTS regions
	if r(N) == 0 {
		replace hregion = 0
	}

        *************************************Gender*************************************

        drop if psex == .
        recode psex (1=0) (2=1)
        rename psex female

        ************************************Couples*************************************

        gen couple = pspouseid != .

        by hid (pid), sort: gen hidpid = _n // consistent person identifier within households
        gen byte spouseid = . // consistent partner identifier within households
        summarize hidpid, meanonly
        qui forval i = 1/`r(max)' {
        	by hid: replace spouseid = `i' if pspouseid == pid[`i'] & !missing(pspouseid)
        }
        by hid: gen spousegender = female[spouseid] // gender of partner
	    count if couple == 1
	    local ncoupled = r(N)
	    count if female == spousegender
	    local nhomos = r(N)
	    gen homocouples = (`nhomos' / `ncoupled') * 100 // % of homosexual couples

        **************************Household adults & children***************************

        egen nadults = total(pageend > 17), by(hid)
        gen children = (hsize - nadults) > 0

        ***********************************Immigrant************************************

        drop if pcountrybirth == ""
        encode pcountrybirth, g(immigrant)
        if country == "Germany" | country == "Estonia" | ///
			country == "Latvia" | country == "Malta" | ///
			country == "Slovenia" {
				recode immigrant (1=0) (2=1)
        }
        else {
            recode immigrant (2=0) (1/3=1)
        }
        la drop immigrant

        **************************************Age***************************************

        drop if pageend < 30 | pageend > 59

        ***********************************Education************************************

        gen edulevel = 1 if pedulevel >= 0 & pedulevel <= 2
        replace edulevel = 2 if pedulevel == 3 | pedulevel == 4
        replace edulevel = 3 if pedulevel == 5 | pedulevel == 6

        if "`aggregate'" == "wage_se" {
            drop if edulevel == .
        }

        **2011 includes the value "-1 = don't know"**
        drop if pedumother == -1
        drop if pedufather == -1

        **Creating levels of education for both parents**
        gen eduparents = 1 if pedumother <= 1 | pedufather <= 1
        replace eduparents = 2 if pedumother == 2 | pedufather == 2
        replace eduparents = 3 if pedumother == 3 | pedufather == 3
        drop if eduparents == .

        ***********************************Occupation************************************

        if "`aggregate'" == "wage_se" {
            if country == "Malta" { // has different coding in 'poccup'
                gen occulevel = 3 if poccup >= 1 & poccup < 4
                replace occulevel = 2 if poccup >= 4 & poccup < 9
                replace occulevel = 1 if poccup >= 9 & poccup < .
            }
            else {
                gen occulevel = 3 if poccup >= 10 & poccup < 40
                replace occulevel = 2 if poccup >= 40 & poccup < 90
                replace occulevel = 1 if poccup >= 90 & poccup < .
            }

            if country == "Bulgaria" | country == "Finland" | ///
                country == "Ireland" {
                    replace occulevel = .
                    // these countries do not have information on personal occupation
        	}
        	else {
                drop if occulevel == .
        	}
        }

        if country != "Sweden" {
            gen pgrpoccufather = 3 if poccufather >= 0 & poccufather < 4
            replace pgrpoccufather = 2 if poccufather >= 4 & poccufather < 9
            replace pgrpoccufather = 1 if poccufather >= 9 & poccufather < .

            gen pgrpoccumother = 3 if poccumother >= 0 & poccumother < 4
            replace pgrpoccumother = 2 if poccumother >= 4 & poccumother < 9
            replace pgrpoccumother = 1 if poccumother >= 9 & poccumother < .

            gen occuparents = 1 if pgrpoccumother == 1 | pgrpoccufather == 1
            replace occuparents = 2 if pgrpoccumother == 2 | pgrpoccufather == 2
            replace occuparents = 3 if pgrpoccumother == 3 | pgrpoccufather == 3
            drop if occuparents >= .
        }
        else {
            gen occuparents = .
        }

        *********************************Activity status********************************

        if "`aggregate'" == "wage_e" {
            keep if pmthftjobemp > 6 | pmthftjobself > 6 | pmthptjobemp > 6 | pmthptjobself > 6
            // only employees and self-employed who worked full- or part-time during 7 or more months
        }

        ************************************Incomes*************************************

        replace pyemplncashg = 0 if pyemplncashg == . // Some countries have no pyemplncashg

        if "`aggregate'" == "wage_e" | "`aggregate'" == "wage_se" {
            gen wage = pyemplcashg + pyemplncashg + pyselfemplg

            if "`aggregate'" == "wage_e" {
                drop if wage <= 0 | wage >= .
                qui sum wage [w=pcsw], d
                replace wage = r(p99) if wage > r(p99) & wage < .
            }
            if "`aggregate'" == "wage_se" {
                qui sum wage [w=pcsw], d
                replace wage = r(p99) if wage > r(p99) & wage < .
                gen lnwage = ln(wage)

                gen intoemplmnt = (pmthftjobemp > 6 | pmthftjobself > 6 | ///
                                   pmthptjobemp > 6 | pmthptjobself > 6) & ///
                                  (wage > 0 & wage < .)
                                  // employees and self-employed who worked full- or part-time during 7 or more months

                if country == "Bulgaria" | country == "Finland" | ///
                    country == "Ireland" {
                        heckman lnwage c.pageend c.pageend#c.pageend i.edulevel, ///
                            vce(robust) ///
                            select(intoemplmnt = i.female i.couple i.female#i.couple ///
                                i.children i.female#i.children i.immigrant)
                }
                else {
                    heckman lnwage c.pageend c.pageend#c.pageend i.edulevel i.occulevel, ///
                        vce(robust) ///
                        select(intoemplmnt = i.female i.couple i.female#i.couple ///
                            i.children i.female#i.children i.immigrant)
                }
                predict yhat_h
                replace lnwage = yhat_h if intoemplmnt == 0
                replace wage = exp(lnwage)
            }
        }
        else {
            gen pcdhi = hytotaln / hsize
            drop if pcdhi <= 0 | pcdhi >= .
            qui sum pcdhi [w=hw], d
            replace pcdhi = r(p99) if pcdhi > r(p99) & pcdhi < .
        }

        if "`aggregate'" == "head" {
            gen head = pid == prespons1
            keep if head == 1
        }

        if "`aggregate'" == "pcdhi" {
		    ****************************Household homogeneity***************************

            preserve
            egen hmembers = total(pageend > 0), by(hid) // household members in selected subsample

            if country != "Denmark" & country != "Finland" & country != "Iceland" & ///
               country != "Netherlands" & country != "Norway" & country != "Slovenia" & ///
               country != "Sweden" { // in these countries only one member per hsh has parental info
                   keep if hmembers > 1
            }

            egen anyfemale = max(female), by(hid)
            egen allfemale = min(female), by(hid)
            gen genderhomo = allfemale | anyfemale == 0
            egen hgenderhomo = total(genderhomo / hmembers) // number of households with 2 or more members with gender homogeneity
            sum hgenderhomo, meanonly
            local hgenderhomo = r(mean)
            quietly distinct hid
            local nhouseholds = r(ndistinct) // number of households with 2 or more members

            egen anyimmi = max(immigrant), by(hid)
            egen allimmi = min(immigrant), by(hid)
            gen originhomo = allimmi | anyimmi == 0
            egen horiginhomo = total(originhomo / hmembers) // number of households with 2 or more members with origin homogeneity
            sum horiginhomo, meanonly
            local horiginhomo = r(mean)

            egen allprimpar = min(eduparents == 1), by(hid)
            egen allsecondpar = min(eduparents == 2), by(hid)
            egen alltercpar = min(eduparents == 3), by(hid)
            gen eduparhomo = allprimpar | allsecondpar | alltercpar
            egen heduparhomo = total(eduparhomo / hmembers) // number of households with 2 or more members with eduparents homogeneity
            sum heduparhomo, meanonly
            local heduparhomo = r(mean)

            egen alloccu1par = min(occuparents  == 1), by(hid)
            egen alloccu2par = min(occuparents == 2), by(hid)
            egen alloccu3par = min(occuparents == 3), by(hid)
            gen occuparhomo = alloccu1par | alloccu2par | alloccu3par
            egen hoccuparhomo = total(occuparhomo / hmembers) // number of households with 2 or more members with occuparents homogeneity
            sum hoccuparhomo, meanonly
            local hoccuparhomo = r(mean)

            bys hid: gen hhomogeneity4 = genderhomo & originhomo & eduparhomo & occuparhomo
            sum hhomogeneity4, meanonly
            local hhomogeneity4 = r(mean) // % of households with 2 or more members with homogenous circumstances
            bys hid: gen hhomogeneity3 = (genderhomo & originhomo & eduparhomo) | ///
                                         (genderhomo & originhomo & occuparhomo) | ///
                                         (genderhomo & eduparhomo & occuparhomo) | ///
                                         (originhomo & eduparhomo & occuparhomo)
            sum hhomogeneity3, meanonly
            local hhomogeneity3 = r(mean) // % of households with 2 or more members with "3 out of 4 homogenous circumstances"
            bys hid: gen hhomogeneity2 = (genderhomo & originhomo) | ///
                                         (genderhomo & eduparhomo) | ///
                                         (genderhomo & occuparhomo) | ///
                                         (originhomo & eduparhomo) | ///
                                         (originhomo & occuparhomo) | ///
                                         (eduparhomo & occuparhomo)
            sum hhomogeneity2, meanonly
            local hhomogeneity2 = r(mean) // % of households with 2 or more members with "2 out of 4 homogenous circumstances"
    		restore

            gen genderhomo = (`hgenderhomo' / `nhouseholds') * 100 // % of households with 2 or more members of only one gender
            gen originhomo = (`horiginhomo' / `nhouseholds') * 100 // % of households with 2 or more members of only one origin
            gen eduparhomo = (`heduparhomo' / `nhouseholds') * 100 // % of households with 2 or more members with only one eduparents
            gen occuparhomo = (`hoccuparhomo' / `nhouseholds') * 100 // % of households with 2 or more members with only one occuparents
            if country == "Sweden" {
                replace occuparhomo = 100 // easier to import into latex later
            }
            gen hhomogeneity4 = `hhomogeneity4' * 100 // % of households with 2 or more members with homogenous circumstances
            if country == "Sweden" {
                replace hhomogeneity4 = 100 // easier to import into latex later
            }
            gen hhomogeneity3 = `hhomogeneity3' * 100 // % of households with 2 or more members with "3 out of 4 homogenous circumstances"
            gen hhomogeneity2 = `hhomogeneity2' * 100 // % of households with 2 or more members with "2 out of 4 homogenous circumstances"
        }

        ****************************Calculating inequalities****************************

        if "`aggregate'" == "wage_e" | "`aggregate'" == "wage_se" {
            local income wage
        }
        else {
            local income pcdhi
        }

        if country != "Sweden" {
            local circumstances female immigrant eduparents occuparents
        }
        else {
            local circumstances female immigrant eduparents
        }

        *Bootstrap replications*
        forvalues i = 1/$reps {
            preserve
            bsample, strata(hregion)

            *Income inequality*
            keep if `income' > 0 & `income' < .
            fastmld `income'
            if `i' == 1 {
                mat define ii = (r(ge0))
                mat define iiN = (r(N))
            }
            else {
                mat define ii = (ii \ r(ge0))
                mat define iiN = (iiN \ r(N))
            }

            *IOP*
            reg `income' `circumstances'
            predict yhat
            fastmld yhat
            if `i' == 1 {
                mat define iop = (r(ge0))
                mat define iopN = (r(N))
            }
            else {
                mat define iop = (iop \ r(ge0))
                mat define iopN = (iopN \ r(N))
            }
            restore
        }

        matrix colnames ii = "_mld"
        svmat ii, names(matcol)
        sum ii_mld
        gen mld = r(mean)
        gen mldSE = r(sd)
        gen mldLL = r(mean) - 1.96 * r(sd)
        gen mldUL = r(mean) + 1.96 * r(sd)
        matrix colnames iiN = "_mld"
        svmat iiN, names(matcol)
        sum iiN_mld, meanonly
        gen mldN = round(r(mean))
        drop ii_mld iiN_mld

        matrix colnames iop = "_mld"
        svmat iop, names(matcol)
        sum iop_mld
        gen fg1a = r(mean)
        gen fg1aSE = r(sd)
        gen fg1aLL = r(mean) - 1.96 * r(sd)
        gen fg1aUL = r(mean) + 1.96 * r(sd)
        gen fg1r = fg1a / mld
        gen fg1rLL = fg1aLL / mld
        gen fg1rUL = fg1aUL / mld
        matrix colnames iopN = "_mld"
        svmat iopN, names(matcol)
        sum iopN_mld, meanonly
        gen fg1N = round(r(mean))
        drop iop_mld iopN_mld

        iop `income' `circumstances', s(fg1a) nologlin
        matrix z1 = r(shapley)
        svmat z1, names(matcol)
        replace z1r2 = z1r2[1] if z1r2 == .
        replace z1r3 = z1r3[1] if z1r3 == .
        replace z1r4 = z1r4[1] if z1r4 == .
        rename z1r2 shapley1
        rename z1r3 shapley2
        rename z1r4 shapley3
        if country != "Sweden" {
            replace z1r5 = z1r5[1] if z1r5 == .
            rename z1r5 shapley4
        }
        else {
            gen shapley4 = .
        }

        if "`aggregate'" == "wage_e" {
            local vars wage pcsw
        }
        else if "`aggregate'" == "wage_se" {
            local vars pageend edulevel couple children occulevel ///
                 intoemplmnt wage lnwage pcsw
        }
        else if "`aggregate'" == "head" {
            local vars pcdhi hw head
        }
        else {
            local vars homocouples genderhomo originhomo eduparhomo occuparhomo ///
                 hhomogeneity4 hhomogeneity3 hhomogeneity2 ///
                 pcdhi hw
        }

        keep country country_short hid pid aggregate ///
             female immigrant eduparents occuparents ///
             mld mldSE mldLL mldUL mldN ///
             fg1a fg1aSE fg1aLL fg1aUL ///
             fg1r fg1rLL fg1rUL fg1N ///
             shapley1 shapley2 shapley3 shapley4 ///
             `vars'

        drop if country == "" // if a sample has less observations than the
            // bootstrap replications, then `svmat` creates new lines
            // (Iceland with head)
        tempfile InAgg_`country'2011_`aggregate'
    	save `InAgg_`country'2011_`aggregate''

    }

    use `InAgg_`country'2011_pcdhi', clear
    append using `InAgg_`country'2011_head'
    append using `InAgg_`country'2011_wage_se'
    append using `InAgg_`country'2011_wage_e'

    tempfile InAgg_`country'2011
    save `InAgg_`country'2011'
}

clear
foreach country in `countries' {
	append using `InAgg_`country'2011'
}

order country country_short pid hid aggregate `circumstances'
compress
save InAgg, replace

capture rm "__000005.dta"
capture rm "__000004.dta"
