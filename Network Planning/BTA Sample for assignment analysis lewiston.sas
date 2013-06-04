*Extract data for John so he can test splitting block groups;
libname IXI_NEw oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=IXI;
 Data Source=bagels"  schema=dbo; 


%let groups1 = '360630244011' '360630244012' '360630244013' '360630244031' '360630244032' '360630244041' '360630244042' '360630244043' 
               '360630244051' '360630244052' '360630244061' '360630244062' '360630244063' '360630245011' '360630245012' '360630245021' 
				'360630245022' '360630245023' '360630245029';



 data market_size (rename=(TotalAssets= assets   InterestChecking=intchk MoneyMarket=mms NonInterestChecking=nonintchk OtherChecking =othchk Savings=sav MutualFunds=funds  
 TotalHouseholds=hhs TotalHouseholdsWithAssets=asset_hh AnnuitiesHouseholds=annuity_hh BondsHouseholds=bond_hh DepositsHouseholds=dep_hh CDHouseholds=cd_hh
InterestCheckingHouseholds =intchk_hh MoneyMarketHouseholds=mms_hh NonInterestCheckingHouseholds=nonintchk_hh OtherCheckingHouseholds=othchk_hh 
SavingsHouseholds=sav_hhs MutualFundsHouseholds=fund_hh OtherHouseholds=oth_hh StocksHouseholds=stock_hh) drop=firm:);
set ixi_new.mtb_census (in=a rename=(blockgroupcode=bgroup) where=(cycleid eq 201106 and bgroup in (&groups1)));
run;

proc print data=market_size noobs;
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
where block in (&groups1);
run;

proc sort data=temp_2012;
by bgroup;
run;

data internal_data ;
set temp_2012 (in=a keep=hhid hh zip_flag  dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins  
                             DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_AMT sln_amt 
                             IXI_tot IXi_Annuity ixi_Bonds ixi_Funds ixi_Stocks ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings 
                             ixi_MMS ixi_tda adj: bus com bgroup);
run;

proc tabulate data=internal_data out = bta_mtb_balances_bgroup (drop= _PAGE_ _TYPE_ _TABLE_) missing;
where zip_flag eq 'R' and sum(bus,com) eq 0;
class  bgroup;
var hh dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt 
   trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt ;
table bgroup, (hh='All' dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins)*sum='HH Count'*f=comma12.
      (DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt)*sum='Balances'*f=dollar24.
	  / nocellmerge;
run;


proc tabulate data=internal_data out = bta_cust_wallet_bgroup (drop= _PAGE_ _TYPE_ _TABLE_)  missing;
where zip_flag eq 'R' and sum(bus,com) eq 0;
class  bgroup;
var adj_tot  adj_intchk adj_NonIntChk adj_MMS adj_sav  adj_tda adj_sec;
table bgroup, (adj_intchk adj_NonIntChk  adj_MMS adj_sav  adj_tda adj_sec adj_tot )*sum='Wallet'*f=dollar24. / nocellmerge;
run;



