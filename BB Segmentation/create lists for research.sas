LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';


filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\BALT ZIPS.txt';

Data BBSEG.BALT;
length ZIP $ 5 Name $ 50 State $ 2 ;
Infile myfile dsd DLM='09'x firstobs=1 lrecl=4096;
Input ZIP $ Name $ State $ FIPS_ST;
run;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Buffalo ZIPS.txt';

Data BBSEG.BUFF;
length ZIP $ 5 Name $ 50 State $ 2;
Infile myfile dsd DLM='09'x firstobs=1 lrecl=4096;
Input ZIP $ Name $ State $ FIPS_ST;
run;


proc sort data=bbseg.addresses;
by hhid;
run;

proc sort data=bbseg.hhdata_new;
by hhid;
run;

proc sort data=clusters;
by hhid;
run;


DATA tempq;
merge bbseg.addresses (IN = A) bbseg.hhdata_new (IN = B keep=HHID target_new sic_int sic_ext tenure_band) clusters (IN=C);
by HHID;
if A and B and C;
run;

data tempx;
set tempq;
length sic $ 4;
if sic_ext ne . then do; 
sic = substr(sic_ext,1,4);
end;
else if sic_int ne . then do;
sic = sic_int;
end;
else do;
sic = sic_ext;
end;
run;

data BBSEG.ADDRESsES;
set tempx;
run;





proc sort data = BBSEG.ADDRESSES;
by ZIP5;
run;

proc sort data = BBSEG.BUFF;
by ZIP;
run;


data BBSEG.BUFFALO_MASTER;
merge BBSEG.ADDRESSES (IN=A rename=(ZIP5 =ZIP)) BBSEG.BUFF (IN = B keep=ZIP);
by ZIP;
if A and B;
run;



proc sort data = BBSEG.BALT;
by ZIP;
run;


data BBSEG.BALTIMORE_MASTER;
merge BBSEG.ADDRESSES (IN=A rename=(ZIP5 =ZIP)) BBSEG.BALT (IN = B keep=ZIP);
by ZIP;
if A and B;
run;

proc freq data=BBSEG.BUFFALO_MASTER ;
tables cluster_new*target_new / nocol norow nopercent;
run;

proc freq data=BBSEG.BALTIMORE_MASTER;
tables cluster_new*target_new / nocol norow nopercent;
run;


proc freq data=clusters;
tables cluster_new / norow nocol nopercent;
run;



/* Merge teh 2 lists with the analysis data to create lists for analysis*/

proc sort data=bbseg.prod_data_clean;
by hhid;
run;

proc sort data=bbseg.trdata_clean;
by hhid;
run;

proc sort data=bbseg.Buffalo_master;
by hhid;
run;


proc sort data=bbseg.Baltimore_master;
by hhid;
run;

data bbseg.Buffalo_Analysis;
merge bbseg.Buffalo_master (in=a keep=HHID) bbseg.prod_data_clean (in=B) bbseg.trdata_clean(in=c);
by HHID;
if A and B and C;
run;

data bbseg.Baltimore_Analysis;
merge bbseg.Baltimore_master (in=a keep=HHID) bbseg.prod_data_clean (in=B) bbseg.trdata_clean(in=c);
by HHID;
if A and B and C;
run;


proc contents data=bbseg.baltimore_master;
run;

proc contents data=bbseg.buffalo_master;
run;


proc export data=bbseg.baltimore_master outfile='C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Baltimore.txt' DBMS=TAB;

proc export data=bbseg.buffalo_master outfile='C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Buffalo.txt' DBMS=TAB;


/* create an additional file with the sales band by HH */




libname myxls oledb init_string="Provider=Microsoft.ACE.OLEDB.12.0;
Data Source=C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Sales_bands.xls;
Extended Properties=Excel 12.0";
data temp;
set bbseg.baltimore_analysis (keep=hhid sales_band);
run;

data myxls.Baltimore;
   set temp;
  run;

data temp;
set bbseg.buffalo_analysis (keep=hhid sales_band);
run;

data myxls.Buffalo;
   set temp;
  run;

libname myxls clear;

/* export data to excel */

libname myxls oledb init_string="Provider=Microsoft.ACE.OLEDB.12.0;
Data Source=C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\BB Survey Analysis Data 20120104.xls;
Extended Properties=Excel 12.0";

data myxls.Baltimore;
   set bbseg.baltimore_analysis;
  run;

  
data myxls.Buffalo;
   set bbseg.buffalo_analysis;
  run;

 

  libname myxls clear;
