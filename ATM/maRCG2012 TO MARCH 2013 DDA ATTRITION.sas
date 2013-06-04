data march12;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\201203.txt' dsd dlm='09'x ;
input hhid $;
march2012dda = 1;
run;


options compress=yes;
data data.main_201303;
length march2012dda 8;
if _N_ eq 1 then do;
	dcl hash h(dataset:'march12');
	h.definekey('hhid');
	h.definedata('march2012dda');
	h.definedone();
end;

retain miss;
set data.main_201303 end=eof;

rc=h.find();

if rc ne 0 then do;
	march2012dda=0;
	miss+1;
end;

if eof then put miss ' records on march 2012 not found in march 2013';
drop miss;
run;

proc freq data=data.main_201303;
table march2012dda*dda / missing;
run;

