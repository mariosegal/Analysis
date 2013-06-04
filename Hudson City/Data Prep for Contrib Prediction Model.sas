data hudson.predict_data;
set data.main_201209;
keep hhid band dda: mms: sav: tda: ira: mtg: heq: iln: cqi: atm: mpos: vpos: ixi_tot segment;
run;

data contr;
set data.contrib_201209;
keep hhid contrib;
run;

data hudson.predict_data; 
merge  hudson.predict_data contr;
by hhid;
run;

data hudson.predict_data; 
set hudson.predict_data;
select (band);
	when ('A') band_num = 1;
	when ('B') band_num = 2;
	when ('C') band_num = 3;
	when ('D') band_num = 4;
	when ('E') band_num = 5;
	otherwise band_num=.;
end;
deposits = max(dda,mms,sav,tda,ira);
loans = max(iln,mtg,heq);
both = deposits*loans;
dep_amt = sum(dda_amt,mms_amt,sav_amt,tda_amt,ira_amt);
loan_amt = sum(iln_amt,mtg_amt,heq_amt);
both_amt = dep_amt + loan_amt;
drop band_new;
run;

data hudson.predict_data; 
set hudson.predict_data;
A = 0;
B = 0;
C = 0;
D= 0;
E=0;
if band = 'A' then A=1;
if band = 'B' then B=1;
if band = 'C' then C=1;
if band = 'D' then D=1;
if band = 'E' then E=1;
run;


options compress=Y;
data temp;
length ID 8;
set hudson.predict_data;
id = hhid;
run;

data temp;
set temp;
drop hhid band:;
run;

%squeeze(temp,hudson.predict_data)

proc surveyselect data = hudson.predict_data method = SRS rep = 1 
                         sampsize = 1000000 seed = 12345 out = hudson.modeling;
  id _all_;
run;


data hudson.validation;
merge hudson.predict_data (in=a1) hudson.modeling(in=b1);
by id;
if a1 and not b1;
run;

data check;
merge hudson.validation (in=a1) hudson.modeling(in=b1);
by id;
if a and b;
run;

proc export data=hudson.modeling outfile='C:\Documents and Settings\ewnym5s\My Documents\Hudson City\modeling.csv' dbms=CSV;
run;

*CLEAN MODELING;

proc means data=HUDSOn.modeling;
var ixi_tot;
run;

DATA HUDSOn.modeling;
set HUDSOn.modeling;
if iln_amt eq . then iln_amt = 0;
s1=0;
s3=0;
s4=0;
s5=0;
s6=0;
s7=0;
select (segment);
	when(1,8) s1 = 1;
	when(2,4,9) s4=1;
	when(3) s3=1;
	when(5) s5=1;
	when(6) s6=1;
	when(7) s7=1;
    otherwise do;
		s1=0;
		s3=0;
		s4=0;
		s5=0;
		s6=0;
		s7=0;
	end;
end;
if ixi_tot ne . then ixi_new = ixi_tot;
if ixi_tot eq . then ixi_new = 304771;
run;


