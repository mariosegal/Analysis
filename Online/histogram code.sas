proc freq data=temp_web;
table web_signon;
run;

proc univariate data=temp_web freq;
var web_signon;
run;


proc univariate data=tempz (where=(nov ge 1 and nov le 150)) noprint;
   histogram nov / lognormal ;
run;

data tempz;
merge data.main_201112(keep=hhid web_signon rename=(web_signon=dec) in=a) data.main_201111(keep=hhid web_signon rename=(web_signon=nov) in=b);
by hhid;
run;


proc rank data=tempz  out=ranks1 groups=10;
where (dec ge 1 and dec le 300);
ranks groups;
var dec;
run;

proc sort data=ranks1;
by groups;
run;

proc tabulate data=ranks1 out=bins;
class groups;
var dec;
table groups, dec*(N pctn min max mean);
run;

proc sgplot data=bins;
where group ne 19;
highlow x=group high=web_signon_max low=web_signon_min
    / close=web_signon_mean type=bar;
run;



data tempx;
length web_band $ 10;
set data.main_201112;
Select;
	when (web_signon eq .) web_band = 'No Web';
	when (web_signon eq 0)  web_band = 'Inactive';
	when (web_signon ge 1 and web_signon le 4)  web_band = 'Up to 4';
	when (web_signon ge 5 and web_signon le 15)  web_band = '5 to 15';
	when (web_signon ge 16 and web_signon le 30)  web_band = '16 to 30';
	when (web_signon gt 30)  web_band = 'Over 30';
end;
run;

proc freq data=tempx;
table web_band / nopercent nocum nofreq out=data.web_band_class;
run;

data data.main_201112;
set tempx;
run;

data data.web_band_class;

input web_band $ 10;
datalines;
No Web
Inactive
Up to 4
5 to 15
16 to 30
Over 30
;
run;

data tempx;
set data.web_band_class (drop= count percent);
run;

data data.web_band_class;
set tempx;
run;


proc freq data=data.main_201111 ;
where web_signon le 100 and hh eq 1;
table web_Signon / out=histogram;
run;

data;
set data.main_201111;
where web_signon gt 100 and hh eq 1;
run;

proc means data=data.main_201111;
where web_signon gt 100 and hh eq 1;
run;
