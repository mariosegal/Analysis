*Extract Data and create train and extra datasets;
libname clv 'C:\Documents and Settings\ewnym5s\My Documents\Lifetime Value';

data clv;
set data.main_201212;
keep hhid dda: mms: tda: ira: sav: mtg: sec: iln: ind: heq: card: ccs: ixi: tenure: segment: distance vpos: mpos: atmt: atmo: bus clv:;
run;


data extra;
length hhid $ 9 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\clv.txt' dsd dlm='09'x lrecl=4096 missover firstobs=1 obs=max;
input hhid $ clv_flag $ steady_flag dob_yr ;
age = 2013-dob_yr;
run;

options compress =yes;
data clv.main;
merge clv(in=a) extra(drop=dob_yr in=b) end=eof;
retain miss miss1;
by hhid;
if a;
if a and not b then miss+1;
if not a and b then miss1+1;
if eof then do;
	put 'WARNING: There were ' miss ' records in A with no match in B';
	put 'WARNING: There were ' miss1 ' records in B with no match in A';
end;
drop miss:;
run;

data clv.main;
set clv.main;
if clv_flag ne 'Y' then do;
	clv_total = .;
	clv_rem = .;
	clv_rem_ten = .;
end;
run;

data clv.main ;
set clv.main ;
hh =1 ;
if segment eq . then segment = 7;
if age eq . or age le 0 then delete;
products = sum(dda,mms,sav,tda,mtg,heq,iln,card);
run;

%Auto_Dummy_Variable(tablename=clv.main,variablename=segment,outputtable=segments,MissingDummy=Y,MaxLevel=10,delimiter=)
;

proc sort data=clv.main;
by hhid segment;
run;

/*proc summary data=clv.main;*/
/*by hhid segment;*/
/*output out=segments sum(hh)=count;*/
/*run;*/

proc format library=sas;
value agefmt (notsorted) 
      . = 'Unknown'
      0 - 17 = 'Up to 17'
	  18 - 25 = '18 to 25'
	  26 - 35 = '26 to 35'
	  36 - 45 = '36 to 45'
	  46 - 55 = '46 to 55'
	  56 - 65 = '56 to 65'
	  66 - 75 = '66 to 75'
	  76 - 85 = '76 to 85'
	  86 - high = '86+'
	  other = 'check';
run;





proc freq data=clv.main;
table age;
format age agefmt.;
run;

proc freq data=clv.main;
where age lt 0;
table age;
format age agefmt.;
run;

proc transpose data=clv.main (obs=max keep=hhid segment hh) out=segments;
by hhid;
id segment;
var hh;
format segment segfmt.;
run;

proc transpose data=clv.main (obs=max keep=hhid age hh) out=age prefix=age_;
by hhid;
id age;
var hh;
format age agefmt.;
run;

data clv.main;
merge clv.main(in=a) segments(drop=_name_ in=b) age(drop=_name_ in=c) end=eof;
retain miss miss1 miss2 miss3;
by hhid;
if a;
deposits = max(dda,mms,sav,tda,ira);
loans = max(ind,iln,card,mtg,heq);
secure = max(mtg,heq);
both = max(deposits,loans);
dep_amt = sum(dda_amt,mms_amt,sav_amt,tda_amt,ira_amt);
loan_amt = max(ind_amt,iln_amt,ccs_amt,mtg_amt,heq_amt);
both_amt = sum(dep_amt, loan_amt);
atm_amt = sum(atmt_amt,atmo_amt);
atm_num = sum(atmt_num,atmo_num);
deb_amt = sum(vpos_amt,mpos_amt);
deb_num = sum(vpos_num,mpos_num);
if a and not b then miss+1;
if a and not c then miss1+1;
if not a and b then miss2+1;
if not a and c then miss3+1;
if eof then do;
	put 'WARNING: There were ' miss ' records in A with no match in B';
	put 'WARNING: There were ' miss1 ' records in A with no match in C';
	put 'WARNING: There were ' miss2 ' records in B with no match in A';
	put 'WARNING: There were ' miss3 ' records in C with no match in A';
end;
drop miss:;
run;

proc contents data=clv.main varnum short;
run;

proc means data=clv.main;
var ixi: clv_total clv_rem:;
run;

%null_to_zero(source=clv.main, destination=clv.main, 
variables=Mass_Affluent_Families Building_Their_Future Mainstream_Families Mainstream_Retired Mass_Affluent_no_Kids 
Mass_Affluent_Retired Not_Coded age_36_to_45 age_18_to_25 age_46_to_55 age_56_to_65 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35)
;



*I want to have 3 groups, non overlapping. and Surveyselect does not do that easy, so I will just do it in data steps;
data steady non;
set clv.main ;
where clv_flag='Y';
if clv_steady eq 1 then output steady;
if clv_steady eq 0 then output non;
run;

proc means data=steady qrange q3 q1 mean median max min p1 p5 p90 p95 p99 maxdec=0;
var clv_total;
run;
*99th pctile is at a 19,762 and 1pctile is at -52. I will then make exclude people with clv_total in the -20,000 to +20,000 range;

proc rank data=steady out=steady_ranked groups=10;
where clv_total ge -20000 and clv_total le 20000 ;
var clv_total;
ranks clv_rank;
run;

proc means data=non qrange q3 q1 mean median max min p1 p5 p90 p95 p99 maxdec=0;
var clv_total;
run;

proc rank data=non out=non_ranked groups=10;
where clv_total ge -20000 and clv_total le 20000 ;
var clv_total;
ranks clv_rank;
run;


data clv.train_steady clv.test_steady clv.validate_steady;
set steady_ranked;
/*if clv_total lt -20000 or clv_total gt 20000 then delete;*/
rand = ranuni(4874248);
if rand le (1/3) then output clv.train_steady;
else if rand le (2/3) then output clv.test_steady;
else output clv.validate_steady;
drop atmT: ATMO: vpos: mpos: segment clv_flag clv_steady steady_flag tenure hh rand;
run;

proc means data=clv.train_steady qrange q3 q1 mean median max min p1 p5 p90 p95 p99 maxdec=0;
var clv_total;
run;

data clv.train_non clv.test_non clv.validate_non;
set non_ranked;
/*if clv_total lt -20000 or clv_total gt 20000 then delete;*/
rand = ranuni(54682359);
if rand le (1/3) then do;
    output clv.train_non;
end;
else if rand le (2/3) then output clv.test_non;
else output clv.validate_non;
drop atmT: ATMO: vpos: ATMO: segment clv_flag clv_steady steady_flag tenure hh rand;
run;

data clv.train_steady;
set clv.train_steady;
row = _N_;
run;

data clv.train_steady_small;
set clv.train_steady;
if ranuni(688767) lt 0.1 then output;
run;
*this was for R;

*######################################################################################;
*#############             EXPLORATORY ANALYSIS                           #############;
*######################################################################################;
proc corr data=clv.train_steady plots(MAXPOINTS=NONE )=scatter(nvar=ALL);
   var DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt 
            products;
   with clv_total;
run;


proc corr data=clv.train_steady outp=clv.corr_out;
   var dda mms sav tda ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt 
             iln_amt IXI_tot IXi_Annuity ixi_Bonds ixi_Funds ixi_Stocks ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS 
             ixi_tda IND IND_AMT distance tenure_yr age Mass_Affluent_Families Building_Their_Future Mainstream_Families 
             Mainstream_Retired Mass_Affluent_no_Kids Mass_Affluent_Retired Not_Coded age_36_to_45 age_18_to_25 age_46_to_55 
             age_56_to_65 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 deposits loans secure both dep_amt loan_amt  
             both_amt atm_amt atm_num deb_amt deb_num products;
   with clv_total;
run;

proc transpose data=clv.corr_out out=clv.corr_out1;
run;

proc sort data=clv.corr_out1;
by clv_total;
run;


*none seem super predictive, let's try stepwise;

proc reg data=clv.train_steady plots(maxpoints=none)=all;
model clv_total = dda mms sav tda ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt 
             iln_amt IXI_tot IXi_Annuity ixi_Bonds ixi_Funds ixi_Stocks ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS 
             ixi_tda IND IND_AMT distance tenure_yr age Mass_Affluent_Families Building_Their_Future Mainstream_Families 
             Mainstream_Retired Mass_Affluent_no_Kids Mass_Affluent_Retired Not_Coded age_36_to_45 age_18_to_25 age_46_to_55 
             age_56_to_65 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 deposits loans secure both dep_amt loan_amt  
             both_amt atm_amt atm_num deb_amt deb_num products / selection=stepwise;
run;

quit;



*I will try the final model only to get more details;
proc reg data=clv.train_steady plots(maxpoints=none)=all;
model clv_total = dda mms ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
                  IXi_Annuity ixi_Funds ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda IND IND_AMT distance tenure_yr age 
                  Mass_Affluent_Families Building_Their_Future Mass_Affluent_no_Kids Mass_Affluent_Retired age_36_to_45 age_18_to_25 
                  age_46_to_55 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 deposits secure both_amt atm_amt atm_num deb_amt 
                  deb_num products / vif collin collinoint  ;
output out=check r=Residual p=pred rstudent=rstudent h=leverage;
run;
quit;

*take out both amt;
proc reg data=clv.train_steady plots(maxpoints=none)=all;
model clv_total = dda mms ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
                  IXi_Annuity ixi_Funds ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda IND IND_AMT distance tenure_yr age 
                  Mass_Affluent_Families Building_Their_Future Mass_Affluent_no_Kids Mass_Affluent_Retired age_36_to_45 age_18_to_25 
                  age_46_to_55 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 deposits secure  atm_amt atm_num deb_amt 
                  deb_num products / vif collin collinoint  ;
output out=check r=Residual p=pred rstudent=rstudent h=leverage;
run;
quit;



*take out age;
proc reg data=clv.train_steady plots(maxpoints=none)=all;
model clv_total = dda mms ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
                  IXi_Annuity ixi_Funds ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda IND IND_AMT distance tenure_yr  
                  Mass_Affluent_Families Building_Their_Future Mass_Affluent_no_Kids Mass_Affluent_Retired age_36_to_45 age_18_to_25 
                  age_46_to_55 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 deposits secure  atm_amt atm_num deb_amt 
                  deb_num products / vif collin collinoint  ;
output out=check r=Residual p=pred rstudent=rstudent h=leverage;
run;
quit;

*take out secure;
proc reg data=clv.train_steady plots(maxpoints=none)=all outest=clv.model1;
model clv_total = dda mms ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
                  IXi_Annuity ixi_Funds ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda IND IND_AMT distance tenure_yr  
                  Mass_Affluent_Families Building_Their_Future Mass_Affluent_no_Kids Mass_Affluent_Retired age_36_to_45 age_18_to_25 
                  age_46_to_55 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 deposits  atm_amt atm_num deb_amt 
                  deb_num products / vif collin collinoint  ;
code file='C:\Documents and Settings\ewnym5s\My Documents\Lifetime Value\model1.sas';
/*output out=check r=Residual p=pred rstudent=rstudent h=leverage;*/
run;
quit;

data check;
set check;
abserror=abs(residual);
run;

proc corr data=check spearman nosimple;
var abserror pred;
run;


proc sgplot data=check (keep=pred rstudent);
scatter x=pred y=rstudent ;
yaxis min=-10 max=10;
xaxis min=-5000 max=5000;
run;
quit;

*###########################################################################;
*normalize variables and then try again full model;
proc contents data=clv.train_steady varnum short;
run;

proc stdize data=clv.train_steady out=clv.train_steady_std method=std outstat=clv.train_steady_scale ;
var DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
    IXI_tot IXi_Annuity ixi_Bonds ixi_Funds ixi_Stocks ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda 
    clv_total clv_rem clv_rem_ten IND_AMT distance tenure_yr dep_amt loan_amt both_amt atm_amt atm_num deb_amt deb_num products;
run;



proc reg data=clv.train_steady_std plots(maxpoints=none)=all;
model clv_total = dda mms sav tda ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt 
             iln_amt IXI_tot IXi_Annuity ixi_Bonds ixi_Funds ixi_Stocks ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS 
             ixi_tda IND IND_AMT distance tenure_yr age Mass_Affluent_Families Building_Their_Future Mainstream_Families 
             Mainstream_Retired Mass_Affluent_no_Kids Mass_Affluent_Retired Not_Coded age_36_to_45 age_18_to_25 age_46_to_55 
             age_56_to_65 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 deposits loans secure both dep_amt loan_amt  
             both_amt atm_amt atm_num deb_amt deb_num products / selection=stepwise;
run;
quit;

*run final model;
proc reg data=clv.train_steady_std plots(maxpoints=none)=all;
model clv_total = dda mms ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
                  IXi_Annuity ixi_Funds ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda IND IND_AMT distance 
                  tenure_yr age Mass_Affluent_Families Building_Their_Future Mass_Affluent_no_Kids Mass_Affluent_Retired 
                  age_36_to_45 age_18_to_25 age_46_to_55 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 
                  deposits secure dep_amt both_amt atm_amt atm_num deb_amt deb_num products / vif collin collinoint  ;
output out=check r=Residual p=pred rstudent=rstudent h=leverage;
run;
quit;

*take out both_amt;
proc reg data=clv.train_steady_std plots(maxpoints=none)=all;
model clv_total = dda mms ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
                  IXi_Annuity ixi_Funds ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda IND IND_AMT distance 
                  tenure_yr age Mass_Affluent_Families Building_Their_Future Mass_Affluent_no_Kids Mass_Affluent_Retired 
                  age_36_to_45 age_18_to_25 age_46_to_55 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 
                  deposits secure dep_amt atm_amt atm_num deb_amt deb_num products / vif collin collinoint  ;
output out=check r=Residual p=pred rstudent=rstudent h=leverage;
run;
quit;


*take out dep_amt;
proc reg data=clv.train_steady_std plots(maxpoints=none)=all;
model clv_total = dda mms ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
                  IXi_Annuity ixi_Funds ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda IND IND_AMT distance 
                  tenure_yr age Mass_Affluent_Families Building_Their_Future Mass_Affluent_no_Kids Mass_Affluent_Retired 
                  age_36_to_45 age_18_to_25 age_46_to_55 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 
                  deposits secure  atm_amt atm_num deb_amt deb_num products / vif collin collinoint  ;
output out=check r=Residual p=pred rstudent=rstudent h=leverage;
run;
quit;

*take out age;
proc reg data=clv.train_steady_std plots(maxpoints=none)=all;
model clv_total = dda mms ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
                  IXi_Annuity ixi_Funds ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda IND IND_AMT distance 
                  tenure_yr  Mass_Affluent_Families Building_Their_Future Mass_Affluent_no_Kids Mass_Affluent_Retired 
                  age_36_to_45 age_18_to_25 age_46_to_55 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 
                  deposits secure  atm_amt atm_num deb_amt deb_num products / vif collin collinoint  ;
output out=check r=Residual p=pred rstudent=rstudent h=leverage;
run;
quit;

*take out secure;
proc reg data=clv.train_steady_std plots(maxpoints=none)=all outest=clv.model2;
model clv_total = dda mms ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
                  IXi_Annuity ixi_Funds ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda IND IND_AMT distance 
                  tenure_yr  Mass_Affluent_Families Building_Their_Future Mass_Affluent_no_Kids Mass_Affluent_Retired 
                  age_36_to_45 age_18_to_25 age_46_to_55 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 
                  deposits   atm_amt atm_num deb_amt deb_num products / vif collin collinoint  ;
/*output out=check r=Residual p=pred rstudent=rstudent h=leverage;*/
code file='C:\Documents and Settings\ewnym5s\My Documents\Lifetime Value\model2.sas';
run;
quit;
*###########################################################################;
*Danny suggested I do not do box cox;
proc transreg data=clv.train_steady ss2 test cl nomiss plots=boxcox (rmse unpack);
model boxcox(clv_total / lambda=2) = identity(dda mms ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
                  IXi_Annuity ixi_Funds ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda IND IND_AMT distance tenure_yr  
                  Mass_Affluent_Families Building_Their_Future Mass_Affluent_no_Kids Mass_Affluent_Retired age_36_to_45 age_18_to_25 
                  age_46_to_55 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 deposits  atm_amt atm_num deb_amt 
                  deb_num products);
output out=check r p ;
run;
quit;



proc corr data=clv.train_steady plots=matrix;
   var  dda mms sav tda ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt 
             iln_amt IXI_tot IXi_Annuity ixi_Bonds ixi_Funds ixi_Stocks ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS 
             ixi_tda IND IND_AMT distance tenure_yr age Mass_Affluent_Families Building_Their_Future Mainstream_Families 
             Mainstream_Retired Mass_Affluent_no_Kids Mass_Affluent_Retired Not_Coded age_36_to_45 age_18_to_25 age_46_to_55 
             age_56_to_65 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 deposits loans secure both dep_amt loan_amt  
             both_amt atm_amt atm_num deb_amt deb_num products;
   with clv_total;
run;






proc contents data=clv.train_steady varnum short ;
run;

data temp;
set clv.train_steady;
if mod(_n_,20) ne 13 then delete;
run;

proc transpose data=temp out=chartdata;
copy clv_total;
by hhid;
run;

data clv_total;
set temp;
keep hhid clv_total;
run;

data chartdata1 ;
merge chartdata(in=a drop=clv_total) clv_total(in=b);
by hhid;
if a;
label _name_ = "Variable";
run;

proc freq data=chartdata1;
table _name_;
run;



proc sgpanel data=chartdata1 (where =(_name_ not in ('clv_rem' ,'clv_rem_ten')));
panelby _name_ / columns=8 onepanel;
scatter x=col1 y=clv_total / markerattrs=(symbol=CircleFilled color=CXC0C0C0 size=4pt);
loess x=col1 y=clv_total / lineattrs=(color="red" thickness=2);
reg x=col1 y=clv_total / lineattrs=(color="green"  thickness=2);
run;




proc sgscatter data=clv.train_steady ;
  title "Correlations versus Total CLV";
  compare x=(dda mms sav tda ira sec mtg heq card )
          y=(clv_total) / loess=(lineattrs=(color="red")) reg==(lineattrs=(color="blue")) spacing=3;
run;
title;

proc sgscatter data=clv.train_steady ;
  title "Correlations versus Total CLV";
  compare x=(dda mms sav tda ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt 
             iln_amt IXI_tot IXi_Annuity ixi_Bonds ixi_Funds ixi_Stocks ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS 
             ixi_tda IND IND_AMT distance tenure_yr age Mass_Affluent_Families Building_Their_Future Mainstream_Families 
             Mainstream_Retired Mass_Affluent_no_Kids Mass_Affluent_Retired Not_Coded age_36_to_45 age_18_to_25 age_46_to_55 
             age_56_to_65 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 deposits loans secure both dep_amt loan_amt  
             both_amt atm_amt atm_num deb_amt deb_num)
          y=(clv_total) / loess;
run;
title;

*TEST ON VALIDATION model 1;

data valid_1;
   set clv.validate_steady;
   %include 'C:\Documents and Settings\ewnym5s\My Documents\Lifetime Value\model1.sas';
run;

PROC Score data=clv.validate_steady score=clv.model1 predict type=parms;
var dda mms ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
                  IXi_Annuity ixi_Funds ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda IND IND_AMT distance tenure_yr  
                  Mass_Affluent_Families Building_Their_Future Mass_Affluent_no_Kids Mass_Affluent_Retired age_36_to_45 age_18_to_25 
                  age_46_to_55 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 deposits  atm_amt atm_num deb_amt 
                  deb_num products;
run;

*I can't believe that I have to do this by hand;
proc sql;
select avg(clv_total) into :avg1 from clv.train_steady;
quit;


data data3;
set data3;
error=clv_total-model1;
error2 = error**2;
total= clv_total-&avg1 ;
total2 = total**2;
run;


proc sql;
select sum(error2) as sserror format=comma18.1, sum(total2) as sstotal format=comma18.1, 1- calculated sserror/calculated sstotal as R2  from data3;
quit;

*TEST ON VALIDATION model 2 stdize;
proc stdize data=clv.Validate_steady method=IN(clv.Train_steady_scale) out=clv.validate_steady_std;
var DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
    IXI_tot IXi_Annuity ixi_Bonds ixi_Funds ixi_Stocks ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda 
    clv_total clv_rem clv_rem_ten IND_AMT distance tenure_yr dep_amt loan_amt both_amt atm_amt atm_num deb_amt deb_num products;
run;

PROC Score data=clv.validate_steady_std score=clv.model2 predict type=parms out=valid2;
var dda mms ira sec mtg heq card ILN bus DDA_Amt MMS_amt sav_amt TDA_Amt sec_Amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
                  IXi_Annuity ixi_Funds ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings ixi_MMS ixi_tda IND IND_AMT distance 
                  tenure_yr  Mass_Affluent_Families Building_Their_Future Mass_Affluent_no_Kids Mass_Affluent_Retired 
                  age_36_to_45 age_18_to_25 age_46_to_55 age_Up_to_17 age_86_ age_76_to_85 age_66_to_75 age_26_to_35 
                  deposits   atm_amt atm_num deb_amt deb_num products;
run;

/*proc sql;*/
/*select avg(clv_total) into :avg1 from clv.train_steady;*/
/*quit;*/


data valid2;
set valid2;
error=clv_total-model1;
error2 = error**2;
total= clv_total-0 ;*because it is scaled and then mean  has to be zero by definition;
total2 = total**2;
run;


proc sql;
select sum(error2) as sserror format=comma18.1, sum(total2) as sstotal format=comma18.1, 1- calculated sserror/calculated sstotal as R2  from valid2;
quit;
