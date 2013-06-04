filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Data\pb.txt';

data pb;
length hhid $ 9 ;
infile myfile dlm='09'x lrecl=4096 firstobs=2 dsd;
input hhid $ ;
pb = 1;
run;

proc contents data=data.main_201203 varnum short;
run;

%read_monthly_data (source=main.txt,identifier=201203,directory=C:\Documents and Settings\ewnym5s\My Documents\Data\)

;

data data.main_201203;
merge data.main_201203 (in=a) pb (in=b);
by hhid;
if a;
run;


data  data.main_201203;
set  data.main_201203;
if pb eq . and dda eq 1 and sec eq 1then teal_flag = 'DDA & SEC';
if pb eq . and dda eq 1 and sec eq 0then teal_flag = 'DDA Only';
if pb eq . and dda eq 0 and sec eq 1then teal_flag = 'SEC Only';
if pb eq 1 then teal_flag = 'PB';
run;


proc freq data=data.main_201203 order=freq;
table teal_flag / missing;
run;

filename mprint "C:\Documents and Settings\ewnym5s\My Documents\SAS\macbug.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic ;
%profile2 (classvars=teal_flag,period = 201203, data_library = data,condition = teal_flag ne '')
;

proc datasets library=work;
copy out=wip move memtype=data;
run;
quit;


data wip.temp_grps;
set wip.temp_merged;
keep hhid teal_flag;
run;

data wip.temp_stype;
merge data.checking_201203 (in=a) wip.temp_grps (in=b);
by hhid;
if a and b;
run;

proc contents data=wip.temp_stype varnum short;
run;

proc tabulate data=wip.temp_stype missing out=wip.stype1;
class teal_flag;
var RE6 RE7 RH2 RJ2 RX2 RA8 RC6 RW2 RA2 RI2 RH5 RX7 RH6 RK2 RK7 RW3 RH3 RZ2 RD2 RI1 RE5 RJ7 RG9;
table (RE6 RE7 RH2 RJ2 RX2 RA8 RC6 RW2 RA2 RI2 RH5 RX7 RH6 RK2 RK7 RW3 RH3 RZ2 RD2 RI1 RE5 RJ7 RG9)*sum N,(teal_flag ALL);
run;

proc contents data=wip.stype1 varnum short;
run;

proc tabulate data=wip.stype1 out=wip.stype2;
var RE6_Sum RE7_Sum RH2_Sum RJ2_Sum RX2_Sum RA8_Sum RC6_Sum RW2_Sum RA2_Sum RI2_Sum RH5_Sum RX7_Sum RH6_Sum 
    RK2_Sum RK7_Sum RW3_Sum RH3_Sum RZ2_Sum RD2_Sum RI1_Sum RE5_Sum RJ7_Sum RG9_Sum N;
class teal_flag;
table teal_flag,(RE6_Sum RE7_Sum RH2_Sum RJ2_Sum RX2_Sum RA8_Sum RC6_Sum RW2_Sum RA2_Sum RI2_Sum RH5_Sum RX7_Sum RH6_Sum 
    RK2_Sum RK7_Sum RW3_Sum RH3_Sum RZ2_Sum RD2_Sum RI1_Sum RE5_Sum RJ7_Sum RG9_Sum N)*sum;
run;


data wip.stype3;
length Package $ 25;
set wip.stype2;
*-------------------------;
Package = 'Power';
HH = rh6_sum_sum;
penetration = hh/N_sum;
output;
*-------------------------;
Package = 'Select';
HH = sum(rh2_sum_sum,rw2_sum_sum);
penetration = hh/N_sum;
output;
*-------------------------;
Package = 'Classic';
HH = sum(ra8_sum_sum,ra2_sum_sum);
penetration = hh/N_sum;
output;
*-------------------------;
Package = '@College';
HH = rc6_sum_sum;
penetration = hh/N_sum;
output;
*-------------------------;
Package = '@Work';
HH = rx7_sum_sum;
penetration = hh/N_sum;
output;
*-------------------------;
Package = 'My Choice';
HH = re6_sum_sum;
penetration = hh/N_sum;
output;
*-------------------------;
Package = 'My Choice Plus';
HH = rw3_sum_sum;
penetration = hh/N_sum;
output;
*-------------------------;
Package = 'My Choice Plus w/Interest';
HH = rh3_sum_sum;
penetration = hh/N_sum;
output;
*-------------------------;
Package = 'My Choice Premium';
HH = rh5_sum_sum;
penetration = hh/N_sum;
output;
*-------------------------;
Package = 'Totally Free';
HH = re5_sum_sum;
penetration = hh/N_sum;
output;
*-------------------------;
Package = 'Retail Free (New)';
HH = re7_sum_sum;
penetration = hh/N_sum;
output;
*-------------------------;
Package = 'Direct';
HH = rx2_sum_sum;
penetration = hh/N_sum;
output;
*-------------------------;
Package = 'Retail Free (New)';
HH = re7_sum_sum;
penetration = hh/N_sum;
output;
keep teal_flag package HH penetration;
run;

libname myxls oledb init_string="Provider=Microsoft.ACE.OLEDB.12.0;
Data Source=C:\Documents and Settings\ewnym5s\My Documents\deposits\PB Analysis 20120703.xls;
Extended Properties=Excel 12.0";


options orientation=landscape;
ods html close;
ods pdf file='C:\Documents and Settings\ewnym5s\My Documents\Deposits\PB HH Overview 20120703.pdf' ;
Title1 'Product Penetration (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Product Penetration") order=(0 to 1 by 0.25)  split=" " ;
axis2 split=" " value=(h=9pt f="Arial/Bold") order=('dda' 'mms' 'sav' 'tda' 'ira' 'sec' 'ins' 'mtg' 'heq' 'iln' 'ind' 'ccs' 'sln' 'sdb') color=black;
axis3 split=" " value=(h=9pt) label=none value=none;
legend1 position=(outside bottom center) mode=reserve cborder=black shape=bar(.15in,.15in) label=('Analysis Group' position=(top center));
proc gchart data=wip.bal3;
where product not in ( 'hh', 'trs');
vbar teal_flag / type=sum sumvar=penetration group=product subgroup=teal_flag
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 autoref clipref cref=graybb;
run;
quit;

Title1 'Product Balances Per Product HH (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Bal per Product HH")   split=" " ;
axis2 split=" " value=(h=9pt f="Arial/Bold") order=('dda' 'mms' 'sav' 'tda' 'ira' 'sec' 'ins'  'mtg' 'heq' 'iln' 'ind' 'ccs' 'sln' 'sdb') color=black;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.bal3;
where product not in ( 'hh', 'trs');
vbar teal_flag / type=sum sumvar=bal_prod_hh group=product subgroup=teal_flag
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 autoref clipref cref=graybb;
run;

Title1 'Product Balances Per Total HH (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Bal per Total HH")   split=" " ;
axis2 split=" " value=(h=9pt f="Arial/Bold") order=('dda' 'mms' 'sav' 'tda' 'ira' 'sec' 'ins'  'mtg' 'heq' 'iln' 'ind' 'ccs' 'sln' 'sdb') color=black;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.bal3;
where product not in ( 'hh', 'trs');
vbar teal_flag / type=sum sumvar=bal_tot_hh group=product subgroup=teal_flag
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 autoref clipref cref=graybb;
run;

Title1 'Product Contribution Per Product HH (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Contribution per Product HH")   split=" " ;
axis2 split=" " value=(h=9pt f="Arial/Bold") order=('dda' 'mms' 'sav' 'tda' 'ira' 'sec' 'ins'  'mtg' 'heq' 'iln' 'ind' 'ccs' 'sln' 'sdb') color=black;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.bal3;
where product not in ( 'hh', 'trs');
vbar teal_flag / type=sum sumvar=con_prod_hh group=product subgroup=teal_flag
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 autoref clipref cref=graybb;
run;

Title1 'Product Contribution Per Total HH (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Contribution per Total HH")   split=" " ;
axis2 split=" " value=(h=9pt f="Arial/Bold") order=('dda' 'mms' 'sav' 'tda' 'ira' 'sec' 'ins'  'mtg' 'heq' 'iln' 'ind' 'ccs' 'sln' 'sdb') color=black;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.bal3;
where product not in ( 'hh', 'trs');
vbar teal_flag / type=sum sumvar=con_tot_hh group=product subgroup=teal_flag
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 autoref clipref cref=graybb;
run;

data myxls.product;
   set wip.bal3;
run;

Title1 'Segment Distribution (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Percent of HHs")  split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.segment_results;
where segment not in (. 7) ;
vbar teal_flag / type=percent freq=hh_sum group=teal_flag subgroup=segment   inside=SUBPCT g100
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
run;

data myxls.segment;
   set wip.segment_results;
run;

Title1 'Profit Band Distribution (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Percent of HHs")  split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.band_results;
where band not in ('') ;
vbar teal_flag / type=percent freq=hh_sum group=teal_flag subgroup=band   inside=SUBPCT g100
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
run;

data myxls.segment;
   set wip.band_results;
run;

proc sql noprint;
create table wip.a as 
   select teal_flag, sum(hh_sum) as hh from wip.cbr_results group by teal_flag;
quit;

proc sql noprint;
select teal_flag, hh  into :grp1 - :grp5, :cnt1 - :cnt5 from wip.a;
quit;

data wip.b;
set wip.cbr_results;
if teal_flag eq "&grp1" then percent1 = hh_sum / &cnt1;
if teal_flag eq "&grp2" then percent1 = hh_sum / &cnt2;
if teal_flag eq "&grp3" then percent1 = hh_sum / &cnt3;
if teal_flag eq "&grp4" then percent1 = hh_sum / &cnt4;
if teal_flag eq "&grp5" then percent1 = hh_sum / &cnt5;
if cbr eq . then cbr = 99;
run;

proc sort data=wip.b;
by teal_flag;
run;

Title1 'CBR Distribution (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Percent of HHs") order=(0 to .5 by 0.1) split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.b;
where   teal_flag ne '';
vbar teal_flag / type=sum sumvar=percent1 group=cbr subgroup=teal_flag   
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
format percent1 percent8.1;
run;

data myxls.cbr;
   set wip.b;
run;

proc sql noprint;
create table wip.a as 
   select teal_flag, sum(hh_sum) as hh from wip.market_results group by teal_flag;
quit;

proc sql noprint;
select teal_flag, hh  into :grp1 - :grp5, :cnt1 - :cnt5 from wip.a;
quit;

data wip.b;
set wip.market_results;
if teal_flag eq "&grp1" then percent1 = hh_sum / &cnt1;
if teal_flag eq "&grp2" then percent1 = hh_sum / &cnt2;
if teal_flag eq "&grp3" then percent1 = hh_sum / &cnt3;
if teal_flag eq "&grp4" then percent1 = hh_sum / &cnt4;
if teal_flag eq "&grp5" then percent1 = hh_sum / &cnt5;
if market eq . then market = 99;
run;

proc sort data=wip.b;
by teal_flag;
run;

Title1 'Market Distribution (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Percent of HHs") order=(0 to .5 by 0.1) split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.b;
where   teal_flag ne '';
vbar teal_flag / type=sum sumvar=percent1 group=market subgroup=teal_flag   
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
format percent1 percent8.1;
run;

data myxls.mkt;
   set wip.b;
run;

Title1 'Tenure (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Percent of HHs")  split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.tenure_yr_results;
where tenure_yr gt 0 and teal_flag ne '';
vbar tenure_yr / type=percent freq=hh_sum group=tenure_yr subgroup=teal_flag   inside=SUBPCT g100
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
run;

data myxls.tenure;
   set wip.tenure_yr_results;
run;

Title1 'Transaction Enrollment CHK HHs (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Percent of HHs") order=(0 to 1 by 0.25) split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.tran3;
vbar teal_flag / type=sum sumvar=enrolled_pct group=transaction subgroup=teal_flag  outside=sum
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
format enrolled_pct percent8.1;
run;

Title1 'Transaction Activation CHK HHs (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Percent of HHs") order=(0 to 1 by 0.25) split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.tran3;
vbar teal_flag / type=sum sumvar=active_pct group=transaction subgroup=teal_flag  outside=sum
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
format active_pct percent8.1;
run;

Title1 'Avg. Transaction Volume CHK HHs (Active HH) (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Transactions")  split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.tran3;
vbar teal_flag / type=sum sumvar=volume_avg group=transaction subgroup=teal_flag  outside=sum
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
format volume_avg COMMA8.1;
run;

Title1 'Avg. Transaction Amount CHK HHs (Active HH) (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Total Amount")  split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.tran3;
vbar teal_flag / type=sum sumvar=spend_avg group=transaction subgroup=teal_flag  outside=sum
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
format spend_avg dollar10.;
run;

data myxls.transactions;
   set wip.tran3;
run;

Title1 'Transaction Enrollment Web HHs (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Percent of HHs") order=(0 to 1 by 0.25) split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.web3;
vbar teal_flag / type=sum sumvar=enrolled_pct group=service subgroup=teal_flag  outside=sum
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
format enrolled_pct percent8.1 ;
run;

Title1 'Transaction Activation Web HHs (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Percent of HHs") order=(0 to 1 by 0.25) split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.web3;
vbar teal_flag / type=sum sumvar=active_pct group=service subgroup=teal_flag  outside=sum
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
format active_pct percent8.1 ;
run;

Title1 'Avg. Transaction Volume Web HHs (Active HH) (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Transactions")  split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.web3;
vbar teal_flag / type=sum sumvar=volume_avg group=service subgroup=teal_flag  outside=sum
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
format volume_avg COMMA8.1 ;
run;

Title1 'Avg. Transaction Amount Web HHs (Active HH) (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Total Amount")  split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
proc gchart data=wip.web4;
vbar teal_flag / type=sum sumvar=spend_avg group=service subgroup=teal_flag  outside=sum
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
format spend_avg dollar10. ;
run;

data myxls.web_svcs;
   set wip.web3;
run;

Title1 'Checking Packege Penetration (Checking HH) (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Total Amount")  split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") split=" ";
axis3 split=" " value=(h=9pt) label=none value=none split=" ";
proc gchart data=wip.stype3;
vbar teal_flag / type=sum sumvar=penetration group=package subgroup=teal_flag  outside=sum
     raxis = axis1 maxis=axis3 gaxis=axis2 legend=legend1 nozeros noframe;
format penetration percent8.1;
run;

data myxls.chk_pkg;
   set wip.stype3;
run;

Title1 'Total Lifetime Value (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Average Amount")  label=none value=none split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt f="Arial/Bold");
proc gchart data=wip.clv2;
where   teal_flag ne 'All';
vbar teal_flag / type=sum sumvar=clv_total_mean  subgroup=teal_flag 
     raxis = axis1 maxis=axis3  nozeros noframe outside=sum nolegend;
format clv_total_mean dollar12.;
run;

Title1 'Remaining Lifetime Value (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Average Amount")  label=none value=none split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt f="Arial/Bold");
proc gchart data=wip.clv2;
where   teal_flag ne 'All';
vbar teal_flag / type=sum sumvar=clv_rem_mean  subgroup=teal_flag 
     raxis = axis1 maxis=axis3  nozeros noframe outside=sum nolegend;
format clv_rem_mean dollar12.;
run;

Title1 'Remaining Tenure (Mar 2012)';
axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Average Years")  label=none value=none split=" "  ;
axis2 split=" " value=(h=9pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt f="Arial/Bold");
proc gchart data=wip.clv2;
where   teal_flag ne 'All';
vbar teal_flag / type=sum sumvar=clv_rem_ten_mean  subgroup=teal_flag 
     raxis = axis1 maxis=axis3  nozeros noframe outside=sum nolegend;
format clv_rem_ten_mean comma8.1;
run;

data wip.clv5;
set wip.clv4;
where teal_flag ne 'All' and clv_total ne .;
run;




axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Percent of HHs") order=(0 to 100 by 25) split=" "  offset=(5,5)pct;
axis2 split=" " value=(h=8pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
Title1 'Total Lifetime Value';

proc gchart data=wip.clv7;
where clv_band ne '';
vbar teal_flag / type=sum sumvar=hh_pctsum_01 group=clv_band nozeros subgroup=teal_flag  outside=sum
       raxis = axis1 maxis=axis3 gaxis=axis2  legend=legend1;

run;

axis1 minor=none color=black label=(a = 90 f="Arial/Bold" "Percent of HHs") order=(0 to 100 by 25) split=" "  offset=(5,5)pct;
axis2 split=" " value=(h=8pt f="Arial/Bold") ;
axis3 split=" " value=(h=9pt) label=none value=none;
Title1 'Total Lifetime Value';

proc gchart data=wip.clv7;
vbar clv_BAND / type=percent inside=SUBPCT freq=HH_SUM group=clv_BAND  subgroup=TEAL_FLAG  
       raxis = axis1 maxis=axis3 gaxis=axis2 nozeros legend=legend1 g100;

run;



libname myxls clear;
ods pdf close;
ods html;

quit;





data wip.clv6;
length clv_band $ 25;
set wip.temp_clv;
   select ;
   		when (clv_total lt 0)  clv_band = 'A - Below Zero';
		when (clv_total eq 0) clv_band = 'B - Zero';
		when (clv_total gt 0 and clv_total lt 250) clv_band = 'C - Up to $250';
		when (clv_total ge 250 and clv_total lt 500) clv_band = 'D - $250 to $500';
		when (clv_total ge 500 and clv_total lt 750) clv_band = 'E - $500 to $750';
		when (clv_total ge 750 and clv_total lt 1000) clv_band = 'F - $750 to $1,000';
		when (clv_total ge 1000 and clv_total  lt 1500) clv_band = 'G - $1,000 to $1,500';
		when (clv_total ge 1500 and clv_total  lt 2500) clv_band = 'H - $1,500 to $2,500';
		when (clv_total ge 2500 and clv_total  lt 5000) clv_band = 'I - $2,500 to $5,000';
		when (clv_total ge 5000) clv_band= 'J - $5,000+';
	end;
run;


proc tabulate data=wip.clv6 out=wip.clv7 ;
where clv_total ne .;
class clv_band teal_flag;
var  HH clv_total;
table teal_flag ,(clv_band  ALL)*(hh)*(sum rowpctsum<hh>) ;
run;

order=('Below Zero'  'Zero'  'Up to $250'  '$250 to 500'  '$500 to 750'  '$750 to 1 000'  '$1,000 to 1,500'  
                                                     '$1,500 to 2,500'  '$2,500 to 5,000') 
