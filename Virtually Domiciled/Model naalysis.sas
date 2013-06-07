proc format library=sas;
value probs 0-<.1 = 'Up to 10%'
	  0.1-<.2 = '10 to 20%'
	  0.2-<.3 = '20 to 30%'
	  0.3-<.4 = '30 to 40%'
	  0.4-<.5 = '40 to 50%'
	  0.5-<.6 = '50 to 60%'
	  0.6-<.7 = '60 to 70%'
	  0.7-<.8 = '70 to 80%'
	  0.8-<.9 = '80 to 90%'
	  0.9-<1 = '90 to 100%';
run;

proc format ;
value probs_a 0-<.01 = 'Up to 1%'
	  0.01-<.02 = '1 to 2%'
	  0.02-<.03 = '2 to 3%'
	  0.03-<.04 = '3 to 4%'
	  0.04-<.05 = '4 to 5%'
	  0.05-<.06 = '5 to 6%'
	  0.06-<.07 = '6 to 7%'
	  0.07-<.08 = '7 to 8%'
	  0.08-<.09 = '8 to 9%'
	  0.09-<.1 = '9 to 10%'
	 0.1-<.2 = '10 to 20%'
	  0.2-<.3 = '20 to 30%'
      .3-high = '30%+';
run;

proc freq data=virtual.models_20130220;
where hh = 1;
table mma_p sec_p iln_p ;
format mma_p sec_p iln_p probs_a.;
run;


data mma;
set virtual.models_20130220;
keep hhid mma_p;
run;

proc means data=mma min p20 p40 p60 p80 max;
var mma_p;
format mmap_p percent 6.1;
run;

*repeat for sec and also ilm;
%let var = iln;

data &var;
set virtual.models_20130220;
keep hhid &var._p;
run;

proc means data=&var  p20 p40 p60 p80 noprint;
var &var._p;
output out=breaks p20(&var._p)=p20 p40(&var._p)=p40 p60(&var._p)=p60 p80(&var._p)=p80;
run;

*this is cool;

options mlogic=on;
data &var;
if _N_ eq 1 then do;
	set breaks (drop=_freq_ _type_);
	array breaks{4} _temporary_ ;
	breaks{1} = p20; breaks{2} = p40; breaks{3}=p60; breaks{4}=p80;
	put breaks{1} breaks{2} breaks{3} breaks{4};
end;
set &var;

select ;
	when (&var._p le breaks{1}) quintile=5;
	when (&var._p gt breaks{1} and &var._p le breaks{2}) quintile=4;
	when (&var._p gt breaks{2} and &var._p le breaks{3}) quintile=3;
	when (&var._p gt breaks{3} and &var._p le breaks{4}) quintile=2;
	when (&var._p gt breaks{4}) quintile=1;
end;
drop p: ;
run;

data data.main_201303(compress=binary);
length hhid $ 9 quintile  8 ;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set &var end=eof1;
	dcl hash hh1 (dataset: "&var");
	hh1.definekey('hhid');
	hh1.definedata('quintile',"&var._p");
	hh1.definedone();
end;

misses = 0;
do until (eof2);
	set data.main_201303 end=eof2;
	rc = hh1.find();	
	if hh1.find() ne 0 then call missing(quintile);
	output;
end;

putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
rename quintile = &var._quintile;
run;

proc format ;
value quintiles 1 = 1
			    2 = 2
				3 = 3
				4 = 4
				5 = 5;
run;

%create_report(class1 = mma_quintile, fmt1 = quintiles,out_dir = C:\Documents and Settings\ewnym5s\My Documents\Analysis\Virtually Domiciled, 
                main_source = data.main_201303,  contrib_source = data.contrib_201303, condition = dda eq 1 and mma_quintile ne ge 1,
                out_file=mma_prospects,
                logo_file= C:\Documents and Settings\ewnym5s\My Documents\Administrative\Tools\logo.png)
