data temp_sec;
set data.main_201206;
keep hh dda mms sav tda ira mtg heq iln ind card sec ins ixi_tot wealth cbr;
wealth = max(ixi_tot,sum(dda_amt,mms_amt,sav_amt,tda_amt,ira_amt,sec_amt));
run;



proc tabulate data=temp_sec missing;
where sec eq 1;
class wealth cbr;
table cbr all, (wealth all)*(N*f=comma12.);
format wealth wealthband. cbr cbr2012fmt.;
run;


proc tabulate data=temp_sec missing;
where sec ne 1;
class wealth cbr;
table cbr all, (wealth all)*(N*f=comma12.);
format wealth wealthband. cbr cbr2012fmt.;
run;


proc tabulate data=temp_sec missing;
where sec eq 1;
class wealth cbr;
var hh dda mms sav tda ira mtg heq iln ind card sec ins;
table (cbr all)*((hh='HHs' dda='Checking' mms='Money Market' sav='Savings' tda='Time Deposits' ira='IRAs' mtg='Mortgage' heq='Home Equity' 
                 iln='Inst. Loan' ind='Ind. Loan' card='Credit Card' sec='Securities' ins='Insurance')*(sum*f=comma12.)
                 (dda='Checking' mms='Money Market' sav='Savings' tda='Time Deposits' ira='IRAs' mtg='Mortgage' heq='Home Equity' 
                 iln='Inst. Loan' ind='Ind. Loan' card='Credit Card' sec='Securities' ins='Insurance')*(pctsum<hh>*f=pctfmt.)), (wealth all);
format wealth wealthband. cbr cbr2012fmt.;
run;

proc tabulate data=temp_sec missing;
where sec ne 1;
class wealth cbr;
var hh dda mms sav tda ira mtg heq iln ind card sec ins;
table (cbr all)*((hh='HHs' dda='Checking' mms='Money Market' sav='Savings' tda='Time Deposits' ira='IRAs' mtg='Mortgage' heq='Home Equity' 
                 iln='Inst. Loan' ind='Ind. Loan' card='Credit Card' sec='Securities' ins='Insurance')*(sum*f=comma12.)
                 (dda='Checking' mms='Money Market' sav='Savings' tda='Time Deposits' ira='IRAs' mtg='Mortgage' heq='Home Equity' 
                 iln='Inst. Loan' ind='Ind. Loan' card='Credit Card' sec='Securities' ins='Insurance')*(pctsum<hh>*f=pctfmt.)), (wealth all);
format wealth wealthband. cbr cbr2012fmt.;
run;
