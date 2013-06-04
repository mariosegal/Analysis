/*

LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

*/ 

/*
proc sort data=BBSEG.HHDATA
	out=work.data (keep= HHID TARGET CHECK_TR1 CHKPD CKDEP CURDP_AMT CURDP_CNT DEPTKT LCKBX_NUM MPOS_TR MPOS_AMT MT_ATM_AMT 
                         MT_ATM_TR OTH_ATM_AMT OTH_ATM_TR RCD_NUM VPOS_AMT VPOS_TR WEB_TR WEB_INFO_NUM);
	   
	by TARGET ;
run;

*/ 

/* this step cleans the data to make zeros from the export be nulls so they can be ignored*/ 


data BBSEG.TRDATA_Clean (keep= HHID TARGET CHECK_TR CHKPD CKDEP CURDP_AMT CURDP_CNT DEPTKT LCKBX_NUM MPOS_TR MPOS_AMT MT_ATM_AMT 
                         MT_ATM_TR OTH_ATM_AMT OTH_ATM_TR RCD_VOL VPOS_AMT VPOS_TR WEB_TR WEB_INFO_NUM TOP40 RM EMPLOYEE_BAND SALES_BAND SALES EMPLOYEES);
set  bbseg.hhdata_new;
       if TARGET = . then do;
		  TARGET = 99;
	   end;
	   else do;
		  TARGET = TARGET;
	   end;

	     if CKDEP = 0 then do;
		  CKDEP = .;
	   end;
	   else do;
		  CKDEP = CKDEP;
	   end;

	   if check_tr = 0 then do;
		  check_tr = .;
	   end;
	   else do;
		  check_tr = check_tr;
	   end;

	   if deptkt = 0 then do;
		  deptkt = .;
	   end;
	   else do;
		  deptkt = deptkt;
	   end;

	   if chkpd = 0 then do;
		  chkpd = .;
	   end;
	   else do;
		  chkpd = chkpd;
	   end;
	   

	   if curdp_amt = 0 then do;
		  curdp_amt = .;
	   end;
	   else do;
		  curdp_amt = curdp_amt;
	   end;

	   if curdp_cnt = 0 then do;
		  curdp_cnt = .;
	   end;
	   else do;
		  curdp_cnt = curdp_cnt;
	   end;

	   if lckbx_num = 0 then do;
		  lckbx_num = .;
	   end;
	   else do;
		  lckbx_num = lckbx_num;
	   end;

	   if MPOS_TR = 0 then do;
		  MPOS_TR = .;
	   end;
	   else do;
		  MPOS_TR = MPOS_TR;
	   end;

	   if MPOS_AMT = 0 then do;
		  MPOS_AMT = .;
	   end;
	   else do;
		  MPOS_AMT = MPOS_AMT;
	   end;

	   if MT_ATM_AMT = 0 then do;
		  MT_ATM_AMT = .;
	   end;
	   else do;
		  MT_ATM_AMT = MT_ATM_AMT;
	   end;

	   if MT_ATM_TR = 0 then do;
		  MT_ATM_TR = .;
	   end;
	   else do;
		  MT_ATM_TR = MT_ATM_TR;
	   end;

	   if OTH_ATM_TR = 0 then do;
		  OTH_ATM_TR = .;
	   end;
	   else do;
		  OTH_ATM_TR = OTH_ATM_TR;
	   end;

	   if OTH_ATM_AMT = 0 then do;
		  OTH_ATM_AMT = .;
	   end;
	   else do;
		  OTH_ATM_AMT = OTH_ATM_AMT;
	   end;

	   if RCD_VOL = 0 then do;
		  RCD_VOL = .;
	   end;
	   else do;
		  RCD_VOL = RCD_VOL;
	   end;

	    if VPOS_AMT = 0 then do;
		  VPOS_AMT = .;
	   end;
	   else do;
		  VPOS_AMT = VPOS_AMT;
	   end;

	    if VPOS_TR = 0 then do;
		  VPOS_TR = .;
	   end;
	   else do;
		  VPOS_TR = VPOS_TR;
	   end;

	    if WEB_TR = 0 then do;
		  WEB_TR = .;
	   end;
	   else do;
		  WEB_TR = WEB_TR;
	   end;

	    if WEB_INFO_NUM = 0 then do;
		  WEB_INFO_NUM = .;
	   end;
	   else do;
		  WEB_INFO_NUM = WEB_INFO_NUM;
	   end;
run;

/* add the MGD Field*/

data tempx;
set BBSEG.HHDATA_NEW;
keep HHID MGD;
run;

proc sort data=tempx;
by HHID;
run;

proc sort data=BBSEG.TRDATA_CLEAn;
by hhid;
run;

data tempz;
merge BBSEG.TRDATA_CLEAn tempx;
by HHID;
run;

data BBSEG.TRDATA_CLEAn;
set tempz;
run;

proc sort data=BBSEG.TRDATA_CLEAn;
	by TARGET ;
run;

PROC TABULATE DATA=BBSEG.TRDATA_Clean 
	out=BBSEG.RESULTS_TRANS (drop=_PAGE_ _TABLE_ _TYPE_);
	CLASS TARGET / missing ;
	by target;
	VAR CHECK_TR CHKPD CKDEP CURDP_AMT CURDP_CNT DEPTKT LCKBX_NUM MPOS_TR MPOS_AMT MT_ATM_AMT 
        MT_ATM_TR OTH_ATM_AMT OTH_ATM_TR RCD_NUM VPOS_AMT VPOS_TR WEB_TR WEB_INFO_NUM;
	TABLES TARGET*(CHECK_TR CHKPD CKDEP CURDP_AMT CURDP_CNT DEPTKT LCKBX_NUM MPOS_TR MPOS_AMT MT_ATM_AMT 
                   MT_ATM_TR OTH_ATM_AMT OTH_ATM_TR RCD_NUM VPOS_AMT VPOS_TR WEB_TR WEB_INFO_NUM) *(N SUM);  
	
RUN;



proc means data=BBSEG.TRDATA_CLEAN N NMISS;
class target / missing;
var ckdep;
run;


/*below is the analys for RCD_VOL*/

proc sort data=BBSEG.HHDATA_NEW;
by TARGET;
run;


proc means data=BBSEG.HHDATA_NEW n nmiss mean sum ;
class TARGET;
var RCD_VOL;
run;
