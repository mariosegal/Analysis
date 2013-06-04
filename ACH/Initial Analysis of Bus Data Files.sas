libname IFM oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=Intelligentsia;
 Data Source=bagels"  schema=dbo; 


 proc contents data=ifm.ifm_bus_profile varnum short;
 run;

 proc tabulate data=ifm.ifm_bus_profile missing out=Payroll;
 where perioddate eq '01JUN2012:00:00:00.000'dt;
 var BankTransferDebitOverallAvgAmoun InvestmentDebitOverallAvgAmount MerchantServicesAvgMonthlyAmount PayrollProcessorAmount;
 class PayrollProcessor MerchantServicesPrimaryProvider PrimaryInvestmentRelationshipNam PrimaryBankTransferRelationshipN;
 table PayrollProcessor='Payroll Vendor', (PayrollProcessorAmount)*(N='N'*f=comma12. sum='Total Amount'*f=dollar24.) / nocellmerge;
 run;

  proc tabulate data=ifm.ifm_bus_profile missing out=merchant;
 where perioddate eq '01JUN2012:00:00:00.000'dt;
 var BankTransferDebitOverallAvgAmoun InvestmentDebitOverallAvgAmount MerchantServicesAvgMonthlyAmount PayrollProcessorAmount;
 class PayrollProcessor MerchantServicesPrimaryProvider PrimaryInvestmentRelationshipNam PrimaryBankTransferRelationshipN;
 table MerchantServicesPrimaryProvider='Merc. Svcs. Vendor', (MerchantServicesAvgMonthlyAmount)*(N*f=comma12. sum='Total Amount'*f=dollar24.) / nocellmerge;
 run;

  proc tabulate data=ifm.ifm_bus_profile missing out=Invest;
 where perioddate eq '01JUN2012:00:00:00.000'dt;
 var BankTransferDebitOverallAvgAmoun InvestmentDebitOverallAvgAmount MerchantServicesAvgMonthlyAmount PayrollProcessorAmount;
 class PayrollProcessor MerchantServicesPrimaryProvider PrimaryInvestmentRelationshipNam PrimaryBankTransferRelationshipN;
 table PrimaryInvestmentRelationshipNam='Investment relat.', (InvestmentDebitOverallAvgAmount)*(N*f=comma12. sum='Total Amount'*f=dollar24.) / nocellmerge;
 table PrimaryBankTransferRelationshipN='Other Bank Relat.', (BankTransferDebitOverallAvgAmoun)*(N*f=comma12. sum='Total Amount'*f=dollar24.) / nocellmerge;
 run;

  proc tabulate data=ifm.ifm_bus_profile missing out=Bank;
 where perioddate eq '01JUN2012:00:00:00.000'dt;
 var BankTransferDebitOverallAvgAmoun InvestmentDebitOverallAvgAmount MerchantServicesAvgMonthlyAmount PayrollProcessorAmount;
 class PayrollProcessor MerchantServicesPrimaryProvider PrimaryInvestmentRelationshipNam PrimaryBankTransferRelationshipN;
 table PrimaryBankTransferRelationshipN='Other Bank Relat.', (BankTransferDebitOverallAvgAmoun)*(N*f=comma12. sum='Total Amount'*f=dollar24.) / nocellmerge;
 run;



 proc tabulate data=ifm.ifm_bus_profile missing out=amexdicover;
  where perioddate eq '01JUN2012:00:00:00.000'dt;
 var AmexMerchantServicesAvgMonthlyAm DiscoverMerchantServicesAvgMonth;
 table (AmexMerchantServicesAvgMonthlyAm DiscoverMerchantServicesAvgMonth),(N*f=comma12. sum='Total Amount'*f=dollar24.) / nocellmerge;
 run;

 proc format;
 value quick . = 'N'
 		other = 'Y';
run;

data b;
set ifm.ifm_bus_profile;
where perioddate eq '01JUN2012:00:00:00.000'dt ;
keep accountkey MerchantServicesPrimaryProvider AmexMerchantServicesAvgMonthlyAm DiscoverMerchantServicesAvgMonth;
run;

data b;
set b;
Amex = 'N';
if AmexMerchantServicesAvgMonthlyAm ne . then Amex = 'Y';
Discover = 'N';
if DiscoverMerchantServicesAvgMonth ne . then Discover = 'Y';
run;


proc tabulate data=b missing;
 class  MerchantServicesPrimaryProvider Amex ;
 table MerchantServicesPrimaryProvider ALL, (Amex All)*n;
 run;

 proc tabulate data=b missing;
 class  MerchantServicesPrimaryProvider Discover ;
 table MerchantServicesPrimaryProvider ALL, (Discover All)*n;
 run;



proc freq data=ifm.ifm_bus_profile order=freq;
where AmexMerchantServicesAvgMonthlyAm gt 0;
table MerchantServicesPrimaryProvider;
run;

proc freq data=ifm.ifm_bus_profile order=freq;
where DiscoverMerchantServicesAvgMonth gt 0;
table MerchantServicesPrimaryProvider;
run;

proc sort data=test;
by descending PayrollProcessorAmount_N ;
run;

proc freq data=ifm.ifm_bus_profile ;
table TaxPaymentLastDate / missing;
run;


proc report data=test nowd;
columns PayrollProcessor PayrollProcessorAmount_N PayrollProcessorAmount_Sum avg1;
define PayrollProcessor / display 'Payroll Processor';
define PayrollProcessorAmount_N / display format=comma12. '# of Accounts';
define PayrollProcessorAmount_Sum / analysis format=dollar24. 'Total Amount';
define avg1 / computed 'Average Amount' format=dollar24.;
compute avg1 / ;
    _c5_ = divide( PayrollProcessorAmount_Sum , PayrollProcessorAmount_N);
endcomp;
run;

proc contents data=test varnum short;
 run;





PayrollProcessor MerchantServicesPrimaryProvider PrimaryInvestmentRelationshipNam PrimaryBankTransferRelationshipN  PayrollProcessorAmount_N PayrollProcessorAmount_Sum N Sum
