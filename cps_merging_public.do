*********************************************************************************
********** CUPID - LINK COUPLES *************************************************
************created by Hansini Munasinghe ***************************************
***************as part of Crossnativity Partnering and Politics Project (2020)***
*********************************************************************************

*********************************************************************************
* This code uses data from the Current Population Survey (IPUMS), and
* creates a new dataset linking head of the household to their married or cohabiting partners
* adapted from code shared by Rosenfeld- https://web.stanford.edu/~mrosenfe/merging_to_create_couples.htm

* Step 1: create one dataset with head of households only
* Step 2: create another dataset of spouses/partners only
* Step 3: join the two datasets based on unique identifier - cupid

/*
How is a record uniquely identified? 
	Two variables constitute a unique identifier for each household record in the IPUMS-CPS:
	YEAR and SERIAL (year and household serial number).

	Three variables constitute a unique identifier for each person record in the IPUMS-CPS:
	YEAR, SERIAL, and PERNUM (year, household serial number, and person serial number). */

**********************************************************************************
*Step 0: Housekeeping
set more off
cap log close
cd "C:\data_analysis\"

*open data set (previously cleaned and variables recoded, as needed)
use "C:\data_analysis\cps_clean.dta", clear


**********************************************************************************
*Step 1: create one dataset with head of households only

keep if relate == 101

*include a flag to indicate spouse vs partners
/*rename variables used in analysis ending with "_hh" to show "head of household"
rename age age_hh
rename woman woman_hh
*/

*generate unique identifier - cupid
gen str20 cupid=string(year, "%-4.0f")+string(month, "%-02.0f")+string(serial, "%-05.0f")
sort cupid
*quietly by cupid:  gen dup = cond(_N==1,0,_n) //check for duplicates
*tab dup
duplicates report cupid
bysort cupid: gen copies=_N
browse if copies>1
*duplicates drop cupid, force
drop copies 

*save dataset with heads of household only
save "cps_hh.dta", replace 
clear all

*********************************************************************************
*Step 2: create another dataset of spouses/partners

*open original data
use "C:\Users\hansi\OneDrive - University of Iowa\Immigration and Intermarriage\data_analysis\CPS\cps_clean.dta", clear

*keep if relate == spouses & partners
keep if relate==201 | relate==1114 // 201=spouse; 1114=unmarried partner
*note: distinction between same sex vs opposite sex spouse/partner starts in 2020 

*rename ending with _so to show "significant other" // rename all variables needed for analysis
rename age age_so
rename woman woman_so 

*only keep variables needed for analysis
keep serial year month var1_so var2_so

*create linking variable - cupid
gen str20 cupid=string(year, "%-4.0f")+string(month, "%-02.0f")+string(serial, "%-05.0f")
sort cupid

*check for and drop duplicates (for some reason in 2000 and 2002 there are duplicates of some SOs?)
duplicates report cupid
bysort cupid: gen copies=_N
browse if copies>1
duplicates drop cupid, force
drop copies

*save dataset with partners only
save "cps_so.dta", replace
*clear all

***********************************************************************************
* Step 3: Merge two datasets

*open head of households again
*use "cps_hh.dta", clear

*merge cupid using cps_hh
merge 1:1 cupid using "cps_hh.dta"
tab _merge // check for partners without heads of household. Find out why?

*keep only couples
keep if _merge ==3

drop _merge cupid

save "cps_merged", replace
*********************************************************************************
STOP


