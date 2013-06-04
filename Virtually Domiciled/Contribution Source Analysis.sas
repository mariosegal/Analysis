libname virtual 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled';
libname Data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname wip 'C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files';

options MSTORED SASMSTORE = mjstore;
libname mjstore 'C:\Documents and Settings\ewnym5s\My Documents\SAS\Macros';

libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
options fmtsearch=(SAS);

filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\cont_brk.txt';
data virtual.contribution;
length hhid $ 9 ptype $ 3 stype $ 3 sbu $ 3;
infile mydata dlm='09'x dsd lrecl=4096 firstobs=2;
input hhid $ ptype $ stype $ sbu $ billpay expense ATM income interch int_exp int_inc maint mtd fees pool POS nsf nsf_waived;
if ptype in ('WEB','ATM','CLN','HBK','DEB') THEN delete;
run;


proc freq data=virtual.contribution;
where ptype not in ('DDA','MMS',"TDA",'IRA',"SAV");
table sbu*ptype / nocol norow nopercent;
run;

proc freq data=virtual.contribution;
where ptype in ('DDA','MMS',"TDA",'IRA',"SAV");
table sbu*ptype*stype / nocol norow nopercent;
run;

proc sort data=virtual.contribution;
by hhid ptype;
run;

proc summary data=virtual.contribution;
by hhid ptype;
output out=virtual.contribution_summary
       sum(billpay) = billpay
	   sum(expense) = expense
	   sum(ATM) = ATM
	   sum(income) = income
	   sum(interch) = interch
	   sum(int_exp) = int_exp 
	   sum(int_inc) = int_inc
	   sum(maint) = maint
	   sum(mtd) = mtd
	   sum(fees) = fees
	   sum(pool) = pool
	   sum(pos)= pos
	   sum(nsf) = nsf
	   sum(nsf_waived) = nsf_waived;
run;

data virtual.contribution_summary ;
merge virtual.contribution_summary (in =a ) data.main_201111 (in=b keep=hhid segment virtual_seg tran_segm rm hh);
if a;
run;

/*proc datasets library=work;*/
/*copy out=virtual move ;*/
/*select tempq;*/
/*run;*/
/**/
/*proc datasets library=virtual;*/
/*delete contribution_summary;*/
/*change tempq=contribution_summary;*/
/*run;*/
/**/
/*proc contents data=virtual.contribution_summary varnum short;*/
/*run;*/

proc sort data=virtual.contribution_summary;
by hhid ptype;
run;

data  virtual.contribution_summary ;
set virtual.contribution_summary;
by hhid;
hh = 0;
if first.hhid then hh = 1;
run;



proc tabulate data=virtual.contribution_summary missing;
where virtual_seg ne '';
class virtual_seg ptype ;
var billpay expense ATM income interch int_exp int_inc maint mtd fees pool pos nsf nsf_waived hh ;
table (virtual_seg='Tran Segm' ALL='Total')*(ptype='Product' ALL='Total'), 
      N='HH'*f=comma12. (billpay expense ATM income interch int_exp int_inc maint mtd fees pool pos nsf nsf_waived)*(sum*f=dollar12.) / nocellmerge ;

run;
