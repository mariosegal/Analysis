LIBNAME ixi ODBC DSN=IXI user=reporting_user pw=Reporting2 schema=dbo;

proc sort data=hudson.Bta_3mi_new_20130125 ;
by zip_char;
run;

data temp_assets_1;
merge ixi.mtb_postal (in=a rename=(regionzipcode=zip_char)  where=(cycleid=201206)) hudson.Bta_3mi_new_20130125(in=b) end=eof;
retain miss;
by zip_char;
if b then output;
if b and not a then miss+1;
if eof then do;
	put "WARNING: Records in b file not on A = " miss;
end;
drop miss;
run;


data temp_assets_2;
merge ixi.mtbexp_postal (in=a rename=(regionzipcode=zip_char)  where=(cycleid=201206)) hudson.Bta_3mi_new_20130125(in=b where=(state='CT')) end=eof;
retain miss;
by zip_char;
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

proc sort data=temp_assets;
by snl_branch;
run;

data temp_assets;
merge temp_assets hudson.Branch_key (keep=snl_key hudson_branch rename=(snl_key=snl_branch));
by snl_branch;
run;



data temp_tiers;
merge ixi.mtb_tiers_postal (in=a rename=(regionzipcode=zip_char)  where=(cycleid=201206)) hudson.Bta_3mi_new_20130125(in=b) end=eof;
retain miss;
by zip_char;
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

proc sort data=temp_tiers;
by snl_branch;
run;

data temp_tiers;
merge temp_tiers hudson.Branch_key (keep=snl_key hudson_branch rename=(snl_key=snl_branch));
by snl_branch;
run;

proc tabulate data=temp_assets missing order=data out=t;
class hudson_branch /  mlf;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
	OtherChecking Savings MutualFunds Other Stocks;
var TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
	InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
	MutualFundsHouseholds OtherHouseholds StocksHouseholds;
table hudson_branch, sum='HHs in Market'*(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
							InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds 
							SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds)*f=comma12.
							(TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
							OtherChecking Savings MutualFunds Other Stocks)*sum='Total Balances'*f=dollar24.
						(TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
							OtherChecking Savings MutualFunds Other Stocks)*rowpctsum<TotalHouseholdsWithAssets>='Avg. Per Asset HH'*f=pctdoll.
			            / nocellmerge misstext='0';
run;


proc tabulate data=temp_tiers missing order=data;
class hudson_branch /  mlf;
var zeroHouseholds under100_hh _100to1MM_hh _1MMto3MM_hh over3MM_hh zerodollars under100_doll _100to1MM_DOLL _1MMto3MM_doll over3MM_doll  asset_hh;
table hudson_branch, sum*(zeroHouseholds under100_hh _100to1MM_hh _1MMto3MM_hh over3MM_hh asset_hh='All')*f=comma12.
                     (zeroHouseholds under100_hh _100to1MM_hh _1MMto3MM_hh over3MM_hh)*rowpctsum<asset_hh>*f=pctfmt.
					 (zerodollars under100_doll _100to1MM_DOLL _1MMto3MM_doll over3MM_doll)*sum*f=dollar24.
			         / nocellmerge misstext='0';

run;

