LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';
OPTIONS FMTSEARCH=(BBSEG WORK);

data temp_prod;
set BBSEG.PROD_DATA_CLEAN;
if SUM (DDA, MMS, SAV, TDA, IRA) ge 1 then do;
Deposits = 1;
end;
else do;
Deposits = 0;
end;

if SUM (CLN, CLS, BALOC, BOLOC, CARD, MTG, HEQB) ge 1 then do;
Loans = 1;
end;
else do;
Loans = 0;
end;
run;


proc sort data=BBSEG.HHDATA_for_clustering;
by HHID;
run;

proc sort data=temp_prod;
by HHID;
run;


data temp_c;
merge BBSEG.HHDATA_for_clustering (in=A keep= HHID DEP_AMT LOAN_AMT) temp_prod (In=b);
by HHID;
if a and B;
run;


proc tabulate data=temp_prod missing ;
class DDA;
var  MMS SAV TDA CLN CLS BALOC BOLOC CARD MTG HEQB;
tables ( MMS SAV TDA CLN CLS BALOC BOLOC CARD MTG HEQB ALL)*(N), DDA  ;
run;

proc tabulate data=temp_prod  ;
class Deposits;
var  DDA MMS SAV TDA CLN CLS BALOC BOLOC CARD MTG HEQB Loans;
tables ( DDA MMS SAV TDA CLN CLS BALOC BOLOC CARD MTG HEQB LOans ALL)*(N), deposits  ;
run;

proc tabulate data=temp_prod  ;
class LOans;
var  DDA MMS SAV TDA CLN CLS BALOC BOLOC CARD MTG HEQB deposits;
tables ( DDA MMS SAV TDA CLN CLS BALOC BOLOC CARD MTG HEQB Deposits ALL)*(N), Loans  ;
run;

proc freq data=temp_prod  ;
tables loans*deposits loans*DDA/ norow nocol nopercent missing;

run;


proc tabulate data=temp_prod  ;
var  deposits loans;
tables Deposits, loans, SUM  ;
run;

proc format library=BBSEG;
value bands 0 = 'Zero'
            1 - 5 = '1 to 5'
			6 - 10 = '6 to 10'
			11 - 20 ='11 to 20'
			21 - 50 = '21 to 50'
			51 - 100 = '51 to 100'
			101 - 200 = '101 to 200'
			201 - 999999999999 = 'Over 200';
run;

proc freq data=bbseg.HHDATA_for_clustering;
tables CKDEP*RCD_VOL / norow nocol nopercent;
format CKDEP RCD_VOL bands.;
run;
proc format ;
value amt_bands low-<0 = 'Below Zero'
		     0		= 'Zero'
			 0 <-10000 = 'Up to $10M'
			 10000 <- 25000 = '$10M to 25M'
			 25000 <- 50000 = '$25M to 250M'
			 50000 <- 100000 = '$50M to 100M'
			 100000 <- 250000 = '$100M to 250M'
			 250000 <- 500000 = '$250M to 500M'
			 500000 <- 1000000 = '$500M to 1MM'
			 1000000 <-high = 'Over $1MM';
run;

proc format ;
value YN 0 = 'N'
         . = 'N'
             1 = 'Y';
run;


proc freq data=temp_C;
tables (DDA Deposits)*loan_Amt / missing  nopercent;
format loan_amt AMT_BANDs. DDA YN. Deposits YN.;
RUN;


/* how many dda accts by sales or employee band */

data tempx;
set BBSEG.HHDATA_NEW;
where DDA ge 1;
keep HHID DDA Sales_new Employee_New SIC;
run;

proc means data=tempx n sum mean;
class Sales_New;
var DDA ;
format Sales_New salesfmt.;
run;

proc means data=tempx n sum mean;
class employee_New;
var DDA;
format employee_New empfmt.;
run;

ods html close;
ods pdf ;

axis1 label=none major=none minor=none style=0 value=none;
axis2 value=(h=8pt) split=" " label=(f="Arial/Bold" "Sales Volume");
proc gchart data=tempx;
vbar sales_new / width=15 sumvar=DDA type=mean inside=freq outside=mean midpoints=1 2 3 4 5 6 7 8 9 10 11 99 . raxis=axis1 maxis=axis2;
format sales_new salesfmt. DDA comma6.2 FREQ comma10.0;

run;


axis1 label=none major=none minor=none style=0 value=none;
axis2 value=(h=8pt) split=" " label=(f="Arial/Bold" "Numer of Employees");
proc gchart data=tempx;
vbar employee_new / width=15 sumvar=DDA type=mean inside=freq outside=mean midpoints=1 2 3 4 5 6 7 8 9 10 11 99 . raxis=axis1 maxis=axis2;
format employee_new empfmt. DDA comma6.2 FREQ comma10.0;

run;

ods pdf close;
ods html;


/* who has multiple accounts */
proc sort data=tempx;
by DDA;
run;


Proc freq data=tempx order = freq;
where DDA ge 2;
tables SIC *DDA / out=ck_stats noprint ;
run;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\SIC.txt';
Data bbseG.sic_list;
length sic $ 4 NAME $ 135;
Infile myfile DLM='09'x firstobs=2 lrecl=4096 DSD;
Input 	SIC $
		Name $;
run;

proc sort data=ck_stats;
by SIC;
run;

proc sort data=bbseg.sic_list;
by SIC;
run;



data temp1;
merge ck_stats (in=a) bbseg.sic_list (in=b);
by SIC;
if a;
run;


/* correlate sales_size based on other variables, likely balances */

proc sort data=BBSEG.PROD_DATA_CLean;
by hhid;
run;

proc sort data=BBSEg.HHDATA_NEW;
by hhid;
run;
 

data temp_corr;
merge BBSEG.PROD_DATA_CLean (in=a drop=DDA MMS SAV CLS IRA CLN BALOC BOLOC WBB DEB MTG TDA HEQB HEQC 
                                       CARD MCC WEB_INFO TARGET TOP40 Rm WBBN DEBN SALES_NEW EMPLOYEE_NEW CLUSTER_NEW HH) 
      BBSEg.HHDATA_NEW (keep=HHID Sales DEP_AMT LOAN_AMT CONTRIB_AMT where=(sales gt 0) in=b);
by hhid;
;
if a and b;
run;




data test;
set temp_corr ;
where DEP_AMT gt 0  and LOAN_AMT gt 0;
logsales = log10(sales);
keep sales dep_AMT loan_AMT dep_AMT contrib_AMT dda_AMT logsales;
run;



proc reg data=test(where=(DEP_AMT le 360000 and LOAN_AMT le 750000 and contrib_amt le 3000)) plots(maxpoints=none) corr;
model sales = dda_amt dep_amt loan_amt contrib_amt;
model1 logsales = dda_amt dep_amt loan_amt contrib_amt;
run;



proc freq data=BBSEG.DDA_DATA (where=(STYPE='CV0')) order=freq;
tables STYPE;
run;

proc sql;
create table test as
	select HHID, STYPE, COUNT(STYPE) as ct1 from BBSEG.DDA_DATA
	group by HHID, STYPE;
quit;
