proc format;
value  prods (notsorted )
	      1 = 'Single'
		2-high = 'Multi';

value $ state (notsorted) 'CT' = 'CT'
              'NY' = 'NY'
			  'NJ' = 'NJ'
			other = 'Other';
run;

proc format;
value hudsonseg (notsorted)
   1 = 'Building Their Future'
2 = 'Mainstream Family'
4 = 'Mass Affluent Family'
3 = 'Mainstream Retired'
5 = 'Mass Affluent Retired'
6, . = 'Unable to Code';
run;

proc format;
value mtbseg (notsorted)
   1 = 'Building Their Future'
3 = 'Mainstream Family'
2 = 'Mass Affluent Family'
4 = 'Mass Affluent Family'
5 = 'Mainstream Retired'
6 = 'Mass Affluent Retired'
Other = 'Unable to Code';
value $bta (notsorted multilabel)
	'NJ' = 'New Jersey'
	'Upstate' = 'Upstate'
	'LI' = 'Long Island'
	'CT' = 'Connecticut'
	'NJ' = 'NJ/SI'
	'Staten' = 'NJ/SI'
	'Upstate' = 'NY xSI'
	'LI' = 'NY xSI'
	'Upstate' = 'NY'
	'Staten' = 'NY'
	'LI' = 'NY'
	'CT','LI','Staten','NJ','Upstate' = 'Footprint'
	other = 'Other';
value $bta_a (notsorted multilabel)
	'NJ' = 'New Jersey'
	'Upstate' = 'NY'
	'LI' = 'NY'
	'Staten' = 'NY'
	'CT' = 'Connecticut'
	'CT','LI','Staten','NJ','Upstate' = 'Footprint'
	other = 'Other';
run;



title 'Hudson City Wealth Distribution';
proc tabulate data=hudson.hudson_hh order=data missing;
where external ne 1 and products ne .;
class bta_group segment products adj_tot state products / preloadfmt mlf;
table  (bta_group all)*(products all)*(segment all), N*f=comma12. (adj_tot ALL)*N*f=comma12. (adj_tot ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
format products prods. adj_tot wltamt.  segment hudsonseg. bta_group $bta.;
run;

*note: I did not do segments separately as the distribution could be gotten from above in excel;

title 'Hudson City Product Ownership and Balances';
proc tabulate data=hudson.hudson_hh order=data missing;
where external ne 1 and products ne .;
class bta_group segment products  / preloadfmt mlf;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt hh;
table (bta_group all)*(products all)*(segment all), (hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*sum='HHs'*f=comma12.
													(hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*rowpctsum<hh>='Penetration'*f=pctfmt.
													(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt)*sum='Balances'*f=dollar24.
                                                    (dda_amt*rowpctsum<dda1> mms_amt*rowpctsum<mms1> sav_amt*rowpctsum<sav1> tda_amt*rowpctsum<tda1> ira_amt*rowpctsum<ira1> 
                                                     mtg_amt*rowpctsum<mtg1> heq_amt*rowpctsum<heq1> iln_amt*rowpctsum<iln1> ccs_amt*rowpctsum<ccs1>)*f=pctdoll.
													/ nocellmerge misstext='0';
format products prods. segment hudsonseg. bta_group $bta.;
run;


*WEALTH ANALYSIS FOR THE NEWLY DEFINED FOOTPRINT;

LIBNAME ixi ODBC DSN=IXI user=reporting_user pw=Reporting2 schema=dbo;

proc sort data=hudson.Bta_for_oppty_3mile ;
by zip;
run;

data temp_assets_1;
merge ixi.mtb_postal (in=a rename=(regionzipcode=zip)  where=(cycleid=201206)) hudson.Bta_for_oppty_3mile(in=b) end=eof;
retain miss;
by zip;
if b then output;
if b and not a then miss+1;
if eof then do;
	put "WARNING: Records in b file not on A = " miss;
end;
drop miss;
run;


data temp_assets_2;
merge ixi.mtbexp_postal (in=a rename=(regionzipcode=zip)  where=(cycleid=201206)) hudson.Bta_for_oppty_3mile(in=b where=(state='CT')) end=eof;
retain miss;
by zip;
if b then output;
if b and not a then miss+1;
if eof then do;
	put "WARNING: Records in b file not on A = " miss;
end;
drop miss;
run;

data temp_assets;
set temp_assets_1 (where=(state ne 'CT')) temp_assets_2;
run;

data temp_tiers;
merge ixi.mtb_tiers_postal (in=a rename=(regionzipcode=zip)  where=(cycleid=201206)) hudson.Bta_for_oppty_3mile(in=b) end=eof;
retain miss;
by zip;
if b then output;
if b and not a then miss+1;
if eof then do;
	put "WARNING: Records in b file not on A = " miss;
end;
drop miss;
run;

data temp_tiers;
set temp_tiers;
under100_hh = T1To2p5kHouseholds +T2p5kTo10kHouseholds +T10kTo25kHouseholds +T25kTo50kHouseholds +T50kTo75kHouseholds +T75kTo100kHouseholds;
_100to1MM_hh = T100kTo250kHouseholds + T250kTo500kHouseholds +T500kTo1mHouseholds;
_1MMto3MM_hh = T1mTo1P5mHouseholds +T1P5mTo2mHouseholds +T2mTo3mHouseholds;
over3MM_hh = T3mTo5mHouseholds+ T5mTo7P5mHouseholds +T7P5mTo10mHouseholds +T10mTo15mHouseholds +T15mTo25mHouseholds +T25mPlusHouseholds;
under100_doll= T1To2p5kDollars +T2p5kTo10kDollars +T10kTo25kDollars +T25kTo50kDollars +T50kTo75kDollars +T75kTo100kDollars ;
_100to1MM_DOLL = T100kTo250kDollars+T250kTo500kDollars + T500kTo1mDollars;
_1MMto3MM_doll= T1mTo1P5mDollars +T1P5mTo2mDollars +T2mTo3mDollars ;
over3MM_doll = T3mTo5mDollars +T5mTo7P5mDollars +T7P5mTo10mDollars +T10mTo15mDollars +T15mTo25mDollars +T25mPlusDollars;
asset_hh = under100_hh+ _100to1MM_hh +_1MMto3MM_hh+ over3MM_hh+ zeroHouseholds;
run;

proc tabulate data=temp_assets missing order=data;
class bta_group /  mlf;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
	OtherChecking Savings MutualFunds Other Stocks;
var TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
	InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
	MutualFundsHouseholds OtherHouseholds StocksHouseholds;
table bta_group all, sum*(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
							InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds 
							SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds)*f=comma12.
						(TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
							OtherChecking Savings MutualFunds Other Stocks)*rowpctsum<TotalHouseholdsWithAssets>*f=pctdoll.
			            / nocellmerge misstext='0';
format bta_group $bta.;
run;


proc tabulate data=temp_tiers missing order=data;
class bta_group /  mlf;
var zeroHouseholds under100_hh _100to1MM_hh _1MMto3MM_hh over3MM_hh zerodollars under100_doll _100to1MM_DOLL _1MMto3MM_doll over3MM_doll  asset_hh;
table bta_group all, sum*(zeroHouseholds under100_hh _100to1MM_hh _1MMto3MM_hh over3MM_hh asset_hh='All')*f=comma12.
                     (zeroHouseholds under100_hh _100to1MM_hh _1MMto3MM_hh over3MM_hh)*rowpctsum<asset_hh>*f=pctfmt.
					 (zerodollars under100_doll _100to1MM_DOLL _1MMto3MM_doll over3MM_doll)*rowpctsum<asset_hh>*f=pctdoll.
			         / nocellmerge misstext='0';
format bta_group $bta.;
run;



*re do M&T Oppty for all CBRs;

proc sort data=branch.Cbr_by_zip_2012 ;
by zip;
run;

data temp_assets_mtb;
length zip_num 8;
merge ixi.mtb_postal (in=a rename=(regionzipcode=zip)  where=(cycleid=201206)) branch.Cbr_by_zip_2012 (in=b drop =state) end=eof;
retain miss;
by zip;
zip_num = zip;
if b then output;
if b and not a then miss+1;
if eof then do;
	put "WARNING: Records in cbr file not on ixi = " miss;
end;
drop miss;
format zip_num z5.;
run;

data temp_assets_mtb;
merge temp_assets_mtb (in=a) sashelp.zipcode (keep=zip countynm zip_class statecode in=b rename=(zip=zip_num)) end=eof;
retain miss;
by zip_num;
if a then output;
if a and not b then miss+1;
if eof then do;
	put "WARNING: Records in mtb file not on sashelp.zipcode = " miss;
end;
drop miss;
run;


data temp_tiers_mtb;
length zip_num 8;
merge ixi.mtb_tiers_postal (in=a rename=(regionzipcode=zip)  where=(cycleid=201206)) branch.Cbr_by_zip_2012 (in=b drop =state) end=eof;
retain miss;
by zip;
zip_num = zip;
if b then output;
if b and not a then miss+1;
if eof then do;
	put "WARNING: Records in cbr file not on ixi = " miss;
end;
drop miss;
format zip_num z5.;
run;

data temp_tiers_mtb;
merge temp_tiers_mtb (in=a) sashelp.zipcode (keep=zip countynm zip_class statecode in=b rename=(zip=zip_num)) end=eof;
retain miss;
by zip_num;
if a then output;
if a and not b then miss+1;
if eof then do;
	put "WARNING: Records in mtb file not on sashelp.zipcode = " miss;
end;
drop miss;
run;

data temp_tiers_mtb;
set temp_tiers_mtb;
under100_hh = T1To2p5kHouseholds +T2p5kTo10kHouseholds +T10kTo25kHouseholds +T25kTo50kHouseholds +T50kTo75kHouseholds +T75kTo100kHouseholds;
_100to1MM_hh = T100kTo250kHouseholds + T250kTo500kHouseholds +T500kTo1mHouseholds;
_1MMto3MM_hh = T1mTo1P5mHouseholds +T1P5mTo2mHouseholds +T2mTo3mHouseholds;
over3MM_hh = T3mTo5mHouseholds+ T5mTo7P5mHouseholds +T7P5mTo10mHouseholds +T10mTo15mHouseholds +T15mTo25mHouseholds +T25mPlusHouseholds;
under100_doll= T1To2p5kDollars +T2p5kTo10kDollars +T10kTo25kDollars +T25kTo50kDollars +T50kTo75kDollars +T75kTo100kDollars ;
_100to1MM_DOLL = T100kTo250kDollars+T250kTo500kDollars + T500kTo1mDollars;
_1MMto3MM_doll= T1mTo1P5mDollars +T1P5mTo2mDollars +T2mTo3mDollars ;
over3MM_doll = T3mTo5mDollars +T5mTo7P5mDollars +T7P5mTo10mDollars +T10mTo15mDollars +T15mTo25mDollars +T25mPlusDollars;
asset_hh = under100_hh+ _100to1MM_hh +_1MMto3MM_hh+ over3MM_hh+ zeroHouseholds;
run;

Title 'M&T Footprint Market';
proc tabulate data=temp_assets_mtb missing order=data;
class cbr_zip /  preloadfmt;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
	OtherChecking Savings MutualFunds Other Stocks;
var TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
	InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
	MutualFundsHouseholds OtherHouseholds StocksHouseholds;
table cbr_zip all, sum*(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
							InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds 
							SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds)*f=comma12.
						(TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
							OtherChecking Savings MutualFunds Other Stocks)*rowpctsum<TotalHouseholdsWithAssets>*f=pctdoll.
			            / nocellmerge misstext='0';
format cbr_zip cbr2012fmt.;
run;


proc tabulate data=temp_tiers_mtb missing order=data;
class cbr_zip /  preloadfmt;
var zeroHouseholds under100_hh _100to1MM_hh _1MMto3MM_hh over3MM_hh zerodollars under100_doll _100to1MM_DOLL _1MMto3MM_doll over3MM_doll  asset_hh;
table cbr_zip all, sum*(zeroHouseholds under100_hh _100to1MM_hh _1MMto3MM_hh over3MM_hh asset_hh='All')*f=comma12.
                     (zeroHouseholds under100_hh _100to1MM_hh _1MMto3MM_hh over3MM_hh)*rowpctsum<asset_hh>*f=pctfmt.
					 (zerodollars under100_doll _100to1MM_DOLL _1MMto3MM_doll over3MM_doll)*rowpctsum<asset_hh>*f=pctdoll.
			         / nocellmerge misstext='0';
format cbr_zip cbr2012fmt.;
run;


*define activity;
proc sort data=hudson.clean_20121106;
by pseudo_hh;
run;

proc summary data=hudson.clean_20121106;
by pseudo_hh;
output out=trans
	   sum(ATM_WD_HUDSON)=ATM_WD_HUDSON
	   sum(ATM_WD_OTHER)=ATM_WD_OTHER
	   sum(DEBIT_PURCH)=DEBIT_PURCH
	   sum(CHKS_PO_MTH)=CHKS_PO_MTH
	   sum(CHKS_PO_YTD)=CHKS_PO_YTD
	   sum(ACH_OUT_YTD)=ACH_OUT_YTD 
	   sum(ACH_OUT_PYR)= ACH_OUT_PYR
	   sum(ND_ANALYSIS)=ND_ANALYSIS;
run;

proc sort data=hudson.hudson_hh;
by pseudo_hh;
run;

data hudson.hudson_hh;
merge hudson.hudson_hh (in=a) trans (in=b) end=eof;
retain miss;
by pseudo_hh;
if a then output;
if a and not b then miss+1;
if eof then put 'WARNING: records in HH not in trans = ' miss;
drop miss;
run;


proc freq data=hudson.hudson_hh;
table ATM_WD_HUDSON ATM_WD_OTHER DEBIT_PURCH CHKS_PO_MTH CHKS_PO_YTD ACH_OUT_YTD ACH_OUT_PYR ND_ANALYSIS / missing;
run;

proc format;
value quick 0,. = 'Inactive'
            1-high = 'Active';
run;


proc tabulate data=hudson.hudson_hh missing ;
where dda eq 1 and bta_group ne '';
class cqi_dd ATM_WD_HUDSON ATM_WD_OTHER DEBIT_PURCH CHKS_PO_MTH ;
var hh dda_amt;
table (cqi_dd*ATM_WD_HUDSON*ATM_WD_OTHER*DEBIT_PURCH*CHKS_PO_MTH All),hh*sum hh*colpctsum<hh>*f=pctfmt. dda_amt*rowpctsum<hh>*f=pctdoll. / nocellmerge;
format cqi_dd ATM_WD_HUDSON ATM_WD_OTHER DEBIT_PURCH CHKS_PO_MTH quick.;
run;

proc tabulate data=data.main_201209 missing ;
where dda eq 1 and cbr ge 1 and cbr le 17;
class atmo_num atmt_num mpos_num vpos_num chk_num cqi_dd ;
var hh dda_amt;
table (cqi_dd*atmo_num *atmt_num* mpos_num *vpos_num *chk_num All),hh*sum hh*colpctsum<hh>*f=pctfmt. dda_amt*rowpctsum<hh>*f=pctdoll./ nocellmerge;
format atmo_num atmt_num mpos_num vpos_num chk_num cqi_dd quick.;
run;

data hudson.hudson_hh;
set hudson.hudson_hh;
activity = sum(ATM_WD_HUDSON, ATM_WD_OTHER, DEBIT_PURCH, CHKS_PO_MTH);
if activity eq . then activity = 0;
run;

proc freq data=hudson.hudson_hh;
where dda eq 1 and bta_group ne '';
table activity *cqi_dd/ missing nocol norow nopercent;
format activity trans. cqi_dd quick.;
run;

proc sql;
select count (*) from hudson.hudson_hh where bta_group ne '' and dda eq 1 and (activity ge 2 or (activity eq 1 and cqi_dd eq 1));
quit;


data hudson.hudson_hh;
length area_group_new $ 20;
set hudson.hudson_hh;
if products eq 1 then do;
	if dda1 eq 1 and (activity ge 2 or (activity eq 1 and cqi_dd eq 1)) then area_group_new = 'Single Active CHK';
	else if dda1 eq 1 then area_group_new = ' Single Inactive CHK';
	else if (MTG1 eq 1 or MTX1 eq 1) then area_group_new = 'Single MTG';
	else if (TDA1 eq 1 or IRA1 eq 1) then area_group_new = 'Single TDA/IRA';
	else if (MMS1 eq 1 or SAV1 eq 1) then area_group_new = 'Single MMS/SAV';
	else area_group_new = 'Single Other';
end;
if products gt 1 then do;
	if dda1 eq 1 and (activity ge 2 or (activity eq 1 and cqi_dd eq 1)) then area_group_new = 'Multi Active CHK';
	else if dda1 eq 1 then area_group_new = ' Multi Inactive CHK';
	else if (TDA1 eq 1 or IRA1 eq 1) then area_group_new = 'Multi TDA/IRA';
	else area_group_new = 'Multi Other';
end;
run;

proc tabulate data=hudson.hudson_hh missing;
where external ne 1 and products ne .;
class area_group_new bta_group / mlf;
var hh;
table bta_group*area_group_new, sum=' '*hh*f=comma12./ nocellmerge misstext='0';
format bta_group $bta_A.;
run;


title 'Hudson City Wealth Distribution';
proc tabulate data=hudson.hudson_hh order=data missing;
where external ne 1 and products ne .;
class bta_group segment products adj_tot state products area_group_new/ preloadfmt mlf;
table  (area_group_new all)*(bta_group all), N*f=comma12. (adj_tot ALL)*N*f=comma12. (adj_tot ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
table  (area_group_new all)*(bta_group all), segment*N*f=comma12. segment*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
format products prods. adj_tot wltamt.  segment hudsonseg. bta_group $bta_A.;
run;

*note: I did not do segments separately as the distribution could be gotten from above in excel;

title 'Hudson City Product Ownership and Balances';
proc tabulate data=hudson.hudson_hh order=data missing;
where external ne 1 and products ne .;
class bta_group segment products  area_group_new/ preloadfmt mlf;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt hh;
table (area_group_new all)*(bta_group all), (hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*sum='HHs'*f=comma12.
													(hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*rowpctsum<hh>='Penetration'*f=pctfmt.
													(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt)*sum='Balances'*f=dollar24.
                                                    (dda_amt*rowpctsum<dda1> mms_amt*rowpctsum<mms1> sav_amt*rowpctsum<sav1> tda_amt*rowpctsum<tda1> ira_amt*rowpctsum<ira1> 
                                                     mtg_amt*rowpctsum<mtg1> heq_amt*rowpctsum<heq1> iln_amt*rowpctsum<iln1> ccs_amt*rowpctsum<ccs1>)*f=pctdoll.
													/ nocellmerge misstext='0';
format products prods. segment hudsonseg. bta_group $bta_A.;
run;


*aCTIVE CHECKING PAGE, MTB DATA;

%let filter1 = dda eq 1 and (sum(atmo_num,atmt_num,vpos_num,mpos_num,chk_num) ge 2) or (sum(atmo_num,atmt_num,vpos_num,mpos_num,chk_num) eq 1 and cqi_dd eq 1);


title 'MTB Wealth Distribution';
proc tabulate data=data.main_201209 ;
where &filter1;
/*and cbr in (6, 8,13,16);*/
class segment  ixi_tot cbr segment;
table  cbr,N*f=comma12. (ixi_tot ALL)*N*f=comma12. (ixi_tot ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
format  ixi_tot wealthband. cbr cbr2012fmt. segment mtbseg.;
run;

proc tabulate data=DATA.MAIN_201209 order=data missing;
where &filter1;;
var dda: mms: tda: sav: mtg: heq: iln: ccs: ira: hh sec: card ins;

class segment/ preloadfmt;
class distance /preloadfmt;
CLASS CBR / PRELOADFMT;
table CBR, sum='All'*hh='HHs'*f=comma12. 
               (dda='Checking' mms='Mon Mkt' sav='Savings' tda='Time Dep' ira='IRA' mtg='Mortgage' 
               iln='Ins Loan' heq='Home Eq' sec='Securities' ins='Insurance' card='Credit Card')*pctsum<hh>='Penet'*f=pctfmt. 
			   (dda_amt='Checking'*pctsum<dda>='Avg. Bal.' mms_amt='Mon Mkt'*pctsum<mms>='Avg. Bal.' sav_amt='Savings'*pctsum<sav>='Avg. Bal.' 
                tda_amt='Time Dep'*pctsum<tda>='Avg. Bal.' ira_amt='IRA'*pctsum<ira>='Avg. Bal.' mtg_amt='Mortgage'*pctsum<mtg>='Avg. Bal.' 
                iln_amt='Ind Loan'*pctsum<iln>='Avg. Bal.' heq_amt='Home Eq'*pctsum<heq>='Avg. Bal.' ccs_amt='Credit Card'*pctsum<card>='Avg. Bal.'
                sec_amt='Securities'*pctsum<sec>='Avg. Bal.' )*f=pctdoll.
			   segment*(N*f=comma12.) segment*colpctN*f=pctfmt. distance*colPCTn*f=pctfmt.   / nocellmerge;
format   segment mtbseg. distance distfmt.  CBR CBR2012FMT.;
run;


* High Active M&T;
options compress=yes;
data data.main_201209;
length chk_act $ 9;
set data.main_201209;
active = 0;
if dda eq 1 and (sum(atmo_num,atmt_num,vpos_num,mpos_num,chk_num) ge 2) or 
   (sum(atmo_num,atmt_num,vpos_num,mpos_num,chk_num) eq 1 and cqi_dd eq 1) then active = 1;
hi_active=0;
if dda eq 1 and (sum(atmo_num,atmt_num,vpos_num,mpos_num,chk_num) ge 6) or 
   (sum(atmo_num,atmt_num,vpos_num,mpos_num,chk_num) eq 5 and cqi_dd eq 1) then hi_active = 1;
if active eq 1 and hi_active eq 1 and dda eq 1 then chk_act = 'Primary';
if active eq 1 and hi_active eq 0 and dda eq 1 then chk_act = 'Secondary';
if dda eq 1 and active eq 0 and hi_active eq 0 then chk_act = 'Inactive';
if dda eq 0 then chk_act = 'No Chk';
run;

proc freq data=data.main_201209;
table chk_act*dda hi_active active;
run;


%penetration(class1=chk_act,period=201209,where=dda eq 1);

%contribution(class1=chk_act,period=201209,where=dda eq 1);

%segments(class1=chk_act,period=201209,where=dda eq 1);

* High Active Hudson;
data hudson.hudson_hh;
set hudson.hudson_hh;
active=0;
if dda1 eq 1 and (activity ge 2) or 
   (activity eq 1 and cqi_dd eq 1) then active = 1;
hi_active=0;
if dda1 eq 1 and (activity ge 6) or 
   (activity eq 5 and cqi_dd eq 1) then hi_active = 1;
if active eq 1 and hi_active eq 1 and dda1 eq 1 then chk_act = 'Primary';
if active eq 1 and hi_active eq 0 and dda1 eq 1 then chk_act = 'Secondary';
if dda1 eq 1 and active eq 0 and hi_active eq 0 then chk_act = 'Inactive';
if dda1 eq 0 then chk_act = 'No Chk';
run;

proc freq data=hudson.hudson_hh;
where dda1 eq 1 and bta_group ne '';
table chk_act*dda1 hi_active active dda dda1;
run;

title 'Hudson City Checking HHs Analysis';
proc tabulate data=hudson.hudson_hh order=data missing;
where external ne 1 and products ne . and dda1 eq 1 ;
class bta_group segment products  area_group_new chk_act/ preloadfmt mlf;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt hh;
table (bta_group all)*(chk_act all), (hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*sum='HHs'*f=comma12.
													(hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*rowpctsum<hh>='Penetration'*f=pctfmt.
													(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt)*sum='Balances'*f=dollar24.
                                                    (dda_amt*rowpctsum<dda1> mms_amt*rowpctsum<mms1> sav_amt*rowpctsum<sav1> tda_amt*rowpctsum<tda1> ira_amt*rowpctsum<ira1> 
                                                     mtg_amt*rowpctsum<mtg1> heq_amt*rowpctsum<heq1> iln_amt*rowpctsum<iln1> ccs_amt*rowpctsum<ccs1>)*f=pctdoll.
													/ nocellmerge misstext='0';
table (bta_group all)*(chk_act all), N*f=comma12. segment*N*f=comma12. segment*rowpctN*f=pctfmt. /nocellmerge misstext='0';
format products prods. segment hudsonseg. bta_group $bta_a.;
run;


* break out the in state for ct, ny, nj from out of footprint;

proc format ;
value $ state (notsorted)
'NY' = 'New York'
'NJ' = 'New Jersey'
'CT' = 'Connecticut'
'' = 'No State'
other = 'Other';
run;



title 'Hudson City Wealth Distribution';
proc tabulate data=hudson.hudson_hh order=data missing;
where not(products eq . or products eq 0) and not(products eq 1 and mtx1 eq 1) and bta_group eq '';
class bta_group segment products adj_tot state products state/ preloadfmt mlf;
table  (state all)*(products all)*(segment all), N*f=comma12. (adj_tot ALL)*N*f=comma12. (adj_tot ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
format state $state. products prods. adj_tot wltamt.  segment hudsonseg. bta_group $bta.;
run;

*note: I did not do segments separately as the distribution could be gotten from above in excel;

title 'Hudson City Product Ownership and Balances';
proc tabulate data=hudson.hudson_hh order=data missing;
where not(products eq . or products eq 0) and not(products eq 1 and mtx1 eq 1) and bta_group eq '';
class bta_group segment products  state/ preloadfmt mlf;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt hh;
table (state all)*(products all)*(segment all), (hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*sum='HHs'*f=comma12.
													(hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*rowpctsum<hh>='Penetration'*f=pctfmt.
													(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt)*sum='Balances'*f=dollar24.
                                                    (dda_amt*rowpctsum<dda1> mms_amt*rowpctsum<mms1> sav_amt*rowpctsum<sav1> tda_amt*rowpctsum<tda1> ira_amt*rowpctsum<ira1> 
                                                     mtg_amt*rowpctsum<mtg1> heq_amt*rowpctsum<heq1> iln_amt*rowpctsum<iln1> ccs_amt*rowpctsum<ccs1>)*f=pctdoll.
													/ nocellmerge misstext='0';
format state $state. products prods. segment hudsonseg. bta_group $bta.;
run;

proc freq data=hudson.hudson_hh;
where  not(products eq . or products eq 0) and not(products eq 1 and mtx1 eq 1);
table bta_group / missing;
run;

*data for panel as rtequested by alli, 7 states;
proc tabulate data=hudson.hudson_hh missing;
where external ne 1 and products ne . and state in ('NJ','NY','CT','PA','MD','DE','DC','VA');
class area_group_new bta_group state/ mlf;
var hh;
table area_group_new all, (state all)*(sum=' '*hh*f=comma12.)/ nocellmerge misstext='0';
format bta_group $bta_A.;
run;
