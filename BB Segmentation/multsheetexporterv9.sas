****************************************************************;
* Multisheetexporterv9                                         *;
* Purpose:  to export all the datasets from one sas library    *;
*           as sheets to a single excel file                   *;
****************************************************************;
* Parameters  - mylibref - macro for LIBNAME libref            *;
*                          this must be in UPPER CASE          *;
*               mylibrary - directory location of SAS files    *;
*                           such as c:\mysasfiles              *;
*               myexcel  - name of the excel file              *;
*                          such as c:\myexcelfiles\excel1.xls  *;
****************************************************************;

options mprint macrogen symbolgen mlogic;
%macro exportexcel9(mylibrary=, mylibref=, myexcel=);

libname &mylibref &mylibrary;

proc sql;
create table tablemems as
select * from dictionary.tables 
where libname="&mylibref";
run; quit;

data _null_; set tablemems end=last;
call symput('sheetm'||left(_n_),trim(memname));
if last then call symput('counter',_n_);
run;

%put _all_;
run;
%do i= 1 %to &counter;
proc export data=&mylibref..&&sheetm&i outfile=&myexcel dbms=excel replace;
sheet="&&sheetm&i";
run; quit;
%end;

%mend exportexcel9;
run;

%exportexcel9(mylibrary="C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\",             /* library where the sas datasets live */
              mylibref=WORK,                      /* libref for the library use UPPERCASE */
              myexcel="C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\myexcel.xls");  /* location of the excel file  */




