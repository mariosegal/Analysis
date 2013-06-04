proc print data=data.main_201112;
where ZIP in ('14202');
var dda_amt sav_amt tda_amt ira_amt sav_amt sec_amt adj_wallet ixi:;
run;

data zip14202;
set data.main_201112;
where ZIP in ('14202');
keep dda mms sav tda ira sec hhid zip hh dda_amt sav_amt tda_amt ira_amt mms_amt sec_amt adj_wallet ixi: internal deposits assets ;
format  dda_amt sav_amt tda_amt ira_amt mms_amt sec_amt adj_wallet ixi: internal dollar24.;
internal = sum(dda_amt,sav_amt, tda_amt, ira_amt ,mms_amt, sec_amt);
deposits = min(1,sum(dda,mms,sav,tda,ira));
assets = min(1,sum(deposits,sec));
run;

data a;
set zip14202;
where ixi_tot eq 10000000;
run;

proc sort data=branch16;
by descending adj_wallet;
run;




proc tabulate data=branch16;
var internal ixi_tot adj_wallet sec_amt deposits;
class zip;
table  zip, N (internal ixi_tot adj_wallet sec_amt)*sum*f=dollar24. deposits*sum*f=comma12.;
run;


proc tabulate data=branch16;
var internal ixi_tot adj_wallet sec_amt ;
class zip assets deposits;
table  deposits*zip, N (internal ixi_tot adj_wallet sec_amt)*sum*f=dollar24. ;
run;


data a;
set ixi_data;
where regionzipcode in ('14202','14204');
run;

data b;
set ixi_new.wt_postal;
where regionzipcode in ('14202','14204');
run;
