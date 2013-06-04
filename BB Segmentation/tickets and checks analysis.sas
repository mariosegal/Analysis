LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';
OPTIONS FMTSEARCH=(BBSEG WORK);

/*proc sort data=bbseg.trdata_clean;*/
/*by hhid;*/
/*run;*/


/*data tempx;*/
/*merge bbseg.trdata_clean (in=a) bbseg.HHDATA_new (keep=hhid RCD in=b);*/
/*by hhid;*/
/*if RCD_VOL ge 1 or CKDEP ge 1 then do;*/
/*	total_chks = sum(RCD_VOL,  CKDEP);*/
/*end;*/
/*else do;*/
/*	total_chks = 0;*/
/*end;*/
/*if RCD_vol ge 1 then do;*/
/* rcd1 = 1;*/
/*end;*/
/*else do;*/
/*  rcd1 = 0;*/
/*end;*/
/*if a and b;*/
/*run;*/

/*proc format;*/
/*value Checks  0 = 'Zero'*/
/*              1 = '1'*/
/*			  2 = '2'*/
/*			  3 = '3'*/
/*			  4 = '4'*/
/*			  5 = '5'*/
/*			  6 - 10 = '6 to 10'*/
/*			  11 - 15 = '11 to 15'*/
/*			  16 - 25 = '16 to 25'*/
/*			  26 - 50 = '26 to 50'*/
/*			  51 - 75 = '51 to 75'*/
/*			  76 - 100 = '76 to 100'*/
/*			  101 - 150 = '101 to 150'*/
/*			  151 - 200 = '151 to 200'*/
/*			  201 - 300 = '201 to 300'*/
/*			  301 - 500 = '301 to 500'*/
/*			  501 - high = 'Over 500';*/
/*run;*/


proc freq data=tempx;
tables RCD*(deptkt)*(ckdep) / out= WORK.RESULTS_RCD_Detail nocol norow nopercent missing;
format deptkt ckdep checks. RCD YN.;
run;


proc tabulate data=tempx missing;
class total_chks rcd1 ;
var RCD_VOL ckdep;
tables  rcd1, (RCD_VOL ckdep) *(N SUM), Total_chks;
format Total_chks checks. RCD1 YN.;
run;

proc freq data=tempx;
tables total_chks / nocol norow nopercent missing;
format total_chks checks.;
run;



libname myxls oledb init_string="Provider=Microsoft.ACE.OLEDB.12.0;
Data Source=C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Results_RCD_Detail.xls;
Extended Properties=Excel 12.0";

data myxls.Data;
   set WORK.RESULTS_RCD_Detail;
  run;




libname myxls clear;

proc format;
value $sics  ' ' = 'Null'
       		other     = 'Other';
run;


proc freq data=bbseg.HHDATA_NEW;
where sic_INT is null	;
tables SIC_EXT / missing ;
format SIC_EXT $SICS.;
run;


