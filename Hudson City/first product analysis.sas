*1 Read the files with the consumer HHS in 200912 and 201012;

options compress=yes;

data hudson.hh_200912;
length hhid $ 9 flag_200912 3;
infile 'C:\Documents and Settings\ewnym5s\My Documents\200912.txt' dlm='09'x dsd firstobs=1 missover;
input hhid $;
flag_200912 = 1;
run;

data hudson.hh_201012 ;
length hhid $ 9 flag_201012 3;
infile 'C:\Documents and Settings\ewnym5s\My Documents\201012.txt' dlm='09'x dsd firstobs=1 missover;
input hhid $;
flag_201012 = 1;
run;


*merge with the 2001209 dataset;
*I will use hash objects for one and traditional merge for other to test;

data data.main_201209;
length hhid $ 9 flag_200912 8 rc 3;


if _n_ eq 1 then do;
	set hudson.hh_200912 end=eof1;
	dcl hash hh1 (dataset: 'hudson.hh_200912', hashexp: 8, ordered:'a');
	hh1.definekey('hhid');
	hh1.definedata('flag_200912');
	hh1.definedone();
end;

do until (eof2);
	set data.main_201209 end=eof2;
	rc=  hh1.find();
	if rc ne 0 then flag_200912 = 0;
	output;	
/*	if hh1.find() ne 0 then  do;*/
/*		pseudo_hh = .;*/
/*		dual=.;*/
/*		output;*/
/*	end;*/
end;
drop rc;
run;


data data.main_201209;
merge data.main_201209(in=a) hudson.hh_201012 (in=b);
by hhid;
if a and not b then do;
	flag_201012=0;
end;
if a then output;
run;


proc freq data=data.main_201209;
table flag_200912*flag_201012 / missing;
run;

*I need to identify the oldest acct open date, type and stype, not including deb,web or atm.;

proc sort data=union.accts_201209;
by key;
run;


data dates ;
length  key $ 28 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\dates.txt' dlm='09'x dsd firstobs=1 missover;
input  key $ open_date:mmddyy10.;
run;

proc sort data=dates;
by key;
run;

data union.accts_201209;
length key  $ 28 open_date 8 rc 3;


if _n_ eq 1 then do;
	set dates end=eof1;
	dcl hash hh1 (dataset: 'dates', hashexp: 8, ordered:'a');
	hh1.definekey('key');
	hh1.definedata('open_date');
	hh1.definedone();
end;

do until (eof2);
	set union.accts_201209 end=eof2;
	rc=  hh1.find();
	if rc ne 0 then open_date = .;
	output;	
/*	if hh1.find() ne 0 then  do;*/
/*		pseudo_hh = .;*/
/*		dual=.;*/
/*		output;*/
/*	end;*/
end;
drop rc;
run;

proc sort data=union.accts_201209;
by hhid open_date;
run;

data accts;
set union.accts_201209;
where not (ptype in ('DEB','WEB','ATM','HBK')) and 
       ( (ptype in ('DDA',"MMS","SAV","TDA","IRA") and substr(stype,1,1)="R") or (not(ptype in ('DDA',"MMS","SAV","TDA","IRA")) and sbu="CON"));
keep key open_date stype sbu ptype hhid;
run;

proc freq data=accts;
table ptype / out=ptype;
run;

proc format;
value $ ptype 'DDA' = 1
'MMS' = 2
'SAV' = 3
'TDA' = 4
'IRA' = 5
'MTG' = 6
'HEQ' = 7
'CCS' = 8
'ILN' = 9
'SEC' = 10
'INS' = 11
'SDB' = 12
'SLN' = 13
'TRS' = 14
'CLN' = 15;
run;

data accts;
set accts;
order = put(ptype,$ptype.);
run;

proc sort data=accts;
by hhid open_date order;
run;

* lost a lot of code, but the matching was done and appended to main.201209;

data data.main_201209;
set data.main_201209;
if group1 eq '2011+' and source ne 'ALLMNT' then group1 = 'WT';
run;

proc sql;
select group1, count(*) from data.main_201209 group by group1;
quit;

*mark as bad those that supposed to join but I see older accts;
data data.main_201209;
set data.main_201209;
if group1 eq '2010' and open_date lt '01JAN2010'd then exclude = 1;
if group1 eq '2011+' and open_date lt '01JAN2011'd then exclude = 1;
run;


*do analysis;

title 'First Product';
proc freq data=data.main_201209 order=freq;
where group1 ne 'WT' and group1 ne 'weird' and ptype ne '' and exclude ne 1;
table ptype*group1 / missing norow nopercent nofreq;
run;


