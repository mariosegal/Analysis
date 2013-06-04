*read the purchased lona file, not service by them;

data hudson.mtg_external;
length  servicer $ 25 Last $ 20 First $ 20 Street $ 25 City $ 20 State $ 2 paym_code $ 15 plan_code $ 15 capitalization $ 15 documentation $ 20
prop_code $ 15 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Data\mtg_ext.txt' firstobs=2 dsd dlm='09'x lrecl=4096 obs=19264;
input svcr_id servicer $ acct note_type $ subtype $  remitance $ Last $ First $ street $ city $ state $ zip  a $ b $ c $  d $ balance  e $ f $ 
      loan_amt :comma24.2 open_date :mmddyy10. appraisal  g $ h $ i $ fico j $ paym_code $ plan_code rate capitalization $ documentation $
	  prop_code $ k $ fico2 fico2_date :mmddyy10. avm  avm_date :mmddyy. appr1  appr1_date :mmddyy. charge_off ;
drop a b c d e f g h i j k;
run;










*start analysis, understand amounts;
title 'Internal MTG Portfolio';
proc tabulate data=hudson.mtg;
var balance;
table N sum*balance*f=dollar24. mean*balance*f=dollar24.;
run;

proc tabulate data=hudson.mtg;
var balance;
class state;
table state ALL, N sum*balance*f=dollar24. mean*balance*f=dollar24.;
format state $stateabbr.;
run;

title 'External MTG Portfolio';
proc tabulate data=hudson.mtg_external;
var balance;
table N sum*balance*f=dollar24. mean*balance*f=dollar24.;
run;

proc tabulate data=hudson.mtg_external;
var balance;
class state;
table state ALL, N sum*balance*f=dollar24. mean*balance*f=dollar24.;
run;




proc format library=sas cntlout=fmtdata1;
select $stateabbr;
run;


proc format ;
value $test '36' = 'NY'
           '34' = 'NJ';
run;

proc format cntout=data1;
select $test;
run;




/* Define a control data set for PROC FORMAT */
data formatdata;
  /* name of the format */
  fmtname='stateabbr';
  type='n';
  do i=1 to 56, 60, 72;
    st=fipstate(i);
    /* not all numbers from 1 to 56 are 
       valid FIPS codes */
    if st ^= "INVALID CODE" then do;
      /* the value of the format is the postal code */
      label=fipstate(i);
      /* the value to format is the state name */
      start=i;
      output;
    end;
  end;
run;

/* Use the control data set with PROC FORMAT */
proc format library=sas cntlin=formatdata;
run;

/*%if %sysfunc(fipstate(&i)) ne '--' %then*/

options mprint nosymbolgen nomlogic mcompilenote=all;

%macro myfmt;

proc format ;
value $stateabbr 
%do i=1 %to 72; 
    "&i" = %BQUOTE(")%sysfunc(fipstate(&i))%BQUOTE(") 
%end;
;
run;

%mend myfmt;

filename mprint "C:\Documents and Settings\ewnym5s\My Documents\SAS\macbug.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic ;

%myfmt

