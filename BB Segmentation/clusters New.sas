LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Clusters.txt';

data BBSEG.Clusters;
Infile myfile DLM='09'x firstobs=2 lrecl=4096;
length HHID $ 9;
Input HHID $ Cluster;
run;

proc contents data=BBSEG.Clusters;
run;





filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\error HH.txt';

data BBSEG.Errors;
Infile myfile DLM='09'x firstobs=1 lrecl=4096;
length HHID $ 9;
Input HHID $;
run;

proc sort data=BBSEG.Errors;
by HHID;
run;


data temp1;
merge BBSEG.CLusters(IN=A) BBSEG.Errors(IN=B);
by HHID;
if A and B;
run;

/* here I am getting teh cluster records not on error file*/
data BBSEG.CLusters_Clean;
merge BBSEG.CLusters(IN=A) BBSEG.Errors(IN=B);
by HHID;
if A and not B;
run;

/* create temp dataset for analysis with the prod data and tran data  and clusters so I can check the clusters*/

proc sort data=BBSEG.PROD_DATA_CLEAN;
by HHID;
run;

proc sort data=BBSEG.Clusters_Clean;
by HHID;
run;

proc sort data=BBSEG.TRDATA_CLEAN;
by hhid;
run;


Data temp;
merge BBSEG.PROD_DATA_CLEAN (IN=A) BBSEG.TRDATA_CLEAN (IN=B) BBSEG.Clusters_Clean (IN=C);
DEP_AMT = SUM(DDA_AMT, MMS_AMT, SAV_AMT, TDA_AMT, IRA_AMT);
LOAN_AMT = SUM ( BALOC_AMT, BOLOC_AMT, CLN_AMT, CLS_AMT, MTG_AMT, HEQB_AMT, CARD_AMT);
DEB_TR = SUM ( MPOS_TR, VPOS_TR);
DEb_AMT = SUM ( MPOS_AMT, VPOS_AMT);
TRANS = SUM (MPOS_TR, VPOS_TR , CKDEP, CHKPD, RCD_VOL, OTH_ATM_TR, MT_ATM_TR ,WEb_TR);
by HHID;
IF A and B;
run;


proc freq data=temp;
tables cluster / missing nocol norow nopercent;
run;

/* I need to do some work to determine if the clusters look clean, basically look for outliers and such*/

proc sort data=temp;
by cluster;
run;

proc means data=temp;
class Cluster;
var DEp_AMT LOAN_AMT DEb_TR DEb_AMT;
format DEp_AMT dollar8.2;
run;




proc means data=temp_chart;
where cluster =1 and loan_amt lt 0;
var DEp_AMT LOAN_AMT DEb_TR DEb_AMT;
run;

proc means data=temp_chart;
where cluster =1 and loan_amt lt 0;
var DEp_AMT LOAN_AMT DEb_TR DEb_AMT;
run;

proc means data=temp_chart;
where cluster =4 and deb_tr = .;
var DEp_AMT LOAN_AMT DEb_TR DEb_AMT;
run;

proc means data=temp_chart;
where cluster =1 and loan_amt lt 0 and dep_amt lt 0;
var DEp_AMT LOAN_AMT DEb_TR DEb_AMT;
run;


%let var = trans;

proc rank data=temp out=order groups=20;
	var &var;
	ranks rank;
	
run;


proc sort data=order;
by Rank;
run;


proc tabulate data=order ;
class rank;
var &var;
tables rank, &var * (N SUM MIN MAX MEAN);
run;

proc freq data=temp_chart ;
where cluster eq 4 and deb_tr eq 0;
tables  deb_tr / missing;
run;

/*Below I assign new clusters as the old ones appear to not be great - especially 4*/

Data temp_new;
set temp;
if (dep_amt ge 45000 and trans gt 150) or (loan_amt ge 150000 and trans gt 150) then do;
cluster_new = 1;
shape = "balloon";
end;
else if dep_amt ge 45000 then do;
cluster_new = 2;
shape = "cross";
end;
else if loan_amt ge 150000 then do;
cluster_new = 3;
shape = "diamond";
end;
else if deb_tr ge 30 then do;
cluster_new = 4;
shape = "square";
end;
else if dep_amt lt 2000 and loan_amt lt 10000 then do;
cluster_new = 6;
shape = "star";
end;
else do;
cluster_new = 5;
shape = "flag";
end;

run;

/*
data tempx;
set temp_new;

if cluster = 1 then do;
shape_1 = "balloon";
end;
if cluster = 2 then do;
shape_1 = "cross";
end;

if cluster = 3 then do;
shape_1 = "diamond";
end;

if cluster = 4 then do;
shape_1 = "square";
end;

if cluster = 5 then do;
shape_1 = "flag";
end;

if cluster = 6 then do;
shape_1 = "star";
end;

if cluster = . then do;
shape_1 = "";
end;

run;
*/



proc freq data=temp_new;
tables cluster_new;
run;

proc means data=temp_new;
class Cluster_new;
var DEp_AMT LOAN_AMT TRANS DEb_TR DEb_AMT;
format DEp_AMT dollar8.2;
run;


proc sort data=temp_new;
by cluster_new;
run;




proc g3d data=temp_new;
where cluster eq 4 ;
 scatter dep_amt*loan_amt=deb_tr/
      shape=shape
      noneedle;
run;

proc gplot data=temp_new;
plot cluster_new*trans;
plot cluster_new*dep_Amt;
plot cluster_new*loan_amt;
plot cluster_new*deb_tr;
run;

proc freq data=temp_new;
tables sales_band*sales_new / nocol norow nopercent;
run;


proc contents data=bbseg.hhdata_new varnum short;
run;

/* single service */

data bbseg.hhdata_new;
set bbseg.hhdata_new;
prods = sum(min(DDA,1) ,min(MMS,1), min(SAV,1), min(TDA,1), min(IRA,1), min(MTG,1), min(HEQB,1), min(CLN,1), min(CARD,1), min(BOLOC,1), min(BALOC,1), min(CLS,1), min(MCC,1));
run;
 
proc freq data=bbseg.hhdata_new;
table prods / nocum missing;
run;

data temp;
set bbseg.hhdata_new;
if dda ge 1 then dda = 1;
if sav ge 1 then sav = 1;
if tda ge 1 then tda = 1;
if mms ge 1 then mms = 1;
if mtg ge 1 then mtg = 1;
if heqb ge 1 then heqb = 1;
if cln ge 1 then cln = 1;
if cls ge 1 then cls = 1;
if card ge 1 then card = 1;
if baloc ge 1 then baloc = 1;
if boloc ge 1 then boloc = 1;
if ira ge 1 then ira = 1;
if mcc ge 1 then mcc = 1;
prods = dda +sav +tda +ira +mms +mtg +heqb +cln +cls +card +baloc+ boloc+  mcc;
keep hhid dda sav tda ira mms mtg heqb cln cls card baloc boloc  mcc prods;
run;

proc freq data=temp;
table prods / nocum missing;
run;

proc tabulate data=temp out=results;
class dda sav tda ira mms mtg heqb cln cls card baloc boloc  mcc;
table (dda sav tda mms mtg heqb cln cls card baloc boloc mcc),(dda sav tda mms mtg heqb cln cls card baloc boloc mcc);
run;


proc freq data=bbseg.hhdata_for_clustering;
table prods / nocum missing;
run;

data bbseg.hhdata_for_clustering;
set bbseg.hhdata_for_clustering;
prods = sum(dda,sav,tda,mms,ira,mtg,heqb,cln,cls,card,baloc,boloc,mcc);
run;
