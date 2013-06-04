LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';
OPTIONS FMTSEARCH=(BBSEG WORK);


/*%let type1= C02;*/
/*options symbolgen;*/

/*proc sql;*/
/*create table test1 as*/
/*	select HHID, sum(count1) as CL3, sum(AMT) as CL3_AMT from test*/
/*	where STYPE = 'CL3'*/
/*	group by HHID;*/
/*quit;*/
/**/
/*proc sort data=test1;*/
/*by HHID;*/
/*run;*/
/**/
/*data tempy;*/
/*merge tempx (in=a) test1 (in=b);*/
/*by hhid;*/
/*if a;*/
/*run;*/
/**/
/*data tempx;*/
/*set tempy ;*/
/*run;*/


/*proc sql;*/
/*create table test1 as*/
/*	select HHID, sum(Count1) as Other  , sum(AMT) as OTHER_AMT from test*/
/*	where STYPE = 'CLE' or STYPE = 'CP2' or STYPE = 'CQ2' or STYPE = 'CN2' or STYPE = 'CQ3'*/
/*	group by HHID;*/
/*quit;*/


/*proc sql;*/
/*create table test as*/
/*	select HHID, stype, COUNT(stype) AS COUNT1, SUM(BAL_PRIME) as AMT from BBSEG.DDA_DATA*/
/*	group by HHID, stype;*/
/*quit;*/

/*DATA BBSEG.DDA_CROSS;*/
/*MERGE TEMPX (IN=A )) bbseg.hhdata_NEW (in=b keep=HHID target_new cluster_new sales_new employee_new tenure_band mgd) bbseg.prod_data_clean (in=c keep=HHID DDA DDA_AMT);*/
/*by hhid;*/
/*if a and b and c;*/
/*RUN;*/


/*proc print data=bbseg.DDA_DATA ;*/
/*where HHID = '200004448';*/
/*run;*/

/*proc means data=bbseg.dda_cross min max;*/
/*var _numeric_;*/
/*run;*/


/*BELOW i ACTUALLY DO  THE ANALYSIS*/

/*DATA BBSEG.DDA_Grouped;*/
/*MERGE test (IN=A ) bbseg.hhdata_NEW (in=b keep=HHID target_new cluster_new sales_new employee_new tenure_band mgd dda DDA_amt) ;*/
/*by hhid;*/
/*if a and b;*/
/*RUN;*/

proc freq data=bbseg.DDA_grouped;
tables (STYPE)*(MGD) / out= WORK.RESULTS_MGD_stype nocol norow nopercent;
tables (STYPE)*(sales_new) / out= WORK.RESULTS_sales_stype nocol norow nopercent;
tables (STYPE)*(employee_new) / out= WORK.RESULTS_employee_stype nocol norow nopercent;
tables (STYPE)*(cluster_new) / out= WORK.RESULTS_cluster_stype nocol norow nopercent;
tables (STYPE)*(target_new) / out= WORK.RESULTS_target_stype nocol norow nopercent;
tables (STYPE)*(dda) / out= WORK.RESULTS_dda_stype nocol norow nopercent;
run;



libname myxls oledb init_string="Provider=Microsoft.ACE.OLEDB.12.0;
Data Source=C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_STYPE..xls;
Extended Properties=Excel 12.0";

data myxls.MGD;
   set WORK.RESULTS_MGD_stype;
  run;

data myxls.TARGET;
   set WORK.RESULTS_target_stype;
    run;


data myxls.cluster;
   set WORK.RESULTS_cluster_stype;
    run;

data myxls.employee;
   set WORK.RESULTS_employee_stype;
    run;

data myxls.sales;
   set WORK.RESULTS_sales_stype;
    run;


libname myxls clear;


