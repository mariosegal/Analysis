filename wtfile 'C:\Documents and Settings\ewnym5s\My Documents\Validate Attrition\wt.txt';
filename pbfile 'C:\Documents and Settings\ewnym5s\My Documents\Validate Attrition\pb.txt';
filename mtfile 'C:\Documents and Settings\ewnym5s\My Documents\Validate Attrition\mtb.txt';

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

proc tabulate data=attr.con_grps missing;
class wt pb mt grp;
table wt mt pb, grp ;
run;

data attr.con_grps;
set combined1;
select;
   when(wt eq 1)  grp = 'WT';
   when(pb eq 1)  grp = 'PB';
   when (mt eq 1 and pb eq .)  grp = 'MT';
end;
keep hhid grp;
run;

proc freq data=attr.con_grps;
table grp;
run;


proc sort data=attr.data_201112;
by hhid;
run;

proc sql;
create table a as select count(hhid) as hhs from attr.data_201112;
quit;

data accts_dec_con;
merge attr.data_201112_new (in=a ) attr.con_grps (in=b);
by hhid;
if a and b;
run;

data accts_dec_con_clean;
set accts_dec_con;
where ptype in ('DDA','SAV','MMS','TDA','IRA') and substr(stype,1,1) eq 'R';
run;

proc tabulate data=accts_dec_con_clean missing;
class grp ptype status;
var bal;
table status, ptype ALL, grp*(bal*sum*f=dollar24. bal*N*f=comma12.1) / nocellmerge;
run;

proc tabulate data=accts_dec_con_clean missing;
class grp ptype status;
var bal;
table status*ptype ALL, grp*(bal*sum*f=dollar24. bal*N*f=comma12.1) / nocellmerge;
run;

proc tabulate data=accts_dec_con_clean missing;
class sbu ptype grp;
var bal;
table sbu*ptype ALL, grp*(bal*sum*f=dollar24. bal*N*f=comma12.1) / nocellmerge;
run;

proc freq data=accts_dec_con_clean;
table ptype*sbu;
run;

/* These dec numbers match datamart */

proc sort data=accts_dec_con_clean;
by acct;
run;


data temp1;
merge accts_dec_con_clean (in=a keep=hhid acct grp) attr.data_201201 (in=b keep=acct hhid rename=(hhid=hhid_jan ));
by acct;
if a and b;
run;

data temp2;
set temp1;
drop acct;
run;

proc sort data=temp2;
by hhid_jan;
run;

proc sort data=attr.data_201201;
by hhid;
run;

data jan_accts;
merge attr.data_201201 (in=a rename=(hhid=hhid_jan)) temp2 (in=b);
by hhid_jan;
run;

data jan_accts_clean;
set jan_accts;
where ptype in ('DDA','SAV','MMS','TDA','IRA') and substr(stype,1,1) eq 'R';
run;


proc tabulate data=jan_accts_clean missing;
class grp ptype;
var bal;
table ptype ALL, grp*(bal*sum*f=dollar24.) / nocellmerge;
run;
 /*these numbers seem in line to me */




* read masked data and append it to acct file, also append status ;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Validate Attrition\masked.txt';

data masked;
length acct $ 28 status $ 1;
infile myfile dlm='09'x dsd lrecl=4096;
input acct $ status $ masked;
run;

proc freq data=masked;
table status / missing;
run;

proc sort data=masked;
by acct;
run;

proc sort data=attr.data_201112;
by acct;
run;

data attr.data_201112;
merge attr.data_201112 (in=a) masked (in=b);
by acct;
if a;
run;

proc sort data=
