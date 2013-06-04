libname  infousa oledb provider=jet datasource='\\koenig\Source\Master_FullFile_Main.mdb';

data wip.medical;
set infousa.info_1;
where substr(primary_sic_code,1,4) in ('8011' ,'8021','8031','8041','8042','8043','8044','8049','8050','8062','8071','8099');
keep PROSPECT_CUSTOMER_INDICATOR account_id market primary_sic_code Location_Employment_Size_Desc Location_Sales_Volume_Desc primary_state;
run;

proc tabulate data=wip.medical missing;
class primary_state PROSPECT_CUSTOMER_INDICATOR;
table primary_state ALL, PROSPECT_CUSTOMER_INDICATOR*N='Count'*f=comma12.;
format PROSPECT_CUSTOMER_INDICATOR $quick.;
run;



proc format;
 value $ quick  'X' = 'Customer'
			  other = 'Prospect';
run;
