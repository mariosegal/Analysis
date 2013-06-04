option symbolgen;

libname wip "C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files";
libname virtual 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled';
libname Data 'C:\Documents and Settings\ewnym5s\My Documents\Data';


options MSTORED SASMSTORE = mjstore;
libname mjstore 'C:\Documents and Settings\ewnym5s\My Documents\SAS\Macros';

libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
options fmtsearch=(SAS);

%let condition=virtual_seg ne "";

PROC FORMAT library=sas;
PICTURE PCTPIC low-high='000%';
RUN;

data wip.temp ;
set data.Main_201111 ;
where &condition;
run;


/*penetration and Balances*/
Proc tabulate data=wip.temp out=wip.prod1;
class virtual_seg segment;
var dda mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins hh DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt IND_AMT sln_amt ;
table  virtual_seg*segment ALL, hh*sum*f=comma12. (sum*f=comma12.0)*(dda mms sav tda ira sec trs ins mtg heq card ILN ind sln sdb) 
(pctsum<hh>*f=PCTPIC.)*(dda mms sav tda ira sec trs ins mtg heq card ILN ind sln sdb )  
(DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt )*sum*f=dollar12. 
(DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt )*mean*f=dollar12.;
keylabel PCTSUM = 'PCT';
format segment segfmt.;
run;


data wip.prod2;
set wip.prod1;
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

proc sort data=wip.prod2;
by descending segment;
run;

data wip.prod3;
set wip.prod2;
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


proc sort data=wip.prod3;
by virtual_seg segment;
run;

proc print data=wip.prod3 (drop=_type_ _page_ _table_) noobs;
run;
/*contribution*/

data wip.temp_hh;
set wip.temp (keep= hhid hh dda mms sav tda ira ins sec trs mtg heq card iln sln ind virtual_seg segment deposits loans securities tran_segm);
run;

proc sort data=data.Contrib_201111;
by hhid;
run;

data wip.temp_contrib ;
merge  data.Contrib_201111 (in=b) wip.temp_hh (in=a);
by hhid;
if a and b;
run;

Proc tabulate data=wip.temp_contrib out=wip.contr1;
class virtual_seg segment;
var dda mms sav tda ira sec trs mtg heq card ILN IND sln ins hh DDA_CON MMS_CON sav_CON TDA_CON IRA_CON sec_CON trs_CON MTG_CON HEQ_CON card_CON iln_CON IND_CON sln_CON ;
table  virtual_seg*segment ALL, hh*sum*f=comma12. (sum*f=comma12.0)*(dda mms sav tda ira sec trs ins mtg heq card ILN ind sln ) 
(DDA_CON MMS_CON sav_CON TDA_CON IRA_CON sec_CON trs_CON MTG_CON HEQ_CON caRD_CON iln_CON ind_CON sln_CON )*sum*f=dollar12. 
(DDA_CON MMS_CON sav_CON TDA_CON IRA_CON sec_CON trs_CON MTG_CON HEQ_CON cARD_CON iln_CON ind_CON sln_CON )*mean*f=dollar12.2;
format segment segfmt.;
run;

data wip.contr2;
set wip.contr1;
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

proc sort data=wip.contr2;
by descending segment;
run;

data wip.contr3;
set wip.contr2;
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

proc sort data=wip.contr3;
by virtual_seg segment;
run;

proc print data=wip.contr3 (drop=_type_ _page_ _table_) noobs;
run;


/* Band*/

data wip.temp_band;
set wip.temp;
keep hhid hh segment virtual_seg band tran_segm;
run;

Proc tabulate data=wip.temp_band out=wip.band1;
class virtual_seg segment band;
var hh;
table (band )* (N*f=comma12. ), virtual_seg*(segment ALL) /nocellmerge ;
/*table band * pctN<band>*f=PCTPIC., virtual_seg*(segment ALL) ;*/
/*table band * pctn<band*virtual_seg>*f=PCTPIC., virtual_seg*(segment ALL) ;*/
/*pctN<segment>*f=PCTPIC.;*/
format segment segfmt.;
run;


proc print data=wip.contr3 noobs;
run;

proc print data=wip.contr3 noobs;
var virtual_seg segment hh_sum mms_sum mms_con_sum mms_con_mean mms_con_avg mms_avg_tot mms_avg_prd;
run;




data wip.temp_1;
set wip.temp;
length wealth $ 15;
    where ixi_tot ne .;
	x = max(ixi_tot,sum(dda_amt,sav_amt,tda_amt,ira_amt,mms_amt,sec_amt));
	select;
		when (x ge 0 and x lt 25000) wealth='Up to 25M';
		when (x ge 25000 and x lt 100000) wealth='25-100M'; 
		when (x ge 100000 and x lt 250000) wealth='100-250M'; 
		when (x ge 250000 and x lt 500000) wealth='250-500M'; 
		when (x ge 500000 and x lt 1000000) wealth='500M-1MM'; 
		when (x ge 1000000 and x lt 2000000) wealth='1-2MM';
		when (x ge 2000000 and x lt 3000000) wealth='2-3MM';
		when (x ge 3000000 and x lt 4000000) wealth='3-4MM'; 
		when (x ge 4000000 and x lt 5000000) wealth='4-5MM';
		when (x ge 5000000 and x lt 10000000) wealth='5-10MM';
	 	when (x ge 10000000 and x lt 15000000) wealth='10-15MM';
		when (x ge 15000000 and x lt 20000000) wealth='15-20MM';
		when (x ge 20000000 and x lt 25000000) wealth='20-25MM';
		when (x ge 25000000 ) wealth='25MM+'; 
		otherwise wealth='XXX';
	end;
	cqi = sum (of cqi:);
	assets = x;
drop x;
keep hhid hh cqi: wealth virtual_seg segment clv: assets;
run;

proc tabulate data=wip.temp_1 ;
class virtual_seg segment;
var hh assets clv: cqi: ;
table hh*f=comma12.0 assets*mean*f=dollar12.0 (clv_total clv_rem)*mean*f=dollar12.0 clv_rem_ten*mean*f=comma8.1 
      cqi*mean*f=comma5.1 (cqi_bp cqi_DD cqi_deb cqi_odl cqi_web )*pctsum<hh>*f=PCTPIC.,virtual_seg*(segment ALL) /nocellmerge ;
format segment segfmt.;
run;


data wip.temp_demog;
merge wip.temp_1 (in=a keep=hhid hh virtual_seg segment) data.demog_201111 (in=b);
by hhid;
if a and b;
run;

data wip.temp_demog;
set wip.temp_demog;
under_10 = .;
if flag_under_10 eq 'Y' then under_10 = 1;
if flag_under_10 eq 'N' then under_10 = 0;
child_11_15 = .;
if flag_11_15 eq 'Y' then child_11_15 = 1;
if flag_11_15 eq 'N' then child_11_15 = 0;
child_16_17 = .;
if flag_16_17 eq 'Y' then child_16_17 = 1;
if flag_16_17 eq 'N' then child_16_17 = 0;
child = .;
if children eq 'Y' then child = 1;
if children eq 'N' then child = 0;
run;


proc tabulate data=wip.temp_demog;
class virtual_seg segment;
var hh own_age child under_10 child_11_15 child_16_17  ;
table hh*f=comma12.0 own_age*mean*f=comma5.1 (child under_10 child_11_15 child_16_17)*pctsum<hh>*f=pctpic.  
      ,virtual_seg*(segment ALL) /nocellmerge ;
format segment segfmt.;
run;


proc tabulate data=wip.temp_demog;
class virtual_seg segment own_age ;
var hh ;
table  hh own_age 
      ,virtual_seg*(segment ALL) /nocellmerge ;
format segment segfmt. own_age ageband.;
run;

proc tabulate data=wip.temp_demog;
class virtual_seg segment income ;
var hh ;
table  hh income 
      ,virtual_seg*(segment ALL) /nocellmerge ;
format segment segfmt. income incmfmt.;
run;

proc freq data=wip.temp_demog;
table flag_under_10 flag_11_15 flag_16_17 / missing;
run;

proc summary data=virtual.checking ;
output out=wip.temp_chk;
class hhid;
id stype;
run;

data tempq;
set wip.temp_chk;
where _type_ ne 0;
drop _TYPE_;
run;

proc transpose data=tempq out=wip.temp_chk_2 (drop=_NAME_);
by hhid;
id stype;
run;

proc format library=sas;
value $stypefmt 	'RA2' = 'Retail Classic Checking'
					'RA8' = 'Retail M&T Classic Checking with Interest'
					'RB2' = 'Retail Pay As You Go'
					'RC2' = 'Retail Student Checking'
					'RC6' = 'Retail @College Checking'
					'RD2' = 'Retail Worry Free Checking'
					'RE2' = 'Retail Worry Free (Dir Dep) Checking'
					'RE5' = 'Retail Totally Free Checking'
					'RE6' = 'Retail MyChoice Checking'
					'RF2' = 'Retail Interest Checking (First)'
					'RG2' = 'Retail Interest Checking'
					'RG6' = 'Retail Premium Checking'
					'RH2' = 'Retail Select Checking with Interest'
					'RH6' = 'Retail Power Checking with Interest'
					'RI1' = 'Retail Brokerage Checking Account'
					'RI2' = 'Retail Portfolio Management Account'
					'RJ2' = 'Retail First Checking'
					'RJ7' = 'Retail Relationship Checking'
					'RK2' = 'Retail First Checking with Interest'
					'RK6' = 'Retail Alliance Checking'
					'RK7' = 'Retail Relationship Checking with Interest'
					'RW2' = 'Retail Select Checking'
					'RX2' = 'Retail Direct Checking'
					'RX7' = 'Retail M&T At Work Checking'
					'RX6' = 'Retail Direct Deposit Checking'
					'RZ2' = 'Retail Basic Checking';
run;

data wip.chk_merged;
merge wip.temp (in=a keep=hhid hh segment virtual_seg) wip.temp_chk_2;
by hhid;
if a;
run;


proc tabulate data=wip.chk_merged;
class segment virtual_seg;
var hh R:;
table hh*sum*f=comma12.0 (R:)*N (R:)*pctN<hh> ,virtual_seg*(segment ALL) /nocellmerge;
run;


proc contents data=wip.temp varnum short;
run;


data wip.temp_tran ;
set wip.temp;
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

Proc tabulate data=wip.temp_tran out=wip.tran1;
class virtual_seg segment;
var HH web bp WAP SMS edeliv estat fico FWorks web_signon BP_NUM BP_AMT SMS_NUM WAP_NUM fico_num fworks_num chk_num cqi_dd
    VPOS_AMT vpos_num mpos_amt mpos_num ATMO_AMT ATMO_NUM ATMT_AMT ATMT_NUM BR_TR_NUM BR_TR_amt VRU_NUM
    vpos mpos atmo atmt br_tr vru web1 bp1 sms1 wap1 fico1 fworks1 chk1 dd_amt;
table    (hh = 'HHs' web = 'Web Enr'  web1 = 'Web Act' bp = 'BPay Enr.' bp1 = 'BPay Act'  edeliv = 'e-deliv Enr'  estat = 'e-statem Enr.'  
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
         br_tr_amt = 'Branch' dd_amt = 'Dir Dep')*sum='Total Amount'*f=dollar12.0
         , virtual_seg='Transaction Segment'*segment='Segment';
format segment segfmt.; 
run;


Proc tabulate data=wip.temp out=wip.prod9;
class virtual_seg segment;
var deposits loans securities dda mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins hh DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt IND_AMT sln_amt ;
table   hh*sum*f=comma12. (sum='Product HHs'*f=comma12.0)*(deposits loans securities dda mms sav tda ira sec trs ins mtg heq card ILN ind sln sdb) 
(pctsum<hh>='Prod penetration'*f=PCTPIC.)*(deposits loans securities dda mms sav tda ira sec trs ins mtg heq card ILN ind sln sdb )  
(DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt )*sum='Total Balances'*f=dollar12. 
(DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt )*mean='Avg. $ Per Total HH'*f=dollar12.,(virtual_seg ALL)*(segment ALL) ALL;
/*keylabel PCTSUM = 'PCT';*/
format segment segfmt.;
run;



data wip.temp;
set wip.temp;
deposits=0;
if dda or mms or tda or ira or sav then deposits=1;
loans=0;
if mtg or heq or ind or iln or sln or card then loans=1;
securities = 0;
if sec or trs or ins then securities=1;
run;


/*table   (sum)*(HH web bp WAP SMS edeliv estat fico FWorks web_signon BP_NUM BP_AMT SMS_NUM WAP_NUM fico_num fworks_num chk_num cqi_dd*/
/*                       VPOS_AMT vpos_num mpos_amt mpos_num ATMO_AMT ATMO_NUM ATMT_AMT ATMT_NUM BR_TR_NUM BR_TR_amt VRU_NUM*/
/*                       vpos mpos atmo atmt br_tr vru web1 bp1 sms1 wap1 fico1 fworks1 chk1 dd_amt), virtual_seg*segment,;*/


filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\Part1.txt';

data Data.promo_2011a;
length month_id $ 9 hhid $9 promo $ 10 name $ 40  segm_name $ 60 chan1 $ 5 chan2 $ 5 chan3 $ 5 target $ 3;
infile mydata DLM='09'x firstobs=2 lrecl=4096 dsd;
	  INPUT month_id $  hhid $ promo $  name $  segm $  segm_name $  date_start :mmddyy. date_end :mmddyy. chan1 $ chan2 $ chan3 $ target $ ;
run;

filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\Part2.txt';

data Data.promo_2011b;
length month_id $ 9 hhid $9 promo $ 10 name $ 40  segm_name $ 60 chan1 $ 5 chan2 $ 5 chan3 $ 5 target $ 3;
infile mydata DLM='09'x firstobs=2 lrecl=4096 dsd;
	  INPUT month_id $  hhid $ promo $  name $  segm $  segm_name $  date_start :mmddyy. date_end :mmddyy. chan1 $ chan2 $ chan3 $ target $ ;
run;

proc freq data=data.promo_2011;
table target;
run;

data Data.Promo_2011;
length  em 1 br 1 tbc 1 DM 1;
set Data.promo_2011a Data.promo_2011b ;
segm_num = segm;
em = 0;
if chan1 eq 'EM' or chan2 eq 'EM' or chan3 eq 'EM' then em = 1;
br = 0;
if chan1 eq 'BR' or chan2 eq 'BR' or chan3 eq 'BR' then br = 1;
dm = 0;
if chan1 eq 'DM' or chan2 eq 'DM' or chan3 eq 'DM' then dm = 1;
tbc = 0;
if chan1 eq 'TBC' or chan2 eq 'TBC' or chan3 eq 'TBC' then tbc = 1;
drop chan1 chan2 chan3 segm;
run;

proc sort data=data.promo_2011;
by month_id;
run;


/*proc sql outobs=10;*/
/*create table test as */
/*select hhid, count(promo) as contacts, sum(em) as sum_em, sum(br) as sum_br, sum(dm) as sum_dm, sum(tbc) as sum_tbc,*/
/*       sum(if target = 'CC' then 1 else 0) as card, sum(if target = 'DDA' then 1 else 0) as chk, */
/**/
/*	    from data.promo_2011 group by month_id;*/
/*quit;*/

/*proc sql outobs=10;*/
/*create table test as */
/*select hhid, count(where target = "DDA") as checking*/
/*	    from data.promo_2011 group by month_id;*/
/*quit;*/

proc freq data=data.promo_2011 noprint;
where month_id ne '';
table month_id*target / out=targets nopercent norow nocol;
run;

data targets;
set targets;
if target eq '' then target = 'XXX';
run;


proc transpose data=targets(drop=PERCENT) Out=targets_table;
by month_id;
id target ;
run;

proc contents data=data.promo_2011 varnum short; run;


data data.promo_2011;
set data.promo_2011;
em1 = 0;
if em eq '1' then em1 = 1;
br1 = 0;
if br eq '1' then br1 = 1;
dm1 = 0;
if dm eq '1' then dm1 = 1;
tbc1 = 0;
if tbc eq '1' then tbc1 = 1;
run;



proc sql;
create table channels as
select month_id, sum(em1), sum(br1), sum(dm1), sum(tbc1), count(promo) as promos
from data.promo_2011 
where month_id <> "" 
group by month_id;
quit;



proc print data=data.promo_2011;
where month_id eq '200003138';
run;

data wip.temp_br_tr;
set virtual.summary_2011;
branch = sum(br_1,  br_15);
keep hhid br_1  br_15 branch;
run;

data virtual.promo_2011_clean;
merge data.main_201111 (in=a keep=hhid virtual_seg segment tran_segm br_tr_num rename=(hhid=id) where=(virtual_seg ne '')) 
      virtual.channels (in=b keep=month_id promos _temg001 _temg002 _temg003 _temg004 rename=(month_id=id _temg001=email _temg002=branch _temg003=DM _temg004=tbc))
	  virtual.targets_table (in=c drop=_NAME_ _LABEL_ rename=(month_id=id))
	  wip.temp_br_tr (in=d keep=hhid branch rename=(hhid=id branch=br_visits));
by id;
hh=1;
if a and b and c and d;
run;
/**/
/*data virtual.promo_2011_clean;*/
/*length hh 3;*/
/*set virtual.promo_2011_clean;*/
/*hh = 1;*/
/*run;*/


/*data tempz;*/
/*merge virtual.promo_2011_clean (in=a) wip.temp (in=b keep=hhid tran_segm rename=(hhid=id));*/
/*if a and b;*/
/*run;*/

/*data virtual.promo_2011_clean;*/
/*set tempz;*/
/*run;*/


proc tabulate data=virtual.promo_2011_clean;
class segment virtual_seg;
var email branch DM tbc promos XXX CC DDA DEB LN MTG HEQ WEB SEC DEP br_tr_num hh br_visits;
table (hh='HHs')*sum='Count'*f=comma12.0 ,(virtual_seg ALL)*(segment ALL);
table (email='Emails Sent' branch='Branch Calls' DM='Mail Pieces Send' tbc='TBC Calls' )*Sum='Number of Contacts'*f=comma12. 
       br_visits='Branch Visits'*Sum='Number of Visits'*f=comma12.
      (DEP='Deposits' DDA='Checking' DEB='Debit Card' WEB='Web Banking' CC='Card' LN='Loans' MTG='Mortgage' HEQ='Home Equity'  SEC='Investments' 
       XXX='Other')*Sum='Number of Leads'*f=comma12.
      ,(virtual_seg ALL)*(segment ALL);
format segment segfmt.;
keylabel ALL='Total';
run;

proc tabulate data=virtual.promo_2011_clean;
class  virtual_seg;
var email branch DM tbc promos XXX CC DDA DEB LN MTG HEQ WEB SEC DEP br_tr_num hh br_visits;
table (hh='HHs' promos='Promos')*sum='Count'*f=comma12.0 ,(virtual_seg ALL);
table (email='Emails Sent' branch='Branch Calls' DM='Mail Pieces Send' tbc='TBC Calls' )*Sum='Number of Contacts'*f=comma12. 
       br_visits='Branch Visits'*Sum='Number of Visits'*f=comma12.
      (DEP='Deposits' DDA='Checking' DEB='Debit Card' WEB='Web Banking' CC='Card' LN='Loans' MTG='Mortgage' HEQ='Home Equity'  SEC='Investments' 
       XXX='Other')*Sum='Number of Leads'*f=comma12.
      ,(virtual_seg ALL);
/*format segment segfmt.;*/
keylabel ALL='Total';
run;

proc contents data=virtual.channels_table varnum short; run;


proc tabulate data=virtual.channels_table out=data1;
var email branch DM tbc promos;
table N='HHs'*f=comma12.0 (email='Emails Sent' branch='Branch Calls' DM='Mail Pieces Send' tbc='TBC Calls')*Sum='Number of Contacts'*f=comma12.;
run;

data data2;
set data1;
channel = 'Branch';
count = branch_sum;
output;
channel = 'Email';
count = email_sum;
output;
channel = 'TBC';
count = tbc_sum;
output;
channel = 'DM';
count = dm_sum;
output;
keep channel count;
run;


proc gchart data=data2;
pie channel / sumvar=count percent=arrow slice=arrow value=arrow slice=arrow
plabel=(font='Arial /bold' color=blue);
format count comma12.0 ;
run;


data data3;
merge virtual.channels_table (in=b keep=id promos email branch DM TBC )
	  virtual.targets_table (in=c drop=_NAME_ _LABEL_ rename=(month_id=id));
hh=1;
by id;
if b and c;
run;

proc tabulate data=data3 out=data4;
var XXX CC DDA DEB LN MTG HEQ WEB SEC DEP;
table (DEP='Deposits' DDA='Checking' DEB='Debit Card' WEB='Web Banking' CC='Card' LN='Loans' MTG='Mortgage' HEQ='Home Equity'  SEC='Investments' 
       XXX='Other')*Sum='Number of Contacts'*f=comma12.;
run;

data data5;
set data4;
target = 'Deposits';
count = dep_sum;
output;
target = 'Checking';
count = dda_sum;
output;
target = 'Debit';
count = deb_sum;
output;
target = 'Web';
count = web_sum;
output;
target = 'Card';
count = cc_sum;
output;
target = 'Lending';
count = ln_sum;
output;
target = 'Mortgage';
count = mtg_sum;
output;
target = 'Home Equity';
count = heq_sum;
output;
target = 'Investments';
count = sec_sum;
output;
target = 'Other';
count = xxx_sum;
output;
keep target count;
run;

/*ods pdf ;*/
proc gchart data=data2;
pie channel / sumvar=count percent=arrow slice=arrow value=arrow slice=arrow
plabel=(font='Arial /bold' color=blue);
format count comma12.0 ;
run;

proc gchart data=data5;
pie target / sumvar=count percent=arrow slice=arrow value=arrow slice=arrow
plabel=(font='Arial /bold' color=blue);
format count comma12.0 ;
run;






data wip.temp_branch;
merge wip.temp (in=a keep=hhid hh virtual_seg tran_segm segment) wip.temp_br_tr (in=b);
by hhid;
if a;
run;

proc tabulate data=wip.temp_branch;
var branch hh;
class segment virtual_seg tran_segm;
table hh*sum='HHs'*f=comma12. branch*sum='Total Visits'*f=comma12. branch*mean='Avg. Visits'*f=comma6.1 , (virtual_seg ALL)*(segment ALL) ALL /nocellmerge;
table hh*sum='HHs'*f=comma12. branch*sum='Total Visits'*f=comma12. branch*mean='Avg. Visits'*f=comma6.1 , (tran_segm ALL)*(segment ALL) ALL /nocellmerge;
format segment segfmt. ;
run;

data virtual.Promo_merged;
merge data.promo_2011 (in=a  where=(key ne '') rename=(month_id=key))
      data.main_201111 (in=b keep = hhid segment virtual_seg tran_segm hh rename=(hhid=key));
by key;
if a and b;
run;

proc contents data=virtual.Promo_merged varnum short;
run;

proc tabulate data=virtual.Promo_merged missing;
where virtual_seg ne '';
var em1 br1 dm1 tbc1;
class target;
table (em1 br1 dm1 tbc1)*sum*f=comma12. , target ALL;
run;

ods html close;
proc tabulate data=virtual.Promo_merged out=wip.promo_detail missing ;
var br1 em1 tbc1 dm1 hh;
class   tran_segm virtual_seg segment target ;
table ((tran_segm='Summary Group' )*(virtual_seg='Tran Segment')*(segment='Lifecycle Segment')*(Target='Target Prodct') )*
      (hh='HHs' br1='Branch Lead' em1='Emails'  tbc1='TBC Lead' DM1='Direct Mail')*sum='Count'*f=comma12. /  nocellmerge;
run;
ods html;

proc tabulate data=wip.promo_detail missing;
class tran_segm virtual_seg segment target ;
where tran_segm ne 'XXXX' and tran_segm ne '' and target ne '';
var hh_sum br1_sum dm1_sum tbc1_sum em1_sum;
table (virtual_seg ALL)*(segment ALL)*(target ALL) ALL, 
      (hh_sum='HHs')*sum='HHs'*f=comma12. (br1_sum='Branch Leads' dm1_sum='Direct Mail' tbc1_sum='TBC Leads' em1_sum='Emails')*sum='Messages'*f=comma12. /nocellmerge;
table (tran_segm ALL)*(segment ALL)*(target ALL) ALL,
      (hh_sum='HHs')*sum='HHs'*f=comma12. (br1_sum='Branch Leads' dm1_sum='Direct Mail' tbc1_sum='TBC Leads' em1_sum='Emails')*sum='Messages'*f=comma12. /nocellmerge;
format segment segfmt.;
run;

proc freq data=data.promo_2011 order=freq;
where target ne '';
table name / norow nocol nopercent;
run;

proc tabulate data=virtual.promo_merged (keep=key);
where virtual_seg ne '';
class key;
table N;
run;


/* do distributions by contact */
/* I need to summarize contacts by HH first, promo 2011 clean appear to have that already, but I want to add a total touches column*/


proc contents data = virtual.promo_2011_clean varnum short;
run;

data test;
set virtual.promo_2011_clean;
total = sum(email, branch, DM, tbc);
run;

data virtual.promo_2011_clean;
set test;
run;

proc tabulate data=virtual.promo_2011_clean missing out=detail (drop=_page_ _table_);
class total virtual_seg tran_segm;
var hh;
table total, (ALL virtual_seg)*(hh*sum='HHs'*f=comma12.0) / nocellmerge;
keylabel pctsum = 'Percent';
run;

proc print data=detail;
run;

proc tabulate data=virtual.promo_2011_clean missing out=summary;
class total virtual_seg tran_segm;
var hh;
table total, ( ALL tran_segm)*(hh*sum='HHs'*f=comma12.0) / nocellmerge;
keylabel pctsum = 'Percent';
run;


proc gchart data=summary;
where tran_segm = 'Branch';
vbar total / freq=hh_sum midpoints=0 to 100 by 1 type=pct g100;
run;



proc gplot data=summary;
symbol1 interpol=join  value=dot ;
plot hh_Sum*totaL=tran_segm;
run;

proc gplot data=detail;
symbol1 interpol=join  value=dot ;
plot hh_Sum*totaL=virtual_seg;
run;

/*create quartiles to investigate why we have 2 humps, 2nd hump is on q2 (second top)*/

data temp1;
set virtual.promo_2011_clean;
select ;
	when (total ge 0 and total le 6) contact_band = 'q4';
	when (total ge 7 and total le 25) contact_band = 'q3';
	when (total ge 26 and total le 38) contact_band = 'q2';
	when (total ge 39 ) contact_band = 'q1';
	otherwise contact_band = 'xx';
end;
keep id total contact_band;
run;

data temp2;
merge virtual.promo_2011_clean (in=a) temp1 (in=b);
by id;
if a and b;
run;

data virtual.promo_2011_clean;
set temp2;
run;

data wip.temp_contact_quartiles;
merge data.Main_201111 (in=a rename=(hhid=id)) temp1 (in=b);
by id;
if a and b;
run;

data wip.temp_band;
set wip.temp_contact_quartiles;
keep id hh segment virtual_seg band tran_segm contact_band;
run;

Proc tabulate data=wip.temp_band out=wip.band1;
class contact_band band;
var  hh;
table (contact_band ALL), (band )* (rowpctn) /nocellmerge ;
/*table band * pctN<band>*f=PCTPIC., virtual_seg*(segment ALL) ;*/
/*table band * pctn<band*virtual_seg>*f=PCTPIC., virtual_seg*(segment ALL) ;*/
/*pctN<segment>*f=PCTPIC.;*/
/*format segment segfmt.;*/
run;

data wip.band2;
length quartile $ 5;
set wip.band1;
if contact_band eq '' then  do;
	quartile = 'Total';
	pct = PCTN_00;
end;
else do;
	pct = PCTN_10;
	quartile = contact_band;
end;
drop _type_ _page_ _table_ pctn_10 pctn_00;
run;


option orientation=landscape;
proc gchart data=wip.band2;
axis1 label=none value=none minor=none major=none;
vbar quartile / group=band sumvar=pct outside=sum  subgroup=quartile
gspace = 2 width=8 raxis=axis1 space=.5;
format pct comma5.1;
run;

option orientation=landscape;
proc gchart data=wip.band2;
axis1 label=none value=none minor=none major=none;
vbar quartile /  sumvar=pct inside=sum  subgroup=band
gspace = 5 width=8 raxis=axis1 space=5;
format pct comma5.1;
run;


Proc tabulate data=wip.temp_contact_quartiles out=wip.prod1;
class contact_band;
var dda mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins hh DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt IND_AMT sln_amt ;
table  contact_band ALL, hh*sum*f=comma12. (sum*f=comma12.0)*(dda mms sav tda ira sec trs ins mtg heq card ILN ind sln sdb) 
(pctsum<hh>*f=PCTPIC.)*(dda mms sav tda ira sec trs ins mtg heq card ILN ind sln sdb ) ;
keylabel PCTSUM = 'PCT';
format segment segfmt.;
run;

data wip.prod2;
length Product $ 3 quartile $ 5;
array prods{15} $ 3 ('DDA' 'MMS' 'SAV' 'TDA' 'IRA' 'SEC' 'INS' 'TRS' 'MTG' 'HEQ' 'ILN' 'CCS' 'IND' 'SLN' 'SDB');
array products{15} $ 4 DDA MMS SAV TDA IRA SEC INS TRS MTG HEQ ILN Card IND SLN SDB;
array sums{15} DDA_SUM MMS_SUM SAV_SUM TDA_SUM IRA_SUM SEC_SUM INS_SUM TRS_SUM MTG_SUM HEQ_SUM ILN_SUM Card_SUM IND_SUM SLN_SUM SDB_SUM;
array pcts{15} DDA_PCTSUM_1 MMS_PCTSUM_1 SAV_PCTSUM_1 TDA_PCTSUM_1 IRA_PCTSUM_1 SEC_PCTSUM_1 INS_PCTSUM_1 TRS_PCTSUM_1 MTG_PCTSUM_1 
               HEQ_PCTSUM_1 ILN_PCTSUM_1 Card_PCTSUM_1 IND_PCTSUM_1 SLN_PCTSUM_1 SDB_PCTSUM_1;
array pcts_0{15} DDA_PCTSUM_0 MMS_PCTSUM_0 SAV_PCTSUM_0 TDA_PCTSUM_0 IRA_PCTSUM_0 SEC_PCTSUM_0 INS_PCTSUM_0 TRS_PCTSUM_0 MTG_PCTSUM_0 
               HEQ_PCTSUM_0 ILN_PCTSUM_0 Card_PCTSUM_0 IND_PCTSUM_0 SLN_PCTSUM_0 SDB_PCTSUM_0;
set wip.prod1;
do i = 1 to 15;
	Product = prods{i};
	Count = sums{i};
	PCT = pcts{i};
	quartile = contact_band;
	if contact_band eq '' then do;
		quartile = 'Total';
		PCT = pcts_0{i};
	end;
	output;
end;
keep product count pct  quartile;
run;

proc gchart data=wip.prod2;
axis1 ;
axis2 order=('SAV' 'MMS' 'TDA' 'IRA' 'SEC' 'INS' 'TRS' 'MTG' 'HEQ' 'ILN' 'CCS' 'IND' 'SLN' 'SDB'); 
axis3 label=none value=none;
vbar quartile / group=product sumvar=pct outside=sum  subgroup=quartile
gspace = 2 width=8 raxis=axis1 space=.5 GAXIS=AXIS2 maxis=axis3;
format pct comma5.1;
run;


data wip.temp_rm;
set wip.temp_contact_quartiles;
keep id hh segment virtual_seg rm tran_segm contact_band;
run;

Proc tabulate data=wip.temp_rm out=wip.rm1;
class contact_band rm;
var  hh;
table (contact_band ALL), (rm )* (rowpctn) /nocellmerge ;
/*table band * pctN<band>*f=PCTPIC., virtual_seg*(segment ALL) ;*/
/*table band * pctn<band*virtual_seg>*f=PCTPIC., virtual_seg*(segment ALL) ;*/
/*pctN<segment>*f=PCTPIC.;*/
/*format segment segfmt.;*/
run;

data wip.rm2;
length quartile $ 5;
set wip.rm1;
if contact_band eq '' then  do;
	quartile = 'Total';
	pct_1 = PCTN_00;
end;
else do;
	pct_1 = PCTN_10;
	quartile = contact_band;
end;
drop _type_ _page_ _table_ pctn_10 pctn_00;
run;

option orientation=landscape;
proc gchart data=wip.rm2;
axis1 label=none value=none minor=none major=none;
vbar quartile / type=sum sumvar=pct_1  inside=sum   subgroup=rm noframe
gaxis=axis1 raxis=axis1;
/*gspace = 2 width=8 raxis=axis1 space=.5;*/
format pct comma5.1;
run;


Proc tabulate data=wip.temp_1 out=wip.asset1;
class virtual_seg wealth;
var  hh;
table (wealth ALL), (virtual_seg ALL )* (rowpctn) /nocellmerge ;
/*table band * pctN<band>*f=PCTPIC., virtual_seg*(segment ALL) ;*/
/*table band * pctn<band*virtual_seg>*f=PCTPIC., virtual_seg*(segment ALL) ;*/
/*pctN<segment>*f=PCTPIC.;*/
/*format segment segfmt.;*/
run;

data wip.asset2;
set wip.asset1;
if wealth eq ''  then  do;
	wealth = 'Total';
	pct_1 = PCTN_00;
end;
else if virtual_seg eq '' then do;
	delete;
end;
else do;
	pct_1=pctn_01;
end;
drop _type_ _page_ _table_ pctn_01 pctn_00;
run;

proc gchart data=wip.asset2;
where virtual_seg ne '';
axis1 label=none value=none minor=none major=none;
axis2 order=('Up to 25M'  '25-100M'  '100-250M'  '250-500M'  '500M-1MM'  '1-2MM' '2-3MM' 
'3-4MM'  '4-5MM' '5-10MM' '10-15MM' '15-20MM' '20-25MM' '25MM+' 'Total'); 
axis3 label=none value=none minor=none major=none ;
vbar wealth / type=sum sumvar=pct_1  inside=sum   subgroup=virtual_seg noframe
gaxis=axis3 raxis=axis1 maxis=axis2;
/*gspace = 2 width=8 raxis=axis1 space=.5;*/
run;
quit;


Proc tabulate data=wip.temp_1 out=wip.segm1;
class virtual_seg segment;
var  hh;
table (segment ALL), (virtual_seg ALL )* (rowpctn) /nocellmerge ;
/*table band * pctN<band>*f=PCTPIC., virtual_seg*(segment ALL) ;*/
/*table band * pctn<band*virtual_seg>*f=PCTPIC., virtual_seg*(segment ALL) ;*/
/*pctN<segment>*f=PCTPIC.;*/
/*format segment segfmt.;*/
run;

data wip.segm2;
set wip.segm1;
if segment eq .  then  do;
	segment = '10';
	pct_1 = PCTN_00;
end;
else if virtual_seg eq '' then do;
	delete;
end;
else do;
	pct_1=pctn_01;
end;
drop _type_ _page_ _table_ pctn_01 pctn_00;
run;

