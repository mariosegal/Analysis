
proc sort data=attr.data_201112;
by hhid;
run;

proc sort data=attr.con_grps;
by hhid;
run;

data temp1;
merge attr.data_201112 (in=a) attr.con_grps (in=b keep = hhid grp);
by hhid;
if a;
run;


data analysis_con_201112;
set temp1;
where grp ne '';
by hhid;
hh=0;
if last.hhid then hh=1;
bal1 = 0;
if PTYPE in('DDA','SAV','MMS','TDA','IRA') and substr(stype,1,1) eq 'R' then bal1 = bal;
run;

proc tabulate data=analysis_con_201112;
where ptype in ('DDA','SAV','MMS','TDA','IRA') and substr(stype,1,1) eq 'R';
class grp ptype;
var bal;
table ptype ALL, grp*(bal*sum*f=dollar24.) / nocellmerge;
run;



/*############################################################################################################*/
/* calculate the HH counts */


data dec_accts_con;
set analysis_con_201112;
/*where substr(acct,26,3) ne 'ELN';*/
run;

proc sort data=dec_accts_con;
by acct;
run;

proc sort data=attr.data_201201;
by acct;
run;

data merged_con;
merge dec_accts_con (in=a) attr.data_201201 (in=b keep=acct bal hhid rename=(bal=new_bal hhid=hhid_new));
by acct;
if a and b;
run;

proc sort data=merged_con;
by hhid;
run;

data merged_con;
set merged_con;
by hhid;
hh_new=0;
if last.hhid then hh_new=1;
bal1_new = 0;
if PTYPE in('DDA','SAV','MMS','TDA','IRA') and SUBSTRN(STYPE,1,1)= 'R' then bal1_new = new_bal;
/*bal1_new has only balances for Deposits, otherwise zeros, easier to sum that way on tabulate */
run;

title1 'Jan 2012 Corrected';
proc tabulate data=merged_con;
where grp ne 'MT';
class grp;
var hh hh_new bal1 bal1_new;
table grp,  hh_new*(SUM*f=comma12.) ;
/*bal1*(SUM*f=dollar21.) bal1_jan*(SUM*f=dollar21.);*/
run;

title1;
proc tabulate data=merged_con;
where grp ne 'WT';
/*class group;*/
var hh hh_new bal1 bal1_new;
table ALL,  hh_new*(SUM*f=comma12.) ;
keylabel ALL = 'M&T';
/*bal1*(SUM*f=dollar21.) bal1_jan*(SUM*f=dollar21.);*/
run;



/*############################################################################################################*/

/* do the balances - balance requires that we add any deposit acct for the hh, since a hhld could have split, we need to add on the 2 or 
more hhs it mapped to*/

/* 1. create table with new HH numbs for old hhs */

data temp ;
set merged_con ;
keep hhid hhid_new grp ;
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


proc sort data=hh_lookup (keep=hhid_new grp) out=new_hhs nodupkey;
by hhid_new;
run;

proc sort data=attr.data_201201;
by hhid;
run;

data new_data_new_hh;
merge new_hhs(rename=(hhid_new=key ) in=a) attr.data_201201 (in=b rename=(hhid=key));
by key;
if a and b;
run;

data new_data_new_hh;
set new_data_new_hh;
by key;
hh_new=0;
if last.key then hh_new=1;
bal1_new = 0;
if PTYPE in('DDA','SAV','MMS','TDA','IRA')  and SUBSTRN(STYPE,1,1)= 'R' then bal1_new = bal;
run;

title1 'Jan 2012 Corrected Bals';
proc tabulate data=new_data_new_hh;
where grp ne 'MT';
class grp;
var hh_new  bal1_new;
table grp,  bal1_new*(SUM*f=dollar21.);
run;

title1;
proc tabulate data=new_data_new_hh;
where grp ne 'WT';
/*class group;*/
var hh_new  bal1_new;
table ALL,  bal1_new*(SUM*f=dollar21.);
keylabel ALL='M&T';
run;

title1 'Jan 2012 Corrected Bals';
proc tabulate data=new_data_new_hh;
where PTYPE in('DDA','SAV','MMS','TDA','IRA')  and SUBSTRN(STYPE,1,1)= 'R';
class grp ptype;
var hh_new  bal1_new;
table ptype ALL, grp*bal1_new*(SUM*f=dollar21.);
run;

