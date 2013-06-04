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

*basic Profile;
proc tabulate data=hudson.hudson_hh order=data missing;
where external ne 1 and products ne . and dda1 eq 1 ;
class bta_group segment products  area_group_new chk_act/ preloadfmt mlf;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt hh;
table (area_group_new all), (hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*sum='HHs'*f=comma12.
													(hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*rowpctsum<hh>='Penetration'*f=pctfmt.
													(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt)*sum='Balances'*f=dollar24.
                                                    (dda_amt*rowpctsum<dda1> mms_amt*rowpctsum<mms1> sav_amt*rowpctsum<sav1> tda_amt*rowpctsum<tda1> ira_amt*rowpctsum<ira1> 
                                                     mtg_amt*rowpctsum<mtg1> heq_amt*rowpctsum<heq1> iln_amt*rowpctsum<iln1> ccs_amt*rowpctsum<ccs1>)*f=pctdoll.
													/ nocellmerge misstext='0';
table (area_group_new all), N*f=comma12. segment*N*f=comma12. segment*rowpctN*f=pctfmt. /nocellmerge misstext='0';
format products prods. segment hudsonseg. bta_group $bta_a.;
run;

*you can add a new row cross by doing
(area_group_new all)*(risk_group all), .....

or create tables for each risk group by doing

risk_group, (area_group_new all), .......
;

