proc tabulate data=hudson.branches;
class state countynm;
table state*countynm , N;
run;

proc sort data=hudson.clean_20121106;
by pseudo_hh order descending curr_bal;
run;

data branches;
set hudson.clean_20121106;
by pseudo_hh;
if first.pseudo_hh then output;
keep pseudo_hh branch;
run;

options compress=y;
 data hudson.hudson_hh;
length pseudo_hh 8 branch $ 3 ;
length rc 3;

if _n_ eq 1 then do;
	set branches end=eof1;
	dcl hash hh1 (dataset: 'branches', hashexp: 8, ordered:'a');
	hh1.definekey('pseudo_hh');
	hh1.definedata('branch');
	hh1.definedone();
end;

do until (eof2);
	set hudson.hudson_hh end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		branch = '';
	end;
	output;
end;
drop rc;
run;

*What customers they have in bergen, defined by county, who cares what branch they use;
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

title 'Profile of Bergen County Customers';
proc tabulate data=hudson.hudson_hh order=data;
where countynm eq 'Bergen' and state = 'NJ';
class segment products  state products ;
class adj_assets / preloadfmt;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 hh  dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt;
table  (products ALL), N='HHs'*f=comma12. (dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*sum*f=comma12.;
table (products ALL), N='HHs'*f=comma12.
			(dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*rowpctsum<hh>*f=pctfmt. /nocellmerge misstext='0.0%';
table (products ALL), N='HHs'*f=comma12. (dda_amt='Checking'*rowpctsum<dda1> mms_amt='Money Market'*rowpctsum<mms1> sav_amt='Savings'*rowpctsum<sav1> tda_amt='Time Deposits'*rowpctsum<tda1> 
					  ira_amt='IRAs'*rowpctsum<ira1> mtg_amt='Mortgage'*rowpctsum<mtg1> heq_amt='Home Equity'*rowpctsum<heq1> iln_amt='Inst. Loan'*rowpctsum<iln1> 
                      ccs_amt='Overdraft'*rowpctsum<ccs1>)*f=pctdoll./nocellmerge misstext='$0';
table  (segment ALL)*N*f=comma12. (segment All)*colpctN*f=pctfmt. ,(products ALL) / nocellmerge misstext='0';
table  (segment ALL)*N*f=comma12. (segment All)*colpctN*f=pctfmt. ,(products ALL) / nocellmerge misstext='0';
table (products ALL), adj_assets*N='HHs'*f=comma12. /nocellmerge misstext='$0';
table (products ALL), adj_assets*rowpctN*f=pctfmt. /nocellmerge misstext='$0';
keylabel sum='Total' rowpctsum='Avg. Bal.' colpctN='Percent' rowpctN="Percent" ;
format products prods. adj_assets wealthband. state $state. segment hudsonseg. ;
run;

title 'Estimated Wealth for Bergen County Customers';
proc tabulate data=hudson.hudson_hh order=data;
where countynm eq 'Bergen' and state = 'NJ' and ixi_assets ne .;
class segment products  state products ;
class adj_assets / preloadfmt;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 hh  dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt;
table (products ALL), adj_assets*N='HHs'*f=comma12. /nocellmerge misstext='$0';
table (products ALL), adj_assets*rowpctN*f=pctfmt. /nocellmerge misstext='$0';
keylabel sum='Total' rowpctsum='Avg. Bal.' colpctN='Percent' rowpctN="Percent" ;
format products prods. adj_assets wealthband. state $state. segment hudsonseg. ;
run;


title 'Wallet and Opportunity for Bergen County Customers';
proc tabulate data=hudson.hudson_hh ;
where countynm eq 'Bergen' and state = 'NJ';
class segment products  state products ;
var adj: opp: hh;
table (products ALL),sum*hh='HHs'*f=comma12. sum='Total Bal.'*(adj: opp:)*f=dollar24. nocellmerge misstext='0';
table (products ALL),sum*hh='HHs'*f=comma12. rowpctsum<hh>*(adj: opp:)*f=pctdoll. nocellmerge misstext='0';
keylabel sum='Total' rowpctsum='Avg. Bal.' colpctN='Percent' ;
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. ;
run;

*Define the total market size, by zip code;
data ixi_assets;
length zip 8;
set ixi.mtb_postal;
where cycleid eq 201206 and statecode = '34';
zip = regionzipcode;
format zip z5.;
run;

data ixi_tiers;
length zip 8;
set ixi.mtb_tiers_postal;
where cycleid eq 201206 and statecode = '34';
zip = regionzipcode;
format zip z5.;
run;

data ixi_assets;
merge ixi_assets(in=a ) sashelp.zipcode(in=b keep=zip countynm);
by zip;
if a;
run;

data ixi_tiers;
merge ixi_tiers(in=a ) sashelp.zipcode(in=b keep=zip countynm);
by zip;
if a;
run;

title 'Market Size by County (NJ)';
proc tabulate data=ixi_tiers missing; 
class countynm;
var ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
    T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
    T10mTo15mDollars T15mTo25mDollars T25mPlusDollars ;
var ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds 
	T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds T2mTo3mHouseholds T3mTo5mHouseholds 
	T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds ;
table countynm all, sum*(ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
    T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
    T10mTo15mDollars T15mTo25mDollars T25mPlusDollars)*f=dollar24. / nocellmerge misstext='$0.0';
table countynm all, sum*(ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds 
	T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds T2mTo3mHouseholds T3mTo5mHouseholds 
	T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds)*f=comma12. / nocellmerge misstext='0';
run;


title 'Market Size by County (NJ)';
proc tabulate data=ixi_assets missing; 
class countynm;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking Savings MutualFunds Other Stocks 
    TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds InterestCheckingHouseholds 
    MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds ;
table countynm all, sum*(TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking Savings MutualFunds Other Stocks)
      *f=dollar24. / nocellmerge misstext='$0.0';
table countynm all, sum*(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds InterestCheckingHouseholds 
    MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds)
    *f=comma12. / nocellmerge misstext='0';
run;



*mkt share;
proc freq date=hudson.nj_branches_all order=freq;
where county = 'Bergen';
table proforma_hcbk;
run;
