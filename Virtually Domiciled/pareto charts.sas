proc contents data=virtual.models_20130220 varnum short;
run;


data mma;
set virtual.models_20130220;
keep hhid mmCondResp_Branch mmCondResp_online mmCondResp_phone mmCondResp_atm mmCondResp_mobile 
     mmDeltaCondClv_Branch mmDeltaCondClv_online mmDeltaCondClv_phone mmDeltaCondClv_atm mmDeltaCondClv_mobile 
     mmDeltaCondEv_Branch mmDeltaCondEv_online mmDeltaCondEv_phone mmDeltaCondEv_atm mmDeltaCondEv_mobile ;
run;

data sec;
set virtual.models_20130220;
keep hhid secCondResp_Branch secCondResp_online secCondResp_phone secCondResp_atm secCondResp_mobile 
     secDeltaCondClv_Branch secDeltaCondClv_online secDeltaCondClv_phone secDeltaCondClv_atm secDeltaCondClv_mobile 
     secDeltaCondEv_Branch secDeltaCondEv_online secDeltaCondEv_phone secDeltaCondEv_atm secDeltaCondEv_mobile ;
run;

data iln;
set virtual.models_20130220;
keep hhid ilnCondResp_Branch ilnCondResp_online ilnCondResp_phone ilnCondResp_atm ilnCondResp_mobile 
     ilnDeltaCondClv_Branch ilnDeltaCondClv_online ilnDeltaCondClv_phone ilnDeltaCondClv_atm ilnDeltaCondClv_mobile 
     ilnDeltaCondEv_Branch ilnDeltaCondEv_online ilnDeltaCondEv_phone ilnDeltaCondEv_atm ilnDeltaCondEv_mobile ;
run;


%let var=mmDeltaCondEv_Branch mmDeltaCondEv_online mmDeltaCondEv_phone mmDeltaCondEv_atm mmDeltaCondEv_mobile;

proc univariate data=mma;
histogram &var / NMIDPOINTS=25 outhist=out1;
run;

proc sort data=out1;
by descending _MIDPT_;
run;

data out1;
set out1;
retain cumm;
cumm+_OBSPCT_;
run;

proc export data=out1 outfile='C:\Documents and Settings\ewnym5s\My Documents\Analysis\Virtually Domiciled\MMA_chart_data.xlsx' 
             dbms=excel replace;
		     sheet="&var";
run;

secCondResp_Branch secCondResp_online secCondResp_phone secCondResp_atm secCondResp_mobile 
%let var=secCondResp_online;

proc univariate data=sec;
histogram &var / NMIDPOINTS=25 outhist=out1;
run;

proc sort data=out1;
by descending _MIDPT_;
run;

data out1;
set out1;
retain cumm;
cumm+_OBSPCT_;
run;

proc export data=out1 outfile='C:\Documents and Settings\ewnym5s\My Documents\Analysis\Virtually Domiciled\SEC_chart_data.xlsx' 
             dbms=excel replace;
		     sheet="&var";
run;


ilnCondResp_Branch ilnCondResp_online ilnCondResp_phone ilnCondResp_atm ilnCondResp_mobile 
%let var=ilnCondResp_mobile;

proc univariate data=iln;
histogram &var / NMIDPOINTS=25 outhist=out1;
run;

proc sort data=out1;
by descending _MIDPT_;
run;

data out1;
set out1;
retain cumm;
cumm+_OBSPCT_;
run;

proc export data=out1 outfile='C:\Documents and Settings\ewnym5s\My Documents\Analysis\Virtually Domiciled\ILN_chart_data.xlsx' 
             dbms=excel replace;
		     sheet="&var";
run;



proc sgplot data=out1;
/*vbar _MIDPT_ / response=_count_;*/
series x=_MIDPT_ y=cumm;
xaxis type = linear values=(0.015 to 0.0 by -.0006) reverse;
yaxis values=(0 to 100 by 10);
format  _MIDPT_ percent6.1;
run;



/*############   do it with the delta clv probability weighted ####################*/
%let prod = iln;
%let table  =ILN;

/*proc means data= &table min  p10 p20 p30 p40 p50 p60 p70 p80 p90 max;*/
/*var &prod.DeltaCondEv_Branch &prod.DeltaCondEv_online &prod.DeltaCondEv_phone &prod.DeltaCondEv_atm &prod.DeltaCondEv_mobile;*/
/*run;*/

proc sql ;
select min(min(&prod.DeltaCondEv_Branch, &prod.DeltaCondEv_online, &prod.DeltaCondEv_phone, &prod.DeltaCondEv_atm, &prod.DeltaCondEv_mobile)),
	  max(max(&prod.DeltaCondEv_Branch, &prod.DeltaCondEv_online, &prod.DeltaCondEv_phone, &prod.DeltaCondEv_atm, &prod.DeltaCondEv_mobile))
	  into :min1 ,:max1 from &table;
quit;

data &table._chart;
set &table ;
retain step;
if _N_ eq 1 then step = ((&max1-&min1)/20);

do i = 1 to 20 ;
	low = &min1 + (i-1)*step;
	high = &min1 + (i)*step;
	if &prod.DeltaCondEv_Branch ge low and &prod.DeltaCondEv_Branch lt high then branch = i;
	if &prod.DeltaCondEv_online ge low and &prod.DeltaCondEv_online lt high then online = i;
	if &prod.DeltaCondEv_phone ge low and &prod.DeltaCondEv_phone lt high then phone = i;
	if &prod.DeltaCondEv_atm ge low and &prod.DeltaCondEv_atm lt high then atm = i;
	if &prod.DeltaCondEv_mobile ge low and &prod.DeltaCondEv_mobile lt high then mobile = i;
end;
drop step low high;
run;


proc tabulate data=&table._chart out=&table._chart1;
class branch online phone atm mobile;
var &prod.DeltaCondEv_Branch &prod.DeltaCondEv_online &prod.DeltaCondEv_phone &prod.DeltaCondEv_atm &prod.DeltaCondEv_mobile;
table branch, &prod.DeltaCondEv_Branch*(N*f=comma12. max*f=dollar12.2);
table online, &prod.DeltaCondEv_online*(N*f=comma12. max*f=dollar12.2);
table phone, &prod.DeltaCondEv_phone*(N*f=comma12. max*f=dollar12.2);
table atm, &prod.DeltaCondEv_atm*(N*f=comma12. max*f=dollar12.2);
table mobile, &prod.DeltaCondEv_mobile*(N*f=comma12. max*f=dollar12.2);
run;

*create a neater table;
data &table._chart2;
length channel $ 6;
set &table._chart1;
	if branch ne . then channel = 'Branch';
	if online ne . then channel = 'Online';
	if Phone ne . then channel = 'Phone';
	if atm ne . then channel = 'ATM';
	if mobile ne . then channel = 'Mobile';
	
	rank=sum(branch,mobile,online,atm,phone);
	count = sum(&prod.DeltaCondEv_Branch_N, &prod.DeltaCondEv_online_N, &prod.DeltaCondEv_phone_N, &prod.DeltaCondEv_atm_N, &prod.DeltaCondEv_mobile_N);	
	keep count channel rank;
run;

proc sort data=&table._chart2;
by channel descending rank;
run;

data &table._chart2;
set &table._chart2;
retain cumm;
by channel;
if first.channel then cumm=0;
cumm+count;
max = &min1 + (rank)*((&max1-&min1)/20);
run;

ods html style=mtbnew;
title "Summary of &table Model";
proc sgplot data=&table._chart2;
series x=max y=cumm / group=channel;
xaxis label="Expected CLV Increase (Probabibility Weighted)" type = linear reverse labelattrs=(weight=bold);
yaxis label="Cummulative number of HHs" labelattrs=(weight=bold);
format  max dollar12.2 cumm comma12.;
run;

proc export data=&table._chart2 outfile="C:\Documents and Settings\ewnym5s\My Documents\Analysis\Virtually Domiciled\chart_data_20130627.xlsx" 
             dbms=excel replace;
		     sheet="&prod";
run;
