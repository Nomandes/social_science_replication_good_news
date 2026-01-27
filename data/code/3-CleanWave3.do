/*====================================================================
  Project: 	Good News Is Not a Sufficient Condition for Motivated Reasoning
  Do-file:  3-CleanWave3.do
  Purpose:  Clean Wave 3 data
  Inputs:   data/wave3_raw.csv
  Outputs:  data/wave3.dta
====================================================================*/

cls
clear all
set more off
set scheme s2color  // use Stata 17 scheme

import delimited "data/wave3_raw.csv", varnames(1) bindquote(strict) clear


forval q=1/3 {
    gen prob_true`q' = .
    forval i=0/10 {
        replace prob_true`q' = `i'/10 if strpos(q`q'_news, "`i'/10 chance it is True")
    }

    gen message_greater`q' = (news`q' == "greater than")
    gen message_less`q' = (news`q' == "less than")
}

*** Drop subjects who fail AI or attention check ***

keep if progress == 100
keep if strpos(lower(q64), "apple")
rename v147 pass_attention
keep if pass_attention == 1


*** Survey for happy/motivated reasoning questions ***

rename moreas_goodnews moreas_good
rename happy_goodnews happy_good
rename moreas_politics moreas_pol
rename happy_politics happy_pol

gen moreas_pol_bin = (strpos(moreas_pol, "their political party") > 0) - (strpos(moreas_pol, "opposing political party") > 0) if moreas_pol != ""

gen happy_pol_bin = (strpos(happy_pol, "their political party") > 0) - (strpos(happy_pol, "opposing political party") > 0) if happy_pol != ""

gen moreas_perf_bin = (strpos(moreas_perf, "better") > 0) - (strpos(moreas_perf, "worse") > 0) if moreas_perf != ""


gen happy_perf_bin = (strpos(happy_perf, "better") > 0) - (strpos(happy_perf, "worse") > 0) if happy_perf != ""

gen moreas_good_bin = (strpos(moreas_good, "better") > 0) - (strpos(moreas_good, "worse") > 0) if moreas_good != ""


gen happy_good_bin = (strpos(happy_good, "better") > 0) - (strpos(happy_good, "worse") > 0) if happy_good != ""

*** Mean levels for each ***
mean moreas*bin
mean happy*bin


*** Happy survey 5-point Likert scale ***

gen happy_good_5 = .
replace happy_good_5 = 1 if (strpos(happy_good, "worse") > 0 & strpos(happy_good, "Much") > 0)
replace happy_good_5 = 2 if (strpos(happy_good, "worse") > 0 & strpos(happy_good, "Slightly") > 0)
replace happy_good_5 = 3 if (strpos(happy_good, "About equal") > 0)
replace happy_good_5 = 4 if (strpos(happy_good, "better") > 0 & strpos(happy_good, "Slightly") > 0)
replace happy_good_5 = 5 if (strpos(happy_good, "better") > 0 & strpos(happy_good, "Much") > 0)


gen happy_pol_5 = .
replace happy_pol_5 = 1 if (strpos(happy_pol, "opposing political party") > 0 & strpos(happy_pol, "Much") > 0)
replace happy_pol_5 = 2 if (strpos(happy_pol, "opposing political party") > 0 & strpos(happy_pol, "Slightly") > 0)
replace happy_pol_5 = 3 if (strpos(happy_pol, "About equal") > 0)
replace happy_pol_5 = 4 if (strpos(happy_pol, "their political party") > 0 & strpos(happy_pol, "Slightly") > 0)
replace happy_pol_5 = 5 if (strpos(happy_pol, "their political party") > 0 & strpos(happy_pol, "Much") > 0)


gen happy_perf_5 = .
replace happy_perf_5 = 1 if (strpos(happy_perf, "worse") > 0 & strpos(happy_perf, "Much") > 0)
replace happy_perf_5 = 2 if (strpos(happy_perf, "worse") > 0 & strpos(happy_perf, "Slightly") > 0)
replace happy_perf_5 = 3 if (strpos(happy_perf, "About equal") > 0)
replace happy_perf_5 = 4 if (strpos(happy_perf, "better") > 0 & strpos(happy_perf, "Slightly") > 0)
replace happy_perf_5 = 5 if (strpos(happy_perf, "better") > 0 & strpos(happy_perf, "Much") > 0)


*** Zodiac question ***

forval q=1/3 {
    gen zodiac_agree`q' = (likert_q_`q' == "Strongly agree" | likert_q_`q' == "Agree") if likert_q_`q' != ""
}
gen zodiac_agree_any = (zodiac_agree1 | zodiac_agree2 | zodiac_agree3)
gen zodiac_agree_num = zodiac_agree1 + zodiac_agree2 + zodiac_agree3

forval i=1/3 {
    gen zodiac_likert`i' = .
    replace zodiac_likert`i' = 0 if likert_q_`i' == "Strongly disagree"
    replace zodiac_likert`i' = 1/4 if likert_q_`i' == "Disagree"
    replace zodiac_likert`i' = 1/2 if likert_q_`i' == "Neither agree nor disagree"
    replace zodiac_likert`i' = 3/4 if likert_q_`i' == "Agree"
    replace zodiac_likert`i' = 1 if likert_q_`i' == "Strongly agree"
}
gen zodiac_likert_avg = (zodiac_likert1 + zodiac_likert2 + zodiac_likert3) / 3


reshape long prob_true message_greater message_less, i(prolific_pid) j(topic_id)


drop if zodiac == ""

gen solution = .
replace solution = 46.12 if strpos(zodiac, "Aries") > 0 & topic_id == 2
replace solution = 42.86 if strpos(zodiac, "Taurus") > 0 & topic_id == 2
replace solution = 43.70 if strpos(zodiac, "Gemini") > 0 & topic_id == 2
replace solution = 45.64 if strpos(zodiac, "Cancer") > 0 & topic_id == 2
replace solution = 44.35 if strpos(zodiac, "Leo") > 0 & topic_id == 2
replace solution = 46.07 if strpos(zodiac, "Virgo") > 0 & topic_id == 2
replace solution = 47.34 if strpos(zodiac, "Libra") > 0 & topic_id == 2
replace solution = 41.94 if strpos(zodiac, "Scorpio") > 0 & topic_id == 2
replace solution = 45.31 if strpos(zodiac, "Sagittarius") > 0 & topic_id == 2
replace solution = 46.60 if strpos(zodiac, "Capricorn") > 0 & topic_id == 2
replace solution = 49.32 if strpos(zodiac, "Aquarius") > 0 & topic_id == 2
replace solution = 46.88 if strpos(zodiac, "Pisces") > 0 & topic_id == 2


*** Demographics ***

rename edu education
gen edu_temp = .
replace edu_temp = 11 if education == "Did not graduate high school"
replace edu_temp = 12 if education == "High school graduate, diploma, or equivalent (such as GED)"
replace edu_temp = 13 if education == "Began college, no degree"
replace edu_temp = 14 if education == "Associate's degree"
replace edu_temp = 16 if education == "Bachelor's degree"
replace edu_temp = 18 if education == "Postgraduate or professional degree"
bysort responseid: egen edu = max(edu_temp)
drop education

gen male = (gender == "Male")

gen democrat = (party == "Strongly Democratic" | party == "Weakly Democratic")
gen republican = (party == "Strongly Republican" | party == "Weakly Republican")

drop consent

save "data/wave3", replace

