options compress=yes;

 
proc sort data= hudson.nj_footprint out=hudson.nj_footprint_deduped (keep=zip_clean footprint) nodupkey;
by zip_clean;
run;


data hudson.hudson_hh;
length rc 3 zip_clean $ 5 footprint 8;

if _n_ eq 1 then do;
	set hudson.nj_footprint_deduped end=eof1;
	dcl hash hh1 (dataset: 'hudson.nj_footprint_deduped', hashexp: 8, ordered:'a');
	hh1.definekey('zip_clean');
	hh1.definedata('footprint');
	hh1.definedone();
end;

do until (eof2);
	set hudson.hudson_hh end=eof2;
	rc=  hh1.find();
	if rc ne 0 then  do;
		*insert here code to set not found values for the hash data variables, commonly . 0 or '';
		footprint = 0;
	end;
	output;
	*because output is for all cases we are doing the merge for all records in file 2;	

end;
drop rc;
run;


*First calculate the profile for Hudson City HHs in the NJ footprint this was from the opportunity analysis part, but we had it for al lNJ;

proc format;
value  prods (notsorted )
	      1 = 'Single'
		2-high = 'Multi';

value $ state 'CT' = 'CT'
              'NY' = 'NY'
			  'NJ' = 'NJ'
			other = 'Other';
run;

proc format;
value abbas  
			1 = '<65 and less $1MM'
			2 = '<65 and $1-3MM'
			3 = '<65 and $3MM+'
			4 = '65+ and less $1MM'
			5 = '65+ and $1-3MM'
			6 = '65+ and $3MM+';
run;

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
value mtbseg (notsorted)
   1 = 'Building Their Future'
3 = 'Mainstream Family'
2 = 'Mass Affluent Family'
4 = 'Mass Affluent Family'
5 = 'Mainstream Retired'
6 = 'Mass Affluent Retired'
Other = 'Unable to Code';
run;

title 'Hudson NJ Footprint Wealth Distribution';
proc tabulate data=hudson.hudson_hh missing;
where footprint eq 1;
class segment products ixi_assets state products;
table  (products All)*(segment All), N*f=comma12. (ixi_assets ALL)*N*f=comma12. (ixi_assets ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
format products prods. ixi_assets wealthband. state $state. segment hudsonseg.;
keylabel rowpctN = 'Percent' All='Total';
run;

title 'Hudson(NJ) Footprint Average Asset Distribution';
proc tabulate data=hudson.hudson_hh (rename=(IXI_IntChecking=intchk IXI_NonIntChecking=nonintchk IXI_OthChecking=othchk IXI_OtherAssets=other IXI_Annuity=annuity
                                               ixi_bond=bond IXI_Deposits=deposits IXI_Savings=savings IXI_StockAssets=stock IXI_MutualFund=mfunds)) missing;
where footprint eq 1;
class segment products  state products;
var IXI_Assets Deposits nonintchk intchk othchk Savings IXI__MMS IXI_CD stock mfunds bond annuity other hh;
table  (products All)*(segment All), N='HHs'*f=comma12. (IXI_Assets Deposits nonintchk intchk othchk Savings
                                       IXI__MMS IXI_CD stock mfunds bond annuity other)*rowpctsum<hh>*f=pctdoll./nocellmerge;
keylabel sum='Total' rowpctsum='Average' All='Total';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg.;
run;

title 'Hudson(NJ) Footprint Average Asset Distribution by Product Ownership';
proc tabulate data=hudson.hudson_hh(rename=(IXI_IntChecking=intchk IXI_NonIntChecking=nonintchk IXI_OthChecking=othchk IXI_OtherAssets=other IXI_Annuity=annuity
                                               ixi_bond=bond IXI_Deposits=deposits IXI_Savings=savings IXI_StockAssets=stock IXI_MutualFund=mfunds))
						out = table missing;
where state = "NJ" and products ne .;;
class segment products  state  dda1 mms1 sav1 tda1 ira1 mtg1 mtx1 heq1 iln1 ccs1;
var IXI_Assets Deposits nonintchk intchk othchk Savings IXI__MMS IXI_CD stock mfunds bond annuity other hh;
table  (products )*(dda1 mms1 sav1 tda1 ira1 mtg1  heq1 iln1 ccs1 ALL), N='HHs'*f=comma12. (IXI_Assets Deposits nonintchk intchk othchk Savings
                                       IXI__MMS IXI_CD stock mfunds bond annuity other)*rowpctsum<hh>*f=pctdoll./nocellmerge;
keylabel sum='Total' rowpctsum='Average';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg.;
run;

data table;
length product $ 15;
set table;
if dda1 then product = 'Checking';
if mms1 then product = 'Money Market';
if sav1 then product = 'Savings';
if tda1 then product = 'Time Deposits';
if mtg1 then product = 'Mortgage';
if heq1 then product = 'Home Equity';
if iln1 then product = 'Ins. Loan';
if ccs1 then product = 'Overdraft';
if ira1 then product = 'IRAs';
if  (dda1  eq . and mms1  eq . and sav1  eq . and tda1  eq . and ira1  eq . and mtg1  eq . and heq1  eq . and iln1  eq . and ccs1 eq .) then product='All';

ixi_cd = sum(of ixi_cd_pctsum:);
IXI_Assets = sum(of IXI_Assets_pctsum:);
Annuity = sum(of Annuity_pctsum:);
BOND = sum(of BOND_pctsum:);
Deposits = sum(of Deposits_pctsum:);
MutualFund = sum(of MFUNDS_pctsum:);
OTHER = sum(of Other_pctsum:);
STOCK = sum(of STOCK_pctsum:);
IntChecking = sum(of INTCHK_pctsum:);
IXI_MMS = sum(of IXI__MMS_pctsum:);
NonIntChK = sum(of NONINTCHK_pctsum:);
OTHCHK = sum(of othchk_pctsum:);
Savings = sum(of Savings_pctsum:);

if dda1 or mms1 or sav1 or tda1 or ira1 or mtg1 or heq1 or iln1 or ccs1 then output;
if  (dda1  eq . and mms1  eq . and sav1  eq . and tda1  eq . and ira1  eq . and mtg1  eq . and heq1  eq . and iln1  eq . and ccs1 eq .) then output;
run;

proc sort data=table;
by products;
run;

proc print data=table noobs;
var products product N ixi_Assets Deposits IntChecking NonIntChK OTHCHK IXI_MMS Savings ixi_cd  Annuity BOND  MutualFund STOCK  OTHER;
format ixi_Assets Deposits IntChecking NonIntChK OTHCHK IXI_MMS Savings ixi_cd  Annuity BOND  MutualFund STOCK  OTHER pctdoll. N comma12.;
run;



proc tabulate data=hudson.hudson_hh (rename=(IXI_IntChecking=intchk IXI_NonIntChecking=nonintchk IXI_OthChecking=othchk IXI_OtherAssets=other IXI_Annuity=annuity
                                               ixi_bond=bond IXI_Deposits=deposits IXI_Savings=savings IXI_StockAssets=stock IXI_MutualFund=mfunds)) missing;
where footprint eq 1;
class segment products  state products abbas_grp;
var IXI_Assets Deposits nonintchk intchk othchk Savings IXI__MMS IXI_CD stock mfunds bond annuity other hh;
table  abbas_grp='' All , N='HHs'*f=comma12. (IXI_Assets Deposits nonintchk intchk othchk Savings
                                       IXI__MMS IXI_CD stock mfunds bond annuity other)*rowpctsum<hh>*f=pctdoll./nocellmerge;
keylabel sum='Total' rowpctsum='Average' All='Total';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. abbas_grp abbas.;
run;

proc tabulate data=hudson.hudson_hh missing;
where footprint eq 1;
class segment products  state products abbas_grp;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 hh  dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt;
table  (products all)*(abbas_grp='' ALL), N='HHs'*f=comma12. (dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*sum*f=comma12.;
table (products all)*(abbas_grp='' ALL), N='HHs'*f=comma12.
			(dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*rowpctsum<hh>*f=pctfmt. /nocellmerge misstext='0.0%';
table (products all)*(abbas_grp='' ALL), N='HHs'*f=comma12. (dda_amt='Checking'*rowpctsum<dda1> mms_amt='Money Market'*rowpctsum<mms1> sav_amt='Savings'*rowpctsum<sav1> tda_amt='Time Deposits'*rowpctsum<tda1> 
					  ira_amt='IRAs'*rowpctsum<ira1> mtg_amt='Mortgage'*rowpctsum<mtg1> heq_amt='Home Equity'*rowpctsum<heq1> iln_amt='Inst. Loan'*rowpctsum<iln1> 
                      ccs_amt='Overdraft'*rowpctsum<ccs1>)*f=pctdoll./nocellmerge misstext='$0';
keylabel sum='Total' rowpctsum='average';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. abbas_grp abbas.;
run;


*do data massaging to calculate adjusted wallet and opportunity;
*I will do checking in dollar all combined;

*
 DDA TDA IRA SAV MTG MMS ILN HEQ CCS MTX dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 mtx1 
DDA_amt TDA_amt IRA_amt SAV_amt MTG_amt MMS_amt ILN_amt HEQ_amt CCS_amt MTX_amt 
IXI_Assets IXI_Annuity IXI_Bond IXI_Deposits IXI_MutualFund IXI_OtherAssets IXI_StockAssets IXI_CD IXI_IntChecking IXI__MMS 
IXI_NonIntChecking IXI_OthChecking IXI_Savings 
;

data hudson.hudson_hh;
set hudson.hudson_hh;
if ixi_assets ne . then do;
	ixi_dda = sum(IXI_IntChecking , IXI_NonIntChecking);
	adj_dda=max(dda_amt, ixi_dda);
	adj_mms=max(mms_amt, IXI__MMS);
	adj_sav=max(SAV_amt,IXI_Savings);
	adj_tda=max(sum(TDA_amt,IRA_AMT),IXI_CD);
	adj_deposits=max(sum(dda_amt,mms_amt,SAV_amt,TDA_amt,IRA_AMT),ixi_deposits);

	opp_dda = sum(adj_dda,-1*MAX(0,DDA_AMT));
	opp_mms = sum(adj_mms,-1*MAX(0,mms_AMT));
	opp_sav = sum(adj_sav,-1*MAX(0,sav_AMT));
	opp_tda = sum(adj_tda,-1*MAX(0,sum(ira_AMT,tda_amt)));
	opp_deposits = sum(adj_deposits,-1*max(sum(dda_amt,mms_amt,SAV_amt,TDA_amt,IRA_AMT),0));
end;

run;



*do wallet analysis for NJ footprint customers;
title ' Wallet Analysis for Hudson Nj footprint';
proc tabulate data= hudson.hudson_hh missing;
where footprint eq 1;
class products segment;
var dda_amt sav_amt mms_amt tda_amt ira_amt ixi: adj: opp: hh;
table (products All)*(segment All), hh*sum*f=comma12. sum*(dda_amt sav_amt mms_amt tda_amt ira_amt )*f=dollar24. / nocellmerge misstext="0";
table (products All)*(segment All), hh*sum*f=comma12. sum*(ixi: )*f=dollar24. / nocellmerge misstext="0";
table (products All)*(segment All), hh*sum*f=comma12. sum*( adj: )*f=dollar24. / nocellmerge misstext="0";
table (products All)*(segment All), hh*sum*f=comma12. sum*( opp:)*f=dollar24. / nocellmerge misstext="0";
format products prods. segment hudsonseg. ;
keylabel N='HHs' sum='Total $';
run;

proc sql;
select products,segment, sum(adj_dda) format=dollar24. from hudson.hudson_hh where footprint eq 1 group by  products, segment;
quit;


*do analysis broken down by type of product at Hudson;

title ' Wallet Analysis for Hudson Nj footprint';
proc tabulate data= hudson.hudson_hh missing;
where footprint eq 1;
class products segment area_group;
var dda_amt sav_amt mms_amt tda_amt ira_amt ixi: adj: opp: hh;
table area_group, hh*sum*f=comma12. sum*(dda_amt sav_amt mms_amt tda_amt ira_amt )*f=dollar24. / nocellmerge misstext="0";
table area_group, hh*sum*f=comma12. sum*(ixi: )*f=dollar24. / nocellmerge misstext="0";
table area_group, hh*sum*f=comma12. sum*( adj: )*f=dollar24. / nocellmerge misstext="0";
table area_group, hh*sum*f=comma12. sum*( opp:)*f=dollar24. / nocellmerge misstext="0";
format products prods. segment hudsonseg. ;
keylabel N='HHs' sum='Total $';
run;

*do wallet analysis all HCSB Customers;
title ' Wallet Analysis for Hudson Customers (All)';
proc tabulate data= hudson.hudson_hh missing;
class products segment;
var dda_amt sav_amt mms_amt tda_amt ira_amt ixi: adj: opp: hh;
table (products All)*(segment All), hh*sum*f=comma12. sum*(dda_amt sav_amt mms_amt tda_amt ira_amt )*f=dollar24. / nocellmerge misstext="0";
table (products All)*(segment All), hh*sum*f=comma12. sum*(ixi: )*f=dollar24. / nocellmerge misstext="0";
table (products All)*(segment All), hh*sum*f=comma12. sum*( adj: )*f=dollar24. / nocellmerge misstext="0";
table (products All)*(segment All), hh*sum*f=comma12. sum*( opp:)*f=dollar24. / nocellmerge misstext="0";
format products prods. segment hudsonseg. ;
keylabel N='HHs' sum='Total $';
run;

proc tabulate data= hudson.hudson_hh missing;
class products segment adj_tot;
var hh;
table (products All)*(segment All), adj_tot*(hh*sum*f=comma12.) adj_tot*(HH*rowpctsum<hh>*f=PCTFMT.) / nocellmerge misstext='0';
format adj_tot ixifmt. products prods. segment hudsonseg. ;
run;



*do analysis broken down by type of product at Hudson;

title ' Wallet Analysis for Hudson Nj footprint';
proc tabulate data= hudson.hudson_hh missing;
where footprint eq 1;
class products segment area_group;
var dda_amt sav_amt mms_amt tda_amt ira_amt ixi: adj: opp: hh;
table area_group, hh*sum*f=comma12. sum*(dda_amt sav_amt mms_amt tda_amt ira_amt )*f=dollar24. / nocellmerge misstext="0";
table area_group, hh*sum*f=comma12. sum*(ixi: )*f=dollar24. / nocellmerge misstext="0";
table area_group, hh*sum*f=comma12. sum*( adj: )*f=dollar24. / nocellmerge misstext="0";
table area_group, hh*sum*f=comma12. sum*( opp:)*f=dollar24. / nocellmerge misstext="0";
format products prods. segment hudsonseg. ;
keylabel N='HHs' sum='Total $';
run;




*do analysis of the total mkt for footpritn using the same footprint definition;
data temp_assets missing1;
merge ixi.mtb_postal (in=a where=(cycleid=201206)) hudson.nj_footprint_deduped (in=b rename=(zip_clean=regionzipcode));
by regionzipcode;
if b then output temp_assets;
if b and not a then output missing1;
run;

data temp_tiers missing2;
merge ixi.mtb_tiers_postal (in=a where=(cycleid=201206)) hudson.nj_footprint_deduped (in=b rename=(zip_clean=regionzipcode));
by regionzipcode;
if b then output temp_tiers;
if b and not a then output missing2;
run;

proc contents data=temp_tiers varnum short;
run;

proc tabulate data=temp_assets;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking Savings 
MutualFunds Other Stocks TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds 
CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds 
SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds;
table sum*(TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking Savings 
MutualFunds Other Stocks)*f=dollar24. sum*(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds 
CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds 
SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds)*f=comma12., All / nocellmerge misstext='0';
run;

proc tabulate data=temp_tiers;
var ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars 
    T100kTo250kDollars T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars 
	T5mTo7P5mDollars T7P5mTo10mDollars T10mTo15mDollars T15mTo25mDollars T25mPlusDollars ZeroHouseholds T1To2p5kHouseholds 
	T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds T100kTo250kHouseholds 
	T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds T2mTo3mHouseholds T3mTo5mHouseholds 
	T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds;
table sum*(ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars 
    T100kTo250kDollars T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars 
	T5mTo7P5mDollars T7P5mTo10mDollars T10mTo15mDollars T15mTo25mDollars T25mPlusDollars)*f=dollar24. 
	sum*(ZeroHouseholds T1To2p5kHouseholds 
	T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds T100kTo250kHouseholds 
	T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds T2mTo3mHouseholds T3mTo5mHouseholds 
	T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds)*f=comma12., All / nocellmerge misstext='0';
run;

*Aggregate CBRs but by zip code, to be consistent with IXI;
data temp_mkt;
set data.main_201209 (in=a keep=hhid hh ixi: zip state cbr zip dda_amt mms_amt sec_amt tda_amt ira_amt sav_amt)  ;
if ixi_tot ne . then do;
	ixi_sec = ixi_tot-ixi_Non_Int_Chk -ixi_int_chk -ixi_savings -ixi_MMS -ixi_tda;
	adj_sec = max(ixi_sec,sec_amt);
	adj_dda=max(ixi_int_chk+ixi_Non_Int_Chk,dda_Amt);
	adj_mms=max(ixi_mms,mms_amt);
	adj_sav=max(ixi_savings,sav_amt);
	adj_tda=max(tda_amt+ira_amt,ixi_tda);
	adj_total=(adj_sec+adj_dda+adj_mms+adj_sav+adj_tda);
	opp_dda=max(0,(adj_dda-dda_amt));
	opp_mms=max(0,(adj_mms-mms_amt));
	opp_sav=max(0,(adj_sav-sav_amt));
	opp_tda=max(0,(adj_tda-tda_amt-ira_amt));
	opp_sec=max(0,(adj_sec-sec_amt));
end;
run;



options compress=y;
 data temp_mkt1;
length zip $ 5  cbr_zip 8;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set branch.Cbr_by_zip_2012 (keep=zip cbr_zip) end=eof1;
	dcl hash hh1 (dataset: 'branch.Cbr_by_zip_2012', hashexp: 8, ordered:'a');
	hh1.definekey('zip');
	hh1.definedata('cbr_zip');
	hh1.definedone();
end;

misses = 0;
do until (eof2);
	set temp_mkt end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		cbr_zip = .;
	end;
	output;
end;

putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;
 *checks;
proc freq data=temp_mkt1;
where zip ne '';
table cbr_zip / missing;
run;

proc freq data=temp_mkt1 order=freq;
where zip ne '' and cbr_zip eq .;
table state cbr / missing;
run;

*(all checks passed);

proc tabulate data=temp_mkt1 missing;
class adj_total cbr_zip;
var hh;
table (cbr_zip aLL),(adj_total="Estimated Wealth (Adjusted)" all)*(sum='Count'*hh*f=comma12.) 
              adj_total="Estimated Wealth (Adjusted)"*(hh*rowpctsum<hh>='Percent'*f=pctfmt.) / nocellmerge misstext='0';
format cbr_zip quickcbr. adj_total wltamt.;
run;


*new analysis for LIZ, she wants the current balance distribution for HCSB by balance band and also the opportunity that way;
data hudson.hudson_hh;
set hudson.hudson_hh;
tdaira = max(tda,ira);
tdaira_amt = sum(tda_amt, ira_amt);
run;

Title 'Hudson City (All) Customers';
proc tabulate data=hudson.hudson_hh missing;
where footprint eq 1;
class adj_tot products;
var dda mms sav tdaira dda_amt  sav_amt mms_amt tdaira_amt opp: hh;
table (products all)*(adj_tot all), 
      sum='Households'*(hh='All' dda='Checking' mms='Money Market' sav='Savings' tdaira='Time/IRAs' )*f=comma12. 
	  / nocellmerge misstext='0'; 
table (products all)*(adj_tot all),
	  sum='Balances at HCSB'*(dda_amt='Checking' mms_amt='Money Market' sav_amt='Savings' tdaira_amt='Time/IRAs' )*f=dollar24.
 	  / nocellmerge misstext='0';
table (products all)*(adj_tot all),
	  sum='Balance Opportunity'*(opp_dda='Checking' opp_mms='Money Market' opp_sav='Savings' opp_tda='Time/IRAs' opp_sec='Securities')*f=dollar24.
 	  / nocellmerge misstext='0';
format adj_tot wltamt. products prods.;
run;

*check how much IRA is not CD;
proc tabulate data=hudson.clean_20121106 missing;
var curr_bal;
where ptype= 'IRA';
class ptype stype;
table ptype*(stype all),sum*curr_bal*f=dollar24. colpctsum<curr_bal>*curr_bal*f=pctfmt.;
run;
