te

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\new_targets.csv';


Data BBSEG.TARGETS_NEW;
length HHID $ 9 TARGET_NEW $ 1;
infile myfile DLM=',' firstobs=1 lrecl=4096;
Input HHID $
      TARGET_NEW $;
run;


data tempu;
set BBSEG.HHDATA_NEW (drop=TARGET_NEW);
run;

proc sort data = tempu;
by HHID;
run;


proc sort data=BBSEG.TARGETS_NEW;
by HHID;
run;


data tempx;
merge tempu BBSEG.TARGETS_NEW;
by HHID;
run;


data BBSEG.HHDATA_NEW;
set tempx;
run;

data temp1;
set BBSEG.TRDATA_CLEAN;
drop TARGET_NEW;
run;

proc sort data=temp1;
by HHID;
run;


data tempz;
merge temp1 BBSEG.TARGETS_NEW;
by HHID;
run;


data BBSEG.TRDATA_CLEAN;
set tempz;
run;




data temp1;
set BBSEG.PROD_DATA_CLEAN;
drop TARGET_NEW;
run;

proc sort data=temp1;
by HHID;
run;


data tempz;
merge temp1 BBSEG.TARGETS_NEW;
by HHID;
run;


data BBSEG.PROD_DATA_CLEAN;
set tempz;
run;

proc freq data=BBSEG.PROD_DATA_CLEAN;
tables target_new /nocol norow nopercent;
run;

proc freq data=BBSEG.TRDATA_CLEAN;
tables target_new /nocol norow nopercent;
run;

proc freq data=BBSEG.HHDATA_NEW;
tables target_new /nocol norow nopercent;
run;
