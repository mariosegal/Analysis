libname Data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname wip 'C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files';
libname ach 'C:\Documents and Settings\ewnym5s\My Documents\ACH';

libname IFM oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=Intelligentsia;
 Data Source=bagels"  schema=dbo; 

 libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
options fmtsearch=(SAS);


proc sql;
create table table1 as 
select count(distinct hhkey) as HH_num, count(distinct accountkey) as acct_num from ifm.ifm_acct_profile;
quit;


proc sql;
create table table2 as 
select count(distinct hhkey) as HH_num from ifm.ifm_hhld_profile;
quit;

proc contents data=ifm.ifm_acct_profile varnum short;
run;




proc freq data=ifm.ifm_acct_profile;
table accounttype;
run;



data ach.temp1;
set ifm.ifm_acct_profile;
where accounttype = "R";
select;
	when (ACHCreditTransactionsCount ge 1 and ACHDebitTransactionsCount ge 1) ach_type = 'Both';
	when (ACHCreditTransactionsCount ge 1 and ACHDebitTransactionsCount eq 0) ach_type = 'In';
	when (ACHCreditTransactionsCount eq 0 and ACHDebitTransactionsCount ge 1) ach_type = 'Out';
	when (ACHCreditTransactionsCount eq 0 and ACHDebitTransactionsCount eq 0) ach_type = 'None';
end;
children = 0;
if Childrenpresent ge '01JAN2011'd then do;
	children = 1;
end;
select;
	when (socialsecuritycount eq .) ssn = 0;
	when (socialsecuritycount ge 1) ssn = 1;
end;

select;
	when (earnedincomecount eq .) earned = 0;
	when (earnedincomecount ge 1) earned = 1;
end;

select;
	when (fixedincomecount eq .) fixed = 0;
	when (fixedincomecount ge 1) fixed = 1;
end;

keep hhkey accountkey ach_type ACHCreditTransactionsCount ACHDebitTransactionsCount TotalACHCreditAmount TotalACHDebitAmount LoyaltyGrade 
children ssn earned fixed earnedincomeamount fixedincomeamount socialsecurityamount;
run;

proc sort data=ach.temp1;
by hhkey;
run;

proc summary data=ach.temp1;
by hhkey;
var ACHCreditTransactionsCount ACHDebitTransactionsCount TotalACHCreditAmount TotalACHDebitAmount 
children ssn earned fixed earnedincomeamount fixedincomeamount socialsecurityamount;
output out=ach.temp2
       sum(ACHCreditTransactionsCount) = ACHCredit
	   sum(ACHDebitTransactionsCount) = ACHdebit
	   sum(TotalACHCreditAmount) = ACHcreditamt
	   sum(TotalACHDebitAmount) = achdebitamt
	   max(children) = children
	   max(ssn) = ssn
	   max(earned) = earned
	   max(fixed) = fixed
	   sum(earnedincomeamount) = earnedamt
	   sum(fixedincomeamount) = fixedamt
	   sum(socialsecurityamount) = ssnamt;
run;

data ach.temp2;
set ach.temp2;
select;
	when (ACHCredit ge 1 and ACHDebit ge 1) ach_type = 'Both';
	when (ACHCredit ge 1 and ACHDebit eq 0) ach_type = 'In';
	when (ACHCredit eq 0 and ACHDebit ge 1) ach_type = 'Out';
	when (ACHCredit eq 0 and ACHDebit eq 0) ach_type = 'None';
end;
run;


proc contents data=ifm.ifm_acct_profile varnum ;
run;

data ach.temp3;
set ifm.ifm_acct_profile;
where  accounttype eq "R";
keep hhkey accountkey  PrimaryEmployerName  PrimaryEstimatedAnnualIncome MortgageLoan1 MortgageLoanAmount1 MortgageLoan2 MortgageLoanAmount2
     MortgageLoan3 MortgageLoanAmount3 PrimaryInvestmentRelationshipNam PrimaryBankTransferRelationshipN AutomobileLoanPrimaryName InvestmentDebitOverallAvgAmount
     BankTransferDebitOverallAvgAmoun AutomobileLoanOverallAvgAmount;
run;

filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\ACH\mar_dda.txt';
data ach.mar_accts;
length accountkey $ 23;
infile mydata dlm='09'x dsd firstobs=2 lrecl=4096 ;
input accountkey $  cbr ;
run;

proc sort data=ach.mar_accts;
by accountkey;
run;
proc sort data=ach.temp3;
by accountkey;
run;

data ach.temp4;
merge ach.temp3 (in=a keep=accountkey PrimaryEmployerName PrimaryEstimatedAnnualIncome hh) ach.mar_accts (in=b);
by accountkey;
if a and b;
run;

proc sort data=ach.temp4;
by cbr PrimaryEmployerName;
run;

proc summary data=ach.temp4 (where=(PrimaryEstimatedAnnualIncome ne .));
var hh PrimaryEstimatedAnnualIncome;
by cbr PrimaryEmployerName;
output out=ach.empl1
       sum(hh) = sum_hh
	   sum(PrimaryEstimatedAnnualIncome) = income;
run;

proc sort data=ach.empl1;
by cbr descending sum_hh;
run;

data ach.empl2;
set ach.empl1;
by cbr;
if first.cbr then do;
	rank = 0;
end;
rank +1;
run;

data ach.empl3 (rename=(PrimaryEmployerName=Name PrimaryEstimatedAnnualIncome=Income));
set ach.empl2;
where rank le 20;
run;

data ach.empl3;
set ach.empl3;
avg1 = divide(Income,sum_hh);
if Name eq '' then do;
	Name = 'Unknown';
end;
if cbr eq . then do;
	cbr = 99;
end;
run;

proc sort data=ach.empl3;
by cbr descending sum_hh;
run;

/**/

/* Profile the fields with discrete values that define the accts*/
proc tabulate data=ifm.ifm_acct_profile out=ach.acct1 (rename =(pctn_0000000=pct1)) missing;
where accounttype eq "R";
class TriScore PrimaryBankIndicator LoyaltyGrade WealthIndicator RetirementIndicator InternetUser HomeOwnerFlag;
table LoyaltyGrade TriScore PrimaryBankIndicator WealthIndicator RetirementIndicator InternetUser HomeOwnerFlag ALL, 
N='Accounts'*f=comma12.0 pctn='Percent'*f=comma12.1/ nocellmerge;
run;

proc tabulate data=ifm.ifm_hhld_profile (where=(AccountType = 'R')) out=ach.hhld1 (rename =(pctn_0000000=pct1)) missing;
class TriScore PrimaryBankIndicator LoyaltyGrade WealthIndicator RetirementIndicator InternetUser HomeOwnerFlag;
table LoyaltyGrade TriScore PrimaryBankIndicator WealthIndicator RetirementIndicator InternetUser HomeOwnerFlag ALL, 
N='HHLDs'*f=comma12.0 pctn='Percent'*f=comma12.1 / nocellmerge;
run;

proc tabulate data=ach.temp1 out=ach.acct2 (rename =(pctn_00000=pct1)) missing;
class ach_type children ssn earned fixed;
table ach_type children ssn earned fixed, N='HHLDs'*f=comma12.0 pctn='Percent'*f=comma12.1 / nocellmerge;
run;

proc tabulate data=ach.temp2 out=ach.hhld2 (rename =(pctn_00000=pct1)) missing;
class ach_type children ssn earned fixed;
table ach_type children ssn earned fixed, N='HHLDs'*f=comma12.0 pctn='Percent'*f=comma12.1 / nocellmerge;
run;


data ach.acct1;
set ach.acct1;
pct1 = pct1/100;
run;

data ach.acct2;
set ach.acct2;
pct1 = pct1/100;
run;

data ach.hhld1;
set ach.hhld1;
pct1 = pct1/100;
run;

data ach.hhld2;
set ach.hhld2;
pct1 = pct1/100;
run;

data ach.temp3;
set ach.temp3;
hh=1;
run;



proc tabulate data=ach.temp3  out=ach.acct3 (drop=_PAGE_ _TABLE_ _TYPE_);
class PrimaryEmployerName ;
var PrimaryEstimatedAnnualIncome hh ;
table PrimaryEmployerName="Name", hh*sum='Count'*f=comma12.0 PrimaryEstimatedAnnualIncome*sum='Total'*f=dollar15. / nocellmerge;
run;

proc tabulate data=ach.temp3  out=ach.mtg1 (drop=_PAGE_ _TABLE_ _TYPE_);
class MortgageLoan1 ;
var MortgageLoanAmount1 hh ;
table MortgageLoan1='Name', hh*sum='Count'*f=comma12.0 MortgageLoanAmount1*sum='Total'*f=dollar15. / nocellmerge;
run;

proc tabulate data=ach.temp3  out=ach.mtg2 (drop=_PAGE_ _TABLE_ _TYPE_);
class MortgageLoan2 ;
var MortgageLoanAmount2 hh ;
table MortgageLoan2='Name', hh*sum='Count'*f=comma12.0 MortgageLoanAmount2*sum='Total'*f=dollar15. / nocellmerge;
run;

proc tabulate data=ach.temp3  out=ach.mtg3 (drop=_PAGE_ _TABLE_ _TYPE_);
class MortgageLoan3 ;
var MortgageLoanAmount3 hh ;
table MortgageLoan3='Name', hh*sum='Count'*f=comma12.0 MortgageLoanAmount3*sum='Total'*f=dollar15. / nocellmerge;
run;

proc tabulate data=ach.temp3 ( out=ach.invest1 (drop=_PAGE_ _TABLE_ _TYPE_);
class PrimaryInvestmentRelationshipNam ;
var InvestmentDebitOverallAvgAmount hh ;
table PrimaryInvestmentRelationshipNam='Name', hh*sum='Count'*f=comma12.0 InvestmentDebitOverallAvgAmount*sum='Total'*f=dollar15. / nocellmerge;
run;

proc tabulate data=ach.temp3  out=ach.bank1 (drop=_PAGE_ _TABLE_ _TYPE_);
class PrimaryBankTransferRelationshipN ;
var BankTransferDebitOverallAvgAmoun hh ;
table PrimaryBankTransferRelationshipN='Name', hh*sum='Count'*f=comma12.0 BankTransferDebitOverallAvgAmoun*sum='Total'*f=dollar15. / nocellmerge;
run;

proc tabulate data=ach.temp3  out=ach.auto1 (drop=_PAGE_ _TABLE_ _TYPE_);
class AutomobileLoanPrimaryName ;
var AutomobileLoanOverallAvgAmount hh ;
table AutomobileLoanPrimaryName='Name', hh*sum='Count'*f=comma12.0 AutomobileLoanOverallAvgAmount*sum='Total'*f=dollar15. / nocellmerge;
run;


data ach.acct3;
set ach.acct3;
avg1 = divide(sum,hh_sum);
run;

data ach.auto1;
set ach.auto1;
avg1 = divide(sum,hh_sum);
run;

data ach.bank1 (rename=(sum=sum1));
set ach.bank1;
avg1 = divide(sum,hh_sum);
run;

data ach.invest1;
set ach.invest1;
avg1 = divide(sum,hh_sum);
run;

data ach.mtg;
set ach.mtg1 (rename=(mortgageloan1=name mortgageloanamount1_sum=sum1))
    ach.mtg2 (rename=(mortgageloan2=name mortgageloanamount2_sum=sum1))
    ach.mtg3 (rename=(mortgageloan3=name mortgageloanamount3_sum=sum1));
run;

proc sort data=ach.mtg;
by name;
run;

proc sort data=ach.mtgx;
by descending hh_sum;
run;



proc summary data=ach.mtg;
var  hh_sum sum1;
by name;
output out=ach.mtgx (drop= _TYPE_ _freq_)
       sum(sum1) = sum1
	   sum(hh_sum) = hh_sum;
run;

data ach.mtgx;
set ach.mtgx;
avg1=divide(sum1,hh_sum);
run;

data ach.mtgz ;
set ach.mtgx (obs=20);
rank = _N_;
name1 = strip(rank || ' - ' || name);
run;


proc sort data=ach.bank1;
by descending hh_sum;
run;

data ach.bank2;
set ach.bank1 (obs=20 rename=(PrimaryBankTransferRelationshipN=Name) );
run;

proc sort data=ach.auto1;
by descending hh_sum;
run;

data ach.auto2;
set ach.auto1 (obs=20 rename=(AutomobileLoanPrimaryName=Name) );
run;

proc sort data=ach.invest1;
by descending hh_sum;
run;

data ach.invest2;
set ach.invest1 (obs=20 rename=(PrimaryInvestmentRelationshipNam=Name ) );
run;


proc sort data=ach.acct3;
by descending hh_sum;
run;




option orientation=landscape;
ods html close;
ods pdf file='C:\Documents and Settings\ewnym5s\My Documents\ACH\ACH Analysis 20120430.pdf';

Title1 'Analysis of ACH Activity Indicators - March 2011';
Title2 'M&T Bank';
Footnote justify=L "Source: M and T Bank Customer Insights; IFM";

axis1 label=(f="Swiss/bold" angle=90 'Percent of Accounts' ) major=none minor=none value=none ;
axis2 label=(f="Swiss/bold"  'Loyalty Grade (IFM)') ;
proc gchart data=ach.acct1;
vbar LoyaltyGrade / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 maxis=axis2;
format pct1 percent6.0 N comma12.0   HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;

axis2 label=(f="Swiss/bold"  'TriScore (IFM)') ;
proc gchart data=ach.acct1;
vbar TriScore/ outside=sum sumvar=pct1 noframe width=10 raxis=axis1 midpoints=0 to 0.9 by 0.1 maxis=axis2;
format pct1 percent6.0 N comma12.0  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;


/*axis2 label=(f="Swiss/bold"  'Primary Bank Indicator (IFM)') ;*/
/*proc gchart data=ach.acct1;*/
/*vbar PrimaryBankIndicator / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 midpoints= 0.1 0.5 0.75 1 maxis=axis2;*/
/*format triscore PrimaryBankIndicator percent6.0 N comma12.0 pct1 comma6.1  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;*/
/*run;*/

title10 'Primary Bank Indicator (IFM)'; 
proc gchart data=ach.acct1;
pie PrimaryBankIndicator / sumvar=pct1  midpoints=  0.1 0.5 0.75 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0 PrimaryBankIndicator percent6.;
run;

/*axis2 label=(f="Swiss/bold" 'Wealth Customer Indicator (IFM)') ;*/
/*proc gchart data=ach.acct1;*/
/*vbar WealthIndicator/ outside=sum sumvar=pct1 noframe width=10 raxis=axis1 midpoints= 0 1 maxis=axis2;*/
/*format triscore PrimaryBankIndicator percent6.0 N comma12.0 pct1 comma6.1  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;*/
/*run;*/

title10 'Wealth Customer Indicator (IFM)'; 
proc gchart data=ach.acct1;
pie WealthIndicator / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;

/*axis2 label=(f="Swiss/bold"  'Retired Customer Indicator (IFM)') ;*/
/*proc gchart data=ach.acct1;*/
/*vbar RetirementIndicator / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 midpoints= 0 1 maxis=axis2;*/
/*format triscore PrimaryBankIndicator percent6.0 N comma12.0 pct1 comma6.1  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;*/
/*run;*/

title10 'Retired Customer Indicator (IFM)'; 
proc gchart data=ach.acct1;
pie RetirementIndicator / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;

/*axis2 label=(f="Swiss/bold"  'Internet User Indicator(IFM)') ;*/
/*proc gchart data=ach.acct1;*/
/*vbar InternetUser / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 midpoints= 0 1 maxis=axis2;*/
/*format triscore PrimaryBankIndicator percent6.0 N comma12.0 pct1 comma6.1  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;*/
/*run;*/

title10 'Internet User Indicator(IFM)'; 
proc gchart data=ach.acct1;
pie InternetUser / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;

axis2 label=(f="Swiss/bold" 'Home Owner Flag (IFM)') ;
/*proc gchart data=ach.acct1;*/
/*vbar HomeOwnerFlag / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 midpoints= 0 1 maxis=axis2;*/
/*format triscore PrimaryBankIndicator percent6.0 N comma12.0 pct1 comma6.1  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;*/
/*run;*/

title10 'Home Owner Flag (IFM)'; 
proc gchart data=ach.acct1;
pie HomeOwnerFlag / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format triscore PrimaryBankIndicator percent6.0 N comma12.0 pct1 percent6.0  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;

title10;
axis1 label=(f="Swiss/bold" angle=90 'Percent of Accounts' ) major=none minor=none value=none ;
axis2 label=(f="Swiss/bold" 'ACH Activity Type');
proc gchart data=ach.acct2;
vbar ach_type / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 maxis=axis2 midpoints='None' 'Out' 'In' 'Both';
format pct1 percent6.0 children ssn earned fixed binary_flag.;
run;

/*axis2 label=(f="Swiss/bold" 'Presence of Children (inferred 2011+)');*/
/*proc gchart data=ach.acct2;*/
/*vbar children/ outside=sum sumvar=pct1 noframe width=10 raxis=axis1 maxis=axis2 midpoints=0 1;*/
/*format pct1 comma6.1  children ssn earned fixed binary_flag.;*/
/*run;*/

title10 'Presence of Children (inferred 2011+)'; 
proc gchart data=ach.acct2;
pie children / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0 children binary_flag.;
run;

/*axis2 label=(f="Swiss/bold" 'Received ACH Social Seurity Payments') ;*/
/*proc gchart data=ach.acct2;*/
/*vbar ssn / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 maxis=axis2 midpoints=0 1;*/
/*format pct1 comma6.1  children ssn earned fixed binary_flag.;*/
/*run;*/

title10 'Received ACH Social Security Payments'; 
proc gchart data=ach.acct2;
pie ssn / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0   ssn binary_flag.;
run;

/*axis2 label=(f="Swiss/bold" 'Received ACH Salary Payments');*/
/*proc gchart data=ach.acct2;*/
/*vbar earned / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 maxis=axis2 midpoints=0 1;*/
/*format pct1 comma6.1  children ssn earned fixed binary_flag.;*/
/*run;*/

title10 'Received ACH Salary Payments'; 
proc gchart data=ach.acct2;
pie earned / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0   earned binary_flag.;
run;


/*axis2 label=(f="Swiss/bold" 'Received ACH Fixed Income Payments');*/
/*proc gchart data=ach.acct2;*/
/*vbar Fixed / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 maxis=axis2 midpoints=0 1;*/
/*format pct1 comma6.1  children ssn earned fixed binary_flag.;*/
/*run;*/

title10 'Received ACH Fixed Income Payments'; 
proc gchart data=ach.acct2;
pie fixed / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0   fixed binary_flag.;
run;
title10;

axis1 label=(f="Swiss/bold" 'Number of Accounts' ) major=none minor=none value=none ;

axis2  label=(f="Swiss/bold" angle=90 'Top Mortgage Lenders') ;
title10 ; 
proc gchart data=ach.mtgz (obs=20);
hbar Name / descending outside=sum sumvar=hh_sum   noframe width=10 raxis=axis1 maxis=axis2 sumlabel='N';
format avg1  dollar12.0 hh_sum comma12.0 ;
run;

axis2  label=(f="Swiss/bold" angle=90 'Top Other Banks') ;
title10 ; 
proc gchart data=ach.bank2 (obs=20);
hbar Name / descending outside=sum sumvar=hh_sum   noframe width=10 raxis=axis1 maxis=axis2 sumlabel='N';
format avg1  dollar12.0 hh_sum comma12.0 ;
run;

axis2  label=(f="Swiss/bold" angle=90 'Top Auto Lenders') ;
title10 ; 
proc gchart data=ach.auto2 (obs=20);
hbar Name / descending outside=sum sumvar=hh_sum   noframe width=10 raxis=axis1 maxis=axis2 sumlabel='N';
format avg1  dollar12.0 hh_sum comma12.0 ;
run;

axis2  label=(f="Swiss/bold" angle=90 'Top Securities Relationships') ;
title10 ; 
proc gchart data=ach.invest2 (obs=20);
hbar Name / descending outside=sum sumvar=hh_sum   noframe width=10 raxis=axis1 maxis=axis2 sumlabel='N';
format avg1  dollar12.0 hh_sum comma12.0 ;
run;

axis2  label=(f="Swiss/bold" angle=90 'Top Employers') ;
title10 ; 
proc gchart data=ach.empl3;
hbar Name / descending outside=sum sumvar=sum_hh   noframe width=10 raxis=axis1 maxis=axis2 sumlabel='N';
by cbr;
format avg1  dollar12.0 sum_hh comma12.0 cbr cbrfmt.;
run;




/*--------*/

axis1 label=(f="Swiss/bold" angle=90 'Percent of Households' ) major=none minor=none value=none ;
axis2 label=(f="Swiss/bold"  'Loyalty Grade (IFM)') ;
proc gchart data=ach.hhld1;
vbar LoyaltyGrade / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 maxis=axis2;
format triscore PrimaryBankIndicator pct1 percent6.0 N comma12.0   HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;

axis2 label=(f="Swiss/bold"  'TriScore (IFM)') ;
proc gchart data=ach.hhld1;
vbar TriScore/ outside=sum sumvar=pct1 noframe width=10 raxis=axis1 midpoints=0 to 0.9 by 0.1 maxis=axis2;
format pct1 percent6.0 N comma12.0  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;


/*axis2 label=(f="Swiss/bold"  'Primary Bank Indicator (IFM)') ;*/
/*proc gchart data=ach.hhld1;*/
/*vbar PrimaryBankIndicator / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 midpoints= 0.1 0.5 0.75 1 maxis=axis2;*/
/*format triscore PrimaryBankIndicator percent6.0 N comma12.0 pct1 comma6.1  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;*/
/*run;*/

title10 'Primary Bank Indicator (IFM)'; 
proc gchart data=ach.hhld1;
pie PrimaryBankIndicator / sumvar=pct1  midpoints=  0.1 0.5 0.75 1 percent=none slice=inside value=inside noheading;
format pct1 PrimaryBankIndicator percent6.0 N comma12.0   HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;

/*axis2 label=(f="Swiss/bold" 'Wealth Customer Indicator (IFM)') ;*/
/*proc gchart data=ach.hhld1;*/
/*vbar WealthIndicator/ outside=sum sumvar=pct1 noframe width=10 raxis=axis1 midpoints= 0 1 maxis=axis2;*/
/*format triscore PrimaryBankIndicator percent6.0 N comma12.0 pct1 comma6.1  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;*/
/*run;*/

title10 'Wealth Customer Indicator (IFM)'; 
proc gchart data=ach.hhld1;
pie WealthIndicator / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0   HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;

/*axis2 label=(f="Swiss/bold"  'Retired Customer Indicator (IFM)') ;*/
/*proc gchart data=ach.hhld1;*/
/*vbar RetirementIndicator / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 midpoints= 0 1 maxis=axis2;*/
/*format triscore PrimaryBankIndicator percent6.0 N comma12.0 pct1 comma6.1  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;*/
/*run;*/

title10 'Retired Customer Indicator (IFM)'; 
proc gchart data=ach.hhld1;
pie RetirementIndicator / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;

/*axis2 label=(f="Swiss/bold"  'Internet User Indicator(IFM)') ;*/
/*proc gchart data=ach.hhld1;*/
/*vbar InternetUser / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 midpoints= 0 1 maxis=axis2;*/
/*format triscore PrimaryBankIndicator percent6.0 N comma12.0 pct1 comma6.1  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;*/
/*run;*/

title10 'Internet User Indicator(IFM)'; 
proc gchart data=ach.hhld1;
pie InternetUser / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;

axis2 label=(f="Swiss/bold" 'Home Owner Flag (IFM)') ;
/*proc gchart data=ach.hhld1;*/
/*vbar HomeOwnerFlag / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 midpoints= 0 1 maxis=axis2;*/
/*format triscore PrimaryBankIndicator percent6.0 N comma12.0 pct1 comma6.1  HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;*/
/*run;*/

title10 'Home Owner Flag (IFM)'; 
proc gchart data=ach.hhld1;
pie HomeOwnerFlag / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format triscore PrimaryBankIndicator pct1 percent6.0 N comma12.0   HomeOwnerFlag WealthIndicator RetirementIndicator InternetUser binary_flag.;
run;

title10;
axis1 label=(f="Swiss/bold" angle=90 'Percent of Accounts' ) major=none minor=none value=none ;
axis2 label=(f="Swiss/bold" 'ACH Activity Type');
proc gchart data=ach.hhld2;
vbar ach_type / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 maxis=axis2 midpoints='None' 'Out' 'In' 'Both';
format pct1 percent6.0  children ssn earned fixed binary_flag.;
run;

/*axis2 label=(f="Swiss/bold" 'Presence of Children (inferred 2011+)');*/
/*proc gchart data=ach.hhld2;*/
/*vbar children/ outside=sum sumvar=pct1 noframe width=10 raxis=axis1 maxis=axis2 midpoints=0 1;*/
/*format pct1 comma6.1  children ssn earned fixed binary_flag.;*/
/*run;*/

title10 'Presence of Children (inferred 2011+)'; 
proc gchart data=ach.hhld2;
pie children / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0  children binary_flag.;
run;

/*axis2 label=(f="Swiss/bold" 'Received ACH Social Seurity Payments') ;*/
/*proc gchart data=ach.hhld2;*/
/*vbar ssn / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 maxis=axis2 midpoints=0 1;*/
/*format pct1 comma6.1  children ssn earned fixed binary_flag.;*/
/*run;*/

title10 'Received ACH Social Security Payments'; 
proc gchart data=ach.hhld2;
pie ssn / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0 ssn binary_flag.;
run;

/*axis2 label=(f="Swiss/bold" 'Received ACH Salary Payments');*/
/*proc gchart data=ach.hhld2;*/
/*vbar earned / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 maxis=axis2 midpoints=0 1;*/
/*format pct1 comma6.1  children ssn earned fixed binary_flag.;*/
/*run;*/

title10 'Received ACH Salary Payments'; 
proc gchart data=ach.hhld2;
pie earned / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0 earned binary_flag.;
run;


/*axis2 label=(f="Swiss/bold" 'Received ACH Fixed Income Payments');*/
/*proc gchart data=ach.hhld2;*/
/*vbar Fixed / outside=sum sumvar=pct1 noframe width=10 raxis=axis1 maxis=axis2 midpoints=0 1;*/
/*format pct1 comma6.1  children ssn earned fixed binary_flag.;*/
/*run;*/

title10 'Received ACH Fixed Income Payments'; 
proc gchart data=ach.hhld2;
pie fixed / sumvar=pct1  midpoints= 0 1 percent=none slice=inside value=inside noheading;
format pct1 percent6.0 N comma12.0 fixed binary_flag.;
run;
title10;

quit;
ods pdf close;
ods html;

proc tabulate data=ifm.ifm_acct_profile missing;
class lifeinsurance;
var LifeInsuranceAvgAmountOverall;
table lifeInsurance, N LifeInsuranceAvgAmountOverall*sum;
run;

proc format library=sas;
value paymntfmt low-<0 = 'None or Negative'
				0-<250 = 'Up to $250'
 				250-<500 = '$250 to 500'
				500-<750 = '$500 to 750'
				750-<1000 = '$750 to 1,000'
				1000-<1500 = '$1,000 to 1,500'
				1500-<2000 = '$1,500 to 2,000'
				2000-<2500 = '$2,000 to 2,500'
				2500-<3000 = '$2,500 to 3,000'
				3000-<4000 = '$3,000 to 4,000'
				4000-<5000 = '$4,000 to 5,000'
				5000-<10000 = '$5,000 to 10,000'
				10000-high = 'Over $10,000';
run;


proc tabulate data=ifm.ifm_acct_profile missing;
where accounttype = "R";
class mortgageloanamount1 CreditCardOverallAvgAmount CreditCardAmount;
table mortgageloanamount1, N ;
table CreditCardAmount, N ;
format mortgageloanamount1 CreditCardAmount paymntfmt.;
run;

proc freq data=ifm.ifm_acct_profile;
where accounttype = "R";
table CreditCardOverallAvgAmount*CreditCardAmount / missing nocol norow nopercent;
format CreditCardAmount CreditCardOverallAvgAmount paymntfmt. ;
run;


proc sql;
select count(hhkey) as count from ifm.ifm_acct_profile where CreditCardOverallAvgAmount gt 0 and CreditCardOverallAvgAmount lt 250;
quit;



/*check charts and fixed, for example primary bank indicator either needs more slices or it needs bars */
proc sort data=ach.temp1;
by hhkey;
run;

data temp1;
set ach.temp1;
merge ach.temp1 (in=a rename=(hhkey=hhid))data.main_201203 (in=b keep=hhid band cqi:);
by hhid;
if a and b;
run;


