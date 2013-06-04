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

proc sort data=attr.data_201203;
by acct;
run;


data merged_bus;
merge dec_accts_bus (in=a) attr.data_201203 (in=b keep=acct bal hhid rename=(bal=new_bal hhid=hhid_new));
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


/* Count the account for appendix */

proc tabulate data=new_data_new_hh;
where ptype eq 'DDA' and substr(stype,1,1) eq 'C' and sbu = 'BUS' and group ne 'MT';
class group ptype;
table group, PTYPE*N='Count'*f=comma12.0;
run;

proc tabulate data=new_data_new_hh;
where ptype eq 'MMS' and substr(stype,1,1) eq 'C' and sbu = 'BUS' and group ne 'MT';
class group ptype;
table group, PTYPE*N='Count'*f=comma12.0;
run;

proc tabulate data=new_data_new_hh;
where ptype eq 'SAV' and substr(stype,1,1) eq 'C' and sbu = 'BUS' and group ne 'MT';
class group ptype;
table group, PTYPE*N='Count'*f=comma12.0;
run;

proc tabulate data=new_data_new_hh;
where ptype eq 'TDA' and substr(stype,1,1) eq 'C' and sbu = 'BUS' and group ne 'MT';
class group ptype;
table group, PTYPE*N='Count'*f=comma12.0;
run;

proc tabulate data=new_data_new_hh;
where ptype eq 'CLN' and sbu = 'BUS' and group ne 'MT';
class group ptype;
table group, PTYPE*N='Count'*f=comma12.0;
run;

/*validate measurement for appendizx in dec for CLN */
proc tabulate data=dec_accts_bus;
where ptype eq 'CLN' and sbu = 'BUS' and group ne 'MT';
class group ptype;
table group, PTYPE*N='Count'*f=comma12.0;
run;

