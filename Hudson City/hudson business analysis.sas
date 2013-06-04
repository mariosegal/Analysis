proc format;
value  prods (notsorted )
	      1 = 'Single'
		2-high = 'Multi';

value $ state 'CT' = 'CT'
              'NY' = 'NY'
			  'NJ' = 'NJ'
			other = 'Other';
run;

proc format;
value hudsonseg (notsorted)
   1 = 'Building Their Future'
2 = 'Mainstream Family'
4 = 'Mass Affluent Family'
3 = 'Mainstream Retired'
5 = 'Mass Affluent Retired'
6 = 'Unable to Code';
run;

proc format;
value mtbseg (notsorted)
   1 = 'Building Their Future'
3 = 'Mainstream Family'
2 = 'Mass Affluent Family'
4 = 'Mass Affluent Family'
5 = 'Mainstream Retired'
6 = 'Mass Affluent Retired'
Other = 'Unable to Code';
run;

data hudson.business_hh;
set hudson.business_hh;
prods_bus1 = prods_bus;
run;


proc tabulate data=hudson.business_hh;
where bus=1;
class prods_bus;
var dda_bus mms_bus sav_bus mtg_bus cln_bus dda_amt_bus mms_amt_bus sav_amt_bus mtg_amt_bus cln_amt_bus hh prods_con con prods_bus1;
table 	(hh='HHs' dda_bus='Checking' mms_bus='Money Mkt' sav_bus='Savings' mtg_bus='Mortgage' cln_bus='Comm. Loan')*sum*f=comma12. 
      	(dda_bus='Checking' mms_bus='Money Mkt' sav_bus='Savings' mtg_bus='Mortgage' cln_bus='Comm. Loan')*colpctsum<hh>*f=pctfmt.
		con='With Consumer'*(sum*f=comma12. colpctsum<hh>*f=pctfmt.)
	  	(dda_amt_bus='Checking avg.'*colpctsum<dda_bus> mms_amt_bus='Money Mkt avg.'*colpctsum<mms_bus> 
         sav_amt_bus='Savings avg.'*colpctsum<sav_bus> mtg_amt_bus='Mortgage avg.'*colpctsum<mtg_bus> 
         cln_amt_bus='Comm. Loan  avg.'*colpctsum<cln_bus>)*f=pctdoll.
		 prods_bus1='Avg. Bus Prods'*colpctsum<hh>*f=pctcomma. , prods_bus ALL
		/nocellmerge misstext='0.0';
format prods_bus prods.;
run;


