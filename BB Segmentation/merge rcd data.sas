/* Merge with the dataset I created with the RCD volumes 

1. Read the dataset, it is excel
2. sort the dataset, and the main data file
3. merge them into a new super file
4. if file look sright, rename it

*/






DATA work.rcddata;
infile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\rcddata.csv' dlm=',';
input HHID $ RCD_VOL;
run;


proc sort data=work.rcddata;
by HHID;
run;

proc sort data=BBSEG.HHDATA
out = work.hhdatatemp;
by HHID;
run;

data BBSEG.HHDATA_NEW;
	merge work.hhdatatemp work.rcddata;
	by HHID;
run;

LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';


