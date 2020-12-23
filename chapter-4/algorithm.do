
////////////////////////////////////////////////////////////////////////////////
//////////////////////////IOPK with EU-SILC - Algorithm/////////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir/IOPK-data"
capture mkdir ./algorithm/
cd ./algorithm/
global algodir : pwd

local combinations 0

local countries Austria Belgium Bulgaria Croatia Cyprus ///
    CzechRepublic Denmark Estonia Finland France Germany ///
    Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
    Luxembourg Malta Netherlands Norway Poland Portugal ///
    Romania Slovakia Slovenia Spain Sweden Switzerland ///
    UnitedKingdom // 31 countries
foreach country in `countries' {
    local d`country'kinc .
    local d`country'dynkinc .
}

foreach pctile1 of numlist .00000001 5(5)95 {
    foreach pctile2 of numlist .0000001 5(5)95 {
        foreach pctile3 of numlist .000001 5(5)95 {

            if `pctile1' < `pctile2' & `pctile2' < `pctile3' {

                local years 05 11
                foreach year in `years' {

                    qui include "$codedir/countrieslist.do"

                    foreach country in `countries' {

                        if `combinations' < 1 {
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

                            **********************************Age groups************************************

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
                            if `year' == 05 {
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
                               (country == "Ireland" & `year' == 11) {
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
                            drop lnincome

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
                               (country == "Ireland" & `year' == 11) {
                                   reg pckinc pageend c.pageend#c.pageend i.edulevel i.couple [w=pcsw]
                        	}
                        	else {
                                reg pckinc pageend c.pageend#c.pageend i.edulevel i.occulevel i.couple [w=pcsw]
                        	}
                            predict pcdynkinc, residuals
                            drop if pcdynkinc >= .

                            tempfile `country'20`year'
                            save ``country'20`year''
                        }

                        use ``country'20`year'', clear

                        *Creating cutoffs in the capital income distribution*
                        *of the pckinc distribution*
                        _pctile pckinc, p(`pctile1')
                        local pckinccut1 = r(r1)
                        _pctile pckinc, p(`pctile2')
                        local pckinccut2 = r(r1)
                        _pctile pckinc, p(`pctile3')
                        local pckinccut3 = r(r1)
                        *of the pcdynkinc distribution*
                        _pctile pcdynkinc, p(`pctile1')
                        local pcdynkinccut1 = r(r1)
                        _pctile pcdynkinc, p(`pctile2')
                        local pcdynkinccut2 = r(r1)
                        _pctile pcdynkinc, p(`pctile3')
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

                        if `combinations' < 1 {
                            gen type_b = .
                			local type 1
                			forvalues i = 0/1 {
                				forvalues k = 0/1 {
                					forvalues p = 1/3 {
                						if country != "Sweden" {
                                            forvalues z = 1/3 {
                								replace type_b = `type' if female == `i' & immigrant == `k' & eduparents == `p' & occuparents == `z'
                                                local ++type
                							}
                                        }
                						else {
                							replace type_b = `type' if female == `i' & immigrant == `k' & eduparents == `p'
                    						local ++type
                						}
                					}
                				}
                			}
                            drop if type_b == .
                        }

                        foreach kvar in $kvars {
                            gen type_`kvar' = .
                            local type 1
                            forvalues i = 0/1 {
                                forvalues k = 0/1 {
                                    forvalues p = 1/4 {
                						replace type_`kvar' = `type' if female == `i' & immigrant == `k' & `kvar' == `p'
                						local ++type
                                    }
                                }
                            }
                            drop if type_`kvar' == .
                        }

                        *Bootstrap replications*
                        forvalues i = 1/$reps {
                            preserve
                            bsample, strata(hregion)

                            *IOP*
                            *w/ baseline circumstances*
                            if `combinations' < 1 {
                                tempvar ytypes_b
                                gen `ytypes_b' = .
                                forvalues n = 1/36 {
                                    sum income if type_b == `n', meanonly
                                    replace `ytypes_b' = r(mean) if type_b == `n' & r(N) >= `minobs'
                                }
                                fastmld `ytypes_b'
                                if `i' == 1 {
                                    mat define iop_b = (r(ge0))
                                }
                                else {
                                    mat define iop_b = (iop_b \ r(ge0))
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
                                }
                                else {
                                    mat define iop_`kvar' = (iop_`kvar' \ r(ge0))
                                }
                            }
                            restore
                        }

                        if `combinations' < 1 {
                            matrix colnames iop_b = "_mld"
                            svmat iop_b, names(matcol)
                            sum iop_b_mld
                            gen eabt_b = r(mean)
                            gen eabtSE_b = r(sd)
                            drop iop_b_mld
                        }

                        foreach kvar in $kvars {
                            preserve
                            matrix colnames iop_`kvar' = "_mld"
                            svmat iop_`kvar', names(matcol)
                            sum iop_`kvar'_mld
                            gen eabt_k = r(mean)
                            gen eabtSE_k = r(sd)
                            drop iop_`kvar'_mld

            			    distinct `kvar'
            			    gen ngroups = r(ndistinct)
                            if `combinations' < 1 {
                                collapse (firstnm) country year eabt_b eabt_k eabtSE_b eabtSE_k ngroups, fast
                            }
                            else {
                                collapse (firstnm) country year eabt_k eabtSE_k ngroups, fast
                            }
                            tempfile `country'20`year'_`kvar'
            				save ``country'20`year'_`kvar''
            				restore
                        }
                    }
                }
                foreach kvar in $kvars {
                    clear
                    foreach year in `years' {

                        qui include "$codedir/countrieslist.do"

                        foreach country in `countries' {
                            append using ``country'20`year'_`kvar''
                        }
                    }
                    if `combinations' < 1 {
                        preserve
                        keep country year eabt_b eabtSE_b
                        tempfile baseline
                        save `baseline'
                        restore
                    }
                    else {
                        merge 1:1 country year using `baseline', nogen
                    }
            		save "`kvar'_`pctile1'_`pctile2'_`pctile3'.dta", replace
                }
                foreach kvar in $kvars {
                    use "`kvar'_`pctile1'_`pctile2'_`pctile3'.dta", clear

                    foreach year in `years' {

                        qui include "$codedir/countrieslist.do"

                        foreach country in `countries' {
                            preserve
                            keep if year == 20`year'
                            keep if country == "`country'"

                            local `country'`year'`kvar' = (eabt_b - eabt_k)^2
                            sum ngroups, meanonly
                            local ng_`country'`year'`kvar' : display %5.4g r(mean)
                            restore
                        }
                    }

                    foreach country in `countries' {
                        if "`country'" == "Bulgaria" | "`country'" == "Croatia" | ///
                            "`country'" == "Malta" | "`country'" == "Romania" | ///
                            "`country'" == "Switzerland" {
                                local t`country'`kvar' = ``country'11`kvar''
                        }
                        else {
                            local t`country'`kvar' = ``country'05`kvar'' + ``country'11`kvar''
                        }

                        if `t`country'`kvar'' < `d`country'`kvar'' {
                            local d`country'`year'`kvar' = `t`country'`year'`kvar''
                            global cutoff1_`country'`kvar' = `pctile1'
                            global cutoff2_`country'`kvar' = `pctile2'
                            global cutoff3_`country'`kvar' = `pctile3'
                        }
                    }
                }
                local ++combinations
            }
        }
    }
}

cd "$maindir"
capture mkdir ./IOPK-output/
cd ./IOPK-output/

capture rm iopk_cdf.tex
foreach country in `countries' {
    matrix cdf_`country' = (${cutoff1_`country'dynkinc},${cutoff2_`country'dynkinc},${cutoff3_`country'dynkinc}, ///
        ${cutoff1_`country'kinc},${cutoff2_`country'kinc},${cutoff3_`country'kinc})

    if "`country'" == "CzechRepublic" {
	  matrix rownames cdf_`country' = "Czech R."
	}
	else if "`country'" == "UnitedKingdom" {
	  matrix rownames cdf_`country' = "United K."
	}
	else {
	  matrix rownames cdf_`country' = "`country'"
	}

    esttab matrix(cdf_`country', fmt(%3.0f)) using iopk_cdf.tex, append ///
        nomtitles nolines booktabs collabels(none) f
}

cd ../IOPK-data/algorithm/
capture file close combinations
file open combinations using combinations.txt, write replace
file write combinations "The number of combinations was `combinations'."
file close combinations

capture rm "__000005.dta"
