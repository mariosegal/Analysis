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
proc import file='C:\Documents and Settings\ewnym5s\My Documents\Analysis\Snowbirds\email.xlsx' out=email dbms=excel replace;
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


*Analysis for Justin - focyus in uinderstanding;

*merge new data;
proc contents data=snow.fl_data varnum short;
run;

proc sort data=snow.fl_data;
by id;
run;

data snow.fl_data;
merge snow.fl_data (in=a) look1(in=b rename=(weekly=ID));
by ID;
if a;
run;


data snow.FL_Data_Updated;
set snow.fl_data ( keep =cost_center zip_num ID hhid Title_Line Address_1 Address_2 City State Zip   Email_Address );
run;

proc sort data=snow.FL_Data_Updated;
by hhid ;
run;

data snow.FL_Data_Updated;
merge  snow.FL_Data_Updated (in=a) data.main_201303;
by hhid;
if a;
run;

data snow.FL_Data_Updated;
length br_num 5;
set  snow.FL_Data_Updated;
flag= 0;
if  hhid ne '' and dda ne . then flag=1;
br_num=branch;
run;

data branches;
set branch.Mtb_branches_201206 ;
keep branch type branch_flag;
rename branch = br_num;
branch_flag = 1;
run;

proc sort data=snow.FL_Data_Updated;
by br_num ;
run;

data snow.FL_Data_Updated;
merge  snow.FL_Data_Updated (in=a) branches(in=b);
by br_num;
if a;
run;


proc freq data=snow.FL_Data_Updated order=freq;
where type eq '';
table br_num;
run;

proc sql;
select count(*) from snow.FL_Data_Updated where hhid eq '';
select count(*) from snow.FL_Data_Updated where hhid ne '' and dda eq .;
quit;

*Overall of 2,958 I had no monthly for 272, plus for 59 I did have one but not on my consumer dataset = 2948-272-59=2617;

/*data _null_;*/
/*set snow.FL_Data_Updated;*/
/*file 'C:\Documents and Settings\ewnym5s\My Documents\Analysis\Snowbirds\snowbirds.txt' dsd dlm='09'x;*/
/*put hhid;*/
/*run;*/
/**/
/**/


proc freq data=snow.FL_Data_Updated order=freq;
where flag=1;
table branch;
run;


proc tabulate data=snow.FL_Data_Updated missing;
where hhid ne '' and (hhid ne '' and dda ne .);
class type state ixi_tot cbr;
var hh dda mms sav tda ira sec mtg heq iln ind card dda_amt mms_amt sav_amt tda_amt ira_amt sec_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt ;
table type all, sum*(hh dda mms sav tda ira sec mtg heq iln ind card)*f=comma12. 
            rowpctsum<hh>*(dda mms sav tda ira sec mtg heq iln ind card)*f=pctfmt. / nocellmerge misstext='0';
table type all, sum*(dda_amt mms_amt sav_amt tda_amt ira_amt sec_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt)*f=dollar24. / nocellmerge misstext='0';
table type all, (dda_amt*rowpctsum<dda> mms_amt*rowpctsum<mms> sav_amt*rowpctsum<sav> tda_amt*rowpctsum<tda> ira_amt*rowpctsum<ira> 
             sec_amt*rowpctsum<sec> mtg_amt*rowpctsum<mtg> heq_amt*rowpctsum<heq> iln_amt*rowpctsum<iln> ind_amt*rowpctsum<ind> ccs_amt*rowpctsum<card>)*f=pctdoll.
             / nocellmerge misstext='0';
table state all, type/ nocellmerge misstext='0';
table type all, (ixi_tot all)*N*f=comma12. / nocellmerge misstext='0';
table type all, cbr;
format ixi_tot wltamt. cbr cbr2012fmt.;
run;


*prepare data for file;
data snow.Fl_data_updated;
retain miss;
merge snow.Fl_data_updated (in=a) 
      snow.branch_details (in=b keep=cost_center branch_name branch_manager External_Phone Latitude Longitude regional_manager region_name market_name market_manager
                           rename=(cost_center=br_num)) 
      email (in=c keep=branch_no email rename=(branch_no=br_num)) end=eof;
by br_num;
if a and  not b then miss+1;
if eof then put 'A not in B = ' miss;
if a;
drop miss and;
run;


proc format ;
value $ type 'Branch' = 'Branch'
             'Instore' = 'Branch'
			 'College' = 'Branch'
			 'BBC' = 'Branch'
			 'Retirement' = 'Branch'
			 other = 'Non Branch';

run;

proc freq data=snow.Fl_data_updated;
where hhid ne '' and (hhid ne '' and dda ne .);
table type / missing;
format type $type.;
run;

proc contents data=snow.Fl_data_updated varnum short;
 run;


 data temp;
 merge snow.Fl_data_updated(where=(hhid ne '' and (hhid ne '' and dda ne .))
           keep =hhid br_num Title_Line Address_1 Address_2 City State Zip Email_Address dda mms sav tda ira sec trs mtg heq card ILN  ins
           DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt  IXI_tot segment clv_total tenure_yr  type
           Branch_Name Branch_Manager External_Phone  Region_Name Regional_Manager Market_Name Market_Manager email);
format segment segfmt. ixi_tot wltamt. dda mms sav tda ira sec trs mtg heq card ILN  ins binary_flag. type $type. 
       DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt clv_total dollar24. tenure_yr comma6.1;
run;


proc export 
    data = temp outfile='C:\Documents and Settings\ewnym5s\My Documents\Analysis\Snowbirds\test.xlsx' dbms=excel replace;
run;


proc print data= temp noobs;
run;

data cnty;
length zip_num 5;
set snow.Fl_data_updated ;
keep  zip zip_char zip_num;
rename zip = zip_char;
zip_num = zip;
format zip_num z5.;
run;

proc sort data=cnty nodupkey;
by zip_num;
run;

data cnty;
merge cnty (in=a keep=zip_num rename=(zip_num=zip)) sashelp.zipcode(in=b keep=zip countynm);
by zip;
if a;

run;
 
proc print data= cnty;
run;


