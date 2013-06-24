/*filename files ('C:\Documents and Settings\ewnym5s\My Documents\brtr0113.txt' 'C:\Documents and Settings\ewnym5s\My Documents\brtr0213.txt'*/
/*                  'C:\Documents and Settings\ewnym5s\My Documents\brtr0313.txt');*/
/**/
/*data data.br_tran_1q2013;*/
/*length hhid $ 9 ;*/
/*infile files dsd dlm='09'x lrecl=4096 firstobs=2 ;*/
/*input hhid $ branch trans db : mmddyy10. ;*/
/*run;*/

*choose one branch #2;
proc sort data=data.br_tran_1q2013;
by hhid branch;
run;


proc summary data=data.br_tran_1q2013 ;
*(where=(branch=&br and trans ge 1));
by hhid branch;
output out=data.transactors_1q2013 sum(trans)=trans;
run;

*get zip for HHld;
data data.transactors_1q2013;
merge data.transactors_1q2013 (in=a) data.main_201303 (in=b keep=hhid zip);
by hhid;
if a;
run;

*get lat/long for branch;

data data.transactors_1q2013;
if 0 then set branch.Mtb_branches_201206(keep=branch lat long name name rename=(long=br_long lat=br_lat name=br_name));
if _n_ eq 1 then do;
     dcl hash h(dataset: 'branch.Mtb_branches_201206(keep=branch lat long name rename=(long=br_long lat=br_lat name=br_name))');
     h.definekey('branch');
     h.definedata('br_long','br_lat','br_name');
     h.definedone();
 end;
 set data.transactors_1q2013;
     rc = h.find(key:branch);
     if rc ne 0 then do;
         br_lat = .;
         br_long = .;
		 br_name = '';
     end;
 drop rc ;
 run;


 data data.transactors_1q2013;
if 0 then set sashelp.zipcode(keep=zip_char x y rename=(x=long y=lat));
if _n_ eq 1 then do;
     dcl hash h(dataset: 'sashelp.zipcode(keep=zip_char x y rename=(x=long y=lat))');
    h.definekey('zip_char');
     h.definedata('zip_char','long','lat');
     h.definedone();
 end;
 set data.transactors_1q2013;
     rc = h.find(key:zip);
     if rc ne 0 then do;
         lat = .;
         long = .;
     end;
 drop rc;
 run;

data data.transactors_1q2013;
set data.transactors_1q2013;
distance=geodist(lat,long,br_lat,br_long,'DM');
run;


%macro create_map(br_num);
	proc sql noprint;
	select lat,long,name into :br_lat, :br_long , :br_name from
	branch.Mtb_branches_201206 where branch eq &br_num;
	quit;

	*select only current branch;
	proc tabulate data=data.transactors_1q2013(where=(branch=&br_num and distance ne . and distance le 20)) out=transactors;
	class zip_char;
	table zip_char, N*f=comma12. / nocellmerge; 
	run;

	data transactors;
	length zip 5;
	set transactors ;
	zip = zip_char;
	format zip z5.;
	run;

	/*proc sort data=sas.us_zips;*/
	/*by zip;*/
	/*run;*/

	/*data sas.footprint_zips;*/
	/*set sas.us_zips;*/
	/*where state in ('NY','NJ','CT','PA','DE','MD','DC','VA','WV');*/
	/*run;*/

	data combo;
	merge transactors (in=a ) sas.footprint_zips (in=b);
	by zip;
	if a;
	run;


	data circles;
	 retain xsys ysys '2' flag 1 when 'a' hsys "3";
	  length text $25 color function $ 8 style $ 25; 
	/*  drop xold yold;*/

	do srvarea= 5 to 15 by 5;
	  
	  d2r=3.1415926/180;

	  /* Radius of the earth in miles */
	  r=3958.739565;
	  
	  /* Point for the circle to be drawn around */
	  xcen=&br_long;
	  ycen=&br_lat;
	  
	  /* Calculate the points to draw a circle */
	  do degree=0 to 360 by 5;  

	     /* Begin a new circle */
	     if degree=0 then do;
	       function='poly';
		   line=20;
		   style='empty';
		   text="";
		   position="";
		   size=1;
		   zip=.;
	     end;

		 /* Continue drawing the circle */
	     else do;
	       function='polycont'; text=""; position="";
	       size='2';
		   zip=.;
		   /* Outline the circle with black */
		   if srvarea = 5 then  color='blue';
		   if srvarea = 10 then  color='blue';
		   if srvarea = 15 then  color='blue';
	     end;

		 /* Calculate a point along the circle */
	     y=arsin(cos(degree*d2r)*sin(srvarea/R)*cos(ycen*d2r)+
	       cos(srvarea/R)*sin(ycen*d2r))/d2r;
	     x=xcen+arsin(sin(degree*d2r)*sin(srvarea/R)/cos(y*d2r))/d2r;
	     output;
		
	  end;

	end;
	   *create the marker for the branch;
		 x=xcen;
		 y=ycen;
		function="symbol"; style="marker"; text="V"; color="yellow"; size=3;position="5"; zip=.;
		 output;

	*create circle labels;
	do srvarea= 5 to 15 by 5; 
	   degree=0;
	   function="label"; position="8"; style=''; zip=.; text=catx(' ',srvarea,"miles"); size=2; cbox='white';
	   y=arsin(cos(degree*d2r)*sin(srvarea/R)*cos(ycen*d2r)+
	       cos(srvarea/R)*sin(ycen*d2r))/d2r;
	   x=xcen+arsin(sin(degree*d2r)*sin(srvarea/R)/cos(y*d2r))/d2r;
	   if srvarea = 5 then  color='blue' ;
		   if srvarea = 10 then  color='blue';
		   if srvarea = 15 then  color='blue';
		output;
	end;
	run;

	*create zip labels;
	data anno;
	set data.transactors_1q2013(where=(branch=&br_num and distance ne . and distance le 20) keep=distance branch zip lat long);
	run;


	proc sort data=anno nodupkey;
	by zip;
	run;


	data anno;
	length text $ 8;
	retain xsys ysys '2' hsys '3' when 'a' flag 1;
	set anno;
	x=long; y = lat;
	function="label"; position="5"; text=zip; size=1.5; color='red';
	run;

	*add markers for other MTB branches;
	data other_br;
	retain xsys ysys '2' flag 1 when 'a' hsys "3";
	length text $25 color function $ 8 style $ 25; 
	set branch.Mtb_branches_201206 (keep=branch lat long);
	distance=geodist(lat,long,&br_lat,&br_long,'DM');
	if distance gt 15 then delete;
	if branch eq &br_num then delete;
	function="symbol"; style="marker"; text="V"; color="purple"; position="5"; ; x=long;y=lat; size=2;  output;
	function="label"; style=''; text=strip(Branch);  size=2; position="8";  output ;
	drop  distance;
	run;



	*merge data for zips and circles and project so it is on the same scale;
	data combo1;
	set combo circles(drop=zip) anno(drop=zip branch) other_br  ;
	run;

	proc gproject data=combo1 out=combo_p degrees asis;
	id zip branch;
	run;
	*this sometimes takes a few, sometimes none of the bracnh labels;

	*split data into map and annotate;
	data circles_p map_p;
	set combo_p;
	*for some reason I need to do this, I remember from help at some point, moust be some option omn projection;
	x=-x;
	if flag eq 1 then output circles_p;
	else output map_p;
	run;

	ods pdf file="C:\Documents and Settings\ewnym5s\My Documents\Analysis\Network Planning\br_&br_num..pdf" style=journal nogfootnote  dpi=300;
	options orientation=landscape;

	Title "Branch &br_num.: &br_name" ;
	legend1 cborder="black" label=("Number of HHs");
	*greenish;
	/*pattern6 color=cx006837;*/
	/*pattern5 color=cx31A354;*/
	/*pattern4 color=cx78C679;*/
	/*pattern3 color=cxADDD8E;*/
	/*pattern2 color=cxD9F0A3;*/
	/*pattern1 color=cxFFFFCC;*/

	/*pattern6 color=cx045A8D;*/
	/*pattern5 color=cx2B8CBE;*/
	/*pattern4 color=cx74A9CF;*/
	/*pattern3 color=cxA6BDDB;*/
	/*pattern2 color=cxD0D1E63;*/
	/*pattern1 color=cxF1EEF6;*/

	pattern6 color=cx31A354;
	pattern5 color=cx74C476;
	pattern4 color=cxA1D99B;
	pattern3 color=cx74C476;
	pattern2 color=cx31A354;
	pattern1 color=cxFFFFCC;
	proc gmap data=transactors map=map_p anno=circles_p;
	id zip_char;
	choro N / statistic=sum legend=legend1 levels=6;
	run;
	quit;

	ods pdf close;
%mend create_map;


data branches;
input branch;
datalines;
430
1146
1312
;
run;

options mprint;
data _null_;
   set branches;
/*   call symput('br_num',trim(left(branch)));*/
   call execute(catx('','%create_map(',branch,')'));
run;


*how come branch number updated but not the branch name ?

ods graphics on / height=4in width=7.5in;
Title 'Breakdown for all Transactors';
proc tabulate data=data.transactors_1q2013(where=(branch=&br and distance ne . )) ;
class distance ;
table distance='Distance top Branch', N='HHs'*f=comma12. pctn='Percent'*f=pctfmt. / nocellmerge misstext='-'; 
format distance distfmt.;
run;








data branches;
input branch;
datalines;
2
17
;
run;

data mydata;
input hhid branch;
datalines;
111 2
112 2
113 2
114 17
115 17
;
run;


%macro test(branch2);
%let branch = %sysfunc(dequote(&branch1));
	data temp;
	set mydata ;
	where branch=&branch2;
	run;
	proc print data=temp;
	var hhid branch;
	run;

%mend;

options cmplib = work.functions;
proc fcmp outlib=work.functions.maps;
function create_map(branch1);
rc = run_macro('test', branch1);
return (rc);
endsub;
run;

options mprint;
data _null_;
set branches;
	rc = create_map(branch);
run;

%test(2)

data _null_;
   set branches;
   call execute('%test(branch)');
run;

