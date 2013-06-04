*read data;

%macro read1;
		
	%do i=1 %to 6;
		%if &i eq 1 %then %let mth = jul;
		%if &i eq 2 %then %let mth = aug;
		%if &i eq 3 %then %let mth = sep;
		%if &i eq 4 %then %let mth = oct;
		%if &i eq 5 %then %let mth = nov;
		%if &i eq 6 %then %let mth = dec;

		
		data &mth._web;
		length hhid $ 9 acct $ 28 month $ 3 ;
		infile "C:\Documents and Settings\ewnym5s\My Documents\&mth.web.txt" dsd dlm='09'x missover lrecl=4096 firstobs=2;
		input hhid $ acct $ sign_on ;
		month = "&mth";
		run;
	%end;

%mend;

%read1


data all;
set jul_web aug_web sep_web oct_web nov_web dec_web;
run;

proc sort data=all;
by hhid month;
run;


proc summary data=all;
by hhid month;
output out=combo 
       sum(sign_on)=sign_on;
run;


proc transpose data=combo out=summary;
by hhid;
id month;
var sign_on;
run;

proc format;
value num 0 = 'Inactive'
		  1-high = 'Active'
          . = 'No Web';
run;

proc tabulate data=summary out=data missing;
class jul aug sep oct nov dec;
table (dec )*(nov )*(oct )*(sep )*(aug )*(jul ),N*f=comma12. / nocellmerge printmiss;
format jul aug sep oct nov dec num.;
run;

