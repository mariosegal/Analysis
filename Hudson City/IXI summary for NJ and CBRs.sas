data wip.ixi_tiers;
set ixi.mtb_tiers_postal ;
where cycleid = 201112;
run;

data wip.ixi_assets;
set ixi.mtb_postal ;
where cycleid = 201112;
run;

proc contents data=wip.ixi_tiers varnum short;
run;

proc sort data=wip.ixi_assets;
by regionzipcode;
run;

proc sort data=branch.cbr_by_zip_2012;
by zip;
run;

data wip.ixi_assets;
merge wip.ixi_assets (in=a ) branch.cbr_by_zip_2012 (in=b rename=(zip=regionzipcode));
by regionzipcode;
if a;
run;

proc sort data=wip.ixi_tiers;
by regionzipcode;
run;

proc sort data=branch.cbr_by_zip_2012;
by zip;
run;

data wip.ixi_tiers;
merge wip.ixi_tiers (in=a ) branch.cbr_by_zip_2012 (in=b rename=(zip=regionzipcode));
by regionzipcode;
if a;
run;


data wip.ixi_tiers;
set wip.ixi_tiers;
under100 = sum(ZeroHouseholds, T1To2p5kHouseholds,T2p5kTo10kHouseholds,T10kTo25kHouseholds,T25kTo50kHouseholds,T50kTo75kHouseholds,T75kTo100kHouseholds);
band100to250 = T100kTo250kHouseholds ;
band250to500 = T250kTo500kHouseholds ;
band500to1000 = T500kTo1mHouseholds ;
band1mmto2mm=sum(T1mTo1P5mHouseholds ,T1P5mTo2mHouseholds );
band2mmto3mm=T2mTo3mHouseholds ;
bandover3mm=sum(T3mTo5mHouseholds,T5mTo7P5mHouseholds ,T7P5mTo10mHouseholds, T10mTo15mHouseholds, T15mTo25mHouseholds, T25mPlusHouseholds );

dollars_under100=sum(ZeroDollars, T1To2p5kDollars,T2p5kTo10kDollars,T10kTo25kDollars,T25kTo50kDollars,T50kTo75kDollars,T75kTo100kDollars);
dollars100to250 = T100kTo250kDollars ;
dollars250to500 = T250kTo500kDollars ;
dollars500to1000 = T500kTo1mDollars ;
dollars1mmto2mm=sum(T1mTo1P5mDollars ,T1P5mTo2mDollars );
dollars2mmto3mm=T2mTo3mDollars ;
dollarsover3mm=sum(T3mTo5mDollars, T5mTo7P5mDollars ,T7P5mTo10mDollars, T10mTo15mDollars, T15mTo25mDollars, T25mPlusDollars );
run;

ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars
T100kTo250kDollars 
T250kTo500kDollars 
T500kTo1mDollars 
T1mTo1P5mDollars T1P5mTo2mDollars 
T2mTo3mDollars 
T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars T10mTo15mDollars T15mTo25mDollars T25mPlusDollars 

ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds 
T100kTo250kHouseholds 
T250kTo500kHouseholds 
T500kTo1mHouseholds 
T1mTo1P5mHouseholds T1P5mTo2mHouseholds 
T2mTo3mHouseholds 
T3mTo5mHouseholds T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds

*##################################################################;

proc tabulate data=wip.ixi_assets;
class cbr_zip;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds 
    DepositsHouseholds CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds 
    OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds;
table cbr_zip, sum*(TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks)*f=dollar18. /nocellmerge misstext="0";
table cbr_zip, sum*(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds 
    DepositsHouseholds CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds 
    OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds)*f=comma12. 
    / nocellmerge misstext="$0.0";
table cbr_zip, (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks)*rowpctsum<TotalHouseholds>*f=pctdoll. /nocellmerge misstext="$0.0";
table cbr_zip, (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks)*rowpctsum<TotalHouseholdswithAssets>*f=pctdoll. /nocellmerge misstext="$0.0";
format cbr_zip cbr2012fmt. ;
run;

proc tabulate data=wip.ixi_assets;
where StateName eq "New Jersey";
class stateName;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds 
    DepositsHouseholds CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds 
    OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds;
table stateName, sum*(TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks)*f=dollar18. /nocellmerge misstext="0";
table stateName, sum*(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds 
    DepositsHouseholds CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds 
    OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds)*f=comma12. 
    / nocellmerge misstext="$0.0";
table stateName, (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks)*rowpctsum<TotalHouseholds>*f=pctdoll. /nocellmerge misstext="$0.0";
table stateName, (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks)*rowpctsum<TotalHouseholdswithAssets>*f=pctdoll. /nocellmerge misstext="$0.0";
format cbr_zip cbr2012fmt. ;
run;


proc tabulate data=wip.ixi_tiers;
class cbr_zip;
var under100 band100to250 band250to500 band500to1000 band1mmto2mm band2mmto3mm bandover3mm dollars_under100 dollars100to250 dollars250to500 dollars500to1000 dollars1mmto2mm dollars2mmto3mm dollarsover3mm;
table cbr_zip, sum*(under100 band100to250 band250to500 band500to1000 band1mmto2mm band2mmto3mm bandover3mm)*f=comma18. /nocellmerge misstext="0";
table cbr_zip, sum*(dollars_under100 dollars100to250 dollars250to500 dollars500to1000 dollars1mmto2mm dollars2mmto3mm dollarsover3mm)*f=dollar24. /nocellmerge misstext="0";
format cbr_zip cbr2012fmt. ;
run;

proc tabulate data=wip.ixi_tiers;
class statename;
where statename="New Jersey" and first_flag eq 1;
var under100 band100to250 band250to500 band500to1000 band1mmto2mm band2mmto3mm bandover3mm;
table statename, sum*(under100 band100to250 band250to500 band500to1000 band1mmto2mm band2mmto3mm bandover3mm)*f=comma18. /nocellmerge misstext="0";
format cbr_zip cbr2012fmt. ;
run;



data footprint;
length regionzipcode $ 5;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\NJBTA_Clean_20121206.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input snl_key regionzipcode $ ;
run;

data hudson.branch_key;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\hudson mtb snl table.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input snl_key mtb_branch hudson_branch ;
run;

data footprint;
set footprint;
regionzipcode1 = regionzipcode;
regionzipcode = catt("0",regionzipcode1);
run;


proc sort data=footprint;
by snl_key;
run;

proc sort data=branches;
by snl_key;
run;

data hudson.NJ_footprint;
merge footprint (in=a) branches (in=b);
by snl_key;
if a;
footprint=1;
run;

proc sort data=hudson.NJ_footprint;
by regionzipcode;
run;

data wip.ixi_tiers;
merge wip.ixi_tiers (in=a ) hudson.NJ_footprint (in=b keep=regionzipcode hudson_branch footprint );
by regionzipcode;
if a;
run;

data wip.ixi_assets;
merge wip.ixi_assets (in=a ) hudson.NJ_footprint (in=b keep=regionzipcode hudson_branch footprint );
by regionzipcode;
if a;
run;


proc sort data=wip.ixi_tiers;
by regionzipcode;
run;

proc sort data=wip.ixi_assets;
by regionzipcode;
run;

data wip.ixi_assets;
set wip.ixi_assets;
by regionzipcode;
first.flag =0;
if first.regionzipcode then first_flag = 1;
run;

data wip.ixi_tiers;
set wip.ixi_tiers;
by regionzipcode;
first.flag =0;
if first.regionzipcode then first_flag = 1;
run;

proc tabulate data=wip.ixi_assets;
where footprint eq 1;
class hudson_branch;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds 
    DepositsHouseholds CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds 
    OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds;
table hudson_branch , sum*(TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks)*f=dollar18. /nocellmerge misstext="0";
table hudson_branch , sum*(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds 
    DepositsHouseholds CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds 
    OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds)*f=comma12. 
    / nocellmerge misstext="$0.0";
table hudson_branch, (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks)*rowpctsum<TotalHouseholds>*f=pctdoll. /nocellmerge misstext="$0.0";
table hudson_branch, (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks)*rowpctsum<TotalHouseholdswithAssets>*f=pctdoll. /nocellmerge misstext="$0.0";
format cbr_zip cbr2012fmt. ;
run;

proc tabulate data=wip.ixi_tiers;
class hudson_branch;
where footprint eq 1;
var under100 band100to250 band250to500 band500to1000 band1mmto2mm band2mmto3mm bandover3mm;
table hudson_branch, sum*(under100 band100to250 band250to500 band500to1000 band1mmto2mm band2mmto3mm bandover3mm)*f=comma18. /nocellmerge misstext="0";
format cbr_zip cbr2012fmt. ;
run;

proc tabulate data=wip.ixi_assets;
where footprint eq 1 and first_flag eq 1 and statename ne "Massachusetts";
class statename;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds 
    DepositsHouseholds CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds 
    OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds;
table statename , sum*(TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks)*f=dollar18. /nocellmerge misstext="0";
table statename , sum*(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds 
    DepositsHouseholds CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds 
    OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds)*f=comma12. 
    / nocellmerge misstext="$0.0";
table statename, (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks)*rowpctsum<TotalHouseholds>*f=pctdoll. /nocellmerge misstext="$0.0";
table statename, (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking 
    Savings MutualFunds Other Stocks)*rowpctsum<TotalHouseholdswithAssets>*f=pctdoll. /nocellmerge misstext="$0.0";
format cbr_zip cbr2012fmt. ;
run;

proc tabulate data=wip.ixi_tiers;
class statename;
where footprint eq 1 and first_flag eq 1 and statename ne "Massachusetts";
var under100 band100to250 band250to500 band500to1000 band1mmto2mm band2mmto3mm bandover3mm under100 band100to250 band250to500 band500to1000 
    band1mmto2mm band2mmto3mm bandover3mm dollars_under100 dollars100to250 dollars250to500 dollars500to1000 dollars1mmto2mm dollars2mmto3mm dollarsover3mm;
table statename, sum*(under100 band100to250 band250to500 band500to1000 band1mmto2mm band2mmto3mm bandover3mm )*f=comma18./nocellmerge misstext="0";
table statename, sum*(dollars_under100 dollars100to250 dollars250to500 dollars500to1000 dollars1mmto2mm dollars2mmto3mm dollarsover3mm )*f=dollar24. /nocellmerge misstext="0";
format cbr_zip cbr2012fmt. ;
run;
