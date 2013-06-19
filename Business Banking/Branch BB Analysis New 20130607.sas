*Read and clean the data;

libname data1  'C:\Documents and Settings\ewnym5s\My Documents\Analysis\Network Planning\Business Customers and Prospects by County  Zip Code.xlsx';

data data2;
set data1.'Prospects by Zip$'n;
where zip ne .;
	   drop f9 f10 f11 f12;
	   rename zip=zip_num;
run;

proc datasets library=work;
modify data2;
attrib _all_ label=' ';
run;


data branch.bb_prospects;
length zip $ 5;
set data2;
ZIP = put(zip_num,z5.);
rename __Prospects=prospects Avg___Emp=avg_emp __TS=TS __Emp=Employees __TS0=targets;
run;

*Merge with BTAs, using zip as key;
libname bta   'C:\Documents and Settings\ewnym5s\My Documents\Analysis\Network Planning\BB_BTA_20130613.xls';

data branch.BTA_20130607;
set bta.'BB_BTA_20130613$'n;
run;

libname radii 'C:\Documents and Settings\ewnym5s\My Documents\Analysis\Network Planning\Radii BB Analysis Full 20130613.xlsx';

*merge with braches to define if some did not pick any zips;

/*data  branch.BTA_20130607;*/
/*merge branch.BTA_20130607 (in=a) radii.data (in=b);*/
/*by branch_id;*/
/*if a or b;*/
/*run;*/

*140 did, so instead, I will add to the bottom the  radii file, with some renaming that will add the branch zxip to the BTA, then I wil dedupe by branch/zip in case it was there;

/*data  branch.BTA_20130607;*/
/*merge branch.BTA_20130607 (in=a) radii.'Sheet1$'n (in=b);*/
/*by branch_id;*/
/*if a ;*/
/*run;*/

data  branch.BTA_20130607;
set branch.BTA_20130607  radii.'Sheet1$'n;
run;

data  branch.BTA_20130607;
set branch.BTA_20130607;
if zip eq '' then zip = br_zip;
run;


proc sort data= branch.BTA_20130607;
by branch_id zip;
run;

data  branch.BTA_20130607;
set branch.BTA_20130607;
by branch_id zip;
*if each zip shows once in each branch then you will never have a record with first.zip and not last.zip;
if first.zip and not last.zip then delete;
run;

data  branch.BTA_20130607;
length zip_match $ 5;
set branch.BTA_20130607;
zip_match = zip;
run;

proc sort data=branch.BTA_20130607;
by zip_match;
run;

proc sort data=branch.bb_prospects;
by zip;
run;



data branch.bb_opp_data;
merge branch.BTA_20130607 (in=a where=(zip ne '' and zip ne '8065')) branch.bb_prospects (in=b rename=(zip=zip_match)) end=eof;
retain miss miss1;
by zip_match;
if a then output;
if a and not b then miss+1;
if b and not a then miss1+1;
if eof then do;
	put 'WARNING: a and not b =  ' miss;
	put 'WARNING: b and not a =  ' miss1;
end;
drop miss:;
run;

data branch.bb_opp_data;
set branch.bb_opp_data;
drop zip;
*Ineed a numeric one named zip, I somehow had it as $;
run;

data branch.bb_opp_data;
length zip 5;
set branch.bb_opp_data;
zip = zip_match;
format zip z5.;
run;

*assign coordinates for zip centroid and for branch;
proc sort data=branch.bb_opp_data;
by branch_id zip_match;
run;

proc sort data=branch.Mtb_branches_201206;
by branch;
run;


data branch.bb_opp_data;
merge  branch.bb_opp_data (in=a) branch.Mtb_branches_201206 (in=b keep=branch lat long   rename=(branch=branch_id )) end=eof;;
retain miss;
by branch_id;
if a then output;
if a and not b then miss+1;
if eof then put 'WARNING: a and not b =  ' miss;
drop miss;
run;


*branches no lat/long;
proc freq data=branch.bb_opp_data;
where lat eq .;
table branch_id;
run;

*I chekced many against Br. bible - all closed so I will drop them

*get rid of junk;
data branch.bb_opp_data;
set branch.bb_opp_data;
if branch_id eq . or lat eq . or long eq . or zip_match eq '' then delete;
run;

proc sql ;
select count(unique(branch_id)) from branch.bb_opp_data;
quit;

* Ihave 655 Branches, souds ak to me;
*but Heimback speaks about 704, the a file he sent says 680;
* i will work with what I have;


proc sort data=branch.bb_opp_data;
by zip;
run;

data  branch.bb_opp_data;
retain miss;
merge  branch.bb_opp_data(in=a) sashelp.zipcode (in=b keep=zip X Y rename=( Y=zip_lat X=zip_long)) end=eof;
by zip;
if a then output;
if a and not b then miss+1;
if eof then put 'WARNING: a and not b =  ' miss;
drop miss;
run;

*calc distance in miles;
data  branch.bb_opp_data;
set  branch.bb_opp_data;
distance = geodist(lat,long,zip_lat,zip_long, 'M');
run;

proc means data= branch.bb_opp_data;
var distance;
run;

proc sort data=branch.bb_opp_data;
by descending distance;
run;

*max distance is 12 miles, I checkedf and it seems to a very large zip code, so centroid could legitimate could be far, N-S it was 12 or more miles;
* checked another at 10 miles and it was one of those split zip codes, nothing I can do about that;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Analysis\Network Planning\transactions by branch.txt';
data trans;
infile myfile dsd dlm='09'x ;
input branch volume;
run;
*new excel file with trans for 2012 from souders;
libname  myxls EXCEL 'C:\Documents and Settings\ewnym5s\My Documents\Analysis\Network Planning\MarioSegal_BranchTransactions.xlsx';

proc summary data=myxls.'Sheet1$'n;
by branch;
output out=trans(drop=_: rename=(branch=branch_id)) sum(totaltrx)=volume;
run;


proc sort data=branch.bb_opp_data;
by branch_id;
run;

proc sort data=trans;
by branch_id;
run;

data branch.bb_opp_data;
set branch.bb_opp_data;
volume = .;
flag_volume = .;
run;

data branch.bb_opp_data ;
length rc 8;
if 0 then set trans;
if _N_ eq 1 then do;
	dcl hash h(dataset:'trans');
	h.definekey('branch_id');
  	h.definedata('volume');
	h.definedone();
end;

set branch.bb_opp_data end=eof;
retain miss;
rc=h.find();
if rc ne 0 then do;
	miss+1;
	call missing(branch_id);
	flag_volume = 1;
end;

if eof then put 'WARNING: a and not b =  ' miss;
drop miss;
drop rc;
run;

*I will use average for these, does nto feel right, but what else can I do;
*not needed anymore;

proc sql;
select mean(volume) into :avgvol from trans;
run;
 
data branch.bb_opp_data;
set branch.bb_opp_data;
if volume eq . then do;
	flag_volume = 1;
	volume = &avgvol;
end;
run;

*clean up;
data branch.bb_opp_data ;
set  branch.bb_opp_data ;
if branch_id eq . then delete;
drop sum_attr attraction weight;
run;


*attractiveness of a branch vis a vis a zip is volume/(distance ^2);

proc sort data=branch.bb_opp_data;
by zip_match;
run;

run;



proc sql;
create table branch.bb_opp_data as 
select a.*, b.sum_attr, divide(a.volume , a.distance**2) as attraction, ( calculated attraction/b.sum_attr) as weight 
       from branch.bb_opp_data as a, 
       (select c.zip_match, sum(c.volume/c.distance**2) as sum_attr from branch.bb_opp_data as c group by zip_match) as b
	   where a.zip_match = b.zip_match;
quit;
*this sql query does all at once, saving you from calculating the attracytion, the summing it, the sorting to merge it back, then merging it and doing the division for weight;


proc print data= branch.bb_opp_data;
where zip_match = '12601';
var zip_match volume distance attraction sum_attr;
sum attraction sum_attr weight;
format volume  attraction sum_attr comma24. weight percent8.4 distance  comma12.6;
run;

data test1;
set branch.bb_opp_data;
retain sum1;
by zip_match;
if first.zip_match then sum1=0;
sum1+weight;
if last.zip_match and (sum1 gt 1.001 or sum1 lt 0.999) then output;
run;
*this will output records if by zip it added to much different than 100%;

*Now I just need to sum by branch the scaled prospects;

data branch.bb_opp_data;
set branch.bb_opp_data;
prospects_scaled = round(prospects*weight,1);
targets_scaled = round(targets*weight,1);
run;
*I rounded the prospects;

data test2;
set branch.bb_opp_data;
retain sum1 ;
by zip_match;
if first.zip_match then sum1=0;
sum1+targets_scaled;
diff = sum1 - targets;
if last.zip_match and (diff ne 0) then output;
run;

* the rounding results in an acceptabe number of 45 errors, all are 1s, ;

*sum by branch;

proc sort data=branch.bb_opp_data;
by branch_id;
run;

proc tabulate data=branch.bb_opp_data out=branch.bb_oppty_by_branch (drop = _:);
class branch_id;
var prospects_scaled targets_scaled;
table branch_id,sum*(prospects_scaled='Total Prospects' targets_scaled='Target Prospects')*f=comma12.;
run;

*###################################################################################################################;
*############       Now do the sum of bb hhlds by zip code the same way     ########################################;
*###################################################################################################################;

/*data zips;*/
/*length hhid $ 9 zip $ 5;*/
/*infile 'C:\Documents and Settings\ewnym5s\My Documents\bb_zip.txt' dsd dlm='09'x lrecl=4096 firstobs=2;*/
/*input hhid $ zip $;*/
/*run;*/
/**/
/*data bb.bbmain_201212  (compress=binary);*/
/*merge bb.bbmain_201212 (in=left) zips (in=right) end=eof;*/
/*retain miss;*/
/*by hhid;*/
/*if left then output;*/
/*if left and not right then miss+1 ;*/
/*if eof then put 'WARNING: A not in B = ' miss;*/
/*drop miss;*/
/*run;*/

/*data bb.bbmain_201212  (compress=binary);*/
/*set bb.bbmain_201212;*/
/*hh = 1;*/
/*run;*/

*he wants all the product coutns and such, I need to collect that;
*rm in this dataset cointains top 40;

data tem_bb_data;
set bb.bbmain_201212;
keep hh dda: mms: sav: tda: cln: boloc: baloc: cls: wbb: deb: rm con zip;
run;

%as_logical(source=tem_bb_data,destination=tem_bb_data,variables=dda mms sav tda cln boloc baloc cls wbb deb rm con);

proc tabulate data=tem_bb_data out=internal (drop = _:);
class zip;
var hh dda: mms: sav: tda: cln: boloc: baloc: cls: wbb: deb: rm con ;
table zip, sum*(hh dda: mms: sav: tda: cln: boloc: baloc: cls: wbb: deb: rm con);
run;


%null_to_zero(source=internal,destination=internal)

%replacesuffix(WORK,internal,2,30,_sum,);;

*assign to BTAs;
data branch.bb_mtb_data (drop=zip);
merge branch.BTA_20130607 (in=a keep = zip_match branch_id where=(zip_match ne '' and zip_match ne '8065')) internal (in=b rename=(zip=zip_match )) end=eof;
retain miss miss1;
by zip_match;
if a then output;
if a and not b then miss+1;
if b and not a then miss1+1;
if eof then do;
	put 'WARNING: a and not b =  ' miss;
	put 'WARNING: b and not a =  ' miss1;
end;
drop miss:;
run;

*merge back with the opp_data;
proc sort data=branch.bb_opp_data;
by zip_match branch_id;
run;

proc sort data=branch.bb_mtb_data;
by zip_match branch_id;
run;

data  branch.bb_opp_data;
merge branch.bb_opp_data(in=a) branch.bb_mtb_data(in=b);
by zip_match branch_id;
if a;
run;




proc contents data=branch.bb_opp_data varnum ; run;


%macro scale(dataset=,start=,stop=);

data temp_table;
set &dataset;
run;

%LET ds=%SYSFUNC(OPEN(temp_table,i));
data &dataset;
set &dataset;
%do i = &start %to &stop;
	%let name=%SYSFUNC(VARNAME(&ds,&i));	
	&name._scaled = round(&name. * weight,1);
%end;
%let rc=%SYSFUNC(CLOSE(&ds));
run;
%mend scale;


filename mprint "C:\Documents and Settings\ewnym5s\My Documents\SAS\scale_test.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic mexecnote;

%scale(dataset=branch.bb_opp_data,start=29,stop=57)
;


*now just do the tabulate;
proc contents data=branch.bb_opp_data varnum short;
run;


proc tabulate data=branch.bb_opp_data out=branch.bb_oppty_by_branch_final (drop = _:);
class branch_id;
var prospects_scaled targets_scaled dda_scaled dda_amt_scaled DDA_con_scaled mms_scaled mms_amt_scaled MMS_con_scaled sav_scaled 
    sav_amt_scaled sav_con_scaled tda_scaled tda_amt_scaled TDA_con_scaled cln_scaled cln_amt_scaled CLN_con_scaled boloc_scaled 
    boloc_amt_scaled BOLoc_con_scaled baloc_scaled baloc_amt_scaled BALOC_con_scaled cls_scaled cls_amt_scaled CLS_con_scaled wbb_scaled 
    deb_scaled RM_scaled con_scaled hh_scaled ;
table branch_id,sum*(prospects_scaled targets_scaled dda_scaled dda_amt_scaled DDA_con_scaled mms_scaled mms_amt_scaled MMS_con_scaled sav_scaled 
    sav_amt_scaled sav_con_scaled tda_scaled tda_amt_scaled TDA_con_scaled cln_scaled cln_amt_scaled CLN_con_scaled boloc_scaled 
    boloc_amt_scaled BOLoc_con_scaled baloc_scaled baloc_amt_scaled BALOC_con_scaled cls_scaled cls_amt_scaled CLS_con_scaled wbb_scaled 
    deb_scaled RM_scaled con_scaled hh_scaled )*f=comma24.;
run;

proc sort data=branch.Bta_20130607;
by branch_id;
run;

data extra;
set branch.Bta_20130607;
by branch_id;
if first.branch_id then output;
run;


data branch.bb_oppty_by_branch_final;
merge extra (in=b drop=zip:) branch.bb_oppty_by_branch_final (in=a) ;
by branch_id;
if a then output;
run;

proc contents data=branch.bb_oppty_by_branch_final varnum short;
run;


proc print data=branch.bb_oppty_by_branch_final;
sum prospects_scaled_Sum targets_scaled_Sum dda_scaled_Sum dda_amt_scaled_Sum DDA_con_scaled_Sum mms_scaled_Sum mms_amt_scaled_Sum MMS_con_scaled_Sum 
    sav_scaled_Sum sav_amt_scaled_Sum sav_con_scaled_Sum tda_scaled_Sum tda_amt_scaled_Sum TDA_con_scaled_Sum cln_scaled_Sum cln_amt_scaled_Sum CLN_con_scaled_Sum 
     boloc_scaled_Sum boloc_amt_scaled_Sum BOLoc_con_scaled_Sum baloc_scaled_Sum baloc_amt_scaled_Sum BALOC_con_scaled_Sum cls_scaled_Sum cls_amt_scaled_Sum 
     CLS_con_scaled_Sum wbb_scaled_Sum deb_scaled_Sum RM_scaled_Sum con_scaled_Sum hh_scaled_Sum;
var Branch_ID Urban_Type Br_Zip Br_lat Br_long Radius;
run;
 
proc freq data=branch.bb_opp_data;
table zip_match / out=zips;
run;


proc sql noprint ;
/* select sum(a.hh) from bb.bbmain_201212 as a, zips as b where a.zip = b.zip_match;*/
/* select a.state, sum(a.hh) from bb.bbmain_201212 as a  LEFT OUTER JOIN zips as b on a.zip = b.zip_match  where b.zip_match is null group by a.state;*/
 create table DE as select a.state, a.zip, sum(a.hh) as hh1 from bb.bbmain_201212 as a  LEFT OUTER JOIN zips as b on a.zip = b.zip_match  where b.zip_match is null and a.state="DE" group by a.state, a.zip order by calculated hh1 descending;
 create table NY as select a.state, a.zip, sum(a.hh) as hh1 from bb.bbmain_201212 as a  LEFT OUTER JOIN zips as b on a.zip = b.zip_match  where b.zip_match is null and a.state="NY" group by a.state, a.zip order by calculated hh1  descending;
create table PA as select a.state, a.zip, sum(a.hh) as hh1 from bb.bbmain_201212 as a  LEFT OUTER JOIN zips as b on a.zip = b.zip_match  where b.zip_match is null and a.state="PA" group by a.state, a.zip order by calculated hh1 descending;
 create table MD as select a.state, a.zip, sum(a.hh) as hh1 from bb.bbmain_201212 as a  LEFT OUTER JOIN zips as b on a.zip = b.zip_match  where b.zip_match is null and a.state="MD" group by a.state, a.zip order by calculated hh1  descending;
quit;

data zips;
set zips;
bta = 1;
run;

data temp_map;
if 0 then set zips (rename=(zip_match=zip));
if _N_ eq 1 then do;
	dcl hash h(dataset:'zips (rename=(zip_match=zip))');
	h.definekey('zip');
  	h.definedata('bta');
	h.definedone();
end;

set bb.bbmain_201212 (keep= zip state hh hhid cb_dist dda mms sav cln cls baloc boloc cb_dist state) ;
rc=h.find();
if rc ne 0 then bta=0;
drop rc;
run;


proc freq data=temp_map;
table bta;
run;


%as_logical(source=temp_map,destination=temp_map,variables=dda mms sav cln cls baloc boloc);

proc tabulate data=temp_map;
class bta;
var dda mms sav cln cls baloc boloc cb_dist hh;
table bta="In BTA", sum=" "*hh='HHs'*f=comma12. pctsum<hh>='Penetration'*(dda mms sav cln cls baloc boloc)*f=pctfmt. /nocellmerge;
format bta binary_flag.;
run;

proc freq data=temp_map order=freq;
where bta eq 0;
table state;
run;

proc gmap map=sas.us_zips (where=(state in("NY","DE","MD","VA","DC","WV","PA"))) data=temp_map (rename=(zip=zip_char) );
id zip_char;
choro bta / discrete statistic=first ;
run;
quit;

ods html close;
proc tabulate data=temp_map out=bta_check;
class zip bta;
table zip*bta;
run;
ods html;


proc export data=bta_check(keep=bta zip N) outfile='C:\Documents and Settings\ewnym5s\My Documents\Analysis\Network Planning\bta_check.xls' 
             dbms=excel replace;
run;


PROC MAPIMPORT OUT=sas.us_zips DATAFILE="C:\Documents and Settings\ewnym5s\Desktop\tl_2010_us_zcta510.shp";
run;

data sas.us_zips;
length zip 5;
set sas.us_zips ;
zip=ZCTA5CE10;
state = zipstate(ZCTA5CE10);
format zip z5.;
run;

data de ;
length zip 5;
set de (rename=(zip=zip_char));
zip = zip_char;
format zip z5.;
run;

proc gmap map=sas.us_zips (where=(state="DE")) data=DE;
id zip;
choro hh1;
run;
quit;

data NY ;
length zip 5;
set NY (rename=(zip=zip_char));
zip = zip_char;
format zip z5.;
run;

proc gmap map=sas.us_zips (where=(state="NY")) data=NY;
id zip;
choro hh1 / ;
run;
quit;

*maps work, cool but I need to look if I missed tyhings we should not have;

