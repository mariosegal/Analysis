%macro read_files;
%do i = 1 %to 6;
   %if &i = 1 %then %let name=v201110;
   %if &i = 2 %then %let name=v201111;
   %if &i = 3 %then %let name=v201201;
   %if &i = 4 %then %let name=v201202;
   %if &i = 5 %then %let name=v201203;
   %if &i = 6 %then %let name=v201204;
	%put &i &name;
	filename mydata "C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\&name..txt";
	
	data &name;
	length HHID $ 9 ;
	infile mydata DLM='09'x firstobs=2 lrecl=4096 dsd;
		  INPUT hhID $ db:mmddyy10. csw atmo_1 atmo_025 atmo_15 vru atmt_1 atmt_025 sign_ons br_1 br_15 mobile_025 mobile_1 web_025 web_1 web_ind;  
    format db date10. ; 
	run;
%end;
%mend;

%read_files;




data virtual.combined_201204;
set v201110 v201111 v201201 v201202 v201203 v201204;
run;



data virtual.combined_201204;
set virtual.combined_201204;
hh =1;
run;


proc sort data=virtual.combined_201204;
by hhid;
run;

proc summary data=virtual.combined_201204;
var csw atmo_1 atmo_025 atmo_15 vru atmt_1 atmt_025 sign_ons br_1 br_15 mobile_025 mobile_1 web_025 web_1 web_ind;
by hhid;
output out=summary (drop=_FREQ_ _TYPE_)
       sum(hh) = count
	   sum(csw) = csw
	   sum(atmo_1) = atmo_1
	   sum(atmo_025) = atmo_025
	   sum(atmo_15) = atmo_15
	   sum(vru) = vru
	   sum(atmt_1) = atmt_1
	   sum(atmt_025) = atmt_025
	   sum(sign_ons) = sign_ons
	   sum(br_1) = br_1
	   sum(br_15) = br_15
	   sum(mobile_025) = mobile_025
	   sum(mobile_1) = mobile_1
	   sum(web_025) = web_025
	   sum(web_1) = web_1
	   sum(web_ind) = web_ind;
run;




filename mydata "C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\apr12dda.txt";

data virtual.dda201204;
length hhid $ 9;
infile mydata ;
input hhid $ ;
run;

data temp1;
merge summary (in=a) virtual.dda201204 (in=b);
by hhid;
if a and b;
run;

data temp2;
set temp1;
where count eq 6;
run;

data virtual.points_201204;
length segment $ 1;
set temp2 ;
if BR_1 eq . then BR_1 = 0;
if BR_15 eq . then BR_15 = 0;
if mobile_025 eq . then mobile_025 = 0;
if mobile_1 eq . then mobile_1 = 0;
if web_025 eq . then web_025 = 0;
if web_1 eq . then web_1 = 0;
if web_ind eq . then web_ind = 0;
if sign_ons eq . then sign_ons = 0;
if vru  eq . then vru  = 0;
if csw eq . then csw = 0;
if atmo_025 eq . then atmo_025 =0;
if atmo_1 eq . then atmo_1 = 0;
if atmo_15 eq . then atmo_15 =0;
if atmt_025 eq . then atmt_025 =0;
if atmt_1 eq . then atmt_1 = 0;

Branch_pts = sum(BR_1, BR_15*1.5)*2;
web_aux = web_ind; *min(sign_ons,1);*divide(sign_ons,4); *this is where I change the points for loging to web;

vru_pts = divide (vru,4)*2;
csw_pts = divide (csw,4)*2;
atmo_pts = sum(atmo_025*0.25 , atmo_1 , atmo_15*1.5)*2;
atmt_pts = sum(atmt_025*0.25 , atmt_1)*2 ;
ATM_pts = sum(atmo_pts , atmt_pts);
mobile_pts = sum(divide(mobile_025,4),mobile_1)*2;
web_pts = sum(web_1,divide(web_025,4),web_aux)*2;
Online_pts = sum(mobile_pts,web_pts);
Phone_pts = sum(vru_pts,csw_pts);
total_pts = sum(ATM_pts , Online_pts , Phone_pts , Branch_pts);

br_pct = divide(branch_pts,total_pts);
ph_pct = divide(phone_pts,total_pts);
onl_pct = divide(online_pts,total_pts);
ATM_pct = divide(ATM_pts,total_pts);


vru_flag = 0;
if vru_pts ge 12 then vru_flag = 1;
csw_flag = 0;
if csw_pts ge 12 then vru_flag = 1;
mobile_flag = 0;
if mobile_pts ge 12 then mobile_flag = 1;
web_flag = 0;
if web_pts ge 12 then web_flag = 1;
branch_flag = 0;
if branch_pts ge 6 then branch_flag = 1;
atmo_flag = 0;
if atmo_pts ge 6 then atmo_flag = 1;
atmt_flag = 0;
if atmt_pts ge 6 then atmt_flag = 1;
active2 = sum(vru_flag, csw_flag, mobile_flag,web_flag,branch_flag,atmo_flag,atmt_flag);

if br_pct eq . then br_pct = 0;
if ph_pct eq . then ph_pct = 0;
if onl_pct eq . then onl_pct = 0;
if ATM_pct eq . then ATM_pct = 0;

segment = 'X';
material = 1; /* should be zero, I used 1 to force it as it is not working as expected */
/*if (branch ge 6) or (atm ge 6) or (phone ge 12) then material = 1; */

if material eq 1 then do;
	active = 0;
	if ((sum(branch_pts,ATM_pts) gt 6 or sum(online_pts,phone_pts) gt 12)) and (material eq 1) then active = 1;

	*section below is the additional inactive flag;
/*	if active eq 1 and active2 eq 0 then do;*/
/*         active = 0;*/
/*		 active1 = 1;*/
/*    end;*/
		
	if active eq 1 then do;
		if max(br_pct,ph_pct,onl_pct,atm_pct) gt 0.8 then do; /*we have a dominant one*/
			if ( sum(online_pts,phone_pts) lt 24 and ATM_pts lt 12 and br_pct gt 0.8) then segment = 'B';
			if ( sum(online_pts,phone_pts) lt 24 and Branch_pts lt 12 and atm_pct gt 0.8) then segment = 'A';
			if ( online_pts lt 24 and sum(Branch_pts,ATM_pts) lt 12 and ph_pct gt 0.8) then segment = 'P';
			if ( Phone_pts lt 24 and sum(Branch_pts,ATM_pts) lt 12 and onl_pct gt 0.8) then segment = 'O';
		end;
	end;

	if active=1 and segment = 'X' then do; /*assign the types for multi channel*/
		if branch_pts lt 6 then segment = 'L';
		if branch_pts gt 24 then segment = 'H';
		if branch_pts ge 6 and branch_pts le 24 then segment='M';
	end;


	if active eq 0 then segment = 'I';
end;

format ph_pct br_pct onl_pct atm_pct percent8.1;
/*keep HHID _FREQ_ Branch PHone Online ATM total br_pct ph_pct onl_pct atm_pct segment active;*/
run;


