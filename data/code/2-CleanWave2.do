/*====================================================================
  Project: 	Good News Is Not a Sufficient Condition for Motivated Reasoning
  Do-file:  2-CleanWave2.do
  Purpose:  Clean Wave 2 data
  Inputs:   data/wave2_raw.csv
  Outputs:  data/wave2.dta
====================================================================*/

cls
clear all
set more off

import delimited "data/wave2_raw.csv", varnames(1) bindquote(strict) clear

rename participant* *
drop playerpayoff
rename player* *
rename _* *

rename subsessionround_number round_number

sort time_started round_number

drop feedback1 feedback2

drop if current_page != "Results"
drop if index_in_pages != 57

gen message_greater = (message == "greater than")
gen message_less = (message == "less than")

**** Demographics ****

gen democrat_temp = (party == "Democrat")
gen republican_temp = (party == "Republican")
gen independent_temp = (party == "Independent")
bysort code: egen democrat = max(democrat_temp)
bysort code: egen republican = max(republican_temp)
bysort code: egen independent = max(independent_temp)

rename ideology ideology_temp
gen ideology_n_temp = .
replace ideology_n_temp = -3 if ideology_temp == "Extremely liberal"
replace ideology_n_temp = -2 if ideology_temp == "Liberal"
replace ideology_n_temp = -1 if ideology_temp == "Slightly liberal"
replace ideology_n_temp = 0 if ideology_temp == "Moderate"
replace ideology_n_temp = 1 if ideology_temp == "Slightly conservative"
replace ideology_n_temp = 2 if ideology_temp == "Conservative"
replace ideology_n_temp = 3 if ideology_temp == "Extremely conservative"
bysort code: egen ideology = max(ideology_n_temp)

gen female_temp = (gender == "Female")
gen male_temp = (gender == "Male")
bysort code: egen female = max(female_temp)
bysort code: egen male = max(male_temp)

gen white_temp = (race == "White")
gen black_temp = (race == "Black or African American")
gen asian_temp = (race == "Asian")
gen latino_temp = (race == "Hispanic or Latino")
bysort code: egen white = max(white_temp)
bysort code: egen black = max(black_temp)
bysort code: egen asian = max(asian_temp)
bysort code: egen latino = max(latino_temp)

rename age age_temp
bysort code: egen age = max(age_temp)
gen age_low = (age < 40)
gen age_mid = (age >= 40 & age < 60)
gen age_high = (age >= 60)

gen religious_group_temp = 0
replace religious_group_temp = 1 if religion != "" & religion != "Unaffiliated" & religion != "Agnostic" & religion != "Atheist"
bysort code: egen religious_group = max(religious_group_temp)

gen edu_temp = .
replace edu_temp = 11 if education == "Did not graduate high school"
replace edu_temp = 12 if education == "High school graduate or GED"
replace edu_temp = 13 if education == "Began college, no degree"
replace edu_temp = 14 if education == "Associate's degree"
replace edu_temp = 16 if education == "Bachelor's degree"
replace edu_temp = 18 if education == "Postgraduate or professional degree"
bysort code: egen edu = max(edu_temp)
drop education

gen inc_temp = .
replace inc_temp = 10 if income == "Less than $20,000"
replace inc_temp = 20 if income == "$20,000 to $29,999"
replace inc_temp = 35 if income == "$30,000 to $39,999"
replace inc_temp = 45 if income == "$40,000 to $49,999"
replace inc_temp = 60 if income == "$50,000 to $69,999"
replace inc_temp = 85 if income == "$70,000 to $99,999"
replace inc_temp = 125 if income == "$100,000 to $149,999"
replace inc_temp = 250 if income == "$150,000 or more"
bysort code: egen inc = max(inc_temp)
gen log_inc = log(inc*1000)

gen prob_true_10 = prob_true
replace prob_true = prob_true / 10

gen true_news = (veracity == "True" | veracity == "TRUE")
gen fake_news = (veracity == "Fake")


*** Drop subjects who give impossible answers ***

gen failed_check_temp = (guess_points + news_points < 200 & topic_id == 6)
bysort code: egen failed_check_new = max(failed_check_temp)

gen out_of_range_q = 0
replace out_of_range_q = 1 if (your_lower < 0 | your_reguess < 0)
replace out_of_range_q = 1 if topic_id == 1 & (your_upper >= 10000 | your_reguess >= 10000)
replace out_of_range_q = 1 if topic_id == 2 & (your_upper >= 20000 | your_reguess >= 20000)
replace out_of_range_q = 1 if topic_id == 3 & (your_upper > 10 | your_reguess > 10)
replace out_of_range_q = 1 if topic_id == 4 & (your_upper >= 100000 | your_reguess >= 100000)
replace out_of_range_q = 1 if topic_id == 5 & (your_upper > 90 | your_reguess > 90)
replace out_of_range_q = 1 if topic_id == 6 & (your_upper != 2019 | your_lower != 2019 | (your_reguess != 2019 & your_reguess != .))
replace out_of_range_q = 1 if topic_id == 7 & (your_upper > 100 | your_reguess > 100)

bysort code: egen out_of_range = sum(out_of_range_q)

sort code round_number

*** Generate second-guess measures ***

gen change_guess = your_reguess - your_answer if topic_id != 6

gen change_message_dir = (change_guess > 0) if message_greater
replace change_message_dir = (change_guess < 0) if message_less
gen change_message_opp = (change_guess < 0) if message_greater
replace change_message_opp = (change_guess > 0) if message_less
gen change_message_zero = (change_guess == 0) if message_greater + message_less
gen change_message_net = change_message_dir - change_message_opp

gen change_correct_bin = change_message_dir - change_message_opp if true_news == 1 & message_greater + message_less
replace change_correct_bin = change_message_opp - change_message_dir if true_news == 0 & message_greater + message_less


gen wave = 2

drop if failed_check_new
drop if out_of_range > 0


save "data/wave2", replace

