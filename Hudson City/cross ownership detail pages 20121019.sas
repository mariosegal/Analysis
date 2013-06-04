proc format ;
value mybala 0  = 'zero'
             .  = 'zero'
             other = 'non zero';
run;
data summary4;
set summary4;
dda_bal1 = dda_bal;
mms_bal1 = mms_bal;
sav_bal1 = sav_bal;
mtg_bal1 = mtg_bal;
he_bal1 = he_bal;
run;


proc tabulate data=summary4 missing out=hudson_cross;
where hhid1 ne .;
class dda mms sav mtg he dda1 mms1 sav1 mtg1 he1 dda_bal mms_bal sav_bal mtg_bal he_bal;
var sav_bal1 mms_bal1 he_bal1 mtg_bal1 dda_bal1;
table (dda*dda_bal mms*mms_bal sav*sav_bal mtg*mtg_bal he*he_bal)*(dda1 mms1 sav1 mtg1 he1), N sum*(sav_bal1 mms_bal1 he_bal1 mtg_bal1 dda_bal1)*f=dollar24.;
format dda_bal mms_bal sav_bal mtg_bal he_bal mybala.;
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
keep x y N dda_bal mms_bal sav_bal he_bal mtg_bal sav_bal1_sum mms_bal1_sum he_bal1_sum mtg_bal1_sum dda_bal1_sum;
if x eq '' or y eq '' then delete;
rename N=Hudson;
run;

proc sql;
select sum(hudson) into :dda_N from hudson_cross_1 where x='DDA' and y='DDA' ;
select sum(hudson) into :mms_N from hudson_cross_1 where x='MMS' and y='MMS' ;
select sum(hudson) into :sav_N from hudson_cross_1 where x='SAV' and y='SAV' ;
select sum(hudson) into :mtg_N from hudson_cross_1 where x='MTG' and y='MTG' ;
select sum(hudson) into :heq_N from hudson_cross_1 where x='HEQ' and y='HEQ' ;
quit;

%put _user_;

data hudson_cross_1;
set hudson_cross_1;
if y eq 'DDA' then hudson_pct = hudson/&dda_N;	
if y eq 'MMS' then hudson_pct = hudson/&mms_N;
if y eq 'SAV' then hudson_pct = hudson/&sav_N;
if y eq 'MTG' then hudson_pct = hudson/&mtg_N;
if y eq 'HEQ' then hudson_pct = hudson/&heq_N;
dda_avg = dda_bal1_sum / hudson;
mms_avg = mms_bal1_sum / hudson;
sav_avg = sav_bal1_sum / hudson;
mtg_avg = mtg_bal1_sum / hudson;
he_avg = he_bal1_sum / hudson;
run;

data temp_mtb;
set temp_mtb;
dda_amt1 = dda_amt;
mms_amt1 = mms_amt;
sav_amt1 = sav_amt;
mtg_amt1 = mtg_amt;
heq_amt1 = heq_Amt;
run;

proc tabulate data=temp_mtb missing out=mtb_cross;
class dda mms sav mtg heq dda1 mms1 sav1 mtg1 heq1 dda_amt mms_amt sav_amt mtg_amt heq_amt;
var dda_amt1 sav_amt1 mms_amt1 heq_amt1 mtg_amt1;
table (dda*dda_amt mms*mms_amt sav*sav_amt mtg*mtg_amt heq*heq_amt)*(dda1 mms1 sav1 mtg1 heq1),N sum*(dda_amt1 sav_amt1 mms_amt1 heq_amt1 mtg_amt1)*f=dollar24.;
format dda_amt mms_amt sav_amt mtg_amt heq_amt mybala.;
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
keep x y N dda_amt mms_amt sav_amt mtg_amt heq_amt dda_amt1_sum sav_amt1_sum mms_amt1_sum heq_amt1_sum mtg_amt1_sum;
if x eq '' or y eq '' then delete;
rename N=mtb;
run;

proc sql;
select sum(mtb) into :dda_N from mtb_cross_1 where x='DDA' and y='DDA' ;
select sum(mtb) into :mms_N from mtb_cross_1 where x='MMS' and y='MMS' ;
select sum(mtb) into :sav_N from mtb_cross_1 where x='SAV' and y='SAV' ;
select sum(mtb) into :mtg_N from mtb_cross_1 where x='MTG' and y='MTG' ;
select sum(mtb) into :heq_N from mtb_cross_1 where x='HEQ' and y='HEQ' ;
quit;


data mtb_cross_1;
set mtb_cross_1;
if y eq 'DDA' then mtb_pct = mtb/&dda_N;	
if y eq 'MMS' then mtb_pct = mtb/&mms_N;
if y eq 'SAV' then mtb_pct = mtb/&sav_N;
if y eq 'MTG' then mtb_pct = mtb/&mtg_N;
if y eq 'HEQ' then mtb_pct = mtb/&heq_N;
dda_avg = dda_amt1_sum / mtb;
mms_avg = mms_amt1_sum / mtb;
sav_avg = sav_amt1_sum / mtb;
mtg_avg = mtg_amt1_sum / mtb;
heq_avg = heq_amt1_sum / mtb;
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
merge mtb_cross_1 (in=a ) hudson_cross_1 (in=b);
by x y;
if a and b;
run;

data cross_merged_dda;
set cross_merged;
bank = "MTB";
pct1 = mtb_pct;
value = mtb;
bal_group=dda_amt;
output;
bank = "Hudson";
pct1 = hudson_pct;
value = hudson;
bal_group=dda_bal;
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

data cross_merged1;
set cross_merged1;
format pct1 percent8.1;
run;

title 'Cross Ownership  MTB DDA';
proc tabulate data=cross_merged1 missing order=data;
where y = "DDA" and bank="MTB";
class bank y x dda_amt;
var pct1;
table dda_amt, x*sum*pct1*f=percent8.1 / nocellmerge;
run;

title 'Cross Ownership  MTB SAV';
proc tabulate data=cross_merged1 missing order=data;
where y = "SAV" and bank="MTB";
class bank y x dda_amt;
var pct1;
table dda_amt, x*sum*pct1*f=percent8.1 / nocellmerge;
run;

title 'Cross Ownership  MTB MMS';
proc tabulate data=cross_merged1 missing order=data;
where y = "MMS" and bank="MTB";
class bank y x dda_amt;
var pct1;
table dda_amt, x*sum*pct1*f=percent8.1 / nocellmerge;
run;


proc print data=mtb_cross_1 noobs;
run;

proc print data=hudson_cross_1 noobs;
run;
