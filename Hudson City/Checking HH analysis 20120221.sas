proc freq data=hudson.hudson_hh;
where dda1 eq 1;
table chk_act;
run;

proc format ;
value $ state (notsorted)
'NY' = 'New York'
'NJ' = 'New Jersey'
'CT' = 'Connecticut'
'' = 'No State'
other = 'Other';
run;

proc format;
value  prods (notsorted )
	      1 = 'Single'
		2-high = 'Multi';

value $ state (notsorted) 'CT' = 'CT'
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
6, . = 'Unable to Code';
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
value $bta (notsorted multilabel)
	'NJ' = 'New Jersey'
	'Upstate' = 'Upstate'
	'LI' = 'Long Island'
	'CT' = 'Connecticut'
	'NJ' = 'NJ/SI'
	'Staten' = 'NJ/SI'
	'Upstate' = 'NY xSI'
	'LI' = 'NY xSI'
	'Upstate' = 'NY'
	'Staten' = 'NY'
	'LI' = 'NY'
	'CT','LI','Staten','NJ','Upstate' = 'Footprint'
	other = 'Other';
value $bta_a (notsorted multilabel)
	'NJ' = 'New Jersey'
	'Upstate' = 'NY'
	'LI' = 'NY'
	'Staten' = 'NY'
	'CT' = 'Connecticut'
	'CT','LI','Staten','NJ','Upstate' = 'Footprint'
	other = 'Other';
run;

title 'Hudson City Wealth Distribution';
proc tabulate data=hudson.hudson_hh order=data missing;
where dda1 eq 1;
class bta_group segment products adj_tot state products state chk_act/ preloadfmt mlf;
table  state, chk_act all, N*f=comma12. (adj_tot ALL)*N*f=comma12. (adj_tot ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
table  state, chk_act all, N*f=comma12. (segment ALL)*N*f=comma12. (segment ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
format state $state. products prods. adj_tot wltamt.  segment hudsonseg. bta_group $bta.;
run;

*note: I did not do segments separately as the distribution could be gotten from above in excel;

title 'Hudson City Product Ownership and Balances';
proc tabulate data=hudson.hudson_hh order=data missing;
where dda1 eq 1;
class bta_group segment products  state chk_act/ preloadfmt mlf;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt hh;
table state, chk_act all , (hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*sum='HHs'*f=comma12.
													(hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*rowpctsum<hh>='Penetration'*f=pctfmt.
													(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt)*sum='Balances'*f=dollar24.
                                                    (dda_amt*rowpctsum<dda1> mms_amt*rowpctsum<mms1> sav_amt*rowpctsum<sav1> tda_amt*rowpctsum<tda1> ira_amt*rowpctsum<ira1> 
                                                     mtg_amt*rowpctsum<mtg1> heq_amt*rowpctsum<heq1> iln_amt*rowpctsum<iln1> ccs_amt*rowpctsum<ccs1>)*f=pctdoll.
													/ nocellmerge misstext='0';
format state $state. products prods. segment hudsonseg. bta_group $bta.;
run;
