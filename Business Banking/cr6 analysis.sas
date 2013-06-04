filename a 'C:\Documents and Settings\ewnym5s\My Documents\Business Banking\cr6.txt';

data bb.cr6_accts;
length hhid $ 9 ;
infile a dsd dlm='09'x lrecl=4096 firstobs=2;
input hhid $ acct bal nii fees contr ssn_type $ owner_code $ sbu $;
run;

filename b 'C:\Documents and Settings\ewnym5s\My Documents\Business Banking\cv0.txt';

data bb.cv0_accts;
length hhid $ 9 ;
infile b dsd dlm='09'x lrecl=4096 firstobs=2;
input hhid $ acct bal nii fees contr ssn_type $ owner_code $ sbu $;
run;

filename c 'C:\Documents and Settings\ewnym5s\My Documents\Business Banking\pure_cr6.txt';

data bb.pure_cr6;
length hhid $ 9 ;
infile c dsd dlm='09'x lrecl=4096 firstobs=1;
input hhid $;
pure = 1;
run;

filename d 'C:\Documents and Settings\ewnym5s\My Documents\Business Banking\ssn_tin.txt';

data remain;
infile d dsd dlm='09'x lrecl=4096 firstobs=2;
input acct type $;
run;

proc sort data=bb.cr6_accts;
by acct;
run;

proc sort data=remain;
by acct;
run;

data bb.cr6_accts;
merge bb.cr6_accts (in=a) remain (in=b);
by acct;
if a;
run;



proc format library=sas;
value balband low-<0 = 'Negative'
              0-250 = 'Up to $250'
			  250<-500 = '$250 to $500'
			  500<-1000 = '$500 to $1,000'
			  1000<-2000 = '$1M to $2M'
			  2000<-3000 = '$2M to $3M'
			  3000<-4000 = '$3M to $4M'
			  4000<-5000 = '$4M to $5M'
			  5000<-7500 = '$5M to $7.5M'
			  7500<-10000 = '$7.5M to $10M'
			  10000<-15000 = '$10M to $15M'
			  15000<-20000 = '$15M to $20M'
			  20000<-25000 = '$20M to $25M'
			  25000<-50000 = '$25M to $50M'
			  50000<-100000 = '$50M to $100M'
			  100000<-high = '$100M+';
value contband low-<0 = 'Negative'
              0-10 = 'Up to $10'
			  10<-20 = '$10 to $20'
			  20<-30 = '$20 to $30'
			  30<-40 = '$30 to $40'
			  40<-50 = '$40 to $50'
			  50<-75 = '$50 to $75'
			  75<-100 = '$75 to $100'
			  100<-125 = '$100 to $125'
			  125<-150 = '$125 to $150'
			  150<-200 = '$150 to $200'
			  200<-250 = '$200 to $250'
			  250<-500 = '$250 to $500'
			  500<-high = '$500+';
run;
title 'CR6';
proc means data=bb.cr6_accts mean;
var bal nii fees contr;
class owner_code;
run;
title 'CV0';
proc means data=bb.cv0_accts mean;
var bal nii fees contr;
class owner_code;
run;

title 'CR6';			  
proc freq data=bb.cr6_accts;
table owner_code / missing out=cr6 ;
run;

title 'CV0';			  
proc freq data=bb.cv0_accts;
table owner_code / missing out = cv0;
run;

data compare;
merge cr6 (keep=owner_code percent rename=(percent=cr6)) cv0 (keep=owner_code percent rename=(percent=cv0));
by owner_code;
run;

proc print data=compare noobs;
run;

title 'CR6';			  
proc freq data=bb.cr6_accts;
table ssn_type / missing out=cr6 ;
run;

title 'CV0';			  
proc freq data=bb.cv0_accts;
table ssn_type / missing out = cv0;
run;

data compare;
merge cr6 (keep=ssn_type percent rename=(percent=cr6)) cv0 (keep=ssn_type percent rename=(percent=cv0));
by ssn_type;
run;

proc print data=compare noobs;
run;

proc freq data=bb.cr6_accts;
table sbu;
run;


proc sort data=bb.cr6_accts;
by owner_code;
run;

proc corr data=bb.cr6_accts plots=matrix(histogram);
/*where owner_code in ('SOL' 'CRP' 'ORG');*/
var bal contr ;
/*by owner_code;*/
run;

title 'CR6';
proc gplot data=bb.cr6_accts; *(where =(bal gt 0));
plot bal*contr;
/*format bal  balband. contr contband.;*/
run;

proc freq data=bb.cr6_accts;
table bal*contr / norow nocol nopercent out=bubble;
format bal  balband. contr contband.;
run;

title 'CR6';
proc gplot data=bubble;
bubble bal*contr=count;
run;

proc corr data=bb.cv0_accts plots=matrix(histogram);
/*where owner_code in ('SOL' 'CRP' 'ORG');*/
var bal contr ;
/*by owner_code;*/
run;

title 'CV0';
proc gplot data=bb.cv0_accts; *(where =(bal gt 0));
plot bal*contr;
/*format bal  balband. contr contband.;*/
run;

title 'CR6';
proc freq data=bb.cr6_accts;
table bal;
format bal balband.;
run;
title 'CV0';
proc freq data=bb.cv0_accts;
table bal;
format bal balband.;
run;

proc sort data=bb.cr6_accts;
by hhid;
run;

proc summary data=bb.cr6_accts;
output out=cr6_hhs N=accts sum(bal)=bal;
var bal;
by hhid;
run;

data pure;
merge cr6_hhs (in=a) bb.pure_cr6 (in=b);
by hhid;
if a and b;
run;

title 'CR6 Pure';
proc freq data=pure;
table bal accts;
format bal balband.;
run;

proc freq data=bb.cr6_accts;
table pure / missing;
run;

proc tabulate data=bb.cv0_accts;
class bal;
var contr;
table bal, N contr*mean;
format bal balband.;
run;

title 'CR6 remainin waterfall';
proc tabulate data=bb.cr6_accts;
class bal type;
var contr ;
table bal, type*(N contr*mean);
format bal balband.;
run;
