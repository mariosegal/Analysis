proc freq data=ixi_new.mtb_tiers_postal;
table cycleid;
run;


libname IXI_NEw oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=IXI;
 Data Source=bagels"  schema=dbo; 

data ixi_hudson_assets;
set ixi_new.MTB_Census;
where cycleid = 201106 and statecode in ('09','36','34');
run;


data ixi_hudson_tiers;
set ixi_new.MTB_Tiers_census;
where cycleid = 201106 and statecode in ('09','36','34');
run;

proc contents data=ixi_hudson_assets varnum short;
run;

data _null_;
file 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\wealth.txt' dsd dlm='09'x;
set ixi_hudson_assets;
avgdep = 0;
if DepositsHouseholds ne 0 then avgdep = Deposits/DepositsHouseholds;
avgassets = 0;
if TotalHouseholdsWithAssets ne 0 then avgassets= totalassets/TotalHouseholdsWithAssets;
put BlockGroupCode	StateCode TotalAssets Deposits DepositsHouseholds TotalHouseholdsWithAssets avgdep avgassets;
run;



