LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\BBADDR.txt';


Data BBSEG.HHDATA_ADDRESSES;
length HHID $ 9 Title1 $ 50 Title2 $ 40 Title3 $ 40 Title4 $ 40 Addr1 $ 40 Addr2 $ 40 Addr3 $ 40 S_Add1 $ 40 S_Add2 $ 40 City $ 40 State $ 2 ZIP5 $ 5 ZIP4 $ 4 PH1 $ 10 PH2 $ 10;
Infile myfile DLM='09'x firstobs=2 lrecl=4096;
Input HHID $ 
Title1 $ 
Title2 $ 
Title3 $
Title4 $
Addr1 $ 
Addr2 $
Addr3 $
Rank
S_Add1 $ 
S_Add2 $ 
City $ 
State $ 
ZIP5 $
ZIP4 $
CBR $
Market $
PH1 $
PH2 $;
run;


proc sort data=BBSEG.HHDATA_ADDRESSES;
by HHID;

proc sort data=BBSEG.HHDATA_NEW;
by HHID;
run;

data temp;
merge BBSEG.HHDATA_NEW (keep=HHID IN=A) 
      BBSEG.HHDATA_ADDRESSES(IN=B);
by HHID;
if A and B;
run;


data temp_a;
merge BBSEG.HHDATA_NEW (keep=HHID IN=A) 
      BBSEG.HHDATA_ADDRESSES(IN=B);
by HHID;
if B and not A;
run;

data BBSEG.ADDRESSES;
set temp;
run;

data BBSEG.ADDRESSES_EXTRA;
set temp_A;
run;
