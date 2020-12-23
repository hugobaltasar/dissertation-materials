

////////////////////////////////////////////////////////////////////////////////
////////////////////Longitudinal-IOP with EU-SILC - Algorithm///////////////////
////////////////////////////////////////////////////////////////////////////////

*Path to the files produced by the algorithm of chapter 4*
cd "$algodir"

local combinations 0

local countries Austria Belgium Bulgaria Croatia Cyprus ///
    CzechRepublic Denmark Estonia Finland France ///
    Greece Hungary Iceland Ireland Italy Latvia Lithuania ///
    Luxembourg Malta Netherlands Norway Poland Portugal ///
    Romania Slovakia Slovenia Spain Sweden Switzerland ///
    UnitedKingdom // 30 countries
foreach country in `countries' {
    local d`country'kinc .
    local d`country'dynkinc .
}

local kvars kinc dynkinc

foreach pctile1 of numlist .00000001 5(5)95 {
    foreach pctile2 of numlist .0000001 5(5)95 {
        foreach pctile3 of numlist .000001 5(5)95 {

            if `pctile1' < `pctile2' & `pctile2' < `pctile3' {

                foreach kvar in `kvars' {
                    use "`kvar'_`pctile1'_`pctile2'_`pctile3'.dta", clear

                    local years 2004 2010
                    foreach year in `years' {

                        qui include "$codedir/countrieslist_algorithm.do"

                        foreach country in `countries' {
                            preserve
                            keep if year == `year'
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
                                local t`country'`kvar' = ``country'2010`kvar''
                        }
                        else {
                            local t`country'`kvar' = ``country'2004`kvar'' + ``country'2010`kvar''
                        }

                        if `t`country'`kvar'' < `d`country'`kvar'' {
                            local d`country'`year'`kvar' = `t`country'`year'`kvar''
                            global cutoff1_`country'`kvar' = `pctile1'
                            global cutoff2_`country'`kvar' = `pctile2'
                            global cutoff3_`country'`kvar' = `pctile3'
                        }
                    }
                }
            }
        }
    }
}
