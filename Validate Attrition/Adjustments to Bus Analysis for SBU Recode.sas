filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Validate Attrition\MaR12.txt';
data attr.data_201203;
length HHID $ 9 acct $ 28 ptype $ 3 stype $ 3 sbu $ 5 status $ 1;
infile mydata DLM='09'x firstobs=2  lrecl=4096 dsd OBS=max;
	  INPUT hhID $ acct $  ptype $  stype $  sbu $ status $ bal open_date :mmddyy10. ;
run;
*##############################################################################################;

data attr.dec_accts_bus_for_bal;
set dec_accts_bus;
where ptype in ('DDA','SAV','MMS','TDA','IRA') and sbu='BUS' and substr(stype,1,1) = 'C';
run;



proc sort data=attr.data_201112_new;
by acct;
run;
data merged_bus_dec;
merge attr.dec_accts_bus_for_bal (in=a) attr.data_201112_new (in=b keep=acct bal hhid sbu  rename=(bal=new_bal hhid=hhid_new sbu=sbu_new));
by acct;
if a and b;
run;

data merged_bus_jan;
merge attr.dec_accts_bus_for_bal (in=a) attr.data_201201 (in=b keep=acct bal hhid sbu  rename=(bal=new_bal hhid=hhid_new sbu=sbu_new));
by acct;
if a and b;
run;

proc sort data=attr.data_201203;
by acct;
run;

data merged_bus_mar;
merge attr.dec_accts_bus_for_bal (in=a) attr.data_201203 (in=b keep=acct bal hhid sbu Open_date rename=(bal=new_bal hhid=hhid_new sbu=sbu_new));
by acct;
if a and b;
run;

data merged_bus_apr;
merge attr.dec_accts_bus_for_bal (in=a) attr.data_201204 (in=b keep=acct bal hhid sbu  rename=(bal=new_bal hhid=hhid_new sbu=sbu_new));
by acct;
if a and b;
run;

%macro cycle;
%do i=1 %to 4;
	%if &i = 1 %then %let month = dec;
	%if &i = 2 %then %let month = jan;
	%if &i = 3 %then %let month = mar;
	%if &i = 4 %then %let month = apr;

	Title "Sum of Dec Tracjed Accouts as of &month";
	proc tabulate data=merged_bus_&month;
	where group eq 'WT' and ptype in ('DDA','SAV','MMS','TDA','IRA');
	class sbu sbu_new;
	var new_bal;
	table sbu, (sbu_new ALL)*sum*new_bal*f=dollar24.;
	run;
%end;
%mend cycle;

%cycle
 *##################################################################################;

data mar_accts_bus;
set attr.analysis_bus_201203;
/*where substr(acct,26,3) ne 'ELN';*/
run;

proc sort data=mar_accts_bus;
by acct;
run;

proc sort data=attr.data_201203;
by acct;
run;

proc freq data=attr.data_201203;
table sbu;
run;

data merged_bus;
merge dec_accts_bus (in=a) attr.data_201203 (in=b keep=acct bal hhid open_date rename=(bal=new_bal hhid=hhid_new));
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
PROC SORT data=attr.data_201203;
by hhid;
run;

data adjusted_data;
merge adjusted_hhs(in=a) attr.data_201203 (in=b);
by hhid;
if a and b;
run;


proc sort data=adjusted_data;
by acct;
run;

proc sort data=merged_bus_jan;
by acct;
run;

data adjusted_data1;
merge adjusted_data (in=a where=(ptype in ('DDA','SAV','MMS','TDA','IRA') and open_date ge '27aug2011'd and substr(stype,1,1)='C' AND SBU='BUS')) merged_bus_mar (in=b keep=acct);
by acct;
if a and not b;
new=1;
run;


data combined;
set merged_bus_jan (keep = hhid new_bal ptype stype group sbu sbu_new acct rename=(new_bal=bal1)) adjusted_data1 (rename=(sbu=sbu_new bal=bal1));
run;


proc tabulate data=combined missing;
where group = 'WT';
class sbu sbu_new new;
var bal1;
table new*sbu ALL,(sbu_new All)*sum*bal1*f=dollar24. / nocellmerge;
run;




data new_data_new_hh;
set new_data_new_hh;
by key;
hh_new=0;
if last.key then hh_new=1;
bal1_new = 0;
if PTYPE in('DDA','SAV','MMS','TDA','IRA') and sbu = "BUS" and SUBSTRN(STYPE,1,1)= 'C' then bal1_new = bal;
run;
