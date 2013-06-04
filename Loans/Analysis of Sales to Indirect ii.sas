proc tabulate data=data.main_201203;
where (distance gt 0 or (distance eq 0 and lat ne 0 and long ne 0));  
where also delta_group ne 'chec';
where also cb_name ne .;
class distance;
var hh dda mms sav tda ira mtg heq card iln ind sdb sec ins dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt ccs_amt iln_amt ind_amt  sec_amt ;
table distance, (hh dda mms sav tda ira mtg heq card iln ind sdb sec ins)*sum*f=comma12. 
                (dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt ccs_amt iln_amt ind_amt  sec_amt)*sum*f=dollar24.;
formaT DISTAnce distfmt.;
run;

proc tabulate data=data.main_201203;
where (distance gt 0 or (distance eq 0 and lat ne 0 and long ne 0));  
where also delta_group ne 'chec';
where also cb_name ne .;
var distance ;
table distance, mean*f=comma12.1;
formaT DISTAnce distfmt.;
run;

proc means data=data.main_201203;
where (distance gt 0 or (distance eq 0 and lat ne 0 and long ne 0));  
where also delta_group ne 'chec';
where also cb_name ne .;
var distance;
formaT DISTAnce distfmt.;
run;


proc freq data=data.main_201203;
where (distance gt 0 or (distance eq 0 and lat ne 0 and long ne 0));  
where also delta_group ne 'chec';
where also cb_name ne .;
where MTG eq 1 and sum(dda,mms,sav,tda,ira,sec,ins) eq 0;
table state*distance / missing nocol norow nopercent;
formaT DISTAnce distfmt.;
run;

proc format library=sas cntlout=tmpfmt;
select distfmt;
run;

data a;
set tmpfmt (keep=start end label fmtname sexcl eexcl type hlo);
run;

proc sort data=a;
by start end;
run;

proc format library=sas cntlin=a ;
run;
