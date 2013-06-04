*READ DATA, 1 time;

data aug;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ATM\aug.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input hhid $ channel $	wsid $	type $	count amount branch;
month = 8;
run;

data sep;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ATM\sep.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input hhid $ channel $	wsid $	type $	count amount branch;
month=9;
run;


data oct;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ATM\oct.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input hhid $ channel $	wsid $	type $	count amount branch;
month=10;
run;


data atm.exxon_transactions;
set aug sep oct;
run;

*NOW figure out how often they used those versus other ATMOs, and how many months to classify like before.;
proc sort data=atm.exxon_transactions nodupkey out=hhs;
by hhid;
run;


data check;
merge hhs (in=a keep=hhid) data.main_201303 (in=b);
by hhid;
if a and b;
run;

proc freq data=check;
table dda;
run;


data check200909;
merge hhs (in=a keep=hhid) data.main_201209(in=b);
by hhid;
if a and b;
run;

data left;
merge check (in=a keep=hhid) check200909 (in=b keep=hhid);
by hhid;
if b and not a;
type = 1;
run;

data nocheck;
set check;
where dda eq 0;
type = 2;
keep hhid type;
run;


data attrited;
set nocheck left;
run;

proc sort data=attrited;
by hhid;
run;

data analysis;
merge check200909 (in=a) attrited (in=b);
by hhid;
if a;
if a and not b then type=0;
run;

proc format;
value mytype 
	0 = 'Retained with Checking'
	1 = 'HH Attrited'
	2 = 'HH Retained, Lost Checking';
value mytype_a 
	0 = 'Retained Checking'
	1 = 'Lost Checking'
	2 = 'Lost Checking';
run;

%create_report(class1=type,fmt1=mytype_a,condition=hh eq 1,main_source=wip.analysis,contrib_source=data.contrib_201209,out_file=Exxon ATM Attrition,
out_dir=C:\Documents and Settings\ewnym5s\My Documents\ATM,logo_file=C:\Documents and Settings\ewnym5s\My Documents\Tools\logo.png)

;

data test;
set penet;
where _table_ eq 1 and _type_ eq '1';
drop _:;
rename hh_sum = total;
run;

data dda;
set test;
keep total dda_sum response count type;
response='Y'; count=dda_sum; output;
response='N'; count=total-dda_sum;output;
run;

data sav;
set wip.test;
keep total sav_sum response count type;
response='Y'; count=sav_sum; output;
response='N'; count=total-sav_sum;output;
run;


proc freq data=sav;
weight count;
table type*(response) / missing chisq fisher;
run;

data sav1;
set wip.test;
keep total sav_sum response count type;
response='Y'; count=sav_sum; output;
/*response='N'; count=(total-sav_sum)/total;output;*/
run;

proc freq data=sav1;
weight count;
table type / missing chisq fisher;
run;

proc ttest data=sav;
weight total;

paired type*count;
run;


proc fcmp outlib=sas.functions.mario;
function prop_test(x1,n1,x2,n2,type $);
	p1h = x1/n1;
	p2h = x2/n2;
	ph = (x1+x2)/(n1+n2);
	diff=p1h-p2h;
	if sqrt(ph*(1-ph)/n1 + ph*(1-ph)/n2) ne 0 then do;
		z=(p1h-p2h)/sqrt(ph*(1-ph)/n1 + ph*(1-ph)/n2);
		pgreater = 1 - PROBNORM(z);
		pless = PROBNORM(z);
		ptwoside = 2*MIN(1-ABS(PROBNORM(z)),ABS(PROBNORM(z)));
	end;
	else do;
		pgreater = .;
		pless = .;
		ptwoside = .;
	end;

	if type = '<' then return(pless);
	if type = '>' then return(pgreater);
	if type = '=' then return(ptwoside);
endsub;
run;

proc contents data=wip.penet varnum short;
run;


proc transpose data=penet out=a;
where _table_ eq 1 and _type_ eq '1';
by type;
var dda_Sum mms_Sum sav_Sum tda_Sum ira_Sum mtg_Sum heq_Sum card_Sum ILN_Sum 
    IND_Sum sln_Sum sec_Sum ins_Sum trs_Sum sdb_Sum ;
copy hh_sum;
run;

data a;
set a;
retain total;
_name_ = substr(_name_,1,3);
rename _name_ = prod col1=count;
if hh_sum ne . then total=hh_sum;
drop hh_sum;
run;


proc sort data=a;
by prod;
run;


data greater smaller equal ;
length result 8;
if 0 then set a a(rename=(prod=prod2 type=type2 count=count2 total=total2));
if _n_ eq 1 then do;
	dcl hash h1(dataset: 'a');
	h1.definekey(key: 'type','prod');
	h1.definedata(all:'yes');
	h1.definedone();
	dcl hiter hi1('h1');

	dcl hash h2(dataset: 'a (rename=(prod=prod2 type=type2 count=count2 total=total2))');
	h2.definekey(key: 'type2','prod2');
	h2.definedata(all:'yes');
	h2.definedone();
	dcl hiter hi2('h2');
end;

rc1=0;
hi1.first();
do while (rc1=0);
	rc2=0;
	hi2.first();
	do while (rc2=0);	
		if prod eq prod2 and type ne type2 then do;
			result=prop_test(count,total,count2,total2,'>');
			output greater;
		end;
		if prod eq prod2 and type ne type2 then do;
			result=prop_test(count,total,count2,total2,'<');
			output smaller;
		end;
		if prod eq prod2 and type ne type2 then do;
			result=prop_test(count,total,count2,total2,'=');
			output equal;
		end;
		rc2=hi2.next();
	end;

	rc1=hi1.next();
end;
run;

proc sort data=equal;
by prod type type2;
run;

proc sort data=smaller;
by prod type type2;
run;

proc sort data=greater;
by prod type type2;
run;

proc tabulate data=smaller;
by prod;
class type type2;
var result;
table type="Lower Group for Ho",type2="Higher Group for Ho"*result*sum*f=percent8.3;
run;

proc print data=a;
where prod eq 'sav';
run;

proc sgpanel data=wip.smaller;
where prod = 'sav';
panelby group2 group / layout=lattice uniscale=row;
vbar result /  response=result stat=sum datalabel;
rowaxis label="Lower Group for Ho";
colaxis label="Higher Group for Ho" type=discrete;
format result percent6.4;
run;

data wip.smaller;
set smaller;
run;
data wip.smaller;
set wip.smaller;
group = put(type,mytype.);
group2 = put(type2,mytype.);
run;

proc sgplot data=smaller;
where prod = 'sav' and group2="Retained Checking" ;
/*panelby type2 type / layout=lattice;*/
vbar result /   stat=sum datalabel group=group;
/*rowaxis label="Lower Group for Ho";*/
/*colaxis label="Higher Group for Ho" type=discrete;*/
run;

proc sgpanel data=wip.smaller;
where prod = 'sav';
panelby type2 / uniscale=all ;
vbar result /  response=result stat=sum datalabel group=type;
rowaxis label="Lower Group for Ho";
colaxis label="Higher Group for Ho" type=discrete;
run;


*so what is their mix after;
*the data I have handy is total usage from december to march 2013.;

*1) extract the transactions for those;

proc sort data=atm.exxon_transactions nodupkey out=exxon_hh(keep=hhid);
by hhid;
run;

proc sort data=atm.Atm_all_sum;
by hhid;
run;

data exxon_after;
merge exxon_hh(in=a) atm.Atm_all_sum (in=b);
by hhid;
if a;
run;

data exxon_before;
if 0 then set atm.atm_coords(keep=wsid group);
if _n_ eq 1 then do;
	dcl hash h(dataset:"atm.atm_coords(keep=wsid group)");
	h.definekey('wsid');
	h.definedata('group');
	h.definedone();
end;

retain miss;

set  atm.exxon_transactions end=eof;

rc = h.find();
if rc ne 0 then  do;
	call missing(group);
	miss+1;
end;

if eof then put miss " records notot found on coords dataset";
run;

proc freq data=exxon_after order=freq;
where group eq '';
table wsid / missing;
run;

data exxon_before;
set exxon_before;
if wsid in ('8673','8691') then group="Exxon";
if wsid = 'ATMT' then group='ATMT';
run;

data exxon_after;
set exxon_after;
if wsid in ('8673','8691') then group="Exxon";
if wsid = 'ATMT' then group='ATMT';
run;

proc tabulate data= exxon_before missing;
class group;
var count amount;
table group all,sum*(count*f=comma12.) sum*amount*f=dollar24. rowpctsum<count>*amount*f=pctdoll. / nocellmerge;
run;



proc tabulate data= exxon_after missing;
class group;
var count amount;
table group all,sum*(count*f=comma12.) sum*amount*f=dollar24. rowpctsum<count>*amount*f=pctdoll. / nocellmerge;
run;
