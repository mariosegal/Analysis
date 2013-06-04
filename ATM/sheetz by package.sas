data stype;
length hhid $ 9 stype $ 3;
infile 'C:\Documents and Settings\ewnym5s\My Documents\stype.txt' dsd dlm='09'x lrecl=4096 firstobs=1;
input hhid  $ stype $ ;
run;

proc sort data=stype;
by hhid stype;
run;

proc summary data=stype;
by hhid stype;
output out=stype;
run;

data stype;
set stype;
if _freq_ ge 1 then count = 1;
run;

proc transpose data=stype out=stype1;
by hhid;
var count;
id stype;
run;


data data.main_201212;
retain miss miss1;
merge data.main_201212 (in=a) stype1 (drop=_name_ in=b) end=eof;
by hhid;
if a;
if a and not b then miss+1;
if b and not a then miss1+1;
if eof then do;
	put 'WARNING: record in A not in B = ' miss;
	put 'WARNING: record in B not in A = ' miss1;
end;
run;


proc freq data=data.main_201212;
table (RE5 RC6 RE6)*atM_group / missing nocol norow ;
table atm_group*re5*re6  / missing nocol norow ;
table atm_group*re5*rc6  / missing nocol norow ;
table atm_group*re6*rc6 / missing nocol norow ;
format atm_group sheetz.;
run;


proc freq data=data.main_201212;
table (RE5 RC6 RE6)*atM_group / missing nopercent norow nofreq;
/*table atm_group*re5*re6  / missing nocol norow ;*/
/*table atm_group*re5*rc6  / missing nocol norow ;*/
/*table atm_group*re6*rc6 / missing nocol norow ;*/
format atm_group sheetz.;
run;
