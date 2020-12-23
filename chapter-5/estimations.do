
////////////////////////////////////////////////////////////////////////////////
///////////////////Longitudinal-IOP with EU-SILC - Estimations//////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir/Longitudinal-IOP-data"

global years 07 08 09 10 11 12 13 14 15 16 17
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

        if country == "Malta" & `year' >= 15 | country == "Portugal" & `year' == 08 {
            replace pageend = year - pbirthyear
        }
        //need to run this now to use it when creating dummy for children

        gen couple = ppartner != .

        egen nadults = total(pageend > 17), by(year hid)
        gen children = (hsize - nadults) > 0

        **************************************Age***************************************

        drop if pageend < 30 | pageend > 59

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

        **************************Full panel cycle individuals**************************

        bys pid: gen periods = _n
        bys pid: egen periodsmax = max(periods)
        drop if periodsmax != 4

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
        qui sum income [w=pbw], d
        replace income = r(p99) if income > r(p99) & income < .
        by pid: egen meanincome = mean(income)
        gen lnmeanincome = ln(meanincome)

        *Household pc gross capital income*
        if country == "France" | country == "Greece" | country == "Italy" | ///
           country == "Latvia" | country == "Portugal" | country == "Spain" {
               gen pckinc = (hyproprentaln + hykrentn) / nadults
        }
        else {
            gen pckinc = (hyproprentalg + hykrentg) / nadults
        }
        drop if pckinc >= .

        by pid: egen meanpckinc = mean(pckinc)

        *Dynastic measure of capital income*
        *of last period's kinc*
        qui reg pckinc pageend c.pageend#c.pageend i.edulevel i.couple [w=pbw]
            // occulevel not included due to limited amount of observations
        predict pcdynkinc, residuals
        drop if pcdynkinc >= .
        *of average's kinc*
        qui reg meanpckinc pageend c.pageend#c.pageend i.edulevel i.couple [w=pbw]
        predict meanpcdynkinc, residuals
        drop if meanpcdynkinc >= .

        *Activity status*
        gen intoemplmnt = meanincome > 0 & meanincome < .

        keep if year == 20`year' // must come before heckman, but after meanpckinc

        heckman lnmeanincome c.pageend c.pageend#c.pageend i.edulevel, ///
            /*vce(robust)*/ twostep /// //ML doesn't converge
            select(intoemplmnt = i.female i.couple i.female#i.couple ///
                i.children i.female#i.children)
        predict yhat_h
        replace lnmeanincome = yhat_h if intoemplmnt == 0
        replace meanincome = exp(lnmeanincome)

        *Creating cutoffs in the capital income distribution*
        *of the pcdynkinc distribution*
        _pctile pcdynkinc, p(${cutoff1_`country'dynkinc})
        local pcdynkinccut1 = r(r1)
        _pctile pcdynkinc, p(${cutoff2_`country'dynkinc})
        local pcdynkinccut2 = r(r1)
        _pctile pcdynkinc, p(${cutoff3_`country'dynkinc})
        local pcdynkinccut3 = r(r1)

        *Generating levels of pc dynastic gross capital income of households*
        gen dynkinc = pcdynkinc < `pcdynkinccut1'
        replace dynkinc = 2 if pcdynkinc >= `pcdynkinccut1' & pcdynkinc < `pcdynkinccut2'
        replace dynkinc = 3 if pcdynkinc >= `pcdynkinccut2' & pcdynkinc < `pcdynkinccut3'
        replace dynkinc = 4 if pcdynkinc >= `pcdynkinccut3' & pcdynkinc < .

        *Creating cutoffs in the capital income distribution*
        *of the pcdynkinc distribution*
        _pctile meanpcdynkinc, p(${cutoff1_`country'dynkinc})
        local pcdynkinccut1 = r(r1)
        _pctile meanpcdynkinc, p(${cutoff2_`country'dynkinc})
        local pcdynkinccut2 = r(r1)
        _pctile meanpcdynkinc, p(${cutoff3_`country'dynkinc})
        local pcdynkinccut3 = r(r1)

        *Generating levels of pc dynastic gross capital income of households*
        gen meandynkinc = meanpcdynkinc < `pcdynkinccut1'
        replace meandynkinc = 2 if meanpcdynkinc >= `pcdynkinccut1' & meanpcdynkinc < `pcdynkinccut2'
        replace meandynkinc = 3 if meanpcdynkinc >= `pcdynkinccut2' & meanpcdynkinc < `pcdynkinccut3'
        replace meandynkinc = 4 if meanpcdynkinc >= `pcdynkinccut3' & meanpcdynkinc < .

        tempfile `country'`year'
        save ``country'`year''

        *****************************Estimating inequalities****************************

        local kvars dynkinc meandynkinc
        foreach kvar in `kvars' {

            use ``country'`year'', clear

            *Defining types*
            local minobs 10

            gen type = .
            local type 1
            forvalues i = 0/1 {
                forvalues p = 1/4 {
                    replace type = `type' if female == `i' & `kvar' == `p'
                    la de type `type' "`i'`p'", modify
                    local ++type
                }
            }
            la val type type
            drop if type == .

            *Bootstrap replications*
            forvalues i = 1/$reps {
                preserve
                bsample, strata(hregion)

                *Income inequality*
                keep if meanincome > 0 & meanincome < .
                fastmld meanincome
                if `i' == 1 {
                    mat define ii = (r(ge0))
                    mat define iiN = (r(N))
                }
                else {
                    mat define ii = (ii \ r(ge0))
                    mat define iiN = (iiN \ r(N))
                }

                *IOP*
                tempvar ytypes
                gen `ytypes' = .
                forvalues n = 1/8 {
                    sum meanincome if type == `n', meanonly
                    replace `ytypes' = r(mean) if type == `n' & r(N) >= `minobs'
                }
                fastmld `ytypes'
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
            qui sum ii_mld
            gen mld = r(mean)
            gen mldSE = r(sd)
            gen mldLL = r(mean) - 1.96 * r(sd)
            gen mldUL = r(mean) + 1.96 * r(sd)
            matrix colnames iiN = "_mld"
            svmat iiN, names(matcol)
            qui sum iiN_mld, meanonly
            gen mldN = round(r(mean))
            drop ii_mld iiN_mld

            matrix colnames iop = "_mld"
            svmat iop, names(matcol)
            qui sum iop_mld
            gen eabt = r(mean)
            gen eabtSE = r(sd)
            gen eabtLL = r(mean) - 1.96 * r(sd)
            gen eabtUL = r(mean) + 1.96 * r(sd)
            gen eabt_e = mld - eabt
            gen eabtR = eabt / mld
            gen eabtRLL = eabtLL / mld
            gen eabtRUL = eabtUL / mld
            matrix colnames iopN = "_mld"
            svmat iopN, names(matcol)
            qui sum iopN_mld, meanonly
            gen eabtN = round(r(mean))
            drop iop_mld iopN_mld

            collapse (firstnm) year country country_short ///
                mld mldSE mldLL mldUL mldN ///
                eabt eabtSE eabtLL eabtUL eabtN ///
                eabt_e eabtR eabtRLL eabtRUL, ///
                fast

            tempfile `country'`year'`kvar'
            save ``country'`year'`kvar''
        }
    }
}

foreach kvar in `kvars' {
    clear
    foreach year in $years {

        qui include "$codedir/countrieslist.do"

        foreach country in `countries' {
            append using ``country'`year'`kvar''
        }
    }

    replace year = year - 1
    compress
    save Longitudinal-IOP_`kvar', replace

}

capture rm "__000005.dta"
