/*LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

data tempx;
set BBSEG.HHDATA_NEW;
DEP_AMT = SUM( DDA_AMT,  MMS_AMT , SAV_AMT , IRA_AMT , TDA_AMT);
LOAN_AMT = SUM(BALOC_AMT , BOLOC_AMT , CLN_AMT , CLS_AMT , HEQB_AMT , MTG_AMT);
run;

data BBSEG.HHDATA_NEW;
set tempx;
run;

data temp;
set BBSEG.HHDATA_NEW (keep=HHID HH DEP_AMT LOAN_AMT);
run;

proc means data=temp;
run;
*/

data temp;
set BBSEG.HHDATA_NEW (keep=HHID HH DEP_AMT LOAN_AMT);
run;

%let var = LOAN_AMT;

proc rank data=temp out=order groups=20;
	var &var;
	ranks rank;
	
run;


proc sort data=order;
by Rank;
run;


proc tabulate data=order
out= results_&var;
class rank;
var &var;
tables rank, &var * (N SUM MIN MAX MEAN);
run;

/* below is for debit trans*/



data temp_tr;
set BBSEG.TRDATA_CLEAN (keep=HHID VPOS_TR MPOS_TR);
DEB_TR = SUM(VPOS_TR, MPOS_TR);
run;

%let var1 = DEB_TR;

proc rank data=temp_tr out=order groups=20;
	var &var1;
	ranks rank;
	
run;


proc sort data=order;
by Rank;
run;


proc tabulate data=order
out= results_&var1;
class rank;
var &var1;
tables rank, &var1 * (N SUM MIN MAX MEAN);
run;
