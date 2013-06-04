libname wip "C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files";
libname virtual 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled';
libname Data 'C:\Documents and Settings\ewnym5s\My Documents\Data';

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\Panel.csv';

data virtual.panel;
length hhid $ 9;
infile myfile dlm=',' lrecl=4096 firstobs=2 missover;
input panelid email $ hhid $ monthid pid;
drop email monthid pid;
run;

proc sql;
create table count as 
select count(hhid) from virtual.panel
where hhid >= '1' ;
quit;

proc sql;
create table count1 as 
select count(panelid) from virtual.panel
where hhid is null ;
quit;

proc sort data = virtual.panel;
by hhid;
run;

data virtual.panel_clean;
set virtual.panel;
where hhid ne '';
run;

data virtual.panel_clean;
merge virtual.panel_clean (in=a) data.main_201111 (in=b keep=hhid virtual_seg);
by hhid;
if a and b;
run;

data bads;
merge virtual.panel_clean (in=a) data.main_201111 (in=b keep=hhid virtual_seg);
by hhid;
if a and not b;
run;

proc freq data=virtual.panel_clean;
table virtual_seg / nocol norow  missing;
run;


filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\Panel with segments.csv';

data _null_;
set virtual.panel_clean;
file myfile dlm=',' ;

if _n_ eq 1 then do;
	put 'panelid,hhid,transaction_Segment';
end;

put panelid $ hhid $ virtual_seg $;
run;

proc freq data=virtual.points_2011;
table segment / nocol norow  missing;
run;
