libname virtual 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled';
libname Data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname wip 'C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files';

options MSTORED SASMSTORE = mjstore;
libname mjstore 'C:\Documents and Settings\ewnym5s\My Documents\SAS\Macros';

libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
options fmtsearch=(SAS);


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


/*read data*/
/*Note: dec 2011 does not have mobile data so I will defacto ignore it*/
/*I modified  the counter at the end to read the last file for jan2012*/
/*this macro could read all my files at once*/
%macro read_files;
/*%do name = JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC;*/
%do i = 1 %to 13;
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

/*merge with chk hhs to create analysis set*/
data temp_summary;
merge virtual.chk_hhs (in=a) virtual.summary_2011 (in=b where=(_FREQ_ eq 12));
by hhid;
if a and b;
run;


/*assign point and classify into groups*/
data virtual.points_2011 ;
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

Branch = sum(BR_1, BR_15*1.5);
Phone = divide(Phone,4);
Online= sum(divide(mobile_025,4),mobile_1,web_1,divide(web_025,4),web);
ATM = sum(divide(ATM_025,4),ATM_1,ATM_15*1.5);
total = sum(ATM , Online , Phone , Branch);
br_pct = divide(branch,total);
ph_pct = divide(phone,total);
onl_pct = divide(online,total);
ATM_pct = divide(ATM,total);

if br_pct eq . then br_pct = 0;
if ph_pct eq . then ph_pct = 0;
if onl_pct eq . then onl_pct = 0;
if ATM_pct eq . then ATM_pct = 0;

active = 0;
if (sum(branch,ATM) gt 6 or sum(online,phone) gt 12) then active = 1;
segment = 'None';

if max(br_pct,ph_pct,onl_pct,atm_pct) gt 0.8 then do; /*we have a dominant one*/
	if ( sum(online,phone) lt 24 and ATM lt 12 and br_pct gt 0.8) then segment = 'Branch Dominant';
	if ( sum(online,phone) lt 24 and Branch lt 12 and atm_pct gt 0.8) then segment = 'ATM Dominant';
	if ( online lt 24 and sum(Branch,ATM) lt 12 and ph_pct gt 0.8) then segment = 'Phone Dominant';
	if ( Phone lt 24 and sum(Branch,ATM) lt 12 and onl_pct gt 0.8) then segment = 'Online Dominant';
end;

if active=1 and segment = 'None' then do; /*assign the types for multi channel*/
	if branch lt 6 then segment = 'Multi - Low Branch';
	if branch gt 24 then segment = 'Multi - High Branch';
	if branch ge 6 and branch le 24 then segment='Multi - Med Branch';
end;

if active eq 0 then segment = 'Inactive';

format ph_pct br_pct onl_pct atm_pct percent8.1;
keep HHID _FREQ_ Branch PHone Online ATM total br_pct ph_pct onl_pct atm_pct segment active;
run;

/*get distribution*/
proc freq data=virtual.points_2011;
table segment*active;
run;





data data.main_201111;
set tempx;
run;

%let class1=virtual_seg segment;
%let identifier=201111;
%let title="Tran Segment";
%let out_file=detailed_ex_trust;
%let condition=virtual_seg ne "";
%let out_dir=Virtually Domiciled;
%let dir="C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files";

option orientation=landscape;
%profile_analysis(condition=tran_segm ne "XXXXX",class1=tran_segm,out_file=virtual_groups_summary_new,
out_dir=Virtually Domiciled,identifier=201111,dir="C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files",title="Tran Segment",clean=0);

%profile_analysis(condition=virtual_seg ne "",class1=virtual_seg,out_file=virtual_groups_detail_new,
out_dir=Virtually Domiciled,identifier=201111,dir="C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files",title="Tran Segment",clean=0);


option orientation=portrait;
%profile_analysis(condition=virtual_seg ne "",class1=tran_segm,out_file=virtual_groups_X,
out_dir=Virtually Domiciled,identifier=201111,dir="C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files",title="Tran Segment");

%profile_analysis(condition=virtual_seg ne "",class1=web_band,out_file=online_new,
out_dir=Online,identifier=201111,dir="C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files",title="Online",clean=0);


proc freq data=data.main_201111;
where virtual_seg ne '';
table virtual_seg / nofreq nocum out = tempz;
run;

data data.virtual_seg_class;
set tempz;
keep virtual_seg;
run;


data tempx;
length tran_segm $ 20;
set data.main_201111;

tran_segm = 'XXXX';
if virtual_seg in ('Inac')  then tran_segm = 'Inactive';
if virtual_seg in ('Branch Dominant' 'Multi - High Branch' 'Multi - Med Branch')  then tran_segm = 'Branch';
if virtual_seg in ('ATM Dominant' 'Online Dominant' 'Phone Dominant' 'Multi - Low Branch')  then tran_segm = 'Virtual';

run;


proc freq data=tempx;
table tran_segm;
run;

data data.main_201111;
set tempx;
run;



data virtual.checking_sample;
set virtual.checking (obs= 100);
run;

data virtual.chk_hhs_sample;
set virtual.chk_hhs (obs= 100);
run;

data virtual.Main_2011_sample;
set virtual.Main_2011 (obs= 100);
run;

data virtual.Summary_2011_sample;
set virtual.Summary_2011 (obs= 100);
run;

data virtual.Points_2011_sample;
set virtual.Points_2011 (obs= 100);
run;


data temp1;
set data.main_201111 (keep=hhid distance virtual_seg hh);
where virtual_seg ne '';
do i = 1 to 15 by 1;
	if  i-1 <= distance < i then do;
		ind=i;
		bin=cat(i-1,' to ',i);
	end;
end;
if bin eq "" then do;
	bin='Over 15';
	ind=16;
end;
drop i;
run;

proc sort data=temp1;
by bin;
run;

data bin_names;
set temp1;
by bin;
if first.bin then output;
keep bin ind;
run;


proc sort data=bin_names;
by ind;
run;

data tempq;
set bin_names;
drop ind;
run;

data bin_names;
set tempq;
run;

proc sort data=temp1;
by virtual_seg;
run;


data virtual_seg;
set temp1;
by virtual_seg;
if first.virtual_seg then output;
keep virtual_seg;
run;

PROC SQL;
create table class as 
SELECT *
FROM virtual_seg, bin_names
;
QUIT;

proc tabulate data=temp1 out=freq_table (DROP=_TYPE_ _PAGE_ _table_) classdata=class exclusive;
class bin virtual_Seg;
var hh;
table (virtual_Seg), (bin All)*(hh)*(SUM ROWPCTSUM);
run;

PROC PRINT DATA=FREQ_TABLE NOBS;
RUN;


