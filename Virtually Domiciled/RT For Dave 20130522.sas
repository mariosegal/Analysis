proc import file='C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\RT file for Datamart analysis.sav'
             out=virtual.RT_from_dave dbms=sav;
run;

  
data virtual.RT_from_dave;
length hhid $ 9;
set virtual.RT_from_dave;
hhid = monthly_id;
run;


proc freq data=virtual.RT_from_dave;
table rt2;
run;

proc sort data=virtual.RT_from_dave;
by hhid;
run;

data merged_data;
retain miss;
merge data.main_201303 (in=a) virtual.RT_from_dave (in=b keep = hhid rt2 q10: q11: q12: ) end=eof;
by hhid;
if a and b then output;
if a and not b then miss+1;
if eof then put 'WARNING: non matches = ' miss;
drop miss;
run;

