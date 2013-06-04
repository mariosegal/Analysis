data passbook;
set hudson.clean_20121106;
where stype eq 'Passbook';
passbook = 1;
keep pseudo_hh passbook;
run;

proc sort data=passbook out=passbook1 nodupkey;
by pseudo_hh;
run;

options compress=y;
 data hudson.hudson_hh;
length pseudo_hh 8 passbook 8 ;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set passbook1 end=eof1;
	dcl hash hh1 (dataset: 'passbook1', hashexp: 8, ordered:'a');
	hh1.definekey('pseudo_hh');
	hh1.definedata('passbook');
	hh1.definedone();
end;

misses = 0;
do until (eof2);
	set hudson.hudson_hh end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		passbook = 0;
	end;
	output;
end;

putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;



proc datasets library=hudson;
modify hudson_hh;
	label dda='Checking' mms='Money Market' sav='Savings' tda='Time Deposits' ira='IRAs' mtg='Mortgage' heq='HOme Equity' ccs='Overdraft' iln='Inst. Loans'
	      dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' mtg1='Mortgage' heq1='HOme Equity' ccs1='Overdraft' iln1='Inst. Loans'
		  dda_amt='Checking' mms_amt='Money Market' sav_amt='Savings' tda_amt='Time Deposits' ira_amt='IRAs' mtg_amt='Mortgage' heq_amt='HOme Equity' ccs_amt='Overdraft' iln_amt='Inst. Loans';
run;
quit;




title1 'Hudson City Passbook Savings Customer Profile';
proc tabulate data=hudson.hudson_hh order=data missing;
where passbook eq 1;
class bta_group segment products distance adj_tot/ preloadfmt mlf;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt hh;
table (products all), (hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*sum='HHs'*f=comma12.
													(hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*rowpctsum<hh>='Penetration'*f=pctfmt.
													(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt)*sum='Balances'*f=dollar24.
                                                    (dda_amt*rowpctsum<dda1>='Avg. Bal' mms_amt*rowpctsum<mms1>='Avg. Bal' sav_amt*rowpctsum<sav1>='Avg. Bal' tda_amt*rowpctsum<tda1>='Avg. Bal' ira_amt*rowpctsum<ira1>='Avg. Bal' 
                                                     mtg_amt*rowpctsum<mtg1>='Avg. Bal' heq_amt*rowpctsum<heq1>='Avg. Bal' iln_amt*rowpctsum<iln1>='Avg. Bal' ccs_amt*rowpctsum<ccs1>='Avg. Bal')*f=pctdoll. /  MISSTEXT='0.0' nocellmerge;
table (products all), N*f=comma12. (adj_tot ALL)*N*f=comma12. (adj_tot ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
table (products all), N*f=comma12. (segment ALL)*N*f=comma12. (segment ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
table (products all), N*f=comma12. (distance ALL)*N*f=comma12. (distance ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
keylabel rowpctN='Percent' N='HHs';
format products prods. segment hudsonseg. bta_group $bta. adj_tot wltamt. distance distfmt.;
run;


title1 'Hudson City CD Customer Profile';
proc tabulate data=hudson.hudson_hh order=data missing;
where tda1 eq 1;
class bta_group segment products distance adj_tot/ preloadfmt mlf;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt hh;
table (products all), (hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*sum='HHs'*f=comma12.
													(hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*rowpctsum<hh>='Penetration'*f=pctfmt.
													(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt)*sum='Balances'*f=dollar24.
                                                    (dda_amt*rowpctsum<dda1>='Avg. Bal' mms_amt*rowpctsum<mms1>='Avg. Bal' sav_amt*rowpctsum<sav1>='Avg. Bal' tda_amt*rowpctsum<tda1>='Avg. Bal' ira_amt*rowpctsum<ira1>='Avg. Bal' 
                                                     mtg_amt*rowpctsum<mtg1>='Avg. Bal' heq_amt*rowpctsum<heq1>='Avg. Bal' iln_amt*rowpctsum<iln1>='Avg. Bal' ccs_amt*rowpctsum<ccs1>='Avg. Bal')*f=pctdoll. /  MISSTEXT='0.0' nocellmerge;
table (products all), N*f=comma12. (adj_tot ALL)*N*f=comma12. (adj_tot ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
table (products all), N*f=comma12. (segment ALL)*N*f=comma12. (segment ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
table (products all), N*f=comma12. (distance ALL)*N*f=comma12. (distance ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
keylabel rowpctN='Percent' N='HHs';
format products prods. segment hudsonseg. bta_group $bta. adj_tot wltamt. distance distfmt.;
run;

proc tabulate data=hudson.hudson_hh order=data missing;
where tda1 eq 1 and passbook eq 1;
table N;
run;

