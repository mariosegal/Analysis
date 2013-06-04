data a2011;
length hhid $ 9 child $ 1 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\2011.txt' dsd dlm='09'x missover firstobs=1;
input hhid $ ixi_tot segment child age;
run;

data a2012;
length hhid $ 9 child $ 1 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\2012.txt' dsd dlm='09'x missover firstobs=1;
input hhid $ ixi_tot segment child age;
run;

data dob2012;
length hhid $ 9 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\dob12.txt' dsd dlm='09'x missover firstobs=1;
input hhid $ dob : mmddyy10. ;
run;

data dob2011;
length hhid $ 9 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\dob11.txt' dsd dlm='09'x missover firstobs=1;
input hhid $ dob : mmddyy10. ;
run;


*merge ;
data c2011 bad2011;
merge a2011 (in=a)  dob2011(in=b);
by hhid;
if a then output c2011;
if a and not b then output bad2011;
run;

data c2011;
set c2011;
by hhid;
if first.hhid then output;
run;



proc sql;
select count(*)  as bad from bad2011 ;
select count(*)  as really_bad from bad2011 where dob eq . and age eq .;
quit;


data c2012 bad2012;
merge a2012 (in=a)  dob2012(in=b);
by hhid;
if a then output c2012;
if a and not b then output bad2012;
run;

data c2012;
set c2012;
by hhid;
if first.hhid then output;
run;

proc sql;
select count(*)  as bad from bad2012 ;
select count(*)  as really_bad from bad2012 where dob eq . and age eq .;
quit;


%squeeze(c2011,data.trend_extra_2011)
%squeeze(c2012,data.trend_extra_2012)

data t2011 check;
merge first2011 (in=a)  c2011(in=b);
by hhid;
if a then output t2011;
if a and not b then output check;
run;

data t2012 check1;
merge first2012 (in=a)  c2012(in=b);
by hhid;
if a then output t2012;
if a and not b then output check1;
run;


data ind;
length hhid $ 9 child $ 1 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ind.txt' dsd dlm='09'x missover firstobs=2;
input hhid $ ixi_tot segment child age dob :mmddyy10.;
run;

data ind;
set ind;
rename segment = segment_x dob = dob_x age=age_x child=child_x ixi_tot = ixi_tot_x;
run;

data ind;
set ind;
by hhid;
if first.hhid then output;
run;
 
data data.trend_extra_2011;
set data.trend_extra_2011;
drop segment_x age_x child_x ixi_tot_x dob_x;
run;


data data.trend_extra_2011 y;
merge data.trend_extra_2011 (in=a) ind (in=b);
by hhid;
if a then output data.trend_extra_2011;
if a and b then output y;
run;
