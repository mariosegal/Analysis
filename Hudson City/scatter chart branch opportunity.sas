data hudson.Bta_by_branch_20130120;
set  hudson.Bta_by_branch_20130120;
rename zip = zip_num zip_2 = branch_zip;
run;

data hudson.Bta_by_branch_20130120;
length zip 8;
set  hudson.Bta_by_branch_20130120;
zip = branch_zip;
format zip z5.;
run;

proc sort data= hudson.Bta_by_branch_20130120;
by zip;
run;


data hudson.Bta_by_branch_20130120;
merge  hudson.Bta_by_branch_20130120 (in=a) sashelp.zipcode (in=b keep=zip countynm statecode);
by zip;
if a;
run;

proc tabulate  data= hudson.Bta_by_branch_20130120;
class statecode countynm;
table statecode*countynm,N*f=comma12.;
run;

data hudson.Bta_by_branch_20130120;
set  hudson.Bta_by_branch_20130120;
if countynm in ('Bronx','Kings','Queens',"New York") the delete;
run;




LIBNAME ixi ODBC DSN=IXI user=reporting_user pw=Reporting2 schema=dbo;

data temp;
merge hudson.Bta_by_branch_20130120 (in=a) 
      ixi.mtb_postal(in=b keep=regionzipcode cycleid totalassets totalhouseholds rename=(regionzipcode=Branch_zip) where=(cycleid=201206))
      ixi.mtbexp_postal(in=c keep=regionzipcode cycleid totalassets totalhouseholds rename=(regionzipcode=Branch_zip)  where=(cycleid=201206));
by branch_zip;
if a;
run;
 
proc tabulate data=temp out=scatter missing;
class SNL_Branch_Key branch_state;
var totalassets totalhouseholds;
table branch_state * SNL_Branch_Key, N sum*(totalassets totalhouseholds);
run;

