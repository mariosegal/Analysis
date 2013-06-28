libname zips 'C:\Documents and Settings\ewnym5s\My Documents\Analysis\Peter\Strathmore Tix Zips.XLSX';

data zips;
set zips.'Single$'n;
drop City_Town_Neighbohood;
type = 'single';
rename zip_char =zip;
format zip_char z5.;
label zip_char= 'zip';
run;

data zips1;
set zips.'Subscriber$'n;
drop City_Town_Neighbohood;
type = 'subsc';
rename zip_char= zip;
format zip_char z5.;
label zip_char ='zip';
run;


data strathmore ;
length zip_char $ 5;
set zips zips1;
zip_char = put(zip,z5.);
strat = 1;
run;

proc sort data=strathmore  ;
by zip_char;
run;


proc summary data=strathmore;
where zip_char ne '    .';
by zip_char;
output out=strat1 sum(count) = count;
run;

proc sort data=strathmore (keep=zip_char strat where=(zip_char ne '    .')) out=strat2 nodupkey;
by zip_char;
run;

data data.main_201303 (compress=binary);
	if 0 then set strat2 (rename=(zip_char=zip));

	if _n_ eq 1 then do;
		dcl hash h(dataset: 'strat2 (rename=(zip_char=zip))');
		h.definekey('zip');
		h.definedata('strat');
		h.definedone();
	end;

	set data.main_201303;
	rc=h.find();
	if rc ne 0 then call missing(strat);
	drop rc;
run;

proc freq data=data.main_201303;
where strat eq 1;
table zip / out=strat_sum;
run;

data combo;
merge strat_sum(in=a keep=zip count rename=(count=mtb_count)) strat1(in=b keep=zip_char count rename=(zip_char=zip count=strathmore_count));
by zip;
run;

data combo;
set combo;
state = zipstate(zip);
label mtb_count='mtb_count' strathmore_count='strathmore_count';
run;

proc sort data=combo;
by descending strathmore_count;
run;

proc tabulate data=combo order=data;
class zip;
var mtb_count strathmore_count;
table zip all='Total', mtb_count='M&T Bank'*(sum='Clients'*f=comma12. colpctsum<mtb_count>='Pct Total'*f=pctfmt.) 
           strathmore_count='Strathmore'*(sum='Clients'*f=comma12. colpctsum<strathmore_count>='Pct Total'*f=pctfmt.) / nocellmerge;
run;


proc tabulate data=data.main_201303;
where strat = 1;
class clv_flag clv_steady brian;
var clv_total;
table (clv_flag all)*(clv_steady all) all, (N sum mean)*(clv_total)*f=comma12.;
/*table (clv_steady all) all,(brian all)*(mean='Average CLV')*(clv_total='')*f=comma12.;*/
run;

proc tabulate data=data.main_201303;
where brian ne 'Other';
class clv_flag clv_steady brian;
var clv_total ;
/*table (clv_flag all)*(clv_steady all) all, (N sum mean)*(clv_total)*f=comma12.;*/
table (clv_steady all) all,(brian all)*(mean='Average CLV')*(clv_total='')*f=comma12.;
table (clv_steady all) all,(brian all)*(mean='Average CLV')*(clv_total='')*f=comma12.;
run;




data data.main_201303 (compress=binary);
if 0 then set sashelp.zipcode (keep=zip county rename=(zip=zip_num));
if _n_ eq 1 then do;
	dcl hash z(dataset:'sashelp.zipcode (keep=zip county rename=(zip=zip_num)');
	z.definekey('zip_num');
	z.definedata('county');
	z.definedone();
end;

set data.main_201303 ;
fips = zipfips(zip);
zip_num = zip;
rc=z.find();
if rc ne 0 then call missing(county);
drop rc;
run;



data data.main_201303 (compress=binary);
length brian $ 25;
set data.main_201303 ;
select;
	when (fips eq 24 and county eq 31) brian='Montgomery County';
	when (fips eq 24 and county eq 27) brian='Howard County';
	when (fips eq 24 and county eq 33) brian='Prince Georges County';
	when (fips eq 24 and county eq 5) brian='Baltimore County';
	when (fips eq 24 and county eq 510) brian='Baltimore City County';
	when (fips eq 11 and county eq 1) brian='District of Columbia';
	otherwise brian='Other';
end;
run;


proc format ;
value $ quick  'Montgomery County' = 'Montgomery County'
				'Howard County' ='Howard County'
				'Prince Georges County' = 'Prince Georges County'
				'Baltimore County' = 'Baltimore County'
				'Baltimore City County' = 'Baltimore City County'
				'District of Columbia' = 'District of Columbia';
run;

filename mprint "C:\Documents and Settings\ewnym5s\My Documents\Analysis\Peter\strat_report.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic ;
%create_report(class1 = brian, fmt1 =$quick,out_dir = C:\Documents and Settings\ewnym5s\My Documents\Analysis\Peter, 
                main_source = data.main_201303,  contrib_source = data.contrib_201303, condition = brian ne 'Other' ,
                out_file=Strathmore_County_Profile,
                logo_file= C:\Documents and Settings\ewnym5s\My Documents\Administrative\Tools\logo.png)



			
%demographics (class1=brian,fmt1=$quick,where=brian ne '',main_source=data.main_201303,demog_source=data.demog_201303);
%penetration (class1=brian,fmt1=$quick,where=brian ne '',main_source=data.main_201303);
%contribution (class1=brian,fmt1=$quick,where=brian ne '',main_source=data.main_201303,contrib_source=data.contrib_201303);
%segments (class1=brian,fmt1=$quick,where=brian ne '',main_source=data.main_201303,out=segments);

/*demog_analysis (condition=brian ne 'Other',Class1=brian,out_file=Strathmore_County_Profile*/
/*                ,out_dir=C:\Documents and Settings\ewnym5s\My Documents\Analysis\Peter,identifier=201303,dir=data, title=, clean=)*/


proc tabulate data=temp_demog missing out=demog_crunched;
class brian ;
class dwelling education income ethnic_rollup home_owner marital poc: gender age_hoh religion languag length_resid ;
var hh;
table  (dwelling='Type of Residence' all),(N="HHs"*f=comma12. colpctN="Percent"*f=pctfmt.)* (brian All) / nocellmerge misstext='0';
table  (education='Education Level' all),(N="HHs"*f=comma12. colpctN="Percent"*f=pctfmt.)* (brian All) / nocellmerge misstext='0';
table  (income='Estimated Income' all),(N="HHs"*f=comma12. colpctN="Percent"*f=pctfmt.)* (brian All) / nocellmerge misstext='0';
table  (ethnic_rollup='Ethnicity' all),(N="HHs"*f=comma12. colpctN="Percent"*f=pctfmt.)* (brian All) / nocellmerge misstext='0';
table  (home_owner='Home Ownership' all),(N="HHs"*f=comma12. colpctN="Percent"*f=pctfmt.)* (brian All) / nocellmerge misstext='0';
table  (marital='Marital Status' all),(N="HHs"*f=comma12. colpctN="Percent"*f=pctfmt.)* (brian All) / nocellmerge misstext='0';
table  (poc="Children" all),(N="HHs"*f=comma12. colpctN="Percent"*f=pctfmt.)* (brian All) / nocellmerge misstext='0'; 
table  (gender='Gender' all),(N="HHs"*f=comma12. colpctN="Percent"*f=pctfmt.)* (brian All) / nocellmerge misstext='0';
table  (age_hoh="HOH Age" all),(N="HHs"*f=comma12. colpctN="Percent"*f=pctfmt.)* (brian All) / nocellmerge misstext='0';
table  (religion all),(N="HHs"*f=comma12. colpctN="Percent"*f=pctfmt.)* (brian All) / nocellmerge misstext='0';
table  (languag='Language' all),(N="HHs"*f=comma12. colpctN="Percent"*f=pctfmt.)* (brian All) / nocellmerge misstext='0';
table  (length_resid='Length of Residence' all),(N="HHs"*f=comma12. colpctN="Percent"*f=pctfmt.)* (brian All) / nocellmerge misstext='0';
format dwelling $dwelling. education $educfmt. income $incmfmt.  home_owner $homeowner.  marital $marital.  
       religion $religion. languag $language. length_resid $residence.   age_hoh ageband. ethnic_rollup $ethnic.;
format brian $quick.;
keylabel rowpctN=' ';
run;



