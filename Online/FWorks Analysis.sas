data online.empl;
length hhid $9 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Online\empl.txt' dsd dlm='09'x firstobs=2;
input hhid $ flag $;
if hhid eq '' then delete;
run;

data online.Svcs_201205;
length  hhid $9 svc $ 15 key $ 28  related $ 28  ptype $ 3 user $ 1
        value1 $ 40 label1 $ 30 value2 $ 40 label2 $ 30 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Online\esvc.txt' dsd dlm='09'x firstobs=2 ;
input  hhid $ svc $  key $   related $    ptype $  user $ enroll: mmddyy10. cancel: mmddyy10. label1 $ value1 $  label2 $ value2 $;
if hhid eq '' then delete;
run;

data online.Activity_201205;
length  hhid $ 9  key $ 28  related $ 28  type $ 15 service $ 15
       label1 $ 30  label2 $ 30  label3 $ 30  label4 $ 30  label5 $ 30 value1 $ 40 value2 $ 40;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Online\eact.txt' dsd dlm='09'x firstobs=2 lrecl=4096;
input  hhid $ key $ related $ type $ service $ label1 $ value1 $  label2 $ value2 $  label3 $ value3  label4 $ value4  label5 $ value5 ;
if hhid eq '' then delete;
run;


data online.Svcs_201205;
merge online.Svcs_201205 (in=a) online.empl (in=b);
by hhid;
if a;
run;


data online.Activity_201205;
merge online.Activity_201205 (in=a) online.empl (in=b);
by hhid;
run;


*####################################################################################################################;

*who has it;
proc freq data=online.Svcs_201205;
where svc eq 'FINANCEWORKS' and ((cancel eq .) or (cancel lt enroll));
table flag / missing;
run;

*who is active;
proc freq data=online.Activity_201205;
where service eq 'FINANCEWORKS' and type eq 'USAGE' and label5 eq 'Num of Sign Ons' and value5 ge 1;
table flag / missing;
run;

*who added accounts;
data temp;
set online.Activity_201205;
where type eq 'ACCOUNT';
keep hhid;
run;

proc summary data=temp ;
class hhid;
output out=accts ;
run;

data accts;
set accts;
where _TYPE_ eq 1;
drop _TYPE_;
run;

data active;
set online.Activity_201205;
where service eq 'FINANCEWORKS' and type eq 'USAGE' and label5 eq 'Num of Sign Ons' and value5 ge 1;
keep hhid value5 ;
run;

proc summary data=active;
class hhid;
var value5;
output out = active1 sum=sign_ons n=accts;
run;

data accts;
merge accts (in=a) online.empl (in=b);
by hhid;
if a;
run;

data active1;
merge active1 (in=a where=(_TYPE_ eq 1)) online.empl (in=b);
by hhid;
if a;
drop _TYPE_ _FREQ_;
run;

data temp1;
set active1;
active_flag = 1;
keep hhid sign_ons active_flag;
run;

data temp2;
merge temp1 (in=a) accts (in=b rename=(_freq_=accts));
by hhid;
run;



data temp2;
set temp2;
if flag eq '' then flag = 'N';
select (accts);
	when (.) acct_flag = 0;
	otherwise acct_flag = 1;
end;
run;


proc tabulate data=temp2 missing;
class active_flag flag  ;
var accts sign_ons acct_flag;
table (active_flag='Active' ALL)*(flag='Employee' ALL) ALL, N*f=comma12. acct_flag='With Accts'*sum*f=comma12. (accts sign_ons)*(sum mean)*f=comma12.1 / nocellmerge rts=25 row=float;
format active_flag flagfmta. flag $flagfmt.;
run;




proc tabulate data=online.activity_201205 missing;
class type service label1 label2 label3 label4 label5 value1 value2 value3 value5;
table type*service*(label1 label2 label3 label4 label5), N;
run;


*new way, above may have problems;

*table with details of all enrolled HHs;
data fworks_hhs;
set online.svcs_201205;
where svc eq 'FINANCEWORKS' and ((enroll ge cancel) or (cancel eq .));
last_session = mdy(substr(value1,1,2),substr(value1,4,2),substr(value1,7,4));
keep hhid enroll last_session ;
format enroll date10.;
run;

proc summary data=fworks_hhs;
by hhid;
output out=fworks_hhs1 (drop=_type_ _freq_) min(enroll)=enroll max(last_session)=last_session;
run;


data temp;
set online.activity_201205;
where service = 'FINANCEWORKS';
run;

proc sort data=temp;
by hhid;
run;


data active;
set temp;
where type eq "USAGE" and label5 eq 'Num of Sign Ons';
active = 0;
if value5 ge 1 then active = 1;
keep hhid value5 active;
rename value5 = signons;
run;

proc summary data=active ;
by hhid;
output out=active1 (drop=_type_ _freq_) sum(signons)=signons max(active)=active ;
run;

data acct_types;
set temp;
where type = 'ACCOUNT' and label1 = 'FI Account Type' ;
array a{10} _temporary_;
array b{10} _temporary_;
by hhid;
*initialize;
if first.hhid then do;
	do i=1 to 10;
		a{i} = 0;
		b{i} = 0;
	end;
	accts = 0;
end;
*repeat each record;
select (value1);
	when ('CHECKING') a{1}+1;
	when ('MONEY_MARKET') a{2}+1;
	when ('SAVINGS') a{3}+1;
	when ('CD') a{4}+1;
	when ('MORTGAGE') a{5}+1;
	when ('LOAN') a{6}+1;
	when ('LINE_OF_CREDIT') a{7}+1;
	when ('CREDIT_CARD') a{8}+1;
	when ('TAXABLE_INVESTMENT') a{9}+1;
	when ('TAX_DEFERRED_INVESTMENT') a{10}+1;
end;
select (value1);
	when ('CHECKING') b{1}+value3;
	when ('MONEY_MARKET') b{2}+value3;
	when ('SAVINGS') b{3}+value3;
	when ('CD') b{4}+value3;
	when ('MORTGAGE') b{5}+value3;
	when ('LOAN') b{6}+value3;
	when ('LINE_OF_CREDIT') b{7}+value3;
	when ('CREDIT_CARD') b{8}+value3;
	when ('TAXABLE_INVESTMENT') b{9}+value3;
	when ('TAX_DEFERRED_INVESTMENT') b{10}+value3;
end;
accts+1;
*write variables;
if last.hhid then do;
	dda = a{1};
	mms = a{2};
	sav = a{3};
	tda = a{4};
	mtg = a{5};
	iln = a{6};
	loc = a{7};
	card = a{8};
	tax_inv = a{9};
	def_inv = a{10}; 

	dda_amt = b{1};
	mms_amt = b{2};
	sav_amt = b{3};
	tda_amt = b{4};
	mtg_amt = b{5};
	iln_amt = b{6};
	loc_amt = b{7};
	card_amt = b{8};
	tax_inv_amt = b{9};
	def_inv_amt = b{10}; 

	acct_flag = 0;
	if accts ge 1 then acct_flag = 1;

	output;
end;
keep hhid accts dda: mms: sav: tda: mtg: iln: loc: card: tax_inv: def_inv: acct_flag;
run;


data analysis_data bad;
merge fworks_hhs1 (in=d) active1 (in=a) acct_types (in=b) online.empl (in=c rename=(flag=employee));
by hhid;
if acct_flag eq . then acct_flag = 0;
if employee eq '' then employee = "N";
last1 = -1;
if last_session ne '' then last1 = year(last_session)*100+ month(last_session);
if d then output analysis_data;
if a and not d then output bad;
run;



proc format;
value $ flagfmt 'Y' = 'Yes'
             'N' = 'No';
			
value  flagfmta 1 = 'Yes'
            0 = 'No'
			. = 'No';
run;



proc tabulate data=analysis_data missing;
class active employee  ;
var accts signons acct_flag;
table (active='Active' ALL)*(employee='Employee' ALL) ALL, N*f=comma12. acct_flag='With Accts'*sum*f=comma12. (accts signons)*(sum mean)*f=comma12.1 / nocellmerge rts=25 row=float;
format active flagfmta. employee $flagfmt.;
run;

proc freq data=analysis_data;
table last1*active / missing norow nocol nopercent;
format active flagfmta.;
run;

proc format ;
value ynfmt . = 0
            0 = 0
			1-high = 1;
run;



data analysis_data_hh;
set analysis_data;
if dda ge 1 then dda = 1;
if mms ge 1 then mms = 1;
if sav ge 1 then sav = 1;
if tda ge 1 then tda = 1;
if mtg ge 1 then mtg = 1;
if iln ge 1 then iln = 1;
if loc ge 1 then loc = 1;
if card ge 1 then card = 1;
if tax_inv ge 1 then tax_inv = 1;
if def_inv ge 1 then def_inv = 1;
dep = max(dda,mms,sav,tda);
loan = max(mtg, iln, loc, card);
format last_Session date10.;
active_new = 0;
if month(last_session) in (5,6) and year(last_session) eq 2012 then active_new = 1;
run;



proc tabulate data=analysis_data_hh missing;
class active_new employee  ;
var  dda mms sav tda tax_inv def_inv mtg loc iln card dep loan acct_flag;
table (active_new='Active' ALL)*(employee='Employee' ALL) ALL, N (acct_flag dep loan dda mms sav tda tax_inv def_inv mtg loc iln card) / nocellmerge rts=25 row=float;
format active_new flagfmta. employee $flagfmt.;
run;


data temp_enroll;
set online.svcs_201205;
where svc eq 'FINANCEWORKS' ;
active = 0;
if ((enroll ge cancel) or (cancel eq .)) then active = 1;
date = year(enroll)*100 + month(enroll);
keep hhid active  date;
run;

data temp_enroll;
merge temp_enroll (in=a) online.empl (in=b rename=(flag=employee));
by hhid;
if a;
if employee eq '' then employee = "N";
run;

proc freq data=temp_enroll;
table date*employee /missing norow nocol nopercent;
run;

data last;
set analysis_data_hh;
last1 = year(last_session)*100 + month(last_session);
keep last1 active_new ;
run;

proc freq data=last;
table last1*active_new / missing norow nocol nopercent;
run;


proc tabulate data=analysis_data_hh missing;
class active_new employee  accts;
var  signons acct_flag;
table  (active_new='Active' ALL)*(employee='Employee' ALL)*accts, N / nocellmerge;
format accts ynfmt. active_new flagfmta. employee $flagfmt.;
run;



proc tabulate data=data.main_201206 missing;
class fworks_flag1 svcs;
var hh;
table  (svcs ALL)* hh*(sum*f=comma12. ), fworks_flag1 ALL / nocellmerge;
run;


proc tabulate data=data.main_201206 missing;
class fworks_flag1 ;
var svcs hh;
table fworks_flag1 ALL, svcs*(sum pctsum<hh>) hh*sum / nocellmerge;
run;
