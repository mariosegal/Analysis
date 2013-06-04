libname online 'C:\Documents and Settings\ewnym5s\My Documents\Online';
libname data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
options fmtsearch=(SAS);

options MSTORED SASMSTORE = mjstore;
libname mjstore 'C:\Documents and Settings\ewnym5s\My Documents\SAS\Macros';





proc tabulate data=data.main_201111;
when clv_rem ne .;
var clv_rem clv_rem_ten;
class segment web_band;
table (segment ALL),(web_band ALL)*clv_rem*N;
table (segment ALL),(web_band ALL)*clv_rem*Mean;
table (segment ALL),(web_band ALL)*clv_rem_ten*Mean;
run;

proc tabulate data=data.main_201111 out=clv;
when clv_rem ne . and segment le 6 and segment ne .;
var clv_rem clv_rem_ten;
class segment web_band;
table (segment ALL),(web_band ALL)*clv_rem* (N*Mean);;
run;


proc tabulate data=data.main_201111 out=ten;
when clv_rem ne . and segment le 6 and segment ne .;
var clv_rem clv_rem_ten;
class segment web_band;
table (segment ALL),(web_band ALL)*clv_rem_ten*Mean;
run;


proc tabulate data=data.main_201111 out=clv;
when clv_rem ne . and segment le 6 and segment ne .;
var clv_rem clv_rem_ten;
class segment web_band;
table (web_band ALL), clv_rem, (N*Mean);
BY SEGMENT;
run;

proc gtile data=clv;
run;

data tempx;
set data.main_201111;
when web_signon le 100;
keep hhid hh clv: segment web_band;
run;

PROC SORT DATA=tempx;
by segment web_band;
run;


proc MEANS data=tempx n MEAN ;
when clv_rem ne . and segment le 6 and segment ne .;
VAR clv_rem ;
BY SEGMENT WEB_BAND;
output out=data(drop=_TYPE_ _FREQ_);
run;

proc transpose data=data out=data1 (drop=_NAME_);
by segment web_band;
ID _STAT_;
run;

data data2;
set data1;
select (web_band);
	when ('No Web') band=1;
	when ('Inactive') band=2;
	when ('q4') band = 3;
	when ('q3') band = 4;
	when ('q2') band = 5;
	when ('q1') band = 6;
	otherwise band=7;
end;
run;








goptions reset=all device=java noborder;
proc gtile data=data1 ;
tile N tileby=(segment web_band) / colorvar=mean;
run;

goptions reset=all;

axis1 order=(1 2 3 4 5 6);
axis2 order=(1 2 3 4 5 6);
proc g3d data=data2;
/*plot band*segment=mean / yaxis=axis2 xaxis=axis1 side tilt=30;*/
scatter band*segment=mean / yaxis=axis2 xaxis=axis1 yticknum=6 xticknum=6;
format segment segfmt. band webbandfmt.;
run;


proc gcontour data=data2;
plot band*segment=mean / vaxis=axis2 haxis=axis1;
run;

proc format library=SAS;
value webbandfmt 1 = 'No Web'
				 2 = 'Inactive'
				 3 = 'Bottom Quartile'
				 4 = 'Second Quartile'
				 5 = 'Third Quartile'
				 6 = 'Top Quartile';
run;

