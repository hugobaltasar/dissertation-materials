
////////////////////////////////////////////////////////////////////////////////
/////////////////////Longitudinal-IOP with EU-SILC - Graphs/////////////////////
////////////////////////////////////////////////////////////////////////////////

cd "$maindir"
capture mkdir ./Longitudinal-IOP-output/
cd ./Longitudinal-IOP-output/

set scheme s1mono
colorpalette cblind, select(3/8) nograph
global c1 `r(p6)'
global c2 `r(p5)'
global c3 `r(p4)'
global c4 `r(p3)'
global c5 `r(p2)'
global c6 `r(p1)'

**********************************Evolution*************************************

local kvars dynkinc meandynkinc
foreach kvar in `kvars' {
    use "$maindir/Longitudinal-IOP-data/Longitudinal-IOP_`kvar'", clear

    local countrieshigh Austria Bulgaria Cyprus ///
     	Estonia Iceland Ireland Latvia Luxembourg ///
    	Malta Netherlands Norway Portugal Romania Switzerland ///
    	UnitedKingdom
    local countrieslow Belgium Croatia CzechRepublic Denmark Finland France ///
    	Greece Hungary Italy Lithuania Poland Slovakia ///
    	Slovenia Spain Sweden

    local scale .8

    local graphslist
    foreach country in `countrieshigh' {
        if "`country'" == "Luxembourg" | "`country'" == "Switzerland" {
                local upr 0.09
                local gap .03
        }
        else {
            local upr .07
            local gap .02
        }
        preserve
        qui keep if country == "`country'"
        twoway (rarea eabtUL eabtLL year, astyle(ci)) ///
            (line eabt year, color("$c1") lpattern(solid)), ///
            title(`country', color(black)) yti("") xti("") ///
            plotregion(m(b=0)) ylabel(0(`gap')`upr', grid) yscale(r(0 `upr')) ///
            xlabel(2006(3)2016) ///
            scale(`scale') ///
            legend(off) name(g`country', replace) nodraw
        local graphslist "`graphslist' g`country'"
        restore
    }
    graph combine `graphslist', col(4) ysize(19) xsize(20)
    graph export long_evoabs_high_`kvar'.png, replace width(5000)

    local graphslist
    foreach country in `countrieslow' {
        if "`country'" == "Croatia" | "`country'" == "CzechRepublic" | ///
            "`country'" == "Greece" | "`country'" == "Hungary" | ///
            "`country'" == "Lithuania" {
                local upr .07
                local gap .02
        }
        else {
            local upr .035
            local gap .01
        }
        preserve
        quietly keep if country == "`country'"
        twoway (rarea eabtUL eabtLL year, astyle(ci)) ///
        	  (line eabt year, color("$c1") lpattern(solid)), ///
        	  title(`country', color(black)) yti("") xti("") ///
        	  plotregion(m(b=0)) ylabel(0(`gap')`upr', grid) yscale(r(0 `upr')) ///
              xlabel(2006(3)2016) ///
              scale(`scale') ///
        	  legend(off) name(g`country', replace) nodraw
        local graphslist "`graphslist' g`country'"
        restore
    }
    graph combine `graphslist', col(4) ysize(19) xsize(20)
    graph export long_evoabs_low_`kvar'.png, replace width(5000)

    local graphslist
    local upr .3
    foreach country in `countrieshigh' {
       preserve
       quietly keep if country == "`country'"
       twoway (rarea eabtRUL eabtRLL year, astyle(ci)) ///
    		  (line eabtR year, color("$c1") lpattern(solid)), ///
    		  title(`country', color(black)) yti("") xti("") ///
    		  plotregion(m(b=0)) ylabel(0(.1)`upr', grid) yscale(r(0 `upr')) ///
              xlabel(2006(3)2016) ///
              scale(`scale') ///
    		  legend(off) name(g`country', replace) nodraw
       local graphslist "`graphslist' g`country'"
       restore
    }
    graph combine `graphslist', col(4) ysize(19) xsize(20)
    graph export long_evorel_high_`kvar'.png, replace width(5000)

    local graphslist
    local upr .2
    foreach country in `countrieslow' {
       preserve
       quietly keep if country == "`country'"
       twoway (rarea eabtRUL eabtRLL year, astyle(ci)) ///
    		  (line eabtR year, color("$c1") lpattern(solid)), ///
    		  title(`country', color(black)) yti("") xti("") ///
    		  plotregion(m(b=0)) ylabel(0(.1)`upr', grid) yscale(r(0 `upr')) ///
              xlabel(2006(3)2016) ///
              scale(`scale') ///
    		  legend(off) name(g`country', replace) nodraw
       local graphslist "`graphslist' g`country'"
       restore
    }
    graph combine `graphslist', col(4) ysize(19) xsize(20)
    graph export long_evorel_low_`kvar'.png, replace width(5000)
}
