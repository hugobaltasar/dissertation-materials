
////////////////////////////////////////////////////////////////////////////////
/////////////////////////IOPK with EU-SILC - Robustness/////////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir/IOPK-output"
capture mkdir ./robustness/
cd ./robustness/

local tests "circ5 circ3 employees older fulltime noheck rentK gini prntscdf 005075 000050 noK"

foreach test in `tests' {

    local years 05 11
    foreach year in `years' {

        if `year' == 05 {
            if "`test'" == "circ5" {
                local countries Austria Belgium Cyprus CzechRepublic Denmark ///
    	            Estonia Finland France Germany Greece Hungary Iceland ///
    	            Ireland Italy Latvia Lithuania Luxembourg ///
    	            Norway Poland Portugal Slovakia Spain Sweden ///
    	            UnitedKingdom // 24 countries
                    // the Netherlands and Slovenia do not have information on population density
            }
            else {
                local countries Austria Belgium Cyprus CzechRepublic Denmark ///
    	            Estonia Finland France Germany Greece Hungary Iceland ///
    	            Ireland Italy Latvia Lithuania Luxembourg Netherlands ///
    	            Norway Poland Portugal Slovakia Slovenia Spain Sweden ///
    	            UnitedKingdom // 26 countries
            }
        }
        else {
            if "`test'" == "circ5" {
                local countries Austria Belgium Bulgaria Croatia Cyprus ///
    	            CzechRepublic Denmark Estonia Finland France Germany ///
    	            Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
    	            Luxembourg Malta Norway Poland Portugal ///
    	            Romania Slovakia Spain Sweden Switzerland ///
    	            UnitedKingdom // 29 countries
                    // the Netherlands and Slovenia do not have information on population density
            }
            else {
                local countries Austria Belgium Bulgaria Croatia Cyprus ///
    	            CzechRepublic Denmark Estonia Finland France Germany ///
    	            Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
    	            Luxembourg Malta Netherlands Norway Poland Portugal ///
    	            Romania Slovakia Slovenia Spain Sweden Switzerland ///
    	            UnitedKingdom // 31 countries
            }
        }

        foreach country in `countries' {
            use "$maindir/IOPK-data/eusilc20`year'_`country'", clear

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

            gen couple = ppartner != .

            egen nadults = total(pageend > 17), by(hid)
            gen children = (hsize - nadults) > 0

            **************************************Age***************************************

            if "`test'" == "older" {
                drop if pageend < 45 | pageend > 59
            }
            else {
                drop if pageend < 30 | pageend > 59
            }

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

            **********************************Urbanisation**********************************

            if "`test'" == "circ5" {
               drop if hurb == .
               gen rural = hurb == 3
            }

            ***********************************Education************************************

            gen edulevel = 1 if pedulevel >= 0 & pedulevel <= 2
            replace edulevel = 2 if pedulevel == 3 | pedulevel == 4
            replace edulevel = 3 if pedulevel == 5 | pedulevel == 6
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
            }
            if `year' == 11 {
                **2011 includes the value "-1 = don't know"**
                drop if pedumother == -1
                drop if pedufather == -1

                **Creating levels of education for both parents**
                gen eduparents = 1 if pedumother <= 1 | pedufather <= 1
                replace eduparents = 2 if pedumother == 2 | pedufather == 2
                replace eduparents = 3 if pedumother == 3 | pedufather == 3
            }
            drop if eduparents == .

            ***********************************Occupation************************************

            if country == "Malta" & year == 2011 { // has different coding in 'poccup'
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
               (country == "Ireland" & `year' == 11) {
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
                gen occuparents = 1 if pgrpoccumother == 1 | pgrpoccufather == 1
                replace occuparents = 2 if pgrpoccumother == 2 | pgrpoccufather == 2
                replace occuparents = 3 if pgrpoccumother == 3 | pgrpoccufather == 3
                drop if occuparents >= .
            }
            else {
                gen occuparents = .
            }

            ************************************Incomes*************************************

            replace pyemplncashg = 0 if pyemplncashg == .
            replace pyemplncashn = 0 if pyemplncashn == .
            // some countries do not have pyemplncash

            *Activity status before income generation*
            if "`test'" == "noheck" {
                if `year' == 05 {
                    keep if pmthftjob > 6 | pmthptjob > 6
                }
                else {
                    keep if pmthftjobemp > 6 | pmthftjobself > 6 | pmthptjobemp > 6 | pmthptjobself > 6
                }
                // only employees and self-employed who worked full- or part-time during 7 or more months
            }
            if "`test'" == "employees" {
                keep if pemplystatus == 3
                // keep only employees
            }

            *Personal labor income*
            if country == "France" | country == "Greece" | country == "Italy" | ///
               country == "Latvia" | country == "Portugal" | country == "Spain" {
                   gen income = pyemplcashn + pyemplncashn + pyselfempln
            }
            else {
                gen income = pyemplcashg + pyemplncashg + pyselfemplg
            }
            if "`test'" == "noheck" {
                drop if income <= 0 | income >= .
            }
            quietly sum income [w=pcsw], d
            replace income = r(p99) if income > r(p99) & income < .
            gen lnincome = ln(income)

            *Activity status after income generation*
            if "`test'" == "fulltime" {
                if `year' == 05 {
                    gen intoemplmnt = (pmthftjob > 6) & ///
                                      (income > 0 & income < .)
                }
                else {
                    gen intoemplmnt = (pmthftjobemp > 6 | pmthftjobself > 6) & ///
                                      (income > 0 & income < .)
                }
                // full-time workers during 7 or more months
            }
            else if "`test'" != "noheck" {
                if `year' == 05 {
                    gen intoemplmnt = (pmthftjob > 6 | pmthptjob > 6) & ///
                                      (income > 0 & income < .)
                }
                else {
                    gen intoemplmnt = (pmthftjobemp > 6 | pmthftjobself > 6 | pmthptjobemp > 6 | pmthptjobself > 6) & ///
                                      (income > 0 & income < .)
                }
                // employees and self-employed who worked full- or part-time during 7 or more months
                // (except with test==employees, in which case self-employed were removed earlier)
            }

            if "`test'" != "noheck" {
                if (country == "Bulgaria" & `year' == 11) | (country == "Finland" & `year' == 11) | ///
                   (country == "Ireland" & `year' == 11) {
                       heckman lnincome c.pageend c.pageend#c.pageend i.edulevel, ///
                           vce(robust) ///
                           select(intoemplmnt = i.female i.couple i.female#i.couple ///
                               i.children i.female#i.children i.immigrant)
                }
                else if ("`test'" == "older" & country == "Iceland" & year == 2005) | ///
                    ("`test'" == "older" & country == "Romania" & year == 2011) { // it doesn't converge with ML
                        heckman lnincome c.pageend c.pageend#c.pageend i.edulevel i.occulevel, ///
                            twostep ///
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
            }

            if "`test'" != "noK" {
                *Household pc gross capital income*
                if country == "France" | country == "Greece" | country == "Italy" | ///
                   country == "Latvia" | country == "Portugal" | country == "Spain" {
                       if "`test'" == "rentK" {
                           gen pckinc = hyproprentaln / nadults
                       }
                       else {
                           gen pckinc = (hyproprentaln + hykrentn) / nadults
                       }
                }
                else {
                    if "`test'" == "rentK" {
                        gen pckinc = hyproprentalg / nadults
                    }
                    else {
                        gen pckinc = (hyproprentalg + hykrentg) / nadults
                    }
                }
                drop if pckinc >= .

                *Dynastic measure of capital income*
                if (country == "Bulgaria" & `year' == 11) | (country == "Finland" & `year' == 11) | ///
                   (country == "Ireland" & `year' == 11) {
                       reg pckinc pageend c.pageend#c.pageend i.edulevel i.couple [w=pcsw]
                }
                else {
                    reg pckinc pageend c.pageend#c.pageend i.edulevel i.occulevel i.couple [w=pcsw]
                }
                predict pcdynkinc, residuals
                drop if pcdynkinc >= .

                if "`test'" == "prntscdf" {
                    tab eduparents, matcell(freq)
                    gen N = r(N)
                    svmat freq, names(matcol)
                    local cut2 = (freqc1[1]/N) * 100
                    local cut3 = ((freqc1[1]/N) + (freqc1[2]/N)) * 100

                    _pctile pckinc, p(.0000001)
                    local pckinccut1 = r(r1)
                    _pctile pckinc, p(`cut2')
                    local pckinccut2 = r(r1)
                    _pctile pckinc, p(`cut3')
                    local pckinccut3 = r(r1)

                    _pctile pcdynkinc, p(.0000001)
                    local pcdynkinccut1 = r(r1)
                    _pctile pcdynkinc, p(`cut2')
                    local pcdynkinccut2 = r(r1)
                    _pctile pcdynkinc, p(`cut3')
                    local pcdynkinccut3 = r(r1)
                }
                else if "`test'" == "000050" {
                    _pctile pckinc, p(.0000001)
                    local pckinccut1 = r(r1)
                    _pctile pckinc, p(.0000001)
                    local pckinccut2 = r(r1)
                    _pctile pckinc, p(50)
                    local pckinccut3 = r(r1)

                    _pctile pcdynkinc, p(.0000001)
                    local pcdynkinccut1 = r(r1)
                    _pctile pcdynkinc, p(.0000001)
                    local pcdynkinccut2 = r(r1)
                    _pctile pcdynkinc, p(50)
                    local pcdynkinccut3 = r(r1)
                }
                else if "`test'" == "005075" {
                    _pctile pckinc, p(.0000001)
                    local pckinccut1 = r(r1)
                    _pctile pckinc, p(50)
                    local pckinccut2 = r(r1)
                    _pctile pckinc, p(75)
                    local pckinccut3 = r(r1)

                    _pctile pcdynkinc, p(.0000001)
                    local pcdynkinccut1 = r(r1)
                    _pctile pcdynkinc, p(50)
                    local pcdynkinccut2 = r(r1)
                    _pctile pcdynkinc, p(75)
                    local pcdynkinccut3 = r(r1)
                }
                else {
                    _pctile pckinc, p(${cutoff1_`country'kinc})
                    local pckinccut1 = r(r1)
                    _pctile pckinc, p(${cutoff2_`country'kinc})
                    local pckinccut2 = r(r1)
                    _pctile pckinc, p(${cutoff3_`country'kinc})
                    local pckinccut3 = r(r1)

                    _pctile pcdynkinc, p(${cutoff1_`country'dynkinc})
                    local pcdynkinccut1 = r(r1)
                    _pctile pcdynkinc, p(${cutoff2_`country'dynkinc})
                    local pcdynkinccut2 = r(r1)
                    _pctile pcdynkinc, p(${cutoff3_`country'dynkinc})
                    local pcdynkinccut3 = r(r1)
                }

                **Generating levels of pc gross capital income of households**
                gen kinc = pckinc < `pckinccut1'
                replace kinc = 2 if pckinc >= `pckinccut1' & pckinc < `pckinccut2'
                replace kinc = 3 if pckinc >= `pckinccut2' & pckinc < `pckinccut3'
                replace kinc = 4 if pckinc >= `pckinccut3' & pckinc < .
                **Generating levels of pc dynastic gross capital income of households**
                gen	dynkinc = pcdynkinc < `pcdynkinccut1'
                replace dynkinc = 2 if pcdynkinc >= `pcdynkinccut1' & pcdynkinc < `pcdynkinccut2'
                replace dynkinc = 3 if pcdynkinc >= `pcdynkinccut2' & pcdynkinc < `pcdynkinccut3'
                replace dynkinc = 4 if pcdynkinc >= `pcdynkinccut3' & pcdynkinc < .
            }

            ****************************Estimating inequalities****************************

            *Defining types*
            local minobs 10

            gen type_b = .
            local type 1
            forvalues i = 0/1 {
                if "`test'" == "circ3" {
                    forvalues p = 1/3 {
                        if country != "Sweden" {
                            forvalues z = 1/3 {
                                replace type_b = `type' if female == `i' & eduparents == `p' & occuparents == `z'
                                la de type_b `type' "`i'`p'`z'", modify
                                local ++type
                            }
                        }
                        else {
                            replace type_b = `type' if female == `i' & eduparents == `p'
                            la de type_b `type' "`i'`p'", modify
                            local ++type
                        }
                    }
                }
                else {
                    forvalues k = 0/1 {
                        forvalues p = 1/3 {
                            if country != "Sweden" {
                                forvalues z = 1/3 {
                                    if "`test'" == "circ5" {
                                        forvalues j = 0/1 {
                                            replace type_b = `type' if female == `i' & immigrant == `k' & eduparents == `p' & occuparents == `z' & rural == `j'
                                            la de type_b `type' "`i'`k'`p'`z'`j'", modify
                                            local ++type
                                        }
                                    }
                                    else {
                                        replace type_b = `type' if female == `i' & immigrant == `k' & eduparents == `p' & occuparents == `z'
                                        la de type_b `type' "`i'`k'`p'`z'", modify
                                        local ++type
                                    }
                                }
                            }
                            else {
                                if "`test'" == "circ5" {
                                    forvalues j = 0/1 {
                                        replace type_b = `type' if female == `i' & immigrant == `k' & eduparents == `p' & rural == `j'
                                        la de type_b `type' "`i'`k'`p'`j'", modify
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
                }
            }
            la val type_b type_b
            drop if type_b == .

            foreach kvar in $kvars {
                gen type_`kvar' = .
                local type 1
                forvalues i = 0/1 {
                    if "`test'" == "circ3" {
                        forvalues p = 1/4 {
                            replace type_`kvar' = `type' if female == `i' & `kvar' == `p'
                            la de type_`kvar' `type' "`i'`p'", modify
                            local ++type
                        }
                    }
                    else {
                        forvalues k = 0/1 {
                            if "`test'" == "noK" {
                                replace type_`kvar' = `type' if female == `i' & immigrant == `k'
                                la de type_`kvar' `type' "`i'`k'", modify
                                local ++type
                            }
                            else {
                                forvalues p = 1/4 {
                                    if "`test'" == "circ5" {
                                        forvalues j = 0/1 {
                                            replace type_`kvar' = `type' if female == `i' & immigrant == `k' & `kvar' == `p' & rural == `j'
                                            la de type_`kvar' `type' "`i'`k'`p'`j'", modify
                                            local ++type
                                        }
                                    }
                                    else {
                                        replace type_`kvar' = `type' if female == `i' & immigrant == `k' & `kvar' == `p'
                                        la de type_`kvar' `type' "`i'`k'`p'", modify
                                        local ++type
                                    }
                                }
                            }
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

                *IOP*
                *w/ baseline circumstances*
                tempvar ytypes_b
                gen `ytypes_b' = .
                forvalues n = 1/36 {
                    sum income if type_b == `n', meanonly
                    replace `ytypes_b' = r(mean) if type_b == `n' & r(N) >= `minobs'
                }
                if "`test'" == "gini" {
                    fastgini `ytypes_b'
                    local stat gini
                }
                else {
                    fastmld `ytypes_b'
                    local stat ge0
                }
                if `i' == 1 {
                    mat define iop_b = (r(`stat'))
                }
                else {
                    mat define iop_b = (iop_b \ r(`stat'))
                }
                *w/ capital circumstances*
                foreach kvar in $kvars {
                    tempvar ytypes_k
                    gen `ytypes_k' = .
                    forvalues n = 1/16 {
                        sum income if type_`kvar' == `n', meanonly
                        replace `ytypes_k' = r(mean) if type_`kvar' == `n' & r(N) >= `minobs'
                    }
                    if "`test'" == "gini" {
                        fastgini `ytypes_k'
                    }
                    else {
                        fastmld `ytypes_k'
                    }
                    if `i' == 1 {
                        mat define iop_`kvar' = (r(`stat'))
                    }
                    else {
                        mat define iop_`kvar' = (iop_`kvar' \ r(`stat'))
                    }
                }
                restore
            }

            matrix colnames iop_b = "_mld"
            svmat iop_b, names(matcol)
            sum iop_b_mld
            gen eabt_b = r(mean)
            gen eabtSE_b = r(sd)
            drop iop_b_mld

            foreach kvar in $kvars {
                preserve
                matrix colnames iop_`kvar' = "_mld"
                svmat iop_`kvar', names(matcol)
                sum iop_`kvar'_mld
                gen eabt_k = r(mean)
                gen eabtSE_k = r(sd)
                drop iop_`kvar'_mld

                collapse (firstnm) year country ///
                    eabt_b eabtSE_b ///
                    eabt_k eabtSE_k, ///
                    fast
                tempfile `country'`year'`kvar'`test'
            	save ``country'`year'`kvar'`test''
            	restore
            }
        }
    }

    foreach kvar in $kvars {
        clear
        foreach year in `years' {

            if `year' == 05 {
                if "`test'" == "circ5" {
                    local countries Austria Belgium Cyprus CzechRepublic Denmark ///
        	            Estonia Finland France Germany Greece Hungary Iceland ///
        	            Ireland Italy Latvia Lithuania Luxembourg ///
        	            Norway Poland Portugal Slovakia Spain Sweden ///
        	            UnitedKingdom // 24 countries
                        // the Netherlands and Slovenia do not have information on population density
                }
                else {
                    local countries Austria Belgium Cyprus CzechRepublic Denmark ///
        	            Estonia Finland France Germany Greece Hungary Iceland ///
        	            Ireland Italy Latvia Lithuania Luxembourg Netherlands ///
        	            Norway Poland Portugal Slovakia Slovenia Spain Sweden ///
        	            UnitedKingdom // 26 countries
                }
            }
            else {
                if "`test'" == "circ5" {
                    local countries Austria Belgium Bulgaria Croatia Cyprus ///
        	            CzechRepublic Denmark Estonia Finland France Germany ///
        	            Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
        	            Luxembourg Malta Norway Poland Portugal ///
        	            Romania Slovakia Spain Sweden Switzerland ///
        	            UnitedKingdom // 29 countries
                        // the Netherlands and Slovenia do not have information on population density
                }
                else {
                    local countries Austria Belgium Bulgaria Croatia Cyprus ///
        	            CzechRepublic Denmark Estonia Finland France Germany ///
        	            Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
        	            Luxembourg Malta Netherlands Norway Poland Portugal ///
        	            Romania Slovakia Slovenia Spain Sweden Switzerland ///
        	            UnitedKingdom // 31 countries
                }
            }

            foreach country in `countries' {
                append using ``country'`year'`kvar'`test''
            }
    	}

        replace year = year - 1
    	compress
    	save IOPK_`kvar'_`test', replace
    }
}

foreach kvar in $kvars {
    foreach test in `tests' {
        local years 2004 2010
        foreach year in `years' {
            use IOPK_`kvar'_`test', clear

            keep if year == `year'
            sum eabt_b, meanonly
            local meanb_`test'_`year'_`kvar' = r(mean)
            sum eabt_k, meanonly
            local meank_`test'_`year'_`kvar' = r(mean)
            local meansrt_`test'_`year'_`kvar' = `meanb_`test'_`year'_`kvar''/`meank_`test'_`year'_`kvar''
            sum eabtSE_b, meanonly
            local SEb_`test'_`year'_`kvar' = r(mean)
            sum eabtSE_k, meanonly
            local SEk_`test'_`year'_`kvar' = r(mean)
            local SErt_`test'_`year'_`kvar' = `SEb_`test'_`year'_`kvar''/`SEk_`test'_`year'_`kvar''
            pwcorr eabt_b eabt_k, listwise
            local corr_`test'_`year'_`kvar' = r(rho)
            spearman eabt_b eabt_k
            local rk_`test'_`year'_`kvar' = r(rho)
        }
    }
}

foreach test in `tests' {
    matrix robustness = (`meanb_`test'_2004_dynkinc',`meanb_`test'_2010_dynkinc',`meanb_`test'_2004_kinc',`meanb_`test'_2010_kinc' \ ///
                         `meank_`test'_2004_dynkinc',`meank_`test'_2010_dynkinc',`meank_`test'_2004_kinc',`meank_`test'_2010_kinc' \ ///
                         `meansrt_`test'_2004_dynkinc',`meansrt_`test'_2010_dynkinc',`meansrt_`test'_2004_kinc',`meansrt_`test'_2010_kinc' \ ///
                         `SEb_`test'_2004_dynkinc',`SEb_`test'_2010_dynkinc',`SEb_`test'_2004_kinc',`SEb_`test'_2010_kinc' \ ///
                         `SEk_`test'_2004_dynkinc',`SEk_`test'_2010_dynkinc',`SEk_`test'_2004_kinc',`SEk_`test'_2010_kinc' \ ///
                         `SErt_`test'_2004_dynkinc',`SErt_`test'_2010_dynkinc',`SErt_`test'_2004_kinc',`SErt_`test'_2010_kinc' \ ///
                         `corr_`test'_2004_dynkinc',`corr_`test'_2010_dynkinc',`corr_`test'_2004_kinc',`corr_`test'_2010_kinc' \ ///
                         `rk_`test'_2004_dynkinc',`rk_`test'_2010_dynkinc',`rk_`test'_2004_kinc',`rk_`test'_2010_kinc')

    matrix rownames robustness = "\ \ Average baseline IOP" "\ \ Average capital IOP" "\ \ Ratio of averages" ///
                                 "\addl \ \ Average baseline SE" "\ \ Average capital SE" "\ \ Ratio of average SEs" ///
                                 "\addl \ \ Pairwise correlation" "\ \ Rank correlation"

    esttab matrix(robustness, fmt(%6.5f)) using iopk_robustness_`test'.tex, replace ///
        nomtitles booktabs collabels(none) f nolines
}
