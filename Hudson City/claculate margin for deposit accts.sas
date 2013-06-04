proc freq data=hudson.clean_20121106;
where ptype in ('DDA',"MMS","SAV","TDA","IRA");
table ptype*stype / list;
run;


*read excel file with margin calculated from M&T, using mapping ;

LibName test excel "C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Margin lookup table.xlsx" ;

data margin;
set test."Sheet1$"n;
run;

*merge usiong hash to avoid sorting;
options compress=y;
 data hudson.clean_20121106;
length ptype $ 3 stype $ 10 margin 8;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set margin end=eof1;
	dcl hash hh1 (dataset: 'margin', hashexp: 8, ordered:'a');
	hh1.definekey('ptype' ,'stype');
	hh1.definedata('margin');
	hh1.definedone();
end;

misses = 0;
do until (eof2);
	set hudson.clean_20121106 end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		margin = .;
	end;
	output;
end;

putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;

data hudson.clean_20121106;
set hudson.clean_20121106;
contrib = .;
if margin ne . and curr_bal ne . then contrib = margin*curr_bal/1000;
run;

proc summary data=hudson.clean_20121106;
by pseudo_hh;
output out=contrib
       sum(contrib) = contrib;
run;

proc freq data=contrib;
table contrib;
format contrib contband.;
run;

proc sort data=hudson.hudson_hh;
by pseudo_hh;
run;

data hudson.hudson_hh;
merge hudson.hudson_hh (in=a) contrib (in=b);
by pseudo_hh;
if a;
run;
