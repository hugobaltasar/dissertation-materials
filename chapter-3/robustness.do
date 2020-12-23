
////////////////////////////////////////////////////////////////////////////////
////////////////////////InAgg with EU-SILC - Robustness/////////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir/InAgg-output/"
capture mkdir ./robustness/
cd ./robustness/

local tests "esamples gini edhi"

foreach test in `tests' {

    if "`test'" == "esamples" {
        global aggregates pcdhi wage_se
    }
    else {
        global aggregates pcdhi head wage_e wage_se
    }

    local countries Austria Belgium Bulgaria Croatia Cyprus ///
        CzechRepublic Denmark Estonia Finland France Germany ///
        Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
        Luxembourg Malta Netherlands Norway Poland Portugal ///
        Romania Slovakia Slovenia Spain Sweden Switzerland ///
        UnitedKingdom // 31 countries

    foreach country in `countries' {
        foreach aggregate in $aggregates {

            use "$maindir/InAgg-data/eusilc2011_`country'", clear

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
            la drop _all

            **************************************Age***************************************

            drop if pageend < 30 | pageend > 59

            ***********************************Education************************************

            gen edulevel = 1 if pedulevel >= 0 & pedulevel <= 2
            replace edulevel = 2 if pedulevel == 3 | pedulevel == 4
            replace edulevel = 3 if pedulevel == 5 | pedulevel == 6

            if "`test'" == "esamples" | "`aggregate'" == "wage_se" {
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

            if "`test'" == "esamples" | "`aggregate'" == "wage_se" {
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

            *****************Activity status & Responsible household member*****************

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
                    drop lnwage
                }
            }
            if "`test'" == "esamples" | "`aggregate'" == "pcdhi" | "`aggregate'" == "head" {
                if "`test'" == "edhi" {
                    gen pcdhi = hytotalen
                }
                else {
                    gen pcdhi = hytotaln / hsize
                }
                drop if pcdhi <= 0 | pcdhi >= .
                qui sum pcdhi [w=hw], d
                replace pcdhi = r(p99) if pcdhi > r(p99) & pcdhi < .
            }

            if "`aggregate'" == "head" {
                gen head = pid == prespons1
                keep if head == 1
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

            if "`test'" == "gini" {
                local program1 fastgini
                local program2 iopgini
                local stat gini
            }
            else {
                local program1 fastmld
                local program2 iop
                local stat ge0
            }

            *Bootstrap replications*
            forvalues i = 1/$reps {
                preserve
                bsample, strata(hregion)

                *IOP*
                reg `income' `circumstances'
                predict yhat
                `program1' yhat
                if `i' == 1 {
                    mat define iop = (r(`stat'))
                }
                else {
                    mat define iop = (iop \ r(`stat'))
                }
                restore
            }
            matrix colnames iop = "_mld"
            svmat iop, names(matcol)
            sum iop_mld
            gen fg1a = r(mean)
            gen fg1aSE = r(sd)
            gen fg1aLL = r(mean) - 1.96 * r(sd)
            gen fg1aUL = r(mean) + 1.96 * r(sd)
            drop iop_mld

            `program2' `income' `circumstances', s(fg1a) nologlin
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

            keep country aggregate fg1a fg1aSE ///
                 shapley1 shapley2 shapley3 shapley4

            drop if country == "" // if a sample has less observations than the
                // bootstrap repetitions, then `svmat` creates new lines
                // (Iceland with head)
            tempfile `country'_`aggregate'_`test'
        	save ``country'_`aggregate'_`test''

        }

        if "`test'" == "esamples" {
            use ``country'_pcdhi_`test'', clear
            append using ``country'_wage_se_`test''
        }
        else {
            use ``country'_pcdhi_`test'', clear
            append using ``country'_head_`test''
            append using ``country'_wage_se_`test''
            append using ``country'_wage_e_`test''
        }

        tempfile InAgg_`country'_`test'
        save `InAgg_`country'_`test''
    }

    clear
    foreach country in `countries' {
    	append using `InAgg_`country'_`test''
    }

    collapse (firstnm) fg1a fg1aSE shapley*, by(country aggregate) fast
    compress
    save "InAgg_`test'", replace

    capture rm "__000005.dta"
    capture rm "__000004.dta"
}

foreach test in `tests' {
    use InAgg_`test', clear

    *mean shapleys*
    preserve
    drop if country == "Sweden" // has only three circumstances
    egen totalabs = rowtotal(shapley*)

    local shapleys shapley1 shapley2 shapley3 shapley4 totalabs

    foreach aggregate in $aggregates {
        foreach shapley in `shapleys' {
            sum `shapley' if aggregate == "`aggregate'", meanonly
            local `shapley'_`aggregate' = r(mean)
        }
    }

    matrix robustshapleys = (`shapley1_pcdhi',`shapley1_head',`shapley1_wage_e',`shapley1_wage_se' \ ///
                       `shapley2_pcdhi',`shapley2_head',`shapley2_wage_e',`shapley2_wage_se' \ ///
                       `shapley3_pcdhi',`shapley3_head',`shapley3_wage_e',`shapley3_wage_se' \ ///
                       `shapley4_pcdhi',`shapley4_head',`shapley4_wage_e',`shapley4_wage_se' \ ///
                       `totalabs_pcdhi',`totalabs_head',`totalabs_wage_e',`totalabs_wage_se')

    matrix rownames robustshapleys = "\ \ Gender" "\ \ Immigrant status" "\ \ Parental education" ///
        "\ \ Parental occupation" "\ \ \emph{Total}"

    esttab matrix(robustshapleys, fmt(%5.4f)) using InAgg_robustshapleys_`test'.tex, replace ///
        nomtitles booktabs collabels(none) f nolines
    restore

    *rank correlation*
    drop shapley* fg1aSE
    rename fg1a fg1a_
    reshape wide fg1a_, i(country) j(aggregate) string
    if "`test'" == "esamples" {
        spearman fg1a_pcdhi fg1a_wage_se
        local cor_pcdhiwagese `r(rho)'
    }
    else {
        spearman fg1a_pcdhi fg1a_head
        local cor_pcdhihead `r(rho)'
        spearman fg1a_pcdhi fg1a_wage_se
        local cor_pcdhiwagese `r(rho)'
        spearman fg1a_head fg1a_wage_se
        local cor_headwagese `r(rho)'
        spearman fg1a_wage_e fg1a_wage_se
        local cor_wagewagese `r(rho)'
    }

    if "`test'" == "esamples" {
        matrix ranks_`test' = (.,`cor_pcdhiwagese',.,.)
        matrix rownames ranks_`test' = "Equal samples"
    }
    else if "`test'" == "gini" {
        matrix ranks_`test' = (`cor_pcdhihead',`cor_pcdhiwagese',`cor_headwagese',`cor_wagewagese')
        matrix rownames ranks_`test' = "Gini"
    }
    else {
        matrix ranks_`test' = (`cor_pcdhihead',`cor_pcdhiwagese',`cor_headwagese',`cor_wagewagese')
        matrix rownames ranks_`test' = "Equivalent income"
    }
}

capture rm InAgg_robustranks.tex
foreach test in `tests' {
    esttab matrix(ranks_`test', fmt(%5.4f)) using InAgg_robustranks.tex, append ///
        nomtitles booktabs collabels(none) f nolines
}
