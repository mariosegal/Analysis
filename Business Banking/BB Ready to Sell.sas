proc freq data=bb.bbmain_201212;
table private;
run;

proc freq data=bb.bbmain_201212;
where private="PRIVATE";
table sales1 / missing;
run;


data data.main_201212 (compress=yes);
retain miss;
merge data.main_201212 (in=a) bb.bbmain_201212 (in=b keep= hh hhid sales1 private where=(private="PRIVATE") rename=(hh=bus1)) end=eof;
by hhid;
if a then output;
if b and not a then miss+1;
if eof then put 'WARNING: BB not consumer = ' miss;
drop miss;
run;


proc freq data=data.main_201212 ;
table bus1*segment;
format segment segfmt.;
run;


data age;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\age.txt' dlm='09'x dsd lrecl=4096 obs=max firstobs=2;
input hhid $ age;

run;

data data.main_201212 (compress=yes);
merge data.main_201212 (in=a) age (in=b);
by hhid;
if a;
run;

proc freq data=data.main_201212 ;
where bus1 eq 1;
table age / missing;
format age ageband.;
run;

proc freq data=data.main_201212 ;
where private="PRIVATE";
table age*bus1 / nocol norow nopercent missing;
format age ageband.;
run;

proc tabulate data=data.main_201212 ;
where private="PRIVATE";
class sales1 age / preloadfmt;
table sales1 all ,(age all)*N='HHs' / nocellmerge;
format age ageband. sales1 $salesband.;
run;

proc tabulate data=data.main_201212 ;
where private="PRIVATE" and age = .;
class sales1  / preloadfmt;
table sales1 all ,N='HHs' / nocellmerge;
format  sales1 $salesband.;
run;
