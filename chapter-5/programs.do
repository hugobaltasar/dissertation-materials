
////////////////////////////////////////////////////////////////////////////////
///////////////Longitudinal-IOP with EU-SILC - Auxiliary programs///////////////
////////////////////////////////////////////////////////////////////////////////

capture program drop fastmld
        program define fastmld, rclass
        syntax varlist(max=1) [if] [in] [aweight fweight]
        preserve
        quietly {
            marksample touse
            keep if `touse'
            sum `varlist' [`weight'`exp'], meanonly
            tempvar mld
            gen `mld' = ln(r(mean) / `varlist')
            sum `mld' [`weight'`exp'], meanonly
            return scalar N = r(N)
            return scalar ge0 = r(mean)
        }
        restore
end
