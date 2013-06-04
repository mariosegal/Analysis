libname virtual 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled';
libname Data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname wip 'C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files';

options MSTORED SASMSTORE = mjstore;
libname mjstore 'C:\Documents and Settings\ewnym5s\My Documents\SAS\Macros';

libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
options fmtsearch=(SAS);

/**/
/*proc freq data=data.main_201111;*/
/*table virtual_seg*seg_new / nocol norow nopercent missing;*/
/*run;*/


data inactives;
set data.main_201111;
where virtual_seg ne 'Inac' and seg_new eq 'Inactive';
run;

Proc tabulate data=inactives out=prod1;
class virtual_seg segment;
var dda mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins hh DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt IND_AMT sln_amt ;
table  segment, hh*sum*f=comma12. (sum*f=comma12.0)*(dda mms sav tda ira sec trs ins mtg heq card ILN ind sln sdb) 
(pctsum<hh>*f=PCTPIC.)*(dda mms sav tda ira sec trs ins mtg heq card ILN ind sln sdb )  
(DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt )*sum*f=dollar12. 
(DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt )*mean*f=dollar12.;
keylabel PCTSUM = 'PCT';
format segment segfmt.;
run;


proc format libname=sas fmtlib;
run;


data prod2;
set prod1;
	dda_amt_avg = divide(dda_amt_sum , dda_sum);
	mms_amt_avg = divide(mms_amt_sum , mms_sum);
	sav_amt_avg = divide(sav_amt_sum , sav_sum);
	tda_amt_avg = divide(tda_amt_sum , tda_sum);
	ira_amt_avg = divide(ira_amt_sum , ira_sum);
	sec_amt_avg = divide(sec_amt_sum , sec_sum);
	trs_amt_avg = divide(trs_amt_sum , trs_sum);
	mtg_amt_avg = divide(mtg_amt_sum , mtg_sum);
	heq_amt_avg = divide(heq_amt_sum , heq_sum);
	iln_amt_avg = divide(iln_amt_sum , iln_sum);
	ind_amt_avg = divide(ind_amt_sum , ind_sum);
	sln_amt_avg = divide(sln_amt_sum , sln_sum);
	ccs_amt_avg = divide(ccs_amt_sum , card_sum);

	if _type_ eq '00' then do;
		virtual_seg = 'Total';
		segment = 99;
		dda_PctSum_11 = dda_pctsum_00;
		mms_PctSum_11 = mms_PctSum_00;
		sav_PctSum_11 = sav_PctSum_00;
		tda_PctSum_11 = tda_PctSum_00;
		ira_PctSum_11 = ira_PctSum_00;
		sec_PctSum_11 = sec_PctSum_00;
		trs_PctSum_11 = trs_PctSum_00;
		ins_PctSum_11 = ins_PctSum_00;
		mtg_PctSum_11 = mtg_PctSum_00;
		heq_PctSum_11 = heq_PctSum_00;
		card_PctSum_11 = card_PctSum_00;
		ILN_PctSum_11 = ILN_PctSum_00;
		IND_PctSum_11 = IND_pctSum_00;
		sln_PctSum_11 = sln_PctSum_00;
		sdb_PctSum_11 = sdb_PctSum_00;
	end;

drop dda_PctSum_00 mms_PctSum_00 sav_PctSum_00 tda_PctSum_00 ira_PctSum_00 sec_PctSum_00 trs_PctSum_00 ins_PctSum_00 mtg_PctSum_00 
     heq_PctSum_00 card_PctSum_00 ILN_PctSum_00 IND_PctSum_00 sln_PctSum_00 sdb_PctSum_00;
run;

proc sort data=prod2;
by descending segment;
run;

data prod3;
set prod2;
retain dda_p mms_p sav_p tda_p ira_p sec_p ins_p trs_p mtg_p heq_p card_p sln_p ind_p iln_p sdb_p
       dda_a mms_a sav_a tda_a ira_a sec_a trs_a mtg_a heq_a card_a sln_a ind_a iln_a 
	   dda_b mms_b sav_b tda_b ira_b sec_b trs_b mtg_b heq_b card_b sln_b ind_b iln_b;
if segment = 99 then do;
	dda_p =dda_pctsum_11;  mms_p =mms_pctsum_11;  sav_p =sav_pctsum_11;  tda_p =tda_pctsum_11;  ira_p =ira_pctsum_11;  sec_p =sec_pctsum_11;  
	ins_p =ins_pctsum_11;  trs_p =trs_pctsum_11;  mtg_p =mtg_pctsum_11;  heq_p =heq_pctsum_11;  card_p =card_pctsum_11;  sln_p =sln_pctsum_11;  
	ind_p =ind_pctsum_11;  iln_p =iln_pctsum_11;  sdb_p =sdb_pctsum_11; 

    dda_a =dda_amt_mean;  mms_a =mms_amt_mean;  sav_a =sav_amt_mean;  tda_a =tda_amt_mean;  ira_a =ira_amt_mean;  sec_a =sec_amt_mean;  
	trs_a =trs_amt_mean;  mtg_a =mtg_amt_mean;  heq_a =heq_amt_mean;  card_a =ccs_amt_mean;  sln_a =sln_amt_mean;  
	ind_a =ind_amt_mean;  iln_a =iln_amt_mean; ; 

	dda_b =dda_amt_avg;  mms_b =mms_amt_avg;  sav_b =sav_amt_avg;  tda_b =tda_amt_avg;  ira_b =ira_amt_avg;  sec_b =sec_amt_avg;  
	trs_b =trs_amt_avg;  mtg_b =mtg_amt_avg;  heq_b =heq_amt_avg;  card_b =ccs_amt_avg;  sln_b =sln_amt_avg;  
	ind_b =ind_amt_avg;  iln_b =iln_amt_avg; ; 
end;
	/*CREATE INDICES FOR pENETRATION */
	dda_Pct = divide( dda_pctsum_11 , dda_p);
	mms_Pct = divide( mms_PctSum_11 , mms_p);
	sav_Pct = divide( sav_PctSum_11 , sav_p);
	tda_Pct = divide( tda_PctSum_11 , tda_p);
	ira_Pct = divide( ira_PctSum_11 , ira_p);
	sec_Pct = divide( sec_PctSum_11 , sec_p);
	trs_Pct = divide( trs_PctSum_11 , trs_p);
	ins_Pct = divide( ins_PctSum_11 , ins_p);
	mtg_Pct = divide( mtg_PctSum_11 , mtg_p);
	heq_Pct = divide( heq_PctSum_11 , heq_p);
	card_Pct = divide( card_PctSum_11 , card_p);
	ILN_Pct = divide( ILN_PctSum_11 , iln_p);
	IND_Pct = divide( IND_pctSum_11 , ind_p);
	sln_Pct = divide( sln_PctSum_11 , sln_p);
	sdb_Pct = divide( sdb_PctSum_11 , sdb_p);

	/*CREATE INDICES FOR aVG bAL_A (tot hh) */
	dda_avg_tot = divide( dda_AMT_MEAN , dda_a);
	mms_avg_tot = divide( mms_AMT_MEAN , mms_a);
	sav_avg_tot = divide( sav_AMT_MEAN , sav_a);
	tda_avg_tot = divide( tda_AMT_MEAN , tda_a);
	ira_avg_tot = divide( ira_AMT_MEAN , ira_a);
	sec_avg_tot = divide( sec_AMT_MEAN , sec_a);
	trs_avg_tot = divide( trs_AMT_MEAN , trs_a);
/*	ins_avg_tot = divide( ins_AMT_MEAN , ins_a);*/
	mtg_avg_tot = divide( mtg_AMT_MEAN , mtg_a);
	heq_avg_tot = divide( heq_AMT_MEAN , heq_a);
	card_avg_tot = divide( ccs_AMT_MEAN , card_a);
	ILN_avg_tot = divide( ILN_AMT_MEAN , iln_a);
	IND_avg_tot = divide( IND_AMT_MEAN , ind_a);
	sln_avg_tot = divide( sln_AMT_MEAN , sln_a);
/*	sdb_avg_tot = divide( sdb_AMT_MEAN , sdb_a);*/

	/*CREATE INDICES FOR aVG bAL_B (prod hh) */
	dda_avg_prd = divide( dda_amt_avg , dda_b);
	mms_avg_prd = divide( mms_amt_avg , mms_b);
	sav_avg_prd = divide( sav_amt_avg , sav_b);
	tda_avg_prd = divide( tda_amt_avg , tda_b);
	ira_avg_prd = divide( ira_amt_avg , ira_b);
	sec_avg_prd = divide( sec_amt_avg , sec_b);
	trs_avg_prd = divide( trs_amt_avg , trs_b);
/*	ins_avg_prd = divide( ins_amt_avg , ins_b);*/
	mtg_avg_prd = divide( mtg_amt_avg , mtg_b);
	heq_avg_prd = divide( heq_amt_avg , heq_b);
	card_avg_prd = divide( ccs_amt_avg , card_b);
	ILN_avg_prd = divide( ILN_amt_avg , iln_b);
	IND_avg_prd = divide( IND_amt_avg , ind_b);
	sln_avg_prd = divide( sln_amt_avg , sln_b);
/*	sdb_avg_prd = divide( sdb_amt_avg , sdb_b);*/
run;


data prod4;
length Product $ 15;
set prod3;
Product = 'Checking';
pct1 = dda_pctsum_1;
avg1 = dda_amt_mean;
output;

Product = 'Money Market';
pct1 = mms_pctsum_1;
avg1 = mms_amt_mean;
output;

Product = 'Savings';
pct1 = sav_pctsum_1;
avg1 = sav_amt_mean;
output;

Product = 'Time Dep.';
pct1 = tda_pctsum_1;
avg1 = tda_amt_mean;
output;

Product = 'IRAs';
pct1 = ira_pctsum_1;
avg1 = ira_amt_mean;
output;

Product = 'Securities';
pct1 = sec_pctsum_1;
avg1 = sec_amt_mean;
output;

Product = 'Insurance';
pct1 = ins_pctsum_1;
avg1 = 0;
output;

Product = 'Mortgage';
pct1 = mtg_pctsum_1;
avg1 = mtg_amt_mean;
output;

Product = 'Home Equity';
pct1 = heq_pctsum_1;
avg1 = heq_amt_mean;
output;

Product = 'Dir. Inst. Loan';
pct1 = iln_pctsum_1;
avg1 = iln_amt_mean;
output;

Product = 'Ind. Inst. Loan';
pct1 = ind_pctsum_1;
avg1 = ind_amt_mean;
output;

Product = 'Credit Card';
pct1 = card_pctsum_1;
avg1 = ccs_amt_mean;
output;

keep segment product pct1 avg1;

run;

axis1 label=(angle=90 f="Arial/Bold" 'Percent Penetration');
axis2  value=none major=none minor=none label=none ;
axis3 label=( f="Arial/Bold" j=l position=bottom 'Product') order=('Checking' 'Money Market' 'Savings' 'Time Dep.' 'IRAs' 'Securities' 'Insurance' 'Mortgage' 'Home Equity' 
             'Dir. Inst. Loan' 'Credit Card' 'Ind. Inst. Loan') split=' '  ;

proc gchart data=prod4;
where Segment not in (. ,7);
vbar segment / outside=sum sumvar=pct1 group=product subgroup=segment
raxis=axis1 maxis=axis2 gaxis=axis3;
run;

data contrib;
merge inactives (in=a keep = hhid segment virtual_seg seg_new dda mms sav tda ira mtg heq iln ind card sec ins trs sln hh) data.contrib_201111 (in=b);
by hhid;
if a;
run;


Proc tabulate data=contrib out=contr1;
class virtual_seg segment;
var dda mms sav tda ira sec trs mtg heq card ILN IND sln ins hh DDA_CON MMS_CON sav_CON TDA_CON IRA_CON sec_CON trs_CON MTG_CON HEQ_CON card_CON iln_CON IND_CON sln_CON ;
table  segment , hh*sum*f=comma12. (sum*f=comma12.0)*(dda mms sav tda ira sec trs ins mtg heq card ILN ind sln ) 
(DDA_CON MMS_CON sav_CON TDA_CON IRA_CON sec_CON trs_CON MTG_CON HEQ_CON caRD_CON iln_CON ind_CON sln_CON )*sum*f=dollar12. 
(DDA_CON MMS_CON sav_CON TDA_CON IRA_CON sec_CON trs_CON MTG_CON HEQ_CON cARD_CON iln_CON ind_CON sln_CON )*mean*f=dollar12.2;
format segment segfmt.;
run;

data contr2;
set contr1;
	dda_con_avg = divide(dda_con_sum , dda_sum);
	mms_con_avg = divide(mms_con_sum , mms_sum);
	sav_con_avg = divide(sav_con_sum , sav_sum);
	tda_con_avg = divide(tda_con_sum , tda_sum);
	ira_con_avg = divide(ira_con_sum , ira_sum);
	sec_con_avg = divide(sec_con_sum , sec_sum);
	trs_con_avg = divide(trs_con_sum , trs_sum);
	mtg_con_avg = divide(mtg_con_sum , mtg_sum);
	heq_con_avg = divide(heq_con_sum , heq_sum);
	iln_con_avg = divide(iln_con_sum , iln_sum);
	ind_con_avg = divide(ind_con_sum , ind_sum);
	sln_con_avg = divide(sln_con_sum , sln_sum);
	card_con_avg = divide(card_con_sum , card_sum);

	if _type_ eq '00' then do;
		virtual_seg = 'Total';
		segment = 99;
	end;
run;

proc sort data=contr2;
by descending segment;
run;

data contr3;
set contr2;
retain dda_a mms_a sav_a tda_a ira_a sec_a trs_a mtg_a heq_a card_a sln_a ind_a iln_a 
	   dda_b mms_b sav_b tda_b ira_b sec_b trs_b mtg_b heq_b card_b sln_b ind_b iln_b;

if segment = 99 then do;

    dda_a =dda_con_mean;  mms_a =mms_con_mean;  sav_a =sav_con_mean;  tda_a =tda_con_mean;  ira_a =ira_con_mean;  sec_a =sec_con_mean;  
	trs_a =trs_con_mean;  mtg_a =mtg_con_mean;  heq_a =heq_con_mean;  card_a =card_con_mean;  sln_a =sln_con_mean;  
	ind_a =ind_con_mean;  iln_a =iln_con_mean; ; 

	dda_b =dda_con_avg;  mms_b =mms_con_avg;  sav_b =sav_con_avg;  tda_b =tda_con_avg;  ira_b =ira_con_avg;  sec_b =sec_con_avg;  
	trs_b =trs_con_avg;  mtg_b =mtg_con_avg;  heq_b =heq_con_avg;  card_b =card_con_avg;  sln_b =sln_con_avg;  
	ind_b =ind_con_avg;  iln_b =iln_con_avg; ; 
end;
	
	/*CREATE INDICES FOR aVG bAL_A (tot hh) */
	dda_avg_tot = divide( dda_con_MEAN , dda_a);
	mms_avg_tot = divide( mms_con_MEAN , mms_a);
	sav_avg_tot = divide( sav_con_MEAN , sav_a);
	tda_avg_tot = divide( tda_con_MEAN , tda_a);
	ira_avg_tot = divide( ira_con_MEAN , ira_a);
	sec_avg_tot = divide( sec_con_MEAN , sec_a);
	trs_avg_tot = divide( trs_con_MEAN , trs_a);
/*	ins_avg_tot = divide( ins_con_MEAN , ins_a);*/
	mtg_avg_tot = divide( mtg_con_MEAN , mtg_a);
	heq_avg_tot = divide( heq_con_MEAN , heq_a);
	card_avg_tot = divide( card_con_MEAN , card_a);
	ILN_avg_tot = divide( ILN_con_MEAN , iln_a);
	IND_avg_tot = divide( IND_con_MEAN , ind_a);
	sln_avg_tot = divide( sln_con_MEAN , sln_a);
/*	sdb_avg_tot = divide( sdb_con_MEAN , sdb_a);*/

	/*CREATE INDICES FOR aVG bAL_B (prod hh) */
	dda_avg_prd = divide( dda_con_avg , dda_b);
	mms_avg_prd = divide( mms_con_avg , mms_b);
	sav_avg_prd = divide( sav_con_avg , sav_b);
	tda_avg_prd = divide( tda_con_avg , tda_b);
	ira_avg_prd = divide( ira_con_avg , ira_b);
	sec_avg_prd = divide( sec_con_avg , sec_b);
	trs_avg_prd = divide( trs_con_avg , trs_b);
/*	ins_avg_prd = divide( ins_con_avg , ins_b);*/
	mtg_avg_prd = divide( mtg_con_avg , mtg_b);
	heq_avg_prd = divide( heq_con_avg , heq_b);
	card_avg_prd = divide( card_con_avg , card_b);
	ILN_avg_prd = divide( ILN_con_avg , iln_b);
	IND_avg_prd = divide( IND_con_avg , ind_b);
	sln_avg_prd = divide( sln_con_avg , sln_b);
/*	sdb_avg_prd = divide( sdb_con_avg , sdb_b);*/

	drop dda_a mms_a sav_a tda_a ira_a sec_a trs_a mtg_a heq_a card_a sln_a ind_a iln_a 
	   dda_b mms_b sav_b tda_b ira_b sec_b trs_b mtg_b heq_b card_b sln_b ind_b iln_b;
run;

proc sort data=contr3;
by virtual_seg segment;
run;


data contr4;
length Product $ 15;
set contr3;
Product = 'Checking';
pct1 = dda_pctsum_1;
avg1 = dda_con_mean;
output;

Product = 'Money Market';
pct1 = mms_pctsum_1;
avg1 = mms_con_mean;
output;

Product = 'Savings';
pct1 = sav_pctsum_1;
avg1 = sav_con_mean;
output;

Product = 'Time Dep.';
pct1 = tda_pctsum_1;
avg1 = tda_con_mean;
output;

Product = 'IRAs';
pct1 = ira_pctsum_1;
avg1 = ira_con_mean;
output;

Product = 'Securities';
pct1 = sec_pctsum_1;
avg1 = sec_con_mean;
output;

Product = 'Insurance';
pct1 = ins_pctsum_1;
avg1 = 0;
output;

Product = 'Mortgage';
pct1 = mtg_pctsum_1;
avg1 = mtg_con_mean;
output;

Product = 'Home Equity';
pct1 = heq_pctsum_1;
avg1 = heq_con_mean;
output;

Product = 'Dir. Inst. Loan';
pct1 = iln_pctsum_1;
avg1 = iln_con_mean;
output;

Product = 'Ind. Inst. Loan';
pct1 = ind_pctsum_1;
avg1 = ind_con_mean;
output;

Product = 'Credit Card';
pct1 = card_pctsum_1;
avg1 = ccs_con_mean;
output;

keep segment product pct1 avg1;

run;

options orientation=landscape;
axis1 label=(angle=90 f="Arial/Bold" 'Contribution');
axis2  value=none major=none minor=none label=none ;
axis3 label=( f="Arial/Bold" j=l position=bottom 'Product') order=('Checking' 'Money Market' 'Savings' 'Time Dep.' 'IRAs' 'Securities' 'Insurance' 'Mortgage' 'Home Equity' 
             'Dir. Inst. Loan' 'Credit Card' 'Ind. Inst. Loan') split=' '  ;

proc gchart data=contr4;
where Segment not in (. ,7);
vbar segment / outside=sum sumvar=avg1 group=product subgroup=segment
raxis=axis1 maxis=axis2 gaxis=axis3;
format avg1 dollar12.2;
run;

data tran ;
set inactives;
where DDA = 1;

	if VPOS_NUM ge 1 then VPOS = 1; else VPOS = 0;
	if MPOS_NUM ge 1 then MPOS = 1; else MPOS = 0;
	if ATMO_NUM ge 1 then ATMO = 1; else ATMO = 0;
	if ATMT_NUM ge 1 then ATMT = 1; else ATMT = 0;
	if BR_TR_NUM ge 1 then BR_TR = 1; else BR_TR = 0;
	if vru_NUM ge 1 then VRU = 1; else VRU = 0;
    if web_signon ge 1 then web1 = 1; else web1 = 0;
    if bp_num ge 1 then bp1 = 1; else bp1 = 0;
    if sms_num ge 1 then sms1 = 1; else sms1 = 0;
	if wap_num ge 1 then wap1 = 1; else wap1 = 0;
    if fico_num ge 1 then fico1 = 1; else fico1 = 0;
	if fworks_num ge 1 then fworks1 = 1; else fworks1 = 0;
	if chk_num ge 1 then chk1 = 1; else chk1 = 0;

keep HHID HH web bp WAP SMS edeliv estat fico FWorks web_signon BP_NUM BP_AMT SMS_NUM WAP_NUM fico_num fworks_num chk_num cqi_dd
VPOS_AMT vpos_num mpos_amt mpos_num ATMO_AMT ATMO_NUM ATMT_AMT ATMT_NUM BR_TR_NUM BR_TR_amt VRU_NUM segment virtual_seg dd_amt
vpos mpos atmo atmt br_tr vru web1 bp1 sms1 wap1 fico1 fworks1 chk1; 
run;

Proc tabulate data=tran out=tran1;
class virtual_seg segment;
var HH web bp WAP SMS edeliv estat fico FWorks web_signon BP_NUM BP_AMT SMS_NUM WAP_NUM fico_num fworks_num chk_num cqi_dd
    VPOS_AMT vpos_num mpos_amt mpos_num ATMO_AMT ATMO_NUM ATMT_AMT ATMT_NUM BR_TR_NUM BR_TR_amt VRU_NUM
    vpos mpos atmo atmt br_tr vru web1 bp1 sms1 wap1 fico1 fworks1 chk1 dd_amt;
table      (hh = 'HHs' web = 'Web Enr'  web1 = 'Web Act' bp = 'BPay Enr.' bp1 = 'BPay Act'  edeliv = 'e-deliv Enr'  estat = 'e-statem Enr.'  
          fico = 'Cred Score Enr' fico1 = 'Cred Score Act'  fworks = 'Finance Wks Enr' fworks1 = 'Finance Wks Act' wap = 'Mobile Enr' wap1 = 'Mobile Act'
	      sms = 'Text Enr' sms1 = 'Text Act' chk1 = 'Checks Active' vpos ='Deb Sign Act' mpos ='Deb PIN Act' atmo = 'MT ATM Act' atmt = 'Oth ATM Act'
          vru = 'VRU Act'  br_tr ='Branch Trans Act' cqi_dd = 'Dir Dep Act')*sum*f=comma12.0

	      (web = 'Web Enr' bp = 'BPay Enr.' edeliv = 'e-deliv Enr'  estat = 'e-statem Enr.' fico = 'Cred Score Enr'   fworks = 'Finance Wks Enr'
          wap = 'Mobile Enr' sms = 'Text Enr')*pctsum<hh>='Percent Enrolled'

		 (web1 = 'Web Act' bp1 = 'BPay Act' fico1 = 'Cred Score Act' fworks1 = 'Finance Wks Act' wap1 = 'Mobiler Act' sms1 = 'Text Act'
		 vpos ='Deb Sign Act' mpos ='Deb PIN Act' atmo = 'MT ATM Act' atmt = 'Oth ATM Act' vru = 'VRU Act'  br_tr ='Branch Trans Act' cqi_dd = 'Dir Dep Act')
         *pctsum<hh>='Percent Active' chk1 = 'Checks Active' 

		 (web_signon = 'Web' bp_num = 'Bill Pay' fico_num = 'Cred Score' fworks_num = 'Finance Wks' wap_num = 'Mobile' sms_num = 'Text' chk_num = 'Checks'
          vpos_num = 'Deb Sign' mpos_num = 'Deb PIN' atmo_num = 'MT ATM' atmt_num = 'Oth ATM' vru_num  ='VRU' br_tr_num = 'Branch')*sum='Transactions'*f=comma12.0 

		(vpos_amt = 'Deb Sign' mpos_amt = 'Deb PIN' atmo_amt = 'MT ATM' atmt_amt = 'oth ATM' bp_amt = 'Bill Pay'  
         br_tr_amt = 'Branch' dd_amt = 'Dir Dep')*sum='Total Amount'*f=dollar12.0 , segment='Segment'
        ;
format segment segfmt.; 
run;


data tran2;
length Type $ 20;
set tran1;

Type = 'Web';
enroll=web_pctsum_1;
active=web1_pctsum_1;
volume=divide(web_signon_sum,web1_sum);
amount=.;
output;

Type = 'Bill Pay';
enroll=bp_pctsum_1;
active=bp1_pctsum_1;
volume=divide(bp_num_Sum,bp1_sum);
amount=divide(bp_amt_sum,bp1_sum);
output;

Type = 'e-delivery';
enroll=edeliv_pctsum_1;
active=.;
volume=.;
amount=.;
output;


Type = 'e-statements';
enroll=estat_pctsum_1;
active=.;
volume=.;
amount=.;
output;

Type = 'Finance Works';
enroll=fworks_pctsum_1;
active=fworks1_pctsum_1;
volume=divide(fworks_num_Sum,fworks1_sum);
amount=.;
output;

Type = 'FICO';
enroll=fico_pctsum_1;
active=fico1_pctsum_1;
volume=divide(fico_num_Sum,fico1_sum);
amount=.;
output;


Type = 'WAP';
enroll=wap_pctsum_1;
active=wap1_pctsum_1;
volume=divide(wap_num_Sum,wap1_sum);
amount=.;
output;

Type = 'SMS';
enroll=SMS_pctsum_1;
active=SMS1_pctsum_1;
volume=divide(SMS_num_Sum,SMS1_sum);
amount=.;
output;

Type = 'Sign Debit';
enroll=.;
active=VPOS_pctsum_1;
volume=divide(VPOS_num_Sum,VPOS_sum);
amount=divide(vpos_amt_sum,vpos_sum);
output;

Type = 'PIN Debit';
enroll=.;
active=mPOS_pctsum_1;
volume=divide(mPOS_num_Sum,mpos_sum);
amount=divide(mpos_amt_sum,mpos_sum);
output;

Type = 'M&T ATM';
enroll=.;
active=atmo_pctsum_1;
volume=divide(atmo_num_Sum,atmo_sum);
amount=divide(atmo_amt_sum,atmo_sum);
output;

Type = 'Non M&T ATM';
enroll=.;
active=atmt_pctsum_1;
volume=divide(atmt_num_Sum,atmt_sum);
amount=divide(atmt_amt_sum,atmt_sum);
output;


Type = 'Branch';
enroll=.;
active=br_tr_pctsum_1;
volume=divide(br_tr_num_Sum,br_tr_sum);
amount=divide(br_tr_amt_sum,br_tr_sum);
output;

Type = 'VRU';
enroll=.;
active=vru_pctsum_1;
volume=divide(vru_num_Sum,vru_sum);
amount=divide(vru_amt_sum,vru_sum);
output;

Type = 'Direct Deposit';
enroll=.;
active=cqi_dd_pctsum_1;
volume=.;
amount=divide(dd_amt_sum,cqi_dd_sum);
output;

keep segment type enroll active volume amount;
run;

options orientation=landscape;
axis1 label=(angle=90 f="Arial/Bold" '% Enrolled');
axis2  value=none major=none minor=none label=none ;
axis3 label=( f="Arial/Bold" j=l position=bottom j=c 'Type of Transaction') order=('Web' 'Bill Pay' 'e=delivery' 'e-statements' 'Finance Works' 'FICO' 'WAP' 'SMS'
             ) split=' '  ;

proc gchart data=tran2;
where Segment not in (. ,7);
vbar segment / outside=sum sumvar=enroll group=Type subgroup=segment
raxis=axis1 maxis=axis2 gaxis=axis3;
format avg1 dollar12.2;
run;

options orientation=landscape;
axis1 label=(angle=90 f="Arial/Bold" '% Active');
axis2  value=none major=none minor=none label=none ;
axis3 label=( f="Arial/Bold" j=l position=bottom j=c 'Type of Transaction') order=('Web' 'Bill Pay' 'Finance Works' 'FICO' 'WAP' 'SMS'
             'Sign Debit' 'PIN Debit' 'M&T ATM' 'Non M&T ATM' 'Branch' 'VRU' 'Direct Deposit') split=' '  ;

proc gchart data=tran2;
where Segment not in (. ,7);
vbar segment / outside=sum sumvar=active group=Type subgroup=segment
raxis=axis1 maxis=axis2 gaxis=axis3;
format avg1 dollar12.2;
run;

options orientation=landscape;
axis1 label=(angle=90 f="Arial/Bold" 'Avg. Transactions (for Active)');
axis2  value=none major=none minor=none label=none ;
axis3 label=( f="Arial/Bold" j=l position=bottom j=c 'Type of Transaction') order=('Web' 'Bill Pay' 'Finance Works' 'FICO' 'WAP' 'SMS'
             'Sign Debit' 'PIN Debit' 'M&T ATM' 'Non M&T ATM' 'Branch' 'VRU' ) split=' '  ;

proc gchart data=tran2;
where Segment not in (. ,7);
vbar segment / outside=sum sumvar=volume group=Type subgroup=segment
raxis=axis1 maxis=axis2 gaxis=axis3;
format avg1 dollar12.2;
run;

options orientation=landscape;
axis1 label=(angle=90 f="Arial/Bold" 'Avg. Amount (for Active)');
axis2  value=none major=none minor=none label=none ;
axis3 label=( f="Arial/Bold" j=l position=bottom j=c 'Type of Transaction') order=(
             'Sign Debit' 'PIN Debit' 'M&T ATM' 'Non M&T ATM' 'Branch'  'Direct Deposit') split=' '  ;

proc gchart data=tran2;
where Segment not in (. ,7);
vbar segment / outside=sum sumvar=amount group=Type subgroup=segment
raxis=axis1 maxis=axis2 gaxis=axis3;
format avg1 dollar12.2;
run;
