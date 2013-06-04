libname virtual 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled';
libname Data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname wip 'C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files';
libname board 'C:\Documents and Settings\ewnym5s\My Documents\Peter';

 libname IXI_NEw oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=IXI;
 Data Source=bagels"  schema=dbo; 

 libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
options fmtsearch=(SAS);

libname Branch 'C:\Documents and Settings\ewnym5s\My Documents\Network Planning';

filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Network Planning\BTAs for SAS.txt';

data branch.btas;
length ZIP $ 5;
infile mydata dlm='09'x dsd lrecl=4096 firstobs=2;
input Branch ZIP $;
run;

proc sort data=branch.btas;
by zip;
run;

data customer_data;
set data.main_201112; 
deposits = sum (dda_amt, mms_amt, tda_amt, ira_amt, sav_amt);
loans = sum(ind_amt,mtg_amt,heq_amt,iln_amt,ccs_amt,sln_amt);
loan_hh = min(1, sum(ind,iln,sln,mtg,heq,card));
sec_hh = min(1,sum(sec,ins));
dep_hh = min(1,sum(dda,mms,sav,tda,ira));
adj_sec_wallet = max(sec_amt,sum(ixi_tot,-1*ixi_savings,-1*ixi_mms,-1*ixi_tda,-1*ixi_int_chk,-1*ixi_non_int_chk));
adj_dep_wallet = max(deposits,sum(ixi_savings,ixi_mms,ixi_tda,ixi_int_chk,ixi_non_int_chk));
keep hhid zip hh dep_hh loan_hh sec_hh adj_dep_wallet adj_sec_wallet loans adj_wallet ixi_tot dda 
mms sav tda ira sec dda_amt sav_amt tda_amt ira_amt mms_amt deposits sec_amt;
run;




proc sql;
create table work.customer_data_bta as
select t1.branch, t2.* from branch.BTAs t1 inner join customer_data t2
on t1.zip=t2.zip;
quit;


proc tabulate data=work.customer_data_bta out=branch.BTA_Internal (drop=_TYPE_ _PAGE_ _TABLE_) missing;
class branch ;
var hh dep_hh loan_hh sec_hh adj_dep_wallet adj_sec_wallet adj_wallet deposits loans sec_amt dda_amt sav_amt mms_amt tda_amt ira_amt;
table branch, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. 
      (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans dda_amt sav_amt mms_amt tda_amt ira_amt sec_amt)*sum='Amount'*f=dollar24. /nocellmerge;
run;



/*###########################################################################################*/
/*MARKET SIZING BY BTA*/

data ixi_data;
set ixi_new.mtb_postal;
where cycleid eq 201106;
run;

proc sort data=ixi_data;
by regionzipcode;
run;

data ixi_data_bta;
merge ixi_data(in=a rename=(regionzipcode=zip)) branch.btas (in=b);
by zip;
if a and b;
run;


proc sort data=ixi_data_bta;
by branch;
run;

data q;
set ixi_data_bta;
by branch;
if first.branch then  do;
	output;
	return;
end;
run;

proc contents data=ixi_data_bta varnum short; run;

proc tabulate data=ixi_data_bta out=branch.BTA_Sizing (drop=_TYPE_ _PAGE_ _TABLE_) missing;
class Branch;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks 
TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds 
FirmTotalAssets FirmAnnuities FirmBonds FirmDeposits FirmCD FirmInterestChecking FirmMoneyMarket FirmNonInterestChecking 
FirmOtherChecking FirmSavings FirmMutualFunds FirmOther FirmStocks FirmHouseholdsWithAssets FirmAnnuitiesHouseholds 
FirmBondsHouseholds FirmDepositsHouseholds FirmCDHouseholds FirmInterestCheckingHouseholds FirmMoneyMarketHouseholds 
FirmNonInterestCheckingHousehold FirmOtherCheckingHouseholds FirmSavingsHouseholds FirmMutualFundsHouseholds 
FirmOtherHouseholds FirmStocksHouseholds ;
tables (Branch='Branch'), 
(TotalHouseholds='HH' TotalHouseholdsWithAssets='Asset_HH'  DepositsHouseholds='Dep HH'  InterestCheckingHouseholds='Int_Chk_HH' NonInterestCheckingHouseholds='Non_Int_Chk_HH'
OtherCheckingHouseholds='Other_Chk_HH'  MoneyMarketHouseholds='MMS_HH'  SavingsHouseholds='SAV_HH' CDHouseholds='CD_HH' OtherHouseholds='Other_HH' 
StocksHouseholds='Stock HH' AnnuitiesHouseholds ='Annuity_HH' MutualFundsHouseholds='Fund_HH' BondsHouseholds='Bond_HH')*SUM='HH_Counts'*f=comma12.
(TotalAssets='Assets' Annuities Bonds Deposits CD InterestChecking='Int_chk' MoneyMarket='MMS'  NonInterestChecking='Non_Int_Chk' 
OtherChecking='Other_Chk' Savings MutualFunds='Funds' Other Stocks )*sum='Total_Balances'*f=dollar24. 
(FirmHouseholdsWithAssets='MTB_Asset_HH'  FirmAnnuitiesHouseholds ='MTB_Annuity_HH'
FirmBondsHouseholds='MTB_Bond_HH'  FirmDepositsHouseholds='MTB_Dep_HH'  FirmCDHouseholds='MTB_CD_HH'  FirmInterestCheckingHouseholds='MTB_Int_Chk_HH'
FirmMoneyMarketHouseholds ='MTB_MMS_HH' FirmNonInterestCheckingHousehold='MTB_Non_Int_Chk_HH'  FirmOtherCheckingHouseholds='MTB_Oth_Chk_HH'  
FirmSavingsHouseholds ='MTb_SAV_HH' FirmMutualFundsHouseholds='MTB_Funds_HH'  FirmOtherHouseholds='MTB_Oth_HH'  
FirmStocksHouseholds='MTB_Stock_HH' )*sum='M&T HHs (from IXI)'*f=comma12.
(FirmTotalAssets='MTB_Assets'  FirmAnnuities='MTB_Annuity' FirmBonds='MTB_bonds' FirmDeposits='mtb_dep' FirmCD='mtb_cd' FirmInterestChecking='mtb_int_chk'
FirmMoneyMarket ='mtb_mms' FirmNonInterestChecking ='mtb_non_int_chk' FirmOtherChecking='mtb_oth_chk'  FirmSavings='mtb_sav' FirmMutualFunds='mtb_funds'
FirmOther='mtb_other'  FirmStocks='mtb_storcks')*sum='M&T Balances (from IXI)'*f=dollar24./ nocellmerge;
run;


data branch.merged;
merge branch.BTA_Internal (in=a) branch.BTA_Sizing (in=b rename=(deposits_sum=ixi_deposits));
by branch;
if a and b;
run;

data branch.merged;
set branch.merged;
HH_share = divide (hh_sum,totalhouseholds_sum);
Asset_share = divide ((deposits_sum+securities_sum),TotalAssets_sum);
Deposit_share = divide (deposits_sum , (interestchecking_sum+noninterestchecking_sum+otherchecking_sum+savings_sum+moneymarket_Sum+cd_sum));
Investment_share = divide (securities_sum, (totalassets_sum-(interestchecking_sum+noninterestchecking_sum+otherchecking_sum+savings_sum+moneymarket_Sum+cd_sum)));
format HH_share Asset_share Deposit_share Investment_share percent12.1;
run;

