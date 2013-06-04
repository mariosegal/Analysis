libname virtual 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled';
libname Data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname wip 'C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files';

options MSTORED SASMSTORE = mjstore;
libname mjstore 'C:\Documents and Settings\ewnym5s\My Documents\SAS\Macros';


filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\chkhhs.txt';
/*read the lits of all checking accts for analysis */
data virtual.checking;
length HHID $ 9 key $ 30 stype $ 3 ;
infile mydata DLM='09'x firstobs=1 lrecl=4096 dsd;
/*informat date_open date.;*/
	  INPUT hhID $key $ stype $ date_open :mmddyy.;
	  format date_open date.;
run;

/*group by HH*/
proc summary data=virtual.checking (drop=date_open stype key);
by HHID;
output out=virtual.chk_hhs (drop=_TYPE_);
run;


/*read non consumer HHs for exlcusion */
filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\non_con.txt';
data virtual.non_consumer;
length HHID $ 9 ;
infile mydata DLM='09'x firstobs=2 lrecl=4096 dsd;
	  INPUT hhID $;
run;

data virtual.non_consumer;
set virtual.non_consumer;
by hhid;
if first.hhid then output;
run;

/*read data*/
/*Note: dec 2011 does not have mobile data so I will defacto ignore it*/
/*I modified  the counter at the end to read the last file for jan2012*/
/*this macro could read all my files at once*/
%macro read_files;
/*%do name = JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC;*/
%do i = 13 %to 13;
   %if &i = 1 %then %let name=JAN;
   %if &i = 2 %then %let name=FEB;
   %if &i = 3 %then %let name=MAR;
   %if &i = 4 %then %let name=APR;
   %if &i = 5 %then %let name=MAY;
   %if &i = 6 %then %let name=JUN;
   %if &i = 7 %then %let name=JUL;
   %if &i = 8 %then %let name=AUG;
   %if &i = 9 %then %let name=SEP;
   %if &i = 10 %then %let name=OCT;
   %if &i = 11 %then %let name=NOV;
   %if &i = 12 %then %let name=DEC;
   %if &i = 13 %then %let name=JAN12;

	%put &i &name;
	filename mydata "C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\&name..txt";
	
	data virtual.&name;
	length HHID $ 9 Db $ 15;
	infile mydata DLM='09'x firstobs=2 lrecl=4096 dsd;
		  INPUT hhID $
			BR_1PT
			BR_15PT
			VRU
			MOBILE_025PT
			MOBILE_1PT
			web_025PT
			web_1PT
			web_flag
			ATM_1PT
			ATM_025PT
			ATM_15PT
			DB $;
	run;
%end;
%mend;

%read_files;

/*this was to merge the jan12 data I extracted after the first 12 files, not really needed*/
data tempx;
set virtual.main_2011;
where db ne '12/31/2011';
run;



/*this concatenates the datasets, need to modify to read all the 12 files we are using as now it takes 11 months and adds jan 12 only*/
data virtual.main_2011;
set tempx virtual.jan12;
run;

proc sort data=virtual.main_2011;
by hhid;
run;

/*summarize data by bucket across months */

proc summary data=virtual.main_2011 (drop=DB );
var BR_1PT BR_15PT VRU MOBILE_025PT MOBILE_1PT web_025PT web_1PT web_flag ATM_1PT ATM_025PT ATM_15PT;
by HHID;
output out=virtual.summary_2011 (drop=_TYPE_)
	SUM(BR_1PT) = BR_1
	SUM(BR_15PT) = BR_15
	sum(VRU) = phone
	sum(mobile_025pt) = mobile_025
	sum(mobile_1pt) = mobile_1
	sum(web_025pt) = web_025
	sum(web_1pt) = web_1
	sum(web_flag) = web
	sum(ATM_025pt) = ATM_025
	sum(ATM_1pt) = ATM_1
	sum(ATM_15pt) = ATM_15;
run;

/* do novantas exclusions:
1. Only pure consumer
2. only checking HHs 
*/

data _null_;
put nobs=;
stop;
set virtual.summary_2011 nobs=nobs;
run;

data temp1;
merge virtual.summary_2011 (in=a) virtual.non_consumer (in=b);
by hhid;
if a and not b;
run;

data temp2;
merge temp1 (in=a) virtual.chk_hhs (in=b drop=_freq_);
by hhid;
if a and b;
run;

data temp_summary;
set temp2;
where _freq_ eq 12;
run;



/*merge with chk hhs to create analysis set*/
/*data temp_summary;*/
/*merge virtual.chk_hhs (in=a) virtual.summary_2011 (in=b where=(_FREQ_ eq 12));*/
/*by hhid;*/
/*if a and b;*/
/*run;*/



/*assign point and classify into groups*/
data virtual.points_2011_New_e;
length segment $ 20;
set temp_summary ;
if BR_1 eq . then BR_1 = 0;
if BR_15 eq . then BR_15 = 0;
if phone eq . then phone = 0;
if mobile_025 eq . then mobile_025 = 0;
if mobile_1 eq . then mobile_1 = 0;
if web_025 eq . then web_025 = 0;
if web_1 eq . then web_1 = 0;
if web eq . then web = 0;
if ATM_025 eq . then ATM_025 = 0;
if ATM_1 eq . then ATM_1 = 0;
if ATM_15 eq . then ATM_15 = 0;
if sign_ons eq . then sign_ons = 0;

Branch = sum(BR_1, BR_15*1.5);
Phone_pts = divide(Phone,4);
Online= sum(divide(mobile_025,4),mobile_1,web_1,divide(web_025,4),web);
/*Online= sum(divide(mobile_025,4),mobile_1,web_1,divide(web_025,4),max(web,1));*/
/*Online= sum(divide(mobile_025,4),mobile_1,web_1,divide(web_025,4),divide(sign_ons,4));*/
/*Online= sum(divide(mobile_025,4),mobile_1,web_1,divide(web_025,4),max(web,6));*/
ATM = sum(divide(ATM_025,4),ATM_1,ATM_15*1.5);
total = sum(ATM , Online , Phone_pts , Branch);
br_pct = divide(branch,total);
ph_pct = divide(phone_pts,total);
onl_pct = divide(online,total);
ATM_pct = divide(ATM,total);

if br_pct eq . then br_pct = 0;
if ph_pct eq . then ph_pct = 0;
if onl_pct eq . then onl_pct = 0;
if ATM_pct eq . then ATM_pct = 0;

segment = 'None';
material = 1; /* should be zero, I used 1 to force it as it is not working as expected */
/*if (branch ge 6) or (atm ge 6) or (phone ge 12) then material = 1; */

if material eq 1 then do;
	active = 0;
	if ((sum(branch,ATM) gt 6 or sum(online,phone) gt 12)) and (material eq 1) then active = 1;
/*	if ((sum(branch,ATM,online,phone) gt 6 )) and (material eq 1) then active = 1;  this is what Novantas code seems to have */
/*	if active eq 1 and (max(branch, ATM) lt 6 or max(phone_pts,online) lt 12) then active=0;  *Novantas had a secnd test for active;*/
/*	if active eq 1 and branch lt 6 and ATM lt 6 and phone_pts lt 12 and online lt 12 then active=0; *prior one did not work, I need for them to have a minimum;*/
	if active=1 then do;
		if max(br_pct,ph_pct,onl_pct,atm_pct) gt 0.8 then do; /*we have a dominant one*/
			if ( sum(online,phone_pts) lt 24 and ATM lt 12 and br_pct gt 0.8) then segment = 'Branch Dominant';
			if ( sum(online,phone_pts) lt 24 and Branch lt 12 and atm_pct gt 0.8) then segment = 'ATM Dominant';
			if ( online lt 24 and sum(Branch,ATM) lt 12 and ph_pct gt 0.8) then segment = 'Phone Dominant';
			if ( Phone_pts lt 24 and sum(Branch,ATM) lt 12 and onl_pct gt 0.8) then segment = 'Online Dominant';
		end;
	end;

	if active=1 and segment = 'None' then do; /*assign the types for multi channel*/
		if branch lt 6 then segment = 'Multi - Low Branch';
		if branch gt 24 then segment = 'Multi - High Branch';
		if branch ge 6 and branch le 24 then segment='Multi - Med Branch';
	end;

	if active eq 1 and branch lt 6 and ATM lt 6 and phone_pts lt 12 and sum(divide(mobile_025,4),mobile_1) lt 12 
       and sum(web_1,divide(web_025,4),web) lt 12 then active=0;

	if active eq 0 then segment = 'Inactive';
end;

format ph_pct br_pct onl_pct atm_pct percent8.1;
/*keep HHID _FREQ_ Branch PHone Online ATM total br_pct ph_pct onl_pct atm_pct segment active;*/
run;

/* comapre scenarios */
proc freq data=virtual.points_2011_b ;
table segment / nocum nopercent missing;
run;

proc freq data=virtual.points_2011_6 ;
table segment / nocum nopercent missing;
run;

proc freq data=virtual.points_2011_1 ;
table segment / nocum nopercent missing;
run;

proc freq data=virtual.points_2011 ;
table segment / nocum nopercent missing;
run;

proc freq data=virtual.points_2011_new ;
table segment / nocum nopercent missing;
run;

proc freq data=virtual.points_2011_new_1 ;
table segment / nocum nopercent missing;
run;

proc freq data=virtual.points_2011_new_2 ;
table segment / nocum nopercent missing;
run;

proc freq data=virtual.points_2011_new_A ;
table segment / nocum nopercent missing;
run;

proc freq data=virtual.points_2011_new_B ;
table segment / nocum nopercent missing;
run;

proc freq data=virtual.points_2011_new_C ;
table segment / nocum nopercent missing;
run;

proc freq data=virtual.points_2011_new_D ;
table segment / nocum nopercent missing;
run;

proc freq data=virtual.points_2011_new_E ;
table segment / nocum nopercent missing;
run;

/*read addtl sign-on files */
%macro read_data_1;
%do i = 1 %to 12;
   %if &i = 1 %then %let name=JAN11;
   %if &i = 2 %then %let name=FEB11;
   %if &i = 3 %then %let name=MAR11;
   %if &i = 4 %then %let name=APR11;
   %if &i = 5 %then %let name=MAY11;
   %if &i = 6 %then %let name=JUN11;
   %if &i = 7 %then %let name=JUL11;
   %if &i = 8 %then %let name=AUG11;
   %if &i = 9 %then %let name=SEP11;
   %if &i = 10 %then %let name=OCT11;
   %if &i = 11 %then %let name=NOV11;
   %if &i = 12 %then %let name=JAN12;

/*	%put &i &name;*/
	filename mydata "C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\&name..txt";
	
	data &name;
	length HHID $ 9 ;
	infile mydata DLM='09'x firstobs=1 lrecl=4096 dsd;
		  INPUT hhID $
		  sign_ons ;
	run;

	data test&i;
	set &name;
	db = put(&i,z2.);
	run;
	
	

%end;
%mend;

%read_data_1;
%let i = 2;

option symbolgen;
%put &i &name;

data combined;
set test1- test12;
run;

proc sort data=combined;
by hhid db;
run;


proc summary data=combined (drop=db);
var sign_ons;
by HHID;
output out=virtual.signons (drop=_TYPE_)
   sum(sign_ons) = sign_ons;
run;


data virtual.summary_2011;
merge virtual.summary_2011 (in=a) virtual.signons (in=b drop=_freq_);
by hhid;
if a;
run;
