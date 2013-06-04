LIBNAME HUDSON1 ODBC DSN=Hudsonsql user=Reporting_User pw=Reporting2 schema=dbo;

proc freq data=hudson1.Loans noprint ;
table ACCT_NBR / out=dump;
run;

proc freq data=dump;
table count;
run;


*it apperar max SSN is 10, so I will transpose into 10 colums;

%macro primaries();

%do i = 1 %to 4 ;

	%if &i eq 1 %then %let name = Checking;
	%if &i eq 2 %then %let name = Deposits;
	%if &i eq 3 %then %let name = Loans;
	%if &i eq 4 %then %let name = LineOfCredit;

	data Hudson.&name._new;
	set hudson1.HC_&name;
	by ACCT_NBR;
	primary = 0; 
	if first.ACCT_NBR and last.ACCT_NBR then do;
	    *if first and last then it must be only one record;
		primary = 1; 
	end;
	else do; 
		*Now I need to look for the 1 in the string;
		if substr(SSN_TYPE,1,1) eq 1 or substr(SSN_TYPE,3,1) eq 1 then primary =1;
	end;
	run;

	proc sort data=Hudson.&name._new;
	by acct_nbr descending primary;
	run;

%end;

%mend;

options mcompilenote=ALL;
%primaries()


*test if there are same acct snumber across files;

data a;
merge hudson.lineofcredit_new (keep=acct_nbr in=a) hudson.loans_new (keep=acct_nbr in=b);
by acct_nbr;
if a and b;
run;

*no collisiosn found;

*read stad data files;
data std_loans;
length acct_nbr $ 14 SSN_1 $ 9 DOB $ 10 add1 $ 255 add2 $ 255 city $ 255 state $ 2 zip $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\HC_Loans_std_tab_Mario.txt' dsd dlm='09'x lrecl=4096 missover firstobs=2;
input acct_nbr $  SSN_1 $  DOB $  add1 $  add2 $  city $  state $ zip $ long lat;
run;

data std_deposits;
length acct_nbr $ 14 SSN_1 $ 9 DOB $ 10 add1 $ 255 add2 $ 255 city $ 255 state $ 2 zip $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\HC_deposits_std_tab_Mario.txt' dsd dlm='09'x lrecl=4096 missover firstobs=2;
input acct_nbr $  SSN_1 $  DOB $  add1 $  add2 $  city $  state $ zip $ long lat;
run;

data std_checking;
length acct_nbr $ 14 SSN_1 $ 9 DOB $ 10 add1 $ 255 add2 $ 255 city $ 255 state $ 2 zip $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\HC_checking_std_tab_Mario.txt' dsd dlm='09'x lrecl=4096 missover firstobs=2;
input acct_nbr $  SSN_1 $  DOB $  add1 $  add2 $  city $  state $ zip $ long lat;
run;

data std_lineofcredit;
length acct_nbr $ 14 SSN_1 $ 9 DOB $ 10 add1 $ 255 add2 $ 255 city $ 255 state $ 2 zip $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\HC_lineofcredit_std_tab_Mario.txt' dsd dlm='09'x lrecl=4096 missover firstobs=2;
input acct_nbr $  SSN_1 $  DOB $  add1 $  add2 $  city $  state $ zip $ long lat;
run;

data std;
set std_checking std_deposits std_loans std_lineofcredit;
run;

data std;
set std;
key =  catx('*',add1,add2,city,state,zip);
run;

proc sort data=std out=uniques (keep=key) nodupkey;
by key;
run;

data  uniques;
set uniques;
pseudo_hh = _N_;
run;

proc sort data=std;
by key;
run;

data std;
merge std (in=a) uniques (in=b);
by key;
if a;
run;


data hudson.hh_keys;
set std;
keep acct_nbr ssn_1 dob pseudo_hh key;
run;

proc sort data=hudson.hh_keys nodupkey;
by acct_nbr ssn_1;
run;

proc tabulate data=hudson.checking_new missing;
class type subtype;
table type*subtype, N*f=comma12.;
run;


proc format library=sas;
value hudsontdatype '62' '63' '67' '70' '71' '72' '73' '74' '75' '76' '77' '78' '79' '84' '69' = 'IRA'
                    '04' '09' '10' '13' '14' '16' '18' '20' '21' '22' '24' '25' '27' '29' '30' '80' = 'TDA';
value hudsonsavtype '01' '41' '31' '22' '23' = 'SAV';
value hudsonchktype '02' '03' '01' '04' '06'  '08'  '12'  '14'  '16' '17' '21' = 'DDA'
                    '05' '09' '13' '15' '21' = 'BUS';
run;

proc freq data=temp1;
table sub*app;
run;

