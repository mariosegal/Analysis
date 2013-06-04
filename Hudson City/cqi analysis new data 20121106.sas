proc format;
value  prods (notsorted )
	      1 = 'Single'
		2-high = 'Multi';
run;

proc freq data=hudson.clean_20121106 ;
table debit direct_deposit web odl bill_pay;
run;


data hudson.clean_20121106;
set hudson.clean_20121106;
cqi_web =0;
if web eq 'Y' then cqi_web=1;
cqi_odl = 0;
if ODL eq 'Y' then cqi_odl =1;
cqi_debit = 0;
if DEBIT = 'Y' then cqi_debit = 1;
cqi_dd = 0;
if DIRECT_DEPOSIT eq 'Y' then cqi_dd = 1;
cqi_bp = 0;
if BILL_PAY in ('Y') then cqi_bp = 1;
cqi = sum(cqi_bp, cqi_dd, cqi_odl, cqi_web, cqi_debit);
aux=1;
run;


proc tabulate data=hudson.clean_20121106 missing;
where ptype in ('DDA',"MMS","TDA","IRA","SAV");
class ptype products cqi;
var cqi_bp cqi_web cqi_dd cqi_debit cqi_odl aux ;
table products, ptype, (sum*aux*f=comma12. cqi_web='Web'*(sum*f=comma12. pctsum<aux>*f=pctfmt.) cqi_debit='Debit'*(sum*f=comma12. pctsum<aux>*f=pctfmt.)
                       cqi_bp='Bill Pay'*(sum*f=comma12. pctsum<aux>*f=pctfmt.) cqi_dd='Dir Dep'*(sum*f=comma12. pctsum<aux>*f=pctfmt.) 
                        cqi_odl='Overdraft'*(sum*f=comma12. pctsum<aux>*f=pctfmt.)) 
                       / nocellmerge;
table products, ptype, N*f=comma12. cqi*aux*sum*f=comma12. cqi*aux*rowpctsum*f=pctfmt. / nocellmerge;
format products prods.;
run;


proc tabulate data=hudson.clean_20121106 missing;
where ptype in ('DDA',"MMS","TDA","IRA","SAV");
class ptype products ;
var cqi_bp cqi_web cqi_dd cqi_debit cqi_odl aux cqi;

table products, ptype,N  cqi*(sum*f=comma12.) cqi*rowpctsum<aux>/ nocellmerge;
format products prods.;
run;


*sumamrize cqi for chk HHs;
proc summary data=hudson.clean_20121106;
where PTYPE = "DDA";
by pseudo_hh;
output out=cqi_summary 
       sum(cqi_web) = cqi_web
	   sum(cqi_dd) = cqi_dd
	   sum(cqi_bp) = cqi_bp
	   sum(cqi_debit) = cqi_debit
	   sum(cqi_odl) = cqi_odl;
run;

data cqi_summary;
set cqi_summary;
if cqi_web ge 1 then cqi_web = 1;
if cqi_dd ge 1 then cqi_dd = 1;
if cqi_odl ge 1 then cqi_odl = 1;
if cqi_debit ge 1 then cqi_debit = 1;
if cqi_bp ge 1 then cqi_bp = 1;
drop _type_ _freq_;
run;

data hudson.hudson_hh;
merge hudson.hudson_hh (in=a) cqi_summary (in=b);
by pseudo_hh;
if a;
run;

data hudson.hudson_hh;
set hudson.hudson_hh;
cqi = sum(cqi_bp, cqi_dd, cqi_odl, cqi_web, cqi_debit);
run;

*analyze checking HHs;

title 'hh level analysis for chk HHs';
proc tabulate data=hudson.hudson_hh missing;
where dda1 eq 1;
class products ;
var cqi_bp cqi_web cqi_dd cqi_debit cqi_odl hh cqi;
table products, N  cqi*(sum*f=comma12.) cqi*rowpctsum<hh>/ nocellmerge;
format products prods.;
run;

proc tabulate data=hudson.hudson_hh missing;
where dda1 eq 1;
class products cqi;
var cqi_bp cqi_web cqi_dd cqi_debit cqi_odl hh ;
table products,  (sum*hh*f=comma12. cqi_web='Web'*(sum*f=comma12. pctsum<hh>*f=pctfmt.) cqi_debit='Debit'*(sum*f=comma12. pctsum<hh>*f=pctfmt.)
                       cqi_bp='Bill Pay'*(sum*f=comma12. pctsum<hh>*f=pctfmt.) cqi_dd='Dir Dep'*(sum*f=comma12. pctsum<hh>*f=pctfmt.) 
                        cqi_odl='Overdraft'*(sum*f=comma12. pctsum<hh>*f=pctfmt.)) 
                       / nocellmerge;
table products, N*f=comma12. cqi*hh*sum*f=comma12. cqi*rowpctN*f=pctfmt. / nocellmerge;
format products prods.;
run;


*MTB Comparison;
data data.main_201209;
set data.main_201209;
cqi = sum(cqi_bp, cqi_web, cqi_dd, cqi_deb, cqi_odl);
run;


proc tabulate data=data.main_201209 missing;
where dda eq 1 and cbr in (1,12,13);
class cqi products;
var hh cqi_bp cqi_web cqi_dd cqi_deb cqi_odl;
table products, sum*(hh) sum*(cqi_bp cqi_web cqi_dd cqi_deb cqi_odl)*f=comma12. pctsum<hh>*(cqi_bp cqi_web cqi_dd cqi_deb cqi_odl)*f=pctfmt. / nocellmerge;
table products, sum*hh cqi*sum*hh*f=comma12. cqi*rowpctN*f=pctfmt.  / nocellmerge;
table products, N cqi*(sum rowpctN);
format products prods.;
run;

proc tabulate data=data.main_201209 missing;
where dda eq 1 and cbr in (1,12,13);
class  products;
var hh cqi_bp cqi_web cqi_dd cqi_deb cqi_odl cqi;
table products, N cqi*(sum rowpctsum<hh>);
format products prods.;
run;
