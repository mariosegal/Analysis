libname attr 'C:\Documents and Settings\ewnym5s\My Documents\Validate Attrition';

/* read initial groupsets from datamart */
/* this is only needed once, there are 12 groupsets and 3 have been done, so somehow we have todo the other 9*/
/* i believe they need to be grouped together in 4 files: consumer, consumer chl, business, business chk*/
/* these 3 were the business ones */

filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Validate Attrition\wt.txt';
data WT;
length HHID $ 9 group $ 2;
infile mydata DLM='09'x firstobs=1  lrecl=4096  dsd;
	  INPUT hhID $ ;
group = 'WT';
run;

filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Validate Attrition\mtb.txt';
data MT;
length HHID $ 9 group $ 2;
infile mydata DLM='09'x firstobs=1 lrecl=4096  dsd;
	  INPUT hhID $ ;
group = 'MT';
run;

filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Validate Attrition\pb.txt';
data PB;
length HHID $ 9 group $ 2;
infile mydata DLM='09'x firstobs=1  lrecl=4096  dsd;
	  INPUT hhID $ ;
group = 'PB';
run;

/*############################################################################################################*/
/* read the accts level data for 201112 and 201201 */
/* a new monthly file needs to be exported and read each subsequent month */

filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Validate Attrition\201112.txt';
data attr.data_201112;
length HHID $ 9 acct $ 28 ptype $ 3 stype $ 3 sbu $ 5;
infile mydata DLM='09'x firstobs=2  lrecl=4096   dsd;
	  INPUT hhID $ acct $  ptype $  stype $  sbu $ bal;
run;


filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Validate Attrition\201201.txt';
data attr.data_201201;
length HHID $ 9 acct $ 28 ptype $ 3 stype $ 3 sbu $ 5;
infile mydata DLM='09'x firstobs=2  lrecl=4096   dsd;
	  INPUT hhID $ acct $  ptype $  stype $  sbu $ bal;
run;

/*############################################################################################################*/
   /* here I combine the 3 group files, one after the other and manipulate them to get a driving file, one HH per group */
  /* the PB group is part of the MT group, so i only call MT those that are not PB (or WT) and later on I combibne them to generate a MT value*/
/* this only neds to be done once per set of 3 groups, needs to be implemenetd for Conumer, consumer chkl and busienss chk */

data attr.groups_bus;
set wt mt pb;
run;

proc sort data=attr.groups_bus;
by HHID group;
run;

data attr.groups_bus;
set attr.groups_bus;
hh = 1;
run;

proc transpose data=attr.groups_bus out=attr.groups_bus_new (drop=_NAME_);
by hhid;
id group;
var hh;
run;

data attr.clean_grps_bus;
set attr.groups_Bus_new;
length group $ 2;
if PB eq 1 then group = 'PB';
else if MT eq 1 then group = 'MT';
else if WT eq 1 then group = 'WT';
run;

/*############################################################################################################*/
/* create a file with all accts from the groups as of december 2011, this is needed for analysis 
it does not need to be redone, but it does need to be extended to the other 3 sets*/

data temp1;
merge attr.data_201112 (in=a) attr.clean_grps (in=b keep = hhid group);
by hhid;
if a;
run;


data attr.analysis_bus_201112;
set temp1;
where group ne '';
by hhid;
hh=0;
if last.hhid then hh=1;
bal1 = 0;
if PTYPE in('DDA','SAV','MMS','TDA','IRA') and sbu = "BUS" and SUBSTRN(STYPE,1,1)= 'C' then bal1 = bal;
run;



/*############################################################################################################*/
/* calculate the HH counts */


data dec_accts_bus;
set attr.analysis_bus_201112;
/*where substr(acct,26,3) ne 'ELN';*/
run;

proc sort data=dec_accts_bus;
by acct;
run;

proc sort data=attr.data_201201;
by acct;
run;

data merged_bus;
merge dec_accts_bus (in=a) attr.data_201201 (in=b keep=acct bal hhid rename=(bal=new_bal hhid=hhid_new));
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

title1 'Jan 2012 Corrected';
proc tabulate data=merged_bus;
where group ne 'MT';
class group;
var hh hh_new bal1 bal1_new;
table group,  hh_new*(SUM*f=comma12.) ;
/*bal1*(SUM*f=dollar21.) bal1_jan*(SUM*f=dollar21.);*/
run;

title1;
proc tabulate data=merged_bus;
where group ne 'WT';
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


proc sort data=hh_lookup (keep=hhid_new group) out=new_hhs nodupkey;
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
if PTYPE in('DDA','SAV','MMS','TDA','IRA') and sbu = "BUS" and SUBSTRN(STYPE,1,1)= 'C' then bal1_new = bal;
run;

title1 'Jan 2012 Corrected Bals';
proc tabulate data=new_data_new_hh;
where group ne 'MT';
class group;
var hh_new  bal1_new;
table group,  bal1_new*(SUM*f=dollar21.);
run;

title1;
proc tabulate data=new_data_new_hh;
where group ne 'WT';
/*class group;*/
var hh_new  bal1_new;
table ALL,  bal1_new*(SUM*f=dollar21.);
keylabel ALL='M&T';
run;




/*############################################################################################################*/

/* misc code below, either erlier attempts, checking consistency or random analysis */

data diff_hh;
set hh_lookup;
where hhid ne hhid_jan;
run;

proc sort data=temp2;
by hhid;
run;

proc sort data=diff_hh;
by hhid;
run;

data temp3;
merge diff_hh (in=a) temp2(in=b where=(_freq_ ge 2));
by hhid;
if b and not a;
run;


/* i am not sure if I am happy wit the noise */











proc summary data=attr.groups;
by HHID;
var HH;
output out=attr.groups1 (drop= _TYPE_);
run;

data attr.groups1;
set attr.groups1;
where HHID ne '';
run;





proc sort data=attr.data_201112;
by acct;
run;

proc sort data=attr.data_201201;
by acct;
run;

proc sort data=attr.groups_new;
by hhid;
run;







data temp2;
merge attr.data_201201 (in=a) attr.clean_grps (in=b keep = hhid group);
by hhid;
if a;
run;

proc freq data=temp2;

table group / missing;
run;

data attr.analysis_201201;
set temp2;
where group ne '';
by hhid;
hh=0;
if last.hhid then hh=1;
bal1 = 0;
if PTYPE in('DDA','SAV','MMS','TDA','IRA') and sbu = "BUS" and SUBSTRN(STYPE,1,1)= 'C' then bal1 = bal;

run;

title 'Dec 2011';
proc tabulate data=attr.analysis_201112 ;
class group;
var hh bal1;
table group, (hh*f=comma12. bal1*f=dollar21.)*(sum);
run;

title 'Dec 2011';
proc tabulate data=attr.analysis_201112 ;
where group ne 'WT';
/*class group;*/
var hh bal1;
table ALL, (hh*f=comma12. bal1*f=dollar21.)*(sum);
run;

title 'Jan 2012';
proc tabulate data=attr.analysis_201201;
class group;
var hh bal1;
table group, hh*(SUM*f=comma12.) bal1*(SUM*f=dollar21.);
run;

title 'Jan 2012';
proc tabulate data=attr.analysis_201201;
where group ne 'WT';
/*class group;*/
var hh bal1;
table ALL , hh*(SUM*f=comma12.) bal1*(SUM*f=dollar21.);
run;

proc sort data=attr.analysis_201112 ;
by acct;
run;

proc sort data=attr.data_201201 ;
by acct;
run;

data attr.merged;
merge attr.analysis_201112 (in=a) attr.data_201201 (in=b keep = acct hhid bal rename=(bal=bal_jan hhid=hhid_jan));
by acct;
if a;
run;

data attr.merged;
set attr.merged;
match=0;
if hhid = hhid_jan then match=1;
run;

proc sort data=attr.merged;
by hhid;
run;

data dummy;
set attr.merged (drop=hh_jan);
if hhid_jan eq '' then delete;
run;


data dummy;
set dummy;
by hhid;
hh_jan=0;
if last.hhid then hh_jan=1;
run;


title 'Jan 2012 Corrected';
proc tabulate data=dummy;
where match=1;
class group;
var hh hh_jan bal1 bal_jan;
table group, hh*(SUM*f=comma12.) hh_jan*(SUM*f=comma12.) bal1*(SUM*f=dollar21.) bal_jan*(SUM*f=dollar21.);
run;

proc tabulate data=dummy;
where group ne 'WT';
/*class group;*/
var hh hh_jan bal1 bal_jan;
table ALL, hh*(SUM*f=comma12.) hh_jan*(SUM*f=comma12.) bal1*(SUM*f=dollar21.) bal_jan*(SUM*f=dollar21.);
run;



data caca;
set attr.merged;
where match ne 1;
run;



proc sort data=attr.data_201112;
by hhid acct;
run;

proc sort data=attr.data_201201;
by hhid acct;
run;

data weird_hh;
merge attr.data_201112 (in=a) attr.data_201201 (in=b keep=hhid acct rename=(hhid=hhid1 acct=acct1));
if not a and not b;
run;



proc sort data=attr.data_201201;
by acct;
run;

data test2;
merge test1 (in=a) attr.data_201201 (in=b keep = hhid BAL acct rename=(hhid=new_hhid BAL = new_bal));
by acct;
if a and b;
run;






proc sort data=attr.data_201201 out=data201201 nodupkey;
by acct;
run;

proc sort data=attr.data_201112 out=analysis_201112 nodupkey;
by acct;
run;


proc sort data=analysis_201112;
by hhid;
run;

data analysis_201112;
set analysis_201112;
by hhid;
hh=0;
if last.hhid then hh=1;
bal1 = 0;
if PTYPE in('DDA','SAV','MMS','TDA','IRA') and sbu = "BUS" and SUBSTRN(STYPE,1,1)= 'C' then bal1 = bal;
run;

proc sort data=analysis_201112;
by acct;
run;

proc sort data=data_201201;
by acct;
run;

data merged;
merge analysis_201112 (in=a) data_201201 (in=b keep=acct hhid bal rename=(bal=bal_jan hhid=hhid_jan));
if a and b;
run;

proc sort data=analysis_201112;
by hhid;
run;


data merged;
set merged;
by hhid;
hh=0;
if last.hhid then hh_jan=1;
bal1_jan = 0;
if PTYPE in('DDA','SAV','MMS','TDA','IRA') and sbu = "BUS" and SUBSTRN(STYPE,1,1)= 'C' then bal1_jan = bal_jan;
run;


data merged;
set merged;
by hhid;
hh_jan = 0;
if last.hhid then hh_jan=1;
run;


data merged;
merge merged (in=a) attr.merged (in=b keep=hhid group);
run;

title 'Jan 2012 Corrected';
proc tabulate data=merged;
where match=1;
class group;
var hh hh_jan bal1 bal1_jan;
table group, hh*(SUM*f=comma12.) hh_jan*(SUM*f=comma12.) bal1*(SUM*f=dollar21.) bal1_jan*(SUM*f=dollar21.);
run;

proc tabulate data=merged;
where group ne 'WT';
/*class group;*/
var hh hh_jan bal1 bal1_jan;
table ALL, hh*(SUM*f=comma12.) hh_jan*(SUM*f=comma12.) bal1*(SUM*f=dollar21.) bal1_jan*(SUM*f=dollar21.);
run;

/*I have a logical porblem, or there is something else wrong in addition to hhs, acct deletions or so*/
/* I need to do it outside sas, as I did it many times with the same results*/


/*the code below appears to work for HHs*/
/* For balances though I needf to also count any new accts from the new or exist HHs*/






/*splits */
proc sort data=hh_lookup;
by hhid;
run;

proc summary data=hh_lookup;
by HHID;
output out=t1 (drop= _TYPE_);
run;

proc freq data=t1;
where _freq_ gt 1;
table _FREQ_;
run;

proc freq data=t1;
where _freq_ eq 1;
table _FREQ_;
run;

/*merges */
proc sort data=hh_lookup;
by hhid_new;
run;

proc summary data=hh_lookup;
by HHID_new;
output out=t2 (drop= _TYPE_);
run;

proc freq data=t2;
where _freq_ gt 1;
table _FREQ_;
run;

proc freq data=t2;
where _freq_ eq 1;
table _FREQ_;
run;
