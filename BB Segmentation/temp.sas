LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

proc sort data=bbseg.prod_data_clean;
by hhid;
run;

proc sort data=bbseg.trdata_clean;
by hhid;
run;

proc sort data=BBSEG.HHDATa_NEw;
by hhid;
run;

proc sort data=bbseg.HHDATA_EXTRA;
by HHID;
run;


data temp;
merge bbseg.prod_data_clean (in=a) bbseg.trdata_clean (in=b) bbseg.hhdata_new (in=c keep=HHID DEp_AMT LOAN_AMT) bbseg.HHDATA_EXTRA (in=d keep=HHID Contrib_AMT);
by hhid;
DEB_TR = SUM ( MPOS_TR, VPOS_TR);
DEb_AMT = SUM ( MPOS_AMT, VPOS_AMT);
TRANS = SUM (MPOS_TR, VPOS_TR , CKDEP, CHKPD, RCD_VOL, OTH_ATM_TR, MT_ATM_TR ,WEb_TR);
if a and b and c and d;
run;

data tempy;
set temp (keep=HHID DEP_AMT LOAN_AMT WEB_TR CHECK_TR VPOS_TR MPOS_TR VPOS_AMT MPOS_AMT DEPTKT CKDEP CHKPD RCD_VOL DEB_TR DEb_AMT TRANS CONTRIB_AMT);

if DEP_AMT = . then do;
dep_AMT = 0;
end ;

if loan_AMT = . then do;
loan_AMT = 0;
end ;

if tran = . then do;
trans = 0;
end ;

if web_tr = . then do;
check_tr = 0;
end ;

if vpos_tr = . then do;
vpos_tr = 0;
end ;

if mpos_tr = . then do;
mpos_tr = 0;
end ;

if vpos_amt = . then do;
vpos_amt = 0;
end ;

if mpos_amt = . then do;
mpos_amt = 0;
end ;


if DEPTKT = . then do;
DEPTKT = 0;
end ;

if CKDEP = . then do;
CKDEP = 0;
end ;


if CHKPD = . then do;
CHKPD = 0;
end ;

if RCD_VOL = . then do;
RCD_VOL = 0;
end ;

if DEB_TR = . then do;
DEB_TR = 0;
end ;

if DEb_AMT = . then do;
DEb_AMT = 0;
end ;

if CONTRIB_AMT = . then do;
CONTRIB_AMT = 0;
end ;
RUN;


proc sort data=tempy;
by hhid;
run;

data temp_all;
merge tempx (in=A) tempz (in=b) tempy (in=c);
by hhid;
if a and b and c;
run;

proc cluster data= temp_all method=ward ccc pseudo print=15 out=tree;
var DDA MMS SAV TDA HEQB HEQC CLS CLN BOLOC BALOC MCC CARD WBB DEB
       DEP_AMT LOAN_AMT
	  RCD_VOL DEB_TR DEb_AMT TRANS; 
run;


data bbseg.HHDaTA_for_CLUSTERing;
set temp_All;
run;


proc fastclus data=temp_all
maxclus=6 out=clus;
   var DDA MMS SAV TDA HEQB HEQC CLS CLN BOLOC BALOC MCC CARD WBB DEB
       DEP_AMT LOAN_AMT
	  RCD_VOL DEB_TR DEb_AMT TRANS
	   ; 

run;

PROC FREQ data=clus;
tables cluster;
run;

proc gplot data=clus;
where cluster=1
DDA MMS SAV TDA);
run;

proc sort data=bbseg.hhdata_new;
by sales_new;
run;


proc freq data=bbseg.hhdata_new;
tables DDA*sales_new / nocol norow nopercent;
run;

data temp1;
set bbseg.HHDATA_new (keep=HHID DDA sales_new employee_new sales_band employee_band);
if DDA =0 then do;
DDA = .;
end;
run;

proc tabulate data=temp1
out=temp_results;
class sales_band employee_band;
var DDA;
tables DDA * (N SUM MEAN) , (sales_band employee_band);
run;

proc gchart data=temp_results;
vbar sales_band / sumvar=DDA_MEAN mean midpoints='LESS THAN $500,000' '$500,000-1 MILLION' '$1-2.5 MILLION' '$2.5-5 MILLION' '$5-10 MILLION' '$10-20 MILLION' 
'$20-50 MILLION' '$50-100 MILLION'  '$100-500 MILLION' '$500M - $1 BILLION' 'OVER $1 BILLION' ;
vbar employee_band / sumvar=DDA_MEAN midpoints= '1-4' '5-9' '10-19' '20-49' '50-99' '100-249' '250-499' '500-999' '1000-4999' '5000-9999' mean ;
run;

proc gchart data=temp1;
vbar employee_band / type=mean SUMVAR=DDA  mean midpoints= '1-4' '5-9' '10-19' '20-49' '50-99' '100-249' '250-499' '500-999' '1000-4999' '5000-9999'  ;
vbar sales_band / type=mean sumvar=DDA mean midpoints='LESS THAN $500,000' '$500,000-1 MILLION' '$1-2.5 MILLION' '$2.5-5 MILLION' '$5-10 MILLION' '$10-20 MILLION' 
'$20-50 MILLION' '$50-100 MILLION'  '$100-500 MILLION' '$500M - $1 BILLION' 'OVER $1 BILLION' ;
run;
