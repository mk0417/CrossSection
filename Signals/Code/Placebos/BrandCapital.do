* BrandCapital
* not shown to predict in OP
* --------------

// DATA LOAD
use gvkey permno time_avail_m fyear datadate xad xad0 at using "$pathDataIntermediate/a_aCompustat", clear

// SIGNAL CONSTRUCTION
xtset gvkey fyear

gen byte OK = !missing(xad)
bys gvkey OK (fyear): gen BrandCapital = xad/(.5 + .1) if OK==1 & _n==1
bys gvkey OK (fyear): gen tempYear = fyear if OK==1 & _n==1
egen FirstNMyear = min(tempYear), by(gvkey)

gen tempxad = xad
replace tempxad = 0 if mi(xad)  

replace BrandCapital = 0 if mi(BrandCapital)
xtset gvkey fyear
by gvkey: replace BrandCapital = (1-.5)*l.BrandCapital + tempxad if _n > 1
replace BrandCapital = . if mi(FirstNMyear) | fyear < FirstNMyear
replace BrandCapital = . if mi(xad) 

replace BrandCapital = BrandCapital/at

drop OK temp* FirstNM

label var BrandCapital "Brand Capital"

* Expand to monthly
gen temp = 12
expand temp
drop temp

gen tempTime = time_avail_m
bysort gvkey tempTime: replace time_avail_m = time_avail_m + _n - 1 

drop tempTime
bysort gvkey time_avail_m (datadate): keep if _n == _N 
bysort permno time_avail_m: keep if _n == 1  // deletes a few observations

// SAVE
do "$pathCode/saveplacebo" BrandCapital