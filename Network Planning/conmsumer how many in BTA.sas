


data bg;
length hhid $ 9 bg $ 13;
infile 'C:\Documents and Settings\ewnym5s\My Documents\bg201303.txt' dsd dlm='09'x lrecl=4096;
input hhid $ bg $;
run;


data bg;
length bgroup $ 12;
set bg;
bgroup = substr(bg,1,9) || substr(BG,11,3);
RUN;


data data.main_201303 (compress=binary);
retain miss;
merge data.main_201303(in=a) bg (in=b keep=bgroup hhid) end=eof;
by hhid;
if a and not b then miss+1;
if eof then put 'WARNING: not in B = ' miss;
drop miss;
if a;
run;


proc sort data= branch.Btas_bgroups_clean out=zips nodupkey;
by bgroup;
run;

data zips;
set zips;
keep bgroup bta;
bta = 1;
run;



data data.main_201303 (compress=binary);
if 0 then set zips ;
if _N_ eq 1 then do;
	dcl hash h(dataset:'zips');
	h.definekey('bgroup');
	h.definedata('bta');
	h.definedone();
end;

set data.main_201303(in=a);
rc = h.find();
if rc ne 0 then bta=0;
drop rc;
run;

proc freq data=data.main_201303;
table bta;
run;

