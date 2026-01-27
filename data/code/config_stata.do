clear all
set more off

local ssc_packages "cdfplot" "coefplot" "egenmore" "erepost" "estout" "reghdfe" "addplot"

foreach package in "`ssc_packages'" {
	* check if package is installed; if not, install with ssc
	capture which `package'
	if _rc == 111 {                 
	   dis "Installing `package'"
	   ssc install `package', replace
	   }
}

set scheme s2color
