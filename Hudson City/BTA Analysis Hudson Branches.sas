LIBNAME ixi ODBC DSN=IXI user=reporting_user pw=Reporting2 schema=dbo;

proc fslist fileref= 'C:\Documents and Settings\ewnym5s\My Documents\MapInfo Data\Census\CenPop2010_Mean_BG09.txt'; run;

*read BTa file;
data btas_bgroups;
length name $ 255 address $ 255 city $ 100 state $ 2 zip $ 10 urbanicity $ 50 bgroup $ 12 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Branch Radii File 20130107- All.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input name $ snl_key address $ city $ state $ zip $  lat long urbanicity $ radius bname bgroup $  ;
run;
 
options compress = yes;


%squeeze(btas_bgroups, hudson.btas_bgroups);


*I nedd the hudson branch number;
proc sort data=hudson.btas_bgroups ;
by snl_key;
run;

data hudson.btas_bgroups;
merge hudson.btas_bgroups (in=a) hudson.branch_key (keep=snl_key hudson_branch);
by snl_key;
if a;
run;

*read  the lat long for bgroup center of population;
data ct;
infile 'C:\Documents and Settings\ewnym5s\My Documents\MapInfo Data\Census\CenPop2010_Mean_BG09.txt' dsd dlm=',' lrecl=4096 firstobs=2;
input STATEFP COUNTYFP TRACTCE BLKGRPCE POPULATION lat long;
bgroup=put(statefp,z2.)||put(countyfp,z3.)||put(TRACTCE,z6.)||put(BLKGRPCE,z1.);
run;


data nj;
infile 'C:\Documents and Settings\ewnym5s\My Documents\MapInfo Data\Census\CenPop2010_Mean_BG34.txt' dsd dlm=',' lrecl=4096 firstobs=2;
input STATEFP COUNTYFP TRACTCE BLKGRPCE POPULATION lat long;
bgroup=put(statefp,z2.)||put(countyfp,z3.)||put(TRACTCE,z6.)||put(BLKGRPCE,z1.);
run;


data ny;
infile 'C:\Documents and Settings\ewnym5s\My Documents\MapInfo Data\Census\CenPop2010_Mean_BG36.txt' dsd dlm=',' lrecl=4096 firstobs=2;
input STATEFP COUNTYFP TRACTCE BLKGRPCE POPULATION lat long;
bgroup=put(statefp,z2.)||put(countyfp,z3.)||put(TRACTCE,z6.)||put(BLKGRPCE,z1.);
run;

data data.bgroups_tristate (keep=bgroup lat long);
set ct nj ny;
run;

data data.bgroups_tristate;
set  data.bgroups_tristate;
rename lat=lat2 long=long2;
run;

data hudson.btas_bgroups;
set hudson.btas_bgroups;
if substr(bgroup,1,1) = '9' then bgroup="0"||bgroup;
run;


proc sort data=hudson.btas_bgroups ;
by bgroup;
run;

data hudson.btas_bgroups ;
merge hudson.btas_bgroups (in=a )  data.bgroups_tristate (in=b) end=myend;
retain miss;
by bgroup;
if a then output hudson.btas_bgroups;
if a and not b then miss+1;
if myend then do;
	put 'WARNING: There were '  miss  ' non matches';
end;
drop miss;
run;


*create distances (this is needed one time only);


proc sort data=hudson.btas_bgroups ;
by hudson_branch;
run;



data hudson.btas_bgroups;
set hudson.btas_bgroups;
	ct = constant('pi')/180;
	distance = .;
	distance = 3959 * ( 2 * arsin(min(1,sqrt( sin( ((lat2 - lat)*ct)/2 )**2 
                                    + cos(lat*ct) * cos(lat2*ct) * sin(((long2-long)*ct)/2)**2))));
drop ct ;
run;

*calc balances;
proc tabulate data=hudson.clean_20121106 missing out=balances;
where ptype in ("DDA","MMS","SAV","TDA","IRA");
class branch;
var curr_bal;
table branch, sum*curr_bal*f=comma12. / nocellmerge;
run;


data balances1;
length hudson_branch 8;
set balances;
deposits = curr_bal_sum;
hudson_branch = put(branch,3.);
keep hudson_branch deposits;
run;


data hudson.btas_bgroups;
merge hudson.btas_bgroups (in=a) balances1 (in=b) end=myend;
retain miss;
by hudson_branch;
if a then output;
if a and not b then miss+1;
if myend then do;
	put 'WARNING: There were '  miss  ' non matches';
end;
drop miss;
run;

*if you get trans use that, if not used balances, not ideal;


data hudson.btas_bgroups;
set hudson.btas_bgroups;
attraction = divide(deposits , distance**2);
run;

proc sort data=hudson.btas_bgroups;
by bgroup;
run;

proc summary data=hudson.btas_bgroups;
class bgroup;
var attraction;
output out = sums 
       sum(attraction) = subtotal;
run;

data sums;
set sums;
where _type_ ne 0;
drop _type_ _freq_;
run;


proc sql;
create table hudson.btas_bgroups as
select * from hudson.btas_bgroups as a, sums as b
where a.bgroup = b.bgroup;
quit;


/*data branch.btas_bgroups_clean;*/
/*merge branch.btas_bgroups_clean (in=a) sums (in=b);*/
/*by bgroup;*/
/*if a;*/
/*run;*/

data hudson.btas_bgroups;
set hudson.btas_bgroups;
weight = divide(attraction,subtotal);
run;


*read bgroup for primary accts;
data hudson_bgroups;
length pseudo_hh 8 acct_nbr $ 14 address1 $ 255 address2 $ 255  city $ 100 zip $ 10 state $ 2 tract $ 15 bgroup_text $  15 tract_text $ 15;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\hudson_accts.txt' dsd dlm='09'x lrecl = 4096 missover firstobs=1;
input pseudo_hh	acct_nbr $	address1 $	 address2	$ city $ zip $	state $	tract_text $ bgroup_text $;
run;

data hudson_bgroups;
length bgroup 8;
set hudson_bgroups;
bgroup = substr(bgroup_text,1,9) || substr(bgroup_text,11);
rename zip = zip_std;
run;

options compress=y;
 data test1;
length pseudo_hh 8 bgroup 8 city $ 100 address2 $ 255 zip_std $ 10 check 3;


if _n_ eq 1 then do;
	set hudson_bgroups (keep=pseudo_hh bgroup zip_std address2 city) end=eof1;
	dcl hash hh1 (dataset: 'hudson_bgroups', hashexp: 8, ordered:'a');
	hh1.definekey('pseudo_hh');
	hh1.definedata('pseudo_hh', 'bgroup',"zip_std","address2","city");
	hh1.definedone();
end;

do until (eof2);
	set hudson.hudson_hh end=eof2;
	if hh1.find()= 0 then output;	
	if hh1.find() ne 0 then  do;
		pseudo_hh = .;
		bgroup=.;
		zip_std = '';
		address2 = '';
		city='';
		check=1;
		output;
	end;
end;
run;

data check;
length bg $ 12;
set test1;
bg = input(bgroup,$12.);
/*where substr(bg,1,1) ne 9 and length(bg) ne 12;*/
run;

data check1;
set check;
where (substr(bg,1,1) ne '9' and substr(bg,1,1) ne '' and length(bg) ne 12) or (substr(bg,1,1) eq '9' and substr(bg,1,1) ne '' and length(bg) ne 11);
run;

data lookup;
set check;
where not( (substr(bg,1,1) ne '9' and substr(bg,1,1) ne '' and length(bg) ne 12) or (substr(bg,1,1) eq '9' and substr(bg,1,1) ne '' and length(bg) ne 11));
keep bgroup zip_std;
run;

proc sort data=lookup(keep=zip_std bgroup) nodupkey;
by zip_std bgroup;
run;

data lookup;
set lookup;
where bgroup ne . and zip_std ne '';
rename bgroup = bgroup1;
run;

data lookup;
set lookup;
flag=1;
run;

proc sort data=lookup;
by zip_std;
run;

proc sort data=check;
by zip_std;
run;

data check;
merge check (in=a) lookup(in=b);
by zip_std;
if a;
run;


proc sort data=check;
by pseudo_hh;
run;



data test1;
merge test1 (in=a) check (in=b keep=pseudo_hh bgroup1 flag);
by pseudo_hh;
if a;
run;

data test1;
length bg $ 12;
set test1;
bg = input(bgroup,$12.);
if (substr(bg,1,1) ne '9' and substr(bg,1,1) ne '' and length(bg) ne 12) or (substr(bg,1,1) eq '9' and substr(bg,1,1) ne '' and length(bg) ne 11) then check=1;
run;

data test1;
set test1;
if check eq 1 and bgroup1 ne . then bgroup=bgroup1;
run;

%squeeze (test1, hudson.hudson_hh)
;


*i only did the market saize  go to marjet part below;

*read data for internal customers;

*now I need to create interest checkiong and non interest checking somehow;
/**/
/*IXI_Assets IXI_Annuity IXI_Bond IXI_Deposits IXI_MutualFund IXI_OtherAssets IXI_StockAssets IXI_CD  */
/*IXI__MMS IXI_NonIntChecking IXI_OthChecking IXI_Savings*/


data temp_internal;
set  hudson.hudson_hh ;
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

proc sort data=branch.btas_bgroups_clean;
by bgroup branch;
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
select one.*, two.branch, two.attraction, two.weight from temp_internal_bgroup as one, branch.btas_bgroups_clean as two
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
select one.*, two.branch, two.attraction, two.weight from wallet_bgroup as one, branch.btas_bgroups_clean as two
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


LIBNAME ixi ODBC DSN=IXI user=reporting_user pw=Reporting2 schema=dbo;


proc sort data=hudson.btas_bgroups (keep=bgroup  where=(bgroup ne '')) out=bgroups  nodupkey;
by bgroup;
run;

data bgroups;
length blockgroupcode $ 12;
set bgroups;
blockgroupcode = bgroup;

run;

data bgroups;
set bgroups;
if substr(strip(blockgroupcode),1,1) eq '9' then blockgroupcode = '0' || strip(blockgroupcode) ;
run;



data market_size (rename=(TotalAssets= assets   InterestChecking=intchk MoneyMarket=mms NonInterestChecking=nonintchk OtherChecking =othchk 
                           Savings=sav MutualFunds=funds TotalHouseholds=hhs TotalHouseholdsWithAssets=asset_hh AnnuitiesHouseholds=annuity_hh 
                           BondsHouseholds=bond_hh DepositsHouseholds=dep_hh CDHouseholds=cd_hh InterestCheckingHouseholds =intchk_hh 
                           MoneyMarketHouseholds=mms_hh NonInterestCheckingHouseholds=nonintchk_hh OtherCheckingHouseholds=othchk_hh 
                           SavingsHouseholds=sav_hhs MutualFundsHouseholds=fund_hh OtherHouseholds=oth_hh StocksHouseholds=stock_hh)) 
     noixi(keep=blockgroupcode );
merge ixi.mtb_census (in=a  where=(cycleid eq 201206  )) 
      bgroups (in=b keep= bgroup blockgroupcode  where=(blockgroupcode ne '' ));
by blockgroupcode;
if b then output market_size;
if b and not a then output noixi;
drop cycleid tractcode countycode countyname statecode firm: statename;
run;

proc sql noprint;
create table market_size_extended as 
select one.*, two.hudson_branch, two.attraction, two.weight from market_size as one, hudson.btas_bgroups as two
where one.bgroup = two.bgroup
order by two.bgroup, two.hudson_branch;
quit;


proc summary data=market_size_extended (drop=bgroup attraction rename=(weight=w)) nway ;
class hudson_branch;
var assets Deposits intchk  nonintchk mms sav CD Annuities Bonds  othchk  funds Other Stocks hhs asset_hh dep_hh intchk_hh nonintchk_hh 
    mms_hh sav_hhs cd_hh annuity_hh bond_hh othchk_hh  fund_hh oth_hh stock_hh  ;
output out=market_size_branch (drop=_type_ _freq_)  sum=  ;
weight w;
run;

*do CT as the above ixi does not have it;
data market_size_ct (rename=(TotalAssets= assets   InterestChecking=intchk MoneyMarket=mms NonInterestChecking=nonintchk OtherChecking =othchk 
                           Savings=sav MutualFunds=funds TotalHouseholds=hhs TotalHouseholdsWithAssets=asset_hh AnnuitiesHouseholds=annuity_hh 
                           BondsHouseholds=bond_hh DepositsHouseholds=dep_hh CDHouseholds=cd_hh InterestCheckingHouseholds =intchk_hh 
                           MoneyMarketHouseholds=mms_hh NonInterestCheckingHouseholds=nonintchk_hh OtherCheckingHouseholds=othchk_hh 
                           SavingsHouseholds=sav_hhs MutualFundsHouseholds=fund_hh OtherHouseholds=oth_hh StocksHouseholds=stock_hh)) 
     noixi_ct (keep=blockgroupcode );
merge ixi.mtbexp_census (in=a  where=(cycleid eq 201206  )) 
      bgroups (in=b keep= bgroup blockgroupcode  where=(blockgroupcode ne '' and substr(blockgroupcode,1,2)='09'));
by blockgroupcode;
if b then output market_size_ct;
if b and not a then output noixi_ct;
drop cycleid tractcode countycode countyname statecode firm: statename;
run;

proc sql noprint;
create table market_size_extended_ct as 
select one.*, two.hudson_branch, two.attraction, two.weight from market_size_ct as one, hudson.btas_bgroups as two
where one.bgroup = two.bgroup
order by two.bgroup, two.hudson_branch;
quit;


proc summary data=market_size_extended_ct (drop=bgroup attraction rename=(weight=w)) nway ;
class hudson_branch;
var assets Deposits intchk  nonintchk mms sav CD Annuities Bonds  othchk  funds Other Stocks hhs asset_hh dep_hh intchk_hh nonintchk_hh 
    mms_hh sav_hhs cd_hh annuity_hh bond_hh othchk_hh  fund_hh oth_hh stock_hh  ;
output out=market_size_branch_ct (drop=_type_ _freq_)  sum=  ;
weight w;
run;




data merged;
merge market_size_branch (in=c)  wallet_branch (in=b) temp_internal_branch (in=a);
by branch;
if a and b and c;
run;


*this was to test the sums;
/*proc tabulate data=temp_internal_bgroup;*/
/*var intchk_Sum nonintchk_Sum mms_Sum sav_Sum tda_Sum ira_Sum sec_Sum trs_Sum mtg_Sum heq_Sum card_Sum ILN_Sum IND_Sum */
/*    sln_Sum sdb_Sum ins_Sum DDA_Amt_Sum intchk_amt_Sum nonintchk_amt_Sum MMS_amt_Sum sav_amt_Sum TDA_Amt_Sum IRA_amt_Sum */
/*    sec_Amt_Sum trs_amt_Sum MTG_amt_Sum HEQ_Amt_Sum ccs_Amt_Sum iln_amt_Sum IND_AMT_Sum sln_amt_Sum;*/
/*table sum*f=comma24.*(intchk_Sum nonintchk_Sum mms_Sum sav_Sum tda_Sum ira_Sum sec_Sum trs_Sum mtg_Sum heq_Sum card_Sum ILN_Sum IND_Sum */
/*    sln_Sum sdb_Sum ins_Sum DDA_Amt_Sum intchk_amt_Sum nonintchk_amt_Sum MMS_amt_Sum sav_amt_Sum TDA_Amt_Sum IRA_amt_Sum */
/*    sec_Amt_Sum trs_amt_Sum MTG_amt_Sum HEQ_Amt_Sum ccs_Amt_Sum iln_amt_Sum IND_AMT_Sum sln_amt_Sum);*/
/*run;*/

data hunt;
merge market_size_extended (in=c where=(branch=6424))  wallet_extended (in=b) temp_internal_extended (in=a); 
by bgroup;
if a and b and c;
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
