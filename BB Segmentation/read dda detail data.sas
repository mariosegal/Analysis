filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\BBACCT.txt';


Data BBSEG.DDA_DATA ;
length HHID $ 9 Title1 $ 50 Title2 $ 40 Title3 $ 40 Title4 $ 40 STYPE $ 3;
Infile myfile DLM='09'x firstobs=2 lrecl=4096 ;
Input HHID $ 
STYPE $
BAL_PRIME
BAL_CONTR
CONTRIB_AMT
Title1 $ 
Title2 $ 
Title3 $
Title4 $;
run;

proc setinit;
run;

