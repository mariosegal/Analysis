proc tabulate data=hudson.hudson_hh missing;
where state in ('NY',"NJ","CT");
class state countynm;
table state*countyNM, N;
run;

LIBNAME ixi ODBC DSN=IXI user=reporting_user pw=Reporting2 schema=dbo;
LIBNAME hud_data ODBC DSN=Hudsonsql user=reporting_user pw=Reporting2 schema=dbo;

proc contents data=hud_data.MKT_anlaysis_chk_123112 varnum short;
run;

proc sort data=hud_data.MKT_anlaysis_chk_123112;
by acct_nbr;
run;


proc sort data=hudson.clean_20121106;
by acct_nbr;
run;

options compress=yes;
data hudson.clean_20121106;
merge hudson.clean_20121106 (in=a) 
hud_data.MKT_anlaysis_chk_123112 (in=b keep=ACCT_NBR  STATUS ATM_WD_HUDSON ATM_WD_OTHER DEBIT_PURCH CHKS_PO_MTH CHKS_PO_YTD ACH_OUT_YTD ACH_OUT_PYR ND_ANALYSIS Field16 rename=(status=status_dec)) end=eof ;
retain miss;
by acct_nbr;
if a then output;
if b and not a then miss+1;
if eof then do;
	put "WARNING: Records in b file not on A = " miss;
end;
run;

data hudson.Bta_for_oppty_3mile;
set BTAs;
drop f5 f6;
run;

data zipcode;
length zip_new $ 5;
set sashelp.zipcode ( keep=zip countynm zip_class);
zip_new = put(zip,z5.);
rename zip=zip_old zip_new=zip;
run;


data hudson.Bta_for_oppty_3mile;
merge hudson.Bta_for_oppty_3mile (in=a) zipcode (in=b keep=zip countynm zip_class);
by zip;
if a;
run;


data hudson.Bta_for_oppty_3mile;
set hudson.Bta_for_oppty_3mile;
if zip in ('12508','10428') or state eq 'PA' then exclude = 1;
run;

proc tabulate  data=hudson.Bta_for_oppty_3mile missing;
class state countynm exclude;
table state*countynm, exclude;
run;


data hudson.Bta_for_oppty_3mile;
length bta_group $ 7;
set hudson.Bta_for_oppty_3mile;
if state eq 'CT' then bta_group = 'CT';
if state eq 'NY' and countynm in ('Westchester','Rockland','Putnam') then bta_group = 'Upstate';
if state eq 'NY' and countynm in ('Orange') and exclude ne 1 then bta_group = 'Upstate';
if state eq 'NY' and countynm in ('Richmond') then bta_group = 'Staten';
if state eq 'NY' and countynm in ('New York','Bronx','Kings') then exclude = 1;
if state eq 'NY' and countynm in ('Suffolk') then bta_group = 'LI';
if state eq 'NJ'  then bta_group = 'NJ';
if zip in ('12508','10928') or state eq 'PA' then exclude = 1;
rename exclude=bta_exclude;
run;

proc tabulate  data=hudson.Bta_for_oppty_3mile missing;
class state bta_group countynm exclude;
table bta_group*state*countynm, exclude;
run;

proc sort data=hudson.hudson_hh;;
by zip_clean;
run;

data hudson.hudson_hh;
merge  hudson.hudson_hh (in=a )  hudson.Bta_for_oppty_3mile (in=b keep =zip bta_group bta_exclude where=(bta_exclude ne 1) rename=(zip=zip_clean));
by zip_clean;
if a;
drop bta_exclude;
run;

*add assorted NJ codes to fill holes;
data hudson.hudson_hh;
set hudson.hudson_hh;
if zip_clean in ("08030","08104","08103","08102","08105","08063","08553","08528","08558") then bta_group = 'NJ';
run;

data extra;
length zip_num 8;
do zip=  "08030","08104","08103","08102","08105","08063","08553","08528","08558";
	state="NJ";
	source="Manual1";
	bta_group="NJ";
	zip_num = zip;
	output;
end;
format zip_num z5.;
run;

proc sort data=extra;
by zip;
run;

data extra;
merge extra (in=a ) sashelp.zipcode (in=b keep=zip countynm zip_class rename=(zip=zip_num));
by zip_num;
if a;
run;
 options compress=yes;
data hudson.Bta_for_oppty_3mile;
set hudson.Bta_for_oppty_3mile extra;
run;

proc freq data=hudson.hudson_hh;
table state*bta_group /missing;
run;

proc freq data=hudson.hudson_hh;
table bta_group /missing;
run;

*watewrfall;
proc sql;
select count(*) as total from hudson.hudson_hh;
select count(*) as no_consumer from hudson.hudson_hh where products in (0,.);
select count(*) as external from hudson.hudson_hh where products not in (0,.) and external eq 1;
select count(*) as not_in_footprint from hudson.hudson_hh where products not in (0,.) and external eq 0 and bta_group not in ('CT','Staten','LI','NJ','Upstate');
select count(*) as analysis from hudson.hudson_hh where products not in (0,.) and external eq 0 and bta_group  in ('CT','Staten','LI','NJ','Upstate');
select state, sum(hh) as not_in_footprint from hudson.hudson_hh where products not in (0,.) and external eq 0 and bta_group not in ('CT','Staten','LI','NJ','Upstate') group by state;
quit;

proc tabulate data=hudson.hudson_hh missing;
where products not in (0,.) and external eq 0 and bta_group not in ('CT','Staten','LI','NJ','Upstate');
where also state in ('NY',"NJ");
class state countynm;
table state*countynm='County',N*f=comma12.;
run;


where external ne 1 and products ne .
