filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Business Banking\Top 40\top40.txt';

data top40.top40_hhs;
length hhid $9;
infile myfile dsd dlm='09'x firstobs=2;
input hhid $ branch lon lat ;
if branch eq . then delete;
run;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Business Banking\Top 40\branch coordinates.csv';

data top40.branch_coords;
infile myfile dsd dlm=',' firstobs=2;
input branch lat2 lon2 ;
run;

proc sort data=top40.branch_coords;
by branch;
run;

proc sort data= top40.top40_hhs;
by branch;
run;


data merged;
merge top40.top40_hhs (in=a) top40.branch_coords (in=b);
by branch;
if a and b;
run;

data merged;
set merged;
	ct = constant('pi')/180;
	distance = 3959 * ( 2 * arsin(min(1,sqrt( sin( ((lat2 - lat1)*ct)/2 )**2
	+ cos(lat1*ct) * cos(lat2*ct) * sin(((long2-long1)*ct)/2)**2))));
drop ct ;
run;

proc format;
value dist 0-<1 = 'Less 1 Mile'
           1-<2 = '1-2 Miles'
		   2-<3 = '2-3 Miles'
		   3-<4 = '3-4 Miles'
		   4-<5 = '4-5 Miles'
		   5-<6 = '5-6 Miles'
		   6-<7 = '6-7 Miles'
		   7-<8 = '7-8 Miles'
		   8-<9 = '8-9 Miles'
		   9-<10 = '9-10 Miles'
		   10-<99999 = '10+ Miles';
run;

proc tabulate data=merged missing;
class branch distance;
table branch, distance / nocellmerge;
format distance dist.;
run;

proc freq data=merged;
table branch*distance / missing nocol nocum nopercent;
format distance dist.;
run;


