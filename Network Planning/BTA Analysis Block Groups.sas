* Create dataset with BTAs defined by block group;
libname IXI_NEw oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=IXI;
 Data Source=bagels"  schema=dbo; 


filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Network Planning\BTA block groups clean.txt';

data branch.btas_bgroups;
length bgroup $ 12;
infile mydata dlm='09'x dsd lrecl=4096 firstobs=2;
input Branch bgroup $;
run;

proc freq data=branch.btas_bgroups;
table branch / out=out1 missing;
run;

proc sort data=branch.btas_bgroups;
by bgroup;
run;

proc print data=bads noobs;
var bgroup;
run;


* extract data from ixi market estimates and sumamrize it;
data market_size (rename=(TotalAssets= assets   InterestChecking=intchk MoneyMarket=mms NonInterestChecking=nonintchk OtherChecking =othchk Savings=sav MutualFunds=funds  
 TotalHouseholds=hhs TotalHouseholdsWithAssets=asset_hh AnnuitiesHouseholds=annuity_hh BondsHouseholds=bond_hh DepositsHouseholds=dep_hh CDHouseholds=cd_hh
InterestCheckingHouseholds =intchk_hh MoneyMarketHouseholds=mms_hh NonInterestCheckingHouseholds=nonintchk_hh OtherCheckingHouseholds=othchk_hh 
SavingsHouseholds=sav_hhs MutualFundsHouseholds=fund_hh OtherHouseholds=oth_hh StocksHouseholds=stock_hh)) noixi(keep=bgroup branch);
merge ixi_new.mtb_census (in=a rename=(blockgroupcode=bgroup) where=(cycleid eq 201106)) branch.btas_bgroups (in=b where=(bgroup ne ''));
by bgroup;
if b then output market_size;
if b and not a then output noixi;
drop cycleid tractcode countycode countyname statecode firm: exclude;
run;

proc freq data=branch.btas_bgroups;
table branch / nopercent nocum nofreq missing out=branches(drop=count percent);
run;

proc tabulate data=market_size out=bta_market_size (drop=_type_ _page_ _TABLE_) classdata=branches missing;
var assets Annuities Bonds Deposits CD intchk mms nonintchk othchk sav funds Other 
    Stocks hhs asset_hh annuity_hh bond_hh dep_hh cd_hh intchk_hh mms_hh nonintchk_hh othchk_hh sav_hhs fund_hh oth_hh stock_hh ;
class branch;
table branch, (hhs asset_hh annuity_hh bond_hh dep_hh cd_hh intchk_hh mms_hh nonintchk_hh othchk_hh sav_hhs fund_hh oth_hh stock_hh)*sum='HH Counts'*f=comma12.
			   (assets Annuities Bonds Deposits CD intchk mms nonintchk othchk sav funds Other Stocks )*sum='Total Balances'*f=dollar24. / nocellmerge;
run;

*aggregate internal data by block group, but only count those HHs that are  considered to be in residential zips - this is using a special flag 
only present in dec2011 monthly  ACCT.FLAG_LMO_RESERVED_1="R";

* first I will read a text file that has that flag (from prime acct), then I will append it to my data.main_201112 dataset;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Network Planning\ziptype.txt';

data ziptype;
length hhid $ 9 zip_flag $ 1;
infile myfile dlm='09'x dsd firstobs=2 ;
input hhid $ zip_flag $;
run;

data data.main_201112;
merge data.main_201112 (in=a) ziptype(in=b);
by hhid;
if a;
run;

* claculate flags and bals for int and nion_int checking;
proc datasets library=attr;
modify data_201112;
index create hhid acct;
run;

proc summary data=attr.data_201112_new (where= (ptype eq "DDA" and STYPE in ('RA8','RG6','RF2','RG2','RH2','RH3','RH5','RH6','RK2','RK7') and status ne "X") );
var bal;
by hhid;
output out=interest (drop=_FREQ_ _TYPE_)
       sum(bal) = bal;
run;

proc summary data=attr.data_201112_new (where= (ptype eq "DDA" and STYPE not in ('RA8','RG6','RF2','RG2','RH2','RH3','RH5','RH6','RK2','RK7') and status ne "X") );
var bal;
by hhid;
output out=nonint (drop=_FREQ_ _TYPE_)
       sum(bal) = bal;
run;

data interest;
set interest;
hh=1;
run;

data nonint;
set nonint;
hh=1;
run;

data data.main_201112;
merge data.main_201112 (in=a drop=intchk intchk_amt nonintchk nonintchk_amt) interest(in=b rename=(hh=intchk bal=intchk_amt)) nonint(in=c rename=(hh=nonintchk bal=nonintchk_amt)) ;
by hhid;
if a;
run;

data data.main_201112;
set data.main_201112;
if intchk eq . then intchk = 0;
if intchk_amt eq . then intchk_amt = 0;
if nonintchk eq . then nonintchk = 0;
if nonintchk_amt eq . then nonintchk_amt = 0;
run;

* extract data from the main dataset while merging with the BTAs *;

proc contents data=data.main_201112 varnum short; run;

proc sort data=data.main_201112;
by block;
run;

proc datasets library=data;
modify main_201112;
index create hhid block;
run;

* I need to create a special extract of 20112 that has the adj wallets by hh;
data temp_2012;
set data.main_201112;
adj_intchk = max(intchk_amt, ixi_int_chk);
adj_nonintchk = max(nonintchk_amt, ixi_Non_Int_Chk);
adj_mms = max(mms_amt,ixi_mms);
adj_sav = max(sav_amt,ixi_savings);
adj_tda = max((tda_amt+ira_amt),ixi_tda);
adj_sec = max(sec_amt,ixi_tot-sum(ixi_int_chk,ixi_Non_Int_Chk,ixi_mms,ixi_savings,ixi_tda));
adj_dep = sum(adj_intchk,adj_nonintchk,adj_sav,adj_mms,adj_tda);
adj_tot = sum(adj_sec,adj_dep);
keep hhid hh zip_flag block dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins  
     DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_AMT sln_amt 
     IXI_tot IXi_Annuity ixi_Bonds ixi_Funds ixi_Stocks ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings  ixi_MMS ixi_tda adj: bus com cbr_zip;
rename block=bgroup;
drop adj_wallet;
run;



data internal_data nointernal;
merge temp_2012 (in=a keep=hhid hh zip_flag  dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins  
                             DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_AMT sln_amt 
                             IXI_tot IXi_Annuity ixi_Bonds ixi_Funds ixi_Stocks ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings 
                             ixi_MMS ixi_tda adj: bus com bgroup)
	   branch.btas_bgroups (in=b where=(bgroup ne ''));
by bgroup;
if b then output internal_data;
if b and not a then output nointernal;
run;

data temp1;
set internal_data;
where adj_mms lt mms_amt;
run;


* when I add internal balances I need to add all people, but when I add the appended estimates I really have to ignore the non residential zips
so this requires 2 tabulates as I need to exclude the non "R" in one;
* the above proved to be problematic, I had many negative internal opportunities, using the filter on both reduced that to 16 branches, and some are tops 
or school ones that are suspect to begin with.;




proc tabulate data=internal_data out = bta_cust_wallet (drop= _PAGE_ _TYPE_ _TABLE_) classdata=branches missing;
where zip_flag eq 'R' and sum(bus,com) eq 0;
class branch;
var adj_tot adj_sec  adj_NonIntChk adj_intchk adj_sav adj_MMS adj_tda ;
table branch, (adj_NonIntChk adj_intchk adj_MMS adj_sav  adj_tda adj_sec adj_tot )*sum='Wallet'*f=dollar24. / nocellmerge;
run;

proc tabulate data=internal_data out = bta_mtb_balances (drop= _PAGE_ _TYPE_ _TABLE_) classdata=branches missing;
where zip_flag eq 'R' and sum(bus,com) eq 0;
class branch;
var hh dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt 
   trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt ;
table branch, (hh='All' dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins)*sum='HH Count'*f=comma12.
      (DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt)*sum='Balances'*f=dollar24.
	  / nocellmerge;
run;

*###############################################################################################;
* Now do it by CBR;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\References\CBR and Market by zip codes 2012.txt';
data branch.CBR_by_zip_2012;
length zip $ 5;
infile myfile dsd firstobs=2 dlm='09'x;
input cbr_zip market_zip zip $;
run;


* extract data from ixi market estimates and and merge the zip assignments to cbr;
data market_size1 (rename=(TotalAssets= assets   InterestChecking=intchk MoneyMarket=mms NonInterestChecking=nonintchk OtherChecking =othchk Savings=sav MutualFunds=funds  
 TotalHouseholds=hhs TotalHouseholdsWithAssets=asset_hh AnnuitiesHouseholds=annuity_hh BondsHouseholds=bond_hh DepositsHouseholds=dep_hh CDHouseholds=cd_hh
InterestCheckingHouseholds =intchk_hh MoneyMarketHouseholds=mms_hh NonInterestCheckingHouseholds=nonintchk_hh OtherCheckingHouseholds=othchk_hh 
SavingsHouseholds=sav_hhs MutualFundsHouseholds=fund_hh OtherHouseholds=oth_hh StocksHouseholds=stock_hh)) noixi1(keep=zip cbr_zip market_zip);
merge ixi_new.mtb_postal (in=a rename=(regionzipcode=zip) where=(cycleid eq 201106)) branch.CBR_by_zip_2012 (in=b );
by zip;;
if b and a then output market_size1;
if b and not a then output noixi1;
run;

*summarize market size;
proc tabulate data=market_size1 out=cbr_market_size (drop=_type_ _page_ _TABLE_)  missing;
var assets Annuities Bonds Deposits CD intchk mms nonintchk othchk sav funds Other 
    Stocks hhs asset_hh annuity_hh bond_hh dep_hh cd_hh intchk_hh mms_hh nonintchk_hh othchk_hh sav_hhs fund_hh oth_hh stock_hh ;
class cbr_zip;
table cbr_zip ALL, (hhs asset_hh annuity_hh bond_hh dep_hh cd_hh intchk_hh mms_hh nonintchk_hh othchk_hh sav_hhs fund_hh oth_hh stock_hh)*sum='HH Counts'*f=comma12.
			   (assets Annuities Bonds Deposits CD intchk mms nonintchk othchk sav funds Other Stocks )*sum='Total Balances'*f=dollar24. / nocellmerge;
format cbr_zip cbrfmt.;
run;

proc sql;
select * from branch.CBR_by_zip_2012 order by zip;
quit;

proc sort data=data.main_201112;
by zip;
run;


data data.main_201112;
merge data.main_201112 (in=a) branch.CBR_by_zip_2012 (in=b );
by zip;
if a;
run;

proc freq data=data.main_201112;
table cbr_zip / missing;
run;

proc tabulate data=temp_2012 out = bta_cust_wallet_cbr (drop= _PAGE_ _TYPE_ _TABLE_)  missing;
where zip_flag eq 'R' and sum(bus,com) eq 0;
class cbr_zip;
var adj_tot adj_sec  adj_NonIntChk adj_intchk adj_sav adj_MMS adj_tda ;
table cbr_zip ALL, (adj_NonIntChk adj_intchk adj_MMS adj_sav  adj_tda adj_sec adj_tot )*sum='Wallet'*f=dollar24. / nocellmerge;
run;

proc tabulate data=temp_2012 out = bta_mtb_balances_cbr (drop= _PAGE_ _TYPE_ _TABLE_)  missing;
where zip_flag eq 'R' and sum(bus,com) eq 0;
class cbr_zip;
var hh dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt 
   trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt ;
table cbr_zip ALL, (hh='All' dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins)*sum='HH Count'*f=comma12.
      (DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt)*sum='Balances'*f=dollar24.
	  / nocellmerge;
run;
