LIBNAME ixi ODBC DSN=IXI user=reporting_user pw=Reporting2 schema=dbo;


proc freq data=ixi.mtb_census;
table statename*cycleid;
run;


data market_size (rename=(TotalAssets= assets   InterestChecking=intchk MoneyMarket=mms NonInterestChecking=nonintchk OtherChecking =othchk 
                           Savings=sav MutualFunds=funds TotalHouseholds=hhs TotalHouseholdsWithAssets=asset_hh AnnuitiesHouseholds=annuity_hh 
                           BondsHouseholds=bond_hh DepositsHouseholds=dep_hh CDHouseholds=cd_hh InterestCheckingHouseholds =intchk_hh 
                           MoneyMarketHouseholds=mms_hh NonInterestCheckingHouseholds=nonintchk_hh OtherCheckingHouseholds=othchk_hh 
                           SavingsHouseholds=sav_hhs MutualFundsHouseholds=fund_hh OtherHouseholds=oth_hh StocksHouseholds=stock_hh)) 
     noixi(keep=blockgroupcode );
set  ixi.mtb_census (  where=(cycleid eq 201206 and blockgroupcode in ('361031700011','361031700012','361031700013','361031700014','361031700015','361031700025')  )) ;
drop cycleid tractcode countycode countyname statecode firm: statename;
run;
