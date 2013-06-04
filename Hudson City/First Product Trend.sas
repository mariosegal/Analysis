*READ DATA;

options compress=yes;

data new2011;
length hhid $ 9 acct_key key $ 28 ptype $ 3 stype $ 3 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\fst2011.txt' dsd dlm='09'x missover firstobs=2;
input hhid $ open_date :mmddyy10. acct_key $ ptype $ stype $ db_month;
if ptype in ("DEB","ATM","WEB","HBK") then delete;
run;

data new2012;
length hhid $ 9 acct_key key $ 28 ptype $ 3 stype $ 3 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\fst2012.txt' dsd dlm='09'x missover firstobs=2;
input hhid $ open_date :mmddyy10. acct_key $ ptype $ stype $ db_month;
if ptype in ("DEB","ATM","WEB","HBK") then delete;
run;

%squeeze(new2011,data.new2011);
%squeeze(new2012,data.new2012);

data sbu2011;
length acct_key key $ 28 sbu $ 3 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\2011sbu.txt' dsd dlm='09'x missover firstobs=2;
input acct_key $ sbu $;
run;

data sbu2012;
length acct_key key $ 28 sbu $ 3 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\2012sbu.txt' dsd dlm='09'x missover firstobs=2;
input acct_key $ sbu $;
run;



data data.new2011;
length acct_key $ 28 sbu $ 3 ;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set sbu2011 end=eof1;
	dcl hash hh1 (dataset: 'sbu2011', hashexp: 8, ordered:'a');
	hh1.definekey('acct_key');
	hh1.definedata('sbu');
	hh1.definedone();
end;
misses = 0;
do until (eof2);
	set data.new2011 end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		sbu = 'XXX';
		misses+1;
	end;
	output;
end;
putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;

data data.new2012;
length acct_key $ 28 sbu $ 3 ;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set sbu2012 end=eof1;
	dcl hash hh1 (dataset: 'sbu2012', hashexp: 8, ordered:'a');
	hh1.definekey('acct_key');
	hh1.definedata('sbu');
	hh1.definedone();
end;
misses = 0;
do until (eof2);
	set data.new2012 end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		sbu = 'XXX';
		misses+1;
	end;
	output;
end;
putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;

* DO data processing;

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
CCS 8
ILN 9
SEC 10
SDB 11
SLN 12
INS 14
TRS 15
;
run;

data data.new2012;
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
	set data.new2012 end=eof2;
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

data data.new2011;
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
	set data.new2011 end=eof2;
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




proc sort data=data.new2011;
by hhid open_date order;
run;

proc sort data=data.new2012;
by hhid open_date order;
run;

data data.new2011;
set data.new2011;
exclude = 0;
if PTYPE in ('CLN',"CLS","FLP","MCC") then exclude = 1;
if  not (PTYPE in ("DDA","SAV","TDA","MMS","IRA")) and SBU ne "CON" then exclude = 1;
if PTYPE in ("DDA","SAV","TDA","MMS","IRA") and substr(STYPE,1,1) ne "R" then exclude = 1;
run;

data data.new2012;
set data.new2012;
exclude = 0;
if PTYPE in ('CLN',"CLS","FLP","MCC") then exclude = 1;
if  not (PTYPE in ("DDA","SAV","TDA","MMS","IRA")) and SBU ne "CON" then exclude = 1;
if PTYPE in ("DDA","SAV","TDA","MMS","IRA") and substr(STYPE,1,1) ne "R" then exclude = 1;
run;

proc format library=sas;
value $ ilnstype "ICA" = 'Indirect'
"IDS" = 'Indirect'
"IHI" = 'Indirect' 
"ILL" = 'Indirect' 
"IMH" = 'Indirect' 
"ISM" = 'Indirect' 
"CMT" = 'Indirect' 
"LCC" = 'Indirect' 
"LC1" = 'Indirect' 
"RWI" = 'Indirect' 
"SIA" = 'Indirect' 
"SIH" = 'Indirect' 
"SIS" = 'Indirect' 
"CGS" = 'Indirect' 
"LCR" = 'Indirect' 
"SCG" = 'Indirect' 
"CSI" = 'Indirect' 
"CGV"  = 'Indirect' 
other = 'Direct';
run;



*ANALYSIS;
data first2011 other2011;
set data.new2011;
where exclude eq 0;
by hhid;
if first.hhid then output first2011;
if not first.hhid then output other2011;
run;

data first2012 other2012;
set data.new2012;
where exclude eq 0;
by hhid;
if first.hhid then output first2012;
if not first.hhid then output other2012;
run;


PROC SQL;
CREATE table cross2011 as 
select hhid, count(unique PTYPE) as prods_total from data.new2011 where exclude eq 0 group by hhid;
CREATE table cross2012 as 
select hhid, count(unique PTYPE) as prods_total from data.new2012 where exclude eq 0 group by hhid;
CREATE table cross2011b as 
select hhid, count(unique PTYPE) as prods_addtl from other2011 where exclude eq 0 group by hhid;
CREATE table cross2012b as 
select hhid, count(unique PTYPE) as prods_addtl from other2012 where exclude eq 0 group by hhid;
quit;


*merge the cross-sell counts;

data first2011 bad2011;
merge first2011 (in=a) cross2011 (in=b) cross2011b(in=c) data.trend_extra_2011 (in=d);
by hhid;
hh = 1;
if ptype = "CCS" and stype in ("REW","NOR","SIG") then PTYPE = "CRD";
if ptype = "ILN" and put(stype,$ilnstype.) = "Indirect" then ptype = "IND";
if a then output first2011;
if a and not d then output bad2011;
run;

data other2011;
set other2011;
if ptype = "CCS" and stype in ("REW","NOR","SIG") then PTYPE = "CRD";
if ptype = "ILN" and put(stype,$ilnstype.) = "Indirect" then ptype = "IND";
run;



data first2012 bad2012;
merge first2012 (in=a) cross2012 (in=b) cross2012b(in=c) data.trend_extra_2012 (in=d);
by hhid;
hh =1;
if ptype = "CCS" and stype in ("REW","NOR","SIG") then PTYPE = "CRD";
if ptype = "ILN" and put(stype,$ilnstype.) = "Indirect" then ptype = "IND";
if a then output first2012;
if a and not d then output bad2012;
run;

data other2012;
set other2012;
if ptype = "CCS" and stype in ("REW","NOR","SIG") then PTYPE = "CRD";
if ptype = "ILN" and put(stype,$ilnstype.) = "Indirect" then ptype = "IND";
run;


*for 2012 I need to create my own segments, as somethign is fishy on datamart in 2012;
*also fro 2011 as who knows what datamart does;

data first2012;
set first2012;
age_calc = 2012 - year(dob);
if age_calc in (.,0) and age not in (.,0) then age_calc= age;
run;

data first2012;
set first2012;

segment_calc=7;
if age_calc not in (0, .) then do;
	if age_calc lt 35 then segment_calc = 1;
	else if age_calc ge 65 then do;
		* code retired;
		if ixi_tot ge 100000 then segment_calc = 6;
		else if ixi_tot lt 100000 and ixi_tot gt 0 then segment_calc = 5;
	end;
	else if age_calc ge 35 and age_calc lt 55 and ixi_tot ge 25000 and child ne "Y" then segment_calc=2;
	*next 2 lines code the people with kids in the 35 to 55 age range;
	else if age_calc ge 35 and age_calc lt 55 and ixi_tot ge 25000 and child eq "Y" then segment_calc=4;
	else if age_calc ge 35 and age_calc lt 55 and ixi_tot lt 25000 and ixi_tot gt 0 then segment_calc=3;
	*the rest are 3 or 4 depending on assets, I really do not even need the age part;
	else if age_calc ge 55 and ixi_tot ge 100000 then segment_calc=4;
	else if age_calc ge 55 and ixi_tot lt 100000 and ixi_tot gt 0 then segment_calc=3;
end;
run;

proc freq data=first2012;
table segment_calc*segment / norow nocol nopercent missing;
run;

data first2011;
set first2011;
age_calc = 2012 - year(dob);
run;

data first2011;
set first2011;

segment_calc=7;
if age_calc not in (0, .) then do;
	if age_calc lt 35 then segment_calc = 1;
	else if age_calc ge 65 then do;
		* code retired;
		if ixi_tot ge 100000 then segment_calc = 6;
		else if ixi_tot lt 100000 and ixi_tot gt 0 then segment_calc = 5;
	end;
	else if age_calc ge 35 and age_calc lt 55 and ixi_tot ge 25000 and child ne "Y" then segment_calc=2;
	*next 2 lines code the people with kids in the 35 to 55 age range;
	else if age_calc ge 35 and age_calc lt 55 and ixi_tot ge 25000 and child eq "Y" then segment_calc=4;
	else if age_calc ge 35 and age_calc lt 55 and ixi_tot lt 25000 and ixi_tot gt 0 then segment_calc=3;
	*the rest are 3 or 4 depending on assets, I really do not even need the age part;
	else if age_calc ge 55 and ixi_tot ge 100000 then segment_calc=4;
	else if age_calc ge 55 and ixi_tot lt 100000 and ixi_tot gt 0 then segment_calc=3;
end;
run;

proc freq data=first2011;
table segment_calc*segment / norow nocol nopercent missing;
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

data first2011;
set first2011;
segment_datamart = segment;
segment = segment_calc;
run;

data first2012;
set first2012;
segment_datamart = segment;
segment = segment_calc;
run;

  *claculate data for panel charts;
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

Title1 'First Product Joined in 2012';
Title2 ;
proc tabulate data=first2012 missing out=out2012_first classdata=class;
class ptype segment;
var prods_total prods_addtl hh;
table ptype='Product', (segment)*(hh='HHs'*sum*f=comma12. hh='HHs'*colpctsum<hh>*f=pctfmt. 
      (prods_total='Final Products'*pctsum<hh>*f=pctcomma. prods_addtl='Addtl Products'*pctsum<hh>*f=pctcomma.)) / nocellmerge misstext='0';
format ptype $ptypefmt. segment segfmt.;
keylabel rowpctN = 'Average' colpctsum='Percent' sum='Total' pctsum='Average';
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


data out2012_first;
set out2012_first;
prods_total_pctsum_11 = prods_total_pctsum_11/100;
prods_addtl_pctsum_11 = prods_addtl_pctsum_11/100;
hh_pctsum_01 = hh_pctsum_01/100;
drop _:;
Year=2012;
rename prods_total_pctsum_11=prods_total prods_addtl_pctsum_11=prods_addtl hh_sum = count hh_pctsum_01 = pct1;
run;

data combined;
set out2011_first out2012_first;
run;


proc sort data=combined;
by segment year;
run;

data combined;
set combined;
if segment eq 8 then segment = 1;
if segment eq 9 then segment = 4;
run;


	title;

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
		vbar year / sumvar=pct1 group=ptype subgroup=year discrete outside=sum noframe raxis=axis1 maxis=axis2 gaxis=axis3 nolegend coutline=same;
		format pct1 percent6.1;
		run;
	%end;
%mend charts;

%charts()
;

*Panel is define in panel for segment first charts;

%panel(x=3,y=2,fileout=C:\Documents and Settings\ewnym5s\My Documents\Hudson City\first_cross.gif,x_size=1350,y_size=600)
;

proc freq data=first2011;
table segment / missing;
format segment segfmt.;
run;

proc freq data=first2012;
table segment / missing;
format segment segfmt.;
run;

proc tabulate data=combined missing out=chartdata;
where segment not in (.,7);
class segment year;
var count;
table segment, year*(sum*count='HHs'*f=comma12. count*colpctsum<count>*f=pctfmt.) / nocellmerge misstext='0';
run;

data chartdata;
set chartdata;
count_pctsum_01 = count_pctsum_01/100;
rename count_pctsum_01 = percent1;
run;

*chart of acquisitionm ix year by year;
axis1 label=none  minor=none major=none color=white value=none ;
axis2 label=none  minor=none major=none  value=none ;
axis3 value=(f="Albany AMT/bo")  label=none split=" ";
proc gchart data=chartdata;
/*where ptype in ("DDA","MMS","SAV","IND","MTG","SEC","CRD") and segment eq &i;*/
vbar year / sumvar=percent1  discrete subgroup=year group=segment outside=sum   noframe raxis=axis1 maxis=axis2 gaxis=axis3 nolegend coutline=same;
format percent1 percent6.1  segment segfmt.;
run;


*below was from the first time without segment, when I did some splits like card seprately, since then I created new ptypes;


Title2 'DDA Detail';
proc tabulate data=first2011 missing;
where ptype eq 'DDA';
class stype;
var prods_total prods_addtl hh;
table stype='Product', hh='HHs'*sum*f=comma12. hh='HHs'*colpctsum<hh>*f=pctfmt. ( prods_total='Final Products'*rowpctsum<hh>*f=pctcomma. prods_addtl='Addtl Products'*rowpctsum<hh>*f=pctcomma.) / nocellmerge misstext='0';
format stype $stypefmt.;
keylabel rowpctN = 'Average' colpctsum='Percent' sum='Total' rowpctsum='Average';
run;


Title2 'Inst. Loan Detail';
proc tabulate data=first2011 missing;
where ptype eq 'ILN';
class stype;
var prods_total prods_addtl hh;
table stype='Product', hh='HHs'*sum*f=comma12. hh='HHs'*colpctsum<hh>*f=pctfmt. ( prods_total='Final Products'*rowpctsum<hh>*f=pctcomma. prods_addtl='Addtl Products'*rowpctsum<hh>*f=pctcomma.) / nocellmerge misstext='0';
format stype $ilnstype.;
keylabel rowpctN = 'Average' colpctsum='Percent' sum='Total' rowpctsum='Average';
run;

proc tabulate data=first2011 missing;
where ptype eq 'ILN';
class stype;
var prods_total prods_addtl hh;
table stype='Product', hh='HHs'*sum*f=comma12. hh='HHs'*colpctsum<hh>*f=pctfmt. ( prods_total='Final Products'*rowpctsum<hh>*f=pctcomma. prods_addtl='Addtl Products'*rowpctsum<hh>*f=pctcomma.) / nocellmerge misstext='0';
/*format stype $ilnstype.;*/
keylabel rowpctN = 'Average' colpctsum='Percent' sum='Total' rowpctsum='Average';
run;

Title2 'Credit Card Detail';
proc tabulate data=first2011 missing;
where ptype eq 'CCS' and STYPE in ("NOR","REW","SIG");
class stype;
var prods_total prods_addtl hh;
table stype='Product', hh='HHs'*sum*f=comma12. hh='HHs'*colpctsum<hh>*f=pctfmt. ( prods_total='Final Products'*rowpctsum<hh>*f=pctcomma. prods_addtl='Addtl Products'*rowpctsum<hh>*f=pctcomma.) / nocellmerge misstext='0';
format stype $cardstype.;
keylabel rowpctN = 'Average' colpctsum='Percent' sum='Total' rowpctsum='Average';
run;








Title2 'DDA Detail';
proc tabulate data=first2012 missing;
where ptype eq 'DDA';
class stype;
var prods_total prods_addtl hh;
table stype='Product', hh='HHs'*sum*f=comma12. hh='HHs'*colpctsum<hh>*f=pctfmt. ( prods_total='Final Products'*rowpctsum<hh>*f=pctcomma. prods_addtl='Addtl Products'*rowpctsum<hh>*f=pctcomma.) / nocellmerge misstext='0';
format stype $stypefmt.;
keylabel rowpctN = 'Average' colpctsum='Percent' sum='Total' rowpctsum='Average';
run;


Title2 'Inst. Loan Detail';
proc tabulate data=first2012 missing;
where ptype eq 'ILN';
class stype;
var prods_total prods_addtl hh;
table stype='Product', hh='HHs'*sum*f=comma12. hh='HHs'*colpctsum<hh>*f=pctfmt. ( prods_total='Final Products'*rowpctsum<hh>*f=pctcomma. prods_addtl='Addtl Products'*rowpctsum<hh>*f=pctcomma.) / nocellmerge misstext='0';
format stype $ilnstype.;
keylabel rowpctN = 'Average' colpctsum='Percent' sum='Total' rowpctsum='Average';
run;

proc tabulate data=first2012 missing;
where ptype eq 'ILN';
class stype;
var prods_total prods_addtl hh;
table stype='Product', hh='HHs'*sum*f=comma12. hh='HHs'*colpctsum<hh>*f=pctfmt. ( prods_total='Final Products'*rowpctsum<hh>*f=pctcomma. prods_addtl='Addtl Products'*rowpctsum<hh>*f=pctcomma.) / nocellmerge misstext='0';
/*format stype $ilnstype.;*/
keylabel rowpctN = 'Average' colpctsum='Percent' sum='Total' rowpctsum='Average';
run;


Title2 'Credit Card Detail';
proc tabulate data=first2012 missing;
where ptype eq 'CCS' and STYPE in ("NOR","REW","SIG");
class stype;
var prods_total prods_addtl hh;
table stype='Product', hh='HHs'*sum*f=comma12. hh='HHs'*colpctsum<hh>*f=pctfmt. ( prods_total='Final Products'*rowpctsum<hh>*f=pctcomma. prods_addtl='Addtl Products'*rowpctsum<hh>*f=pctcomma.) / nocellmerge misstext='0';
format stype $cardstype.;
keylabel rowpctN = 'Average' colpctsum='Percent' sum='Total' rowpctsum='Average';
run;




*cross matrix;
proc sort data=other2011;
by hhid ptype;
run;


proc summary data=other2011 ;
by hhid ptype;
output out=after2011
       N(exclude) = count;
run;

data after2011;
set after2011;
drop _:;
if count ge 1 then count=1;
run;

proc transpose data=after2011 out=after2011b (drop= _:);
by hhid;
id ptype;
var count;
run;

proc sort data=other2012;
by hhid ptype;
run;


proc summary data=other2012 ;
by hhid ptype;
output out=after2012
       N(exclude) = count;
run;

data after2012;
set after2012;
drop _:;
if count ge 1 then count=1;
run;

proc transpose data=after2012 out=after2012b (drop= _:);
by hhid;
id ptype;
var count;
run;


data first2011 bad;
merge first2011 (in=a) after2011b (in=b);
by hhid;
if a then output first2011;
if b and not a then output bad;
run;

data first2012 bad;
merge first2012 (in=a) after2012b (in=b);
by hhid;
if a then output first2012;
if b and not a then output bad;
run;

proc contents data=first2011 varnum short;
run;


proc tabulate data=first2011 missing out=x2011 (where=(dda or mms or sav or tda or ira or mtg or heq or ccs or iln or sdb or ins or sec or trs or crd or ind));
class ptype DDA MMS  SAV   TDA IRA  MTG HEQ CCS ILN SDB  SEC  INS TRS CRD IND;
var hh;
table ptype , sum*hh='HHs' (DDA MMS  SAV TDA IRA  MTG HEQ CRD CCS ILN IND SDB  SEC INS TRS)*rowpctN / nocellmerge misstext='0';
keylabel sum=' ' rowpctN=' ' rowpctsum=' ';
run;


proc tabulate data=first2012 missing out=x2012 (where=(dda or mms or sav or tda or ira or mtg or heq or ccs or iln or sdb or ins or sec or trs or crd or ind));
class ptype DDA MMS  SAV   TDA IRA  MTG HEQ CCS ILN SDB  SEC  INS TRS CRD IND;
var hh;
table ptype , sum*hh='HHs' (DDA MMS  SAV TDA IRA  MTG HEQ CRD CCS ILN IND SDB  SEC INS TRS)*rowpctN / nocellmerge misstext='0';
keylabel sum=' ' rowpctN=' ' rowpctsum=' ';
run;

data x2011;
set x2011;
if dda then x='DDA';
if mms then x='MMS';
if sav then x='SAV';
if tda then x='TDA';
if ira then x='IRA';
if mtg then x='MTG';
if heq then x='HEQ';
if ccs then x='CCS';
if iln then x='ILN';
if sdb then x='SDB';
if sec then x='SEC';
if ins then x='INS';
if trs then x='TRS';
if crd then x='CRD';
if ind then x='IND';
Year='2011';
rename PctN_1000000000000000=PCT1 ptype = y;
RUN;

data x2012;
set x2012;
if dda then x='DDA';
if mms then x='MMS';
if sav then x='SAV';
if tda then x='TDA';
if ira then x='IRA';
if mtg then x='MTG';
if heq then x='HEQ';
if ccs then x='CCS';
if iln then x='ILN';
if sdb then x='SDB';
if sec then x='SEC';
if ins then x='INS';
if trs then x='TRS';
if crd then x='CRD';
if ind then x='IND';
Year='2012';
rename PctN_1000000000000000=PCT1 ptype = y;
RUN;

data extra;
do k=1 to 2;
	if k =1 then Year='2011';
	if k = 2 then year ='2012';
do i = 1 to 15;
	if i eq 1 then  y='DDA';
	if i eq 2 then  y='MMS';
	if i eq 3 then  y='SAV';
	if i eq 4 then  y='TDA';
	if i eq 5 then  y='IRA';
	if i eq 6 then  y='MTG';
	if i eq 7 then  y='HEQ';
	if i eq 8 then  y='CRD';
	if i eq 9 then  y='CCS';
	if i eq 10 then  y='ILN';
	if i eq 11 then  y='IND';
	if i eq 11 then  y='SDB';
	if i eq 12 then  y='SEC';
	if i eq 13 then  y='TRS';
	if i eq 14 then  y='INS';
	do j = 1 to 15;
		if j eq 1 then  x='DDA';
		if j eq 2 then  x='MMS';
		if j eq 3 then  x='SAV';
		if j eq 4 then  x='TDA';
		if j eq 5 then  x='IRA';
		if j eq 6 then  x='MTG';
		if j eq 7 then  x='HEQ';
		if j eq 8 then  x='CRD';
		if j eq 9 then  x='CCS';
		if j eq 10 then  x='ILN';
		if i eq 11 then  x='IND';
		if j eq 12 then  x='SDB';
		if j eq 13 then  x='SEC';
		if j eq 14 then  x='TRS';
		if j eq 15 then  x='INS';
		pct1 = 0;
		output;
	end;
end;
end;
drop i j k;
run;



data cross;
set x2011 x2012 extra;
pct1=pct1/100;
keep x y pct1 year;
run;


	

/**/
/*proc sgpanel data=cross;*/
/*panelby x y / layout=lattice rows=13 columns=13;*/
/*vbar Year / response=pct1;*/
/*format pct1 percent6.1;*/
/*run;*/


options mcompilenote=all;
%macro create_panel_charts1 (xsize=,ysize=, file=, group1=, order1=, sumvar=);
proc sql;
select min((ceil(max(&sumvar)*10)/10)+ 0.2,1.2) into :max1 from &file;
quit;


proc catalog c=work.gseg kill; 
run; quit; 

ods html style=MTB;
goptions reset=all cback=white noborder htitle=14pt htext=12pt;  
goptions device=gif nodisplay xpixels=&xsize ypixels=&ysize;

%do i = 1 %to 15;
	%if &i eq 1 %then %let yname=DDA;
	%if &i eq 2 %then %let yname=MMS;
	%if &i eq 3 %then %let yname=SAV;
	%if &i eq 4 %then %let yname=TDA;
	%if &i eq 5 %then %let yname=IRA;
	%if &i eq 6 %then %let yname=MTG;
	%if &i eq 7 %then %let yname=HEQ;
	%if &i eq 8 %then %let yname=CRD;
	%if &i eq 9 %then %let yname=CCS;
	%if &i eq 10 %then %let yname=ILN;
	%if &i eq 11 %then %let yname=IND;
	%if &i eq 12 %then %let yname=SDB;
	%if &i eq 13 %then %let yname=SEC;
	%if &i eq 14 %then %let yname=TRS;
	%if &i eq 15 %then %let yname=INS;

	%do j = 1 %to 15;
		%if &j eq 1 %then %let xname=DDA;
		%if &j eq 2 %then %let xname=MMS;
		%if &j eq 3 %then %let xname=SAV;
		%if &j eq 4 %then %let xname=TDA;
		%if &j eq 5 %then %let xname=IRA;
		%if &j eq 6 %then %let xname=MTG;
		%if &j eq 7 %then %let xname=HEQ;
		%if &j eq 8 %then %let xname=CRD;
		%if &j eq 8 %then %let xname=CCS;
		%if &j eq 9 %then %let xname=ILN;
		%if &j eq 10 %then %let xname=IND;
		%if &j eq 11 %then %let xname=SDB;
		%if &j eq 12 %then %let xname=SEC;
		%if &j eq 13 %then %let xname=TRS;
		%if &j eq 14 %then %let xname=INS;

		%if &i eq 1 %then %do;
			%let xname1 = %sysfunc(putc(&xname,$ptypefmt.));
			title1 "&xname1";
		%end;
		%if &i ne 1 %then %do;
			title1 ;
		%end;
		%if &j eq 1 %then %do;
			%let yname1 = %sysfunc(putc(&yname,$ptypefmt.));
			axis1 label=(angle=90 f="Arial / bo" justify=center color=black height=14pt "&yname1")  minor=none major=none color=white value=none order=(0 to &max1 by 0.1) split=' '; 
		%end;
		%if &j ne 1 %then %do;
			axis1 label=none  minor=none major=none color=white value=none order=(0 to &max1 by 0.1); 
		%end;
		axis2 label=none  minor=none major=none value=none order=(&order1);
		
	
		proc gchart data=&file(where=(y="&yname" and x="&xname")) gout=work.gseg;
		vbar &group1 / sumvar=&sumvar subgroup=&group1 discrete raxis=axis1 width=35 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe coutline=same;
		format &sumvar percent8.0;
		run;
		quit;
	%end;
	 title1 ;
      %if &i eq 1 %then %do;
		title1 'Avg. Products';
	%end;

%end;
%mend create_panel_charts1;

%create_panel_charts1 (xsize=250, ysize=150, file=cross, group1=year, order1 = "2011" "2012",sumvar=pct1)

;

%custom_panel(x=15,y=15,fileout=C:\Documents and Settings\ewnym5s\My Documents\Hudson City\first_cross.gif,x_size=3750,y_size=2250)

;
