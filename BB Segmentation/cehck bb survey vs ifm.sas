data bb_survey;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Lookup New New 20120807.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input yours $ hhid $;
drop yours;
run;

libname IFM oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=Intelligentsia;
 Data Source=bagels"  schema=dbo; 

 proc freq data=ifm.ifm_bus_profile;
 table perioddate;
 run;
proc sort data=bb_survey;
by hhid;
run;

data a;
merge ifm.ifm_bus_profile (in=a keep= rename=(hhkey=hhid ) where=(perioddate eq '01JUL2012:00:00:00.000'dt)) bb_survey (in=b);
by hhid;
if a and b;
run;

proc sort data=a out=b nodupkey;
by hhid;
run;

proc contents data=a varnum short;
run;

proc freq data=a;
table  ACHCreditTransactionsCount ACHDebitTransactionsCount AmexCreditCardPaymentCount DiscoverCreditCardPaymentCount VisaMCCreditCardPaymentCount 
InvestmentDebitCount InvestmentCreditCount BankTransferDebitCount BankTransferCreditCount TotalACHCreditAmount TotalACHDebitAmount AmexCreditCardOverallAvgPayment 
AmexCreditCardAmount AmexCreditCardMaxEver DiscoverCreditCardOverallAvgPaym DiscoverCreditCardAmount DiscoverCreditCardMaxEver VisaMCCreditCardOverallAvgPaymen 
VisaMCCreditCardAmount VisaMCCreditCardMaxEver TaxPaymentTotalAmount TaxRefundTotalAmount PayrollProcessorAmount MerchantServicesAvgMonthlyAmount 
MerchantServicesAmount AmexMerchantServicesAvgMonthlyAm AmexMerchantServicesAmount DiscoverMerchantServicesAvgMonth DiscoverMerchantServicesAmount 
InvestmentDebitOverallAvgAmount InvestmentDebitAmount InvestmentDebitTrailing12Months InvestmentCreditOverallAvgAmount InvestmentCreditAmount 
InvestmentCreditTrailing12Months BankTransferDebitOverallAvgAmoun BankTransferDebitAmount BankTransferDebitTrailing12Month BankTransferCreditOverallAvgAmou 
BankTransferCreditAmount BankTransferCreditTrailing12Mont TaxPaymentLastDate TaxRefundLastDate PayrollProcessorLastDate MerchantServicesLastDate 
AmexMerchantServicesLastDate DiscoverMerchantServicesLastDate InvestmentDebitLastDate InvestmentCreditLastDate BankTransferDebitLastDate BankTransferCreditLastDate 
AccountType PayrollProcessor MerchantServicesPrimaryProvider PrimaryInvestmentRelationshipNam PrimaryBankTransferRelationshipN CNum / missing;
format _numeric_ mybinary.;
run;
