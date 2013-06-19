proc contents data=virtual.models_20130220 varnum short;
run;


data mma;
set virtual.models_20130220;
keep hhid mmCondResp_Branch mmCondResp_online mmCondResp_phone mmCondResp_atm mmCondResp_mobile ;
run;

data sec;
set virtual.models_20130220;
keep hhid secCondResp_Branch secCondResp_online secCondResp_phone secCondResp_atm secCondResp_mobile ;
run;

data iln;
set virtual.models_20130220;
keep hhid ilnCondResp_Branch ilnCondResp_online ilnCondResp_phone ilnCondResp_atm ilnCondResp_mobile ;
run;


%let var=mmCondResp_Branch;

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



