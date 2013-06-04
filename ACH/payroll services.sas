libname  infousa oledb provider=jet datasource='\\koenig\Source\Master_FullFile_Main.mdb';



options obs=max;

data info_data;
length hhid $ 9;
 set infousa.info_1;
 where length(account_ID) eq 9;
 hhid = account_id;
 run;


proc sort data=info_data;
by hhid;
run;

data temp_payroll;
length hhid $ 9;
set ifm.ifm_bus_profile (where=(PayrollProcessor ne ''));
keep payrollprocessor hhkey PayrollProcessorAmount hhid Perioddate;
hhid = hhkey;
run;

proc sort data=temp_payroll;
by hhid;
run;

data merged;
merge temp_payroll(in=b ) info_data (in=a ) ;
by hhid;
if b;
run;

proc sort data=merged SORTSEQ=LINGUISTIC(NUMERIC_COLLATION=ON);
by Location_Employment_Size_Desc;
run;

proc tabulate data=merged missing order=freq;
where perioddate eq '01JUN2012:00:00:00.000'dt;
class Location_Sales_Volume_Desc /preloadfmt;
class payrollprocessor perioddate ;
var PayrollProcessorAmount;
table payrollprocessor,Location_Sales_Volume_Desc='Sales'*(N='Accts'*f=comma12.0 PayrollProcessorAmount='Amount'*mean='Avg.'*f=dollar12.0) /nocellmerge;
format Location_Sales_Volume_Desc $salesband.;
run;

proc tabulate data=merged missing order=data;
where perioddate eq '01JUN2012:00:00:00.000'dt;
class Location_Employment_Size_Desc /preloadfmt;
class payrollprocessor perioddate ;
var PayrollProcessorAmount;
table payrollprocessor,Location_Employment_Size_Desc='Employees'*(N='Accts'*f=comma12.0 PayrollProcessorAmount='Amount'*mean='Avg.'*f=dollar12.0) /nocellmerge;
format Location_Employment_Size_Desc $emplbandnew.;
run;

* tabulate to show IFM of sudden growth *;
proc tabulate data=temp_payroll missing;
class payrollprocessor perioddate;
var PayrollProcessorAmount;
table payrollprocessor,perioddate*(N='Accts' PayrollProcessorAmount*(sum='Total' mean='Avg.')) /nocellmerge;
run;


proc format library=sas cntlout=fmt;
select $emplbandnew;
run;

data fmt;
length order 8;
set fmt;
if end ne 'NULL' then order = put(scan(end,1),6.0);
if end eq 'NULL' then order = 9999;
run;

proc sort data=fmt;
by order;
run;

data fmt;
set fmt;
fmtname = 'EMPLBANDNEW';
run;

proc format library=sas cntlin=fmt ;
run;

proc format library=sas  fmtlib;
select $emplbandnew;
run;
