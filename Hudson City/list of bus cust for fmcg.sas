data bus;
set hudson.clean_20121106;
where sbu_new ne "CON";
keep name_: add: city country  phon: acct_nbr state zip;
drop address_key name_key;
run;

proc sort data=bus;
by acct_nbr;
run;

data bus1;
merge bus (in=a) hudson.ssns_20121106 (in=b keep = acct_nbr ssn_:);
by acct_nbr;
if a;
run;

proc export data=bus1 outfile='C:\Documents and Settings\ewnym5s\My Documents\Hudson City\bus_customers.xlsx' dbms=excel;
run;
