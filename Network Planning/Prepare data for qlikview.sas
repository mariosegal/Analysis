data atm;
length HHID $ 9 BRANCH $ 5;
infile 'C:\Documents and Settings\ewnym5s\My Documents\atm.txt' dsd dlm='09'x firstobs=2 missover obs=max;
input hhid $ branch $;
atm=1;
run;

data domiciled;
length HHID $ 9 BRANCH $ 5;
infile 'C:\Documents and Settings\ewnym5s\My Documents\domic.txt' dsd dlm='09'x firstobs=2 missover obs=max;
input hhid $ branch $;
domicile=1;
run;

data branch;
length HHID $ 9 BRANCH $ 5;
infile 'C:\Documents and Settings\ewnym5s\My Documents\BR_TRANS.TXT' dsd dlm='09'x firstobs=2 missover obs=max;
input hhid $ branch $;
br_tr=1;
run;

options compress=no;
%squeeze(atm,branch.atm_201209);
%squeeze(domiciled,branch.domiciled_201209);
%squeeze(branch,branch.branch_201209);




proc sort data=branch.atm_201209;
by hhid branch;
run;

proc sort data=branch.domiciled_201209;
by hhid branch;
run;

proc sort data=branch.branch_201209;
by hhid branch;
run;

proc freq data=branch.domiciled_201209;
table branch / missing;
run;

data branch.Branch_touchpoints_201209;
merge branch.atm_201209 (in=a) branch.domiciled_201209 (in=b) branch.branch_201209(in=c);
by hhid branch;
if a or b or c;
if atm eq . then atm=0;
if br_tr eq . then br_tr=0;
if domicile eq . then domicile=0;
run;

data a;
set branch.Branch_touchpoints_201209;
where branch ne '00000' and length(branch) eq 5 and findc(branch,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','it') eq 0;
run;



data branch.Branch_touchpoints_201209;
set a;
run;

data hhs;
set data.main_201209 (keep=hhid);
run;

data branch.Branch_touchpoints_201209;
merge hhs (in=a) branch.Branch_touchpoints_201209; (in=b)
by hhid;
if a;
run;

