data nick;
length  hhid $ 9 cardgrp $ 1;
infile 'C:\Documents and Settings\ewnym5s\My Documents\cc_link.txt' dsd dlm='09'x lrecl=4096 missover firstobs=2;
input  hhid $  acct cardgrp $;
run;


proc freq data=nick noprint;
table hhid / missing out=x (where=(count ge 2));
run;

proc sort data=nick;
by hhid cardgrp;
run;

proc summary data=nick;
by hhid cardgrp;
output out=x1 N(acct)=count;
run;

proc transpose data=x1 out=x2;
by hhid;
var count;
id cardgrp;
run;

data x3;
set x2;
where (A and (b or C or D)) or (b and (c or d)) or (c and d);
run;

proc contents data=data.contrib_201209 varnum short; run;

data data.contrib_201209;
set data.contrib_201209(in=a);
contrib = sum(DDA_CON,MMS_CON,SAV_CON,TDA_CON,IRA_CON,SEC_CON,TRS_CON,mtg_con,heq_con,card_con,ILN_CON,SLN_CON,IND_CON);
run;


data nick1;
merge data.main_201209 (in=a keep=hhid clv: tenure: card hh) nick (in=b) data.contrib_201209 (in=c keep=hhid contrib);
by hhid;
if a;
tenure=tenure_yr + clv_rem_ten;
run;

proc tabulate data=nick1 missing;
class cardgrp clv_flag card hh;
var clv_total clv_rem_ten clv_rem tenure_yr tenure contrib;
/*table clv_flag all, cardgrp, N*f=comma12. (CLV_total clv_rem)*mean*f=dollar24. (clv_rem_ten tenure_yr)*mean*f=comma12.1 / nocellmerge;*/
/*table clv_flag all, card, N*f=comma12. (CLV_total clv_rem)*mean*f=dollar24. (clv_rem_ten tenure_yr)*mean*f=comma12.1 / nocellmerge;*/
table clv_flag all, cardgrp card hh, N*f=comma12. (CLV_total clv_rem)*mean*f=dollar24. (clv_rem_ten tenure_yr tenure )*mean*f=comma12.1 contrib*mean*f=dollar18.2 / nocellmerge;
run;

proc freq data=nick1;
table clv_flag / missing;
run;


