%squeeze(hudson.deposits_new,hudson.deposits_20121106)

options compress=yes;

data hudson.checking_20121106;
set hudson.checking_20121106;
run;

%squeeze(hudson.hh_keys, hudson.hh_keys_20121106)


data hudson.all_20121106;
set hudson.checking_20121106 hudson.deposits_20121106 hudson.loans_20121106 hudson.lines_20121106;
run;

proc sort data=hudson.all_20121106;
by acct_nbr SSN_1;
run;

proc summary data=hudson.all_20121106;
by acct_nbr  ssn_1;
output out=temp1 max(PRIMARY)=primary;
run;

data temp1;
set temp1;
rename SSN_1=SSN;
run;

proc sort data=temp1;
by acct_nbr descending primary;
run;

data hudson.ssns_20121106;
set temp1(obs=max);
by acct_nbr;
retain count SSN_PRIMARY SSN_2 SSN_3 SSN_4 SSN_5 SSN_6 SSN_7 SSN_8 SSN_9 SSN_10;
IF first.acct_nbr then do;
	count=1;
	ssn_primary = ssn;
end;
else do;
   count+1;
   select (count);
       when (2) ssn_2 = ssn;
	   when (3) ssn_3 = ssn;
	   when (4) ssn_4 = ssn;
	   when (5) ssn_5 = ssn;
	   when (6) ssn_6 = ssn;
	   when (7) ssn_7 = ssn;
	   when (8) ssn_8 = ssn;
	   when (9) ssn_9 = ssn;
	   when (10) ssn0 = ssn;
	end;
end;
if last.acct_nbr then DO;
   output;
   SSN_PRIMARY = '';
   SSN_2 = '';
   SSN_3 = '';
   SSN_4 = '';
   SSN_5 = '';
   SSN_6 = '';
   SSN_7 = '';
   SSN_8 = '';
   SSN_9 = '';
   SSN_10 = '';
END;
run;

proc sort data=hudson.all_20121106;
by acct_nbr descending primary;
run;

proc sort data=hudson.all_20121106 out=a nodupkey;
by acct_nbr;
run;

proc sql; 
select count(distinct acct_nbr) from hudson.hh_keys_20121106;
select count(distinct acct_nbr) from hudson.all_20121106;
select count(distinct acct_nbr) from hudson.all_20121106 where primary eq 1;
run;

data hudson.clean_20121106;
set hudson.all_20121106;
by acct_nbr;
if first.acct_nbr then output;
run;



