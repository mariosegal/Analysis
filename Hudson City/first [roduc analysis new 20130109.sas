*read data ;
proc fslist fileref='C:\Documents and Settings\ewnym5s\My Documents\acc2011.txt'; run;

options compress=yes;

data wip.f2011;
length hhid $ 9 key $ 28 ptype stype sbu $ 3 child $ 1;
infile 'C:\Documents and Settings\ewnym5s\My Documents\f2011.txt' dsd dlm='09'x missover lrecl=4096;
input hhid $ key $ date_open :mmddyy10. ptype stype sbu year month segment ixi_tot age child $;
format date_open mmddyy10.;
run;

data wip.f2012;
length hhid $ 9 key $ 28 ptype stype sbu $ 3 child $ 1;
infile 'C:\Documents and Settings\ewnym5s\My Documents\f2012.txt' dsd dlm='09'x missover lrecl=4096;
input hhid $ key $ date_open :mmddyy10. ptype stype sbu year month segment ixi_tot age child $;
format date_open mmddyy10.;
run;

data wip.acc2011;
length hhid $ 9 key $ 28 child1 $ 1;
infile 'C:\Documents and Settings\ewnym5s\My Documents\acc2011.txt' dsd dlm='09'x missover lrecl=4096;
input hhid $ key $ dob :mmddyy10.  segment1 ixi_tot1 age1 child1 $;
format dob mmddyy10.;
run;

data wip.acc2012;
length hhid $ 9 key $ 28 child1 $ 1;
infile 'C:\Documents and Settings\ewnym5s\My Documents\acc2012.txt' dsd dlm='09'x missover lrecl=4096;
input hhid $ key $ dob :mmddyy10.  segment1 ixi_tot1 age1 child1 $;
format dob mmddyy10.;
run;


*############################################################################################################;
*data clean-up and massaging;
*2011;
data clean2011;
set wip.f2011;
where ptype not in ('ATM',"DEB","WEB",'HBK');
where also (ptype in ('DDA','MMS','SAV','IRA','TDA') and substr(stype,1,1) = 'R') or (ptype not in ('DDA','MMS','SAV','IRA','TDA') and sbu='CON');
where also year = 2011;
where also ptype ne "CLN";
where also hhid ne '';
run;


proc freq data=clean2011;
table ptype;
run;

data order;
length ptype $ 3 order 3;
input ptype $ order;
datalines;
DDA 1
MMS 2
SAV 3
TDA 4
IRA 5
MTG 6
HEQ 7
CRD 8
ILN 9
CCS 10
IND 11
SEC 12
SDB 13
SLN 14
INS 15
TRS 16
CLN 99
;
run;

data clean2011;
length ptype $ 3 order 3;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set order end=eof1;
	dcl hash hh1 (dataset: 'order', hashexp: 8, ordered:'a');
	hh1.definekey('ptype');
	hh1.definedata('order');
	hh1.definedone();
end;
misses = 0;
do until (eof2);
	set clean2011 end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		order = .;
		misses+1;
	end;
	output;
end;
putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;

proc freq data=clean2011;
table order;
run;

proc sort data=clean2011;
by hhid date_open order month key;
run;

proc sort data=clean2011;
by hhid  key;
run;

data clean2011b;
set clean2011;
by hhid key;
if first.key then output;
run;

proc sort data=clean2011b;
by hhid date_open order month ;
run;

data first2011 other2011;
set clean2011b;
by hhid;
if first.hhid then output first2011;
if not first.hhid then output other2011;
run;


proc freq data=first2011;
table ptype;
run;

proc freq data=first2011;
table segment age child;
run;


*2012;
data clean2012;
set wip.f2012;
where ptype not in ('ATM',"DEB","WEB",'HBK');
where also (ptype in ('DDA','MMS','SAV','IRA','TDA') and substr(stype,1,1) = 'R') or (ptype not in ('DDA','MMS','SAV','IRA','TDA') and sbu='CON');
where also year = 2012;
where also ptype ne "CLN";
where also hhid ne '';
run;


proc freq data=clean2012;
table ptype;
run;

data clean2012;
length ptype $ 3 order 3;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set order end=eof1;
	dcl hash hh1 (dataset: 'order', hashexp: 8, ordered:'a');
	hh1.definekey('ptype');
	hh1.definedata('order');
	hh1.definedone();
end;
misses = 0;
do until (eof2);
	set clean2012 end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		order = 99;
		misses+1;
	end;
	output;
end;
putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;

proc sort data=clean2012;
by hhid date_open order month key;
run;

proc sort data=clean2012;
by hhid  key;
run;

data clean2012b;
set clean2012;
by hhid key;
if first.key then output;
run;

proc sort data=clean2012b;
by hhid date_open order;
run;

data first2012 other2012;
set clean2012b;
by hhid;
if first.hhid then output first2012;
if not first.hhid then output other2012;
run;


*append acct data, first for 2012 as that is where the issue is;
proc sort data=wip.acc2012;
by hhid key;
run;

proc sort data=first2012;
by hhid key;
run;

data first2012;
merge first2012 (in=a) wip.acc2012 (in=b);
by hhid key;
if a;
run;

proc freq data=first2012;
table segment*segment1 / missing norow nocol nopercent;
run;

proc sql;
select count(*) from first2012 where ixi_tot eq 0 ;
select count(*) from first2012 where ixi_tot eq 0 and ixi_tot1 not in (0,.);
run;

*I do not seem to have enough addtl IXI matches to make a difference;
*I will check now how  the mix looks, if the num,bers are too disparate then I will have to do only 2011 and be done with it, until we can fix the issue in datamart;

title '2011 New HH mix';
proc freq data=first2011;
table segment / missing;
format segment segfmt.;
run;

title '2012 New HH mix';
proc freq data=first2012;
table segment / missing;
format segment segfmt.;
run;

proc freq data=first2011 order=freq	;
table ptype*segment / missing nopercent norow; 
format ptype $ptypefmt.;
run;



proc freq data=first2012 order=freq	;
table ptype / missing; 
format ptype $ptypefmt.;
run;


proc format;
value quick . = 'missing';
      $quick '' - 'missing';
run;

proc freq data=wip.f2011;
table segment ixi age child;
run;

*looks bad, so I will do 2011;

*############################################################################################################;
*2011 Analsysis;


PROC SQL;
CREATE table cross2011 as 
select hhid, count(unique PTYPE) as prods_total from clean2011b  group by hhid;
CREATE table cross2011b as 
select hhid, count(unique PTYPE) as prods_addtl from other2011  group by hhid;
quit;

data first2011 ;
merge first2011 (in=a) cross2011 (in=b) cross2011b(in=c) ;
by hhid;
hh = 1;
if ptype = "CCS" and stype in ("REW","NOR","SIG") then PTYPE = "CRD";
if ptype = "ILN" and put(stype,$ilnstype.) = "Indirect" then ptype = "IND";
if a ;
run;

data other2011;
set other2011;
if ptype = "CCS" and stype in ("REW","NOR","SIG") then PTYPE = "CRD";
if ptype = "ILN" and put(stype,$ilnstype.) = "Indirect" then ptype = "IND";
run;


*create classdata dataset;
proc format library=sas cntlout=class1 (keep=start );
select $ptypefmt;
run;

data class1;
length ptype  $ 3;
set class1;
ptype=trim(start);
drop start;
run;



proc format library=sas cntlout=class2 (keep=start  );
select segfmt;
run;

data class2;
length segment 8;
set class2;
segment=start;
drop start;
run;


data class2;
set class2;
where segment ne -1;
run;

proc sql;
create table class as select a.*, b.* from class1 as a, class2 as b;
quit;

Title1 'First Product Joined in 2011';
Title2 ;
proc tabulate data=first2011  missing out=out2011_first classdata=class;
class ptype segment ;
var prods_total prods_addtl hh;
table (ptype='Product' ),(segment)*( hh='HHs'*sum*f=comma12. hh='HHs'*colpctsum<hh>*f=pctfmt. 
      (prods_total='Final Products'*pctsum<hh>*f=pctcomma. prods_addtl='Addtl Products'*pctsum<hh>*f=pctcomma.))
       / nocellmerge misstext='0';
format ptype $ptypefmt. segment segfmt.;
keylabel rowpctN = 'Average' colpctsum='Percent' sum='Total' rowpctsum='Average';
run;

data out2011_first;
set out2011_first;
prods_total_pctsum_11 = prods_total_pctsum_11/100;
prods_addtl_pctsum_11 = prods_addtl_pctsum_11/100;
hh_pctsum_01 = hh_pctsum_01/100;
Year=2011;
drop _:;
rename prods_total_pctsum_11=prods_total prods_addtl_pctsum_11=prods_addtl hh_sum = count hh_pctsum_01 = pct1;
run;

data combined;
set out2011_first ;
run;

proc sort data=combined;
by segment year;
run;

data combined;
set combined;
if segment eq 8 then segment = 1;
if segment eq 9 then segment = 4;
run;

*create charts for panel;
 
%macro charts();

proc catalog c=work.gseg kill; 
run; quit; 

ods html style=MTB;
goptions reset=all cback=white noborder  htext=10pt;  
goptions device=gif nodisplay xpixels=450 ypixels=300;

	%do i =1 %to 6;
		%let titl = %sysfunc(putn(&i,segfmt.));
		Title2 "&titl";
		axis1 label=none  minor=none major=none color=white value=none ;
		axis2 label=none  minor=none major=none  value=none ;
		axis3 value=(f="Albany AMT/bo") order=("Checking" "Indirect Loan" "Mortgage" "Savings" "Money Market" "Credit Card" ) label=none split=" ";
		proc gchart data=combined;
		where ptype in ("DDA","MMS","SAV","IND","MTG","SEC","CRD") and segment eq &i;
		vbar year / sumvar=pct1 group=ptype subgroup=year discrete outside=sum noframe raxis=axis1 width=20 maxis=axis2 gaxis=axis3 nolegend coutline=same;
		format pct1 percent6.1;
		run;
	%end;
%mend charts;

%charts()
;

*Panel is define in panel for segment first charts;

%panel(x=3,y=2,fileout=C:\Documents and Settings\ewnym5s\My Documents\Hudson City\first_cross.gif,x_size=1350,y_size=600)
;



proc tabulate data=first2011 missing;
class ptype segment;
table ptype All , (segment All)*(N*f=comma12. rowpctN*f=pctfmt.) / nocellmerge misstext='0';
format segment segfmt. ptype $ptypefmt. ;
run;


*2012 Analsysis;


PROC SQL;
CREATE table cross2012 as 
select hhid, count(unique PTYPE) as prods_total from clean2012b  group by hhid;
CREATE table cross2012b as 
select hhid, count(unique PTYPE) as prods_addtl from other2012  group by hhid;
quit;

data first2012 ;
merge first2012 (in=a) cross2012 (in=b) cross2012b(in=c) ;
by hhid;
hh = 1;
if ptype = "CCS" and stype in ("REW","NOR","SIG") then PTYPE = "CRD";
if ptype = "ILN" and put(stype,$ilnstype.) = "Indirect" then ptype = "IND";
if a then output first2012;
run;

data other2012;
set other2012;
if ptype = "CCS" and stype in ("REW","NOR","SIG") then PTYPE = "CRD";
if ptype = "ILN" and put(stype,$ilnstype.) = "Indirect" then ptype = "IND";
run;


*total page;
title '2011';
proc freq data=first2011 order=freq	;
table ptype / missing; 
format ptype $ptypefmt.;
run;


title'2012';
proc freq data=first2012 order=freq	;
table ptype / missing; 
format ptype $ptypefmt.;
run;

title '2011';
proc tabulate data=first2011 missing;
class ptype;
var prods_total prods_addtl hh;
table ptype='Product', hh='HHs'*sum*f=comma12. hh='HHs'*colpctsum<hh>*f=pctfmt. ( prods_total='Final Products'*rowpctsum<hh>*f=pctcomma. prods_addtl='Addtl Products'*rowpctsum<hh>*f=pctcomma.) / nocellmerge misstext='0';
format ptype $ptypefmt.;
keylabel rowpctN = 'Average' colpctsum='Percent' sum='Total' rowpctsum='Average';
run;

title '2012';
proc tabulate data=first2012 missing;
class ptype;
var prods_total prods_addtl hh;
table ptype='Product', hh='HHs'*sum*f=comma12. hh='HHs'*colpctsum<hh>*f=pctfmt. ( prods_total='Final Products'*rowpctsum<hh>*f=pctcomma. prods_addtl='Addtl Products'*rowpctsum<hh>*f=pctcomma.) / nocellmerge misstext='0';
format ptype $ptypefmt.;
keylabel rowpctN = 'Average' colpctsum='Percent' sum='Total' rowpctsum='Average';
run;
