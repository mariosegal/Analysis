/*filename files ('C:\Documents and Settings\ewnym5s\My Documents\brtr0113.txt' 'C:\Documents and Settings\ewnym5s\My Documents\brtr0213.txt'*/
/*                  'C:\Documents and Settings\ewnym5s\My Documents\brtr0313.txt');*/
/**/
/*data data.br_tran_1q2013;*/
/*length hhid $ 9 ;*/
/*infile files dsd dlm='09'x lrecl=4096 firstobs=2 ;*/
/*input hhid $ branch trans db : mmddyy10. ;*/
/*run;*/

*choose one branch #2;
proc sort data=data.br_tran_1q2013;
by hhid;
run;

%let br = 2;
proc summary data=data.br_tran_1q2013 (where=(branch=&br and trans ge 1));
by hhid;
output out=transactors sum(trans)=trans;
run;

* I am not sure the query in datamart is working, so the data looks fishy - it may be ok in terms of who, but still need to check;

data transactors;
merge transactors (in=a) data.main_201303 (in=b keep=hhid zip);
by hhid;
if a;
run;
