
////////////////////////////////////////////////////////////////////////////////
/////////////////////IOPK with EU-SILC - Auxiliary programs/////////////////////
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

capture program drop addnchoosek
		program define addnchoosek
		forvalues r = 1(1)`2' {
			local temp = exp(lnfactorial(`1')) / (exp(lnfactorial(`1' - `r')) * exp(lnfactorial(`r')))
			local groups = `groups' + `temp'
		}
		local groupings : display %3.0f round(`groups' + 1)
		di "The number of groups is `groupings'."
		local A : display %3.2f (`groupings' + 1) / (3600 * 24 * 365)
		di "If it takes 1 sec to process each combination, it would be done in `A' years."
		local B : display %3.2f `A' / 1000000
		di "If it takes a millionth (0.000001) of a sec to compute each combination, it would be done in `B' years."
end
