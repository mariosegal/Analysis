*Extract data for John so he can test splitting block groups;
libname IXI_NEw oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=IXI;
 Data Source=bagels"  schema=dbo; 

%let branches = 6490 6479 3094 3091 6487 6480 3097 6406 3078 6428 6431 6408 3096 3670 3102 3109 3115 3073;
%let branch1 = 3091;

option symbolgen;

 data market_size_&branch1 (rename=(TotalAssets= assets   InterestChecking=intchk MoneyMarket=mms NonInterestChecking=nonintchk OtherChecking =othchk Savings=sav MutualFunds=funds  
 TotalHouseholds=hhs TotalHouseholdsWithAssets=asset_hh AnnuitiesHouseholds=annuity_hh BondsHouseholds=bond_hh DepositsHouseholds=dep_hh CDHouseholds=cd_hh
InterestCheckingHouseholds =intchk_hh MoneyMarketHouseholds=mms_hh NonInterestCheckingHouseholds=nonintchk_hh OtherCheckingHouseholds=othchk_hh 
SavingsHouseholds=sav_hhs MutualFundsHouseholds=fund_hh OtherHouseholds=oth_hh StocksHouseholds=stock_hh)) noixi_&branch1(keep=bgroup branch);
merge ixi_new.mtb_census (in=a rename=(blockgroupcode=bgroup) where=(cycleid eq 201106)) 
      branch.btas_bgroups (in=b where=(bgroup ne '' and branch in (&branches )));
by bgroup;
if b then output market_size_&branch1;
if b and not a then output noixi_&branch1;
run;

proc sort data=market_size_&branch1;
by branch bgroup;
run;



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

proc sort data=temp_2012;
by bgroup;
run;

data internal_data_&branch1 nointernal_&branch1;
merge temp_2012 (in=a keep=hhid hh zip_flag  dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins  
                             DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_AMT sln_amt 
                             IXI_tot IXi_Annuity ixi_Bonds ixi_Funds ixi_Stocks ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings 
                             ixi_MMS ixi_tda adj: bus com bgroup)
	   branch.btas_bgroups (in=b where=(bgroup ne '' and branch in (&branches)));
by bgroup;
if b then output internal_data_&branch1;
if b and not a then output nointernal_&branch1;
run;

proc tabulate data=internal_data_&branch1 out = bta_mtb_balances_bgroup_&branch1 (drop= _PAGE_ _TYPE_ _TABLE_) missing;
where zip_flag eq 'R' and sum(bus,com) eq 0;
class branch bgroup;
var hh dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt 
   trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt ;
table bgroup, (hh='All' dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins)*sum='HH Count'*f=comma12.
      (DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt)*sum='Balances'*f=dollar24.
	  / nocellmerge;
run;


proc tabulate data=internal_data_&branch1 out = bta_cust_wallet_bgroup_&branch1 (drop= _PAGE_ _TYPE_ _TABLE_)  missing;
where zip_flag eq 'R' and sum(bus,com) eq 0;
class branch bgroup;
var adj_tot  adj_intchk adj_NonIntChk adj_MMS adj_sav  adj_tda adj_sec;
table bgroup, (adj_intchk adj_NonIntChk  adj_MMS adj_sav  adj_tda adj_sec adj_tot )*sum='Wallet'*f=dollar24. / nocellmerge;
run;


data bta_mtb_balances_&branch1;
merge bta_mtb_balances_bgroup_&branch1 (in=a) branch.btas_bgroups (in=b where=(bgroup ne '' and branch in (&branches)));
by bgroup;
if a;
run;

data bta_cust_wallet_&branch1;
merge bta_cust_wallet_bgroup_&branch1 (in=a) branch.btas_bgroups (in=b where=(bgroup ne '' and branch in (&branches)));
by bgroup;
if a;
run;

proc sort data=bta_mtb_balances_&branch1;
by branch bgroup;
run;

proc sort data=bta_cust_wallet_&branch1;
by branch bgroup;
run;

data merged_&branch1;
merge market_size_&branch1 (drop = firm:) bta_cust_wallet_&branch1 bta_mtb_balances_&branch1;
by branch bgroup;
run;

