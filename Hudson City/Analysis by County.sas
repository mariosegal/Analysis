title 'Profile of HCSB Customers by County';
proc tabulate data=hudson.hudson_hh order=data;
where state ="NJ" 
      or (state eq "NY" and Countynm in ("Westchester","Kings","New York","Orange","Suffolk","Rockland","Essex","Rockland",
                                        "Essex","Putnam","Nassau","Dutchess","Queens","Richmond","Bronx")) 
      or (State = "CT" and countynm = "Fairfield");
class segment products  state products countynm state adj_assets ;
class adj_assets / preloadfmt;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 hh  dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt;
table  state*(countynm='County Name' All), N='HHs'*f=comma12. (dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*sum*f=comma12. / nocellmerge misstext='0';
table state*(countynm='County Name' All), N='HHs'*f=comma12.
			(dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*rowpctsum<hh>*f=pctfmt. 
            /nocellmerge misstext='0.0%';
table state*(countynm='County Name' All), N='HHs'*f=comma12. (dda_amt='Checking'*rowpctsum<dda1> mms_amt='Money Market'*rowpctsum<mms1> sav_amt='Savings'*rowpctsum<sav1> tda_amt='Time Deposits'*rowpctsum<tda1> 
					  ira_amt='IRAs'*rowpctsum<ira1> mtg_amt='Mortgage'*rowpctsum<mtg1> heq_amt='Home Equity'*rowpctsum<heq1> iln_amt='Inst. Loan'*rowpctsum<iln1> 
                      ccs_amt='Overdraft'*rowpctsum<ccs1>)*f=pctdoll./nocellmerge misstext='$0';
table  state*(countynm='County Name' All),(segment ALL)*N*f=comma12. (segment All)*rowpctN*f=pctfmt. / nocellmerge misstext='0';
table  state*(countynm='County Name' All),(adj_assets="Estimated Wealth" ALL)*N*f=comma12. (adj_assets="Estimated Wealth" All)*rowpctN*f=pctfmt. / nocellmerge misstext='0';
keylabel sum='Total' rowpctsum='Avg. Bal.' colpctN='Percent' rowpctN="Percent" ;
format products prods. adj_assets wltamt. state $state. segment hudsonseg. ;
run;

title 'Estimated Wealth for Bergen County Customers';
proc tabulate data=hudson.hudson_hh order=data;
where countynm eq 'Bergen' and state = 'NJ' and ixi_assets ne .;
class segment products  state products ;
class adj_assets / preloadfmt;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 hh  dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt;
table (products ALL), adj_assets*N='HHs'*f=comma12. /nocellmerge misstext='$0';
table (products ALL), adj_assets*rowpctN*f=pctfmt. /nocellmerge misstext='$0';
keylabel sum='Total' rowpctsum='Avg. Bal.' colpctN='Percent' rowpctN="Percent" ;
format products prods. adj_assets wealthband. state $state. segment hudsonseg. ;
run;


title 'Wallet and Opportunity for Bergen County Customers';
proc tabulate data=hudson.hudson_hh ;
where countynm eq 'Bergen' and state = 'NJ';
class segment products  state products ;
var adj: opp: hh;
table (products ALL),sum*hh='HHs'*f=comma12. sum='Total Bal.'*(adj: opp:)*f=dollar24. nocellmerge misstext='0';
table (products ALL),sum*hh='HHs'*f=comma12. rowpctsum<hh>*(adj: opp:)*f=pctdoll. nocellmerge misstext='0';
keylabel sum='Total' rowpctsum='Avg. Bal.' colpctN='Percent' ;
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. ;
run;
