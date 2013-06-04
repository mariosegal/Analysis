data data.deposits_201212;
length hhid $ 9 key $ 28 ptype stype  $ 3 status $ 3 sbu_group $ 7;
infile 'C:\Documents and Settings\ewnym5s\My Documents\dec12.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input hhid $  key $  branch cost_center stype $ ptype $ sbu $ sbu_group $ balance date_closed :mmddyy10. status $;
run;

proc import  out=data.sbu_groups
file='C:\Documents and Settings\ewnym5s\My Documents\compliance\sbu codes.xlsx' dbms=excel replace;
run;

proc freq data=data.sbu_groups;
 table sbu_name segment;
 run;


data data.deposits_201212 (compress=yes);
if 0 then set data.sbu_groups (rename=(sbu_code=sbu_group) drop=sbu_name);


if _n_ eq 1 then do;
	dcl hash h1(dataset:'data.sbu_groups (rename=(sbu_code=sbu_group))');
	h1.definekey('sbu_group');
	h1.definedata('segment');
	h1.definedone();
end;

set  data.deposits_201212 end=eof2;

	rc= h1.find(key:sbu_group);
	if rc ne 0 then call missing(segment);

drop rc;

run;

proc freq data=data.deposits_201212 order = freq;
where sbu_group eq '';
table stype*ptype / nocol norow nopercent missing;
table cost_center*ptype/ nocol norow nopercent missing;
run;

proc freq data=data.deposits_201212 order = freq;
where sbu_group eq '';
table stype*ptype / nocol norow nopercent missing;
table cost_center*ptype/ nocol norow nopercent missing;
run;

data data.deposits_201212 (compress=yes);
set data.deposits_201212;
bal_flag = 0;
if balance > 250000 then bal_flag = 1;
run;

proc format ;
value tier (notsorted) 0 = 'Up to $250,000'
     1 = 'Over $250,000';
run;

title ;
proc tabulate data=data.deposits_201212 missing;
class segment bal_flag;
var balance;
table segment All='Total', (bal_flag="Balance Tier" All='Total')*(N='Accounts'*f=comma12. sum=' '*balance='Balances'*f=dollar24.2) / nocellmerge misstext='0';
format bal_flag tier.;
run;

title ;
proc tabulate data=data.deposits_201212 missing;
class ptype bal_flag;
var balance;
table ptype='Product' All='Total', (bal_flag="Balance Tier" All='Total')*(N='Accounts'*f=comma12. sum=' '*balance='Balances'*f=dollar24.2) / nocellmerge misstext='0';
format bal_flag tier. ptype $ptypefmt.;
run;


proc freq data=data.deposits_201212 ;
where substr(stype,1,1)='O';
table segment / missing;
run;


proc format ;
value $ now 
     'RA8', 'RH2', 'RH3', 'RH5', 'RK2', 'RH6', 'CN2', 'CO2', 'CP2' , 'CS2', 'CU3', 'CU4' = "NOW"
	 other = "DDA";
run;





title ;
proc tabulate data=data.deposits_201212 missing;
where status ne 'X';
class ptype bal_flag stype;
var balance;
table (ptype='Product'*stype='Subtype')  All='Total', (bal_flag="Balance Tier" All='Total')*(N='Accounts'*f=comma12. sum=' '*balance='Balances'*f=dollar24.2) / nocellmerge misstext='0';
format bal_flag tier. ptype $ptypefmt. stype $now.;
run;

proc format ;
value quick low-<0 = 'Negative'
            0-high = "Positive";
			run;




