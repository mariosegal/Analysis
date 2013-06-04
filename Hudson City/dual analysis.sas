proc format;
value hudsonseg (notsorted)
   1 = 'Building Their Future'
2 = 'Mainstream Family'
4 = 'Mass Affluent Family'
3 = 'Mainstream Retired'
5 = 'Mass Affluent Retired'
6 = 'Unable to Code';
run;


proc format;
value  prods (notsorted multilabel)
	      1 = 'Single'
	 
		2-high = 'Multi';
run;

proc format ;
value ixi (notsorted)
		low - 100000 = 'Up to $100M'
		100000 -< 250000 = '$100M to 250M'
		250000 -< 500000 = '$250M to 500M'
		500000 -< 750000 = '$500M to 750M'
		750000 -< 1000000 = '$750M to 1MM'
		1000000 -< 2000000 = '$1MM to 2MM'
		2000000 - high = 'Over $2MM'
		. = 'Unknown';
run;


proc contents data=hudson.dual_hh varnum short;
run;

data hudson.dual_hh;
set hudson.dual_hh;
prods_mtb = sum(DDA_mtb, MMS_mtb,  SAV_mtb, TDA_mtb, IRA_mtb, MTG_mtb, HEQ_mtb, ILN_mtb, SEC_mtb, INS_mtb,SDB_mtb, ccs_mtb, trs_mtb);
run;

data safety;
set hudson.dual_hh;
run;

%null_to_zero(dataset=hudson.dual_hh)

*##########################################################################################################;
*########################            ANALYSIS PART              ###########################################;
*##########################################################################################################;

title 'Dual HH Analysis';
proc tabulate data=hudson.dual_hh missing;
class segment products distance prods_mtb state IXI_Assets;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 mtx1 hh  
    DDA_amt TDA_amt IRA_amt SAV_amt MTG_amt MMS_amt ILN_amt HEQ_amt CCS_amt MTX_amt
	  
	DDA_mtb  HEQ_mtb IRA_mtb SAV_mtb  MTG_mtb TDA_mtb  MMS_mtb ILN_mtb SEC_mtb INS_mtb 
	DDA_amt_mtb  HEQ_amt_mtb IRA_amt_mtb SAV_amt_mtb  MTG_amt_mtb TDA_amt_mtb  MMS_amt_mtb ILN_amt_mtb SEC_amt_mtb ;
/*title 'Hudson Product Ownership';*/
table segment all='HHs', N*f=comma12. (dda1 mms1 sav1 tda1 ira1 mtg1 mtx1 heq1 iln1)*rowpctsum<hh>*f=pctfmt. / nocellmerge misstext="0";
/*title "Hudson Balances per Product HH ($ 000's)";*/
table segment all='HHs',N*f=comma12. (DDA_amt*rowpctsum<dda1> MMS_amt*rowpctsum<mms1> SAV_amt*rowpctsum<sav1> TDA_amt*rowpctsum<tda1> IRA_amt*rowpctsum<ira1>  
                            MTG_amt*rowpctsum<mtg1>  MTX_amt*rowpctsum<mtx1> HEQ_amt*rowpctsum<heq1> ILN_amt*rowpctsum<iln1>)*f=pctdollm. / nocellmerge misstext="$0.0";
/*title 'MTB Product Ownership';*/
table segment all='HHs',N*f=comma12. (DDA_mtb MMS_mtb  SAV_mtb TDA_mtb IRA_mtb MTG_mtb HEQ_mtb ILN_mtb SEC_mtb INS_mtb)*rowpctsum<hh>*f=pctfmt. / nocellmerge misstext="0";
/*title "MTB Balances per Product HH ($ 000's)";*/
table segment all='HHs',N*f=comma12. (DDA_amt_mtb*rowpctsum<DDA_mtb> MMS_amt_mtb*rowpctsum<mms_mtb>  SAV_amt_mtb*rowpctsum<sav_mtb> TDA_amt_mtb*rowpctsum<tDA_mtb>
                            IRA_amt_mtb*rowpctsum<irA_mtb> MTG_amt_mtb*rowpctsum<mtg_mtb> HEQ_amt_mtb*rowpctsum<heq_mtb> ILN_amt_mtb*rowpctsum<iln_mtb> 
                            SEC_amt_mtb*rowpctsum<sec_mtb>)*f=pctdollm. / nocellmerge misstext="$0.0";
/*Title 'Demographics';*/
table segment all='HHs',distance*N*f=comma12. distance*rowpctN*f=pctfmt.  / nocellmerge misstext="0.0%";
table segment all='HHs',products='Prods Hudson'*N*f=comma12. products='Prods Hudson'*rowpctN*f=pctfmt.  / nocellmerge misstext="0.0";
table segment all='HHs' ,prods_mtb='Prods MTB'*N*f=comma12. prods_mtb='Prods MTB'*rowpctN*f=pctfmt.  / nocellmerge misstext="0.0";
table segment all='HHs' ,state*N*f=comma12. state*rowpctN*f=pctfmt.  / nocellmerge misstext="0.0";
table segment all='HHs',ixi_assets*N*f=comma12.  ixi_assets*rowpctN*f=pctfmt.  / nocellmerge misstext="0.0";
format segment hudsonseg. distance distfmt. products prods. prods_mtb prods. ixi_assets ixi.;
keylabel rowpctsum=" " N = " " sum=" " rowpctN=" ";
run;


*   cross_ownership analysis;

proc tabulate data=hudson.dual_hh out=duals missing;
class segment products distance prods_mtb state IXI_Assets;
class dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 mtx1   
	DDA_mtb  HEQ_mtb IRA_mtb SAV_mtb  MTG_mtb TDA_mtb  MMS_mtb ILN_mtb SEC_mtb INS_mtb ind_mtb;
var hh dda_amt_both sav_amt_both mms_amt_both ira_amt_both tda_amt_both mtg_amt_both heq_amt_both iln_amt_both sec_amt_both;
table (dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1  mtx1) ,  
      (dda_mtb MMS_mtb SAV_mtb TDA_mtb IRA_mtb  MTG_mtb HEQ_mtb ILN_mtb  SEC_mtb INS_mtb )*(
      (hh dda_amt_both sav_amt_both mms_amt_both ira_amt_both tda_amt_both mtg_amt_both heq_amt_both iln_amt_both sec_amt_both)*sum*f=comma18.)
	/ nocellmerge misstext='0';
run;


data duals1;
set duals;
array hudson_prods{*} dda1 mms1 sav1 tda1 ira1 mtg1 mtx1 heq1 iln1  ;
array hudson_names{9}  $ 3 _temporary_ ('dda' ,'mms' ,'sav' ,'tda' ,'ira' ,'mtg' ,'mtx' ,'heq' ,'iln')  ;
array mtb_prods{*} DDA_mtb  MMS_mtb SAV_mtb TDA_mtb IRA_mtb MTG_mtb HEQ_mtb ILN_mtb  SEC_mtb INS_mtb;
array  mtb_names{10} $ 3 _temporary_ ('dda', 'mms' ,'sav', 'tda', 'ira' ,'mtg' ,'heq', 'iln'  ,'sec', 'ins') ;

	keep = 0; keep1= 0;
	do i = 1 to dim(hudson_prods);
		if hudson_prods{i} eq 1 then do;
			keep=1;
			Hudson = hudson_names{i};
		end;
	end;
	do i = 1 to dim(mtb_prods);
		if mtb_prods{i} eq 1 then do;
			keep1=1;
			MTB = mtb_names{i};
		end;
	end;
	if keep and keep1 then output;

keep hudson mtb hh_sum dda_amt_both_sum sav_amt_both_sum mms_amt_both_sum ira_amt_both_sum tda_amt_both_sum mtg_amt_both_sum heq_amt_both_sum iln_amt_both_sum sec_amt_both_sum;
/*	rename N=HH;*/
run;


proc format ;
value $ order (notsorted)		'dda'  = 'Checking' 
					'mms' = 'Money Market'
					'sav' = 'Savings' 
					'tda' = 'Time Deposits' 
					'ira' = 'IRAs'
					'mtg' = 'Mortgage (Svcd)'
					'mtx' = 'Mortgage (Non Svcd)'
					'heq' = 'Home Equity'
					'iln' = 'Inst. Loan'
					'ind' = 'Ind. Loan'
					'sec' = 'Securities'
					'ins' = 'Insurance'
					'All' = 'Total';
value $ hud_names 'dda'  = 1 
					'mms' = 2
					'sav' = 3 
					'tda' = 4 
					'ira' = 5
					'mtg' = 6
					'heq' = 7
					'iln' = 8
					'All' = 9;
value $ mtb_names 'dda'  = 1 
					'mms' = 2
					'sav' = 3 
					'tda' = 4 
					'ira' = 5
					'mtg' = 6
					'heq' = 7
					'iln' = 8
					'sec' = 9
					'ins' = 10
					'All' = 11;
run;

proc sort data=duals1;
by Hudson MTB;
run;




proc tabulate data=hudson.dual_hh out=rows missing;
class dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 mtx1;
var hh dda_amt_both sav_amt_both mms_amt_both ira_amt_both tda_amt_both mtg_amt_both heq_amt_both iln_amt_both sec_amt_both;
table (hh dda_amt_both sav_amt_both mms_amt_both ira_amt_both tda_amt_both mtg_amt_both heq_amt_both iln_amt_both sec_amt_both)*sum,
(dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 mtx1);
run;


data rows1;
set rows;
array hudson_prods{*} dda1 mms1 sav1 tda1 ira1 mtg1 mtx1 heq1 iln1  ;
array hudson_names{9}  $ 3 _temporary_ ('dda' ,'mms' ,'sav' ,'tda' ,'ira' ,'mtg' ,'mtx' ,'heq' ,'iln')  ;

	keep = 0; 
	do i = 1 to dim(hudson_prods);
		if hudson_prods{i} eq 1 then do;
			keep=1;
			Hudson = hudson_names{i};
		end;
	end;
	mtb='All';
	if keep  then output;

keep hh_sum hudson mtb dda_amt_both_sum sav_amt_both_sum mms_amt_both_sum ira_amt_both_sum tda_amt_both_sum mtg_amt_both_sum heq_amt_both_sum iln_amt_both_sum sec_amt_both_sum;
/*	rename N=HH;*/
run;

proc sort data=rows1;
by hudson;
run;

proc summary data=rows1;
by hudson;
output out=rows2
		sum(hh_sum)=hh_sum
		sum(dda_amt_both_sum)=dda_amt_both_sum
		sum(sav_amt_both_sum)=sav_amt_both_sum  
		sum(mms_amt_both_sum)=mms_amt_both_sum 
		sum(ira_amt_both_sum)=ira_amt_both_sum 
		sum(tda_amt_both_sum)=tda_amt_both_sum
		sum(mtg_amt_both_sum)=mtg_amt_both_sum 
		sum(heq_amt_both_sum)=heq_amt_both_sum 
		SUM(iln_amt_both_sum)=iln_amt_both_sum
		SUM(sec_amt_both_sum)=sec_amt_both_sum;
run;

data rows2;
set rows2;
mtb = 'All';
x = put(hudson,$hud_names.);
drop _freq_ _type_;
run;

proc sort data=rows2;
by x;
run;

proc tabulate data=hudson.dual_hh out=cols missing;
class dda_mtb MMS_mtb SAV_mtb TDA_mtb IRA_mtb  MTG_mtb HEQ_mtb ILN_mtb ind_mtb SEC_mtb INS_mtb;
var hh dda_amt_both sav_amt_both mms_amt_both ira_amt_both tda_amt_both mtg_amt_both heq_amt_both iln_amt_both sec_amt_both;
table (hh dda_amt_both sav_amt_both mms_amt_both ira_amt_both tda_amt_both mtg_amt_both heq_amt_both iln_amt_both sec_amt_both)*sum, 
(dda_mtb MMS_mtb SAV_mtb TDA_mtb IRA_mtb  MTG_mtb HEQ_mtb ILN_mtb  SEC_mtb INS_mtb);
run;



data cols1;
set cols;

array mtb_prods{*} DDA_mtb  MMS_mtb SAV_mtb TDA_mtb IRA_mtb MTG_mtb HEQ_mtb ILN_mtb  SEC_mtb INS_mtb;
array  mtb_names{10} $ 3 _temporary_ ('dda', 'mms' ,'sav', 'tda', 'ira' ,'mtg' ,'heq', 'iln'  ,'sec', 'ins') ;

	keep1= 0;
	do i = 1 to dim(mtb_prods);
		if mtb_prods{i} eq 1 then do;
			keep1=1;
			MTB = mtb_names{i};
		end;
	end;
	hudson='All';
	if keep1 then output;

keep hh_sum mtb hudson mtb dda_amt_both_sum sav_amt_both_sum mms_amt_both_sum ira_amt_both_sum tda_amt_both_sum mtg_amt_both_sum heq_amt_both_sum iln_amt_both_sum sec_amt_both_sum;
/*	rename N=HH;*/
run;

proc sort data=cols1;
by mtb;
run;

proc summary data=cols1;
by mtb;
output out=cols2
		sum(hh_sum)=hh_sum
		sum(dda_amt_both_sum)=dda_amt_both_sum
		sum(sav_amt_both_sum)=sav_amt_both_sum  
		sum(mms_amt_both_sum)=mms_amt_both_sum 
		sum(ira_amt_both_sum)=ira_amt_both_sum 
		sum(tda_amt_both_sum)=tda_amt_both_sum
		sum(mtg_amt_both_sum)=mtg_amt_both_sum 
		sum(heq_amt_both_sum)=heq_amt_both_sum 
		SUM(iln_amt_both_sum)=iln_amt_both_sum
		SUM(sec_amt_both_sum)=sec_amt_both_sum;
run;

data cols2;
length x 8;
set cols2;
hudson = 'All';
x = put(mtb,$mtb_names.);
drop _freq_ _type_;
run;

proc sort data=cols2;
by x;
run;


proc sql;
select hh_sum into :hudson1-:hudson999 from rows2;
select hh_sum into :mtb1-:mtb999 from cols2;
select count(*) into :total from hudson.dual_hh;
select sum(dda_amt_both) , sum(sav_amt_both) ,  sum(mms_amt_both) , sum(ira_amt_both), sum(tda_amt_both) ,
       sum(mtg_amt_both) , sum(heq_amt_both), sum(iln_amt_both) , sum(sec_amt_both) into :dda,:sav,:mms,:ira,:tda,:mtg,:heq,:iln,:sec from hudson.dual_hh;
quit;

data combined;
set duals1 rows2 (drop=x) cols2(drop=x) end=eof;
if eof then do;
	Hudson = "All";
	MTB = "All";
	hh_sum = &total;
	dda_amt_both_sum=&dda;
	mms_amt_both_sum=&mms;
	sav_amt_both_sum=&sav;
	tda_amt_both_sum=&tda;
	ira_amt_both_sum=&ira;
	mtg_amt_both_sum=&mtg;
	heq_amt_both_sum=&heq;
	sec_amt_both_sum=&sec;
	iln_amt_both_sum=&iln;
end;
run;

%put _user_;
data combined;
set combined;
array hudson_denom{8}   _temporary_  (&hudson1,&hudson2,&hudson3,&hudson4,&hudson5,&hudson6,&hudson7,&hudson8);
array  mtb_denom{10}  _temporary_ (&mtb1,&mtb2,&mtb3,&mtb4,&mtb5,&mtb6,&mtb7,&mtb8,&mtb9,&mtb10) ;

hud_num = put(hudson,$hud_names.);
mtb_num = put(mtb,$mtb_names.);

if hud_num ne 9 and mtb_num ne 11 then do;
	*body of table;
	percent = divide(hh_sum,hudson_denom{hud_num});
	divisor = hudson_denom{hud_num};
end;
else if hud_num eq 9 and mtb_num ne 11 then do;
	* total row for hudson (y axis);
	percent = divide(hh_sum,&total);
	divisor = &total;
end;
else if hud_num ne 9 and mtb_num eq 11 then do;
	* total row for mtb (x axis);
	percent = divide(hh_sum,&total);
	divisor = &total;
end;
else if hud_num eq 9 and mtb_num eq 11 then do;
	* total overall ;
	percent = divide(hh_sum,&total);
	divisor = &total;
end;
percent1 = divide(hh_Sum,&total);
dda = dda_amt_both_sum / hh_sum;
mms = mms_amt_both_sum / hh_sum;
sav = sav_amt_both_sum / hh_sum;
tda = tda_amt_both_sum / hh_sum;
ira = ira_amt_both_sum / hh_sum;
mtg = mtg_amt_both_sum / hh_sum;
heq = heq_amt_both_sum / hh_sum;
iln = iln_amt_both_sum / hh_sum;
sec = sec_amt_both_sum / hh_sum;
ins=0;
run;

proc tabulate data=combined ORDER=DATA missing;
class hudson mtb / preloadfmt;	
var hh_sum percent dda mms sav tda ira mtg heq iln sec percent1;
table hudson='Hudson Products' , ( mtb='M&T Products' )*( sum*hh_sum=' '*f=comma12.)  / misstext="0" nocellmerge;
table hudson='Hudson Products' , ( mtb='M&T Products' )*( sum*percent=' '*f=percent8.1)  / misstext="0.0%" nocellmerge;
table hudson='Hudson Products' , ( mtb='M&T Products' )*( sum*percent1=' '*f=percent8.1)  / misstext="0.0%" nocellmerge;

table hudson='Hudson Products' , ( mtb='M&T Products' )*( sum*dda*f=dollar12.)  / misstext="0" nocellmerge;
table hudson='Hudson Products' , ( mtb='M&T Products' )*( sum*mms*f=dollar12.)  / misstext="0" nocellmerge;
table hudson='Hudson Products' , ( mtb='M&T Products' )*( sum*sav*f=dollar12.)  / misstext="0" nocellmerge;
table hudson='Hudson Products' , ( mtb='M&T Products' )*( sum*tda*f=dollar12.)  / misstext="0" nocellmerge;
table hudson='Hudson Products' , ( mtb='M&T Products' )*( sum*ira*f=dollar12.)  / misstext="0" nocellmerge;
table hudson='Hudson Products' , ( mtb='M&T Products' )*( sum*mtg*f=dollar12.)  / misstext="0" nocellmerge;
table hudson='Hudson Products' , ( mtb='M&T Products' )*( sum*heq*f=dollar12.)  / misstext="0" nocellmerge;
table hudson='Hudson Products' , ( mtb='M&T Products' )*( sum*iln*f=dollar12.)  / misstext="0" nocellmerge;
table hudson='Hudson Products' , ( mtb='M&T Products' )*( sum*sec*f=dollar12.)  / misstext="0" nocellmerge;

format hudson mtb $order.;
keylabel sum=' ' rowpctsum=' ';
run;

data combined1;
set combined;
group = 'dual';
keep hudson mtb percent group;
run;

*panel stuff is on panel for dual.sas;


*calc avg at each bank for those who have aT BOTH;

PROC SQL;
select sum(hh) as dda,sum(dda_amt_mtb) as mtb,sum(dda_amt) as hudson from hudson.dual_hh where dda1 eq 1 and dda_mtb eq 1;
select sum(hh) as mms,sum(mms_amt_mtb) as mtb,sum(mms_amt) as hudson from hudson.dual_hh where mms1 eq 1 and mms_mtb eq 1;
select sum(hh) as sav,sum(sav_amt_mtb) as mtb,sum(sav_amt) as hudson from hudson.dual_hh where sav1 eq 1 and sav_mtb eq 1;
select sum(hh) as tda ,sum(tda_amt_mtb) as mtb,sum(tda_amt) as hudson from hudson.dual_hh where tda1 eq 1 and tda_mtb eq 1;
select sum(hh) as ira,sum(ira_amt_mtb) as mtb,sum(ira_amt) as hudson from hudson.dual_hh where ira1 eq 1 and ira_mtb eq 1;
select sum(hh) as mtg,sum(mtg_amt_mtb) as mtb,sum(mtg_amt) as hudson from hudson.dual_hh where mtg1 eq 1 and mtg_mtb eq 1;
select sum(hh) as heq,sum(heq_amt_mtb) as mtb,sum(heq_amt) as hudson from hudson.dual_hh where heq1 eq 1 and heq_mtb eq 1;
select sum(hh) as iln,sum(iln_amt_mtb) as mtb,sum(iln_amt) as hudson from hudson.dual_hh where iln1 eq 1 and iln_mtb eq 1;
select sum(hh) as sec,sum(sec_amt_mtb) as mtb as hudson from hudson.dual_hh where sec_mtb eq 1;
quit;



*calc avg bal across 2 banks;
data hudson.dual_hh;
set hudson.dual_hh;
dda_amt_both = sum(dda_amt,dda_amt_mtb);
sav_amt_both = sum(sav_amt,sav_amt_mtb);
mms_amt_both = sum(mms_amt,mms_amt_mtb);
tda_amt_both = sum(tda_amt,tda_amt_mtb);
ira_amt_both = sum(ira_amt,ira_amt_mtb);
mtg_amt_both = sum(mtg_amt,mtg_amt_mtb);
heq_amt_both = sum(heq_amt,heq_amt_mtb);
iln_amt_both = sum(iln_amt,iln_amt_mtb);
sec_amt_both = sum(sec_amt_mtb);
drop sec_amt;
run;

*after this ai modified c ode above ;


*/
area_group pseudo_hh CON BUS INT con1 bus1 int1 DDA TDA IRA SAV MTG MMS ILN HEQ CCS MTX dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 mtx1 _LABEL_ DDA_amt 
TDA_amt IRA_amt SAV_amt MTG_amt MMS_amt ILN_amt HEQ_amt CCS_amt MTX_amt products accts products1 hh age Assets segment STATE snl_key distance open LAT 
LONG cqi_web cqi_dd cqi_bp cqi_debit cqi_odl cqi zip_clean zip COUNTYNM IXI_Assets IXI_Annuity IXI_Bond IXI_Deposits IXI_MutualFund IXI_OtherAssets 
IXI_StockAssets IXI_CD IXI_IntChecking IXI__MMS IXI_NonIntChecking IXI_OthChecking IXI_Savings abbas_grp active dual prods DDA_mtb DEB_mtb HEQ_mtb 
IRA_mtb SAV_mtb WEB_mtb MTG_mtb TDA_mtb TRS_mtb CCS_mtb MMS_mtb ILN_mtb SEC_mtb SDB_mtb ATM_mtb CLN_mtb CLS_mtb INS_mtb SLN_mtb MCC_mtb HBK_mtb DDA_amt_mtb 
DEB_amt_mtb HEQ_amt_mtb IRA_amt_mtb SAV_amt_mtb WEB_amt_mtb MTG_amt_mtb TDA_amt_mtb TRS_amt_mtb CCS_amt_mtb MMS_amt_mtb ILN_amt_mtb SEC_amt_mtb SDB_amt_mtb 
ATM_amt_mtb CLN_amt_mtb CLS_amt_mtb INS_amt_mtb SLN_amt_mtb MCC_amt_mtb HBK_amt_mtb 
/*;


