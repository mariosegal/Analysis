*cross product chart generation ;

%macro dummy();
	data temp_&group;
	set &source;
	%do k = 1 %to &nvars;
		%scan(&vars2,&k,' ') = %scan(&vars,&k,' ');
	%end;
	run;
%mend dummy;

*1) first create the cross using tabulate, unfortunately it has lines for the zeros too, so  that is not ideal
I need a temp dataset with duplicate flags for teh cross;
%let group=Hudson;
%let source=hudson.hudson_hh;
%let vars= dda1 mms1 sav1 tda1 ira1 mtg1 mtx1 heq1 iln1 ccs1;
%let vars2 = dda2 mms2 sav2 tda2 ira2 mtg2 mtx2 heq2 iln2 ccs2;
%let filter = con1 eq 1 ;
%let nvars=10;
%let names="Checking","Money Market","Savings","Time Deposits","IRA","Svcd Mortgage","Non-Svcd Mortgage","Home Equity","Inst. Loan","Overdraft";


%let group=Wash;
%let source=data.main_201209;
%let vars= dda mms sav tda ira mtg heq iln ccs;
%let vars2 = dda2 mms2 sav2 tda2 ira2 mtg2 heq2 iln2 ccs2;
%let filter = cbr eq 13 and products ge 1;
%let nvars=9;
%let names="Checking","Money Market","Savings","Time Deposits","IRA","Svcd Mortgage","Home Equity","Inst. Loan","Overdraft";



%dummy() 

proc tabulate data=temp_&group  missing out=&group._cross;
where &filter;
CLASS &vars &vars2;
table (&vars ),(&vars2)*rowpctn / nocellmerge;
run;

*2) have to clean the lines that have the crosses for the zeros, you only want rows with 1 or 2 1's, no zeros;
data &group._cross1;
set &group._cross;
array flags{&nvars} &vars;
array flags2{&nvars} &vars2;
group= "&group";
keep = 1;
do i = 1 to &nvars;
   if flags{i} eq 0 then keep=0;
   if flags2{i} eq 0 then keep = 0;
end;
percent = sum(of PCTN:);
if keep eq 1 then output;
drop _type_ _page_ _table_ i keep pctn:;
run; 

*3) define y and x variables that will define the rows (Y dimension) and columns (x dimension) for the matrix;
* y is the first 1 in the matrix, x is the second one if found, if not it is =y;
data &group._cross2;
length x $ 20 y $ 20 group $ 15;
set &group._cross1;
array names{&nvars} $ 20 _temporary_ (&names);
array flags{&nvars} &vars;
array flags2{&nvars} &vars2;

y=""; x="";
do i = 1 to &nvars;
   if flags{i} eq 1 and y eq "" then do; *we found the y one;
   		y=names{i};
   end;
   if flags2{i} eq 1 and x eq "" then do; *we found the x one;
   		x=names{i};
   end;
end;
percent = divide(percent,100);
drop i;
run;

proc format;
value $ productx (notsorted)
      'Checking' = 'Checking'
	'Money Market' = 'Money Market'
	'Savings' = 'Savings'
	'Time Deposits'= 'Time Deposits'
	'IRA'= 'IRA'
	'Svcd Mortgage'= 'Svcd Mortgage'
	'Non-Svcd Mortgage'= 'Non Svcd Mortgage'
	'Home Equity'= 'Home Equity'
	'Inst. Loan'= 'Inst. Loan'
	 'Overdraft'= 'Overdraft';
run;

proc format;
value $ groups (notsorted)
	'Hudson' = 'Hudson'
	'WNY' = 'WNY'
	'Balt' = 'Balt'
	'Wash' = 'Wash';
run;

proc tabulate data=&group._cross2 order=data;
class y x / preloadfmt;
class group / preloadfmt;
var percent;
table group, y,x*sum*percent*f=percent8.1;
format x y $productx. group $groups.;
run;

data combined;
set hudson_cross2 wny_cross2 balt_cross2 wash_cross2;
keep x y group percent;
run;

 *add missing points to combined;
*i could also fix it by naming the charts myself, and not relying on the standar naming, but not sure how;

proc contents data=combined;
run;

data extra;
length x $ 25 y $ 25 group $ 15;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\extra.txt' dsd dlm='09'x missover lrecl=4096;
input x y group percent;
run;


data wip.combined;
set combined extra;
run;


proc tabulate data=wip.combined order=data;
class y x / preloadfmt;
class group / preloadfmt;
var percent;
table group, y,x*sum*percent*f=percent8.1;
format x y $productx. group $groups.;
run;

proc format;
value $ groups (notsorted)
	'Hudson' = 'Hudson'
	'WNY' = 'WNY'
	'Balt' = 'Balt'
	'Wash' = 'Wash';
run;


*addtl number for abbas;

data prods1;
set DATA.MAIN_201209;
products1 = sum(dda,mms,tda,sav,ira, iln, heq, mtg, ccs);
keep hhid products cbr products1 dda mms tda sav ira  iln  heq  mtg  ccs;
run;

proc tabulate data=prods1 order=data missing;
where products ge 2 and cbr in (1,12,13);
class dda: mms: tda: sav: mtg: heq: iln: ccs: ira: ccs: ;
CLASS CBR / PRELOADFMT;
var products products1;
table dda MMS SAV TDA IRA mtg heq iln ccs  ,N*f=comma12. sum*( products products1)*f=comma12. /nocellmerge;
format  CBR CBR2012FMT.;
run;

proc tabulate data=hudson.hudson_hh missing;
where products gt 1;
class dda1 mms1 sav1 tda1 ira1 mtg1 mtx1 heq1 iln1 ccs1;
var products ;
table dda1 mms1 sav1 tda1 ira1 mtg1 mtx1 heq1 iln1 ccs1, N sum*products / nocellmerge;
run;

proc format;
value $ mystate (notsorted)
 'NJ' = 'NJ'
 'NY' = 'NY'
 'CT' = 'CT'
 other = 'Other';
 run;



proc tabulate data=hudson.hudson_hh missing order=data;
/*where state in ("NJ","NY","CT");*/
class state /preloadfmt;
class products / mlf preloadfmt;
class distance / preloadfmt;
var products1;
table state ALL, (products ALL)*(N rowpctn) / nocellmerge;
table state ALL, (products ALL)*(N products1*sum) / nocellmerge;

table distance ALL, (products ALL)*(N rowpctn) / nocellmerge;
/*table distance ALL, (state ALL)*(products) / nocellmerge;*/

format state $mystate. products prods. distance distfmt.;
run;


proc tabulate data=hudson.hudson_hh missing order=data;
where distance ne -1 AND distance ne 0 and distance ne .;
class state /preloadfmt;
class products / mlf preloadfmt;
var distance ;
var products1;
table  (state ALL), products*(N sum*distance) / nocellmerge;

format state $mystate. products prods. ;
run;






proc tabulate data=data.main_201209 (keep = cbr products dda: mms: tda: sav: mtg: heq: iln: ccs: ira: ccs:) missing out=prods_mtb;
where cbr in (1 12 13) and products ge 1;
var products;
class cbr dda mms tda sav ira  iln  heq  mtg  ccs;
table (dda mms tda sav ira  iln  heq  mtg  ccs)*cbr*(N sum*products);
/*format cbr cbr2012fmt.;*/
run;


data prods_mtb;
set prods_mtb;
where sum(dda,mms,tda,sav,ira, iln, heq, mtg, ccs) eq 1;
prods = products_sum/ N;
drop _type_ _page_ _table_;
run;

data prods_mtb;
set prods_mtb;
if dda eq 1 then num =1;
if mms eq 1 then num =2;
if sav eq 1 then num =3;
if tda eq 1 then num =4;
if ira eq 1 then num =5;
if mtg eq 1 then num =6;
if heq eq 1 then num =8;
if iln eq 1 then num =9;
if ccs eq 1 then num =10;
run;

data prods_mtb;
set prods_mtb;
keep num prods N cbr;
run;

proc tabulate data=hudson.hudson_hh (keep =  products dda: mms: tda: sav: mtg: heq: iln: ccs: ira: ccs: mtx1) missing out=prods_hudson;;
WHERE PRODUCTS GE 1;
var products;
class dda1 mms1 tda1 sav1 ira1  iln1  heq1  mtg1  ccs1 mtx1;
table (dda1 mms1 tda1 sav1 ira1  iln1  heq1  mtg1 mtx1 ccs1)*(N sum*products);
run;

data prods_hudson;
set prods_hudson;
where sum(dda1,mms1,tda1,sav1,ira1, iln1, heq1, mtg1, ccs1, mtx1) eq 1;
prods = products_sum/ N;
drop _type_ _page_ _table_;
run;

data prods_hudson;
set prods_hudson;
if dda1 eq 1 then num =1;
if mms1 eq 1 then num =2;
if sav1 eq 1 then num =3;
if tda1 eq 1 then num =4;
if ira1 eq 1 then num =5;
if mtg1 eq 1 then num =6;
if mtx1 eq 1 then num=7;
if heq1 eq 1 then num =8;
if iln1 eq 1 then num =9;
if ccs1 eq 1 then num =10;
run;

data prods_hudson;
set prods_hudson;
cbr = 0;
keep num prods N cbr;
run;

DATA EXTRA1	;
input num cbr prods;
datalines;
7 1 0
7 12 0
7 13 0
;
run;


data products_combined;
set prods_hudson prods_mtb extra1;
run;

data wip.products_combined;
length group $ 15;
set products_combined;
select (cbr);
	when (0) group = 'Hudson';
	when (1) group = 'WNY';
	when (12) group = 'Balt';
	when (13) group = 'Wash';
end;
run;

proc sort data=wip.products_combined;
by cbr num;
run;



datalines;
"Overdraft" "Non-Svcd Mortgage" "Hudson" 0
"Non-Svcd Mortgage" "Overdraft" "Hudson" 0
"Home Equity" "Non-Svcd Mortgage" "Hudson" 0
"Non-Svcd Mortgage" "Home Equity" "Hudson" 0
"Checking" "Non-Svcd Mortgage" "WNY" 0
"Money Market" "Non-Svcd Mortgage" "WNY" 0
"Savings" "Non-Svcd Mortgage" "WNY" 0
"Time Deposits" "Non-Svcd Mortgage" "WNY" 0
"IRA" "Non-Svcd Mortgage" "WNY" 0
"Svcd Mortgage" "Non-Svcd Mortgage" "WNY" 0
"Non-Svcd Mortgage" "Non-Svcd Mortgage" "WNY" 0
"Home Equity" "Non-Svcd Mortgage" "WNY" 0
"Inst. Loan" "Non-Svcd Mortgage" "WNY" 0
"Overdraft" "Non-Svcd Mortgage" "WNY" 0
"Non-Svcd Mortgage" "Checking" "WNY" 0
"Non-Svcd Mortgage" "Money Market" "WNY" 0
"Non-Svcd Mortgage" "Savings" "WNY"0
"Non-Svcd Mortgage" "Time Deposits" "WNY" 0
"Non-Svcd Mortgage" "IRA" "WNY" 0
"Non-Svcd Mortgage" "Svcd Mortgage "WNY" 0
"Non-Svcd Mortgage" "Home Equity" "WNY" 0
"Non-Svcd Mortgage" "Inst. Loan" "WNY" 0
"Non-Svcd Mortgage" "Overdraft" "WNY" 0
"Checking" "Overdraft" "WNY" 0
"Money Market" "Overdraft" "WNY" 0
"Savings" "Overdraft" "WNY" 0
"Time Deposits" "Overdraft" "WNY" 0
"IRA" "Overdraft" "WNY" 0
"Svcd Mortgage" "Overdraft" "WNY" 0
"Non-Svcd Mortgage" "Overdraft" "WNY" 0
"Home Equity" "Overdraft" "WNY" 0
"Inst. Loan" "Overdraft" "WNY" 0
"Overdraft" "Overdraft" "WNY" 0
"Overdraft" "Checking" "WNY" 0
"Overdraft" "Money Market" "WNY" 0
"Overdraft" "Savings" "WNY"0
"Overdraft" "Time Deposits" "WNY" 0
"Overdraft" "IRA" "WNY" 0
"Overdraft" "Svcd Mortgage "WNY" 0
"Overdraft" "Non-Svcd Mortgage" "WNY" 0
"Overdraft" "Home Equity" "WNY" 0
"Overdraft" "Inst. Loan" "WNY" 0
"Checking" "Non-Svcd Mortgage" "Balt" 0
"Money Market" "Non-Svcd Mortgage" "Balt" 0
"Savings" "Non-Svcd Mortgage" "Balt" 0
"Time Deposits" "Non-Svcd Mortgage" "Balt" 0
"IRA" "Non-Svcd Mortgage" "Balt" 0
"Svcd Mortgage" "Non-Svcd Mortgage" "Balt" 0
"Non-Svcd Mortgage" "Non-Svcd Mortgage" "Balt" 0
"Home Equity" "Non-Svcd Mortgage" "Balt" 0
"Inst. Loan" "Non-Svcd Mortgage" "Balt" 0
"Overdraft" "Non-Svcd Mortgage" "Balt" 0
"Non-Svcd Mortgage" "Checking" "Balt" 0
"Non-Svcd Mortgage" "Money Market" "Balt" 0
"Non-Svcd Mortgage" "Savings" "Balt"0
"Non-Svcd Mortgage" "Time Deposits" "Balt" 0
"Non-Svcd Mortgage" "IRA" "Balt" 0
"Non-Svcd Mortgage" "Svcd Mortgage "Balt" 0
"Non-Svcd Mortgage" "Home Equity" "Balt" 0
"Non-Svcd Mortgage" "Inst. Loan" "Balt" 0
"Non-Svcd Mortgage" "Overdraft" "Balt" 0
"Checking" "Overdraft" "Balt" 0
"Money Market" "Overdraft" "Balt" 0
"Savings" "Overdraft" "Balt" 0
"Time Deposits" "Overdraft" "Balt" 0
"IRA" "Overdraft" "Balt" 0
"Svcd Mortgage" "Overdraft" "Balt" 0
"Non-Svcd Mortgage" "Overdraft" "Balt" 0
"Home Equity" "Overdraft" "Balt" 0
"Inst. Loan" "Overdraft" "Balt" 0
"Overdraft" "Overdraft" "Balt" 0
"Overdraft" "Checking" "Balt" 0
"Overdraft" "Money Market" "Balt" 0
"Overdraft" "Savings" "Balt"0
"Overdraft" "Time Deposits" "Balt" 0
"Overdraft" "IRA" "Balt" 0
"Overdraft" "Svcd Mortgage "Balt" 0
"Overdraft" "Non-Svcd Mortgage" "Balt" 0
"Overdraft" "Home Equity" "Balt" 0
"Overdraft" "Inst. Loan" "Balt" 0
"Checking" "Non-Svcd Mortgage" "Wash" 0
"Money Market" "Non-Svcd Mortgage" "Wash" 0
"Savings" "Non-Svcd Mortgage" "Wash" 0
"Time Deposits" "Non-Svcd Mortgage" "Wash" 0
"IRA" "Non-Svcd Mortgage" "Wash" 0
"Svcd Mortgage" "Non-Svcd Mortgage" "Wash" 0
"Non-Svcd Mortgage" "Non-Svcd Mortgage" "Wash" 0
"Home Equity" "Non-Svcd Mortgage" "Wash" 0
"Inst. Loan" "Non-Svcd Mortgage" "Wash" 0
"Overdraft" "Non-Svcd Mortgage" "Wash" 0
"Non-Svcd Mortgage" "Checking" "Wash" 0
"Non-Svcd Mortgage" "Money Market" "Wash" 0
"Non-Svcd Mortgage" "Savings" "Wash"0
"Non-Svcd Mortgage" "Time Deposits" "Wash" 0
"Non-Svcd Mortgage" "IRA" "Wash" 0
"Non-Svcd Mortgage" "Svcd Mortgage "Wash" 0
"Non-Svcd Mortgage" "Home Equity" "Wash" 0
"Non-Svcd Mortgage" "Inst. Loan" "Wash" 0
"Non-Svcd Mortgage" "Overdraft" "Wash" 0
"Checking" "Overdraft" "Wash" 0
"Money Market" "Overdraft" "Wash" 0
"Savings" "Overdraft" "Wash" 0
"Time Deposits" "Overdraft" "Wash" 0
"IRA" "Overdraft" "Wash" 0
"Svcd Mortgage" "Overdraft" "Wash" 0
"Non-Svcd Mortgage" "Overdraft" "Wash" 0
"Home Equity" "Overdraft" "Wash" 0
"Inst. Loan" "Overdraft" "Wash" 0
"Overdraft" "Overdraft" "Wash" 0
"Overdraft" "Checking" "Wash" 0
"Overdraft" "Money Market" "Wash" 0
"Overdraft" "Savings" "Wash"0
"Overdraft" "Time Deposits" "Wash" 0
"Overdraft" "IRA" "Wash" 0
"Overdraft" "Svcd Mortgage "Wash" 0
"Overdraft" "Non-Svcd Mortgage" "Wash" 0
"Overdraft" "Home Equity" "Wash" 0
"Overdraft" "Inst. Loan" "Wash" 0
;
run;

ods html style=MTB;
goptions reset=all cback=white noborder htitle=14pt htext=9pt;  





