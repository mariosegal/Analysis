* file for jeremy to code MTG HE;

data _null_;
file 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\jeremy.txt' dsd dlm='09'x;
set hudson.mtg hudson.he ;
put acct add1 add2 add3 product;
run;

*read standardized file from jeremy;
data standard;
LENGTH acct $ 12 street_std $ 50 city_std $ 25 state_std $ 2 ZIP5_std $ 5;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\jeremy2.txt' dsd dlm='09'x firstobs=2 lrecl=4096 obs=max;
input acct a1 $ a2 $ a3 $ product $ street_std $  city_std $  state_std $  ZIP5_std $ ;
mykey = catx('*',street_std,city_std,state_std,zip5_std);
drop a1 a2 a3;
if mykey eq '' then delete;
run;

*match back;
data mtg he;
set standard;
if product eq 'mtg' then output mtg;
if product eq 'he' then output he;
run;

proc sort data=hudson.mtg;
by acct;
run;

proc sort data=mtg;
by acct;
run;

data hudson.mtg;
merge hudson.mtg (in=a) mtg (in=b drop=product);
by acct;
if a;
run;

proc sort data=hudson.he;
by acct;
run;

proc sort data=he;
by acct;
run;

data hudson.he;
merge hudson.he (in=a) he (in=b drop=product);
by acct;
if a;
run;

*clear an empty row;
data hudson.he;
set hudson.he;
if acct eq '' then delete;
run;

data hudson.mtg;
set hudson.mtg;
if acct eq '' then delete;
run;

* create the key for the sav and dda files;
data hudson.sav;
set hudson.sav (obs=max);
zip_part = substr(address_key,1,9);
addr_part = upcase(substr(address_key,10));
zip5 = substr(zip_part,1,5);
zip4 = substr(zip_part,6,4);
if zip5 ne '' and verify(trim(zip5),'1234567890')eq 0 then do;
city = upcase(zipcity(zip5));
if length(city)  gt 4 then city = substr(city,1,length(city)-4);
state= zipstate(zip5);
end;
run;

data hudson.dda ;
set hudson.dda (obs=max);
zip_part = substr(address_key,1,9);
addr_part = upcase(substr(address_key,10));
zip5 = substr(zip_part,1,5);
zip4 = substr(zip_part,6,4);
if zip5 ne '' and verify(trim(zip5),'1234567890') eq 0 then do;
city = upcase(zipcity(zip5));
if length(city)  gt 4 then city = substr(city,1,length(city)-4);
state= zipstate(zip5);
end;
run;

*check how many cases I get a state and no city;
proc sql;
select count(*) as dda from hudson.dda where city ='' and state ne '';
select count(*) as sav from hudson.dda where city ='' and state ne '';
quit;

*very few, some were in the US bust most were foreign addresses where the post code was nu,eric and passed my test;

*I will create a simple key by address, with street address * city * state * zip;
* ex: 36 CLAY HILL RD*STAMFORD*CT*06905;
data hudson.dda;
set hudson.dda;
mykey = catx('*',addr_part,city,state,zip5);
run;

data hudson.sav;
set hudson.sav;
mykey = catx('*',addr_part,city,state,zip5);
run;

*create new tyope variable that is numeric, and clkean summary lines I had not seen;

data hudson.dda;
length type1 3;
set hudson.dda;
if find(type,'total','it') ne 0  or find(type,'grand','it') ne 0then delete;
type1 = type;
run;

data hudson.sav;
length type1 3;
set hudson.sav;
if find(type,'total','it') ne 0  or find(type,'grand','it') ne 0then delete;
type1 = type;
run;



*standardize dda and sav addresses;

data _null_;
file 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\jeremy_new.txt' dsd dlm='09'x;
set hudson.dda hudson.sav;
put acct product addr_part zip5 zip4 city state;
run;


*read standardized file from jeremy;
data standard_dda_sav;
LENGTH acct $ 12 product $ 3 street_std $ 50 city_std $ 25 state_std $ 2 ZIP5_std $ 5 zip4_std $ 4;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\jeremy_new2.txt' dsd dlm='09'x firstobs=2 lrecl=4096 obs=max;
input acct product a1 $ a2 $ a3 a4 $ a5 $  street_std $  city_std $  state_std $  ZIP5_std $ zip4_std $;
mykey = catx('*',street_std,city_std,state_std,zip5_std);
drop a1 a2 a3 a4 a5;
if mykey eq '' then delete;
run;

*match back to dda and aav;
data dda sav;
set standard_dda_sav;
if product eq 'dda' then output dda;
if product eq 'sav' then output sav;
run;

proc sort data=hudson.dda;
by acct;
run;

proc sort data=dda;
by acct;
run;

data hudson.dda;
merge hudson.dda (in=a drop=mykey) dda (in=b drop=product);
by acct;
if a;
run;

proc sort data=hudson.sav;
by acct;
run;

proc sort data=sav;
by acct;
run;

data hudson.sav;
merge hudson.sav (in=a ) sav (in=b drop=product);
by acct;
if a;
run;




data hudson.combined;
set hudson.sav (keep=acct mykey bal_june open type1 product rename=(bal_june=balance)) 
    hudson.dda (keep=acct mykey bal_june open type1 product rename=(bal_june=balance)) 
    hudson.mtg (keep= product mykey acct balance open_date state type subtype maturity  rename=(open_date=open type=type1))
    hudson.he (keep= product mykey acct balance open_date state type subtype maturity  rename=(open_date=open type=type1));
run;

proc freq data=hudson.combined;
table product;
run;


proc sort data=hudson.combined;
by descending mykey;
run;


proc sort data=hudson.combined (keep=mykey) out=keys nodupkey;
by mykey;
run;

data keys;
set keys;
if mykey eq '' then delete;
run;

data keys;
set keys;
hhid1 = _N_;
run;

proc sort data=hudson.combined;
by  mykey;
run;

data hudson.combined;
merge hudson.combined (in=a) keys (in=b);
by mykey;
if a;
run;

*I need to recategorize some dda as mms, based on the codes they gave me, or I am not being fair.;
data hudson.combined;
length sbu $ 3;
set hudson.combined;
if product eq 'dda' and type1 eq 12 then product = 'mms';
if product eq 'dda' and type1 eq 15 then product = 'mms';
sbu='con';
if product in  ('dda','mms') and type1 in (15 10 5 13 7) then sbu = 'bus';
run;

proc freq data=hudson.combined;
where product not in ('sav' 'mtg' 'he');
table sbu*product*type1 / missing nocol norow nopercent;
run;

proc freq data=hudson.combined;
where product  in ('sav' 'mtg' 'he');
table sbu*product/ missing nocol norow nopercent;
run;

proc freq data=hudson.combined;
where sbu='con';
table product;
run;

*do data processing;

*code bus products';
data hudson.combined;
set hudson.combined;
sbu='con';
if (product eq 'mms' and type1 eq 15) or (product eq 'dda' and type1 in (10 5 7 13)) then sbu='bus';
run;

proc freq data=hudson.combined;
table sbu*product*type1;
run;

*This is where the analysis starts, before it was all one time stuff *;

proc summary data=hudson.combined noprint;
where sbu='con';
by hhid1;
class product ;
output out=summary

	   N(type1) = accts
       sum(balance) = balance;
run;
	

data summary;
set summary;
where _type_ ne 0;
run;

proc transpose data=summary out=summary1 suffix=_bal;
by hhid1;
id product;
var  balance;
run;

proc transpose data=summary out=summary2 suffix=_accts;
by hhid1;
id product;
var  accts;
run;

data summary3;
merge summary2 (in=a drop=_name_) summary1 (in=b drop=_name_);
by hhid1;
run;

data summary4;
set summary3;
if dda_accts eq . then dda_accts =0;
dda = min(dda_accts, 1);
if sav_accts eq . then sav_accts =0;
sav = min(sav_accts, 1);
if mtg_accts eq . then mtg_accts =0;
mtg = min(mtg_accts, 1);
if he_accts eq . then he_Accts =0;
he = min(he_Accts, 1);
if mms_accts eq . then mms_Accts =0;
mms = min(mms_Accts, 1);
hh = 0;
if last.hhid1 then hh = 1;
by hhid1;
dda1 = dda;
sav1 = sav;
mtg1 = mtg;
mms1=mms;
he1=he;
run;

data summary4;
set summary4;
if dda_bal eq . then dda_bal=0;
if mms_bal eq . then mms_bal=0;
if sav_bal eq . then sav_bal=0;
if mtg_bal eq . then mtg_bal=0;
if he_bal eq . then he_bal=0;
run;



proc format;
value mybal (notsorted) low-<0 = 'Negative'
            0 = 'Zero'
			. = 'Zero'
			other = 'Positive';
run;

Title 'Summary of Hudson City Data';
proc tabulate data=summary4 missing;
where hhid1 ne .;
class dda1 sav1 mtg1 he1 mms1 ;
var dda_accts sav_accts he_accts mtg_accts dda_bal sav_bal he_bal mtg_bal hh dda sav mtg he mms_accts mms_bal mms;
table  sum="HHs"*(hh dda mms sav mtg he )*f=comma12. sum="Accts"*(dda_accts mms_accts sav_accts mtg_accts he_accts)*f=comma12. 
                    pctsum<hh>='Penetration'*(dda mms sav mtg he) mean="Avg. Accts"*(dda_accts mms_accts sav_accts mtg_accts he_accts)*f=comma6.1
                    sum="Balances"*(dda_bal mms_bal sav_bal mtg_bal he_bal)*f=dollar24. mean="Avg. Balance"*(dda_bal mms_bal sav_bal mtg_bal he_bal)*f=dollar24.
					, dda1 mms1 sav1 mtg1 he1 all;
format dda1 sav1 mms1 mtg1 he1 binary_flag.;
run;

/*data hudson.combined;*/
/*set hudson.combined;*/
/*bal1 = balance;*/
/*run;*/


Title 'Balance distribution for Hudson Accts';
proc tabulate data=hudson.combined out=hudson_bal1;
class product bal1;
var balance;
table bal1*(N colpctN*f=pctfmt. balance*(sum*f=dollar24. colpctsum*f=pctfmt.)), product / nocellmerge;
format bal1 amtband.;
run;

proc sort data=hudson_bal1;
by product;
run;

proc means data=hudson_bal1 (drop= _type_ _table_ _page_) sum;
by product;
var _numeric_;
format balance dollar24.;
run;

proc sort data=hudson_bal1;
by product ;
run;

proc print data=hudson_bal1 noobs;
by product;
var bal1 N balance_sum;
run;


option orientation=landscape;

axis1 split=" ";
axis2 value=none label=none major=none minor=none;
proc gchart data=hudson_bal1;
where product in ('he');
by product;
vbar bal1 / discrete outside=sum sumvar=N cpercent width=25 maxis=axis1 raxis=axis2;
format N comma12. ;
run;
quit;


Title 'Avg. Balance for Hudson Accts with non zero balance';
proc tabulate data=hudson.combined;
where balance ne 0;
class product ;
var balance;
table balance*(N mean)*f=comma12.2, product / nocellmerge;
/*format balance amtband.;*/
run;

proc tabulate data=hudson.tda;
where bal_june ne 0;
class product ;
var bal_june;
table bal_june*(N mean)*f=comma12.2, product / nocellmerge;
/*format balance amtband.;*/
run;

Title 'Avg. Balance for Hudson Accts with non zero balance';
proc tabulate data=hudson.tda;
/*where bal_june ne 0;*/
class product bal_june;
table bal_june*(N colpctN)*f=comma12.2, product / nocellmerge;
format bal_june amtband.;
run;

*mtb comparison;
data temp_mtb;
set data.main_201206 (keep=hhid hh dda sav mms mtg heq dda_amt sav_amt mms_amt heq_amt mtg_amt);
DDA1 = DDA;
sav1 = sav;
mtg1 = mtg;
heq1=heq;
mms1=mms;
num_prods = sum(dda, sav, mtg, heq, mms);
dda_zero = 0;
if dda_amt in (0 .) then dda_zero = 1;
mms_zero = 0;
if mms_amt in (0 .) then mms_zero = 1;
sav_zero = 0;
if sav_amt in (0 .) then sav_zero = 1;
mtg_zero=0;
if mtg_amt in (0 .) then mtg_zero = 1;
heq_zero=0;
if heq_amt in (0 .) then heq_zero = 1;
run;

proc tabulate data=temp_mtb missing;
class dda1 sav1 mms1 mtg1 heq1;
var  dda_amt sav_amt mms_amt heq_amt mtg_amt hh dda sav mms mtg heq;
table  sum="HHs"*(hh dda mms sav mtg heq )*f=comma12. pctsum<hh>='Penetration'*(dda mms sav mtg heq) 
    sum="Balances"*(dda_amt mms_amt sav_amt mtg_amt heq_amt)*f=dollar24. mean="Avg. Balance"*(dda_amt mms_amt sav_amt mtg_amt heq_amt)*f=dollar24.
    , dda1 mms1 sav1 mtg1 heq1 all;
format dda1 sav1 mms1 mtg1 heq1 binary_flag.;
run;


proc means data=hudson.dda sum;
var bal_june;
run;

*single service;
data summary4;
set summary4;
num_prods = sum(dda, sav, mtg, he, mms);
run;

proc format;
value quick 1 = 'Single'
            2-high = 'Multi';
run;

proc freq data=summary4;
where hhid1 ne .;
table num_prods*(dda mms sav mtg he) / missing  norow  ;
format num_prods quick.;
run;

proc freq data=temp_mtb;
table num_prods*(dda mms sav mtg heq) / missing  norow  ;
format num_prods quick.;
run;


*do cross-matrix to try a block chart;

proc tabulate data=summary4 missing out=hudson_cross;
class dda mms sav mtg he dda1 mms1 sav1 mtg1 he1 ;
table (dda mms sav mtg he)*(dda1 mms1 sav1 mtg1 he1);
run;

data hudson_cross_1;
set hudson_cross;
if dda eq 1 then x = 'DDA';
if dda1 eq 1 then y = 'DDA';
if sav eq 1 then x = 'SAV';
if sav1 eq 1 then y = 'SAV';
if mms eq 1 then x = 'MMS';
if mms1 eq 1 then y = 'MMS';
if mtg eq 1 then x = 'MTG';
if mtg1 eq 1 then y = 'MTG';
if he eq 1 then x = 'HEQ';
if he1 eq 1 then y = 'HEQ';
keep x y N;
if x eq '' or y eq '' then delete;
rename N=Hudson;
run;

proc sql;
select hudson into :dda_N from hudson_cross_1 where x='DDA' and y='DDA' ;
select hudson into :mms_N from hudson_cross_1 where x='MMS' and y='MMS' ;
select hudson into :sav_N from hudson_cross_1 where x='SAV' and y='SAV' ;
select hudson into :mtg_N from hudson_cross_1 where x='MTG' and y='MTG' ;
select hudson into :heq_N from hudson_cross_1 where x='HEQ' and y='HEQ' ;
quit;



data hudson_cross_1;
set hudson_cross_1;
if y eq 'DDA' then hudson_pct = hudson/&dda_N;	
if y eq 'MMS' then hudson_pct = hudson/&mms_N;
if y eq 'SAV' then hudson_pct = hudson/&sav_N;
if y eq 'MTG' then hudson_pct = hudson/&mtg_N;
if y eq 'HEQ' then hudson_pct = hudson/&heq_N;
run;


proc tabulate data=temp_mtb missing out=mtb_cross;
class dda mms sav mtg heq dda1 mms1 sav1 mtg1 heq1;
table (dda mms sav mtg heq)*(dda1 mms1 sav1 mtg1 heq1);
run;

data mtb_cross_1;
set mtb_cross;
if dda eq 1 then x = 'DDA';
if dda1 eq 1 then y = 'DDA';
if sav eq 1 then x = 'SAV';
if sav1 eq 1 then y = 'SAV';
if mms eq 1 then x = 'MMS';
if mms1 eq 1 then y = 'MMS';
if mtg eq 1 then x = 'MTG';
if mtg1 eq 1 then y = 'MTG';
if heq eq 1 then x = 'HEQ';
if heq1 eq 1 then y = 'HEQ';
keep x y N;
if x eq '' or y eq '' then delete;
rename N=mtb;
run;

proc sql;
select mtb into :dda_N from mtb_cross_1 where x='DDA' and y='DDA' ;
select mtb into :mms_N from mtb_cross_1 where x='MMS' and y='MMS' ;
select mtb into :sav_N from mtb_cross_1 where x='SAV' and y='SAV' ;
select mtb into :mtg_N from mtb_cross_1 where x='MTG' and y='MTG' ;
select mtb into :heq_N from mtb_cross_1 where x='HEQ' and y='HEQ' ;
quit;


data mtb_cross_1;
set mtb_cross_1;
if y eq 'DDA' then mtb_pct = mtb/&dda_N;	
if y eq 'MMS' then mtb_pct = mtb/&mms_N;
if y eq 'SAV' then mtb_pct = mtb/&sav_N;
if y eq 'MTG' then mtb_pct = mtb/&mtg_N;
if y eq 'HEQ' then mtb_pct = mtb/&heq_N;
run;


Title 'Cross ownership for Hudson';
proc tabulate data=hudson_cross_1 order=data;
class x y;
var hudson_pct;
table (y)*f=comma12.,(x)*hudson_pct*f=percent6.1  ;
run;

proc sort data=mtb_cross_1;
by x y;
run;

proc sort data=hudson_cross_1;
by x y;
run;

data cross_merged;
merge mtb_cross_1 (in=a) hudson_cross_1 (in=b);
by x y;
if a and b;
run;

data cross_merged1;
set cross_merged;
bank = "MTB";
pct1 = mtb_pct;
value = mtb;
output;
bank = "Hudson";
pct1 = hudson_pct;
value = hudson;
output;
drop hudson_pct hudson mtb_pct mtb;
run;


data cross_merged1;
set cross_merged1;
select (x);
	when ('DDA') x1=1;
	when ('MMS') x1=2;
	when ('SAV') x1=3;
	when ('MTG') x1=4;
	when ('HEQ') x1=5;
end;
select (y);
	when ('DDA') y1=1;
	when ('MMS') y1=2;
	when ('SAV') y1=3;
	when ('MTG') y1=4;
	when ('HEQ') y1=5;
end;
run;

proc sort data=cross_merged1;
by x1 y1;
run;

title 'Cross Ownership Hudson and MTB (Ns)';
proc tabulate data=cross_merged1 missing order=data;
class bank y x;
var value;
table bank, y,x*sum*value*f=comma12. / nocellmerge;
run;



proc gchart data=cross_merged1;
block y / group=x subgroup=bank sumvar=pct1;
format pct1 percent6.1;
run;



Pattern1 c=cxFFB300;
Pattern2 c=cx007856;
Pattern3 c=cxC3E76F;
Pattern4 c=cx86499D;
Pattern5 c=cx003359;
Pattern6 c=cxAFAAA3;
Pattern7 c=cx7AB800;
Pattern8 c=cx23A491;
Pattern9 c=cx144629;



ods html style=MTB;
proc sgpanel data=cross_merged1;
panelby  x y / border columns=5 rows=5 layout=lattice ROWHEADERPOS= left novarname uniscale=all ;
vbar bank / response=pct1 STAT=SUM nostatlabel group=bank ;
format pct1 percent6.1;
run;


*###############################################################################;
*do chart panel;



proc catalog c=work.gseg kill; 
run; quit; 


 /* Set the graphics environment */
goptions reset=all cback=white noborder htitle=14pt htext=9pt;  

 /* Use the NODISPLAY graphics option when */
 /* creating the original graphs.          */
goptions device=gif nodisplay xpixels=150 ypixels=150;



pattern1 c=cxFFC000;
pattern2 c=cx007850;
axis1 label=(angle=90 f="Arial / bo" justify=center color=black height=14pt "DDA")  minor=none major=none color=white value=none order=(0 to 1.2 by 0.2); 
axis2 label=none  minor=none major=none value=none ;

title1 'DDA';
proc gchart data=cross_merged1(where=(y='DDA' and x='DDA')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;
quit;

axis1 label=none minor=none major=none value=none color=white order=(0 to 1.2 by 0.2); 
axis2 label=none  minor=none major=none value=none;
title1 'MMS';
proc gchart data=cross_merged1(where=(y='DDA' and x='MMS')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;


title1 'SAV';
proc gchart data=cross_merged1(where=(y='DDA' and x='SAV')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;


title1 'MTG';
proc gchart data=cross_merged1(where=(y='DDA' and x='MTG')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;


title1 'HEQ';
proc gchart data=cross_merged1(where=(y='DDA' and x='HEQ')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;


title1;
axis1 label=(angle=90 f="Arial / bo" justify=center color=black height=14pt "MMS" ) minor=none major=none value=none color=white order=(0 to 1.2 by 0.2); 
axis2 label=none  minor=none major=none value=none;
proc gchart data=cross_merged1(where=(y='MMS' and x='DDA')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe ;
format pct1 percent6.;
run;


axis1 label=none minor=none major=none value=none color=white order=(0 to 1.2 by 0.2); 
axis2 label=none  minor=none major=none value=none;
proc gchart data=cross_merged1(where=(y='MMS' and x='MMS')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;



proc gchart data=cross_merged1(where=(y='MMS' and x='SAV')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;



proc gchart data=cross_merged1(where=(y='MMS' and x='MTG')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;



proc gchart data=cross_merged1(where=(y='MMS' and x='HEQ')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;


axis1 label=(angle=90 f="Arial / bo" justify=center color=black height=14pt "SAV") minor=none major=none value=none color=white order=(0 to 1.2 by 0.2); 
axis2 label=none  minor=none major=none value=none;
proc gchart data=cross_merged1(where=(y='SAV' and x='DDA')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe ;
format pct1 percent6.;
run;


axis1 label=none minor=none major=none value=none color=white order=(0 to 1.2 by 0.2); 
axis2 label=none  minor=none major=none value=none;
proc gchart data=cross_merged1(where=(y='SAV' and x='MMS')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;



proc gchart data=cross_merged1(where=(y='SAV' and x='SAV')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;



proc gchart data=cross_merged1(where=(y='SAV' and x='MTG')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;



proc gchart data=cross_merged1(where=(y='SAV' and x='HEQ')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;


axis1 label=(angle=90 f="Arial / bo" justify=center color=black height=14pt "MTG") minor=none major=none value=none color=white order=(0 to 1.2 by 0.2); 
axis2 label=none  minor=none major=none value=none;
proc gchart data=cross_merged1(where=(y='MTG' and x='DDA')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe ;
format pct1 percent6.;
run;


axis1 label=none minor=none major=none value=none color=white order=(0 to 1.2 by 0.2); 
axis2 label=none  minor=none major=none value=none;
proc gchart data=cross_merged1(where=(y='MTG' and x='MMS')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;



proc gchart data=cross_merged1(where=(y='MTG' and x='SAV')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;



proc gchart data=cross_merged1(where=(y='MTG' and x='MTG')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;



proc gchart data=cross_merged1(where=(y='MTG' and x='HEQ')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;



axis1 label=(angle=90 f="Arial / bo" justify=center color=black height=14pt "HEQ") minor=none major=none value=none color=white order=(0 to 1.2 by 0.2); 
axis2 label=none  minor=none major=none value=none;
proc gchart data=cross_merged1(where=(y='HEQ' and x='DDA')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe ;
format pct1 percent6.;
run;


axis1 label=none minor=none major=none value=none color=white order=(0 to 1.2 by 0.2);
axis2 label=none  minor=none major=none value=none; 
proc gchart data=cross_merged1(where=(y='HEQ' and x='MMS')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;


proc gchart data=cross_merged1(where=(y='HEQ' and x='SAV')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;



proc gchart data=cross_merged1(where=(y='HEQ' and x='MTG')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;


proc gchart data=cross_merged1(where=(y='HEQ' and x='HEQ')) gout=work.gseg;
vbar bank / sumvar=pct1 subgroup=bank discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
format pct1 percent6.;
run;
quit;





goptions reset=all device=gif 
         gsfname=grafout gsfmode=replace
         xpixels=2000 ypixels=1000;

filename grafout 'c:\sample.gif'; 

proc greplay igout=work.gseg tc=tempcat nofs;

  /* Define a custom template called NEWTEMP */
  tdef newtemp des='5x5 panel template'

        /* Define panel 1 */
        1/llx=0   lly=80
          ulx=0   uly=100
          urx=20  ury=100
          lrx=20  lry=80
          color=blue

        /* Define panel 2 */
        2/llx=20   lly=80
          ulx=20   uly=100
          urx=40  ury=100
          lrx=40  lry=80
          color=blue

         /* Define panel 3 */
        3/llx=40  lly=80
          ulx=40  uly=100
          urx=60 ury=100
          lrx=60 lry=80
          color=blue

        /* Define panel 4 */
        4/llx=60  lly=80
          ulx=60  uly=100
          urx=80 ury=100
          lrx=80 lry=80
          color=blue

        /* Define panel 5 */
        5/llx=80   lly=80
          ulx=80   uly=100
          urx=100 ury=100
          lrx=100 lry=80
          color=blue

/* Define panel 6 */
        6/llx=0   lly=60
          ulx=0   uly=80
          urx=20  ury=80
          lrx=20  lry=60
          color=blue

        /* Define panel 7 */
        7/llx=20   lly=60
          ulx=20   uly=80
          urx=40  ury=80
          lrx=40  lry=60
          color=blue

         /* Define panel 8 */
        8/llx=40  lly=60
          ulx=40  uly=80
          urx=60 ury=80
          lrx=60 lry=60
          color=blue

        /* Define panel 9 */
        9/llx=60  lly=60
          ulx=60  uly=80
          urx=80 ury=80
          lrx=80 lry=60
          color=blue

        /* Define panel 10 */
        10/llx=80   lly=60
          ulx=80   uly=80
          urx=100 ury=80
          lrx=100 lry=60
          color=blue

/* Define panel 11 */
        11/llx=0   lly=40
          ulx=0   uly=60
          urx=20  ury=60
          lrx=20  lry=40
          color=blue

        /* Define panel 12 */
        12/llx=20   lly=40
          ulx=20   uly=60
          urx=40  ury=60
          lrx=40  lry=40
          color=blue

         /* Define panel 13 */
        13/llx=40  lly=40
          ulx=40  uly=60
          urx=60 ury=60
          lrx=60 lry=40
          color=blue

        /* Define panel 14 */
        14/llx=60  lly=40
          ulx=60  uly=60
          urx=80 ury=60
          lrx=80 lry=40
          color=blue

        /* Define panel 15 */
        15/llx=80   lly=40
          ulx=80   uly=60
          urx=100 ury=60
          lrx=100 lry=40
          color=blue

 /*Define panel 16 */
        16/llx=0   lly=20
          ulx=0   uly=40
          urx=20  ury=40
          lrx=20  lry=20
          color=blue

        /* Define panel 17 */
        17/llx=20   lly=20
          ulx=20   uly=40
          urx=40  ury=40
          lrx=40  lry=20
          color=blue

         /* Define panel 18 */
        18/llx=40  lly=20
          ulx=40  uly=40
          urx=60 ury=40
          lrx=60 lry=20
          color=blue

        /* Define panel 19 */
        19/llx=60  lly=20
          ulx=60  uly=40
          urx=80 ury=40
          lrx=80 lry=20
          color=blue

        /* Define panel 20 */
        20/llx=80   lly=20
          ulx=80   uly=40
          urx=100 ury=40
          lrx=100 lry=20
          color=blue

		  /*Define panel 21 */
        21/llx=0   lly=0
          ulx=0   uly=20
          urx=20  ury=20
          lrx=20  lry=0
          color=blue

        /* Define panel 22 */
        22/llx=20   lly=0
          ulx=20   uly=20
          urx=40  ury=20
          lrx=40  lry=0
          color=blue

         /* Define panel 23 */
        23/llx=40  lly=0
          ulx=40  uly=20
          urx=60 ury=20
          lrx=60 lry=0
          color=blue

        /* Define panel 24*/
        24/llx=60  lly=0
          ulx=60  uly=20
          urx=80 ury=20
          lrx=80 lry=0
          color=blue

        /* Define panel 25 */
        25/llx=80   lly=0
          ulx=80   uly=20
          urx=100 ury=20
          lrx=100 lry=0
          color=blue;
   /* Assign current template */
   template newtemp;

   /* List contents of current template */
   list template;

   /* Replay a total of five graphs using  */
   /* the custom template just created.    */
   treplay 1:gchart
           2:gchart1
           3:gchart2
           4:gchart3
           5:gchart4
		   6:gchart5
		   7:gchart6
		   8:gchart7
		   9:gchart8
		   10:gchart9
		   11:gchart10
           12:gchart11
           13:gchart12
           14:gchart13
           15:gchart14
		   16:gchart15
		   17:gchart16
		   18:gchart17
		   19:gchart18
		   20:gchart19
		   21:gchart20
           22:gchart21
           23:gchart22
           24:gchart23
           25:gchart24;
run; 
quit;


*calculate % zero balance for panel chart;
data summary5;
set summary4;
dda_zero = 0;
if dda_bal in (0 .) then dda_zero = 1;
mms_zero = 0;
if mms_bal in (0 .) then mms_zero = 1;
sav_zero = 0;
if sav_bal in (0 .) then sav_zero = 1;
run;

proc tabulate data=summary5 missing out=zerobal;
class dda mms sav dda1 mms1 sav1;
var hh dda_zero;
/*table (dda mms sav), (dda1 mms1 sav1);*/
table (dda mms sav), (dda1 mms1 sav1)*((hh dda_zero)*sum*f=comma12. ) /nocellmerge;
run;

data zerobal;
set zerobal;
where sum(dda,mms,sav,dda1,mms1,sav1) eq 2;
pct1 = dda_zero_sum / hh_sum;
format pct1 percent8.2;
run;

data zerobal1;
set zerobal;

if dda eq 1 then x = 'DDA';
if dda1 eq 1 then y = 'DDA';
if sav eq 1 then x = 'SAV';
if sav1 eq 1 then y = 'SAV';
if mms eq 1 then x = 'MMS';
if mms1 eq 1 then y = 'MMS';
if mtg eq 1 then x = 'MTG';
if mtg1 eq 1 then y = 'MTG';
if he eq 1 then x = 'HEQ';
if he1 eq 1 then y = 'HEQ';
keep x y pct1;
if x eq '' or y eq '' then delete;
/*rename N=Hudson;*/
run;

proc tabulate data=zerobal1;
class y x;
var pct1;
table y,x*sum*pct1 / nocellmerge;
/*format pct1 percent8.1;*/
run;


proc tabulate data=temp_mtb missing out=mtb_zerobal;
class dda mms sav dda1 mms1 sav1;
var hh dda_zero;
/*table (dda mms sav), (dda1 mms1 sav1);*/
table (dda mms sav), (dda1 mms1 sav1)*((hh dda_zero)*sum*f=comma12. ) /nocellmerge;
run;


data mtb_zerobal;
set mtb_zerobal;
where sum(dda,mms,sav,dda1,mms1,sav1) eq 2;
pct1 = dda_zero_sum / hh_sum;
format pct1 percent8.2;
run;


data mtb_zerobal1;
set mtb_zerobal;
if dda eq 1 then x = 'DDA';
if dda1 eq 1 then y = 'DDA';
if sav eq 1 then x = 'SAV';
if sav1 eq 1 then y = 'SAV';
if mms eq 1 then x = 'MMS';
if mms1 eq 1 then y = 'MMS';
if mtg eq 1 then x = 'MTG';
if mtg1 eq 1 then y = 'MTG';
if he eq 1 then x = 'HEQ';
if he1 eq 1 then y = 'HEQ';
keep x y pct1;
if x eq '' or y eq '' then delete;
/*rename N=Hudson;*/
run;

proc tabulate data=mtb_zerobal1;
class y x;
var pct1;
table y,x*sum*pct1 / nocellmerge;
/*format pct1 percent8.1;*/
run;


*break single product into zero and non zero balances;
title 'MTB';
proc tabulate data=temp_mtb missing;
class dda mms sav mtg heq dda_zero num_prods sav_zero mms_zero mtg_zero heq_zero;
var hh;
table num_prods*dda_zero,dda*(N colpctN) / nocellmerge;
table num_prods*mms_zero,mms*(N colpctN) / nocellmerge;
table num_prods*sav_zero,sav*(N colpctN) / nocellmerge;
table num_prods*mtg_zero,mtg*(N colpctN) / nocellmerge;
table num_prods*heq_zero,heq*(N colpctN) / nocellmerge;
format num_prods quick.;
run;

title 'Hudson';
proc tabulate data=summary4 missing;
class dda mms sav mtg he num_prods ddA_bAL SAV_BAL MMS_BAL HE_BAL MTG_BAL;
var hh;
table num_prods*dda_AMT,dda*(N colpctN) / nocellmerge;
table num_prods*mms_AMT,mms*(N colpctN) / nocellmerge;
table num_prods*sav_AMT,sav*(N colpctN) / nocellmerge;
table num_prods*mtg_AMT,mtg*(N colpctN) / nocellmerge;
table num_prods*he_AMT,he*(N colpctN) / nocellmerge;
format num_prods quick. dda_amt mms_amt sav_amt mtg_amt he_amt mybal.;
run;

title;
