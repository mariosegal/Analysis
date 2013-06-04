/* oroginal code weas for distribution by target, to add another variable we need to change teh class statements*/




/*Freq analysis*/






/* Below we do analysis of the penetrations and balances 
I need to create a copy of original data making 0 = . and >=1 to 1 for the count balances and 
0 = . for the balance variables
*/

/*

data temp1 (keep= HHID DDA MMS SAV TDA IRA MTG BALOC BOLOC HEQB HEQC CARD CLN CLS 
DDA_AMT MMS_AMT SAV_AMT TDA_AMT IRA_AMT CLS_AMT CLN_AMT MTG_AMT HEQB_AMT HEQC_AMT CARD_AMT BALOC_AMT BOLOC_AMT 
RM TOP40 TARGET TARGET_NEW SALES SALES_BAND EMPLOYEES EMPLOYEE_BAND DEB WBB MCC WEB_INFO WBB DEB WBBN DEBN);
set BBSEG.HHDATA_NEW;

	   if TARGET = . then do;
		  TARGET = 99;
	   end;
	   else do;
		  TARGET = TARGET;
	   end;
	   
	   if DDA >=1 then do;
		  DDA = 1;
	   end;
	   else do;
		  DDA = .;
	   end;

	   if SAV >=1 then do;
		  SAV = 1;
	   end;
	   else do;
		  SAV = .;
	   end;

	   
	   if MMS >=1 then do;
		  MMS = 1;
	   end;
	   else do;
		  MMS = .;
	   end;


	   if TDA >=1 then do;
		  TDA = 1;
	   end;
	   else do;
		  TDA = .;
	   end;

	   if IRA >=1 then do;
		  IRA = 1;
	   end;
	   else do;
		  IRA = .;
	   end;


	   if MTG >=1 then do;
		  MTG = 1;
	   end;
	   else do;
		  MTG = .;
	   end;

	   
	   if CLN >=1 then do;
		  CLN = 1;
	   end;
	   else do;
		  CLN = .;
	   end;

	   
	   if CLS >=1 then do;
		  CLS = 1;
	   end;
	   else do;
		  CLS = .;
	   end;

	   
	   if CARD >=1 then do;
		  CARD = 1;
	   end;
	   else do;
		  CARD = .;
	   end;

	   
	   if BOLOC >=1 then do;
		  BOLOC = 1;
	   end;
	   else do;
		  BOLOC = .;
	   end;

	   
	   if BALOC >=1 then do;
		  BALOC = 1;
	   end;
	   else do;
		  BALOC = .;
	   end;

	   
	   if HEQB >=1 then do;
		  HEQB = 1;
	   end;
	   else do;
		  HEQB = .;
	   end;

	   
	   if HEQC >=1 then do;
		  HEQC = 1;
	   end;
	   else do;
		  HEQC = .;
	   end;

	 

	   if DDA_AMT =0 then do;
		  DDA_AMT = .;
	   end;
	 

	   if SAV_AMT =0 then do;
		  SAV_AMT = .;
	   end;
	   
	   
	   if MMS_AMT =0 then do;
		  MMS_AMT = .;
	   end;
	   


	   if TDA_AMT =0 then do;
		  TDA_AMT = .;
	   end;
	   
	   if IRA_AMT =0 then do;
		  IRA_AMT = .;
	   end;
	   


	   if MTG_AMT =0 then do;
		  MTG_AMT = .;
	   end;
	   

	   
	   if CLN_AMT =0 then do;
		  CLN_AMT = .;
	   end;
	   
	   
	   if CLS_AMT =0 then do;
		  CLS_AMT = .;
	   end;
	   
	   
	   if CARD_AMT =0 then do;
		  CARD_AMT = .;
	   end;
	   

	   
	   if BOLOC_AMT =0 then do;
		  BOLOC_AMT = .;
	   end;
	   

	   
	   if BALOC_AMT =0 then do;
		  BALOC_AMT = .;
	   end;
	   

	   
	   if HEQB_AMT =0 then do;
		  HEQB_AMT = .;
	   end;
	   

	   
	   if HEQC_AMT =0 then do;
		  HEQC_AMT = .;
	   end;
	
	   

	if WBB >=1 then do;
		WBBN = WBB;
		WBB = 1;  
	   end;
	   else do;
		WBBN = .;
		WBB = .;
	   end;

	   if DEB >=1 then do;
		DEBN = DEB;
		DEB = 1;  
	   end;
	   else do;
		DEBN = .;
		DEB = .;
	   end;

	   if WEB_INFO = 0 then do;
		  WEB_INFO = .;
	   end;
	   
	   if MCC = 0 then do;
		  MCC = .;
	   end;

RUN;





DATA BBSEG.PROD_DATA_CLEAN;
SET temp1;
run;

 
*/



LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

%let GROUP_VAR = cluster_new;

/* here you sort by the desired variable*/
proc sort data= BBSEG.PROD_DATA_CLEAN;
by &GROUP_VAR;
run;

/* HERE you do the analysis and dump it on a table*/

proc tabulate data=BBSEG.PROD_DATA_CLEAN
out=WORK.RESULTS_PROD_&GROUP_VAR (drop=_PAGE_ _TABLE_ _TYPE_);
class &GROUP_VAR;
var DDA MMS SAV TDA IRA CLN CLS BALOC BOLOC CARD MTG HEQB HEQC MCC DEB WBB DEBN WBBN
DDA_AMT MMS_AMT SAV_AMT TDA_AMT IRA_AMT CLN_AMT CLS_AMT BALOC_AMT BOLOC_AMT CARD_AMT MTG_AMT HEQB_AMT HEQC_AMT;
tables (DDA MMS SAV TDA IRA CLN CLS BALOC BOLOC CARD MTG HEQB HEQC MCC DEB WBB
DDA_AMT MMS_AMT SAV_AMT TDA_AMT IRA_AMT CLN_AMT CLS_AMT BALOC_AMT BOLOC_AMT CARD_AMT MTG_AMT HEQB_AMT HEQC_AMT DEB WBB DEBN WBBN MCC)*(SUM), &GROUP_VAR;
keylabel SUM='';
run;

proc freq data=BBSEG.PROD_DATA_CLEAN;
tables &GROUP_VAR / out= WORK.RESULTS_Ns_&GROUP_VAR ;
run;


proc sort data=BBSEG.TRDATA_CLEAn;
	by &GROUP_VAR ;
run;

PROC TABULATE DATA=BBSEG.TRDATA_Clean 
	out=WORK.RESULTS_TRANS_&GROUP_VAR (drop=_PAGE_ _TABLE_ _TYPE_);
	CLASS &GROUP_VAR;
	VAR CHECK_TR CHKPD CKDEP CURDP_AMT CURDP_CNT DEPTKT LCKBX_NUM MPOS_TR MPOS_AMT MT_ATM_AMT 
        MT_ATM_TR OTH_ATM_AMT OTH_ATM_TR RCD_VOL VPOS_AMT VPOS_TR WEB_TR WEB_INFO_NUM;
	TABLES (CHECK_TR CHKPD CKDEP CURDP_AMT CURDP_CNT DEPTKT LCKBX_NUM MPOS_TR MPOS_AMT MT_ATM_AMT 
                   MT_ATM_TR OTH_ATM_AMT OTH_ATM_TR RCD_VOL VPOS_AMT VPOS_TR WEB_TR WEB_INFO_NUM ) *(N SUM MEAN), &GROUP_VAR;  
	
RUN;

proc sort data=BBSEG.HHDATA_NEW;
	by &GROUP_VAR ;
run;



data temp;
set BBSEG.HHDATA_NEW (keep= &GROUP_VAR HH sales_new employee_new tenure_band Score_Month Contrib_AMT);
run;

proc freq data=temp;
tables (Sales_new)*&GROUP_VAR / out= WORK.RESULTS_sales_&GROUP_VAR nocol norow nopercent;
tables (employee_new)*&GROUP_VAR / out= WORK.RESULTS_employee_&GROUP_VAR nocol norow nopercent;
tables (tenure_band)*&GROUP_VAR / out= WORK.RESULTS_tenure_&GROUP_VAR nocol norow nopercent;
tables (Score_Month)*&GROUP_VAR / out= WORK.RESULTS_Profit_&GROUP_VAR nocol norow nopercent;
run;


PROC TABULATE DATA=temp
	out=WORK.RESULTS_CONTR_&GROUP_VAR (drop=_PAGE_ _TABLE_ _TYPE_);
	CLASS &GROUP_VAR ;
	VAR  Contrib_AMT;
	TABLES (Contrib_AMT ) *(N SUM MEAN), &GROUP_VAR;  
	
RUN;


/*
proc format ;
value $salesband '$1-2.5 MILLION' = 3
				  '$10-20 MILLION' = 6
				  '$100-500 MILLION' = 9
				  '$2.5-5 MILLION' = 4
				  '$20-50 MILLION' = 7
				  '$5-10 MILLION' = 5
				  '$50-100 MILLION' = 8
				  '$500,000-1 MILLION' = 2
				  '$500M - $1 BILLION' = 10
				  'LESS THAN $500,000' = 1
				  'OVER $1 BILLION' = 11
				  NULL = 99;

value $emplband '10-19' = 3
				  '100-249' = 6
				  '1000-4999' = 9
				  '20-49' = 4
				  '250-499' = 7
				  '50-99' = 5
				  '500-999' = 8
				  '5-9' = 2
				  '5000-9999' = 10
				  '1-4' = 1
				  NULL = 99;
run;
*/

/*
PROC FORMAT ;
VALUE TENUREF   0 - 365 = 'Under 1 Year'
				  366 - 730 = '1 - 2 Years'
				  731 - 1095 = '2 - 3 Years'
				  1096 - 1460 = '3 - 4 Years'
			      1461 - 1825 = '4 - 5 Years'
				  1826 - 3650 = '5 - 10 Years'
				  3651 - 5475 = '10 - 15 Years'
				  5476 - high  = 'Over 15 Years';
run;

*/

data temp;
set BBSEG.HHDATA_NEW;
Keep HHID TARGET_NEW MGD &GROUP_VAR;
run;

proc freq data=temp;
tables &GROUP_VAR*MGD / out=WORK.RESULTS_MGD_&GROUP_VAR nocol norow nopercent;
run;

proc freq data=temp;
tables &GROUP_VAR*TARGET_NEW / out=WORK.RESULTS_TARGET_&GROUP_VAR nocol norow nopercent;
run;


libname myxls oledb init_string="Provider=Microsoft.ACE.OLEDB.12.0;
Data Source=C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_&Group_Var..xls;
Extended Properties=Excel 12.0";

data myxls.MGD;
   set WORK.RESULTS_MGD_&GROUP_VAR;
  run;

data myxls.TARGET;
   set WORK.RESULTS_target_&GROUP_VAR;
    run;

data myxls.CONTR;
   set WORK.RESULTS_CONTR_&GROUP_VAR;
    run;

data myxls.Profit;
   set WORK.RESULTS_profit_&GROUP_VAR;
    run;

data myxls.tenure;
   set WORK.RESULTS_tenure_&GROUP_VAR;
    run;

data myxls.employee;
   set WORK.RESULTS_employee_&GROUP_VAR;
    run;

data myxls.sales;
   set WORK.RESULTS_sales_&GROUP_VAR;
    run;

data myxls.TRANS;
   set WORK.RESULTS_TRANS_&GROUP_VAR;
    run;

data myxls.PROD;
   set WORK.RESULTS_PROD_&GROUP_VAR;
    run;

data myxls.Ns;
   set WORK.RESULTS_Ns_&GROUP_VAR;
    run;

libname myxls clear;

/* Below is the old export routine, the one above is nicer, all in one file */

/*
proc export data=WORK.RESULTS_PROD_&GROUP_VAR 
outfile= "C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_PROD_&GROUP_VAR..csv"
DBMS = CSV REPLACE;
run;

proc export data=WORK.RESULTS_Ns_&GROUP_VAR 
outfile= "C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_Ns_&GROUP_VAR..csv"
DBMS = CSV REPLACE;
run;


proc export data=WORK.RESULTS_TRANS_&GROUP_VAR 
outfile= "C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_TRANS_&GROUP_VAR..csv"
DBMS = CSV REPLACE;
run;

proc export data=WORK.RESULTS_sales_&GROUP_VAR 
outfile= "C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_sales_&GROUP_VAR..csv"
DBMS = CSV REPLACE;
run;

proc export data=WORK.RESULTS_employee_&GROUP_VAR 
outfile= "C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_employee_&GROUP_VAR..csv"
DBMS = CSV REPLACE;
run;

proc export data=WORK.RESULTS_tenure_&GROUP_VAR 
outfile= "C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_tenure_&GROUP_VAR..csv"
DBMS = CSV REPLACE;
run;

proc export data=WORK.RESULTS_profit_&GROUP_VAR 
outfile= "C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_profit_&GROUP_VAR..csv"
DBMS = CSV REPLACE;
run;

proc export data=WORK.RESULTS_CONTR_&GROUP_VAR 
outfile= "C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_contr_&GROUP_VAR..csv"
DBMS = CSV REPLACE;
run;

proc export data=WORK.RESULTS_target_&GROUP_VAR 
outfile= "C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_target_&GROUP_VAR..csv"
DBMS = CSV REPLACE;
run;

proc export data=WORK.RESULTS_MGD_&GROUP_VAR 
outfile= "C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_MGD_&GROUP_VAR..csv"
DBMS = CSV REPLACE;
run;
*/




