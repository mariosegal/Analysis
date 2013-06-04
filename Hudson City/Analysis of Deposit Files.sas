data hudson.DDA;
length acct $ 12  custid $ 12 address_key $ 50 name_key $ 20;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Data\DDA.txt' dsd dlm='09'x lrecl=4096 firstobs=2 ;
input acct $ type $ branch rate :percent20.10  bal_june drop1 $ drop2 $ bal_may drop3 $ drop4 $ bal_apr drop5 $ drop6 $ 
      opendate $ custid $   address_key $ name_key $;
drop drop: ;
run;

data hudson.SAV;
length acct $ 12  custid $ 12 address_key $ 50 name_key $ 20;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Data\savings.txt' dsd dlm='09'x lrecl=4096 firstobs=2 ;
input acct $ type $ branch rate :percent20.10  bal_june drop1 $ drop2 $ bal_may drop3 $ drop4 $ bal_apr drop5 $ drop6 $ 
      opendate $ custid $   address_key $ name_key $;
drop drop: ;
run;

data hudson.TDA;
length acct $ 12  name $ 50 custid $ 12 address_key $ 50 name_key $ 20 state $ 2 zip $ 10 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Data\tda1.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input type $ name $  rate :percent20.10  acct $ opendate :mdyampm16. maturity :mdyampm16. state $ zip $  bal_june ;
drop drop: ;
open = datepart(opendate);
mature = datepart(maturity);
run;


data hudson.mtg;
length  acct $ 12 zip $ 10 add1 add2 add3 $ 50 prop1 prop2 prop3 $ 50 delinq_date $ 20;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Data\mtg.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input appl_code acct $ type subtype prop_type purpose open_date :mmddyy10. orig_amt :comma24.2 balance :comma24.2 rate maturity :mmddyy10. 
      rem_term delinq_cat delinq_date $ orig_appr :comma24.2 curr_appr :comma24.2 appr_date :mmddyy10. orig_ltv : percent10.2 
      state $ zip $ add1 $ add2 $ add3 $ prop1 $ prop2 $ prop3 $ fico fico_date :mmddyy10.;
run;

data hudson.he;
length  acct $ 12 zip $ 10 add1 add2 add3 $ 50 prop1 prop2 prop3 $ 50 delinq_date $ 20;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Data\he.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input appl_code acct $ type subtype prop_type purpose open_date :mmddyy10. orig_amt :comma24.2 balance :comma24.2 rate maturity :mmddyy10. 
      orig_appr :comma24.2 curr_appr :comma24.2 appr_date :mmddyy10. ltv : percent10.2 
      state $ zip $ add1 $ add2 $ add3 $ prop1 $ prop2 $ prop3 ;
run;

data hudson.dda;
length m y 8. l 8.;
set hudson.dda (obs=max) ;
l = length(trim(opendate));
if l = 3 then do;
	m=substr(opendate,1,1);
	y=substr(opendate,2,2);
end;
if l = 4 then do;
	m=substr(opendate,1,2);
	y=substr(opendate,3,2);
end;
open=MDY(m,1,y);
/*open=MDY(substr(open_date,1,2),1,substr(open_date,3,2));*/
drop m y l;
run;

data hudson.sav;
length m y 8. l 8.;
set hudson.sav (obs=max) ;
l = length(trim(opendate));
if l = 3 then do;
	m=substr(opendate,1,1);
	y=substr(opendate,2,2);
end;
if l = 4 then do;
	m=substr(opendate,1,2);
	y=substr(opendate,3,2);
end;
open=MDY(m,1,y);
/*open=MDY(substr(open_date,1,2),1,substr(open_date,3,2));*/
drop m y l;
run;

data hudson.sav;
set hudson.sav;
product = 'sav';
run;

data hudson.tda;
set hudson.tda;
product = 'tda';
run;


data hudson.deposits;
set hudson.tda;
run;

proc append base=hudson.deposits data=hudson.sav force;
run;

*check combined;


*analysis of TDA portfolio;

proc tabulate data=hudson.tda missing;
where state in ('CT' 'NJ' 'NY' 'PA' 'FL');
class type state maturity;
var bal_june;
table state, (N sum*bal_june)*f=comma24. / nocellmerge;
run;

proc tabulate data=hudson.tda missing;
where state not in ('CT' 'NJ' 'NY' 'PA' 'FL');
class type state maturity;
var bal_june;
table ALL, (N sum*bal_june)*f=comma24. / nocellmerge;
run;

data temp;
set hudson.tda;
bal1 = bal_june;
run;


proc format ;
value afmt low-<1000 = 'Under $1M'
           1000-<2500 = '$1M to 2.5M'
		   2500-<5000 = '$2.5M to 5M'
		   5000-<10000 = '$5M to 10M'
		   10000-<25000 = '$10M to 25M'
		   25000-<50000 = '$25M to 50M'
		   50000-<100000 = '$50M to 100M'
		   100000-<250000= '$100M to 250M'
		   250000-<500000= '$250M to 500M'
		   500000-<1000000= '$500M to 1MM'
		   1000000-high= '$1MM+';
run;





proc tabulate data=temp missing;
/*where state  in ('CT' 'NJ' 'NY' 'PA' 'FL');*/
class type state maturity bal1;
var bal_june;
table bal1 all, (bal_june )*(N*f=comma24. sum*f=dollar24. mean*f=dollar24. pctN pctsum ) / nocellmerge;
format bal1 afmt.;
run;

data temp;
set hudson.tda (obs=max);
yr = year(mature);
mth = month(mature);
mature1 = yr*100 + mth;
run;

proc tabulate data=temp missing;
/*where state not in ('CT' 'NJ' 'NY' 'PA' 'FL');*/
class mature1;
var bal_june;
table mature1, (N sum*bal_june)*f=comma24. / nocellmerge;
run;


*Average rate analysis;

proc report data=hudson.tda nowd;
column name  bal_june  a avg_rate;
define name / group;
define bal_june / format=dollar18.2 ;
define a / computed;
define avg_rate / computed;
compute a;
   a = rate*bal_june;
endcomp;
compute avg_rate;
   avg_rate = _c3_/_c2_;
endcomp;
run;

title 'CDs';
proc sql;
select name, count(*) as N format=comma12. ,sum(bal_june) format=dollar24.2 as balance, sum(bal_june*rate)  format=dollar24.2 as aux, 
sum(bal_june*rate)/sum(bal_june) format percent12.6 as avg_rate from hudson.tda group by name;
quit;

title 'Savings';
proc sql;
select type, count(*) as N format=comma12. , sum(bal_june) format=dollar24.2 as balance, sum(bal_june*rate)  format=dollar24.2 as aux, 
sum(bal_june*rate)/sum(bal_june) format percent12.6 as avg_rate from hudson.sav group by type;
quit;

title 'DDA and MMS';
proc sql;
select type, count(*) as N format=comma12. , sum(bal_june) format=dollar24.2 as balance, sum(bal_june*rate)  format=dollar24.2 as aux, 
sum(bal_june*rate)/sum(bal_june) format percent12.6 as avg_rate from hudson.dda group by type;

quit;

title 'Interest DDA';
proc sql;
select  count(*) as N format=comma12. , sum(bal_june) format=dollar24.2 as balance, sum(bal_june*rate)  format=dollar24.2 as aux, 
sum(bal_june*rate)/sum(bal_june) format percent12.6 as avg_rate from hudson.dda where type in ('16','17','8') ;
quit;
