/*====================================================================
  Project: 	Good News Is Not a Sufficient Condition for Motivated Reasoning
  Do-file:  1-Master.do
  Purpose:  Master file
====================================================================*/

******************************
*****  1. Master Do-File *****
******************************

** Change the username and root folder here to your Stata username and the
* directory in which you placed the folder.
* Stata will automatically set the global

global good_news_insufficient ""

if "`c(username)'"=="" {      //Change username here
    global good_news_insufficient ""     //Change folder here
}
if "`c(username)'"=="mthaler" {
    global good_news_insufficient "/Users/mthaler/Dropbox/good-news-insufficient"
    cd "/Users/mthaler/Dropbox/good-news-insufficient"
}


di "$good_news_insufficient"


* Install packages (can comment out after first run)
do code/config_stata.do 

* Clean data
* Input: wave2_raw.csv. Output: wave2.dta
do code/2-CleanWave2.do
* Input: wave3_raw.csv. Output: wave3.dta
do code/3-CleanWave3.do
* Note: Wave 1 comes from an already-cleaned file, wave1.dta

// * Create figures + tables
* Input: wave1.dta, wave2.dta, wave3.dta. Output: Main experiment tables, figures, and numbers
do code/4-AnalysisMain.do
* Input: wave3.dta. Output: Survey figures and numbers
do code/5-AnalysisSurvey.do

