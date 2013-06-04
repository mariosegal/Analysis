

%macro new_bals;

proc sort data=dec_accts_bus;
by acct;
run;

proc sort data=attr.data_&period;
by acct;
run;


data merged_bus;
merge dec_accts_bus (in=a) attr.data_&period (in=b keep=acct bal hhid open_date rename=(bal=new_bal hhid=hhid_new));
by acct;
if a and b;
run;

proc sort data=merged_bus;
by hhid;
run;

data merged_bus;
set merged_bus;
by hhid;
hh_new=0;
if last.hhid then hh_new=1;
bal1_new = 0;
if PTYPE in('DDA','SAV','MMS','TDA','IRA') and sbu = "BUS" and SUBSTRN(STYPE,1,1)= 'C' then bal1_new = new_bal;
/*bal1_new has only balances for Deposits, otherwise zeros, easier to sum that way on tabulate */
run;

proc sort data= attr.dec_accts_bus_for_bal;
by acct;
run;

data merged_bus_&period;
merge attr.dec_accts_bus_for_bal (in=a) attr.data_&period (in=b keep=acct bal hhid sbu  rename=(bal=new_bal hhid=hhid_new sbu=sbu_new));
by acct;
if a and b;
run;
*#######################################################################;
*find new accts in other HHs and get their balances, then combine and measure all;

data temp ;
set merged_bus ;
keep hhid hhid_new group ;
run;

proc sort data=temp;
by hhid hhid_new ;
run;


proc sort data=temp out=hh_lookup nodupkey;
by hhid hhid_new;
run;

proc summary data=hh_lookup;
by hhid;
output out=temp2 (drop=_TYPE_);
run;


proc sort data=hh_lookup (drop=hhid_new) out=old_hhs nodupkey;
by hhid group;
run;


proc sort data=hh_lookup (drop=hhid) out=new_hhs (rename=(hhid_new=hhid)) nodupkey;
by hhid_new group;
run;



data adjusted_hhs;
set new_hhs old_hhs;
run;


proc sort data=adjusted_hhs nodupkey;
by hhid group;
run;

*get the data for the adjusted HHs, this contains more accts that I need but I i will  combine with the accts we are trackign and dedupe;
PROC SORT data=attr.data_&period;
by hhid;
run;

data adjusted_data;
merge adjusted_hhs(in=a) attr.data_&period (in=b);
by hhid;
if a and b;
run;


proc sort data=adjusted_data;
by acct;
run;

proc sort data=merged_bus_&period;
by acct;
run;

data adjusted_data1;
merge adjusted_data (in=a where=(ptype in ('DDA','SAV','MMS','TDA','IRA') and open_date ge '27aug2011'd and substr(stype,1,1)='C' AND SBU='BUS')) 
      merged_bus_&period (in=b keep=acct);
by acct;
if a and not b;
new=1;
run;


data combined;
set merged_bus_&period (keep = hhid new_bal ptype stype group sbu sbu_new acct rename=(new_bal=bal1)) adjusted_data1 (rename=(sbu=sbu_new bal=bal1));
run;

title "Results for &Month New - Balances";
proc tabulate data=combined missing;
where group = 'WT';
class sbu sbu_new new;
var bal1;
table new*sbu ALL,(sbu_new All)*sum*bal1*f=dollar24. / nocellmerge;
run;

title1 "&month 2012 Corrected";
proc tabulate data=merged_bus;
where group ne 'MT';
class group;
var hh hh_new bal1 bal1_new;
table group,  hh_new*(SUM*f=comma12.) ;
/*bal1*(SUM*f=dollar21.) bal1_jan*(SUM*f=dollar21.);*/
run;

title1;
proc tabulate data=merged_bus;
where group ne 'WT';
/*class group;*/
var hh hh_new bal1 bal1_new;
table ALL,  hh_new*(SUM*f=comma12.) ;
keylabel ALL = 'M&T';
/*bal1*(SUM*f=dollar21.) bal1_jan*(SUM*f=dollar21.);*/
run;
%mend new_bals;


*this data step does not need to be modified, or rerun as long as the data set exists;
data dec_accts_bus;
set attr.analysis_bus_201112;
/*where substr(acct,26,3) ne 'ELN';*/
run;
*this data step does not need to be modified, or rerun as long as the data set exists;
data attr.dec_accts_bus_for_bal;
set dec_accts_bus;
where ptype in ('DDA','SAV','MMS','TDA','IRA') and sbu='BUS' and substr(stype,1,1) = 'C';
run;

%let period = 201204;
%let month = apr;
%new_bals




filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Validate Attrition\apr_clsd.txt';
data apr_clsd;
length HHID $ 9 acct $ 28 ptype $ 3 stype $ 3 sbu $ 5 status $ 1 ;
infile mydata DLM='09'x firstobs=2  lrecl=4096   dsd obs=max ;
	  INPUT hhID $ acct $  ptype $  stype $  sbu $ status $ bal  open_date :mmddyy10. ;
run;


data attr.data_201204;
set attr.data_201204 apr_clsd;
run;


proc format ;
value quick low-<0 = 'Negative'
				0 = 'Zero'
	        0<-high = 'Positive';
			run;

			proc freq data=attr.data_201204;
			table status*bal;
			format bal quick.;
			run;


proc tabulate data=attr.data_201204;
where ptype in ('DDA','SAV','MMS','TDA','IRA') and status = 'X' and bal lt 0;
class  status ;
var bal;
table status ALL, bal*(sum N);
;
run;

proc sort data=apr_clsd;
by ptype;
run;


proc means data=apr_clsd;
by ptype;
var bal;
run;
