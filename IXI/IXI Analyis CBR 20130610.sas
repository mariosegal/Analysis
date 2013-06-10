
LIBNAME ixi_new ODBC DSN=IXI user=reporting_user pw=Reporting2 schema=dbo;
	 %let Cycle=201206;

	 
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

*union part may not be needed anymore;

proc sort data=temp_data;
by RegionZIPCode;
run;

data temp_data_unique;
set IXI_NEW.MTB_Postal;
where cycleid eq 201106;
by RegionZIPCode;
if first.RegionZIPCode then output;
run;

*this was before, now in 2013 at least this does not happend anymore, but just in case;

LIBNAME IXI 'C:\Documents and Settings\ewnym5s\My Documents\Analysis\IXI';;

  data temp_cbr;
  merge temp_data (in=A rename=(RegionZIPCode=ZIP)) 
        IXi.CBR_BY_ZIP_2012(in=b keep=ZIP CBR CBR_Name);
  by ZIP;
  rename FirmInterestCheckingHouseholds=FirmIntChkHH FirmNonInterestCheckingHousehold=FirmNonIntChkHH;
  if A;
  run;

    data temp_cbr;
  length cbr_num 3;
  set temp_cbr;
  cbr_num = put(cbr,2.);
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


*INTERNAL PART;

proc tabulate data=data.main_201212 out=results_MTB_Mkt(drop=_PAGE_ _TABLE_ _TYPE_);
class cbr;
var dda: mms: sav: tda: ira: sec: ;
table N=' '*(dda mms sav tda ira sec)*f=comma12. sum=' '*(dda_amt mms_amt sav_amt tda_amt ira_amt sec_amt)*f=dollar24., cbr;
format cbr cbr2012fmt.;
run;
