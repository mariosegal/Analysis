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

title 'Hudson NJ Wealth Distribution';
proc tabulate data=hudson.hudson_hh ;
where state = "NJ";
class segment products ixi_assets state products;
table  products*segment, N*f=comma12. (ixi_assets ALL)*N*f=comma12. (ixi_assets ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
format products prods. ixi_assets wealthband. state $state. segment hudsonseg.;
run;

title 'MTB Wealth Distribution';
proc tabulate data=data.main_201209 ;
where (products ne 0 and products ne .);
/*and cbr in (6, 8,13,16);*/
class segment products ixi_tot cbr segment;
table  cbr*products*segment,N*f=comma12. (ixi_tot ALL)*N*f=comma12. (ixi_tot ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
format products prods. ixi_tot wealthband. cbr cbr2012fmt. segment mtbseg.;
run;


title 'Hudson(NJ) Average Asset Distribution';
proc tabulate data=hudson.hudson_hh (rename=(IXI_IntChecking=intchk IXI_NonIntChecking=nonintchk IXI_OthChecking=othchk IXI_OtherAssets=other IXI_Annuity=annuity
                                               ixi_bond=bond IXI_Deposits=deposits IXI_Savings=savings IXI_StockAssets=stock IXI_MutualFund=mfunds));
where state = "NJ";
class segment products  state products;
var IXI_Assets Deposits nonintchk intchk othchk Savings IXI__MMS IXI_CD stock mfunds bond annuity other hh;
table  products*segment, N='HHs'*f=comma12. (IXI_Assets Deposits nonintchk intchk othchk Savings
                                       IXI__MMS IXI_CD stock mfunds bond annuity other)*rowpctsum<hh>*f=pctdoll./nocellmerge;
keylabel sum='Total' rowpctsum='Average';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg.;
run;

title 'Hudson(NJ) Average Asset Distribution by Product Ownership';
proc tabulate data=hudson.hudson_hh(rename=(IXI_IntChecking=intchk IXI_NonIntChecking=nonintchk IXI_OthChecking=othchk IXI_OtherAssets=other IXI_Annuity=annuity
                                               ixi_bond=bond IXI_Deposits=deposits IXI_Savings=savings IXI_StockAssets=stock IXI_MutualFund=mfunds))
						out = table missing;
where footprint eq 1 and products ne .;
class segment products  state  dda1 mms1 sav1 tda1 ira1 mtg1 mtx1 heq1 iln1 ccs1;
var IXI_Assets Deposits nonintchk intchk othchk Savings IXI__MMS IXI_CD stock mfunds bond annuity other hh;
table  (products )*(dda1 mms1 sav1 tda1 ira1 mtg1  heq1 iln1 ccs1 ALL), N='HHs'*f=comma12. (IXI_Assets Deposits nonintchk intchk othchk Savings
                                       IXI__MMS IXI_CD stock mfunds bond annuity other)*rowpctsum<hh>*f=pctdoll./nocellmerge;
keylabel sum='Total' rowpctsum='Average';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg.;
run;

data table;
length product $ 15;
set table;
if dda1 then product = 'Checking';
if mms1 then product = 'Money Market';
if sav1 then product = 'Savings';
if tda1 then product = 'Time Deposits';
if mtg1 then product = 'Mortgage';
if heq1 then product = 'Home Equity';
if iln1 then product = 'Ins. Loan';
if ccs1 then product = 'Overdraft';
if ira1 then product = 'IRAs';
if  (dda1  eq . and mms1  eq . and sav1  eq . and tda1  eq . and ira1  eq . and mtg1  eq . and heq1  eq . and iln1  eq . and ccs1 eq .) then product='All';

ixi_cd = sum(of ixi_cd_pctsum:);
IXI_Assets = sum(of IXI_Assets_pctsum:);
Annuity = sum(of Annuity_pctsum:);
BOND = sum(of BOND_pctsum:);
Deposits = sum(of Deposits_pctsum:);
MutualFund = sum(of MFUNDS_pctsum:);
OTHER = sum(of Other_pctsum:);
STOCK = sum(of STOCK_pctsum:);
IntChecking = sum(of INTCHK_pctsum:);
IXI_MMS = sum(of IXI__MMS_pctsum:);
NonIntChK = sum(of NONINTCHK_pctsum:);
OTHCHK = sum(of othchk_pctsum:);
Savings = sum(of Savings_pctsum:);

if dda1 or mms1 or sav1 or tda1 or ira1 or mtg1 or heq1 or iln1 or ccs1 then output;
if  (dda1  eq . and mms1  eq . and sav1  eq . and tda1  eq . and ira1  eq . and mtg1  eq . and heq1  eq . and iln1  eq . and ccs1 eq .) then output;
run;

proc sort data=table;
by products;
run;

proc print data=table noobs;
var products product N ixi_Assets Deposits IntChecking NonIntChK OTHCHK IXI_MMS Savings ixi_cd  Annuity BOND  MutualFund STOCK  OTHER;
format ixi_Assets Deposits IntChecking NonIntChK OTHCHK IXI_MMS Savings ixi_cd  Annuity BOND  MutualFund STOCK  OTHER pctdoll. N comma12.;
run;

data hudson.hudson_hh;
set hudson.hudson_hh;
select ;
	when (age lt 65 and ixi_assets lt 1000000) abbas_grp = 1;
	when (age lt 65 and  ixi_assets ge 1000000 and ixi_assets lt 3000000) abbas_grp = 2;
	when (age lt 65 and  ixi_assets ge 3000000 and ixi_assets le 25000000) abbas_grp = 3;
	when (age ge 65 and ixi_assets lt 1000000) abbas_grp = 4;
	when (age ge 65 and  ixi_assets ge 1000000 and ixi_assets lt 3000000) abbas_grp = 5;
	when (age ge 65 and  ixi_assets ge 3000000 and ixi_assets le 25000000) abbas_grp = 6;
	otherwise abbas_grp=7; 
end;
run;

proc format;
value abbas  
			1 = '<65 and less $1MM'
			2 = '<65 and $1-3MM'
			3 = '<65 and $3MM+'
			4 = '65+ and less $1MM'
			5 = '65+ and $1-3MM'
			6 = '65+ and $3MM+';
run;

						
proc tabulate data=hudson.hudson_hh (rename=(IXI_IntChecking=intchk IXI_NonIntChecking=nonintchk IXI_OthChecking=othchk IXI_OtherAssets=other IXI_Annuity=annuity
                                               ixi_bond=bond IXI_Deposits=deposits IXI_Savings=savings IXI_StockAssets=stock IXI_MutualFund=mfunds));
where state = "NJ";
class segment products  state products abbas_grp;
var IXI_Assets Deposits nonintchk intchk othchk Savings IXI__MMS IXI_CD stock mfunds bond annuity other hh;
table  abbas_grp='', N='HHs'*f=comma12. (IXI_Assets Deposits nonintchk intchk othchk Savings
                                       IXI__MMS IXI_CD stock mfunds bond annuity other)*rowpctsum<hh>*f=pctdoll./nocellmerge;
keylabel sum='Total' rowpctsum='Average';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. abbas_grp abbas.;
run;

proc tabulate data=hudson.hudson_hh ;
where state = "NJ";
class segment products  state products abbas_grp;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 hh  dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt;
table  products*(abbas_grp='' ALL), N='HHs'*f=comma12. (dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*sum*f=comma12.;
table products*(abbas_grp='' ALL), N='HHs'*f=comma12.
			(dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*rowpctsum<hh>*f=pctfmt. /nocellmerge misstext='0.0%';
table products*(abbas_grp='' ALL), N='HHs'*f=comma12. (dda_amt='Checking'*rowpctsum<dda1> mms_amt='Money Market'*rowpctsum<mms1> sav_amt='Savings'*rowpctsum<sav1> tda_amt='Time Deposits'*rowpctsum<tda1> 
					  ira_amt='IRAs'*rowpctsum<ira1> mtg_amt='Mortgage'*rowpctsum<mtg1> heq_amt='Home Equity'*rowpctsum<heq1> iln_amt='Inst. Loan'*rowpctsum<iln1> 
                      ccs_amt='Overdraft'*rowpctsum<ccs1>)*f=pctdoll./nocellmerge misstext='$0';
keylabel sum='Total' rowpctsum='';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. abbas_grp abbas.;
run;

proc tabulate data=hudson.hudson_hh ;
where state = "NJ" and dda1 ne 1 and (tda1 eq 1 or ira1 eq 1);
class segment products  state products abbas_grp;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 hh  dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt;
table  products*(abbas_grp='' ALL), N='HHs'*f=comma12. (dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*sum*f=comma12.;
table products*(abbas_grp='' ALL), N='HHs'*f=comma12.
			(dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*rowpctsum<hh>*f=pctfmt. /nocellmerge misstext='0.0%';
table products*(abbas_grp='' ALL), N='HHs'*f=comma12. (dda_amt='Checking'*rowpctsum<dda1> mms_amt='Money Market'*rowpctsum<mms1> sav_amt='Savings'*rowpctsum<sav1> tda_amt='Time Deposits'*rowpctsum<tda1> 
					  ira_amt='IRAs'*rowpctsum<ira1> mtg_amt='Mortgage'*rowpctsum<mtg1> heq_amt='Home Equity'*rowpctsum<heq1> iln_amt='Inst. Loan'*rowpctsum<iln1> 
                      ccs_amt='Overdraft'*rowpctsum<ccs1>)*f=pctdoll./nocellmerge misstext='$0';
keylabel sum='Total' rowpctsum='';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. abbas_grp abbas.;
run;



*steve page 8;

proc tabulate data=DATA.MAIN_201209 order=data missing;
where products ne 0 and products ne .;
var dda: mms: tda: sav: mtg: heq: iln: ccs: ira: hh sec: card ins;
class products   /mlf preloadfmt;
class segment/ preloadfmt;
class distance /preloadfmt;
CLASS CBR / PRELOADFMT;
table CBR, sum='All'*hh='HHs'*f=comma12. 
               (dda='Checking' mms='Mon Mkt' sav='Savings' tda='Time Dep' ira='IRA' mtg='Mortgage' 
               iln='Ins Loan' heq='Home Eq' sec='Securities' ins='Insurance' card='Credit Card')*pctsum<hh>='Penet'*f=pctfmt. 
			   (dda_amt='Checking'*pctsum<dda>='Avg. Bal.' mms_amt='Mon Mkt'*pctsum<mms>='Avg. Bal.' sav_amt='Savings'*pctsum<sav>='Avg. Bal.' 
                tda_amt='Time Dep'*pctsum<tda>='Avg. Bal.' ira_amt='IRA'*pctsum<ira>='Avg. Bal.' mtg_amt='Mortgage'*pctsum<mtg>='Avg. Bal.' 
                iln_amt='Ind Loan'*pctsum<iln>='Avg. Bal.' heq_amt='Home Eq'*pctsum<heq>='Avg. Bal.' ccs_amt='Credit Card'*pctsum<card>='Avg. Bal.'
                sec_amt='Securities'*pctsum<sec>='Avg. Bal.' )*f=pctdoll.
			   segment*(N*f=comma12.) segment*colpctN*f=pctfmt. distance*colPCTn*f=pctfmt.   / nocellmerge;
format products prods. segment mtbseg. distance distfmt. assets ixi. CBR CBR2012FMT.;
run;

data temp;
merge DATA.MAIN_201209 (in=a keep=hhid dda: mms: tda: sav: mtg: heq: iln: ccs: ira: hh sec: card ins products) DATA.contrib_201209(in=b);
by hhid;
if a and b;
run;


proc tabulate data=temp order=data missing;
where products ne 0 and products ne .;
var dda: mms: tda: sav: mtg: heq: iln: ccs: ira: hh sec: card ins card_con contrib;
CLASS CBR / PRELOADFMT;
table CBR,   (dda_con='Checking' mms_con='Mon Mkt' sav_con='Savings' tda_con='Time Dep' ira_con='IRA'mtg_con='Mortgage'
                iln_con='Ind Loan' heq_con='Home Eq' card_con='Credit Card'
                sec_con='Securities' contrib='Total')*pctsum<hh>='Avg. Bal.'*f=pctdoll.  / nocellmerge misstext='$0.0';
format CBR CBR2012FMT.;
run;

*check analysis;

proc tabulate data=hudson.hudson_hh out=table;
where state = "NJ" and dda1=1 ;
class segment products  state products cqi:;
var dda1 hh;
table   (cqi:), products*(N='HHs'*f=comma12. colpctN*f=pctfmt.)/nocellmerge;
table ALL cqi_debit*cqi_web*cqi_bp* cqi_dd*cqi_odl,( hh*sum*f=comma12. hh*colpctN);
keylabel sum='Total' ;
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. abbas_grp abbas.;
run;



data table;
set table;
where _table_ eq 2;
run;

proc print data=table noobs;
var cqi: hh_sum hh_pctn_0000000;
label cqi_debit='Debit' cqi_web='Web Banking' cqi_dd='Direct Deposit' cqi_bp='Bill Pay' cqi_odl='Overdraft' hh_sum='HHs' hh_pctn_0000000='%';
format hh_pctn_0000000 pctfmt. hh_sum comma12. cqi: binary_flag.;
run;

proc print data=table noobs;
var cqi: hh_sum hh_pctn_0000000;
label cqi_debit='Debit' cqi_web='Web Banking' cqi_dd='Direct Deposit' cqi_bp='Bill Pay' cqi_odl='Overdraft' hh_sum='HHs' hh_pctn_0000000='%';
format hh_pctn_0000000 pctfmt. hh_sum comma12. cqi: binary_flag.;
run;






proc tabulate data=DATA.MAIN_201209 out=table1;
where  dda=1 ;
class segment products  state products cqi:;
var dda hh;
table   (cqi:), products*(N='HHs'*f=comma12. colpctN*f=pctfmt.)/nocellmerge;
table ALL cqi_deb*cqi_web*cqi_bp* cqi_dd*cqi_odl,( hh*sum*f=comma12. hh*colpctN);
keylabel sum='Total' ;
format products prods.  state $state. segment mtbseg. ;
run;



data table1;
set table1;
where _table_ eq 2;
run;

proc print data=table1 noobs;
var cqi: hh_sum hh_pctn_0000000;
label cqi_deb='Debit' cqi_web='Web Banking' cqi_dd='Direct Deposit' cqi_bp='Bill Pay' cqi_odl='Overdraft' hh_sum='HHs' hh_pctn_0000000='%';
format hh_pctn_0000000 pctfmt. hh_sum comma12. cqi: binary_flag.;
run;



proc tabulate data=hudson.hudson_hh;
where state = "NJ" and dda1=1 ;
class segment products  state products cqi;
var dda1 cqi_dd cqi_debit cqi_odl cqi_web cqi_bp hh;
table   hh*sum*f=comma12.  (cqi_debit='Debit' cqi_web='Web Banking' cqi_dd='Direct Deposit' cqi_bp='Bill Pay' cqi_odl='Overdraft'   )*colpctsum<hh>*f=pctfmt. 
        cqi*hh*colpctsum<hh>*f=pctfmt., products/nocellmerge;
keylabel sum='Total' ;
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. abbas_grp abbas.;
run;

data hudson.hudson_hh;
set hudson.hudson_hh;
select ;
	when (dda1 eq 1 and cqi_dd eq 1 and (cqi_bp eq 1 or cqi_odl eq 1) ) active = 1;
	otherwise active = 0;
end;
run;

proc tabulate data=hudson.hudson_hh missing;
where state = "NJ" and dda=1 ;
class active products;
table active,products*N;
/*format products prods.;*/
run;


proc tabulate data=hudson.hudson_hh missing;
where dda1 eq 1 and state="NJ";
class segment products  state products abbas_grp active distance;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 hh  dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt;
table  Active*products*(abbas_grp='' ALL), N='HHs'*f=comma12. (dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*rowpctsum<hh>*f=pctfmt. /nocellmerge misstext='0.0%';
table active*products*(abbas_grp='' ALL), N='HHs'*f=comma12. (dda_amt='Checking'*rowpctsum<dda1> mms_amt='Money Market'*rowpctsum<mms1> sav_amt='Savings'*rowpctsum<sav1> tda_amt='Time Deposits'*rowpctsum<tda1> 
					  ira_amt='IRAs'*rowpctsum<ira1> mtg_amt='Mortgage'*rowpctsum<mtg1> heq_amt='Home Equity'*rowpctsum<heq1> iln_amt='Inst. Loan'*rowpctsum<iln1> 
                      ccs_amt='Overdraft'*rowpctsum<ccs1>)*f=pctdoll./nocellmerge misstext='$0';
table active*products*(abbas_grp='' ALL), distance*rowPCTN*f=pctfmt. / nocellmerge misstext='0.0%';
keylabel sum='Total' rowpctsum='';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. abbas_grp abbas. active binary_flag. distance distfmt.;
run;

proc freq data=hudson.Hudson_hh;
where dda1 eq 1 and state="NJ";
table products*active / missing;
run;

*MTB by abbas groups;

data age;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\age.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input hhid $ age;
run;

data data.main_201209;
merge  data.main_201209(in=a) age (in=b);
by hhid;
if a;
run;


data data.main_201209;
set data.main_201209;
select ;
	when (age lt 65 and ixi_tot lt 1000000) abbas_grp = 1;
	when (age lt 65 and  ixi_tot ge 1000000 and ixi_tot lt 3000000) abbas_grp = 2;
	when (age lt 65 and  ixi_tot ge 3000000 and ixi_tot le 25000000) abbas_grp = 3;
	when (age ge 65 and ixi_tot lt 1000000) abbas_grp = 4;
	when (age ge 65 and  ixi_tot ge 1000000 and ixi_tot lt 3000000) abbas_grp = 5;
	when (age ge 65 and  ixi_tot ge 3000000 and ixi_tot le 25000000) abbas_grp = 6;
	otherwise abbas_grp=7; 
end;
run;

proc freq data=data.main_201209 (keep=abbas_grp);
table abbas_grp / missing;
run;

proc tabulate data=DATA.MAIN_201209 order=data missing;
where products ne 0 and products ne .;
var dda: mms: tda: sav: mtg: heq: iln: ccs: ira: hh sec: card ins;
class products   /mlf preloadfmt;
class segment/ preloadfmt;
class distance /preloadfmt;
class abbas_grp / preloadfmt;
table products*abbas_grp, sum='All'*hh='HHs'*f=comma12. 
               (dda='Checking' mms='Mon Mkt' sav='Savings' tda='Time Dep' ira='IRA' mtg='Mortgage' 
               iln='Ind Loan' heq='Home Eq' sec='Securities' ins='Insurance' card='Credit Card')*pctsum<hh>='Penet'*f=pctfmt. 
			   (dda_amt='Checking'*pctsum<dda>='Avg. Bal.' mms_amt='Mon Mkt'*pctsum<mms>='Avg. Bal.' sav_amt='Savings'*pctsum<sav>='Avg. Bal.' 
                tda_amt='Time Dep'*pctsum<tda>='Avg. Bal.' ira_amt='IRA'*pctsum<ira>='Avg. Bal.' mtg_amt='Mortgage'*pctsum<mtg>='Avg. Bal.' 
                iln_amt='Ind Loan'*pctsum<iln>='Avg. Bal.' heq_amt='Home Eq'*pctsum<heq>='Avg. Bal.' ccs_amt='Credit Card'*pctsum<card>='Avg. Bal.'
                sec_amt='Securities'*pctsum<sec>='Avg. Bal.' )*f=pctdoll.
			   segment*(N*f=comma12.) segment*colpctN*f=pctfmt. distance*colPCTn*f=pctfmt.   / nocellmerge;
format products prods. segment mtbseg. distance distfmt.  CBR CBR2012FMT. abbas_grp abbas.;

run;

