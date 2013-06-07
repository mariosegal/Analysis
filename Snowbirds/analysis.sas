libname snow 'C:\Documents and Settings\ewnym5s\My Documents\Analysis\Snowbirds' ;

proc import file='C:\Documents and Settings\ewnym5s\My Documents\Snowbirds\Fl List.xlsx' out=snow.FL_data dbms=excel replace;
run;

proc import file='C:\Documents and Settings\ewnym5s\My Documents\Snowbirds\TelExportRpt.xlsx' out=tel dbms=excel replace;
run;

proc import file='C:\Documents and Settings\ewnym5s\My Documents\Snowbirds\BrnOrgExport.xlsx' out=org dbms=excel replace;
run;



proc import file='C:\Documents and Settings\ewnym5s\My Documents\Snowbirds\BrnExport.xlsx' out=branch dbms=excel replace;
run;



data snow.branch_details;
merge branch (in=a) org (in=b) tel(in=c rename=(branch_number=cost_center) drop=closest_branch);
by cost_center;
if a ;
run;


data snow.fl_data;
length cost_center 8;
set snow.fl_data;
cost_center = branch_domiciled;
run;

proc sort data=snow.fl_data;
by cost_center;
run;

data snow.fl_data;
retain miss;
merge snow.fl_data (in=a) snow.branch_details (in=b keep=cost_center branch_name branch_manager External_Phone Latitude Longitude regional_manager region_name market_name market_manager) end=eof;
by cost_center;
if a then output;
if a and not b then miss+1;
if eof then put "WARNING: There were " miss 'Records with no branch match';
drop miss;
run;


proc freq data=snow.fl_data;
where market_manager eq '';
 table cost_center*flag_checking;
 run;


proc tabulate  data=snow.fl_data order=freq;
class branch_manager cost_center;
table branch_manager*cost_center,N*f=comma12.;
run;

proc sort data=snow.fl_data;
by zip_num;
run;

data snow.fl_data;
length zip_num 8;
set snow.fl_data ;
zip_num = zip;
run;


data snow.fl_data;
merge snow.fl_data (in=a) sashelp.zipcode (in=b keep=zip countynm state county rename=(zip=zip_num state=fips));
by zip_num;
if a;
run;

proc freq data=snow.fl_data;
where countynm eq '';
table zip_num;
run;


proc freq data=snow.fl_data order=freq;
table countynm ;
table market_name;
table countynm*market_name / nocol norow nopercent out=cross;
run;



proc freq data=snow.fl_data order=freq;
where countynm ne '' and market_name ne '';
table countynm*market_name / nocol norow nopercent out=cross;
run;

proc export data=cross outfile='C:\Documents and Settings\ewnym5s\My Documents\Snowbirds\where_to_data.xlsx' dbms=excel replace;
run;

*add emails;
proc import file='C:\Documents and Settings\ewnym5s\My Documents\Snowbirds\email.xlsx' out=email dbms=excel replace;
run;

data snow.fl_data;
merge snow.fl_data (in=a) email (in=b keep = branch_no brmanager email phone rename=(branch_no=cost_center));
by cost_center;
if a;
run;

proc sort data=snow.fl_data;
by countynm cost_center ;
run;

proc freq data=snow.fl_data order=freq;
by countynm;
run;

data snow.fl_data;
set snow.fl_data;
full_address = catx("; ",title_line, address_1||address_2, catx(" ",catx(", ",city,state),zip));
run;

proc sort data=snow.fl_data;
by cost_center  ;
run;

data snow.fl_data;
merge snow.fl_data (in=a) snow.branch_details (in=b keep = cost_center market_name market_manager );
by cost_center;
if a;
run;


proc sort data=snow.fl_data;
by countynm cost_center ;
run;
ods pdf file='C:\Documents and Settings\ewnym5s\My Documents\Snowbirds\Report.pdf';
Title ;
proc report data=snow.fl_data (obs=max) nowd split="";
where cost_center not in (., 999);
Column countynm cost_center brmanager email phone full_address flag_checking flag_CD Flag_InvestmentInsurance ixi_range; 
define countynm / order width=15 left order= freq descending 'County Name' ;
define cost_center / order width=5 left order=freq 'M&T Branch';
define brmanager / order width=25 left 'Branch Manager';
define email / order width=25 left 'Mgr. Email';
define phone / order width=15 left 'Mgr. Phone';
define full_address / order style(column)=[cellwidth=2in] left 'Customer Details';
define flag_checking / width=1 center 'Has Checking';
define flag_CD / width=1 center 'Has CD';
define Flag_InvestmentInsurance / width=1 center 'Has Investments';
define ixi_range / width=11 center 'Estimated Wealth';

break after countynm / page suppress ;
break before cost_center / ol;
break after cost_center / skip ;
break after brmanager / skip suppress;
break after email / skip suppress;
break after phone / skip suppress;
break before full_address / skip;
run;
quit;


proc sort data=snow.fl_data;
by countynm market_name ;
run

*create simple table for excel filter;
proc print data=snow.fl_data;
where cost_center not in (., 999);
var countynm market_name market_manager cost_center brmanager email phone full_address flag_checking flag_CD Flag_InvestmentInsurance ixi_range; 
run;
