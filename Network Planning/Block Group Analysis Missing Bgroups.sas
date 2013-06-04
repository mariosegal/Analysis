*create distances (this is needed one time only);
filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Network Planning\bgroup_coords.txt';
data bgroup_coords;
length bgroup $ 12;
infile myfile dsd dlm='09'x firstobs=2;
input bgroup $ lat1 long1;
run;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Network Planning\Missing block groups.txt';
data branch.bta_missing;
length bgroup $ 12;
infile myfile dsd dlm='09'x firstobs=2;
input branch bgroup $ lat1 long1;
run;

*exclude look alike and other wt branches not desired;
data  branch.bta_missing;
set  branch.bta_missing;
where branch not in (7021 7029 7042 7272 7311 7333 7338 7345 7366 7320 7016 7031 7042 7049 .);
run;

proc sort data=branch.bta_missing nodupkey;
by bgroup branch;
run;

proc sort data=bgroup_coords;
by bgroup;
run;

data branch.btas_bgroups_missing;
set branch.bta_missing;
run;

*I received them from John, and the coords file seems to be missing them anyway;
/*data branch.btas_bgroups_missing bad;*/
/*merge branch.bta_missing (in=a) bgroup_coords (in=b);*/
/*by bgroup;*/
/*if a and b then output branch.btas_bgroups_missing;*/
/*if a and not b then output bad;*/
/*run;*/

proc sort data=branch.btas_bgroups_missing ;
by branch;
run;

proc sort data=top40.branch_coords ;
by branch;
run;

data branch.btas_bgroups_missing;
merge branch.btas_bgroups_missing (in=a) top40.branch_coords (in=b rename=(lon2=long2));
by branch;
exclude = 0;
if a;
if a and not b then exclude = 1;
run;

proc sort data=branch.btas_bgroups_missing;
by bgroup branch;
run;

data branch.btas_bgroups_missing;
set branch.btas_bgroups_missing;
	ct = constant('pi')/180;
	distance = .;
	if exclude eq 0 then distance = 3959 * ( 2 * arsin(min(1,sqrt( sin( ((lat2 - lat1)*ct)/2 )**2 
                                    + cos(lat1*ct) * cos(lat2*ct) * sin(((long2-long1)*ct)/2)**2))));
drop ct ;
run;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Network Planning\transactions by branch.txt';
data trans;
infile myfile dsd dlm='09'x ;
input branch volume;
run;

proc sort data=branch.btas_bgroups_missing;
by branch;
run;

proc sort data=trans;
by branch;
run;

data branch.btas_bgroups_missing ;
merge branch.btas_bgroups_missing (in=a) trans (in=b);
by branch;
if a;
run;


data branch.btas_bgroups_missing;
set branch.btas_bgroups_missing;
attraction = divide(volume , distance**2);
run;

proc sort data=branch.btas_bgroups_missing;
by bgroup;
run;



proc summary data=branch.btas_bgroups_missing;
class bgroup;
var attraction;
output out = sums (drop=_type_ _freq_)
       sum(attraction) = subtotal;
run;




proc sql;
create table branch.btas_bgroups_missing as
select * from branch.btas_bgroups_missing as a, sums as b
where a.bgroup = b.bgroup;
quit;


data branch.btas_bgroups_missing;
set branch.btas_bgroups_missing;
weight = divide(attraction,subtotal);
run;

*validate it is all logical;
proc tabulate data=branch.btas_bgroups_missing (rename=(weight=w)) out=c;
var w;
class  bgroup;
table bgroup, w*sum*f=percent8.1;
run;


*########################################################################################################################;
*need to modify this to use the bgroups from the bta file;
data temp_internalp;
set  data.main_201112 ;
where zip_flag eq 'R' and sum(bus,com) eq 0 ;
adj_intchk = max(intchk_amt, ixi_int_chk);
adj_nonintchk = max(nonintchk_amt, ixi_Non_Int_Chk);
adj_mms = max(mms_amt,ixi_mms);
adj_sav = max(sav_amt,ixi_savings);
adj_tda = max((tda_amt+ira_amt),ixi_tda);
adj_sec = max(sec_amt,ixi_tot-sum(ixi_int_chk,ixi_Non_Int_Chk,ixi_mms,ixi_savings,ixi_tda));
adj_dep = sum(adj_intchk,adj_nonintchk,adj_sav,adj_mms,adj_tda);
adj_tot = sum(adj_sec,adj_dep);
keep hhid hh zip_flag block dda intchk nonintchk mms sav 
     tda ira sec trs mtg heq card ILN IND sln sdb ins DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt 
     sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_AMT sln_amt IXI_tot IXi_Annuity ixi_Bonds ixi_Funds ixi_Stocks 
     ixi_Other ixi_Non_Int_Chk ixi_int_chk ixi_savings  ixi_MMS ixi_tda bus com cbr_zip block adj: ;
drop adj_wallet;
rename block=bgroup;
run;

proc sort data=branch.btas_bgroups_missing;
by bgroup branch;
run;

*take only the bgroups in question *;
data temp_internal;
merge temp_internal (in=a) branch.btas_bgroups_missing (in=b);
by bgroup;
if a and b;
run;



*tabulate internal data by bgroup;
ods html close;
proc tabulate data=temp_internal out=temp_internal_bgroup (drop=_type_ _page_ _table_) missing ;
class bgroup;
var DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_AMT sln_amt
    dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins;
	table bgroup, (dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins)*sum*f=comma12.
           (DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt 
           ind_AMT sln_amt)*sum*f=dollar24. / nocellmerge;
run;
ods html;



proc sql noprint;
create table temp_internal_extended as 
select one.*, two.branch, two.attraction, two.weight from temp_internal_bgroup as one, branch.btas_bgroups_missing as two
where one.bgroup = two.bgroup
order by two.bgroup, two.branch;
quit;


proc summary data=temp_internal_extended (drop=bgroup attraction rename=(weight=w)) nway ;
class branch;
var intchk_Sum nonintchk_Sum mms_Sum sav_Sum tda_Sum ira_Sum sec_Sum trs_Sum mtg_Sum heq_Sum card_Sum ILN_Sum IND_Sum 
    sln_Sum sdb_Sum ins_Sum DDA_Amt_Sum intchk_amt_Sum nonintchk_amt_Sum MMS_amt_Sum sav_amt_Sum TDA_Amt_Sum IRA_amt_Sum 
    sec_Amt_Sum trs_amt_Sum MTG_amt_Sum HEQ_Amt_Sum ccs_Amt_Sum iln_amt_Sum IND_AMT_Sum sln_amt_Sum  ;
output out=temp_internal_branch (drop=_type_ _freq_)  sum=  ;
weight w;
run;



*wallet analysis;
ods html close;
proc tabulate data=temp_internal out=wallet_bgroup (drop=_type_ _page_ _table_) missing ;
class bgroup;
var adj_intchk adj_nonintchk adj_mms adj_sav adj_tda adj_sec adj_dep adj_tot;
	table bgroup, (adj_intchk adj_nonintchk adj_mms adj_sav adj_tda adj_sec adj_dep adj_tot)*sum*f=dollar24. / nocellmerge;
run;
ods html;

proc sql noprint;
create table wallet_extended as 
select one.*, two.branch, two.attraction, two.weight from wallet_bgroup as one, branch.btas_bgroups_missing as two
where one.bgroup = two.bgroup
order by two.bgroup, two.branch;
quit;

proc summary data=wallet_extended (drop=bgroup attraction rename=(weight=w)) nway ;
class branch;
var adj_intchk_Sum adj_nonintchk_Sum adj_mms_Sum adj_sav_Sum adj_tda_Sum adj_sec_Sum adj_dep_Sum adj_tot_Sum;
output out=wallet_branch (drop=_type_ _freq_)  sum=  ;
weight w;
run;


*########################################################################################################################;
*do the market part ;

libname IXI_NEw oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=IXI;
 Data Source=bagels"  schema=dbo; 


proc sort data=branch.btas_bgroups_missing (keep=bgroup exclude where=(exclude eq 0)) out=bgroups  nodupkey;
by bgroup;
run;


data market_size (rename=(TotalAssets= assets   InterestChecking=intchk MoneyMarket=mms NonInterestChecking=nonintchk OtherChecking =othchk 
                           Savings=sav MutualFunds=funds TotalHouseholds=hhs TotalHouseholdsWithAssets=asset_hh AnnuitiesHouseholds=annuity_hh 
                           BondsHouseholds=bond_hh DepositsHouseholds=dep_hh CDHouseholds=cd_hh InterestCheckingHouseholds =intchk_hh 
                           MoneyMarketHouseholds=mms_hh NonInterestCheckingHouseholds=nonintchk_hh OtherCheckingHouseholds=othchk_hh 
                           SavingsHouseholds=sav_hhs MutualFundsHouseholds=fund_hh OtherHouseholds=oth_hh StocksHouseholds=stock_hh)) 
     noixi(keep=bgroup );
merge ixi_new.mtb_census (in=a rename=(blockgroupcode=bgroup) where=(cycleid eq 201106  )) 
      bgroups (in=b keep= bgroup  where=(bgroup ne '' ));
by bgroup;
if b then output market_size;
if b and not a then output noixi;
drop cycleid tractcode countycode countyname statecode firm: statename;
run;

proc sql noprint;
create table market_size_extended as 
select one.*, two.branch, two.attraction, two.weight from market_size as one, branch.btas_bgroups_missing as two
where one.bgroup = two.bgroup
order by two.bgroup, two.branch;
quit;


proc summary data=market_size_extended (drop=bgroup attraction rename=(weight=w)) nway ;
class branch;
var assets Deposits intchk  nonintchk mms sav CD Annuities Bonds  othchk  funds Other Stocks hhs asset_hh dep_hh intchk_hh nonintchk_hh 
    mms_hh sav_hhs cd_hh annuity_hh bond_hh othchk_hh  fund_hh oth_hh stock_hh  ;
output out=market_size_branch (drop=_type_ _freq_)  sum=  ;
weight w;
run;


data merged;
merge market_size_branch (in=c)  wallet_branch (in=b) temp_internal_branch (in=a);
by branch;
if a and b and c;
run;


*this was to test the sums;
proc tabulate data=temp_internal_bgroup;
var intchk_Sum nonintchk_Sum mms_Sum sav_Sum tda_Sum ira_Sum sec_Sum trs_Sum mtg_Sum heq_Sum card_Sum ILN_Sum IND_Sum 
    sln_Sum sdb_Sum ins_Sum DDA_Amt_Sum intchk_amt_Sum nonintchk_amt_Sum MMS_amt_Sum sav_amt_Sum TDA_Amt_Sum IRA_amt_Sum 
    sec_Amt_Sum trs_amt_Sum MTG_amt_Sum HEQ_Amt_Sum ccs_Amt_Sum iln_amt_Sum IND_AMT_Sum sln_amt_Sum;
table sum*f=comma24.*(intchk_Sum nonintchk_Sum mms_Sum sav_Sum tda_Sum ira_Sum sec_Sum trs_Sum mtg_Sum heq_Sum card_Sum ILN_Sum IND_Sum 
    sln_Sum sdb_Sum ins_Sum DDA_Amt_Sum intchk_amt_Sum nonintchk_amt_Sum MMS_amt_Sum sav_amt_Sum TDA_Amt_Sum IRA_amt_Sum 
    sec_Amt_Sum trs_amt_Sum MTG_amt_Sum HEQ_Amt_Sum ccs_Amt_Sum iln_amt_Sum IND_AMT_Sum sln_amt_Sum);
run;




*get the bgroups and states for those not in BTAs;

data not_in_bta;
set  data.main_201112 ;
where zip_flag eq 'R' and sum(bus,com) eq 0 and bta_flag_new ne 1;
deposits = sum(dda_amt, mms_amt, sav_amt, tda_amt, ira_amt);
keep  block hh deposits sec_amt ;
rename block=bgroup;
run;

ods html close;
proc tabulate data=not_in_bta out=not_in_bta_summary missing;
	var hh deposits sec_amt;
	class block;
	table block, hh*sum*f=comma12. (deposits sec_amt)*sum*f=dollar24.
