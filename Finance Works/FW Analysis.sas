*READ DATA;

data data.eservice_201206;
length hhid $ 9 svc $ 15  label1 $ 30 value1 $ 40 label2 $ 30 value2 $ 40;
infile  'C:\Documents and Settings\ewnym5s\My Documents\Finance Works\esvc.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input hhid $ svc $ user_type $ enroll :mmddyy10. cancel :mmddyy10. label1 $ value1 $ label2 $ value2 $;
run;


data data.eactivity_201206;
length hhid $ 9 type $ 15 svc $ 15 label1 $ 30 value1 $ 40 label2 $ 30 value2 $ 40 label3 $ 30 value3 $ 40 label4 $ 30 value4 $ 40 
       label5 $ 30 value5 $ 40;
infile  'C:\Documents and Settings\ewnym5s\My Documents\Finance Works\eactiv.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input hhid $ type $ svc $ label1 $ value1 $ label2 $ value2 $ label3 $  value3 $  label4 $ value4 $  label5 $  value5 ;
run;


*understand file ;
data temp;
set data.eservice_201206;
where svc eq 'FINANCEWORKS';
status=1;
if (cancel ge enroll) or (cancel ne . and enroll eq .) then status=0;
active = 0;
if label1 eq "Date Last Session" and input(value1,mmddyy10.) gt '01APR2012'd then active = 1;
run;



*Perform Analysis;

Title ' Enrolled Status';
proc tabulate data=temp missing;
class status;
table status ALL='Total', N*f=comma12. pctN*f=pctpic. / nocellmerge;
format status binary_flag.;
run;

Title ' Active Status';
proc tabulate data=temp missing;
where status eq 1;
class active;
table active ALL='Total', N*f=comma12. pctN*f=pctpic. / nocellmerge;
format active binary_flag.;
run;

data accounts usage;
merge temp (in=a keep=hhid status active) data.eactivity_201206 (in=b where=(svc="FINANCEWORKS"));
by hhid;
if a and b and type="ACCOUNT" then output accounts;
if a and b and type="USAGE" then output usage;
run;

Title 'Top Other Institutions';
proc freq data=accounts order=freq;
where find(value2,'M&T','it',1) eq 0; 
table value2;
run;


*How many have added accounts;

proc sort data=accounts;
by hhid value1;
run;

proc summary data=accounts;
by hhid value1;
output out=acct_summary (drop=_TYPE_);
run;
 
proc transpose data=acct_summary out=acct_summary1;
by hhid;
id value1;
run;

data acct_summary1;
set acct_summary1;
total = sum(of _numeric_);
hh=1;
run;

data acct_summary1;
merge acct_summary1 (in=a) temp(in=b keep=hhid status active);
by hhid;
if a or b;
if total eq . then total=0;
run;

data accounts;
set accounts;
balance = input(value3,comma24.2);
trans=input(value5,comma24.);
run;

proc sort data=accounts;
by value1;
run;

/*proc univariate data=accounts;*/
/*var balance trans;*/
/*by value1;*/
/*run;*/

proc format;
value quick low-<0 = 'negative'
            0 = 'zero'
			0<-high = 'positive';
run;

Title 'Balance Classification by Account Type';
proc tabulate data=accounts missing order=fmt;
class value1;
class balance /preloadfmt;
table value1='Type',balance*N*f=comma12. / nocellmerge;
format balance quick.;
run;

*Note Balances look weird to me, I am worried about a few negative CDs, a few positive loans and 1 positive mortgage - 
need to ask and decide how I will deal with that;
proc summary data=accounts;
by hhid value1;
output out=bal_summary (drop=_TYPE_) sum(balance)=balance sum(trans)=trans;
run;

proc transpose data=acct_summary out=bal_summary1;
by hhid;
id value1;
run;

data acct_summary1;
set acct_summary1;
total = sum(of _numeric_);
hh=1;
run;

data acct_summary1;
merge acct_summary1 (in=a) temp(in=b keep=hhid status active);
by hhid;
if a or b;
if total eq . then total=0;
run;



proc format;
value status 1 = 'Activated'
             0 = 'Cancelled';
run;


Title 'External Accounts Count';
proc tabulate data=acct_summary1 missing order=fmt;
class status  / preloadfmt exclusive;
class active total;
table (status all)*(active all) all,(total all)*(N*f=comma12. rowpctN*f=pctpic.) / nocellmerge;
format status status. active binary_flag.;
run;

Title 'External Accounts Avg';
proc tabulate data=acct_summary1 missing order=fmt;
class status  / preloadfmt exclusive;
class active ;
var total;
table (status all)*(active all) all,(total)*(mean*f=comma12.2) / nocellmerge;
format status status. active binary_flag.;
run;

proc contents data=acct_summary1 varnum short;
run;

title 'Type of External Accounts';
proc tabulate data=acct_summary1 missing order=fmt;
class status  / preloadfmt exclusive;
class active ;
var CREDIT_CARD TAX_DEFERRED_INVESTMENT CHECKING SAVINGS TAXABLE_INVESTMENT MONEY_MARKET LOAN LINE_OF_CREDIT MORTGAGE CD hh;
table  hh="HH"*sum*f=comma12. (CREDIT_CARD TAX_DEFERRED_INVESTMENT CHECKING SAVINGS TAXABLE_INVESTMENT MONEY_MARKET LOAN LINE_OF_CREDIT MORTGAGE CD)
      *(sum*f=comma12. pctsum<hh>*f=pctpic. mean*f=comma8.2)
      ,(status all)*(active all) all / nocellnmerge;
format status status. active binary_flag.;
run;

Title ' Top Financial Institutions by Account Type';
proc freq data=accounts;
table Value2*value1 / out=a;
run;

proc sort data=a;
by value1 descending count;
run;

proc print data=a noobs;
by value1;
var value2 count;
sum count;
format count comma12.;
run;

data fworks_flag;
merge acct_summary1 (in=a keep=hhid active status) data.main_201206 (in=b keep=hhid);
by hhid;
if b;
fworks_flag = 'N';
if status eq 0 then fworks_flag = 'C';
if status eq 1 and active eq 0 then fworks_flag = 'I';
if status eq 1 and active eq 1 then fworks_flag = 'A';
run;

proc tabulate data=fworks_flag MISSING;
class status active fworks_flag;
table status*active, fworks_flag;
run;




data DATA.main_201206;
merge DATA.main_201206 (in=a) fworks_flag (in=b keep=hhid fworks_flag);
by hhid;
if a;
run;

proc freq data=DATA.main_201206;
table svcs;
run;

data DATA.main_201206;
set DATA.main_201206;
svcs = sum(dda,mms,sav,tda,ira,mtg,heq,iln,ind,sln,sdb,sec,ins,trs,card);
run;


filename mprint "C:\Documents and Settings\ewnym5s\My Documents\Finance Works\macbug.sas" ;
data _null_ ; file mprint ; run ;
options  mfile nomlogic ;

%profile2 (classvars= fworks_flag1 ,period = 201206, data_library = data,condition = hh eq 1, name=Fworks_analysis)

filename mprint "C:\Documents and Settings\ewnym5s\My Documents\Finance Works\output_macro.sas" ;
data _null_ ; file mprint ; run ;
options  mfile nomlogic ;

%output_profile (name=FWorks_20121004)
