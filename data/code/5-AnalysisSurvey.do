/*====================================================================
  Project: 	Good News Is Not a Sufficient Condition for Motivated Reasoning
  Do-file:  5-AnalysisSurvey.do
  Purpose:  Figures for Wave 3 survey data
  Inputs:   data/wave3.dta
  Outputs:  Figure 3
====================================================================*/

cls
clear all
set more off
set scheme s2color  // use Stata 17 scheme

use "data/wave3.dta", clear

*** Figure 3: Survey results ***
** Figure 3a

preserve

keep if topic_id == 1

* Create dummy indicators
gen var1 = (moreas_good_bin == -1) if moreas_good_bin != .  // motivated reasoning towards bad news
gen var2 = (moreas_good_bin == 0) if moreas_good_bin != .  // no valence motivated reasoning
gen var3 = (moreas_good_bin == 1) if moreas_good_bin != .  // motivated reasoning towards good news
gen var4 = (moreas_pol_bin == -1) if moreas_pol_bin != .  // motivated reasoning towards anti-party news
gen var5 = (moreas_pol_bin == 0) if moreas_pol_bin != .  // no political motivated reasoning
gen var6 = (moreas_pol_bin == 1) if moreas_pol_bin != .  // motivated reasoning towards pro-party news
gen var7 = (moreas_perf_bin == -1) if moreas_perf_bin != .  // motivated reasoning towards anti-performance news
gen var8 = (moreas_perf_bin == 0) if moreas_perf_bin != .  // no performance motivated reasoning
gen var9 = (moreas_perf_bin == 1) if moreas_perf_bin != .  // motivated reasoning towards pro-performance news

mean var*  // shares in each category

prtest var1 == var3  // test good vs. bad
prtest var4 == var6  // test pro-party vs. anti-party
prtest var7 == var9  // test pro-performance vs. anti-performance

prtest var3 == var6  // test good vs. pro-party
prtest var3 == var9  // test good vs. pro-performance


local vs var1 var2 var3 var4 var5 var6 var7 var8 var9

local sdlist
foreach v of local vs {
    local sdlist "`sdlist' sd_`v'=`v'"
}

collapse (mean) `vs' (sd) `sdlist' (count) N=var1
foreach v of local vs {
    gen se_`v'      = sd_`v' / sqrt(N)
    gen ci_lo_`v'   = `v' - invnormal(0.975)*se_`v'
    gen ci_hi_`v'   = `v' + invnormal(0.975)*se_`v'
}


forvalues i = 1/9 {
    rename var`i' share`i'
    rename se_var`i' se`i'
    rename ci_lo_var`i' lo`i'
    rename ci_hi_var`i' hi`i'
}

gen id = 1
reshape long share se lo hi, i(id) j(group)

* Label categories
label define vlab ///
    1 "Bad News"          ///
    2 "Similar News"      ///
    3 "Good News"         ///
    4 "Anti-Party"        ///
    5 "Similar Party"     ///
    6 "Pro-Party"         ///
    7 "Anti-Performance"  ///
    8 "Similar Performance" ///
    9 "Pro-Performance"
label values group vlab

gen plot_axis = .
replace plot_axis = 1 if group == 1
replace plot_axis = 1.8 if group == 2
replace plot_axis = 2.6 if group == 3
replace plot_axis = 4.2 if group == 4
replace plot_axis = 5 if group == 5
replace plot_axis = 5.8 if group == 6
replace plot_axis = 7.4 if group == 7
replace plot_axis = 8.2 if group == 8
replace plot_axis = 9 if group == 9

* Create graph
twoway ///
    (bar share plot_axis if inlist(group,1,4,7), ///
         barwidth(0.8) fcolor("140 70 30") lcolor(none))         ///
    (bar share plot_axis if inlist(group,2,5,8), ///
         barwidth(0.8) fcolor("150 150 150") lcolor(none))     ///
    (bar share plot_axis if inlist(group,3,6,9), ///
         barwidth(0.8) fcolor("0 110 140") lcolor(none))       ///
    (rcap lo hi plot_axis, lwidth(medium) lcolor(black)),       ///
    graphregion(fcolor(white))                                ///
    xscale(  r(0.4 9.6)  )                                     ///
    xlabel( 1 `" "Bad" "News" "'   ///
             1.8 "Similar"         ///
             2.6 `" "Good" "News" "' ///
             4.2 `" "Anti-" "Party" "' ///
             5 "Similar"          ///
             5.8 `" "Pro-" "Party" "' ///
             7.4 `" "Anti-" "Performance" "' ///
             8.2 "Similar"        ///
             9 `" "Pro-" "Performance" "' , ///
             labsize(small) )                                  ///
    yscale(  r(0 1) )                                          ///
    ylabel(0(.1)1)                                            ///
    xtitle("")                                                ///
    ytitle("Share of Responses")                             ///
    legend(off)                                                ///
    name(survey_moreas, replace)
graph export "figures/figure3a.png", replace

restore


** Figure 3b

preserve

keep if topic_id == 1

* Create dummy indicators
gen var1 = (happy_good_bin == -1) if happy_good_bin != .  // happier with bad news
gen var2 = (happy_good_bin == 0) if happy_good_bin != .  // happiness unrelated to valence
gen var3 = (happy_good_bin == 1) if happy_good_bin != .  // happier with good news
gen var4 = (happy_pol_bin == -1) if happy_pol_bin != .  // happier with anti-party news
gen var5 = (happy_pol_bin == 0) if happy_pol_bin != .  // happiness unrelated to party
gen var6 = (happy_pol_bin == 1) if happy_pol_bin != .  // happier with pro-party news
gen var7 = (happy_perf_bin == -1) if happy_perf_bin != .  // happier with anti-performance news
gen var8 = (happy_perf_bin == 0) if happy_perf_bin != .  // happiness unrelated to performance
gen var9 = (happy_perf_bin == 1) if happy_perf_bin != .  // happier with pro-performance news

mean var*  // shares in each category

prtest var1 == var3  // test good vs. bad
prtest var4 == var6  // test pro-party vs. anti-party
prtest var7 == var9  // test pro-performance vs. anti-performance

prtest var3 == var6  // test good vs. pro-party
prtest var3 == var9  // test good vs. pro-performance

gen happy_good_strong = (happy_good == "Much happier if it said that the world was a better place")
gen happy_pol_strong = (happy_pol == "Much happier if it said the answer was further in the direction of their political party")
gen happy_perf_strong = (happy_perf == "Much happier if it said that they performed better on this task")


prtest happy_good_strong == happy_pol_strong
prtest happy_good_strong == happy_perf_strong
prtest happy_pol_strong == happy_perf_strong


local vs var1 var2 var3 var4 var5 var6 var7 var8 var9

local sdlist
foreach v of local vs {
    local sdlist "`sdlist' sd_`v'=`v'"
}

collapse (mean) `vs' (sd) `sdlist' (count) N=var1

foreach v of local vs {
    gen se_`v'      = sd_`v' / sqrt(N)
    gen ci_lo_`v'   = `v' - invnormal(0.975)*se_`v'
    gen ci_hi_`v'   = `v' + invnormal(0.975)*se_`v'
}

forvalues i = 1/9 {
    rename var`i' share`i'
    rename se_var`i' se`i'
    rename ci_lo_var`i' lo`i'
    rename ci_hi_var`i' hi`i'
}

gen id = 1
reshape long share se lo hi, i(id) j(group)

* Label categories
label define vlab ///
    1 "Bad News"          ///
    2 "Similar News"      ///
    3 "Good News"         ///
    4 "Anti-Party"        ///
    5 "Similar Party"     ///
    6 "Pro-Party"         ///
    7 "Anti-Performance"  ///
    8 "Similar Performance" ///
    9 "Pro-Performance"
label values group vlab

gen plot_axis = .
replace plot_axis = 1 if group == 1
replace plot_axis = 1.8 if group == 2
replace plot_axis = 2.6 if group == 3
replace plot_axis = 4.2 if group == 4
replace plot_axis = 5 if group == 5
replace plot_axis = 5.8 if group == 6
replace plot_axis = 7.4 if group == 7
replace plot_axis = 8.2 if group == 8
replace plot_axis = 9 if group == 9

* Create graph
twoway ///
    (bar share plot_axis if inlist(group,1,4,7), ///
         barwidth(0.8) fcolor("140 70 30") lcolor(none))         ///
    (bar share plot_axis if inlist(group,2,5,8), ///
         barwidth(0.8) fcolor("150 150 150") lcolor(none))     ///
    (bar share plot_axis if inlist(group,3,6,9), ///
         barwidth(0.8) fcolor("0 110 140") lcolor(none))       ///
    (rcap lo hi plot_axis, lwidth(medium) lcolor(black)),       ///
    graphregion(fcolor(white))                                ///
    xscale(  r(0.4 9.6)  )                                     ///
    xlabel( 1 `" "Bad" "News" "'   ///
             1.8 "Similar"         ///
             2.6 `" "Good" "News" "' ///
             4.2 `" "Anti-" "Party" "' ///
             5 "Similar"          ///
             5.8 `" "Pro-" "Party" "' ///
             7.4 `" "Anti-" "Performance" "' ///
             8.2 "Similar"        ///
             9 `" "Pro-" "Performance" "' , ///
             labsize(small) )                                  ///
    yscale(  r(0 1) )                                          ///
    ylabel(0(.1)1)                                            ///
    xtitle("")                                                ///
    ytitle("Share of Responses")                             ///
    legend(off)                                                ///
    name(survey_happy, replace)
graph export "figures/figure3b.png", replace

restore
