/**/
/*	 libname IXI_NEw odbc init_string="Provider=ODBC;*/
/*     Password=Reporting2;*/
/*     Persist Security Info=True;*/
/*     User ID=reporting_user;*/
/*     Initial Catalog=IXI;*/
/*     Data Source=bagels"  schema=dbo; */

LIBNAME ixi ODBC DSN=IXI user=reporting_user pw=Reporting2 schema=dbo;
	 %let Cycle=201106;


/* code below to create table of directory contents */

/*
proc sql;
create table contents as
SELECT t1.name, t2.rows
FROM IXI_NEW.sysobjects t1
  INNER JOIN IXI_NEW.sysindexes t2
  ON t1.id = t2.id
WHERE t2.indid <= 1
  AND xtype='U'
;
quit;
*/


proc freq data=IXI_NEW.MTB_Postal;
/*where cycleID = 201106;*/
table cycleid;
run;


/* create temp data table from Sql table*/
/*proc sql;*/
/*create table temp_data as*/
/*	Select *,  'MTB' as source*/
/*	From IXI_NEW.MTB_Postal*/
/*	where cycleID = &Cycle*/
/*	UNION*/
/*	Select * , 'WT' as source*/
/*	From IXI_NEW.WT_Postal*/
/*    where cycleID = &Cycle;*/
/*quit;*/

*not needed new data is all together;

proc sql;
create table temp_data as
	Select *,  'MTB' as source
	From IXI_NEW.MTB_Postal
	where cycleID = &Cycle;
quit;


proc freq data=temp_data;
table statename;
run;


/* this is a test to concatenate using UNION, Jeremy is concatenating the files at source so I do not have to here
I only needed it once*/


proc sql;
create table temp_data as
	Select *
	From IXI_NEW.MTB_Postal
	where cycleID = &Cycle
  UNION
	Select *
	From IXI_NEW.MTBEXP_Postal
	where cycleID = &Cycle;
quit;


/*summarize the data*/
/* when I add the wt data, I am double counting the total side, how to not do that? use first and group? */ 

proc sort data=temp_data;
by RegionZIPCode;
run;

data temp_data_unique;
set IXI_NEW.MTB_Postal;
where cycleid eq 201106;
by RegionZIPCode;
if first.RegionZIPCode then output;
run;

proc freq data=temp_data;
table statename;
run;



/*this tabulate adds the market data by state, the data for the market comes in both the MTB abnd IXI files, so i can get it only from one*/

/*proc freq data=ixi_new.mtb_postal;*/
/*where cycleid = 201106;*/
/*table statename;*/
/*run;*/


proc tabulate data=ixi_new.mtb_postal (drop=RegionZIPCode RegionZIPCityName StateCode) out=results_Market_Size(drop=_PAGE_ _TABLE_ _TYPE_);
where cycleid = 201106;
class StateName;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks 
TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds;
tables (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks )*sum='Total Balances'*f=dollar24.
(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds)*SUM='HH Counts'*f=comma12., (StateName='State' ALL='Total');
run;

/*this tabulate adds the MTB/WT data by state, sIn this case I do add the internal part from each table there could be double counting of HHs, of course not dollars,
I am not sure if I will ever use this, internally sounds th ebest way anyway, as we are missing securities and such */

proc tabulate data=temp_data (drop=RegionZIPCode RegionZIPCityName StateCode ) out=results_Firm_Size (drop=_PAGE_ _TABLE_ _TYPE_);
where cycleid = 201106;
class StateName;
var FirmTotalAssets FirmAnnuities FirmBonds FirmDeposits FirmCD FirmInterestChecking FirmMoneyMarket FirmNonInterestChecking FirmOtherChecking 
FirmSavings FirmMutualFunds FirmOther FirmStocks FirmHouseholdsWithAssets FirmAnnuitiesHouseholds FirmBondsHouseholds FirmDepositsHouseholds 
FirmCDHouseholds FirmInterestCheckingHouseholds FirmMoneyMarketHouseholds FirmNonInterestCheckingHousehold FirmOtherCheckingHouseholds 
FirmSavingsHouseholds FirmMutualFundsHouseholds FirmOtherHouseholds FirmStocksHouseholds;
tables (FirmTotalAssets FirmAnnuities FirmBonds FirmDeposits FirmCD FirmInterestChecking FirmMoneyMarket FirmNonInterestChecking FirmOtherChecking 
FirmSavings FirmMutualFunds FirmOther FirmStocks )*sum='MTB Balances'*f=dollar24.0 
(FirmHouseholdsWithAssets FirmAnnuitiesHouseholds FirmBondsHouseholds FirmDepositsHouseholds 
FirmCDHouseholds FirmInterestCheckingHouseholds FirmMoneyMarketHouseholds FirmNonInterestCheckingHousehold FirmOtherCheckingHouseholds 
FirmSavingsHouseholds FirmMutualFundsHouseholds FirmOtherHouseholds FirmStocksHouseholds)*SUM='MTB HHs'*f=comma12., (StateName='State' ALL='Total');
run;

proc means data=ixi_new.wt_postal sum;
where statename = 'Delaware' and cycleID eq 201116;
var TotalAssets FirmTotalAssets;
format   TotalAssets FirmTotalAssets dollar18.0;
run;


proc means data=ixi_new.mtb_postal sum;
where statename = 'Delaware' and cycleID eq 201116;
var TotalAssets FirmTotalAssets;
format   TotalAssets FirmTotalAssets dollar18.0;
run;

proc means data=temp_data sum;
where statename = 'Delaware' and cycleID eq 201116;
var TotalAssets FirmTotalAssets;
format   TotalAssets FirmTotalAssets dollar18.0;
run;

proc contents data=ixi_new.wt_postal varnum short;
run;

/* create temp data table from Sql table*/
proc sql;
create table temp_data1 as
	Select *
	From IXI_NEW.MTB_Tiers_Postal
	where cycleID = &Cycle;
quit;

/*summarize the data*/

proc contents data=temp_data1 short varnum;
run;

proc tabulate data=temp_data1 (drop=RegionZIPCode RegionZIPCityName StateCode CycleID) out=results_Tiers(drop=_PAGE_ _TABLE_ _TYPE_);
class StateName;
var _NUMERIC_;
tables (ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds 
        T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds T2mTo3mHouseholds T3mTo5mHouseholds 
        T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds)*SUM='Total HHs'*f=comma12.0
		(ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
         T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
         T10mTo15mDollars T15mTo25mDollars T25mPlusDollars )*SUM='Total $$$s'*f=Dollar24.0  
         , StateName='State' ALL ;
run;

*/I validated the majot struff through here */


/*libname myxls oledb init_string="Provider=Microsoft.ACE.OLEDB.12.0;*/
/*Data Source=C:\Documents and Settings\ewnym5s\My Documents\ixi\IXI Potential State &Cycle..xls;*/
/*Extended Properties=Excel 12.0";*/

data myxls.Market;
   set WORK.RESULTS_Market_Size;
  run;

  
data myxls.Tiers;
   set WORK.RESULTS_Tiers;
  run;

  data myxls.Firm;
   set WORK.RESULTS_Firm_SIZE;
  run;



  libname myxls clear;




/* need to read new file from netwk planning and use it for cbr analysis */

LIBNAME IXI 'C:\Documents and Settings\ewnym5s\My Documents\IXI';
/**/
/**/
/*filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Maps\CBR ZIPS Updated with NJ  20111205.txt';*/
/**/
/**/
/*Data IXI.CBR_BY_ZIP_2012;*/
/*length Name $ 30 ZIP $ 5 County $ 25  State $ 25 CBR_Name $ 20;*/
/*Infile myfile DLM='09'x firstobs=2 lrecl=4096;*/
/*Input 	Name $ */
/*		ZIP $ */
/*		County $ */
/*		FIPS */
/*		State $ */
/*		CBR_Name $ */
/*		CBR $;*/
/*run;*/



  /*further create dataset with CBR */
  proc sort data=IXI.CBR_BY_ZIP_2012;
  by ZIP;
  run;

  proc sort data =temp_data;
  by RegionZIPCode;
  run;

  proc sort data =temp_data1;
  by RegionZIPCode;
  run;

  data temp_cbr;
  merge temp_data (in=A rename=(RegionZIPCode=ZIP)) 
        IXi.CBR_BY_ZIP_2012(in=b keep=ZIP CBR CBR_Name);
  by ZIP;
  rename FirmInterestCheckingHouseholds=FirmIntChkHH FirmNonInterestCheckingHousehold=FirmNonIntChkHH;
  if A;
  run;

  data temp1_cbr;
  merge temp_data1 (in=A rename=(RegionZIPCode=ZIP)) 
        IXI.CBR_BY_ZIP_2012(in=b keep=ZIP CBR CBR_Name);
  by ZIP;
  if A;
  run;

  data temp_cbr;
  length cbr_num 3;
  set temp_cbr;
  cbr_num = put(cbr,2.);
  run;

  data temp1_cbr;
  length cbr_num 3;
  set temp1_cbr;
  cbr_num = put(cbr,2.);
  run;


*I need to get rid of dupes, for some reason there were dupes - this may be fixed by jeremy;
  data temp1_cbr;
  set temp1_cbr;
  by zip;
  if first.zip then output;
  run;


  proc contents data = temp1_cbr varnum short;
  run;

proc tabulate data=temp_cbr (drop=CycleID) out=results_CBR_Mkt(drop=_PAGE_ _TABLE_ _TYPE_);
class CBR_num / missing;
where cbr_num ne .;
var Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking Savings MutualFunds Other Stocks TotalHouseholds 
	TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds 
	NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds FirmTotalAssets 
	FirmAnnuities FirmBonds FirmDeposits FirmCD FirmInterestChecking FirmMoneyMarket FirmNonInterestChecking FirmOtherChecking FirmSavings FirmMutualFunds 
	FirmOther FirmStocks FirmHouseholdsWithAssets FirmAnnuitiesHouseholds FirmBondsHouseholds FirmDepositsHouseholds FirmCDHouseholds FirmIntChkHH 
	FirmMoneyMarketHouseholds FirmNonIntChkHH FirmOtherCheckingHouseholds FirmSavingsHouseholds FirmMutualFundsHouseholds FirmOtherHouseholds FirmStocksHouseholds;
tables (Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking Savings MutualFunds Other Stocks)*SUM*f=dollar24.
       (TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds InterestCheckingHouseholds MoneyMarketHouseholds 
	NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds)*sum*f=comma12.
   , CBR_num ;
format cbr_num cbr2012fmt.;
run;

proc tabulate data=temp1_cbr (drop=CycleID)  out=results_CBR_Tiers(drop=_PAGE_ _TABLE_ _TYPE_) order=unformatted;
class CBR_num / missing;
where cbr_num ne .;
var ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
T10mTo15mDollars T15mTo25mDollars T25mPlusDollars ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds 
T50kTo75kHouseholds T75kTo100kHouseholds T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds 
T2mTo3mHouseholds T3mTo5mHouseholds T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds ;
tables (ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
T10mTo15mDollars T15mTo25mDollars T25mPlusDollars)*sum*f=dollar24. (ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds 
T50kTo75kHouseholds T75kTo100kHouseholds T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds 
T2mTo3mHouseholds T3mTo5mHouseholds T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds)*SUM*f=comma12., CBR_num ;
format cbr_num cbr2012fmt.;
run;


*##############################################################################################################################################;




  /* Write files to Excel*/

libname myxls oledb init_string="Provider=Microsoft.ACE.OLEDB.12.0;
Data Source=C:\Documents and Settings\ewnym5s\My Documents\ixi\IXI Potential &Cycle..xls;
Extended Properties=Excel 12.0";

data myxls.Market;
   set WORK.RESULTS_Market_Size;
  run;

  
data myxls.Tiers;
   set WORK.RESULTS_Tiers;
  run;

  data myxls.Firm;
   set WORK.RESULTS_Firm_SIZE;
  run;

  data myxls.CBR_Tiers;
   set WORK.RESULTS_CBR_Tiers;
  run;

  libname myxls clear;



