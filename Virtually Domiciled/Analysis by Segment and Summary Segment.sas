Proc tabulate data=wip.temp out=wip.proda1;
class tran_segm segment;
var deposits loans securities dda mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins hh DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt 
    MTG_amt HEQ_Amt ccs_Amt iln_amt IND_AMT sln_amt ;
table   hh*sum*f=comma12. (sum*f=comma12.0)*(deposits loans securities dda mms sav tda ira sec trs ins mtg heq card ILN ind sln sdb) 
		(pctsum<hh>*f=PCTPIC.)*(deposits loans securities dda mms sav tda ira sec trs ins mtg heq card ILN ind sln sdb )  
		(DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt )*sum='Total Balances'*f=dollar12. 
		(DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt )*mean='Avg. per Tot HH'*f=dollar12.
		, (tran_segm='Summary Group' ALL)*(segment='Segment' ALL) ALL;
keylabel PCTSUM = 'Product Penetration' ALL='Total';
format segment segfmt.;
run;

Proc tabulate data=wip.temp_contrib out=wip.contr1;
class tran_segm segment;
var deposits loans securities dda mms sav tda ira sec trs mtg heq card ILN IND sln ins hh DDA_CON MMS_CON sav_CON TDA_CON IRA_CON 
    sec_CON trs_CON MTG_CON HEQ_CON card_CON iln_CON IND_CON sln_CON ;
table hh*sum='HHs'*f=comma12. (sum='Prodcut HHs'*f=comma12.0)*(deposits loans securities dda mms sav tda ira sec trs ins mtg heq card ILN ind sln ) 
(DDA_CON MMS_CON sav_CON TDA_CON IRA_CON sec_CON trs_CON MTG_CON HEQ_CON caRD_CON iln_CON ind_CON sln_CON )*sum='Total Contrib'*f=dollar12. 
(DDA_CON MMS_CON sav_CON TDA_CON IRA_CON sec_CON trs_CON MTG_CON HEQ_CON cARD_CON iln_CON ind_CON sln_CON )*mean='Avg. per Tot. HH.'*f=dollar12.2
, (tran_segm='Summary Group' ALL)*(segment='Segment' ALL) ALL;
format segment segfmt.;
run;

data wip.temp_band;
set wip.temp;
keep hhid hh segment virtual_seg band tran_segm;
run;

Proc tabulate data=wip.temp_band out=wip.band1;
class tran_segm segment band;
var hh;
table (band )* (N*f=comma12. ), (tran_segm ALL)*(segment ALL) ALL /nocellmerge ;
/*table band * pctN<band>*f=PCTPIC., virtual_seg*(segment ALL) ;*/
/*table band * pctn<band*virtual_seg>*f=PCTPIC., virtual_seg*(segment ALL) ;*/
/*pctN<segment>*f=PCTPIC.;*/
format segment segfmt.;
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
		when (x ge 500000 and x lt 1000000) wealth='500M-1M'; 
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
keep hhid hh cqi: wealth virtual_seg segment tran_segm clv: assets;
run;

proc format library=SAS;
value wltamt 0-25000 = 1
             25000 <- 100000 = 2
			 100000 <- 250000 = 3
			 250000 <- 500000 = 4
			 500000 <- 1000000 = 5
			 1000000 <- 2000000 = 6
			 2000000 <- 3000000 = 7
			 3000000 <- 4000000 = 8
			 4000000 <- 5000000 = 9
			 5000000 <- 10000000 = 10
			 10000000 <- 15000000 = 11
			 15000000 <- 20000000 = 12
			 20000000 <- 25000000 = 13
			 25000000 <- high = 14;
value $wltband 'Up to 25M' = 'Up to 25M'
               '25-100M' = '25-100M'
			'100-250M'= '100-250M'
            	'250-500M' = '250-500M'
				'500M-1M' = '500M-1M'
				'1-2MM' = '1-2MM'
				'2-3MM' = '2-3MM'
				'3-4MM' = '3-4MM'
				'4-5MM' = '4-5MM'
				'5-10MM' = '5-10MM'
				'10-15MM' = '10-15MM'
				'15-20MM' = '15-20MM'
				'20-25MM' = '20-25MM'
				'25MM+' = '25MM+';
run;





proc tabulate data=wip.temp_1;
class tran_segm segment wealth;
var hh assets ;
table hh*f=comma12.0 assets*mean*f=dollar12.0 assets*sum='Total Assets'*f=dollar24. 
                     (assets*f=wltamt.)*pctsum<hh>='Percent' (assets)*pctsum<hh>='Percent'*f=wltamt. ,(tran_segm ALL)*(segment ALL) ALL /nocellmerge ;
format segment segfmt.;
run;



proc tabulate data=wip.temp_1;
class tran_segm segment wealth assets;
var hh  ;
table assets ,(tran_segm ALL)*(segment ALL) ALL /nocellmerge ;
format segment segfmt. wealth $wltband. assets wltamt.;
run;

proc tabulate data=wip.temp_1;
class tran_segm segment;
var hh assets clv: cqi: ;
table hh*f=comma12.0 assets*mean*f=dollar12.0 (clv_total clv_rem)*mean*f=dollar12.0 clv_rem_ten*mean*f=comma8.1 
      cqi*mean*f=comma5.1 (cqi_bp cqi_DD cqi_deb cqi_odl cqi_web )*pctsum<hh>,(tran_segm ALL)*(segment ALL) ALL /nocellmerge ;
format segment segfmt.;
run;


data wip.temp_demog;
merge wip.temp_1 (in=a keep=hhid hh virtual_seg segment tran_segm) data.demog_201111 (in=b);
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
class tran_segm segment;
var hh own_age child under_10 child_11_15 child_16_17  ;
table hh*f=comma12.0 own_age*mean*f=comma5.1 (child under_10 child_11_15 child_16_17)*pctsum<hh>*f=pctpic.  
      ,(tran_segm ALL)*(segment ALL) ALL /nocellmerge ;
format segment segfmt.;
run;


proc tabulate data=wip.temp_demog;
class tran_segm segment own_age ;
var hh ;
table  hh own_age 
      ,(tran_segm ALL)*(segment ALL) ALL /nocellmerge ;
format segment segfmt. own_age ageband.;
run;

proc tabulate data=wip.temp_demog;
class tran_segm segment income ;
var hh ;
table  hh income 
      ,(tran_segm ALL)*(segment ALL) ALL /nocellmerge ;
format segment segfmt. income incmfmt.;
run;


data wip.chk_merged;
merge wip.temp (in=a keep=hhid hh segment virtual_seg tran_segm) wip.temp_chk_2;
by hhid;
if a;
run;


proc tabulate data=wip.chk_merged;
class segment tran_segm;
var hh R:;
table hh*sum*f=comma12.0 (R:)*N (R:)*pctN<hh> ,(tran_segm ALL)*(segment ALL) ALL /nocellmerge;
format segment segfmt.;
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
vpos mpos atmo atmt br_tr vru web1 bp1 sms1 wap1 fico1 fworks1 chk1 tran_segm; 
run;

Proc tabulate data=wip.temp_tran out=wip.tran1;
class tran_segm segment;
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
         , (tran_segm='Transaction Group' ALL)*(segment='Segment' ALL) ALL;
keylabel ALL='Total';
format segment segfmt.; 
run;

proc tabulate data=virtual.promo_2011_clean;
class tran_segm segment;
var email branch DM tbc promos XXX CC DDA DEB LN MTG HEQ WEB SEC DEP br_tr_num hh;
table (hh='HHs' promos='Promos')*sum='Count'*f=comma12.0 ,(tran_segm ALL)*(segment ALL) all;
table (email='Emails Sent' branch='Branch Calls' DM='Mail Pieces Send' tbc='TBC Calls' br_tr_num='Branch Visits')*Sum='Number of Contacts'*f=comma12.
      (DEP='Deposits' DDA='Checking' DEB='Debit Card' WEB='Web Banking' CC='Card' LN='Loans' MTG='Mortgage' HEQ='Home Equity'  SEC='Investments' 
       XXX='Other')*Sum='Number of Leads'*f=comma12.
      ,(tran_segm ALL)*(segment ALL) ALL;
format segment segfmt.;
keylabel ALL='Total';
run;


proc tabulate data=wip.temp_1;
class tran_segm virtual_seg segment wealth assets;
var hh  ;
table assets ,(tran_segm ALL)*(segment ALL) ALL
;
format segment segfmt. wealth $wltband. assets wltamt.;
run;

filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\rm.txt';
data temp_rm;
length hhid $ 9 RM $ 1 tenure 8;
infile mydata DLM='09'x firstobs=2 lrecl=4096 dsd ;
input hhid $ RM tenure;
tenure_yr = divide(tenure,365);
run;

data temp;
merge data.main_201111 (in=a) temp_rm (in=b);
by hhid;
if a and b;
run;

data data.main_201111;
set temp;
run;

PROC FORMAT library=sas;
value tenureband   0-1 = 'Up to 1 Yr'
                    1<-2 = '1 to 2 Yrs'
					2<-3 = '2 to 3 Years'
					3<-5 = '5 to 5 Years'
					5<-7 = '5 to 7 Years'
					7<-10 = '7 to 10 Years'
					10<-15 = '10 to 15 Years'
					15<-high = '15+';
run;

proc tabulate data=wip.temp;
var   hh;
class  tenure_yr rm tran_segm virtual_seg segment ;
table hh*sum='HHs' (rm tenure_yr='Tenure')*(n='HHs') , (tran_segm ALL)*(segment ALL) ALL /nocellmerge;
format segment segfmt. tenure_yr tenureband.;
run;

proc tabulate data=wip.temp;
var   hh;
class  tenure_yr rm tran_segm virtual_seg segment ;
table hh*sum='HHs' (rm tenure_yr='Tenure')*(n='HHs') , (virtual_seg ALL)*(segment ALL) ALL /nocellmerge;
format segment segfmt. tenure_yr tenureband.;
run;




