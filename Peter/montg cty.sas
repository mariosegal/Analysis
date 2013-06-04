data tempx;
set ixi_new.mtb_census;
where countyname eq 'Montgomery County, MD' and cycleid eq 201106;
run;

data tempy;
set tempx;
avg1 = divide(totalassets, totalhouseholdswithassets);
keep blockgroupcode totalhouseholdswithassets totalassets avg1;
run;

proc means data=tempy;
var avg1;
run;

proc contents data=tempx varnum short; run;

data _null_;
length BlockGroupCode $ 12 ;
set tempx;
file 'C:\Documents and Settings\ewnym5s\My Documents\Peter\Motgomery County.txt' dsd dlm=',' ;
put BlockGroupCode $ CountyCode $  StateCode $ TotalAssets Annuities Bonds Deposits CD 
InterestChecking MoneyMarket NonInterestChecking OtherChecking Savings MutualFunds Other Stocks TotalHouseholds 
TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds InterestCheckingHouseholds 
MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds;
run;


