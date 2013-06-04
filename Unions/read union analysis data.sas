options fmtsearch=(SAS);

options MSTORED SASMSTORE = mjstore;
libname mjstore 'C:\Documents and Settings\ewnym5s\My Documents\SAS\Macros';

Data temp;
length HHID $ 9 Title1 $ 50 Title2 $ 40 Title3 $ 40 Title4 $ 40 ptype $ 3 stype $ 3 sbu $ 3 key $ 40;
Infile 'C:\Documents and Settings\ewnym5s\My Documents\unionsep.txt' DLM='09'x firstobs=1 lrecl=4096 missover obs=max;
Input HHID $ key $ ptype $ stype $ sbu $ title1 $ title2 $ title3 $ title4 $ sic4 $ sic $ source $;
run;

options compress=yes;
%squeeze(temp, union.Accts_201209);

