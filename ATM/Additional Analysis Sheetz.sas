* do I have all coords;

proc sort data=atm.atm_coords;
by Import_Export_ID;
run;


data atms missing;
merge atm.atm_sum_all (in=a keep=wsid group count _freq_) atm.atm_coords(in=b rename=(Import_Export_ID=wsid) keep= Import_Export_ID latitude longitude);
by wsid;
if a and b then output atms;
if a and not b then output missing;
run;

proc print data=missing;
run;

*read stypes;
data stype;
length hhid $ 9 stype $ 3;
infile 'C:\Documents and Settings\ewnym5s\My Documents\mar_styp.txt' dsd dlm='09'x lrecl=4096 ;
input hhid $ stype $ ;
run;

proc sort data=stype;
by hhid stype;
run;


proc summary data=stype N;
by hhid stype;
output out=stype2 ;
run;


proc freq data=stype2 order=freq;
table stype / out=stypes;
run;

proc print data=stypes noobs;
var stype;
run;


proc format;
value $order 
'RE7'  = 'Retail Free'
'RX2'  = 'Direct Checking'
'RA8'  = 'Classic w/Int'
'RE6'  = 'MyChoice'
'RH2'  = 'Select w/int'
'RC6'  = '@College'
'RW2'  = 'Select'
'RH3'  = 'My Choice Plus w/Int'
'RH6'  = 'Power'
'RA2'  = 'Classic'
'RH5'  = 'MyChoice Premium'
'RJ2'  = 'First'
'RW3'  = 'MyChoice Plus'
'RK2'  = 'First w/Int'
'RZ2'  = 'Basic'
'RI2'  = 'PMA'
'RI1'  = 'Brokerage'
'RE5'  = 'Totally Free';
value $ptype_grps
'RE7','RX2','RE6','RC6','RJ2','RZ2','RE5' = 'Entry Level'
'RA8', 'RH2', 'RW2', 'RH3','RA2','RW3', 'RK2' = 'Medium'
 'RH6','RH5','RI2','RI1' = 'Premium';
 value $ptype_order
'RE7','RX2','RE6','RC6','RJ2','RZ2','RE5' = 1
'RA8', 'RH2', 'RW2', 'RH3','RA2','RW3', 'RK2' = 2
 'RH6','RH5','RI2','RI1' = 3;
 run;


data stype2;
set stype2;
Name = put(stype,$order.);
Ptype_grp = put(stype,$ptype_grps.);
order = put(stype,$ptype_order.);
run;

proc sort data=stype2;
by hhid descending order;
run;

data atm.stype_usage;
merge stype2 (in=a) atm.atm_usage (in=b keep=sheetz_usage_num hhid);
by hhid;
if a;
run;

proc format ;
value sheetz_num (notsorted)
	4 = 'No Sheetz ATM Usage'
1 = 'Limited Sheetz Usage'
	2 = 'Moderate Sheetz Dependency'
		3 = 'High Sheetz Dependency'
	5 = 'No M&T ATM Usage';
run;

proc freq data=atm.stype_usage;
table stype*sheetz_usage_num / nopercent nocol norow;
table stype*sheetz_usage_num / nofreq nopercent  norow;
table stype*sheetz_usage_num / nofreq nopercent  nocol;
format stype $stypefmt. sheetz_usage_num sheetz_num.;
run;


*Lets identify the closest non-sheetz ATM to each sheetz ATM;

data atm_view / view=atm_view;
set atm.atm_coords( where=(wsid ne '' and (x1 ne . or y1 ne .) and group ne 'Sheetz'));
rename wsid=wsid1 x1=x2 y1=y2;
keep wsid x1 y1 ;
run;


data atm.closest_non_sheetz;
retain m n;
length error_code $ 10 best_id $ 8;
*define the variables for hash objects, line only executes at compilation;
if 0 then set atm_view ;
*at beginning of execution, load atm_view into hash and also define the iterator;
if _N_ eq 1 then do;
	dcl hash h(dataset: "atm_view",ordered:'a');
	h.definekey('x2','y2');
	h.definedata(all: 'yes');
	h.definedone();
    
	dcl hiter hi('h');
end;
*load the atm_data to find the nearest atm and calculate the distance;
set atm.atm_coords (where=(wsid ne '' and (x1 ne . or y1 ne .)) );
n=_n_;


best = 999999; *initialize best distance to a ridiculous value;
best_id=''; *initialize if of best match;

rc=hi.first();

q = 1;
rc2=0;
do while (rc2=0);
	current = geodist(y1,x1,y2,x2,'DM');
	if current lt best and wsid ne wsid1 and (x1 ne x2 and y1 ne y2) then do; *do not set best to be distance to self or to a colocated ATM;
	    best = current; 
		best_id = wsid1;
	end;
	rc2=hi.next();
	q+1;
end;


keep x1 y1 best best_id wsid x2 y2 group terminal_:;
rename wsid=atm_id ;
run;

proc sgplot data=atm.closest_non_sheetz;
vbox best / group=group;
run;

data coords;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\hhcoords.txt' dsd dlm='09'x lrecl=4096;
input hhid $ lat long;
run;

data atm.atm_usage;
merge atm.atm_usage (in=a) coords(in=b);
by hhid;
if a;
run;

proc sort data=atm.atms_all;
by wsid;
run;

data atm.atms_all;
merge atm.atms_all (in=a) atm.Closest_non_sheetz (in=b keep=atm_id best rename=(best=closest atm_id=wsid));
by wsid;
if a;
run;


data atm.atms_all;
merge atm.atms_all (in=a) atm.atm_coords(in=b keep=wsid x1 y1);
by wsid;
if a;
run;

proc sort data=atm.atms_all;
by hhid;
run;

data atm.atms_all;
merge atm.atms_all (in=a) coords(in=b);
by hhid;
if a;
run;


data atm.atms_all;
set atm.atms_all;
dist_home = geodist(y1,x1,lat,long,'DM');
run;

proc sort data=atm.atms_all;
by hhid channel wsid;
run;

proc summary data=atm.atms_all ;
by hhid channel wsid;
output out=atm.atm_all_sum
       sum(count) = count
	   sum(amount)= amount;
id closest x1 y1 lat long dist_home;
run;

data atm.atm_all_sum;
merge atm.atm_all_sum (in=a) atm.atm_usage (in=b keep=hhid sheetz_usage_num);
by hhid;
if a;
run;

proc sort data=atm.atm_all_sum;
by wsid;
run;

data atm.atm_all_sum;
merge atm.atm_all_sum (in=a) atm.atm_coords(in=b keep=wsid group terminal_state terminal_zip);
by wsid;
if a;
run;

proc sql;
select  count(*) into :total1- :total4 from atm.atm_all_sum where channel="ATMO" and group eq 'Sheetz' group by sheetz_usage_num;
quit;

data atm.atm_all_sum;
set atm.atm_all_sum;
hh = 1;
select (sheetz_usage_num);
	when(1) f=1/&total1;
	when(2) f=1/&total2;
	when(3) f=1/&total3;
	when(4) f=1/&total4;
end;
run;



proc tabulate data=atm.atm_all_sum ;
class sheetz_usage_num;
var f hh;
table sheetz_usage_num,sum*(f hh);
run;

ods html style= mtbhtml;
proc sgpanel data=atm.atm_all_sum (where=(channel="ATMO" and group eq 'Sheetz' and sheetz_usage_num ne 4));
panelby sheetz_usage_num / novarname;
scatter x=closest y=dist_home ;
format sheetz_usage_num sheetz_num.;
colaxis min=0 max=200 label="Distance to Closest non-Sheetz ATM";
rowaxis min=0 max=200 label="Distance to Employee Home";
run;


ods graphics on /  height=5in width=9in;
proc sgpanel data=atm.atm_all_sum (where=(channel="ATMO" and group eq 'Sheetz' and sheetz_usage_num ne 4));
panelby sheetz_usage_num / novarname rows=3 noborder;
vbar closest / response=f stat=sum datalabel;
format sheetz_usage_num sheetz_num. closest distfmt. f percent6.1;
colaxis label="Distance to Closest non-Sheetz ATM" labelattrs=(weight=bold) fitpolicy=stagger;
rowaxis label="Percent of HH/ATM Combinations" labelattrs=(weight=bold);
run;

proc sort data=atm.atm_all_sum ;
by sheetz_usage_num;
run;

ods graphics on /  height=5in width=9in;
proc sgplot data=atm.atm_all_sum (where=(channel="ATMO" and group eq 'Sheetz' and sheetz_usage_num ne 4));
by sheetz_usage_num ;
vbar closest / response=f stat=sum datalabel;
format sheetz_usage_num sheetz_num. closest distfmt. f percent6.1;
xaxis label="Distance to Closest non-Sheetz ATM" labelattrs=(weight=bold);
yaxis label="Percent of HH/ATM Combinations" labelattrs=(weight=bold);
run;







proc sgplot data=chartdata;
scatter x=avg_dist y=max_dist / group=sheetz_usage_num;
format avg_dist max_dist distfmt. ;
run;


goptions reset=all device=java noborder;
proc gtile data=chartdata;
  tile count tileby=(avg_dist max_dist)
  / colorvar=count colortype=discrete;
format avg_dist max_dist distfmt. ;  
run;

quit;

proc tabulate data=chartdata out=chartdata1;
class avg_dist max_dist;
var count;
table avg_dist="Weighted Average of Distance to Closest Alternative",
      max_dist="Distance of ATM Used Fartest Away from Alternatives"*sum*count*f=comma12. /nocellmerge misstext='';;
format avg_dist max_dist distfmt. ;  
run;

proc tabulate data=chartdata out=wip.chartdata1;
class avg_dist max_dist sheetz_usage_num;
var count;
table  sheetz_usage_num, avg_dist="Weighted Average of Distance to Closest Alternative",
      max_dist="Distance of ATM Used Fartest Away from Alternatives"*f=comma12. /nocellmerge misstext='';;
table sheetz_usage_num, avg_dist="Weighted Average of Distance to Closest Alternative",
      max_dist="Distance of ATM Used Fartest Away from Alternatives"*pctN*f=pctfmt. /nocellmerge misstext='';;
format avg_dist max_dist distfmt. sheetz_usage_num sheetz_num.;  
run;
 
*generate data for R charts;
data _null_;
file 'C:\Documents and Settings\ewnym5s\My Documents\ATM\matrix_data.txt' dsd dlm=",";
set wip.chartdata1;
put avg_dist max_dist sheetz_usage_num N pctN_000;
run;
