LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';



proc sort data=BBSEG.HHDATA_NEW;
by HHID;
run;

proc sort data=BBSEG.CLUSTERS_NEW;
by HHID;
run;

data tempx;
merge BBSEG.HHDATA_NEW (IN=A) BBSEG.CLUSTERS_NEW (IN=B);
by HHID;
if A and B;
run;

data BBSEG.HHDATA_NEW;
set tempx;
run;



