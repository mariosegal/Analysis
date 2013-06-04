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

data temp_chart;
set temp (where= (cluster ne .));
keep HHID Cluster DEp_AMT LOAN_AMT DEB_TR deb_AMT;
if cluster=1 then do;
color = blue;
end;
if cluster=2 then do;
color = blue;
end;
run;

proc gplot data=temp_chart;
by cluster;
plot dep_amt*loan_amt;
run;

libname myxls oledb init_string="Provider=Microsoft.ACE.OLEDB.12.0;
Data Source=C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Clusters.xls;
Extended Properties=Excel 12.0";

data myxls.MGD;
   set temp_chart;
  run;

  libname myxls clear;

  proc g3d data=temp_Chart;

 scatter dep_amt*loan_amt*deb_tr/
      color=color
      noneedle
run;
