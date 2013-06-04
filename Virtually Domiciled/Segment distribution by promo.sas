libname wip "C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files";
libname virtual 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled';
libname Data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname wip 'C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files';

options MSTORED SASMSTORE = mjstore;
libname mjstore 'C:\Documents and Settings\ewnym5s\My Documents\SAS\Macros';

libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
options fmtsearch=(SAS);

proc tabulate data=virtual.Promo_merged out=promo_dist missing;
class promo virtual_seg key;
var hh;
table promo, virtual_seg*N*f=comma12.0 / nocellmerge;
run;

proc sort data=virtual.promo_merged;
by promo;
run;

data temp1;
set virtual.promo_merged;
by promo;
if first.promo;
keep promo name segm_name;
run;

proc sort data=promo_dist;
by promo;
run;

data temp2;
merge promo_dist (in=a) temp1 (in=b where=(promo ne''));
by promo;
if a and b;
drop _type_ _page_ _table_;
run;

proc print data=temp2 noobs;
run;

