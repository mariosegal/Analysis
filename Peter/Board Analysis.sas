libname virtual 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled';
libname Data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname wip 'C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files';
libname board 'C:\Documents and Settings\ewnym5s\My Documents\Peter';

 libname IXI_NEw oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=IXI;
 Data Source=bagels"  schema=dbo; 

 libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
options fmtsearch=(SAS);


 /*read the 2012 hierarchy file */
 filename mytxt 'C:\Documents and Settings\ewnym5s\My Documents\References\CBRs and Market 2012.txt';

 data data.Hierarchy_2012;
 length mkt_2012 $ 3 zip $ 5 cbr_2012 $ 3;
 infile mytxt DLM='09'x firstobs=2 lrecl=4096 dsd ;
 input mkt_2012 $ zip $ cbr_2012 $;
 run;

 proc freq data=data.hierarchy_2012;
 table cbr_2012*mkt_2012;
 run;


/* merge new cbr and zip to data files */
proc sort data=data.main_201112;
by zip;
run;

proc sort data=data.hierarchy_2012;
by zip;
run;

data test;
merge data.main_201112 (in=a) data.hierarchy_2012 (in=b);
by zip;
if a;
run;

proc freq data=test;
table cbr*cbr_2012 /norow nocol nopercent missing;
run;

proc freq data=test;
table market*mkt_2012 /norow nocol nopercent missing;
run;

data data.main_201112;
set test;
if mkt_2012 eq '' then mkt_2012 = '99';
if cbr_2012 eq '' then cbr_2012 = '99';
run;

proc freq data=data.main_201112;
table cbr_2012 MKT_2012 /norow nocol nopercent missing;
run;

/*Aggregate data and wallet for customers */

data wip.customer_data;
set data.main_201112;
keep hhid ixi: deposits loans securities hh cbr_2012 zip segment dep_wallet sec_wallet wallet adj_dep_wallet adj_sec_wallet adj_wallet 
     zip dep_hh loan_hh sec_hh dda mms sav tda ira sec mtg card heq iln ind sln mtg_amt heq_amt ccs_amt iln_amt ind_amt sln_amt hh; 
deposits = sum (dda_amt, sav_amt, ira_amt, tda_amt, mms_amt);
loans = sum(mtg_amt, heq_amt, ccs_amt, iln_amt, ind_amt, sln_amt);
securities = sec_amt;
dep_wallet = sum(ixi_tda,ixi_savings, ixi_mms, ixi_non_int_chk, ixi_int_chk);
sec_wallet = ixi_tot - dep_wallet;
wallet = ixi_tot;
adj_dep_wallet = max(dep_wallet, deposits);
adj_sec_wallet = max(securities, sec_wallet);
adj_wallet = sum(adj_dep_wallet,adj_sec_wallet);
dep_hh = 0;
if sum(dda,mms,sav,tda,ira) gt 1 then dep_hh = 1;
loan_hh = 0;
if sum(mtg,card,iln, ind,sln,heq) gt 1 then loan_hh = 1;
sec_hh = sec;
run;

/* aggregate wallet details */

proc freq data=wip.customer_data;
table segment / missing;
run;


proc tabulate data=wip.customer_data missing;
class cbr_2012 segment;
var hh dep_hh loan_hh sec_hh adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities;
table cbr_2012, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. /nocellmerge;
table cbr_2012*segment, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. / nocellmerge;
format cbr_2012 $cbrfmt. segment segfmt.;
run;


data wip.customer_data;
length asset_band $ 10;
set wip.customer_data;
select ;
	when (adj_wallet lt 100000)  asset_band = 'Mainstream';
	when (adj_wallet ge 100000 and adj_wallet lt 1000000)  asset_band = 'Mass Affl';
	when (adj_wallet gt  1000000)  asset_band = 'Affluent';
end;
run;



proc tabulate data=wip.customer_data missing;
class asset_band cbr_2012;
var hh dep_hh loan_hh sec_hh adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities;
table cbr_2012, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. /nocellmerge;
table cbr_2012*asset_band, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. / nocellmerge;
format cbr_2012 $cbrfmt. segment segfmt.;
run;


proc freq data=customer_data;
table segment cbr_2012 / missing;
/*format format cbr_2012 $cbrfmt. segment segfmt.;*/
run;

/* do analysis for market, using new cbrs;*/

data ixi_data;
set ixi_new.mtb_postal;
where cycleid eq 201106;
run;

proc sort data=ixi_data;
by regionzipcode;
run;

data ixi_data;
merge ixi_data(in=a rename=(regionzipcode=zip)) data.hierarchy_2012 (in=b) data.cbsa_clean (in=c keep=zip cbsa_fips cbsa_name);
by zip;
if a;
run;

proc freq data=ixi_data;
table cbr_2012 mkt_2012 / missing nocum nopercent;
run;

data ixi_data;
set ixi_data;
if cbr_2012 eq '' then cbr_2012 = '99';
if mkt_2012 eq '' then mkt_2012 = '99';
run;

proc freq data=ixi_data;
table cbr_2012 mkt_2012 / missing nocum nopercent;
run;

proc tabulate data=work.ixi_data;
class cbr_2012;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks 
TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds;
tables (cbr_2012='CBR_2012'), (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks )*sum='Total Balances'*f=dollar24. /nocellmerge;
tables (cbr_2012='CBR_2012'),(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds)*SUM='HH Counts'*f=comma12. / nocellmerge;
format cbr_2012 $cbrfmt.;
run;

/* wealth band analysis */
proc sql;
create table ixi_bands as
	Select *
	From IXI_NEW.MTB_Tiers_Postal
	where cycleID = 201106;
quit;



proc sort data=ixi_bands;
by regionzipcode;
run;

data ixi_bands;
merge ixi_bands(in=a rename=(regionzipcode=zip)) data.hierarchy_2012 (in=b) data.cbsa_clean (in=c keep=zip cbsa_fips cbsa_name);
by zip;
if a;
run;

data ixi_bands;
set ixi_bands;
if cbr_2012 eq '' then cbr_2012 = '99';
if mkt_2012 eq '' then mkt_2012 = '99';
run;

proc tabulate data=ixi_bands;
class cbr_2012;
var _NUMERIC_;
tables (cbr_2012='CBR_2012'), (ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds 
        T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds T2mTo3mHouseholds T3mTo5mHouseholds 
        T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds)*SUM='Total HHs'*f=comma12.0 / nocellmerge;
tables	(cbr_2012='CBR_2012'),(ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
         T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
         T10mTo15mDollars T15mTo25mDollars T25mPlusDollars )*SUM='Total $$$s'*f=Dollar24.0 /nocellmerge ;
format cbr_2012 $cbrfmt.;
run;

/*analyze product penetration */
proc tabulate data=data.main_201112;
var hh dda mms sav tda ira sec trs ins mtg heq card iln ind sln sdb;
class cbr_2012 segment;
table cbr_2012*segment, (hh dda mms sav tda ira sec trs ins mtg heq card iln ind sln sdb)*sum='HHs'*f=comma12. / nocellmerge;
format cbr_2012 $cbrfmt. segment segfmt.;
run;


/*read cbsa file*/

filename mytxt 'C:\Documents and Settings\ewnym5s\My Documents\References\zip07_cbsa06.txt';

data data.cbsa;
length zip $ 5 zip4 $ 4 zip9 $ 9 fips $ 2 state $ 2 county_fips $ 5 county_name $ 50 cbsa_fips $ 5 cbsa_name $ 50 cbsa_lsad $ 40 ;
/*metro_code $ 5 metro_name $ 50 metro_lsad $ 20 csa_code $ 5 csa_name $ 50 csa_lsad $ 20;*/
infile mytxt dlm=',' firstobs=2 lrecl=4096 dsd;
input zip $ zip4 $  zip9 $  fips $  state $  county_fips $  county_name $  cbsa_fips $  cbsa_name $  cbsa_lsad $  ;
/*metro_code $  metro_name $  metro_lsad $  csa_code $  csa_name $  csa_lsad $ ;*/
if cbsa_name eq '' then delete;
run;

proc sort data=data.cbsa;
by zip;
run;

data data.cbsa_clean ;
set data.cbsa ;
/*where cbsa_lsad eq 'Metropolitan Statistical Area';*/
by zip;
if first.zip then output;
run;


/*filename mytxt 'C:\Documents and Settings\ewnym5s\My Documents\References\cbsa names.txt';*/
/*data cbsa_names;*/
/*length cbsa_name $ 50 cbsa 5;*/
/*infile mytxt dlm='09'x firstobs=2 lrecl=4096 dsd;*/
/*input cbsa_name $ cbsa ;*/
/*run;*/
/**/
/*proc sort data=data.cbsa;*/
/*by cbsa;*/
/*run;*/
/**/
/*proc sort data=cbsa_names;*/
/*by cbsa;*/
/*run;*/
/**/
/*data data.cbsa;*/
/*merge data.cbsa (in=a) cbsa_names (in=b);*/
/*by cbsa;*/
/*if a;*/
/*run;*/
/**/
/*proc sort data=data.cbsa;*/
/*by zcta5;*/
/*run;*/

data test1;
merge data.main_201112 (in=a ) data.cbsa_clean (in=b keep=zip cbsa_fips cbsa_name);
by zip;
if a;
run;

data data.main_201112;
set test1;
run;


proc freq data=test1 order=freq;
where cbsa_fips in('12580','20100','49620','40380','28740','30500','25180','25420','39100','40060','39740','35620','47900',
                   '37980','42580','45060','23900','29540','27060','20700','13780','15380','30260','41540','44300','10900',
                   '12860','33100','36180','20660','16540','12180','42380','42780','30820','19060','18500','46540','10580',
                   '30140','21300','36460','44980','15700','18660','14100','27460','42900','11020','39060','42540','48060','48700','20180');
table cbsa_name*cbr_2012 / nocol norow nopercent missing;
run;


data data.main_201112;
set test1;
run;


/* wallet analysis by cbsa */

data wip.customer_data;
set data.main_201112;
keep hhid ixi: deposits loans securities hh cbr_2012 zip segment dep_wallet sec_wallet wallet adj_dep_wallet adj_sec_wallet adj_wallet 
     zip dep_hh loan_hh sec_hh dda mms sav tda ira sec mtg card heq iln ind sln mtg_amt heq_amt ccs_amt iln_amt ind_amt sln_amt cbsa_fips cbsa_name state ;
deposits = sum (dda_amt, sav_amt, ira_amt, tda_amt, mms_amt);
loans = sum(mtg_amt, heq_amt, ccs_amt, iln_amt, ind_amt, sln_amt);
securities = sec_amt;
dep_wallet = sum(ixi_tda,ixi_savings, ixi_mms, ixi_non_int_chk, ixi_int_chk);
if sum(ixi_tda,ixi_savings, ixi_mms, ixi_non_int_chk, ixi_int_chk) eq . then deposit_wallet = 0;
sec_wallet = sum(ixi_tot, -1*dep_wallet);
if sum(ixi_tot, -1*dep_wallet) eq . then sec_wallet = 0;
wallet = ixi_tot;
adj_dep_wallet = max(dep_wallet, deposits);
adj_sec_wallet = max(securities, sec_wallet);
adj_wallet = sum(adj_dep_wallet,adj_sec_wallet);
dep_hh = 0;
if sum(dda,mms,sav,tda,ira) gt 1 then dep_hh = 1;
loan_hh = 0;
if sum(mtg,card,iln, ind,sln,heq) gt 1 then loan_hh = 1;
sec_hh = sec;
run;


proc freq data=wip.customer_data;
table cbsa_name;
run;

title 'Share of Wallet by MSA - Footprint MSAs';
proc tabulate data=wip.customer_data missing classdata=class;
where cbsa_fips in('12580','20100','49620','40380','28740','30500','25180','25420','39100','40060','39740','35620','47900',
                   '37980','42580','45060','23900','29540','27060','20700','13780','15380','30260','41540','44300','10900',
                   '12860','33100','36180','20660','16540','12180','42380','42780','30820','19060','18500','46540','10580',
                   '30140','21300','36460','44980','15700','18660','14100','27460','42900','11020','39060','42540','48060','48700','20180');
class cbsa_name segment;
var hh dep_hh loan_hh sec_hh adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities;
table cbsa_name, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. /nocellmerge;
table cbsa_name*segment, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. / nocellmerge;
format  segment segfmt.;
run;

title 'Share of Wallet by MSA - Footprint no MSA';
proc tabulate data=wip.customer_data missing classdata=segment;
where cbsa_fips not in('12580','20100','49620','40380','28740','30500','25180','25420','39100','40060','39740','35620','47900',
                   '37980','42580','45060','23900','29540','27060','20700','13780','15380','30260','41540','44300','10900',
                   '12860','33100','36180','20660','16540','12180','42380','42780','30820','19060','18500','46540','10580',
                   '30140','21300','36460','44980','15700','18660','14100','27460','42900','11020','39060','42540','48060','48700','20180') and cbr_2012 ne '99';
class  segment;
var hh dep_hh loan_hh sec_hh adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities;
/*table ALL, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. /nocellmerge;*/
table segment, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. / nocellmerge;
format  segment segfmt.;
run;

title 'Share of Wallet by MSA - Out of Footprint ';
proc tabulate data=wip.customer_data missing classdata=segment;
where cbsa_fips not in('12580','20100','49620','40380','28740','30500','25180','25420','39100','40060','39740','35620','47900',
                   '37980','42580','45060','23900','29540','27060','20700','13780','15380','30260','41540','44300','10900',
                   '12860','33100','36180','20660','16540','12180','42380','42780','30820','19060','18500','46540','10580',
                   '30140','21300','36460','44980','15700','18660','14100','27460','42900','11020','39060','42540','48060','48700','20180') and cbr_2012 eq '99';
class  segment;
var hh dep_hh loan_hh sec_hh adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities;
/*table ALL, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. /nocellmerge;*/
table segment, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. / nocellmerge;
format  segment segfmt.;
run;

title 'Share of Wallet - ALL ';
proc tabulate data=wip.customer_data missing;
/*where cbsa_fips not in('12580','20100','49620','40380','28740','30500','25180','25420','39100','40060','39740','35620','47900',*/
/*                   '37980','42580','45060','23900','29540','27060','20700','13780','15380','30260','41540','44300','10900',*/
/*                   '12860','33100','36180','20660','16540','12180','42380','42780','30820','19060','18500','46540','10580',*/
/*                   '30140','21300','36460','44980','15700','18660','14100','27460','42900','11020','39060','42540','48060','48700','20180') and cbr_2012 eq '99';*/
class cbsa_name segment;
var hh dep_hh loan_hh sec_hh adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities;
/*table ALL, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. /nocellmerge;*/
table ALL, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. / nocellmerge;
format  segment segfmt.;
run;


proc means data=data.main_201112 N sum;
var hh;
run;

proc freq data=customer_data;
table cbr_2012 / missing nopercent ;
run;

/*analyze mmarket by proiduct by cbsa */

proc tabulate data=work.ixi_data;
where cbsa_fips in('12580','20100','49620','40380','28740','30500','25180','25420','39100','40060','39740','35620','47900',
                   '37980','42580','45060','23900','29540','27060','20700','13780','15380','30260','41540','44300','10900',
                   '12860','33100','36180','20660','16540','12180','42380','42780','30820','19060','18500','46540','10580',
                   '30140','21300','36460','44980','15700','18660','14100','27460','42900','11020','39060','42540','48060','48700','20180');
class cbsa_name;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks 
TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds;
tables (cbsa_name), (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks )*sum='Total Balances'*f=dollar24. /nocellmerge;
tables (cbsa_name),(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds)*SUM='HH Counts'*f=comma12. / nocellmerge;
format cbr_2012 $cbrfmt.;
run;

proc tabulate data=work.ixi_data;
where cbsa_fips not in('12580','20100','49620','40380','28740','30500','25180','25420','39100','40060','39740','35620','47900',
                   '37980','42580','45060','23900','29540','27060','20700','13780','15380','30260','41540','44300','10900',
                   '12860','33100','36180','20660','16540','12180','42380','42780','30820','19060','18500','46540','10580',
                   '30140','21300','36460','44980','15700','18660','14100','27460','42900','11020','39060','42540','48060','48700','20180') ;
class cbsa_name;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks 
TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds;
tables (ALL), (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks )*sum='Total Balances'*f=dollar24. /nocellmerge;
tables (ALL),(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds)*SUM='HH Counts'*f=comma12. / nocellmerge;
format cbr_2012 $cbrfmt.;
run;

proc tabulate data=ixi_bands;
where cbsa_fips in('12580','20100','49620','40380','28740','30500','25180','25420','39100','40060','39740','35620','47900',
                   '37980','42580','45060','23900','29540','27060','20700','13780','15380','30260','41540','44300','10900',
                   '12860','33100','36180','20660','16540','12180','42380','42780','30820','19060','18500','46540','10580',
                   '30140','21300','36460','44980','15700','18660','14100','27460','42900','11020','39060','42540','48060','48700','20180');
class cbsa_name;
var _NUMERIC_;
tables (cbsa_name), (ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds 
        T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds T2mTo3mHouseholds T3mTo5mHouseholds 
        T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds)*SUM='Total HHs'*f=comma12.0 / nocellmerge;
tables	(cbsa_name),(ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
         T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
         T10mTo15mDollars T15mTo25mDollars T25mPlusDollars )*SUM='Total $$$s'*f=Dollar24.0 /nocellmerge ;
format cbr_2012 $cbrfmt.;
run;

proc tabulate data=ixi_bands;
where cbsa_fips not in('12580','20100','49620','40380','28740','30500','25180','25420','39100','40060','39740','35620','47900',
                   '37980','42580','45060','23900','29540','27060','20700','13780','15380','30260','41540','44300','10900',
                   '12860','33100','36180','20660','16540','12180','42380','42780','30820','19060','18500','46540','10580',
                   '30140','21300','36460','44980','15700','18660','14100','27460','42900','11020','39060','42540','48060','48700','20180');
class cbsa_name;
var _NUMERIC_;
tables (ALL), (ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds 
        T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds T2mTo3mHouseholds T3mTo5mHouseholds 
        T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds)*SUM='Total HHs'*f=comma12.0 / nocellmerge;
tables	(ALL),(ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
         T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
         T10mTo15mDollars T15mTo25mDollars T25mPlusDollars )*SUM='Total $$$s'*f=Dollar24.0 /nocellmerge ;
format cbr_2012 $cbrfmt.;
run;

proc tabulate data=data.main_201112 classdata=class missing;
where cbsa_fips in('12580','20100','49620','40380','28740','30500','25180','25420','39100','40060','39740','35620','47900',
                   '37980','42580','45060','23900','29540','27060','20700','13780','15380','30260','41540','44300','10900',
                   '12860','33100','36180','20660','16540','12180','42380','42780','30820','19060','18500','46540','10580',
                   '30140','21300','36460','44980','15700','18660','14100','27460','42900','11020','39060','42540','48060','48700','20180');
var hh dda mms sav tda ira sec trs ins mtg heq card iln ind sln sdb;
class  segment cbsa_name;
table cbsa_name*segment, (hh dda mms sav tda ira sec trs ins mtg heq card iln ind sln sdb)*sum='HHs'*f=comma12. / nocellmerge;
format cbr_2012 $cbrfmt. segment segfmt.;
run;

proc tabulate data=data.main_201112 classdata=segment missing;
where cbsa_fips not in('12580','20100','49620','40380','28740','30500','25180','25420','39100','40060','39740','35620','47900',
                   '37980','42580','45060','23900','29540','27060','20700','13780','15380','30260','41540','44300','10900',
                   '12860','33100','36180','20660','16540','12180','42380','42780','30820','19060','18500','46540','10580',
                   '30140','21300','36460','44980','15700','18660','14100','27460','42900','11020','39060','42540','48060','48700','20180');
var hh dda mms sav tda ira sec trs ins mtg heq card iln ind sln sdb;
class  segment ;
table ALL*segment, (hh dda mms sav tda ira sec trs ins mtg heq card iln ind sln sdb)*sum='HHs'*f=comma12. / nocellmerge;
format cbr_2012 $cbrfmt. segment segfmt.;
run;

/*###########################################################################################################################*/
/*BY STATE*/


title 'Share of Wallet by State - Footprint';
proc tabulate data=wip.customer_data missing ;
where state in ('NY','PA','MD','DE','VA','DC') and cbr_2012 ne '99';
class state segment;
var hh dep_hh loan_hh sec_hh adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities;
/*table state, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. /nocellmerge;*/
table state*segment, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. / nocellmerge;
format  segment segfmt.;
run;

title 'Share of Wallet by State - Out of Footprint';
proc tabulate data=wip.customer_data missing classdata=segment;
where (state in('NY','PA','MD','DE','VA','DC') and cbr_2012 eq '99') or (state not in ('NY','PA','MD','DE','VA','DC'));
class  segment;
var hh dep_hh loan_hh sec_hh adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities;
/*table ALL, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. /nocellmerge;*/
table segment, (hh dep_hh loan_hh sec_hh)*sum='HH Counts'*f=comma12. (adj_dep_wallet adj_sec_wallet adj_wallet deposits loans securities)*sum='Amount'*f=dollar24. / nocellmerge;
format  segment segfmt.;
run;

proc tabulate data=work.ixi_data missing;
where StateName in ('Delaware','New York','Maryland','District of Columbia','Pennsylvania','Virginia')and cbr_2012 ne '99';
class statename;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks 
TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds;
tables (statename), (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks )*sum='Total Balances'*f=dollar24. /nocellmerge;
tables (statename),(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds)*SUM='HH Counts'*f=comma12. / nocellmerge;
format cbr_2012 $cbrfmt.;
run;

proc tabulate data=work.ixi_data;
where (StateName in ('Delaware','New York','Maryland','District of Columbia','Pennsylvania','Virginia')and cbr_2012 ne '99') or
(StateName not in ('Delaware','New York','Maryland','District of Columbia','Pennsylvania','Virginia'));
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks 
TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds;
tables (ALL), (TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking 
OtherChecking Savings MutualFunds Other Stocks )*sum='Total Balances'*f=dollar24. /nocellmerge;
tables (ALL),(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds 
InterestCheckingHouseholds MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds 
MutualFundsHouseholds OtherHouseholds StocksHouseholds)*SUM='HH Counts'*f=comma12. / nocellmerge;
format cbr_2012 $cbrfmt.;
run;

proc tabulate data=ixi_bands;
where StateName in ('Delaware','New York','Maryland','District of Columbia','Pennsylvania','Virginia')and cbr_2012 ne '99';
class statename;
var _NUMERIC_;
tables ( statename), (ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds 
        T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds T2mTo3mHouseholds T3mTo5mHouseholds 
        T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds)*SUM='Total HHs'*f=comma12.0 / nocellmerge;
tables	( statename),(ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
         T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
         T10mTo15mDollars T15mTo25mDollars T25mPlusDollars )*SUM='Total $$$s'*f=Dollar24.0 /nocellmerge ;
format cbr_2012 $cbrfmt.;
run;

proc tabulate data=ixi_bands;
where (StateName in ('Delaware','New York','Maryland','District of Columbia','Pennsylvania','Virginia')and cbr_2012 ne '99') or
(StateName not in ('Delaware','New York','Maryland','District of Columbia','Pennsylvania','Virginia'));
class statename;
var _NUMERIC_;
tables ( all), (ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds 
        T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds T2mTo3mHouseholds T3mTo5mHouseholds 
        T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds)*SUM='Total HHs'*f=comma12.0 / nocellmerge;
tables	( all),(ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
         T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
         T10mTo15mDollars T15mTo25mDollars T25mPlusDollars )*SUM='Total $$$s'*f=Dollar24.0 /nocellmerge ;
format cbr_2012 $cbrfmt.;
run;



proc tabulate data=data.main_201112  missing;
where state in ('NY','PA','MD','DE','VA','DC') and cbr_2012 ne '99';
var hh dda mms sav tda ira sec trs ins mtg heq card iln ind sln sdb;
class  segment state;
table state*segment, (hh dda mms sav tda ira sec trs ins mtg heq card iln ind sln sdb)*sum='HHs'*f=comma12. / nocellmerge;
format cbr_2012 $cbrfmt. segment segfmt.;
run;

proc tabulate data=data.main_201112  missing;
where (state in('NY','PA','MD','DE','VA','DC') and cbr_2012 eq '99') or (state not in ('NY','PA','MD','DE','VA','DC'));
var hh dda mms sav tda ira sec trs ins mtg heq card iln ind sln sdb;
class  segment;
table segment, (hh dda mms sav tda ira sec trs ins mtg heq card iln ind sln sdb)*sum='HHs'*f=comma12. / nocellmerge;
format cbr_2012 $cbrfmt. segment segfmt.;
run;

data data.main_201112;
length asset_band $ 10;
set data.main_201112;
adj_wallet = max (ixi_tot,sum(dda_amt,sav_amt,mms_amt, tda_amt, ira_amt),0);
select ;
	when (adj_wallet lt 100000)  asset_band = 'Mainstream';
	when (adj_wallet ge 100000 and adj_wallet lt 1000000)  asset_band = 'Mass Affl';
	when (adj_wallet gt  1000000)  asset_band = 'Affluent';
end;
run;


proc tabulate data=data.main_201112;
class asset_band cbr_2012;
var hh;
table cbr_2012, asset_band*(hh*sum*f=comma12.);
format cbr_2012 $cbrfmt.;
run;


 data data.main_201112;
set data.main_201112;
length wealth $ 15;
	select;
		when (adj_wallet ge 0 and adj_wallet lt 25000) wealth='Up to 25M';
		when (adj_wallet ge 25000 and adj_wallet lt 100000) wealth='25-100M'; 
		when (adj_wallet ge 100000 and adj_wallet lt 250000) wealth='100-250M'; 
		when (adj_wallet ge 250000 and adj_wallet lt 500000) wealth='250-500M'; 
		when (adj_wallet ge 500000 and adj_wallet lt 1000000) wealth='500M-1MM'; 
		when (adj_wallet ge 1000000 and adj_wallet lt 2000000) wealth='1-2MM';
		when (adj_wallet ge 2000000 and adj_wallet lt 3000000) wealth='2-3MM';
		when (adj_wallet ge 3000000 and adj_wallet lt 4000000) wealth='3-4MM'; 
		when (adj_wallet ge 4000000 and adj_wallet lt 5000000) wealth='4-5MM';
		when (adj_wallet ge 5000000 and adj_wallet lt 10000000) wealth='5-10MM';
	 	when (adj_wallet ge 10000000 and adj_wallet lt 15000000) wealth='10-15MM';
		when (adj_wallet ge 15000000 and adj_wallet lt 20000000) wealth='15-20MM';
		when (adj_wallet ge 20000000 and adj_wallet lt 25000000) wealth='20-25MM';
		when (adj_wallet ge 25000000 ) wealth='25MM+'; 
		otherwise wealth='XXX';
	end;
run;

data data.main_201112;
set data.main_201112;
length region $ 12;
select (cbr_2012);
	when ('1','2','3','4','5') region = 'Upstate';
	when ('6','7','8') region = 'Metro';
	when ('9','10','11') region = 'Pennsylvania';
	when ('12','13','14','15','16','17') region = 'Mid-Atlantic';
	otherwise region = 'Other';
end;
run;

PROC TABULATE DATA=data.main_201112 out=wip.was1 missing;
class region wealth  was;
var hh;
table was*region, wealth*(hh*sum*f=comma12.) / nocellmerge;
run;

proc univariate data=virtual.signons;
var sign_ons;
run;

proc tabulate data=data.main_201112;
where adj_wallet ge 10000000;
class cbr; var adj_wallet;
table cbr,(n*f=comma12. adj_wallet*sum='Assets'*f=dollar18.);
format cbr cbrfmt.;
run;

data test;
merge data.main_201111 (in=a ) 
      virtual.points_2011 (in=b keep = hhid segment rename=(segment=virtual_seg)) 
      virtual.points_2011_new_base (in=c keep=hhid segment rename=(segment=seg_new) );
by hhid;
if a;
run;


data data.main_201111;
length summary_segm $ 20 summary_segm_new $ 20;
set test;
if virtual_seg eq '' then virtual_seg = 'XXXXX';
if seg_new eq '' then seg_new = 'XXXXX';
select (virtual_seg);
    when ('Branch Dominant','Multi - High Branch','Multi - Med Branch') summary_segm = 'Branch Centric';
	when ('ATM Dominant','Phone Dominant','Online Dominant','Multi - Low Branch') summary_segm = 'Virtual Domiciled';
	when ('Inactive','Inac') summary_segm = 'Inactive';
	otherwise summary_segm = 'XXXXX';
end;
select (seg_new);
    when ('Branch Dominant','Multi - High Branch','Multi - Med Branch') summary_segm_new = 'Branch Centric';
	when ('ATM Dominant','Phone Dominant','Online Dominant','Multi - Low Branch') summary_segm_new = 'Virtual Domiviled';
	when ('Inactive','Inac') summary_segm_new = 'Inactive';
	otherwise summary_segm_new = 'XXXXX';
end;
run;

