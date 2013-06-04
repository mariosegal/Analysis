filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\BBAUX.txt';




Data BBSEG.HHDATA_EXTRA;
length HHID $ 9 Score_Month $ 1 Score_Yr $ 1;
Infile myfile DLM='09'x firstobs=2 lrecl=4096;
Input HHID $
	  Score_Month $
	  Score_Yr$
	  Contrib_AMT;
run;
