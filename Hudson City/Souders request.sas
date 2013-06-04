proc format ;
value $order  (notsorted)
	'DDA' = 'Checking'
	'MMS' = 'Money Market'
	'SAV' = 'Savings'
	'TDA' = 'Time Deposits'
	'IRA' = 'IRAs';
value $sbunew (notsorted)
	'CON' = 'Consumer'
	'BUS' = 'Business'
	'INT' = 'Internal';
run;



proc tabulate data=hudson.clean_20121106 missing order=data out=branches1;
where ptype in ('DDA','MMS','SAV','TDA','IRA');
class branch  sbu_new;
class ptype / preloadfmt;
var curr_bal;
table (branch all),(sbu_new='' all)*(ptype='' all)*sum=''*curr_bal=''*f=dollar24. / nocellmerge misstext='0';
format ptype $order. sbu_new $sbunew.;
run;

proc sort data=hudson.branch_key;
by hudson_branch;
run;

proc print data=hudson.branch_key;
run;






proc tabulate data=hudson.hudson_hh missing;
where external ne 1;
class branch;
var  hh;
table (branch all),N='HHs'*f=comma12. / nocellmerge misstext='0';
run;


