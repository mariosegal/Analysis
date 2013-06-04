data temp_bus;
set hudson.clean_20121106;
where sbu_new = "BUS";
run;

proc sort data=temp_bus;
by pseudo_hh ptype;
run;

proc summary data=temp_bus;
by pseudo_hh ptype;
output out=temp_bus2
       N(pseudo_hh) = count
	   sum(curr_bal) = balance;
run;

proc transpose data=temp_bus2 out=temp_bus_counts suffix=_bus;
by pseudo_hh;
id ptype;
var count;
run;

proc transpose data=temp_bus2 out=temp_bus_amt suffix=_amt_bus;
by pseudo_hh;
id ptype;
var balance;
run;

data consumer;
set hudson.hudson_hh;
keep pseudo_hh con dda tda mms sav ira mtg mtx heq iln ccs dda_amt tda_amt mms_amt sav_amt ira_amt mtg_amt mtx_amt heq_amt iln_amt ccs_amt segment products;
rename dda=dda_con tda=tda_con mms=mms_con sav=sav_con ira=ira_con mtg=mtg_con mtx=mtx_con heq=heq_con iln=iln_con ccs=ccs_con 
       dda_amt=dda_amt_con tda_amt=tda_amt_con mms_amt=mms_amt_con sav_amt=sav_amt_con ira_amt=ira_amt_con mtg_amt=mtg_amt_con 
       mtx_amt=mtx_amt_con heq_amt=heq_amt_con iln_amt=iln_amt_con ccs_amt=ccs_amt_con
	   products=prods_con;
run;

data merged_bus;
merge temp_bus_counts(in=a drop=_name_ ) temp_bus_amt (in=b drop=_name_ _label_) ;
by pseudo_hh;
if a or b;
bus=1;
run;


data hudson.business_hh;
merge merged_bus (in=a) consumer (in=b drop=con);
by pseudo_hh;
if a;
hh = 1;
run;

data hudson.business_hh;
set hudson.business_hh;
select (prods_con);
	when(.) con=0;
	when(0) con=0;
	otherwise con=1;
end;
prods_bus = sum(dda_bus,mms_bus,sav_bus,mtg_bus,cln_bus);
run;


proc freq data=hudson.business_hh;
table con*bus;
run;

%null_to_zero(hudson.business_hh)

*take out the ones that are bus and internal;


