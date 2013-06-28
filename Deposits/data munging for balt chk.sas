data cbr;
input branch cbr ;


data temp1;
length acct_key $ 28 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\2012br.txt' dsd dlm='09'x lrecl=4096 ;
input acct_key $ branch zip;
format zip z5.;
run;


data data.new2012 (compress=binary);
retain miss;
if 0 then set temp1;

if _n_ eq 1 then do;
	dcl hash h(dataset: 'temp1');
	h.definekey('acct_key');
	h.definedata('branch','zip');
	h.definedone();
end;

set data.new2012 end=eof;
rc = h.find();
if rc ne 0 then  do;
	call missing(branch, zip);
	if ptype eq 'DDA' and substr(stype,1,1) = 'R' then miss+1;
end;

if eof then put 'misses = ' miss;
drop rc miss;
run;


proc freq data=bad order=freq;
table branch;
run;
