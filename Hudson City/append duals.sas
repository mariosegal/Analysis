data duals;
length hhid $ 9 acct $ 28 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\duals.txt' dsd dlm='09'x lrecl=4096 firstobs=1;
input hhid $ acct $ ptype $ stype $ sbu $ hud_flag $ Balance open_date :mmddyy10.;
run;

data duals;
length acct_nbr $ 14;
set duals;
if hud_flag eq "Y" then acct_nbr = substr(acct,12,14);
run;

data hudson.duals;
set duals;
run;

data duals1;
set hudson.duals;
where hud_flag eq "Y";
dual = 1;
keep acct_nbr dual;
run;

proc sort data=duals1 out=duals2 nodupkey;
by acct_nbr;
run;


data temp;
set hudson.clean_20121106;
keep pseudo_hh acct_nbr;
run;


proc sort data=temp;
by acct_nbr;
run;

data merged;
merge temp(in=a) duals2(in=b);
by acct_nbr;
if a;
run;

data merged1;
set merged;
where dual eq 1;
keep pseudo_hh dual;
run;

proc sort data=merged1 out=merged2 nodupkey;
by pseudo_hh;
run;



data hudson.hudson_hh;
merge hudson.hudson_hh (in=a) merged2 ;
by pseudo_hh;
if a;
run;

proc freq data=hudson.hudson_hh;
table con1*dual / missing;
table bus1*dual / missing;
run;



*#####################;
*append the pseudo_hh to the dual flag so I can regroup  the m&T accts on the same basis;

*1. get pseudo_hh numbers for duals;

data dual_hh;
set hudson.hudson_hh (where = (dual eq 1));
keep pseudo_hh dual;
run;


/*data hudson.clean_20121106;*/
/*merge hudson.clean_20121106 (in=a) dual_hh (in=b);*/
/*by pseudo_hh;*/
/*if a;*/
/*run;*/


data hudson.clean_20121106;
length pseudo_hh 8 dual 8;

if _n_ eq 1 then do;
	set dual_hh end=eof1;
	dcl hash hh (dataset: 'dual_hh', hashexp: 8, ordered:'a');
	hh.definekey('pseudo_hh');
	hh.definedata('dual');
	hh.definedone();
end;

do until (eof2);
	set hudson.clean_20121106 end=eof2;
	if hh.find() ne 0 then dual=0;
	output;
end;

run;

data keys (drop=dual);
set hudson.clean_20121106(keep=pseudo_hh acct_nbr dual where=(dual eq 1));
run;


data hudson.duals;
length pseudo_hh 8 acct_nbr $ 14;

if _n_ eq 1 then do;
	set keys end=eof1;
	dcl hash hh (dataset: 'keys', hashexp: 8, ordered:'a');
	hh.definekey('acct_nbr');
	hh.definedata('pseudo_hh');
	hh.definedone();
end;

do until (eof2);
	set hudson.duals end=eof2;
	if hh.find() ne 0 then pseudo_hh=.;
	output;
end;

run;

proc freq data=hudson.duals (where=(pseudo_hh ne .));
table hud_flag;
run;



data keys2;
set hudson.duals;
where pseudo_hh ne .;
keep pseudo_hh hhid;
run;

proc sort data=keys2 nodupkey;
by pseudo_hh hhid;
run;

proc sort data=keys2 ;
by  hhid;
run;

data doubles;
set keys2;
by hhid;
if not(first.hhid and last.hhid) then check=1;
run;

proc freq data=doubles;
table check;
run;

proc freq data=doubles order=freq;
where check eq 1;
table hhid / out=x1;
run;

data keys_clean;
set keys2;
by hhid;
if first.hhid then output;
run;

*I took the first pseudo --, as it makes littel difference;

data hudson.duals;
length pseudo_hh 8 hhid $ 9 a 8;


if _n_ eq 1 then do;
	set keys_clean end=eof1;
	dcl hash hh (dataset: 'keys_clean', hashexp: 8, ordered:'a');
	hh.definekey('hhid');
	hh.definedata('pseudo_hh');
	hh.definedone();
end;

do until (eof2);
	set hudson.duals end=eof2;
	a = pseudo_hh;
	if hh.find()= 0 then output;
	if hh.find() ne 0 then do;
		pseudo_hh = a;
		output;
	end;
end;
drop a;
run;

proc sort data=hudson.duals;
by pseudo_hh ptype;
run;

proc summary data=hudson.duals (where=(hud_flag="N"));
by pseudo_hh ptype;
output out=duals_mtb 
       sum(balance) = balance
	   N(pseudo_hh) = count;
run;

proc transpose data=duals_mtb out=duals_mtb_count suffix=_mtb;
by pseudo_hh;
id ptype;
var count;
run;

%as_logical(dataset=duals_mtb_count,exclude=pseudo_hh)
%null_to_zero(dataset=duals_mtb_count)

proc transpose data=duals_mtb out=duals_mtb_bal suffix=_amt_mtb;
by pseudo_hh;
id ptype;
var balance;
run;

%null_to_zero(dataset=duals_mtb_bal)


data duals_mtb_merged;
merge duals_mtb_count (in=a drop= _name_) duals_mtb_bal(in=b drop= _name_);
by pseudo_hh;
if a and b;
run;

data duals_hudson;
set hudson.hudson_hh;
where dual eq 1;
run;

data hudson.dual_hh;
merge duals_hudson (in=a) duals_mtb_merged (in=b);
by pseudo_hh;
run;
