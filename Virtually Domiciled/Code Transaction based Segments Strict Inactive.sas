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
%do i = 12 %to 12;
   %if &i = 1 %then %let name=n201101;
   %if &i = 2 %then %let name=n201102;
   %if &i = 3 %then %let name=n201103;
   %if &i = 4 %then %let name=n201104;
   %if &i = 5 %then %let name=n201105;
   %if &i = 6 %then %let name=n201106;
   %if &i = 7 %then %let name=n201107;
   %if &i = 8 %then %let name=n201108;
   %if &i = 9 %then %let name=n201109;
   %if &i = 10 %then %let name=n201110;
   %if &i = 11 %then %let name=n201111;
   %if &i = 12 %then %let name=n201201;
/*   %if &i = 13 %then %let name=JAN12;*/

	%put &i &name;
	filename mydata "C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\&name..txt";
	
	data virtual.&name;
	length HHID $ 9 Db $ 15;
	infile mydata DLM='09'x firstobs=2 lrecl=4096 dsd;
		  INPUT hhID $
			csw atmo1 atmo025 atmo15 db $ vru atmt1 atmt025;            
	run;
%end;
%mend;

%read_files;





/*this concatenates the datasets, need to modify to read all the 12 files we are using as now it takes 11 months and adds jan 12 only*/
data virtual.main_2011_new;
set virtual.n2011: virtual.n201201;
run;

proc sort data=virtual.main_2011_new;
by hhid;
run;

/*summarize data by bucket across months */
proc contents data=temp_summary varnum short; run;

proc summary data=virtual.main_2011_new (drop=DB);
var csw atmo1 atmo025 atmo15 vru atmt1 atmt025;
by HHID;
output out=virtual.summary_2011_new (drop=_TYPE_)
	sum(VRU) = vrux
	sum(csw) = csw
	sum(atmo025) = atmo025
	sum(atmo1) = atmo1
	sum(atmo15) = atmo15
	sum(atmt025) = atmt025
	sum(atmt1) = atmt1;
run;


data virtual.summary_2011_new ;
merge virtual.summary_2011_new (in=a rename=(_FREQ_=count)) virtual.summary_2011 (in=b);
by hhid;
if a and b;
run;



data temp1;
merge virtual.summary_2011_new (in=a) virtual.non_consumer (in=b);
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
data virtual.points_2011_New_base;
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
if vrux  eq . then vrux  = 0;
if csw eq . then csw = 0;
if atmo025 eq . then atmo025 =0;
if atmo1 eq . then atmo1 = 0;
if atmo15 eq . then atmo15 =0;
if atmt025 eq . then atmt025 =0;
if atmt1 eq . then atmt1 = 0;


Branch = sum(BR_1, BR_15*1.5);
web_aux = web; *this is where I change the points for loging to web, do not use the commented lines below;
Online= sum(divide(mobile_025,4),mobile_1,web_1,divide(web_025,4),web_aux);
/*Online= sum(divide(mobile_025,4),mobile_1,web_1,divide(web_025,4),max(web,1));*/
/*Online= sum(divide(mobile_025,4),mobile_1,web_1,divide(web_025,4),divide(sign_ons,4));*/
/*Online= sum(divide(mobile_025,4),mobile_1,web_1,divide(web_025,4),max(web,6));*/
ATM = sum(divide(ATM_025,4),ATM_1,ATM_15*1.5);
total = sum(ATM , Online , Phone_pts , Branch);
vru_pts = divide (vrux,4);
csw_pts = divide (csw,4);
atmo_pts = atmo025*0.25 + atmo1 + atmo15*1.5;
atmt_pts = atmt025*0.25 + atmt1 ;
mobile_pts = sum(divide(mobile_025,4),mobile_1);
web_pts = sum(web_1,divide(web_025,4),web_aux);
Phone_pts = vru_pts+csw_pts;
br_pct = divide(branch,total);
ph_pct = divide(phone_pts,total);
onl_pct = divide(online,total);
ATM_pct = divide(ATM,total);

vru_flag = 0;
if vru_pts ge 12 then vru_flag = 1;
csw_flag = 0;
if csw_pts ge 12 then vru_flag = 1;
mobile_flag = 0;
if mobile_pts ge 12 then mobile_flag = 1;
web_flag = 0;
if web_pts ge 12 then web_flag = 1;
branch_flag = 0;
if branch ge 6 then branch_flag = 1;
atmo_flag = 0;
if atmo_pts ge 6 then atmo_flag = 1;
atmt_flag = 0;
if atmt_pts ge 6 then atmt_flag = 1;
active2 = sum(vru_flag, csw_flag, mobile_flag,web_flag,branch_flag,atmo_flag,atmt_flag);


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
    if active eq 1 and active2 eq 0 then do;
         active = 0;
		 active1 = 1;
    end;
		
	if active eq 1 then do;
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

/*	if active eq 1 and branch lt 6 and (atmo025*0.25 + atmo1 + atmo15*1.5) lt 6 and (atmt025*0.25 + atmt1 ) lt 6 and (vrux*0.25) lt 12 and (csw*0.25) lt 12 */
/*       and sum(divide(mobile_025,4),mobile_1) lt 12 and sum(web_1,divide(web_025,4),web_pts) lt 12 then  do;*/
/*			active=0;*/
/*		end;*/

	if active eq 0 then segment = 'Inactive';
end;

format ph_pct br_pct onl_pct atm_pct percent8.1;
/*keep HHID _FREQ_ Branch PHone Online ATM total br_pct ph_pct onl_pct atm_pct segment active;*/
run;

/* comapre scenarios */
proc freq data=virtual.points_2011_New_base ;
table segment / nocum nopercent missing;
run;

data data.main_201111;
merge data.main_201111 (in=a) virtual.points_2011_New_base (in=b keep=hhid segment rename=(segment=segment_new));
by hhid;
if a ;
run;

%profile_analysis (condition=segment_new eq 'Inactive' and virtual_seg ne 'Inac',Class1=segment_new,out_file=Inactives,
                         out_dir=Virtually Domiciled,identifier=201111,
                         dir="C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files", title='New Inactives', clean=0);

data temp;
set data.main_201111;
where segment_new eq 'Inactive' and virtual_seg ne 'Inac';
keep hhid segment_new virtual_seg;
run;

data temp_a;
merge temp (in=a) virtual.points_2011_New_base (in=b drop = segment);
by hhid;
if a and b;
run;



proc tabulate data = temp_a;
class phone_pts ATM Online Branch;
table phone_pts*ATM*Online*Branch,N='HHs'*f=comma12.;
run;
