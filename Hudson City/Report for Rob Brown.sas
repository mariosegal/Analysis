proc sort data=hudson.accts_201302;
by acct_nbr;
run;


proc sort data=hudson.feb_combined;
by acct_nbr;
run;

data test;
/*length hudson_branch 8;*/
merge hudson.feb_combined (in=a) hudson.accts_201302(in=b keep=acct_nbr branch );
by acct_nbr;
if a then output;
hudson_branch = input(branch,comma12.);
run;

data hudson.feb_combined;
set test;
hudson_branch= branch;
run;

proc freq data= hudson.feb_combined;
table hudson_branch / missing;
run;

proc sql;
select count(unique(hudson_branch)) from  hudson.feb_combined;
quit;


proc import 
   datafile='C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Branches 20130328.xlsx'
   out=hudson.Branch_key_20130328
   dbms=EXCEL 
	replace;

run;

options compress=y;
 data hudson.feb_combined;
length hudson_branch  8  snl__key 8 hudson_name $30 branch_city $17 branch_state $2;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set hudson.Branch_key_20130328 end=eof1;
	dcl hash hh1 (dataset: 'hudson.Branch_key_20130328', hashexp: 8, ordered:'a');
	hh1.definekey('hudson_branch');
	hh1.definedata('snl__key','hudson_name');
	hh1.definedone();
end;

misses = 0;
do until (eof2);
	set hudson.feb_combined end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		snl__key = .;
		hudson_name = '';
		branch_city = '';
		branch_state = '';
	end;
	output;
end;

putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;

proc sort data=hudson.feb_combined;
by pseudo_hh order descending balance;;
run;


data report_data;
set hudson.feb_combined (where=(pseudo_hh ne .));
by pseudo_hh;
hh=0;
if first.pseudo_hh then hh = 1;
run;

proc sort data=report_data;
by pseudo_hh sbu_new;;
run;

proc summary data=report_data;
by pseudo_hh sbu_new;
output out=sbu N(pseudo_hh)=count;
run;

proc transpose data=sbu out=sbu1;
by pseudo_hh ;
id sbu_new;
var count;
run;

data sbu1;
set sbu1;
hh = 1;
if con ge 1 then con=1;
if bus ge 1 then bus = 1;
run;

proc sort data=report_data;
by pseudo_hh order descending balance;;
run;


data report_data;
merge report_data(in=a) sbu1 (in=b keep=pseudo_hh con bus );
by pseudo_hh ;
if a;
run;


data report_data;
set report_data;
if hh ne 1 then do;
	bus=.;
	con=.;
end;
run;

proc format ;
value $ mysbu (notsorted)
    'CON' = 'Consumer'
	'BUS' = 'Business';
value $ myprod (notsorted)
    'DDA' = 'Checking'
	'MMS' = 'Money Market'
	'SAV' = 'Savings'
	'TDA' = 'Time Deposits'
	'IRA' = 'IRAs';
run;


proc tabulate data=report_data order=data;
where hudson_name ne '' and sbu_new ne 'INT' and ptype in ("DDA","MMS","SAV","TDA","IRA");
class hudson_branch ptype sbu_new /preloadfmt;
var con bus hh balance ;
table hudson_branch='Branch Number' ALL, sum*(con='Consumer HHs'*f=comma12.) sum*(bus='Business HHs'*f=comma12.) 
                                     sbu_new='Accounts'*ptype=' '*(N=' '*f=comma12.) sbu_new='Balances'*ptype=' '*(sum*balance=" "*f=dollar24.) / nocellmerge misstext='0';
keylabel sum=' ' All = 'Total';
format sbu_new $mysbu.  ptype $myprod.;
run;


proc tabulate data=report_data order=data;
where hudson_name eq '' and sbu_new ne 'INT' and ptype in ("DDA","MMS","SAV","TDA","IRA");
class hudson_branch ptype sbu_new /preloadfmt;
var con bus hh balance ;
table hudson_branch='Branch Number' ALL, sum*(con='Consumer HHs'*f=comma12.) sum*(bus='Business HHs'*f=comma12.) 
                                     sbu_new='Accounts'*ptype=' '*(N=' '*f=comma12.) sbu_new='Balances'*ptype=' '*(sum*balance=" "*f=dollar24.) / nocellmerge misstext='0';
keylabel sum=' ' All = 'Total';
format sbu_new $mysbu.  ptype $myprod.;
run;


proc tabulate data=report_data order=data;
where sbu_new eq 'INT' and ptype in ("DDA","MMS","SAV","TDA","IRA");
class hudson_branch ptype sbu_new /preloadfmt;
var con bus hh balance ;
table hudson_branch='Branch Number' ALL, sum*(con='Consumer HHs'*f=comma12.) sum*(bus='Business HHs'*f=comma12.) 
                                     sbu_new='Accounts'*ptype=' '*(N=' '*f=comma12.) sbu_new='Balances'*ptype=' '*(sum*balance=" "*f=dollar24.) / nocellmerge misstext='0';
keylabel sum=' ' All = 'Total';
format sbu_new $mysbu.  ptype $myprod.;
run;
