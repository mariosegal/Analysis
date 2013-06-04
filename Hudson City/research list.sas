data hudson.research_zips;
length zip_clean $ 5;
set hudson.research_zips;
zip_clean = put(zip_num,z5.);
format zip_num z5.;
run;

proc sort data=hudson.hudson_hh;
by zip_clean;
run;

proc sort data=hudson.research_zips;
by zip_clean;
run;

data hudson.research;
merge hudson.hudson_hh (in=a) hudson.research_zips (in=b);
by zip_clean;
if a;
run;

proc tabulate data=hudson.research missing;
where external ne 1 and products ne . and town ne '' and age lt 75 and age gt 17;
class town area_group_new / mlf;
var hh;
table area_group_new, town*(sum=' '*hh*f=comma12.)/ nocellmerge misstext='0';
run;


*generate list with new rules;

data hudson.research_zips_new;
set zips;
run;

proc sort data=hudson.research_zips_new;
by zip_codes;
run;

proc sort data=hudson.hudson_hh;
by zip_clean;
run;

data list;
merge hudson.research_zips_new (in=a rename=(zip_codes=zip_clean)) 
      hudson.hudson_hh (in=b keep=pseudo_hh zip_clean dda: dda_amt atm: mtx: mtg: debit: ch: cqi_dd heq1 ccs: products tda: ira: iln: mms: sav: ixi_assets
      where=((products eq 1 and mtx1=0 and mtg1=0) or (products ge 2 and (mtx1=1 or mtg1 =1))));
by zip_clean; 
if a;
run;



data list;
set list;
active = 0;
if dda1 eq 1 and (sum(ATM_WD_HUDSON, ATM_WD_OTHER, DEBIT_PURCH, CHKS_PO_MTH ) ge 2 or 
   (sum(ATM_WD_HUDSON, ATM_WD_OTHER, DEBIT_PURCH, CHKS_PO_MTH ) eq 1 and cqi_dd eq 1)) then active = 1;
run;

proc sort data=list(keep=pseudo_hh) out=hhs nodupkey;
by pseudo_hh;
run;

proc sort data=hudson.clean_20121106;
by pseudo_hh order descending curr_bal;
run;



data primaries;
set hudson.clean_20121106;
by pseudo_hh;
if first.pseudo_hh then output;
keep pseudo_hh NAME_1 NAME_2 ADDRESS_1 ADDRESS_2 CITY STATE ZIP PHONE_1 PHONE_2;
run;



proc sort data=list;
by pseudo_hh;
run;

data list1;
merge list (in=a) primaries (in=b);
by pseudo_hh;
if a;
run;

data list1;
set list1;
if dda1 eq 1 and products eq 1 and dda_amt in (.,0) then delete;
if (mtg1 eq 1 or mtx1 eq 1) and products eq 1 then delete;
if (ccs1 eq 1 or heq1 eq 1 or iln1 eq 1) and products eq 1 then delete;
if products eq . or products eq 0 then delete;
run;


proc tabulate data=list1 missing;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 ccs1 iln1 mtx1;
class products town;
table town all ,products all, N sum*(dda1 mms1 sav1 tda1 ira1 mtg1 heq1 ccs1 iln1 mtx1) / nocellmerge;
run;


data mamaroneck jersey_city toms_river both paramus;
set list1;
if town eq 'Mamaroneck' then output mamaroneck;
if town eq 'Jersey City' then output jersey_city;
if town eq 'Paramus' then output paramus;
if town eq 'Both' then output Both;
if town eq 'Toms River' then output toms_river;
drop f3 f4 products;
run;



proc export data=mamaroneck outfile='C:\Documents and Settings\ewnym5s\My Documents\Hudson City\mamaroneck.xlsx'  
dbms=EXCEL;
run;

proc export data=jersey_city outfile='C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Jersey_City.xlsx' 
dbms=EXCEL;
run;

proc export data=toms_river outfile='C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Toms_river.xlsx' 
dbms=EXCEL;
run;

proc export data=both outfile='C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Both.xlsx' 
dbms=EXCEL;
run;

proc export data=paramus outfile='C:\Documents and Settings\ewnym5s\My Documents\Hudson City\paramus.xlsx' 
dbms=EXCEL;
run;



*new list for john;
data toms_river ;
set list1;
if town eq 'Toms River' then output toms_river;
drop products;
run;
