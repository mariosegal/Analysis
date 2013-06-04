data dec2009;
length hhid $ 9 tran_code $ 1;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\dec09.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input hhid $ tran_code $ svcs accts;
run;


data dec2010;
length hhid $ 9 tran_code $ 1;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\dec10.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input hhid $ tran_code $ svcs accts;
drop tran_code;
run;

data dec2011;
length hhid $ 9 tran_code $ 1;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\dec11.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input hhid $ tran_code $ svcs accts;
drop tran_code;
run;

data virtual.baseline_xsell bad;
merge dec2009 (in=a) dec2010(in=b rename=(svcs=svcs10 accts=accts10)) dec2011 (in=c rename=(svcs=svcs11 accts=accts11)) ;
by hhid;
if a then output virtual.baseline_xsell;
if (b or c) and not a then output bad;
run;

data virtual.baseline_xsell;
set virtual.baseline_xsell;
original = 1;
retain10 = 1;
if svcs10 eq . and accts10 eq . then retain10 = 0;
if retain10 = 1 then type10 = 'Stay';
if retain10 = 0 then type10 = 'Left';
retain11 = 1;
if svcs11 eq . and accts11 eq . then retain11 = 0;
if retain11 = 1 then type11 = 'Stay';
if retain11 = 0 then type11 = 'Left';
if type10 eq 'Left' and Type11 eq 'Stay' then exclude =1;
run;


proc freq data=virtual.baseline_xsell;
where  exclude ne 1;
table type10*type11 / missing;
run;

proc tabulate data=virtual.baseline_xsell;
where  exclude ne 1;
class tran_code type10;
var original  svcs10 svcs svcs11 accts10 accts accts11 retain11 retain10;
table type10*tran_code, sum*(original retain10 svcs svcs10 accts svcs11 accts10 accts11)*f=comma12. /nocellmerge;
format tran_code $transegm.;
run;

proc tabulate data=virtual.baseline_xsell;
where  exclude ne 1 and retain10 = 1;
class tran_code type11;
var original  svcs10 svcs svcs11 accts10 accts accts11 retain11;
table type11*tran_code, sum*(original retain11 svcs svcs10 svcs11 accts accts10 accts11)*f=comma12./nocellmerge;
format tran_code $transegm.;
run;


*################################################################################################;
*Cross Sell details;

data virtual.xsell;
length hhid $ 9 ptype $ 3 stype $ 3 sbu $ 3;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\xsell.txt' dsd dlm='09'x lrecl=4096 ;
input hhid $ ptype $ stype $ sbu $;
run;

proc sort data=virtual.xsell;
by hhid ptype;
run;

proc summary data=virtual.xsell;
by hhid ptype;
output out=xsell_summary (drop=_type_);
run;

proc formay library=sas;
value mybinary 0 = 0
               . = 0
			 1-high = 1;
run;

proc transpose data=xsell_summary out=transposed (drop=_name_);
by hhid;
id ptype;
var _freq_;
format _numeric_ mybinary.;
run;

data merged;
merge transposed (in=a) virtual.points_201204(in=b keep=hhid segment);
by hhid;
run;

proc contents data=merged varnum short;
run;

proc tabulate data=merged missing;
var DDA SAV  MMS TDA IRA MTG HEQ ILN CCS SLN  SEC  INS SDB ;
class segment;
table segment, N*f=comma12. sum*(DDA SAV  MMS TDA IRA MTG HEQ ILN CCS SLN  SEC  INS SDB)*f=comma12. / nocellmerge;
format segment $transegm.;
run;

