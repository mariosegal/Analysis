data balt;
set sashelp.zipcode;
where city = 'Baltimore' and Statecode='MD';
run;

proc sort data=balt;
by y x;
run;

*The coordinates for baltimore from google are 39.2833 and -76.6167 - the zip that is closest to that ;
*appears to be 21275 and it is right by the harbours so it makes sense ;

/*########### ONE TIME ONLY, APPEND CBR TO branch table ############*/
libname cbr 'C:\Documents and Settings\ewnym5s\My Documents\Administrative\References\branch_cbr.xlsx' ;

data branch.Mtb_branches_201206 ;
merge branch.Mtb_branches_201206 (in=a) cbr.branch (keep = branch_recoded community rename=(branch_recoded=branch)) ;
by branch;
label branch='branch' cbr='cbr';;
run;

/*##############  ANALYSIS #####################;*/

*1) get all chk accounts opened in baltimore branches in 2012, calculate their distance to center (21275);
*2) then summarize by zip code and create a color coded map with circles for some radii of interest;

data balt_accts bad;
retain miss;
if 0 then set branch.Mtb_branches_201206 (keep=branch cbr);

if _n_ eq 1 then do;
	dcl hash h(dataset: 'branch.Mtb_branches_201206 (keep=branch cbr)');
	h.definekey('branch');
	h.definedata('cbr');
	h.definedone();
end;

set data.new2012 (where=(ptype eq 'DDA' and substr(stype,1,1) = 'R')) end=eof;
rc = h.find();
if (rc ne 0 and branch eq 1266) then cbr = 12;
if (rc eq 0 or (rc ne 0 and branch eq 1266)) and cbr eq 12 then output balt_accts;
*also output the baltimore online service center, only output baltimore ones;
if rc ne 0 then  do;
	call missing(cbr);
	miss+1;
	output bad;
end;

if eof then put 'misses = ' miss;
drop rc miss;
run;

proc tabulate data=balt_accts out=summary1;
class zip stype;
table zip,stype;
run;


*new to extract zips, and the rerun code to use it;
