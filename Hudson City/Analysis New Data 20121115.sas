proc freq data=hudson.all_20121106 noprint;
table acct_nbr / out=freq1;
run;

Title 'Accts by HH'
proc freq data=freq1;
table count;
run;





proc format ;
value hudsontdatype '62' '63' '67' '70' '71' '72' '73' '74' '75' '76' '77' '78' '79' '84' '69' = 'IRA'
                    '04' '09' '10' '13' '14' '16' '18' '20' '21' '22' '24' '25' '27' '29' '30' '80' = 'TDA';
value hudsonsavtype '01' '41' '31' '22' '23' = 'SAV';
value hudsonchktype '02' '03' '01' '04' '06'  '08'  '12'  '14'  '16' '17' '21' = 'DDA'
                    '05' '09' '13' '15' '21' = 'BUS';
run;


proc freq data=hudson.clean_20121106;
table type subtype source status SBU/ missing;
run;

proc freq data=hudson.clean_20121106;
where type ='SAV';
table type*subtype / missing;
run;

*do savings first;
proc format;
value $ savings 	'01' = 'Passbook'
				'41', '60' = 'Statement'
				'31', '32' = 'MMA Sav'
				'22' = 'Hlday Club'
				'23' = 'Vacat Club'
				'54' = 'Rent Scty'
				'55' = 'landlord';
value $ sbu 	'54' ,'55' = 'BUS'
				other = 'CON';
value $ product   '01', '41',  '22', '23', '54', '55' = 'SAV'
				'31' = "MMS"
 				'60' ,'32' = 'IRA';
run;

proc contents data=hudson.clean_20121106 varnum short; run;



proc format;
value $ checking 	'02' = 'Employee'
					'03' = 'Estate'
					'01','04','06' = 'Regular'
					'05' = 'Business'
					'08' = 'Super'
					'09' = 'Br Exp'
					'12' = 'MMA'
					'13' = 'Atny Trust'
					'14' = 'Consumer'
					'15' = 'Bus MMA'
					'16' = 'High Value'
					'17' = 'Better Int'
					'10' = 'IOLTA'
					'07' = 'Public'
					'20','21','22','23','24','28' = "Internal";
value $ chktype     '12','15' = 'MMS'
                    Other = 'DDA';
value $ chksbu 		'05','13','15','07' = 'BUS'
					'09','20','21','22','23','24','28' = 'INT'
					Other = 'CON';
run;


data temp;
length PTYPE $ 3 stype $ 10 sbu_new $ 3;
set hudson.clean_20121106;
if TYPE = 'SAV' then do;
	PTYPE = put(subtype, $product.);
	STYPE = put(subtype, $savings.);
	SBU_NEW = put(subtype, $sbu.);
end;
if TYPE = 'CHKG' then do;
	PTYPE = put(subtype, $chktype.);
	STYPE = put(subtype, $checking.);
	SBU_NEW = put(subtype, $chksbu.);
end;
run;

proc tabulate data=temp missing;
where type = 'CHKG';
class ptype stype type subtype sbu sbu_new;
table (sbu*sbu_new)*(type*ptype), subtype*stype*N*f=comma12.;
run;

proc format;
value $ cdtype	'24','04','10','14','21','09','27','13','18','16','25','29','30','20','22','80' = 'TDA'
				'72','62','63','67','71','79','75','74','70','76','68','73','77','78','84','69' = 'IRA';
value $ cdstype (notsorted) '24','72' = '91 day'
				'04','62'='4M'
				'10','63'='5M'
				'14','67'='6M'
				'21','71'='7M'
				'09','79'='9M'
				'27','75'='1Y'
				'13','74'='13M'
				'18','70','76'='18M'
				'16','20','68' = '2Y'
				'25','22','73','84' = '3Y'
				'29','77'='4Y'
				'30','78'='5Y'
				'80','69'='OTH';
run;

data temp;
length PTYPE $ 3 stype $ 10 sbu_new $ 3;
set temp;
if TYPE = 'CD' then do;
	PTYPE = put(subtype, $cdtype.);
	STYPE = put(subtype, $cdstype.);
	SBU_NEW = "CON";
end;

run;

proc tabulate data=temp missing;
where type = 'CD';
class ptype stype type subtype sbu sbu_new;
table (sbu*sbu_new)*(type*ptype), subtype*stype*N*f=comma12.;
run;

proc format;
value $ ptype45a '01','02','03','04','05','06','07','08','09' = 'HEQ'
                 '12','13','14' = 'CCS'
				 '41' = 'CLN'
				 '42' = 'CLN'
				 '43'='CLN';
value $ ptype51a '20','40','41','42','43','57','56','52' = 'ILN'
 				 '54' = 'CLN'
                 '58','59' = 'ILN';
value $ ptype52a '01' = 'ILN';
value $ sbu45a '01','02','03','04','05','06','07','08','09','12','13','14' = 'CON'
				'41','42','43' = 'BUS';
value $ sbu51a '54' = 'BUS'
				other = 'CON';
value $ sbu50a '50','51','52' = 'BUS'
				other = 'CON';
run;

*final  processing;
options compress=yes;

data hudson.clean_20121106;
length PTYPE $ 3 stype $ 10 sbu_new $ 3;
set hudson.clean_20121106;
if TYPE = 'SAV' then do;
	PTYPE = put(subtype, $product.);
	STYPE = put(subtype, $savings.);
	SBU_NEW = put(subtype, $sbu.);
end;
if TYPE = 'CHKG' then do;
	PTYPE = put(subtype, $chktype.);
	STYPE = put(subtype, $checking.);
	SBU_NEW = put(subtype, $chksbu.);
end;
if TYPE = 'CD' then do;
	PTYPE = put(subtype, $cdtype.);
	STYPE = put(subtype, $cdstype.);
	SBU_NEW = "CON";
end;
if substr(acct_nbr,1,2) = '45' then do;
	PTYPE = put(subtype, $ptype45a.);
	STYPE = subtype;
	SBU_NEW = put(subtype, $sbu45a.);
end;
if substr(acct_nbr,1,2) = '51' then do;
	PTYPE = put(subtype, $ptype51a.);
	STYPE = subtype;
	SBU_NEW = put(subtype, $sbu51a.);
end;
if substr(acct_nbr,1,2) = '52' then do;
	PTYPE = put(subtype, $ptype52a.);
	STYPE = subtype;
	SBU_NEW = "CON";
end;
if substr(acct_nbr,1,2) = '50' then do;
	PTYPE = "MTG";
	STYPE = subtype;
	SBU_NEW = put(subtype, $sbu50a.);
end;
run;

proc sort data= hudson.hh_keys_20121106 (keep=acct_nbr pseudo_hh) out=keys nodupkey;
by acct_nbr;
run;

data hudson.clean_20121106;
merge hudson.clean_20121106 (in=a) keys (keep=acct_nbr pseudo_hh in=b);
by acct_nbr;
if a;
run;

*now I can start the analysis (finally!!!);

proc format;
value  status 1 = 'Open'
			   2 = 'Dormant';
run;

Title 'Acct Counts by Type';
proc tabulate data=hudson.clean_20121106 missing;
class sbu_new ptype status;
table PTYPE,SBU_new*STATUS*N*f=comma12. / nocellmerge;
format status status.;
run;

Title 'Acct Balances by Type';
proc tabulate data=hudson.clean_20121106 missing;
class sbu_new ptype status;
var curr_bal;
table PTYPE,sbu_new*STATUS*curr_bal*f=dollar24. / nocellmerge;
format status status.;
run;
Title;

Title 'Accts by Type ansd MOunt';
proc tabulate data=hudson.clean_20121106 missing;
class sbu_new ptype status curr_bal;
var ;
table PTYPE,sbu_new*curr_bal*f=comma12. / nocellmerge;
format status status. curr_bal amtband.;
run;
Title;

*create the HH table;

proc freq data=hudson.clean_20121106;
table ptype*curr_bal / missing nocol norow;
format curr_bal amtband.;
run;


proc sort data=hudson.clean_20121106 ;
by pseudo_hh sbu_new;
run;

proc summary data=hudson.clean_20121106;
by pseudo_hh sbu_new;
output out=hhsbu ;
run;

proc transpose data=hhsbu out = hhsbu1;
by pseudo_hh;
var _freq_;
id sbu_new;
run;

data hhsbu1;
set hhsbu1;
if con eq . then con =0;
if bus eq . then bus = 0;
if int eq . then int = 0;
con1 = min(1,con);
bus1 = min(1,bus);
int1=min(1,int);
run;

proc tabulate data=hhsbu1;
class con1 bus1 int1;
table con1*bus1*int1 ALL,N*f=comma12.;
run;

proc freq data=hudson_hh order=freq;
where con1 eq 1;
table (state)/ missing;
run;

*by product;
proc sort data=hudson.clean_20121106 ;
by pseudo_hh ptype;
run;


proc summary data=hudson.clean_20121106 (where=( sbu_new='CON'));
by pseudo_hh ptype;
output out=hhptype 
       sum(curr_bal) = bal;
run;


proc transpose data=hhptype out = hhptype1;
by pseudo_hh;
var _freq_;
id ptype;
run;

data hhptype1;
set hhptype1;
if dda eq . then dda =0;
if mms eq . then mms = 0;
if sav eq . then sav = 0;
if tda eq . then tda =0;
if ira eq . then ira = 0;
if mtg eq . then mtg = 0;
if heq eq . then heq =0;
if iln eq . then iln = 0;
if ccs eq . then ccs = 0;
if mtx eq . then mtx = 0;

dda1=min(1,dda);
mms1=min(1,mms);
sav1=min(1,sav);
tda1=min(1,tda);
ira1=min(1,ira);
mtg1=min(1,mtg);
heq1=min(1,heq);
iln1=min(1,iln);
ccs1=min(1,ccs);
mtx1=min(1,mtx);

run;


*bals by product;

proc transpose data=hhptype out = hhbals1 suffix=_amt;
by pseudo_hh;
var bal;
id ptype;
run;

*create HH datasets;

data hudson_hh;
merge hhsbu1 (in=a drop=_name_) hhptype1 (in=b drop=_name_) hhbals1 (in=c drop=_name_);
by pseudo_hh;
if a or b or c;
run;

data hudson_hh;
set hudson_hh;
products = sum(dda1, mms1, sav1, tda1, ira1, mtg1, iln1, ccs1, heq1,mtx1);
accts = sum(dda, mms, sav, tda, ira, mtg, iln, ccs, heq,mtx);
products1 = products;
hh=1;
run;

proc format;
value accts 1 = 1
            2 = 2
			3 = 3
			4 = 4
			5= 5
			6-high = 6;
run;

title 'Number of Products';
proc tabulate data=hudson_hh missing;
where con1=1;
class products accts;
table accts ALL, (products ALL)*N*f=comma12.;
table accts ALL, N*f=comma12.;
table (products ALL),N*f=comma12.;
format accts accts.;
run;

proc format;
value  prods (notsorted multilabel)
	      1 = 'Single'
	    2 = '2'
		3 = '3'
		4 = '4'
		5= '5'
		6-high = '6+'
		2-high = 'Multi';
run;

Title 'Product Ownership and Average Balances';
proc tabulate data=hudson_hh order=data;
where con1=1;
var dda: mms: tda: sav: mtg: heq: iln: ccs: ira:;
class products segment /mlf preloadfmt;
table N='HHs'*f=comma12.   (dda1 mms1 sav1 tda1 ira1 mtg1 iln1 ccs1 heq1)*sum='HH Counts'*f=comma12. 
               (dda mms sav tda ira mtg iln ccs heq)*sum='Accts'*f=comma12.
			   (dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt iln_amt ccs_amt heq_amt)*sum='Balances'*f=dollar24.
			   segment*N*f=comma12., products  ALL;
format products prods. segment hudsonseg. ;
run;


proc format ;
value ixi (notsorted)
		low - 100000 = 'Up to $100M'
		100000 -< 250000 = '$100M to 250M'
		250000 -< 500000 = '$250M to 500M'
		500000 -< 750000 = '$500M to 750M'
		750000 -< 1000000 = '$750M to 1MM'
		1000000 -< 2000000 = '$1MM to 2MM'
		2000000 - high = 'Over $2MM'
		. = 'Unknown';
run;

%let var = hh=1;
%let name = Any Product;

Title "Product Ownership HHs Having &name";
proc tabulate data=hudson.hudson_hh order=data missing;
where con1=1 and &var = 1;
var dda: mms: tda: sav: mtg: heq: iln: ccs: ira: hh mtx:;
class products   /mlf preloadfmt;
class segment/ preloadfmt;
class distance /preloadfmt;
class assets /preloadfmt;
table sum='All'*hh='HHs'*f=comma12.   (dda1='Checking' mms1='Mon Mkt' sav1='Savings' tda1='Time Dep' ira1='IRA' mtg1='Svcd. Mtg.' 
               mtx1='Non Svcd Mtg' iln1='Ind Loan' ccs1='Overdraft' heq1='Home Eq')*sum='HH Counts'*f=comma12. 
               (dda1='Checking' mms1='Mon Mkt' sav1='Savings' tda1='Time Dep' ira1='IRA' mtg1='Mortgage' mtx1='Non Svcd Mtg.' 
               iln1='Ind Loan' ccs1='Overdraft' heq1='Home Eq')*pctsum<hh>='Penet'*f=pctfmt. 
               (dda='Checking' mms='Mon Mkt' sav='Savings' tda='Time Dep' ira='IRA' mtg='Mortgage' iln='Ind Loan' ccs='Overdraft' heq)*sum='Accts'*f=comma12.
			   (dda_amt='Checking' mms_amt='Mon Mkt' sav_amt='Savings' tda_amt='Time Dep' ira_amt='IRA' mtg_amt='Mortgage' mtx_amt='Non Svcd Mtg'
                iln_amt='Ind Loan' ccs_amt='Overdraft' heq_amt='Home Eq')*sum='Balances'*f=dollar24.
			   (dda_amt='Checking'*pctsum<dda1>='Avg. Bal.' mms_amt='Mon Mkt'*pctsum<mms1>='Avg. Bal.' sav_amt='Savings'*pctsum<sav1>='Avg. Bal.' 
                tda_amt='Time Dep'*pctsum<tda1>='Avg. Bal.' ira_amt='IRA'*pctsum<ira1>='Avg. Bal.' mtg_amt='Mortgage'*pctsum<mtg1>='Avg. Bal.' 
                mtx_amt='Non Svcd Mtg'*pctsum<mtx1>='Avg. Bal.' iln_amt='Ind Loan'*pctsum<iln1>='Avg. Bal.' ccs_amt='Overdraft'*pctsum<ccs1>='Avg. Bal.' heq_amt='Home Eq'*pctsum<heq1>='Avg. Bal.')*f=pctdoll.
			   segment*(N*f=comma12.) segment*colpctN*f=pctfmt. distance*N*f=comma12. distance*colPCTn*f=pctfmt. assets*colPCTn*f=pctfmt. , products  ALL /nocellmerge;
format products prods. segment hudsonseg. distance distfmt. assets ixi.;
run;


*cross ownership for multi;

data temp;
set hudson_hh (keep= con1 products dda1 mms1 sav1 tda1 ira1 mtg1 mtx1 heq1 iln1 ccs1) ;
dda2 = dda1;
mms2 = mms1;
sav2 = sav1;
tda2 = tda1;
ira2 = ira1;
mtg2=mtg1;
mtx2=mtx1;
heq2=heq1;
iln2=iln1;
ccs2=ccs1;
run;



Title 'cross ownership for multi product HHs';
proc tabulate data=temp  missing out=hudson_cross;
where con1=1 and products gt 1;
CLASS dda1 mms1 sav1 tda1 ira1 mtg1 mtx1 heq1 iln1 ccs1 dda2 mms2 sav2 tda2 ira2 mtg2 mtx2 heq2 iln2 ccs2;
table (dda1 mms1 sav1 tda1 ira1 mtg1 mtx1 heq1 iln1 ccs1),(dda2 mms2 sav2 tda2 ira2 mtg2 mtx2 heq2 iln2 ccs2) / nocellmerge;
run;


data hudson_cross1;
set hudson_cross;
where sum(dda1,mms1,sav1,tda1,ira1,mtg1,mtx1,heq1,iln1,ccs1,dda2,mms2,sav2,tda2,ira2,mtg2,mtx2,heq2,iln2,ccs2)=2;
drop _type_ _page_ _table_ ;
rename N=HHs;

run;

data hudson_cross1;
length x $ 20 y $ 120;
set hudson_cross1;
if (dda1 = 1) then x = 'Checking';
else if (mms1 = 1) then x = 'Money Market';
else if (sav1 = 1) then x = 'Savings';
else if (tda1 = 1) then x = 'Time Deposits';
else if (ira1 = 1) then x = 'IRA';
else if (mtg1 = 1) then x = 'Svcd Mortgage';
else if (mtx1 = 1) then x = 'Non Svcd Mortgage';
else if (heq1 = 1) then x = 'Home Equity';
else if (iln1 = 1) then x = 'Inst. Loan.';
else if (ccs1 = 1) then x = 'Overdraft';

if (dda2 = 1) then y = 'Checking';
else if (mms2 = 1) then y = 'Money Market';
else if (sav2 = 1) then y = 'Savings';
else if (tda2 = 1) then y = 'Time Deposits';
else if (ira2 = 1) then y = 'IRA';
else if (mtg2 = 1) then y = 'Svcd Mortgage';
else if (mtx2 = 1) then y = 'Non Svcd Mortgage';
else if (heq2 = 1) then y = 'Home Equity';
else if (iln2 = 1) then y = 'Inst. Loan.';
else if (ccs2 = 1) then y = 'Overdraft';
run;

proc format;
value $ productx (notsorted)
      'Checking' = 'Checking'
	'Money Market' = 'Money Market'
	'Savings' = 'Savings'
	'Time Deposits'= 'Time Deposits'
	'IRA'= 'IRA'
	'Svcd Mortgage'= 'Svcd Mortgage'
	'Non-Svcd Mortgage'= 'Non Svcd Mortgage'
	'Home Equity'= 'Home Equity'
	'Inst. Loan'= 'Inst. Loan'
	 'Overdraft'= 'Overdraft';
run;

	

proc tabulate data=hudson_cross1 missing order=data;
class x y /preloadfmt;
var HHs;
table x ALL,(y ALL)*sum*hhs*f=comma12. / nocellmerge;
table x ALL,(y ALL)*rowpctsum*hhs*f=pctfmt. / nocellmerge;
format x y $productx.;
run;


*###################################################################################
MTB Comparison;


data data.main_201209;
set data.main_201209;
products = sum( dda, mms, tda, ira, sav, mtg, heq, ind, iln, card, sec, ins, sdb, sln, trs);
run;

proc freq data=data.main_201209;
table products;
run;


proc tabulate data=DATA.MAIN_201209 order=data missing;
where products ne 0 and products ne .;
var dda: mms: tda: sav: mtg: heq: iln: ccs: ira: hh ;
class products   /mlf preloadfmt;
class segment/ preloadfmt;
class distance /preloadfmt;
CLASS CBR / PRELOADFMT;
table CBR, sum='All'*hh='HHs'*f=comma12.   (dda='Checking' mms='Mon Mkt' sav='Savings' tda='Time Dep' ira='IRA' mtg='Svcd. Mtg.' 
                iln='Ind Loan'  heq='Home Eq' ccs='Overdraft')*sum='HH Counts'*f=comma12. 
               (dda='Checking' mms='Mon Mkt' sav='Savings' tda='Time Dep' ira='IRA' mtg='Mortgage' 
               iln='Ind Loan' heq='Home Eq' ccs='Overdraft')*pctsum<hh>='Penet'*f=pctfmt. 
			   (dda_amt='Checking' mms_amt='Mon Mkt' sav_amt='Savings' tda_amt='Time Dep' ira_amt='IRA' mtg_amt='Mortgage' 
                iln_amt='Ind Loan'  heq_amt='Home Eq')*sum='Balances'*f=dollar24.
			   (dda_amt='Checking'*pctsum<dda1>='Avg. Bal.' mms_amt='Mon Mkt'*pctsum<mms1>='Avg. Bal.' sav_amt='Savings'*pctsum<sav1>='Avg. Bal.' 
                tda_amt='Time Dep'*pctsum<tda1>='Avg. Bal.' ira_amt='IRA'*pctsum<ira1>='Avg. Bal.' mtg_amt='Mortgage'*pctsum<mtg1>='Avg. Bal.' 
                iln_amt='Ind Loan'*pctsum<iln1>='Avg. Bal.' heq_amt='Home Eq'*pctsum<heq1>='Avg. Bal.')*f=pctdoll.
			   segment*(N*f=comma12.) segment*colpctN*f=pctfmt. distance*colPCTn*f=pctfmt.  , products  ALL /nocellmerge;
format products prods. segment mtbseg. distance distfmt. assets ixi. CBR CBR2012FMT.;
run;

proc tabulate data=DATA.MAIN_201209 order=data missing;
where products ne 0 and products ne . and cbr in (1,12,13);
var dda: mms: tda: sav: mtg: heq: iln: ccs: ira: hh ;
class products   /mlf preloadfmt;
class segment/ preloadfmt;
class distance /preloadfmt;
CLASS CBR / PRELOADFMT;
table CBR, sum='All'*hh='HHs'*f=comma12.   (dda='Checking' mms='Mon Mkt' sav='Savings' tda='Time Dep' ira='IRA' mtg='Svcd. Mtg.' 
                iln='Ind Loan'  heq='Home Eq' ccs='Overdraft')*sum='HH Counts'*f=comma12. 
               (dda='Checking' mms='Mon Mkt' sav='Savings' tda='Time Dep' ira='IRA' mtg='Mortgage' 
               iln='Ind Loan' heq='Home Eq' ccs='Overdraft')*pctsum<hh>='Penet'*f=pctfmt. 
			   (dda_amt='Checking' mms_amt='Mon Mkt' sav_amt='Savings' tda_amt='Time Dep' ira_amt='IRA' mtg_amt='Mortgage' 
                iln_amt='Ind Loan'  heq_amt='Home Eq')*sum='Balances'*f=dollar24.
			   (dda_amt='Checking'*pctsum<dda>='Avg. Bal.' mms_amt='Mon Mkt'*pctsum<mms>='Avg. Bal.' sav_amt='Savings'*pctsum<sav>='Avg. Bal.' 
                tda_amt='Time Dep'*pctsum<tda>='Avg. Bal.' ira_amt='IRA'*pctsum<ira>='Avg. Bal.' mtg_amt='Mortgage'*pctsum<mtg>='Avg. Bal.' 
                heq_amt='Home Eq'*pctsum<heq>='Avg. Bal.' iln_amt='Ind Loan'*pctsum<iln>='Avg. Bal.' )*f=pctdollm.
			   segment*(N*f=comma12.) segment*colpctN*f=pctfmt. distance*colPCTn*f=pctfmt.  , products  ALL /nocellmerge;
format products prods. segment mtbseg. distance distfmt. assets ixi. CBR CBR2012FMT.;
run;


*read segments;
data segments;
length acct_nbr $ 14 ssn_1 $ 9 dob $ 10 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Segment_Final_Export.txt' dsd dlm='09'x lrecl=4096 missover firstobs=2 obs=max ;
input pseudo_hh  acct_nbr $ ssn_1 $ DOb $ age Assets :comma24.2 segment;
run;

proc sort data=segments;
by pseudo_hh;
run;

data primaries;
set hudson.clean_20121106;
keep pseudo_hh acct_nbr ssn_1;
run;

*merge primaries into clean;

proc sort data=hudson.clean_20121106;
by acct_nbr ssn_1;
run;

proc sort data=segments;
by acct_nbr ssn_1;
run;

data hudson.clean_20121106;
merge hudson.clean_20121106 (in=a) segments (in=b keep = acct_nbr ssn_1 segment assets age);
by acct_nbr ssn_1;
if a;
run;

*assign hierarchy;
data hudson.clean_20121106;
set hudson.clean_20121106;
select (PTYPE);
	when ('DDA') order =1;
	when ('MMS') order=2;
	when ('SAV') order=3;
	when ("TDA") order=4;
	when ('IRA') order=5;
	when ('MTG') order=6;
	when ('HEQ') order=7;
	when ('ILN') order=8;
	when ('CCS') order=9;
	when ('CLN') order=10;
	when ('MTX') order=11;
	otherwise order=99;
end;
run;

proc freq data=hudson.clean_20121106;
table ptype /missing;
table order /missing;
run;

proc sort data=hudson.clean_20121106;
by pseudo_hh order descending curr_bal;
run;

proc sql;
select count(distinct pseudo_hh) from hudson.clean_20121106;
quit;


data primaries;
set hudson.clean_20121106;
by pseudo_hh;
if first.pseudo_hh then output;
keep age assets segment pseudo_hh;
run;

data hudson_hh;
merge hudson_hh (in=a) primaries (in=b);
by pseudo_hh;
if a  ;
run;

proc freq data=hudson_hh;
table segment /missing;
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
7 = 'Unable to Code';
run;

*read distance to branch;
data closest;
length acct_nbr $ 14 ssn_1 $ 9 snl_key $ 25;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Closest Branch Final Export.txt' dsd dlm='09'x lrecl=4096 missover firstobs=2 obs=max ;
input pseudo_hh  acct_nbr $ ssn_1 $ snl_key $ distance:comma12.2;
run;

proc sort data=closest;
by acct_nbr ssn_1;
run;

proc sort data=hudson.clean_20121106;
by acct_nbr ssn_1;
run;

data hudson.clean_20121106;
merge hudson.clean_20121106 (in=a) closest (in=b );
by acct_nbr ssn_1;
if a;
run;

proc sort data=hudson.clean_20121106;
by pseudo_hh order descending curr_bal;
run;

data primaries1;
set hudson.clean_20121106;
by pseudo_hh;
if snl_key eq '' then distance = -1;
if first.pseudo_hh then output;
keep distance snl_key pseudo_hh;
run;

data hudson_hh;
merge hudson_hh (in=a) primaries1 (in=b);
by pseudo_hh;
if a  ;
run;

data hudson.hudson_hh;
set hudson_hh;
if distance eq . then distance = -1;
run;


*add distance from clean;
data closest1;
set hudson.clean_20121106;
if snl_key eq '' then distance = -1;
if first.pseudo_hh then output;
by pseudo_hh;
keep pseudo_hh distance open state snl_key lat long;
run;

data hudson_hh;
merge hudson_hh (in=a) closest1 (in=b);
by pseudo_hh;
if a  ;
run;

proc means data=hudson_hh;
var distance;
run;

data hudson_hh;
set hudson_hh;
if distance eq -1 and state ne '' then distance =50;
run;

