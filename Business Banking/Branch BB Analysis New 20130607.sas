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
libname bta   'C:\Documents and Settings\ewnym5s\My Documents\Analysis\Network Planning\BTA 20130607.xlsx';

data branch.BTA_20130607;
set bta.'bta$'n;
run;

libname radii 'C:\Documents and Settings\ewnym5s\My Documents\Analysis\Network Planning\Radii for BTA Analysis - 20130607.xlsx';

*merge with braches to define if some did not pick any zips;

/*data  branch.BTA_20130607;*/
/*merge branch.BTA_20130607 (in=a) radii.data (in=b);*/
/*by branch_id;*/
/*if a or b;*/
/*run;*/

*140 did, so instead, I will add to the bottom the  radii file, with some renaming that will add the branch zxip to the BTA, then I wil dedupe by branch/zip in case it was there;

data  branch.BTA_20130607;
merge branch.BTA_20130607 (in=a) radii.data (in=b);
by branch_id;
if a ;
run;

data  branch.BTA_20130607;
set branch.BTA_20130607  radii.data ;
run;

data  branch.BTA_20130607;
set branch.BTA_20130607;
if zip eq . then zip = br_zip;
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
merge branch.BTA_20130607 (in=a where=(zip ne . and zip ne 8065)) branch.bb_prospects (in=b rename=(zip=zip_match)) end=eof;
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

*mas distance is 12 miles, I checkedf and it seems to a very large zip code, so centroid could legitimate could be far, N-S it was 12 or more miles;
* checked another at 10 miles and it was one of those split zip codes, nothing I can do about that;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Analysis\Network Planning\transactions by branch.txt';
data trans;
infile myfile dsd dlm='09'x ;
input branch volume;
run;

proc sort data=branch.bb_opp_data;
by branch_id;
run;

proc sort data=trans;
by branch;
run;

data branch.bb_opp_data ;
merge branch.bb_opp_data (in=a) trans (in=b rename=(branch=branch_id)) end=eof;
retain miss;
by branch_id;
if a then output;
if a and not b then miss+1;
if eof then put 'WARNING: a and not b =  ' miss;
drop miss;
run;

*I will use average for these, does nto feel right, but what else can I do;

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


*attractiveness of a branch vis a vis a zip is volume/(distance ^2);

proc sort data=branch.bb_opp_data;
by zip_match;
run;



proc sql;
create table branch.bb_opp_data as 
select a.*, b.sum_attr, divide(a.volume , a.distance**2) as attraction, ( calculated attraction/b.sum_attr) as weight 
       from branch.bb_opp_data as a, 
       (select c.zip_match, sum(c.volume/c.distance**2) as sum_attr from branch.bb_opp_data as c group by zip_match) as b
	   where a.zip_match = b.zip_match;
quit;


proc print data= branch.bb_opp_data;
where zip_match = '12601';
var zip_match volume distance attraction sum_attr;
sum attraction sum_attr weight;
format volume  attraction sum_attr comma24. weight percent8.4 distance  comma12.6;
run;
*this sql query does all at once, saving you from calculating the attracytion, the summing it, the sorting to merge it back, then merging it and doing the division for weight;

data test1;
set branch.bb_opp_data;
retain sum1;
by zip_match;
if first.zip_match then sum1=0;
sum1+weight;
if last.zip_match and (sum1 gt 1.001 or sum1 lt 0.999) then output;
run;

*Now I just need to sum by branch the scaled prospects;

data branch.bb_opp_data;
set branch.bb_opp_data;
prospects_scaled = round(prospects*weight,1);
targets_scaled = round(targets*weight,1);
run;

data test2;
set branch.bb_opp_data;
retain sum1 ;
by zip_match;
if first.zip_match then sum1=0;
sum1+targets_scaled;
diff = sum1 - targets;
if last.zip_match and (diff ne 0) then output;
run;

* the rounding results in an acceptabe number 30 to45 errors, all 1s, and one 2;

*sum by branch;

proc sort data=branch.bb_opp_data;
by branch_id;
run;

proc tabulate data=branch.bb_opp_data out=branch.bb_oppty_by_branch (drop = _:);
class branch_id;
var prospects_scaled targets_scaled;
table branch_id,sum*(prospects_scaled='Total Prospects' targets_scaled='Target Prospects')*f=comma12.;
run;

*Now do the sum of bb hhlds by zip code the same way;

data zips;
length hhid $ 9 zip $ 5;
infile 'C:\Documents and Settings\ewnym5s\My Documents\bb_zip.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input hhid $ zip $;
run;

data bb.bbmain_201212  (compress=binary);
merge bb.bbmain_201212 (in=left) zips (in=right) end=eof;
retain miss;
by hhid;
if left then output;
if left and not right then miss+1 ;
if eof then put 'WARNING: A not in B = ' miss;
drop miss;
run;

/*data bb.bbmain_201212  (compress=binary);*/
/*set bb.bbmain_201212;*/
/*hh = 1;*/
/*run;*/


proc tabulate data=bb.bbmain_201212 out=branch.bb_hhs (drop = _:);
class zip;
var hh;
table zip, sum*hh;
run;

