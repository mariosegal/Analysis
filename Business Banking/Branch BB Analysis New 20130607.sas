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







data branch.bb_opp_data;
merge branch.BTAs (in=a) branch.bb_prospects (in=b) end=eof;
retain miss miss1;
by zip;
if a then output;
if a and not b then miss+1;
if b and not a then miss1+1;
if eof then do;
	put 'WARNING: a and not b =  ' miss;
	put 'WARNING: b and not a =  ' miss1;
end;
drop miss:;
run;

*Note of missing they were in florida so who cars, except 19717 in DElaware, looks like a country club ;

*assign coordinates for zip centroid and for branch;
proc sort data=branch.bb_opp_data;
by branch zip;
run;

proc sort data=branch.Mtb_branches_201206;
by branch;
run;


data branch.bb_opp_data;
merge  branch.bb_opp_data (in=a) branch.Mtb_branches_201206 (in=b keep=branch lat long statecode zip rename=(zip=br_zip statecode=br_state)) end=eof;;
retain miss;
by branch;
if a then output;
if a and not b then miss+1;
if eof then put 'WARNING: a and not b =  ' miss;
run;


*get rid of junk;
data branch.bb_opp_data;
set branch.bb_opp_data;
if branch eq . or lat eq . or long eq . or zip_num eq . then delete;
format zip_num z5.;
run;

proc sql ;
select count(unique(branch)) from branch.bb_opp_data;
quit;

* Ihave 547 Branches;

*get lat/long for zip code;

proc sort data=branch.bb_opp_data;
by zip_num;
run;

data  branch.bb_opp_data;
retain miss;
merge  branch.bb_opp_data(in=a) sashelp.zipcode (in=b keep=zip X Y rename=(zip=zip_num Y=zip_lat X=zip_long)) end=eof;
by zip_num;
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
by branch;
run;

proc sort data=trans;
by branch;
run;

data branch.bb_opp_data ;
merge branch.bb_opp_data (in=a) trans (in=b) end=eof;
retain miss;
by branch;
if a then output;
if a and not b then miss+1;
if eof then put 'WARNING: a and not b =  ' miss;
drop miss;
run;

