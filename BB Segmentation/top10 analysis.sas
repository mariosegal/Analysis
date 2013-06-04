LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';
OPTIONS FMTSEARCH=(BBSEG WORK);

PROC FREQ DATA=BBSEG.hHdata_NEW ORDER=FREQ;

tables SIC*target_new / out = work.results_top5 norow nocol nopercent;
run;


proc sort data=results_top5;
by sic;
run;

data temp;
merge results_top5 (in=a) bbseg.sic_list (in=b);
by sic;
if a;
run;

data results_top5;
set temp;
run;

proc sort data=results_top5;
by Target_new descending count ;
run;

proc rank data=results_top5 out=ranked_results descending;
by target_new;
var  count;
ranks rank1;

run;

proc sort data=ranked_results;
by Target_new rank1;
run;

data tempx;
set ranked_results;
where rank1 le 10;
run;

proc report data=tempx out=top10_report (DROP=_break_) nowindows;
columns Target_new NAME Rank1 Count;
define Target_new/order;
define rank1 /display;
define count / analysis;
FORMAT COUNT COMMA10.0;
run;




