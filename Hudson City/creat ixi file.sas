data _null_;
file 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\for_ixi.txt' dsd dlm='09'x lrecl=4096;
set hudson.clean_20121106;
put PTYPE	stype	sbu_new	ZIP	LAT	LONG	DOB	CURR_BAL	pseudo_hh;
run;
