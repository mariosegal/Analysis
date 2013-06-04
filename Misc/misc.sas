data test1;
set test;
where best eq current;
run;

proc sort data=test1;
by n current;
run;

data test2;
set test1;
by n;
if first.n then output;
run;

proc freq data=test2;
table p;
run;


*try the brute force approach;

proc sql;
create table large as select a.import_export_id as wsid, a.x1, a.y1, b.wsid1, b.x2,b.y2 from atm.atm_coords as a, atm_view as b;
quit;


data atm.large;
set large;
dist = geodist(y1,x1,y2,x2);
run;

proc sort data=atm.large(where=(dist ne .));
by wsid dist;
run;

data atm.large;
set atm.large;
if wsid=wsid1 then delete;
run;

data atm.best;
set atm.large;
by wsid;
if first.wsid then output;
run;
