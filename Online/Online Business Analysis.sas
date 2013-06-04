libname online 'C:\Documents and Settings\ewnym5s\My Documents\Online';
libname data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
libname bbseg 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';
options fmtsearch=(SAS);

options MSTORED SASMSTORE = mjstore;
libname mjstore 'C:\Documents and Settings\ewnym5s\My Documents\SAS\Macros';


/* look at distribution, start with deciles */

proc rank data=bbseg.hhdata_new  out=ranks (keep=hhid group web_tr hh) groups=10;
where (wbb ge 1);
ranks group;
var web_tr;
run;

proc tabulate data=ranks;
class group;
var web_tr;
table group, web_tr*(N PCTN MIN MAX MEAN);
run;

proc rank data=bbseg.hhdata_new  out=ranks1 (keep=hhid group web_tr hh) groups=4;
where (wbb ge 1);
ranks group;
var web_tr;
run;

proc tabulate data=ranks1;
class group;
var web_tr;
table group, web_tr*(N PCTN MIN MAX MEAN);
run;

proc rank data=bbseg.hhdata_new  out=ranks2 (keep=hhid group web_tr hh) groups=8;
where (wbb ge 1 and web_tr gt 0 and web_tr le 100);
ranks group;
var web_tr;
run;

proc freq data=ranks2;
table web_tr;
run;

proc tabulate data=ranks2;
class group;
var web_tr;
table group, web_tr*(N PCTN MIN MAX MEAN);
run;


data bbseg.hhdata_new;
length web_band $ 10;
set bbseg.hhdata_new;

select;
when (wbb eq 0) web_band = 'No Web';
when (wbb ge 1 and web_tr eq 0) web_band = 'Inactive';
when (wbb ge 1 and web_tr gt 0 and web_tr le 2) web_band = 'q1';
when (wbb ge 1 and web_tr gt 2 and web_tr le 6) web_band = 'q2';
when (wbb ge 1 and web_tr gt 6 and web_tr le 16) web_band = 'q3';
when (wbb ge 1 and web_tr gt 16 and web_tr le 100) web_band = 'q4';
otherwise web_band = 'xxxx';
end;

run;


proc freq data=bbseg.hhdata_new (keep=web_band hhid);
table web_band;
run;


data temp;
set bbseg.hhdata_new ;
if DDA ge 1 then DDA = 1;
if MMS ge 1 then MMS = 1;
if SAV ge 1 then SAV = 1;
if TDA ge 1 then TDA = 1;
if IRA ge 1 then IRA = 1;
if MTG ge 1 then MTG = 1;
if HEQB ge 1 then HEQB = 1;
if HEQC ge 1 then HEQC = 1;
if CLN ge 1 then CLN = 1;
if CARD ge 1 then CARD = 1;
if BOLOC ge 1 then BOLOC = 1;
if BALOC ge 1 then BALOC = 1;
if CLS ge 1 then CLS = 1;
if BOLOC ge 1 then BOLOC = 1;
if MCC ge 1 then MCC = 1;
KEEP hhid hh WEB_BAND CBR MARKET SCORE_MONTH TENURE_BAND SALES_NEW EMPLOYEE_NEW
DDA MMS SAV TDA IRA TRS MTG HEQB HEQC CLN CARD BOLOC BALOC CLS WBB DEB MCC LCKBX RCD BBFB 
DDA_AMT MMS_AMT SAV_AMT TDA_AMT IRA_AMT MTG_AMT HEQB_AMT HEQC_AMT CLN_AMT CARD_AMT BOLOC_AMT BALOC_AMT CLS_AMT MCC_AMT CON COM ;
RUN;



/* do analysis */

proc contents data=bbseg.hhdata_new short varnum;
run;

proc format lib=sas ;
value salesband 3 = '$1-2.5 MILLION'
				  6 = '$10-20 MILLION' 
				  9 = '$100-500 MILLION' 
				  4 = '$2.5-5 MILLION' 
				  7 = '$20-50 MILLION' 
				  5 = '$5-10 MILLION' 
				  8 = '$50-100 MILLION' 
				  2 = '$500,000-1 MILLION' 
				  10 = '$500M - $1 BILLION' 
				  1 = 'LESS THAN $500,000' 
				  11 = 'OVER $1 BILLION' 
				  99 = 'Unknown';

value emplband 3 = '10-19' 
				  6 = '100-249' 
				  9 = '1000-4999' 
				  4 = '20-49' 
				  7 = '250-499' 
				  5 = '50-99' 
				  8 = '500-999' 
				  2 = '5-9' 
				  10 = '5000-9999' 
				  1 = '1-4'
				  99 = 'Unknown' ;
run;


/*proc tabulate data=temp out= prod1;*/
/*where web_band ne 'xxxx';*/
/*class web_band;*/
/*var HH DDA MMS SAV TDA IRA TRS MTG HEQB HEQC CLN CARD BOLOC BALOC CLS WBB DEB MCC LCKBX RCD BBFB;*/
/*table web_band, (HH*SUM*F=comma6.) (DDA MMS SAV TDA IRA TRS MTG HEQB HEQC CLN CARD BOLOC BALOC CLS MCC)* (SUM*F=comma6. PCTSUM<HH>*F=comma5.1);*/
/*run;*/

/*proc tabulate data=temp out= prod2;*/
/*where web_band ne 'xxxx';*/
/*class web_band;*/
/*var HH DDA_AMT MMS_AMT SAV_AMT TDA_AMT IRA_AMT MTG_AMT HEQB_AMT HEQC_AMT CLN_AMT CARD_AMT BOLOC_AMT BALOC_AMT CLS_AMT MCC_AMT;*/
/*table web_band, (HH*SUM*F=comma6.)(DDA_AMT MMS_AMT SAV_AMT TDA_AMT IRA_AMT MTG_AMT HEQB_AMT HEQC_AMT CLN_AMT CARD_AMT BOLOC_AMT BALOC_AMT CLS_AMT MCC_AMT)*/
/** ( MEAN*F=DOLLAR12.);*/
/*run;*/

proc tabulate data=temp out= prod1;
where web_band ne 'xxxx';
class web_band;
var HH DDA MMS SAV TDA IRA TRS MTG HEQB HEQC CLN CARD BOLOC BALOC CLS WBB DEB MCC LCKBX RCD BBFB DDA_AMT MMS_AMT SAV_AMT TDA_AMT IRA_AMT MTG_AMT HEQB_AMT HEQC_AMT CLN_AMT CARD_AMT BOLOC_AMT BALOC_AMT CLS_AMT MCC_AMT;
table web_band, (HH*SUM*F=comma6.) (DDA MMS SAV TDA IRA TRS MTG HEQB HEQC CLN CARD BOLOC BALOC CLS MCC)* (SUM*F=comma6. PCTSUM<HH>*F=comma5.1) 
(DDA_AMT MMS_AMT SAV_AMT TDA_AMT IRA_AMT MTG_AMT HEQB_AMT HEQC_AMT CLN_AMT CARD_AMT BOLOC_AMT BALOC_AMT CLS_AMT MCC_AMT)* ( MEAN*F=DOLLAR12.);
run;

proc print data=prod1;
run;

PROC FORMAT;
PICTURE PCTPIC low-high='000%';
RUN;


proc tabulate data=temp out= prod1 ;
where web_band ne 'xxxx';
class web_band;
var HH DDA MMS SAV TDA IRA TRS MTG HEQB HEQC CLN CARD BOLOC BALOC CLS WBB DEB MCC LCKBX RCD BBFB DDA_AMT MMS_AMT SAV_AMT TDA_AMT IRA_AMT MTG_AMT HEQB_AMT HEQC_AMT CLN_AMT CARD_AMT BOLOC_AMT BALOC_AMT CLS_AMT MCC_AMT;
table  (HH*SUM*F=comma6.) (DDA MMS SAV TDA IRA TRS MTG HEQB HEQC CLN CARD BOLOC BALOC CLS MCC)* (SUM*F=comma6. PCTSUM<HH>*F=PCTPIC9.) 
(DDA_AMT MMS_AMT SAV_AMT TDA_AMT IRA_AMT MTG_AMT HEQB_AMT HEQC_AMT CLN_AMT CARD_AMT BOLOC_AMT BALOC_AMT CLS_AMT MCC_AMT)* ( MEAN*F=DOLLAR12.), web_band / NOCELLMERGE;
run;

proc freq data=temp;
table cbr*web_band;
run;


proc tabulate data=temp out=cbr1 (drop=_TYPE_ _PAGE_ _TABLE_) missing ;
where web_band ne 'xxxx';
class web_band cbr;
var hh;
table web_band,  cbr, hh*(SUM*F=comma6. PCTSUM<hh>*F=PCTPIC9.) / NOCELLMERGE;
/*format cbr $cbrfmtb.;*/
run;

proc print data=cbr1 noobs;
run;


proc tabulate data=temp out=band1 (drop=_TYPE_ _PAGE_ _TABLE_);
where web_band ne 'xxxx';
class web_band score_month;
var hh;
table web_band,  score_month, hh*(SUM*F=comma6. ) / NOCELLMERGE;
run;

proc print data=band1 noobs;
run;

proc tabulate data=temp out=sales1 (drop=_TYPE_ _PAGE_ _TABLE_);
where web_band ne 'xxxx';
class web_band sales_new;
var hh;
table web_band,  sales_new, hh*(SUM*F=comma6. ) / NOCELLMERGE;
format sales_new salesband.;
run;

proc print data=sales1 noobs;
run;

proc tabulate data=temp out=empl1 (drop=_TYPE_ _PAGE_ _TABLE_);
where web_band ne 'xxxx';
class web_band employee_new;
var hh;
table web_band,  employee_new, hh*(SUM*F=comma6. ) / NOCELLMERGE;
format employee_new emplband.;
run;

proc print data=empl1 noobs;
run;

filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Online\BB_CON.txt';

data bbseg.CONTRIB_NEW;
length HHID $ 9 ;     
;
infile mydata DLM='09'x firstobs=2 lrecl=4096  dsd;
	  INPUT hhID $  DDA MMS SAV TDA IRA MTG HEQB HEQC CLn CARD BOLOC BALOC CLS MCC;
run;

data temp_Contr;
merge temp (keep=hhid web_band hh in=a) bbseg.contrib_new (in=b);
by hhid;
if a;
run;

proc contents data=temp_contr varnum short;
run;

proc tabulate data=temp_contr out= contr1 ;
where web_band ne 'xxxx';
class web_band;
var HH DDA MMS SAV TDA IRA MTG HEQB HEQC CLn CARD BOLOC BALOC CLS MCC;
table  (HH*SUM*F=comma6.) (DDA MMS SAV TDA IRA MTG HEQB HEQC CLn CARD BOLOC BALOC CLS MCC)* (N*F=comma6. SUM*F=dollar12. MEAN*F=DOLLAR12.), web_band / NOCELLMERGE;
run;


proc print data=contr1 noobs;
run;

data temp;
merge bbseg.dda_cross (in=a) bbseg.hhdata_new (in=b keep=hhid web_band);
by hhid;
hh = 1;
run;



proc tabulate data=temp;
var CR6  CV0  CT2  CY2  CV7  CO2  CS2  CV2  CV6  CR2  CU2  CL3  Other hh;
class web_band;
table hh*sum='HHs'*f=comma12. (CR6  CV0  CT2  CY2  CV7  CO2  CS2  CV2  CV6  CR2  CU2  CL3  Other)*N='Prod HHs'*f=comma12. , web_band / nocellmerge;
run;


proc format library=sas;
value $chkstypecomm 'CL3' = 'Commercial Leased Security - Landlord'
					'CLE' = 'Commercial M&T Escrow Services'
					'CM2' = 'Commercial Non-Personal Checking'
					'CN2' = 'Commercial Municipal Investment NOW'
					'CO2' = 'Commercial IOLA NOW Checking'
					'CP2' = 'Commercial Corporate Non-Profit NOW'
					'CQ2' = 'Commercial Business Sweep'
					'CQ3' = 'Commercial Business Sweep II'
					'CR2' = 'Commercial Business Flex Checking'
					'CR6' = 'Commercial Business Free Checking'
					'CS2' = 'Commercial Non-Profit/Sole Proprietor NOW'
					'CT2' = 'Commercial Checking'
					'CT6' = 'Commercial Tailored Business Checking'
					'CU2' = 'Commercial Corporate Checking'
					'CU3' = 'Commercial Corporate Checking w/Interest'
					'CV0' = 'Commercial Advance Business Checking'
					'CV2' = 'Commercial Business Pro Checking'
					'CV6' = 'Commercial Business Checking 1'
					'CV7' = 'Commercial Business Checking 2'
					'CV8' = 'Commercial Business Checking 1 w/Interest'
					'CV9' = 'Commercial Business Checking 2 w/Interest'
					'CY2' = 'Commercial Non-Profit Checking'
					'Other' = 'Other';
run;

