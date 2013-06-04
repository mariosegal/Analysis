data hudson.hudson_hh;
set hudson.hudson_hh;
liquid = sum(mms_amt, sav_amt,tda_amt,ira_amt);
products_new = sum(dda1,mms1,sav1,tda1,ira1,heq1,iln1,mtg1,ccs1);
run;

proc tabulate data=hudson.hudson_hh missing;
where products_new ge 1 and products_new le 8 and ixi_assets ne .;
class ixi_assets products_new liquid;
table (ixi_assets all), products_new*N=' '*f=comma12. / nocellmerge misstext='0';
table (ixi_assets all), liquid*N=' '*f=comma12. /nocellmerge misstext='0';
format liquid balband. ixi_assets ixifmt. ;
run;

proc format ;
value mtgamt (notsorted)
	low-<100000 = 'Under 100M'
	100000-<200000 = '100M to 200M'
	200000-<300000 = '200M to 300M'
	300000-<400000 = '300M to 400M'
	400000-<500000 = '400M to 500M'
	500000-<750000 = '500M to 750M'
	750000-<1000000 = '750M to 1MM'
	1000000-high = 'Over 1MM';
run;


proc tabulate data=hudson.hudson_hh missing;
where products_new ge 1 and products_new le 8 and ixi_assets ne .;
where also mtg1 eq 1;
class ixi_assets products_new mtg_amt;
table (ixi_assets all), products_new*N=' '*f=comma12. / nocellmerge misstext='0';
table (ixi_assets all), (products_new)*mtg_amt*N=' '*f=comma12. /nocellmerge misstext='0';
format  ixi_assets ixifmt. products_new prods. mtg_amt mtgamt.;
run;

proc format;
value $ mystate (notsorted) 'NY' = 'NY'
            'NJ' = 'NJ'
			'CT' = 'CT'
			'PA' = 'PA'
			'MA'='MA'
			'FL'='FL'
			'DE'='DE'
			'CA'='CA'
			'AZ'='AZ'
			other ='Other';
value bands 3000000-<10000000 = '$3 to $10MM'
			10000000-<25000000 = '$10 to $25MM'
			25000000-high = '$25MM Plus';
run;


proc tabulate data=hudson.hudson_hh order=data missing;
where products_new ge 1 and products_new le 8 and ixi_assets  ge 3000000;
class  segment ixi_assets products_new state / preloadfmt ;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt hh;
table (state all)*(ixi_assets all), (hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*sum='HHs'*f=comma12.
													(hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*rowpctsum<hh>='Penetration'*f=pctfmt.
													(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt)*sum='Balances'*f=dollar24.
                                                    (dda_amt*rowpctsum<dda1> mms_amt*rowpctsum<mms1> sav_amt*rowpctsum<sav1> tda_amt*rowpctsum<tda1> ira_amt*rowpctsum<ira1> 
                                                     mtg_amt*rowpctsum<mtg1> heq_amt*rowpctsum<heq1> iln_amt*rowpctsum<iln1> ccs_amt*rowpctsum<ccs1>)*f=pctdoll.
													/ nocellmerge misstext='0';
table (state all)*(ixi_assets all), N*f=comma12. segment*N*f=comma12. segment*rowpctN*f=pctfmt. /nocellmerge misstext='0';
format products_new prods. ixi_assets bands. segment hudsonseg. state $mystate.;
run;

proc tabulate data=hudson.hudson_hh order=data missing;
where products_new ge 1 and products_new le 8 and ixi_assets  ge 3000000 and mtg1 eq 1;
class  segment ixi_assets products_new state / preloadfmt ;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt hh;
table products_new, (state all)*(ixi_assets all), (hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*sum='HHs'*f=comma12.
													(hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*rowpctsum<hh>='Penetration'*f=pctfmt.
													(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt)*sum='Balances'*f=dollar24.
                                                    (dda_amt*rowpctsum<dda1> mms_amt*rowpctsum<mms1> sav_amt*rowpctsum<sav1> tda_amt*rowpctsum<tda1> ira_amt*rowpctsum<ira1> 
                                                     mtg_amt*rowpctsum<mtg1> heq_amt*rowpctsum<heq1> iln_amt*rowpctsum<iln1> ccs_amt*rowpctsum<ccs1>)*f=pctdoll.
													/ nocellmerge misstext='0';
table (state all)*(ixi_assets all), N*f=comma12. segment*N*f=comma12. segment*rowpctN*f=pctfmt. /nocellmerge misstext='0';
format products_new prods. ixi_assets bands. segment hudsonseg. format state $mystate.;
run;
