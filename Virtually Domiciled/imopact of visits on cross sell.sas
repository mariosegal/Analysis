/*data data.main_201203 ;*/
/*merge data.main_201203 (in=a ) virtual.points_201204 (in=b keep=hhid segment rename=(segment=tran_segment) );*/
/*by hhid;*/
/*if a;*/
/*run;*/

/*data data.main_201203;*/
/*set data.main_201203;*/
/*svcs = sum(dda, mms, sav, tda, ira, mtg, card, heq, iln, ind, sec, trs, ins, sdb, cqi_deb, web);*/
/*if br_tr_num eq . then br_tr_num = 0;*/
/*run;*/

data temp;
set data.main_201203;
where dda eq 1 and br_tr_num le 100;
keep svcs br_tr_num dda rm;
run;

proc sort data=temp;
by rm;
run;

proc corr data=temp plot=matrix(histogram);
by RM;
run;

proc gplot data=temp ;
by RM;
plot svcs*br_tr_num;
run;
