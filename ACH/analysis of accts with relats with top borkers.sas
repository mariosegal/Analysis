proc sql;
select type, count(*) from bagels.top_company_flow group by type;
quit;

proc freq data=bagels.top_company_flow order=freq noprint;
where type='R';
table accountkey / out=a;
run;

proc freq data=a order=freq;
table count;
run;

proc freq data=bagels.top_company_flow order=freq ;
where type='R';
table company / out=b;
run;

data b;
set b;
flag = .;
run;

proc sort data=bagels.top_company_flow;
by company;
run;

proc sort data=b;
by company;
run;


data temp;
merge bagels.top_company_flow (in=a) b (in=b keep=company flag);
by company;
if a;
run;

data temp1;
set temp;
where type eq 'R' and flag eq 1;
run;

proc sort data=temp1;
by accountkey;
run;

data temp4;
set ifm.ifm_acct_profile;
keep accountkey hhkey;
where month(perioddate) eq 5;
run;


proc sort data=temp4;
by hhkey;
run;

data ixi;
merge temp4 (in=a rename=(hhkey=hhid)) data.main_201206 (in=b keep=hhid ixi_tot sec);
by hhid;
if a and b;
run;

proc sort data=ixi;
by accountkey;
run;

data ixi1;
merge ixi(in=a) temp1(in=b keep=accountkey flag where=(flag eq 1));
by accountkey;
if a and b;
run;

proc sort data=ixi1;
by hhid;
run;

proc summary data=ixi1;
by hhid;
output out=ixi2 sum(sec)=sec mean(ixi_tot)=ixi_tot;
run;


data ixi2;
set ixi2;
secflag = 'N';
if sec ge 1 then secflag='Y';
run;

proc format library=sas;
   picture pctfmt low-high='009.9 %';
run;


proc tabulate data=ixi2;
class secflag ixi_tot;
table secflag='M&T Securities' ALL, (ixi_tot='IXI Wealth Estimate' ALL)*(N*f=comma12. rowpctn='Row %'*f=pctfmt9. colpctN='Col %'*f=pctfmt9.);
format ixi_tot wealthband.;
keylabel all="Total" N="HHs";
run;

proc tabulate data=ixi2;
class secflag ixi_tot;
table (ixi_tot='IXI Wealth Estimate' ALL),(secflag='M&T Securities' ALL)*(N*f=comma12. rowpctn='Row %'*f=pctfmt9. colpctN='Col %'*f=pctfmt9.) / nocellmerge;
format ixi_tot wealthband.;
keylabel all="Total" N="HHs";
run;


proc sort data=temp1;
by accountkey;
run;

proc sort data=temp4;
by accountkey;
run;

data brokers;
merge temp1 (in=a) temp4 (in=b);
by accountkey;
if a;
run;

proc freq data=brokers order=freq;
where company ne 'FRONTIER TRUST';
table company;
run;

