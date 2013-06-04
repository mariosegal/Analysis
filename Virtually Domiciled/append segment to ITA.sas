


filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Credit Card\ITA Campaign March 2012\Mar_ita.txt';

data virtual.ita;
length promo $ 10 week_id $ 9 cell $ 30 control $ 1;
infile mydata dlm='09'x dsd lrecl=4096 ;
input promo $ week_id $ cell $ control $;
run;

filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Credit Card\ITA Campaign March 2012\ita_id.txt';

data virtual.ita_ids;
length week_id $ 9 hhid $ 9;
infile mydata dlm='09'x dsd lrecl=4096 firstobs=2;
input week_id $ hhid $;
run;

data virtual.ita;
merge virtual.ita (in=a) virtual.ita_ids (in=b);
by week_id;
if a;
run;

proc sort data=virtual.ita;
by hhid;
run;

data test;
merge virtual.ita (in=a) data.main_201111 (in=b keep=hhid virtual_seg);
by hhid;
if a;
run;

data virtual.ita;
set test;
run;

proc freq data=virtual.ita;
table virtual_seg/missing;
run;


