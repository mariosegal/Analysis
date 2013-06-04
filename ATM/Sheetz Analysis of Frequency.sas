data Branch.Sheetz_Trans;
length HHID $ 9 type $ 8 card_type $ 3 ptype $ 3 channel $ 8;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ATM\Sheetz.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input hhid $ channel $ atmid type $ tran_num tran_amt branch card_type $  ptype $ bin ;
run;

data Branch.ATMO_Trans;
length atmid1 $ 10 HHID $ 9 type $ 8 card_type $ 3 ptype $ 3 channel $ 8;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ATM\ATMO.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input hhid $ channel $ atmid1 $ type $ tran_num tran_amt branch card_type $  ptype $ bin ;
run;

proc freq data=Branch.Sheetz_Trans;
table channel atmid type branch card_type ptype bin;
run;
 

proc tabulate data=Branch.Sheetz_Trans out=branch.sheetz_summary missing;
class atmid type ;
var tran_num tran_amt;
table atmid*type,  N sum*(tran_num*f=comma12. tran_amt*f=dollar24.) / nocellmerge;
run;

data branch.atm_groups;
length group $ 8;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ATM\coords.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input atmid group $ branch lat long;
run;

proc freq data=branch.atm_groups;
where lat eq . and long eq .;
table group;
run;

proc sort data=Branch.ATMO_Trans;
by atmid;
run;

proc sort data=branch.atm_groups;
by atmid;
run;

/*
data Branch.ATMO_Trans;
merge Branch.ATMO_Trans (in=a) branch.atm_groups (in=b drop=branch);
by atmid;
if a;
run;
*/

proc freq data=test;
where lat eq .;
table atmid;
run;

proc sort data=Branch.ATMO_Trans;
by atmid1;
run;

proc sort data=Branch.ATM_groups;
by atmid;
run;

data Branch.ATMO_Trans;
length atmid 8;
set Branch.ATMO_Trans;
atmid = atmid1;
run;

proc freq data=test_a;
table group;
run;


data Branch.ATMO_Trans;
merge Branch.ATMO_Trans (in=a) Branch.ATM_groups (in=b keep=atmid group );
by atmid;
if a;
run;


proc sort data=Branch.ATMO_Trans;
by hhid;
run;

proc summary data=Branch.ATMO_Trans;
where group = 'STZ' and type = 'WDRAL';
output out=sheetz_trans (rename=(_freq_=stz_ATMs) drop=_type_)
       sum(tran_num) = stz_num
	   sum(tran_amt) = stz_amt;
by hhid;
run;

proc summary data=Branch.ATMO_Trans;
where type = 'WDRAL';
output out=all_trans (rename=(_freq_=all_ATMs) drop=_type_)
       sum(tran_num) = all_num
	   sum(tran_amt) = all_amt;
by hhid;
run;

data merged;
merge all_trans(in=a) sheetz_trans (in=b);
by hhid;
if a;
run;

data merged;
set merged;
if stz_Atms eq . then stz_atms = 0;
if stz_num eq . then stz_num = 0;
if stz_amt eq . then stz_amt = 0;
atm_p = divide(stz_atms,all_atms);
num_p = divide(stz_num,all_num);
amt_p = divide(stz_amt,all_amt);
run;

* check the distribution for each, use a % format in 10% groups;
* do a 3D scatter see if anything comes up;
proc format library=sas;
value  pctdecile (notsorted) 0-.1 = '0-10%' 
                           .1<-.2 = '10<-20%'
						   .2<-.3 = '20<-30%'
						   .3<-.4 = '30<-40%'
						   .4<-.5 = '40<-50%'
						   .5<-.6 = '50<-60%'
						   .6<-.7 = '60<-70%'
						   .7<-.8 = '70<-80%'
						   .8<-.9 = '80<-90%'
						   .9<-1 = '90<-100%';
run;



Title 'All HHs - % of Sheetz ATM Usage';
proc freq data=merged;
table atm_p num_p amt_p;
format atm_p num_p amt_p pctdecile.;
run;

Title 'Sheetz HHs - % of Sheetz ATM Usage';
proc freq data=merged;
where stz_num ge 1;
table atm_p num_p amt_p;
format atm_p num_p amt_p pctdecile.;
run;

proc g3d data=merged;
where stz_num ge 1;
plot atm_p*num_p=amt_p;
scatter atm_p*num_p=amt_p/noneedle ;
format atm_p num_p amt_p pctdecile.;
run;
quit;

proc fastclus data=merged (where=(stz_num ge 1)) out=clust1 maxclusters=5 maxiter=0;
var atm_p num_p amt_p;
run;

proc sort data=clust1;
by cluster;
run;

data chartdata;
set clust1;
color = put(cluster,mycolor.);
run;

proc g3d data=chartdata ;
scatter  atm_p*num_p=amt_p/ noneedle color=color;
format atm_p num_p amt_p pctdecile.;
run;
quit;

data branch.atm_groups_pam;
length atmid1 $ 10;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ATM\Open ATMs.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input atmid1 $ zip $ long lat cost_center;
run;


proc freq data=Branch.ATMO_Trans;
table atmid1 / out=atmid missing;
run;

proc print data=nolist noobs;
var atmid1;
run;


proc sort data=branch.atm_groups_pam;
by atmid1;
run;


data match notran nolist;
merge atmid(in=a) branch.atm_groups_pam(in=b);
by atmid1;
if a and b then output match;
if a and not b then output nolist;
if not a and b then output notran;
run;



*#################################################################################################;

data temp_sheetz;
merge data.main_201206 (in=a ) sheetz_trans (in=b) all_trans (in=c);
by hhid;
if a;
run;

data temp_sheetz;
set temp_sheetz;
stz_pct = divide (stz_num, all_num);
run;

proc freq data=temp_sheetz;
table stz_pct;
format stz_pct pctdecile.;
run;


proc freq data=temp_sheetz;
table stz_pct*atmt_num / nocol norow nopercent missing;
format stz_pct pctdecile. atmt_num trans.;
run;

data _null_;
file 'C:\Documents and Settings\ewnym5s\My Documents\ATM\stz_atm.txt' dsd dlm='09'x;
set branch.atm_groups;
where group = 'STZ';
put atmid lat long;
run;

data _null_;
file 'C:\Documents and Settings\ewnym5s\My Documents\ATM\non_stz_atm.txt' dsd dlm='09'x;
set branch.atm_groups;
where group ne 'STZ';
put atmid lat long;
run;


proc freq data=temp_sheetz;
where stz_pct gt .9;
table cbr / missing;
format cbr cbr2012fmt.;
run;

data mostly_sheetz;
set temp_sheetz (keep = hhid stz_pct hh zip);
where stz_pct gt .9;
run;

proc freq data=mostly_sheetz order=freq;
table zip / out=mostly_sheetz_zips;
run;



proc freq data=temp_sheetz order=freq;
where stz_num ge 1;
table zip / out=sheetz_zips;
run;

data _null_;
file 'C:\Documents and Settings\ewnym5s\My Documents\ATM\sheetz_zips_primary.txt' dsd dlm='09'x;
set mostly_sheetz_zips;
put zip count;
run;

data _null_;
file 'C:\Documents and Settings\ewnym5s\My Documents\ATM\sheetz_zips_all.txt' dsd dlm='09'x;
set sheetz_zips;
put zip count;
run;
