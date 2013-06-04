options compress=yes;

data deposits.CRA;
length tract2 $ 20;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Deposits\CRA Class.txt' dsd dlm='09'x firstobs=2 lrecl=4096 missover obs=max;
input ID state $ county $ tract $ tract2 cra $;
run;

data a;
length hhid $ 9 tract $ 20 block $ 20;
infile 'C:\Documents and Settings\ewnym5s\My Documents\tract.txt' dsd dlm='09'x firstobs=2 lrecl=4096 missover obs=max;
input hhid $ tract $  block $ ;
run;

proc sort data=a;
by tract;
run;

proc sort data=deposits.cra;
by tract2;
run;

data b;
merge a (in=a rename=(tract=tract2)) deposits.cra(in=b rename=( tract=tract1));
by tract2;
if a;
run;

proc sort data=deposits.dda_Analysis;
by hhid;
run;

proc sort data=b;
by hhid;
run;

data data.main_201206;
merge data.main_201206 (in=a) b(in=b keep=hhid  tract2 cra);
by hhid;
if a;
run;

proc freq data=deposits.cra;
table cra;
run;

/*data data.main_201206;*/
/*set data.main_201206;*/
/*year = 'Other';*/
/*if dda_2008 eq 1 and dda_2011 ne 1 then year = '2008';*/
/*if dda_2008 ne 1 and dda_2011 eq 1 then year = '2011';*/
/*run;*/


proc tabulate data=data.main_201206 (keep=cra tract2 tag_new year) missing;
where tag_new ne '';
class cra tag_new year;
table (year ALL)*tag_new, CRA*(N='HHs'*f=comma12. rowpctN='Percent'*f=pctfmt.) / nocellmerge;
run;

proc sort data=data.main_201206;
by tract2;
run;

proc tabulate data=data.main_201206 (keep=cra tract2 tag_new dda) out=cra_data missing;
where tag_new ne '' and dda eq 1;
class tract2  cra tag_new;
var dda ;
table tract2, tag_new*sum*dda / mocellmerge;
run;


proc transpose data=cra_data out=cra_data1 ;
by tract2;
id tag_new;
var dda_sum;
run;
 options compress=yes;
data deposits.cra_data1;
set cra_data1;
if free_only eq . then free_only = 0;
if college_only eq . then college_only = 0;
if premium_only eq . then premium_only = 0;
if other_only eq . then other_only = 0;
if Multi eq . then Multi = 0;
total = sum(Free_Only, College_Only, Premium_Only, Other_Only, Multi);
free_pct = divide (free_only, total);
college_pct = divide (college_only, total);
basic_pct = free_pct + college_pct;
run;

proc freq data=cra_data1 order=freq;
table total;
run;

proc contents data=deposits.cra_data1 varnum short;
run;

/**/
/*data _null_;*/
/*file 'C:\Documents and Settings\ewnym5s\My Documents\Deposits\cra_mapdata.txt' dsd dlm='09'x;*/
/*set deposits.cra_data1;*/
/*put tract2$ College_Only Free_Only Other_Only Premium_Only Multi total free_pct college_pct basic_pct;*/
/*run;*/

PROC EXPORT DATA= deposits.cra_data1(drop=_name_)
            OUTFILE= 'C:\Documents and Settings\ewnym5s\My Documents\Deposits\cra_mapdata.xls'
            DBMS=XLS REPLACE;

RUN;



