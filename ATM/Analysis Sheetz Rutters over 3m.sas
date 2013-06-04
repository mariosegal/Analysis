*Read all the 1Q 2013 and related data;

data atm_dec;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ATM_dec.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input hhid $ channel $	wsid $	type $	count amount branch;
run;


data atm_jan;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ATM_jan.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input hhid $ channel $	wsid $	type $	count amount branch;
run;


data atm_feb;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ATM_feb.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input hhid $ channel $	wsid $	type $	count amount branch;
run;


data atm_mar;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ATM_mar.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input hhid $ channel $	wsid $	type $	count amount branch;
run;

%let period = 201302;
%let month = feb;
%read_monthly_data (source=main_&month..txt,identifier=&period,directory=C:\Documents and Settings\ewnym5s\My Documents\,first=2)
options compress=yes;
%SQUEEZE( data.main_&period, data.main_&period._new )
%replace(dir=data,source=main_&period._new,dest=main_&period);

%read_contr_data (source=con_&month..txt,identifier=&period,directory=C:\Documents and Settings\ewnym5s\My Documents\)
options compress=yes;
%SQUEEZE( data.contrib_&period, data.contrib_&period._new )
%replace(dir=data,source=contrib_&period._new,dest=contrib_&period);


%let period = 201301;
%let month = jan;
%read_monthly_data (source=main_&month..txt,identifier=&period,directory=C:\Documents and Settings\ewnym5s\My Documents\,first=2)
options compress=yes;
%SQUEEZE( data.main_&period, data.main_&period._new )
%replace(dir=data,source=main_&period._new,dest=main_&period);

%read_contr_data (source=con_&month..txt,identifier=&period,directory=C:\Documents and Settings\ewnym5s\My Documents\)
options compress=yes;
%SQUEEZE( data.contrib_&period, data.contrib_&period._new )
%replace(dir=data,source=contrib_&period._new,dest=contrib_&period);

data ptypes;
length hhid $ 9 stype $ 3;
infile 'C:\Documents and Settings\ewnym5s\My Documents\stypemar.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input hhid $ stype $;
run;

proc import datafile="C:\Documents and Settings\ewnym5s\My Documents\ATM\Open ATM's 2-14-13.xls" out=atm.atm_key dbms=excel;
run;


*Massage the data to get it into shape, this is one time only;

data atm_dec;
set atm_dec ;
month = 201212;
run;

data atm_jan;
set atm_jan ;
month = 201301;
run;

data atm_feb;
set atm_feb ;
month = 201302;
run;

data atm_mar;
set atm_mar ;
month = 201303;
run;


data atm.atm_key;
set atm.atm_key;
rename Import_Export_ID=wsid;
run;


data atm_dec;
length wsid $ 8 group $ 8 ;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set atm.atm_key (keep=wsid group) end=eof1;
	dcl hash hh1 (dataset: 'atm.atm_key', hashexp: 8, ordered:'a');
	hh1.definekey('wsid');
	hh1.definedata('group');
	hh1.definedone();
end;

misses = 0;
do until (eof2);
	set atm_dec end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		group = '';
		misses+1;
	end;
	output;
end;

putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;


data atm_jan;
length wsid $ 8 group $ 8 ;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set atm.atm_key (keep=wsid group) end=eof1;
	dcl hash hh1 (dataset: 'atm.atm_key', hashexp: 8, ordered:'a');
	hh1.definekey('wsid');
	hh1.definedata('group');
	hh1.definedone();
end;

misses = 0;
do until (eof2);
	set atm_jan end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		group = '';
		misses+1;
	end;
	output;
end;

putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;

data atm_feb;
length wsid $ 8 group $ 8 ;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set atm.atm_key (keep=wsid group) end=eof1;
	dcl hash hh1 (dataset: 'atm.atm_key', hashexp: 8, ordered:'a');
	hh1.definekey('wsid');
	hh1.definedata('group');
	hh1.definedone();
end;

misses = 0;
do until (eof2);
	set atm_feb end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		group = '';
		misses+1;
	end;
	output;
end;

putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;

data atm_mar;
length wsid $ 8 group $ 8 ;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set atm.atm_key (keep=wsid group) end=eof1;
	dcl hash hh1 (dataset: 'atm.atm_key', hashexp: 8, ordered:'a');
	hh1.definekey('wsid');
	hh1.definedata('group');
	hh1.definedone();
end;

misses = 0;
do until (eof2);
	set atm_mar end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		group = '';
		misses+1;
	end;
	output;
end;

putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;


proc tabulate data=atm_dec out=dec ;
where group eq '';
class wsid;
var count;
table wsid, N sum*count / ;
run;

proc tabulate data=atm_jan out=jan ;
where group eq '';
class wsid;
var count;
table wsid, N sum*count / ;
run;


proc tabulate data=atm_feb out=feb ;
where group eq '';
class wsid;
var count;
table wsid, N sum*count / ;
run;


proc tabulate data=atm_mar out=mar ;
where group eq '';
class wsid;
var count;
table wsid, N sum*count / ;
run;

data missings;
set dec jan feb mar;
run;

proc sort data=missings;
by wsid;
run;

proc summary data=missings;
by wsid;
output out = weird sum(count_sum)=count;
run;

proc print data=weird;
var wsid count;
run;

*create tabulates for each month, I will need to redo if I fix the ATMs not categorized;

proc format;
value $ atm 'Sheetz' = 'Sheetz'
			'Rutters' = 'Rutters'
			'Branch' = 'Branch'
			'Blank' = 'Branch'
			'Foreign' = 'Foreign'
			other = 'Oth Part'
			'' = 'Oth Part';
run;

%let month = mar;
*run it for dec, jan, feb, mar;

data atm_&month;
set atm_&month;
if channel = "ATMT" then group = "Foreign";
group_new = put(group,$atm.);
run;

proc sort data=atm_&month;
by hhid group_new;
run;

proc summary data=atm_&month;
by hhid group_new;
output out=&month._sum 
       sum(count)= count
	   sum(amount) = amount;
run;

proc transpose data=&month._sum (drop = _:) out=&month._tran(drop=_name:) prefix=&month._ suffix=_count;
by hhid;
var count;
id group_new;
run;

proc transpose data=&month._sum (drop = _:) out=&month._tran1(drop=_name:) prefix=&month._ suffix=_amt;
by hhid;
var amount;
id group_new;
run;

*------;

data atm.atm_usage;
merge dec_tran dec_tran1 jan_tran jan_tran1 feb_tran feb_tran1 mar_tran mar_tran1;
by hhid;
run;

data atm.atm_usage;
set atm.atm_usage;
sheetz_months = min(max(dec_sheetz_count,0),1) + min(max(jan_sheetz_count,0),1) + min(max(feb_sheetz_count,0),1) + min(max(mar_sheetz_count,0),1)  ;
sheetz_count = sum(dec_sheetz_count,jan_sheetz_count,feb_sheetz_count,mar_sheetz_count);
sheetz_amt = sum(dec_sheetz_amt,jan_sheetz_amt,feb_sheetz_amt,mar_sheetz_amt);

rutters_months = min(max(dec_rutters_count,0),1) + min(max(jan_rutters_count,0),1) + min(max(feb_rutters_count,0),1) + min(max(mar_rutters_count,0),1)  ;
rutters_count = sum(dec_rutters_count,jan_rutters_count,feb_rutters_count,mar_rutters_count);
rutters_amt = sum(dec_rutters_amt,jan_rutters_amt,feb_rutters_amt,mar_rutters_amt);

branch_months = min(max(dec_branch_count,0),1) + min(max(jan_branch_count,0),1) + min(max(feb_branch_count,0),1) + min(max(mar_branch_count,0),1)  ;
branch_count = sum(dec_branch_count,jan_branch_count,feb_branch_count,mar_branch_count);
branch_amt = sum(dec_branch_amt,jan_branch_amt,feb_branch_amt,mar_branch_amt);

foreign_months = min(max(dec_foreign_count,0),1) + min(max(jan_foreign_count,0),1) + min(max(feb_foreign_count,0),1) + min(max(mar_foreign_count,0),1)  ;
foreign_count = sum(dec_foreign_count,jan_foreign_count,feb_foreign_count,mar_foreign_count);
foreign_amt = sum(dec_foreign_amt,jan_foreign_amt,feb_foreign_amt,mar_foreign_amt);

oth_part_months = min(max(dec_oth_part_count,0),1) + min(max(jan_oth_part_count,0),1) + min(max(feb_oth_part_count,0),1) + min(max(mar_oth_part_count,0),1)  ;
oth_part_count = sum(dec_oth_part_count,jan_oth_part_count,feb_oth_part_count,mar_oth_part_count);
oth_part_amt = sum(dec_oth_part_amt,jan_oth_part_amt,feb_oth_part_amt,mar_oth_part_amt);

non_sheetz_count = sum(oth_part_count,rutters_count,branch_count);
non_sheetz_amt = sum(oth_part_amt,rutters_amt,branch_count);
non_rutters_count = sum(oth_part_count,sheetz_count,branch_count);
non_rutters_amt = sum(oth_part_amt,sheetz_amt,branch_count);

run;


proc tabulate data=atm.atm_usage;
class sheetz_months sheetz_count;
var ;
table sheetz_months='Number of Months' All,(sheetz_count='Total Transactions' All)*(N='HHs'*f=comma12. rowpctn='Row Percent'*f=pctfmt.)/ nocellmerge;
format sheetz_count trans. ;
run;

proc format;
value mytrans (notsorted) 
	., 0 = 'None'
	1-2 = '1 to 2'
	3-5 = '3 to 5'
	6-10 = '6 to 10'
	11-high = 'Over 10';
run;


proc tabulate data=atm.atm_usage out=chartdata (rename=(N=HH)) missing;
class sheetz_months foreign_count sheetz_count non_sheetz_count;
table sheetz_months*foreign_count*sheetz_count*non_sheetz_count,N*f=comma12. / nocellmerge;
format foreign_count mytrans.;
run;

proc tabulate data=atm.atm_usage  missing;
class sheetz_months foreign_count sheetz_count non_sheetz_count;
table sheetz_months,N*f=comma12. / nocellmerge;
format foreign_count mytrans.;
run;

proc freq data=atm.atm_usage;
table sheetz_months;
run;


proc sgpanel data=chartdata ;
where sheetz_months ne 0;
panelby sheetz_months / onepanel layout=panel columns=2;
bubble x=sheetz_count y=non_sheetz_count size=N / group=foreign_count bradiusmax = 5pct;
colaxis min=0 max=100 label='Other M&T ATM Withdrawals (Branch or Partner)';
rowaxis min=0 max=100 label='Sheetz ATM Withdrawals (Branch or Partner)';
run;

ods html style= mtbnew;
proc sgplot data=chartdata;
where sheetz_months eq 4;
/*panelby sheetz_months / onepanel layout=panel columns=2;*/
bubble x=sheetz_count y=non_sheetz_count size=N / group=foreign_count bradiusmax = 5% name="a";
yaxis min=0 max=100 label='Other M&T ATM Withdrawals (Branch or Partner)' labelattrs=(weight=Bold);
xaxis min=0 max=100 label='Sheetz ATM Withdrawals (Branch or Partner)' labelattrs=(weight=Bold);
lineparm x=0 y=0 slope=1 / lineattrs=(color="red") name="b";
keylegend "a"/ title='Foreign ATM Withdrawals' titleattrs=(weight=Bold);
run;

*this w3as the chart used;
proc sort data=chartdata;
by descending sheetz_months;
run;

ods graphics on /  ANTIALIASMAX=2700 height=5.5in width=9in;
proc sgplot data=chartdata;
where  sheetz_months ne 0;
bubble x=sheetz_count y=non_sheetz_count size=HH / group=sheetz_months bradiusmin = 5 bradiusmax = 50 name="a" transparency=0.5;
yaxis grid min=0 max=100 label='Other M&T ATM Withdrawals (Branch or Partner)' labelattrs=(weight=Bold);
xaxis grid min=0 max=100 label='Sheetz ATM Withdrawals (Branch or Partner)' labelattrs=(weight=Bold);
lineparm x=0 y=0 slope=1 / lineattrs=(color="red") name="b";
keylegend "a"/ title='Months Using Sheetz ATM' titleattrs=(weight=Bold);
run;


*dump some numbers for annotations;
proc tabulate data=chartdata missing;
where sheetz_months ne 0;
class sheetz_count non_sheetz_count sheetz_months;
var HH;
table (sheetz_count all), (non_sheetz_count all)*sum*(HH)*f=comma12.;
table all, sum*(hh);
table sheetz_months all, (sheetz_count all), (non_sheetz_count all)*sum*(HH)*f=comma12.;
format sheetz_count non_sheetz_count mytrans.;
run;

proc sql;
select sheetz_months, sum(HH) from chartdata where sheetz_count gt non_sheetz_count group by sheetz_months;
select sheetz_months, sum(HH) from chartdata where sheetz_count gt non_sheetz_count+1  group by sheetz_months;
select sheetz_months, sum(HH) from chartdata where sheetz_count le non_sheetz_count+1  group by sheetz_months;
quit;


data atm.atm_usage;
length sheetz_grp $ 8;
set atm.atm_usage;
select;
	when(sheetz_months in (3,4) and (max(sheetz_count,0) / sum(non_sheetz_count,sheetz_count)) gt 0.33)  sheetz_grp = 'High';
		when(sheetz_months in (3,4) and (max(sheetz_count,0) / sum(non_sheetz_count,sheetz_count,branch_count)) le 0.33)  sheetz_grp = 'Med';
	when(sheetz_months eq 2 and (max(sheetz_count,0) / sum(non_sheetz_count,sheetz_count)) gt 0.5)  sheetz_grp = 'High';
	when(sheetz_months eq 2 and (max(sheetz_count,0) / sum(non_sheetz_count,sheetz_count)) le 0.5 and (sheetz_count / sum(non_sheetz_count,sheetz_count)) gt 0.25)  sheetz_grp = 'Med';
	when(sheetz_months eq 2 and (max(sheetz_count,0) / sum(non_sheetz_count,sheetz_count)) le 0.25) sheetz_grp = 'Low';
	when(sheetz_months eq 1 )  sheetz_grp = 'Low';
	otherwise sheetz_grp = 'None';
end;
run;

proc freq data=atm.atm_usage;
table sheetz_grp*sheetz_months / nocol norow nopercent;
run;

options compress=yes;

proc sort data=atm.atm_usage;
by hhid;
run;

data data.main_201303;
set data.main_201303;
drop sheetz_usage_num sheetz_usage Sheetz_grp;
run;

data data.main_201303;
merge data.main_201303 (in=a) atm.atm_usage (in=b keep=hhid sheetz_grp);
by hhid;
if a;
run;

data data.main_201303;
set data.main_201303;
if sheetz_grp eq '' then sheetz_grp = 'xMTB ATM';
run;

proc format ;
value $ sheetz (notsorted)
	'High' = 'High Sheetz Dependency'
	'Med' = 'Moderate Sheetz Dependency'
	'Low' = 'Limited Sheetz Usage'
	'None' = 'No Sheetz ATM Usage'
	'xMTB ATM' = 'No M&T ATM Usage';
run;

/*data data.main_201303;*/
/*set data.main_201303;*/
/*rename sheetz_grp = sheetz_usage;*/
/*run;*/

data data.main_201303;
set data.main_201303 (rename=(sheetz_grp = sheetz_usage));
select(sheetz_usage);
	when ('High') sheetz_usage_num = 3;
	when ('Med') sheetz_usage_num = 2;
	when ('Low') sheetz_usage_num = 1;
	when ('None') sheetz_usage_num = 4;
	when ('xMTB ATM') sheetz_usage_num = 5;
end;
run;

proc format ;
value sheetz_num (notsorted)
1 = 'Limited Sheetz Usage'
	2 = 'Moderate Sheetz Dependency'
		3 = 'High Sheetz Dependency'
	4 = 'No Sheetz ATM Usage'
	5 = 'No M&T ATM Usage';
run;


option compress=no;
filename mprint "C:\Documents and Settings\ewnym5s\My Documents\SAS\sheetz_macro.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic ;

%create_report(class1 = sheetz_usage_num ,fmt1 = sheetz_num ,out_dir = C:\Documents and Settings\ewnym5s\My Documents\SAS, 
                main_source = data.main_201303,  contrib_source = data.contrib_201303, condition = dda eq 1,
                out_file=Sheetz_Profile_20130429,
                logo_file= C:\Documents and Settings\ewnym5s\My Documents\Tools\logo.png)

;


*data for boxxplots;
proc format;
value order 1 = 'Checking' 2 = 'Money Mkt' 3 = 'Savings' 4 = 'Time Dep' 5 = 'IRAs' 6 = 'Credit Card' 7 = 'Dir. Loan' 8 = 'Ind. Loan' 9 = 'Securities' 10= 'Mortgage' 11='Home Equity';
run;

proc tabulate data=box1;
class variable order;
var balance;
table  balance*(N q1 qrange mean median), order*variable / nocellmerge;
format order order.;
run;


proc tabulate data=temp_contr;
class sheetz_usage_num ;
var total_contr;
table  total_contr*(N q1 qrange median mean ), sheetz_usage_num / nocellmerge;
format sheetz_usage_num sheetz_num.;
run;


proc tabulate data=data.main_201303;
where dda eq 1;
class sheetz_usage_num ;
var svcs;
table  svcs*(N q1 qrange median mean ), sheetz_usage_num / nocellmerge;
format sheetz_usage_num sheetz_num.;
run;

proc tabulate data=atm.cbox1;
class variable order;
var contribution;
table  contribution*(N q1 qrange median mean), order*variable / nocellmerge;
format order order.;
run;


*where do they live;
proc freq data=data.main_201303 order=freq;
where dda eq 1 and sheetz_Usage_num le 3;
table zip*sheetz_Usage_num /nocol norow nopercent out=zips;
format sheetz_usage_num sheetz_num.;
run;

proc freq data=atm.atm_usage;
table sheetz_grp;
run;


data high med low;
set zips;
if sheetz_usage_num eq 3 then output high;
if sheetz_usage_num eq 2 then output med;
if sheetz_usage_num eq 1 then output low;
run;


proc sort data=high;
by descending count;
run;

proc sql;
select sum(count) into :total from high ;
quit;

data high;
set high;
percent = count/&total;
run;

proc print data=high (obs=25);
sum count percent ;
run;

data high ;
length zip 5;
set high (rename=(zip=zipstring));
zip = put(zipstring, 5.);
state = zipstate(zip);
format zip z5.;
run;

data high ;
set high;
rename zipstring=zcta;
run;

libname mapfiles 'C:\Documents and Settings\ewnym5s\My Documents\SAS Map Data';

proc sort data=high (obs=50) out=top;
by zcta;
run;

data mapdata;
merge mapfiles.Zips_pa_md (in=a) top(in=b keep=zcta count);
by zcta;
if a;
run;


proc gmap  map=mapdata;
id zcta;
choro count /cempty=grey;
run;
quit;



*what ATMs are they using;


options compress=yes;
data atm.atm_usage;
set atm.atm_usage;
select(sheetz_grp);
	when ('High') sheetz_usage_num = 3;
	when ('Med') sheetz_usage_num = 2;
	when ('Low') sheetz_usage_num = 1;
	when ('None') sheetz_usage_num = 4;
	when ('xMTB ATM') sheetz_usage_num = 5;
end;
run;


data atms;
set atm_dec atm_jan atm_feb atm_mar;
run;

proc sort data=atms;
by wsid;
run;

proc summary data=atms(where=(channel="ATMO")) noprint;
by wsid;
output out=atm_sum sum(count)=count sum(amount)=amount;
run;

proc sort data=atm.atm_key;
by wsid;
run;

data atm_sum;
merge atm_sum (in=a) atm.atm_key (keep=wsid terminal_zip group in=b);
by wsid;
if a;
run;

data top_sheetz;
set atm_sum;
where group = "Sheetz";
run;

proc sort data=top_sheetz;
by descending count;
run;

proc export data=high(obs=50) outfile='C:\Documents and Settings\ewnym5s\My Documents\ATM\top_zips.xls' dbms=excel replace;
run;


proc export data=top_sheetz(obs=50) outfile='C:\Documents and Settings\ewnym5s\My Documents\ATM\top_sheetz.xls' dbms=excel replace;
run;


proc tabulate data=atm.atm_usage out=trans;
class sheetz_usage_num;
var sheetz_count non_sheetz_count oth_part_count branch_count rutters_count;
table sheetz_usage_num, (sheetz_count non_sheetz_count oth_part_count branch_count rutters_count)*(N*f=comma12. sum*f=comma12.) / nocellmerge;
run;
