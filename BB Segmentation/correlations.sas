LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

OPTIONS FMTSEARCH=(BBSEG WORK);

%LET ANALYSIS_VAR = Band;

proc sort data=BBSEG.HHDATA_for_clustering;
by &ANALYSIS_VAR;
run;



Proc corr data=BBSEG.HHDATA_for_clustering pearson outp=outp(type=corr);
with CONTRIB_AMT;
RUN;
