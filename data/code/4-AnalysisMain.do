/*====================================================================
  Project: 	Good News Is Not a Sufficient Condition for Motivated Reasoning
  Do-file:  4-AnalysisMain.do
  Purpose:  Run main experimental analyses; export core figures and tables for the paper.
  Inputs:   data/wave1.dta, data/wave2.dta, data/wave3.dta
  Outputs:  Figure 1, Figure 2, Appendix Figure 4, Table 1, Appendix Table 3, Balance
====================================================================*/

cls
clear all
set more off
set scheme s2color  // use Stata 17 scheme

use "data/wave2.dta", clear

append using "data/wave1.dta"

replace wave = 1 if wave == .


* wave == 1 <-> issue_id <= 30
* wave == 2 <-> 30 < issue_id <= 40
* wave == 3 <-> issue_id > 40

replace issue_id = topic_id+30 if wave == 2  


*** Make labels consistent for waves 1-2 ***

rename *good* *pro*
rename *bad* *anti*

rename positive_high good_high
rename negative_high bad_high
rename positive_news good_news
rename negative_news bad_news




append using "data/wave3.dta"



replace issue_id = topic_id + 40 if zodiac != "" 
replace wave = 3 if issue_id >= 40 & issue_id != . 

replace code = responseid if wave == 3


replace your_answer = q2_median if issue_id == 42
replace your_answer = q3_median if issue_id == 43


replace logit_prob = log(prob_true) - log(1-prob_true) if prob_true > 0 & prob_true < 1 ///
& (message_greater | message_less)
replace logit_prob = log(.05) - log(.95) if prob_true == 0 & (message_greater | message_less)
replace logit_prob = log(.95) - log(.05) if prob_true == 1 & (message_greater | message_less)

drop good_high bad_high good_news bad_news


*** classify questions by whether higher/lower answers are "Good News"
gen good_high = (issue_id == 5 | issue_id == 6 | issue_id == 9 | issue_id == 10 | issue_id == 33 | issue_id == 42)
gen bad_high = (issue_id == 2 | issue_id == 3 | issue_id == 4 | issue_id == 31 | issue_id == 32 | issue_id == 34)
gen neutral_topic = (topic == "Latitude" | issue_id == 43)

gen good_news = 0
replace good_news = message_greater if good_high == 1
replace good_news = message_less if bad_high == 1
gen bad_news = 0
replace bad_news = message_less if good_high == 1
replace bad_news = message_greater if bad_high == 1


***** RESULTS *****



**********
* Tables *
**********

*** Table 1: Main specification ***

eststo clear

label var prob_true "P(True)"
label var good_news "Good News"
label var true_news "True News"
label var bad_news  "Bad News \hspace{35mm}"

label var pro_news  "Pro-Party News"
label var anti_news "Anti-Party News"

local controls "age male edu"

reghdfe prob_true good_news `controls' if good_news + bad_news == 1, absorb(issue_id) cluster(code)
eststo spec1
qui sum prob_true if good_news + bad_news == 1
estadd scalar Mean = `r(mean)'
estadd scalar Participants = e(N_clust)

reghdfe prob_true good_news if good_news + bad_news == 1, absorb(issue_id code) cluster(code)
eststo spec2
qui sum prob_true if good_news + bad_news == 1
estadd scalar Mean = `r(mean)'
estadd scalar Participants = e(N_clust)

reghdfe prob_true good_news pro_news `controls' if good_news + bad_news == 1 & pro_news + anti_news == 1, absorb(issue_id) cluster(code)
eststo spec3
qui sum prob_true if good_news + bad_news == 1 & pro_news + anti_news == 1
estadd scalar Mean = `r(mean)'
estadd scalar Participants = e(N_clust)

reghdfe prob_true good_news pro_news if good_news + bad_news == 1 & pro_news + anti_news == 1, absorb(issue_id code) cluster(code)
eststo spec4
qui sum prob_true if good_news + bad_news == 1 & pro_news + anti_news == 1
estadd scalar Mean = `r(mean)'
estadd scalar Participants = e(N_clust)

test pro_news = good_news // compare coefficients from good news and pro-party news

reghdfe change_message_net good_news `controls' if good_news + bad_news == 1, absorb(issue_id) cluster(code)
eststo spec5
qui sum change_message_net if good_news + bad_news == 1
estadd scalar Mean = `r(mean)'
estadd scalar Participants = e(N_clust)

reghdfe change_message_net good_news if good_news + bad_news == 1, absorb(issue_id code) cluster(code)
eststo spec6
qui sum change_message_net if good_news + bad_news == 1
estadd scalar Mean = `r(mean)'
estadd scalar Participants = e(N_clust)

reghdfe change_message_net good_news pro_news `controls' if good_news + bad_news == 1 & pro_news + anti_news == 1, absorb(issue_id) cluster(code)
eststo spec7
qui sum change_message_net if good_news + bad_news == 1 & pro_news + anti_news == 1
estadd scalar Mean = `r(mean)'
estadd scalar Participants = e(N_clust)

reghdfe change_message_net good_news pro_news if good_news + bad_news == 1 & pro_news + anti_news == 1, absorb(issue_id code) cluster(code)
eststo spec8
qui sum change_message_net if good_news + bad_news == 1 & pro_news + anti_news == 1
estadd scalar Mean = `r(mean)'
estadd scalar Participants = e(N_clust)

estfe spec*, labels(issue_id "Question FE" code "Participant FE")


esttab spec* using "tables/table1.tex", ///
    se label b(3) noconstant nostar ///
    nodepvars ///
    mlabels(none) ///
    posthead("&\multicolumn{4}{c}{Dep Var: News Assessment}&\multicolumn{4}{c}{Dep Var: Changing Guesses}\\ \hline") ///
    scalars(Participants Mean) sfmt(%9.0f %9.3f) drop(_cons) ///
    varwidth(20) wrap compress nogap replace ///
    indicate(`r(indicate_fe)' "Participant controls = `controls'")


estfe, restore
eststo clear



*** Appendix Table 3: Logit specification for trust in news ***

label var logit_prob "Logit(P(True))"
label var good_news "Good News"
label var true_news "True News"
label var bad_news "Bad News \hspace{35mm}"

label var pro_news "Pro-Party News \hspace{35mm}"
label var anti_news "Anti-Party News"

local controls "age male edu"

reghdfe logit_prob good_news `controls' if good_news + bad_news == 1, absorb(issue_id) cluster(code)
eststo spec1
qui sum logit_prob if good_news + bad_news == 1
estadd scalar Mean = `r(mean)'
estadd scalar Participants = e(N_clust)

reghdfe logit_prob good_news if good_news + bad_news == 1, absorb(issue_id code) cluster(code)
eststo spec2
qui sum logit_prob if good_news + bad_news == 1
estadd scalar Mean = `r(mean)'
estadd scalar Participants = e(N_clust)

reghdfe logit_prob good_news pro_news `controls' if good_news + bad_news == 1 & pro_news + anti_news == 1, absorb(issue_id) cluster(code)
eststo spec3
qui sum logit_prob if good_news + bad_news == 1 & pro_news + anti_news == 1
estadd scalar Mean = `r(mean)'
estadd scalar Participants = e(N_clust)

reghdfe logit_prob good_news pro_news if good_news + bad_news == 1 & pro_news + anti_news == 1, absorb(issue_id code) cluster(code)
eststo spec4
qui sum logit_prob if good_news + bad_news == 1 & pro_news + anti_news == 1
estadd scalar Mean = `r(mean)'
estadd scalar Participants = e(N_clust)

estfe spec*, labels(issue_id "Question FE" round_number "Round FE" code "Participant FE")

esttab spec* using "tables/appendix_table3.tex", ///
    se lab b(3) noconstant nostar ///
    scalars(Participants Mean) sfmt(%9.0f %9.3f) drop("_cons") ///
    varwidth(20) wrap compress nomtitles nogap replace ///
    indicate(`r(indicate_fe)' "Participant controls = `controls'")

estfe, restore
eststo clear



***********
* Figures *
***********

*** Figure 1: CDF plots ***
** Figure 1a
cdfplot prob_true if good_news + bad_news == 1, by(good_news) ///
    opt1( lc(red black) ) opt2( lp(dot dot) ) graphregion(fcolor(white)) ///
    legend(order(2 "Good News" 1 "Bad News" )) xtitle("Belief About P(True News)") ytitle("Share of responses") ///
name(good_bad_cdf, replace)
graph export "figures/figure1a.png", replace

** Figure 1b
cdfplot prob_true if pro_news + anti_news == 1, by(pro_news) ///
    opt1( lc(red black) ) opt2( lp(dot dot) ) graphregion(fcolor(white)) ///
    legend(order(2 "Pro-Party/Self News" 1 "Anti-Party/Self News" )) xtitle("Belief About P(True News)") ytitle("Share of responses") ///
name(pro_anti_cdf, replace)
graph export "figures/figure1b.png", replace


*** Figure 2: Heterogeneity in direction ***

* create binary variables at the median
gen older = (age>32) if age != .
gen college = (edu>13) if edu != .
gen richer = (inc >= 50) if inc != .


foreach demo in republican democrat older male white college richer religious_group {
    gen good_`demo' = good_news * `demo'
    reghdfe prob_true good_`demo' good_news if good_news + bad_news == 1, ///
    absorb(round_number topic_id code) cluster(code)
    eststo het_`demo'
}


gen too_good = .
replace too_good = (your_answer > solution) if good_high == 1 & your_answer != .
replace too_good = (your_answer < solution) if bad_high == 1 & your_answer != .

gen too_bad = .
replace too_bad = (your_answer < solution) if good_high == 1 & your_answer != .
replace too_bad = (your_answer > solution) if bad_high == 1 & your_answer != .

gen political_issue = (issue_id <= 8 | issue_id == 10 | issue_id == 11 | issue_id == 14) if message_greater + message_less == 1

gen too_pro_party = .
replace too_pro_party = (your_answer > solution) if rep_high == 1 & pro_rep == 1 & your_answer != .
replace too_pro_party = (your_answer > solution) if rep_high == -1 & pro_dem == 1 & your_answer != .
replace too_pro_party = (your_answer < solution) if rep_high == 1 & pro_dem == 1 & your_answer != .
replace too_pro_party = (your_answer < solution) if rep_high == -1 & pro_rep == 1 & your_answer != .

reghdfe prob_true pro_news_party age male edu if pro_news_party + anti_news_party == 1 & too_pro_party == 1, absorb(issue_id) cluster(code)

reghdfe prob_true pro_news_party age male edu if pro_news_party + anti_news_party == 1 & too_pro_party == 0, absorb(issue_id) cluster(code)

gen too_pro_ego = .
replace too_pro_ego = (your_answer > solution) if issue_id == 13 & your_answer != .

reghdfe prob_true pro_news_ego age male edu if pro_news_ego + anti_news_ego == 1 & too_pro_ego == 1, absorb(issue_id) cluster(code)

reghdfe prob_true pro_news_ego age male edu if pro_news_ego + anti_news_ego == 1 & too_pro_ego == 0, absorb(issue_id) cluster(code)

gen good_political = good_news * political_issue
gen good_nonpolitical = good_news * (1-political_issue)

gen good_too_good = good_news * too_good if good_news + bad_news == 1 & political_issue == 0
gen good_too_bad = good_news * too_bad if good_news + bad_news == 1 & political_issue == 0

gen happy_self = (happy7 == "Completely happy" | happy7 == "Very happy") if happy7 != ""
mean too_good if happy_self == 1 & issue_id == 42, cluster(code)
mean too_good if happy_self == 0 & issue_id == 42, cluster(code)


* pro-party/anti-party and pro-performance/anti-performance for comparisons
reghdfe prob_true pro_news_party age male edu if pro_news_party + anti_news_party == 1, absorb(issue_id) cluster(code)
reghdfe prob_true pro_news_ego age male edu if pro_news_ego + anti_news_ego == 1, absorb(issue_id) cluster(code)


* create figure
reghdfe prob_true good_political good_nonpolitical if good_news + bad_news == 1, ///
absorb(issue_id) cluster(code)
eststo het_issue

reghdfe prob_true good_too_good good_too_bad if good_news + bad_news == 1, ///
absorb(issue_id) cluster(code)
eststo het_prior

reghdfe prob_true good_republican good_democrat good_older good_male  ///
good_white good_college good_richer good_religious_group ///
good_news republican democrat older male white college richer religious_group if good_news + bad_news == 1, ///
absorb(issue_id) cluster(code)
eststo het_horserace

reghdfe prob_true good_news if good_news + bad_news == 1, absorb(issue_id) cluster(code)
eststo main_effect

lab var good_news "Good News"
lab var good_political "Good News x Political"
lab var good_nonpolitical "Good News x Nonpolitical"
lab var good_too_good "Good News x Prior Good"
lab var good_too_bad "Good News x Prior Bad"
lab var good_republican "Good News x Republican"
lab var good_democrat "Good News x Democrat"
lab var good_older "Good News x Older"
lab var good_male "Good News x Male"
lab var good_white "Good News x White"
lab var good_college "Good News x College"
lab var good_richer "Good News x High Income"
lab var good_religious_group "Good News x Religious"

coefplot ///
(main_effect, keep(good_news) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_prior, keep(good_too_good) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_prior, keep(good_too_bad) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_older) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_male) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_white) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_college) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_richer) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_republican) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_democrat) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_religious_group) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_issue, keep(good_political) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_issue, keep(good_nonpolitical) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
, offset(0) drop(rep_news *round* *_dummy *topic_id* _Icode* _cons) xline(0) ///
xline(.0479946, lcolor(green) lpattern(dash)) xline(.0798209, lcolor(purple) lpattern(shortdash)) ///
xscale(r(-.15 .15)) xlabel(-.15 (.05) .15, labsize(small)) ///
ylabel(, labsize(small)) ///
mlabposition(6) mlabsize(3) mlabcolor("0 0 0") xtitle("Effect of Good vs. Bad News on P(True)", size(small)) ///
headings(good_news = "{bf:Overall Effect}" good_political = "{bf:Issue Type}" good_too_good = "{bf:Prior Belief}" good_older = "{bf:Demographics}", labsize(small)) ///
legend(off) ///
graphregion(fcolor(white)) ///
ysize(4.5) ///
name(heterogeneity, replace)

graph export "figures/figure2.png", replace

eststo clear



*** Appendix Table 4: Heterogeneity using logit spec ***

* pro-party/anti-party and pro-performance/anti-performance for comparisons
reghdfe logit_prob pro_news_party age male edu if pro_news_party + anti_news_party == 1, absorb(issue_id) cluster(code)
reghdfe logit_prob pro_news_ego age male edu if pro_news_ego + anti_news_ego == 1, absorb(issue_id) cluster(code)

* create figure
reghdfe logit_prob good_political good_nonpolitical if good_news + bad_news == 1, ///
absorb(issue_id) cluster(code)
eststo het_issue

reghdfe logit_prob good_too_good good_too_bad if good_news + bad_news == 1, ///
absorb(issue_id) cluster(code)
eststo het_prior

reghdfe logit_prob good_republican good_democrat good_older good_male  ///
good_white good_college good_richer good_religious_group ///
good_news republican democrat older male white college richer religious_group if good_news + bad_news == 1, ///
absorb(issue_id) cluster(code)
eststo het_horserace

reghdfe logit_prob good_news if good_news + bad_news == 1, absorb(issue_id) cluster(code)
eststo main_effect

lab var good_news "Good News"
lab var good_political "Good News x Political"
lab var good_nonpolitical "Good News x Nonpolitical"
lab var good_too_good "Good News x Prior Good"
lab var good_too_bad "Good News x Prior Bad"
lab var good_republican "Good News x Republican"
lab var good_democrat "Good News x Democrat"
lab var good_older "Good News x Older"
lab var good_male "Good News x Male"
lab var good_white "Good News x White"
lab var good_college "Good News x College"
lab var good_richer "Good News x High Income"
lab var good_religious_group "Good News x Religious"

coefplot ///
(main_effect, keep(good_news) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_prior, keep(good_too_good) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_prior, keep(good_too_bad) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_older) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_male) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_white) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_college) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_richer) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_republican) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_democrat) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_religious_group) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_issue, keep(good_political) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_issue, keep(good_nonpolitical) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
, offset(0) drop(rep_news *round* *_dummy *topic_id* _Icode* _cons) xline(0) ///
xline(.25321, lcolor(green) lpattern(dash)) xline(.4218564, lcolor(purple) lpattern(shortdash)) ///
xscale(r(-.75 .75)) xlabel(-.75 (.25) .75, labsize(small)) ///
ylabel(, labsize(small)) ///
mlabposition(6) mlabsize(3) mlabcolor("0 0 0") xtitle("Effect of Good vs. Bad News on Logit(P(True))", size(small)) ///
headings(good_news = "{bf:Overall Effect}" good_political = "{bf:Issue Type}" good_too_good = "{bf:Prior Belief}" good_older = "{bf:Demographics}", labsize(small)) ///
legend(off) ///
graphregion(fcolor(white)) ///
ysize(4.5) ///
name(heterogeneity_logit, replace)

graph export "figures/appendix_figure4.png", replace

eststo clear


*** Balance Table (note that column 3-4 names are changed manually) *** 

preserve

lab var male "Male"
lab var age "Age"
lab var edu "Education"
lab var log_inc "Log(Income)"
lab var democrat "Democrat"
lab var republican "Republican"
lab var white "White"
lab var black "Black"
lab var latino "Latino"
lab var asian "Asian"
lab var religious_group "Religious"

orth_out male age edu log_inc democrat republican white black latino asian religious_group ///
    if good_news + bad_news == 1 using "tables/balance.tex", by(good_news) ///
    se compare test count latex full replace ///
    armlabel("Bad News" "Good News")

restore


************
* Raw data *
************

* raw data for good vs. bad
mean prob_true if good_news+bad_news == 1, over(good_news) vce(cluster code) 
reg prob_true i.good_news if good_news+bad_news == 1, vce(cluster code) 

* KS differences in distributions
ksmirnov prob_true if good_news + bad_news == 1, by(good_news) 
ksmirnov prob_true if pro_news + anti_news == 1, by(pro_news)

* raw data for prior beliefs
mean too_bad if good_news + bad_news == 1, vce(cluster code)
mean too_pro_party if pro_news_party + anti_news_party == 1, vce(cluster code)
mean too_pro_ego if issue_id==13, vce(cluster code)

* heterogeneity by prior beliefs
reg prob_true i.good_news if good_news+bad_news == 1 & political_issue==0 & too_good==1, vce(cluster code)
reg prob_true i.good_news if good_news+bad_news == 1 & political_issue==0 & too_good==0, vce(cluster code)

reg prob_true i.pro_news_party if pro_news_party + anti_news_party == 1 & too_pro_party==1, vce(cluster code)
reg prob_true i.pro_news_party if pro_news_party + anti_news_party == 1 & too_pro_party==0, vce(cluster code)

reg prob_true i.pro_news_ego if pro_news_ego + anti_news_ego == 1 & too_pro_ego==1, vce(cluster code)
reg prob_true i.pro_news_ego if pro_news_ego + anti_news_ego == 1 & too_pro_ego==0, vce(cluster code)

* separately for wave 3 good vs. bad news
reg prob_true i.good_news if good_news+bad_news == 1 & issue_id==42, vce(cluster code)

mean too_good if good_news+bad_news == 1 & issue_id==42, vce(cluster code)
reg prob_true i.good_news if good_news+bad_news == 1 & issue_id==42 & too_good==1, vce(cluster code)

* effect of own happiness on priors and belief updating
reg too_good happy_self if good_news+bad_news == 1 & issue_id==42, vce(cluster code)
reg prob_true i.good_news i.happy_self 1.happy_self#1.good_news if good_news+bad_news == 1 & issue_id==42, vce(cluster code) 

