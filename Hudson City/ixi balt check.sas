
proc freq data=temp_mkt1;
where cbr_zip eq 12;
table (ixi_tot adj_total) / nopercent norow nocol missing;
format cbr_zip quickcbr. ixi_tot adj_total wltamt.;
run;


LIBNAME ixi ODBC DSN=IXI user=reporting_user pw=Reporting2 schema=dbo;

data temp_tiers miss1;
merge ixi.mtb_tiers_postal (in=a where=(cycleid eq 201206)) branch.cbr_by_zip_2012 (in=b keep= zip cbr_zip rename=(zip=regionzipcode) where=(cbr_zip eq 12));
by regionzipcode;
if b then output temp_tiers;
if b and not a then output miss1;
run;

data temp_ixi miss2;
merge ixi.mtb_postal (in=a where=(cycleid eq 201206)) branch.cbr_by_zip_2012 (in=b keep= zip cbr_zip rename=(zip=regionzipcode) where=(cbr_zip eq 12));
by regionzipcode;
if b then output temp_ixi;
if b and not a then output miss2;
run;

proc contents data=temp_ixi varnum short;
run;

proc contents data=temp_tiers varnum short;
run;

proc tabulate data=temp_tiers missing;
var ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
T10mTo15mDollars T15mTo25mDollars T25mPlusDollars ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds 
T50kTo75kHouseholds T75kTo100kHouseholds T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds 
T2mTo3mHouseholds T3mTo5mHouseholds T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds ;
class cbr_zip;
table N sum*(ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
T10mTo15mDollars T15mTo25mDollars T25mPlusDollars ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds 
T50kTo75kHouseholds T75kTo100kHouseholds T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds 
T2mTo3mHouseholds T3mTo5mHouseholds T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds)*f=comma24., cbr_zip / nocellmerge;
run;

proc tabulate data=temp_ixi missing;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking Savings MutualFunds Other Stocks TotalHouseholds 
    TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds 
NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds FirmTotalAssets 
FirmAnnuities FirmBonds FirmDeposits FirmCD FirmInterestChecking FirmMoneyMarket FirmNonInterestChecking FirmOtherChecking FirmSavings FirmMutualFunds 
FirmOther FirmStocks FirmHouseholdsWithAssets FirmAnnuitiesHouseholds FirmBondsHouseholds FirmDepositsHouseholds FirmCDHouseholds FirmInterestCheckingHouseholds 
FirmMoneyMarketHouseholds FirmNonInterestCheckingHousehold FirmOtherCheckingHouseholds FirmSavingsHouseholds FirmMutualFundsHouseholds FirmOtherHouseholds 
FirmStocksHouseholds ;
class cbr_zip;
table N sum*(TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking Savings MutualFunds Other Stocks TotalHouseholds 
    TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds 
NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds FirmTotalAssets 
FirmAnnuities FirmBonds FirmDeposits FirmCD FirmInterestChecking FirmMoneyMarket FirmNonInterestChecking FirmOtherChecking FirmSavings FirmMutualFunds 
FirmOther FirmStocks FirmHouseholdsWithAssets FirmAnnuitiesHouseholds FirmBondsHouseholds FirmDepositsHouseholds FirmCDHouseholds FirmInterestCheckingHouseholds 
FirmMoneyMarketHouseholds FirmNonInterestCheckingHousehold FirmOtherCheckingHouseholds FirmSavingsHouseholds FirmMutualFundsHouseholds FirmOtherHouseholds 
FirmStocksHouseholds)*f=comma24., cbr_zip/ nocellmerge;
run;


proc export data=branch.cbr_by_zip_2012 (keep = cbr_zip zip where =(cbr_zip eq 12)) outfile='C:\Documents and Settings\ewnym5s\My Documents\Hudson City\balt_zips.xlsx' dbms=excel;
run;


