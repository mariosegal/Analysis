/*filename files ('C:\Documents and Settings\ewnym5s\My Documents\brtr0113.txt' 'C:\Documents and Settings\ewnym5s\My Documents\brtr0213.txt'*/
/*                  'C:\Documents and Settings\ewnym5s\My Documents\brtr0313.txt');*/
/**/
/*data data.br_tran_1q2013;*/
/*length hhid $ 9 ;*/
/*infile files dsd dlm='09'x lrecl=4096 firstobs=2 ;*/
/*input hhid $ branch trans db : mmddyy10. ;*/
/*run;*/

*choose one branch #2;
/*proc sort data=data.br_tran_1q2013;*/
/*by hhid;*/
/*run;*/

%let br = 3802;
proc summary data=data.br_tran_1q2013 (where=(branch=&br and trans ge 1));
by hhid;
output out=transactors sum(trans)=trans;
run;

proc sql noprint;
select lat,long,name into :br_lat, :br_long , :br_name from
branch.Mtb_branches_201206 where branch eq &br;
quit;

* I am not sure the query in datamart is working, so the data looks fishy - it may be ok in terms of who, but still need to check;

data transactors;
merge transactors (in=a) data.main_201303 (in=b keep=hhid zip);
by hhid;
if a;
run;

data transactors;
if 0 then set sashelp.zipcode(keep=zip_char x y rename=(x=long y=lat));
if _n_ eq 1 then do;
     dcl hash h(dataset: 'sashelp.zipcode(keep=zip_char x y rename=(x=long y=lat))');
    h.definekey('zip_char');
     h.definedata('zip_char','long','lat');
     h.definedone();
 end;
 set transactors;
     rc = h.find(key:zip);
     if rc ne 0 then do;
         br_lat = .;
         br_long = .;
         distance = 999999;
     end;
     else distance=geodist(lat,long,&br_lat,&br_long,'DM');
 drop rc;
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

	   /* The circles will be solid yellow */
       function='poly';
	   line=1;
	   style='empty';
     end;

	 /* Continue drawing the circle */
     else do;
       function='polycont';

	   /* Outline the circle with black */
	   if srvarea = 5 then  color='blue';
	   if srvarea = 10 then  color='green';
	   if srvarea = 15 then  color='red';
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
	function="symbol"; style="marker"; text="V"; color="yellow"; size=3;
	 output;

	 
run;

/*proc contents data=sas.us_zips varnum short;*/
/*run;*/

proc sort data=transactors;
by zip_char;
run;

data transactors;
length zip 5;
set transactors (drop=zip);
zip = zip_char;
format zip z5.;
run;

/*proc sort data=sas.us_zips;*/
/*by zip;*/
/*run;*/

data combo;
merge transactors (in=a where=(distance le 20) keep= distance zip) sas.us_zips (in=b);
by zip;
if a;
run;

 *can I do this only once, the extract for projection what I need? if so I need the entire transactor fiel above;

data combo1;
set combo circles;
run;


/*data combo;*/
/*if 0 then set sas.us_zips;*/
/*if _n_ eq 1 then do;*/
/*     dcl hash h(dataset: 'sas.us_zips');*/
/*    h.definekey('zip_char');*/
/*     h.definedata(all:'yes');*/
/*     h.definedone();*/
/* end;*/
/* set transactors (where=(distance le 20) keep= distance zip_char);*/
/*     rc = h.find(key:zip_char);*/
/*     if rc ne 0 then call missing (X, Y ,SEGMENT, ALAND10, AWATER10, CLASSFP10, FUNCSTAT10, GEOID10, INTPTLAT10, INTPTLON10, MTFCC10, state);*/
/* drop rc;*/
/* run;*/

proc gproject data=combo1 out=combo_p degrees ;
id zip;
run;

data circles_p map_p;
set combo_p;
*for some reason I need to do this, I remember from help at some point, moust be some option omn projection;
x=-x;
if flag eq 1 then output circles_p;
else output map_p;
run;

Title "Branch &br.: &br_name" ;

proc gmap data=transactors ( where =(distance le 20)) map=map_p anno=circles_p;
id zip_char;
choro zip_char / statistic=frequency;
run;
quit;

*add the table below and output to pdf;
*merge all data at ince to set up all processing at once;
