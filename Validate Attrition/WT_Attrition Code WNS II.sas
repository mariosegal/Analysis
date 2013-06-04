filename wtfile '/sasmnt/u2/cfsdata/MTB/Aju/WT_CON_NEW.TXT';
filename pbfile '/sasmnt/u2/cfsdata/MTB/Aju/PB_CON_NEW.TXT';
filename mtfile '/sasmnt/u2/cfsdata/MTB/Aju/MTB_CON_NEW.TXT';
LIBNAME Dec11 "/sasmnt/u2/cfsdata/MTB/Dec11/SASData";


data wt_con;
length hhid $ 9;
infile wtfile dlm='09'x dsd;
input hhid $;
wt = 1;
run;


data pb_con;
length hhid $ 9;
infile pbfile dlm='09'x dsd;
input hhid $;
pb = 1;
run;


data mt_con;
length hhid $ 9;
infile mtfile dlm='09'x dsd;
input hhid $;
mt = 1;
run;


data combined;
set mt_con pb_con wt_con;
run;


proc sort data=combined;
by hhid;
run;


proc summary data=combined;
by hhid;
output out=combined1 (drop=_TYPE_ _FREQ_)
sum(wt) = wt
sum(mt) =  mt
sum(pb) = pb;
run;



data con_grps;
set combined1;
select;
   when(wt eq 1)  grp = 'WT';
   when(pb eq 1)  grp = 'PB';
   when (mt eq 1 and pb eq .)  grp = 'MT';
end;
keep hhid grp;
run;


proc freq data=con_grps;
table grp;
run;


DATA d_201112;
SET Dec11.Acct(KEEP=ACCT_ID acct_mask_account_key_1 acct_ptype acct_stype acct_sbu_group acct_amt_bal_current);
RENAME acct_id=hhid;
RUN;


proc sort data=d_201112;
by hhid;
run;


proc sort data=con_grps;
by hhid;
run;


data temp1;
merge d_201112 (in=a) con_grps (in=b keep = hhid grp);
by hhid;
if a;
run;


data analysis_con_201112;
set temp1;
where grp ne '';
by hhid;
hh=0;
if last.hhid then hh=1;
bal1 = 0;
if acct_PTYPE in('DDA','SAV','MMS','TDA','IRA') and substr(acct_stype,1,1) eq 'R' then bal1 =ACCT_AMT_BAL_CURRENT;
run;


ods html file='/sasmnt/u1/mntdata/u180094/WTBAL.HTML';


proc freq data=con_grps;
table grp;
run;

proc tabulate data=analysis_con_201112;
where acct_ptype in ('DDA','SAV','MMS','TDA','IRA') and substr(acct_stype,1,1) eq 'R';
class grp acct_ptype;
var ACCT_AMT_BAL_CURRENT;
table acct_ptype ALL, grp='Groupwise balances'*(ACCT_AMT_BAL_CURRENT=''*sum=''*f=dollar24.);
run;

ods html close;