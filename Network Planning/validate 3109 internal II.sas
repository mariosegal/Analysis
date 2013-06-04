*extract data from customers to validate inmternal balances and HHs;
%let grouplist = '240054114071' '240054401001' '240054401002' '240054401003'
'240054401004' '240054901002' '240054902001' '240054903011' '240054903012'
'240054903013' '240054903021' '240054903022' '240054906011' '240054906012'
'240054906021' '240054906022' '240054906031' '240054906032' '240054906051'
'240054906052' '240054907011' '240054907031' '240054907032' '240054908001'
'240054908002' '240054909001' '240054909002' '240054909003' '240054910001'
'240054910002' '240054911001' '240054911002' '240054911003' '240054912011'
'240054912012' '240054912021' '240054912022' '240054913001' '240054913002'
'240054914011' '240054914012' '240054914013' '240054914021' '240054914022'
'240054915001' '240054915002' '240054915003' '240054916001' '240054916002'
'240054916003' '240054917011' '240054917012' '240054919001' '240054919002'
'240054920011' '240054920012' '240054920021' '240054920022' '240054920023'
'240054920024' '240054921011' '240054921012' '240054921013' '240054921014'
'240054921021' '240054921022' '240054922002' '245102702003' '245102703011'
'245102703012' '245102703013' '245102703014' '245102703021' '245102703022'
'245102704021' '245102704022' '245102704023' '245102704024' '245102705011'
'245102705012' '245102705013' '245102705014' '245102705022' '245102705023'
'245102705024' '245102706001' '245102706002' '245102706003' '245102706004'
'245102706005' '245102706006' '245102707011' '245102707021' '245102707022'
'245102707023' '245102707031' '245102707032' '245102707033' '245102708011'
'245102708012' '245102708013' '245102708014' '245102708021' '245102708022'
'245102708023' '245102708024' '245102708025' '245102708031' '245102708032'
'245102708033' '245102708041' '245102708042' '245102708043' '245102708044'
'245102708051' '245102708052' '245102708053' '245102708054' '245102708055'
'245102709011' '245102709012' '245102709013' '245102709021' '245102709022'
'245102709023' '245102709031' '245102709033' '245102710021' '245102710023'
'245102710024' '245102710025' '245102712001' '245102712002' '245102712003'
'245102712005' '245102712006';


data temp_3091_internal;
set data.main_201112;

keep hhid hh zip_flag block dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins
     DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_AMT sln_amt 
      bus com cbr_zip;
rename block=bgroup;
drop adj_wallet;
where block in (&grouplist) and zip_flag eq 'R' and bus eq 0 and com eq 0;
run;

proc freq data=temp_3091_internal;
table bgroup;
run;

*extract data for wallet part;

data wallet_3091;
set data.main_201112;
adj_intchk = max(intchk_amt, ixi_int_chk);
adj_nonintchk = max(nonintchk_amt, ixi_Non_Int_Chk);
adj_mms = max(mms_amt,ixi_mms);
adj_sav = max(sav_amt,ixi_savings);
adj_tda = max((tda_amt+ira_amt),ixi_tda);
adj_sec = max(sec_amt,ixi_tot-sum(ixi_int_chk,ixi_Non_Int_Chk,ixi_mms,ixi_savings,ixi_tda));
adj_dep = sum(adj_intchk,adj_nonintchk,adj_sav,adj_mms,adj_tda);
adj_tot = sum(adj_sec,adj_dep);
keep hhid zip_flag block adj: bus com cbr_zip;
rename block=bgroup;
drop adj_wallet;
where block in (&grouplist) and zip_flag eq 'R' and bus eq 0 and com eq 0;
run;

proc tabulate data=temp_3091   missing;
where zip_flag eq 'R' and sum(bus,com) eq 0;
var adj_tot adj_sec  adj_NonIntChk adj_intchk adj_sav adj_MMS adj_tda ;
table  (adj_NonIntChk adj_intchk adj_MMS adj_sav  adj_tda adj_sec adj_tot )*sum='Wallet'*f=dollar24. / nocellmerge;
run;

proc tabulate data=temp_3091 missing;
where zip_flag eq 'R' and sum(bus,com) eq 0;
var hh dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt 
   trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt ;
table  (hh='All' dda intchk nonintchk mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins)*sum='HH Count'*f=comma12.
      (DDA_Amt intchk_amt nonintchk_amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt)*sum='Balances'*f=dollar24.
	  / nocellmerge;
run;

* i extracte ddata and aggregated in excel, it matches perfectly the aggregation from tabulate, or basic ally pretty much
