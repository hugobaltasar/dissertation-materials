
////////////////////////////////////////////////////////////////////////////////
/////////////////////////IOPK with EU-SILC - Estimations////////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir/IOPK-data"

global years 05 11 04 06 07 08 09 10 12 13 14 15 16 17
foreach year in $years {

    qui include "$codedir/countrieslist.do"

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

        if country == "Malta" & year >= 2015 { // Malta has missing values in 'pageend' from 2015 on
            replace pageend = year - pbirthyear
        }
        // need to run this now to use it when creating dummy for children

        gen couple = ppartner != .

        egen nadults = total(pageend > 17), by(hid)
        gen children = (hsize - nadults) > 0

        **************************************Age***************************************

        drop if pageend < 30 | pageend > 59

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

        if `year' == 05 {
            **Creating levels of education for the mother**
            gen	pgrpedumother = 1 if pedumother >= 0 & pedumother < 3
            replace pgrpedumother = 2 if pedumother > 2 & pedumother < 5
            replace pgrpedumother = 3 if pedumother == 5

            **Creating levels of education for the father**
            gen	pgrpedufather = 1 if pedufather >= 0 & pedufather < 3
            replace pgrpedufather = 2 if pedufather > 2 & pedufather < 5
            replace pgrpedufather = 3 if pedufather == 5

            **Creating levels of education for both parents**
            gen eduparents = 1 if pgrpedumother == 1 | pgrpedufather == 1
            replace eduparents = 2 if pgrpedumother == 2 | pgrpedufather == 2
            replace eduparents = 3 if pgrpedumother == 3 | pgrpedufather == 3
            drop if eduparents == .
        }
        if `year' == 11 {
            **2011 includes the value "-1 = don't know"**
            drop if pedumother == -1
            drop if pedufather == -1

            **Creating levels of education for both parents**
            gen eduparents = 1 if pedumother <= 1 | pedufather <= 1
            replace eduparents = 2 if pedumother == 2 | pedufather == 2
            replace eduparents = 3 if pedumother == 3 | pedufather == 3
            drop if eduparents == .
        }

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

        if (country == "Bulgaria" & `year' == 11) | (country == "Finland" & `year' == 11) | ///
            (country == "Ireland" & `year' == 11) | (country == "Romania" & `year' == 10) | ///
            (country == "Iceland" & `year' >= 14) {
                replace occulevel = .
                // these countries do not have information on personal occupation in these periods
        }
        else {
            drop if occulevel == .
        }

        if country != "Sweden" {
            if `year' == 05 {
                gen pgrpoccufather = 3 if poccufather >= 0 & poccufather < 40
                replace pgrpoccufather = 2 if poccufather >= 40 & poccufather < 90
                replace pgrpoccufather = 1 if poccufather >= 90 & poccufather < .

                gen pgrpoccumother = 3 if poccumother >= 0 & poccumother < 40
                replace pgrpoccumother = 2 if poccumother >= 40 & poccumother < 90
                replace pgrpoccumother = 1 if poccumother >= 90 & poccumother < .
            }
            if `year' == 11 {
                gen pgrpoccufather = 3 if poccufather >= 0 & poccufather < 4
                replace pgrpoccufather = 2 if poccufather >= 4 & poccufather < 9
                replace pgrpoccufather = 1 if poccufather >= 9 & poccufather < .

                gen pgrpoccumother = 3 if poccumother >= 0 & poccumother < 4
                replace pgrpoccumother = 2 if poccumother >= 4 & poccumother < 9
                replace pgrpoccumother = 1 if poccumother >= 9 & poccumother < .
            }
            if `year' == 05 | `year' == 11 {
                gen occuparents = 1 if pgrpoccumother == 1 | pgrpoccufather == 1
                replace occuparents = 2 if pgrpoccumother == 2 | pgrpoccufather == 2
                replace occuparents = 3 if pgrpoccumother == 3 | pgrpoccufather == 3
                drop if occuparents >= .
            }
        }
        else {
            if `year' == 05 | `year' == 11 {
                gen occuparents = .
            }
        }

        ************************************Incomes*************************************

        replace pyemplncashg = 0 if pyemplncashg == .
        replace pyemplncashn = 0 if pyemplncashn == .
        // some countries do not have pyemplncash

        *Personal labor income*
        if country == "France" | country == "Greece" | country == "Italy" | ///
           country == "Latvia" | country == "Portugal" | country == "Spain" {
               gen income = pyemplcashn + pyemplncashn + pyselfempln
        }
        else {
            gen income = pyemplcashg + pyemplncashg + pyselfemplg
        }
        qui sum income [w=pcsw], d
        replace income = r(p99) if income > r(p99) & income < .
        gen lnincome = ln(income)

        *Activity status*
        if `year' < 09 {
            gen intoemplmnt = (pmthftjob > 6 | pmthptjob > 6) & ///
                              (income > 0 & income < .)
        }
        else {
            gen intoemplmnt = (pmthftjobemp > 6 | pmthftjobself > 6 | ///
                               pmthptjobemp > 6 | pmthptjobself > 6) & ///
                              (income > 0 & income < .)
        }
        // employees and self-employed who worked full- or part-time during 7 or more months

        if (country == "Bulgaria" & `year' == 11) | (country == "Finland" & `year' == 11) | ///
            (country == "Ireland" & `year' == 11) | (country == "Romania" & `year' == 10) | ///
            (country == "Iceland" & `year' >= 14) {
                heckman lnincome c.pageend c.pageend#c.pageend i.edulevel, ///
                    vce(robust) ///
                    select(intoemplmnt = i.female i.couple i.female#i.couple ///
                        i.children i.female#i.children i.immigrant)
        }
        else {
            heckman lnincome c.pageend c.pageend#c.pageend i.edulevel i.occulevel, ///
                vce(robust) ///
                select(intoemplmnt = i.female i.couple i.female#i.couple ///
                    i.children i.female#i.children i.immigrant)
        }
        predict yhat_h
        replace lnincome = yhat_h if intoemplmnt == 0
        replace income = exp(lnincome)

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
        if (country == "Bulgaria" & `year' == 11) | (country == "Finland" & `year' == 11) | ///
            (country == "Ireland" & `year' == 11) | (country == "Romania" & `year' == 10) | ///
            (country == "Iceland" & `year' >= 14) {
                reg pckinc pageend c.pageend#c.pageend i.edulevel i.couple [w=pcsw]
        }
        else {
            reg pckinc pageend c.pageend#c.pageend i.edulevel i.occulevel i.couple [w=pcsw]
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

        *****************************Estimating inequalities****************************

        *Defining types*
        local minobs 10

        if `year' == 05 | `year' == 11 {
            gen type_b = .
            local type 1
            forvalues i = 0/1 {
                forvalues k = 0/1 {
                    forvalues p = 1/3 {
                        if country != "Sweden" {
                            forvalues z = 1/3 {
                                replace type_b = `type' if female == `i' & immigrant == `k' & eduparents == `p' & occuparents == `z'
                                la de type_b `type' "`i'`k'`p'`z'", modify
                                local ++type
                            }
                        }
                        else {
                            replace type_b = `type' if female == `i' & immigrant == `k' & eduparents == `p'
                            la de type_b `type' "`i'`k'`p'", modify
                            local ++type
                        }
                    }
                }
            }
            la val type_b type_b
            drop if type_b == .
        }

        foreach kvar in $kvars {
            gen type_`kvar' = .
            local type 1
            forvalues i = 0/1 {
                forvalues k = 0/1 {
                    forvalues p = 1/4 {
                        replace type_`kvar' = `type' if female == `i' & immigrant == `k' & `kvar' == `p'
                        la de type_`kvar' `type' "`i'`k'`p'", modify
                        local ++type
                    }
                }
            }
            la val type_`kvar' type_`kvar'
            drop if type_`kvar' == .
        }

        *Bootstrap replications*
        forvalues i = 1/$reps {
            preserve
            bsample, strata(hregion)

            *Income inequality*
            keep if income > 0 & income < .
            fastmld income
            if `i' == 1 {
                mat define ii = (r(ge0))
                mat define iiN = (r(N))
            }
            else {
                mat define ii = (ii \ r(ge0))
                mat define iiN = (iiN \ r(N))
            }

            *IOP*
            *w/ baseline circumstances*
            if `year' == 05 | `year' == 11 {
                tempvar ytypes_b
                gen `ytypes_b' = .
                forvalues n = 1/36 {
                    sum income if type_b == `n', meanonly
                    replace `ytypes_b' = r(mean) if type_b == `n' & r(N) >= `minobs'
                }
                fastmld `ytypes_b'
                if `i' == 1 {
                    mat define iop_b = (r(ge0))
                    mat define iopN_b = (r(N))
                }
                else {
                    mat define iop_b = (iop_b \ r(ge0))
                    mat define iopN_b = (iopN_b \ r(N))
                }
            }
            *w/ capital circumstances*
            foreach kvar in $kvars {
                tempvar ytypes_k
                gen `ytypes_k' = .
                forvalues n = 1/16 {
                    sum income if type_`kvar' == `n', meanonly
                    replace `ytypes_k' = r(mean) if type_`kvar' == `n' & r(N) >= `minobs'
                }
                fastmld `ytypes_k'
                if `i' == 1 {
                    mat define iop_`kvar' = (r(ge0))
                    mat define iopN_`kvar' = (r(N))
                }
                else {
                    mat define iop_`kvar' = (iop_`kvar' \ r(ge0))
                    mat define iopN_`kvar' = (iopN_`kvar' \ r(N))
                }
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

        if `year' == 05 | `year' == 11 {
            matrix colnames iop_b = "_mld"
            svmat iop_b, names(matcol)
            sum iop_b_mld
            gen eabt_b = r(mean)
            gen eabtSE_b = r(sd)
            gen eabtLL_b = r(mean) - 1.96 * r(sd)
            gen eabtUL_b = r(mean) + 1.96 * r(sd)
            gen eabt_e_b = mld - eabt_b
            gen eabtR_b = eabt_b / mld
            gen eabtRLL_b = eabtLL_b / mld
            gen eabtRUL_b = eabtUL_b / mld
            matrix colnames iopN_b = "_mld"
            svmat iopN_b, names(matcol)
            sum iopN_b_mld, meanonly
            gen eabtN_b = round(r(mean))
            drop iop_b_mld iopN_b_mld
        }

        foreach kvar in $kvars {
            preserve
            matrix colnames iop_`kvar' = "_mld"
            svmat iop_`kvar', names(matcol)
            sum iop_`kvar'_mld
            gen eabt_k = r(mean)
            gen eabtSE_k = r(sd)
            gen eabtLL_k = r(mean) - 1.96 * r(sd)
            gen eabtUL_k = r(mean) + 1.96 * r(sd)
            gen eabt_e_k = mld - eabt_k
            gen eabtR_k = eabt_k / mld
            gen eabtRLL_k = eabtLL_k / mld
            gen eabtRUL_k = eabtUL_k / mld
            matrix colnames iopN_`kvar' = "_mld"
            svmat iopN_`kvar', names(matcol)
            sum iopN_`kvar'_mld, meanonly
            gen eabtN_k = round(r(mean))
            drop iop_`kvar'_mld iopN_`kvar'_mld

            if `year' == 05 | `year' == 11 {
                collapse (firstnm) year country country_short ///
                    mld mldSE mldLL mldUL mldN ///
                    eabt_b eabtSE_b eabtLL_b eabtUL_b eabtN_b ///
                    eabt_e_b eabtR_b eabtRLL_b eabtRUL_b ///
                    eabt_k eabtSE_k eabtLL_k eabtUL_k eabtN_k ///
                    eabt_e_k eabtR_k eabtRLL_k eabtRUL_k, ///
                    fast
            }
            else {
                collapse (firstnm) year country country_short ///
                    mld mldSE mldLL mldUL mldN ///
                    eabt_k eabtSE_k eabtLL_k eabtUL_k eabtN_k ///
                    eabt_e_k eabtR_k eabtRLL_k eabtRUL_k, ///
                    fast
            }

            tempfile IOPK_`country'20`year'_`kvar'
        	save `IOPK_`country'20`year'_`kvar''
        	restore
        }
    }
}

foreach kvar in $kvars {
    clear
    foreach year in $years {

        qui include "$codedir/countrieslist.do"

        foreach country in `countries' {
            append using `IOPK_`country'20`year'_`kvar''
        }
    }

    replace year = year - 1
    sort country year
    compress
    save IOPK_`kvar', replace
}

capture rm "__000005.dta"
