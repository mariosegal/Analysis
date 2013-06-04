options compress=yes;
data data.main_201209;
set  data.main_201209;
products = sum(dda,mms,sav,tda,ira,card,mtg,heq,iln,ind, sdb, sec,ins,sln);
run;

proc freq data=data.main_201209;
where products ge 1 and not (products eq 1 and ind eq 1);
table products / missing;
run;

proc freq data=data.main_201209;
where products ge 1 and not (products eq 1 and ind eq 1);
table segment / missing;
format segment mtbseg.;
run;


proc tabulate data=data.main_201209 missing;
where products ge 1 and not (products eq 1 and ind eq 1);
var hh dda: mms: sav: tda: ira: heq: mtg: iln: ccs_amt: ;
table sum*(hh dda mms sav tda ira mtg heq iln)*f=comma12. (dda mms sav tda ira mtg heq iln)*pctsum<hh>*f=pctfmt. 
	  (dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt)*sum*f=dollar24.	
      (dda_amt*pctsum<dda> mms_amt*pctsum<mms> sav_amt*pctsum<sav> tda_amt*pctsum<tda> ira_amt*pctsum<ira> mtg_amt*pctsum<mtg> heq_amt*pctsum<heq> iln_amt*pctsum<iln>)*f=pctdoll.;
run;

%penetration(class1=cbr,fmt1=cbr2012fmt,where=(products ge 1 and dda eq 1 and active eq 1 and  not (products eq 1 and ind eq 1)),period=201209)
;

%segments(class1=products,fmt1=prods,where=(products ge 1   and not (products eq 1 and ind eq 1)),period=201209)
;


proc freq data=data.main_201209;
where products ge 1 and dda eq 1 and active eq 1 and not (products eq 1 and ind eq 1);
table products;
run;


*new area chart (now waterfall);

proc freq data=hudson.hudson_HH;
where external ne 1;
table area_group_new*products / norow nocol nopercent;
format products prods.;
run;
