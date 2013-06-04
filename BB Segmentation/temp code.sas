
/*
LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';


proc format;
value  flags 0  = 'N'
			 1 - high  = 'Y';
run;

proc format;
value balances 			
			low -< 0 = 'less than Zero'
	        0 = 'zero'
			0 <- 5000 = 'Up to $5M'
			5000 <- 10000 = '5M to 10M'
			10000 <- 25000 = '10M to 25M'
			25000 <- 50000 = '25M to 50M'
			50000 <- 100000 = '50M to 100M'
			100000 <- 250000 = '100M to 250M'
			250000 <- 500000 = '250M to 500M'
			500000 <- 1000000 = '500M to 1MM'
			1000000 <- high = 'Over 1MM';
run;


proc sort data=BBSEG.HHDATA
	out=work.data (keep= HHID DDA_AMT MMS_AMT SAV_AMT TDA_AMT CLN_AMT CLS_AMT HEQB_AMT HEQC_AMT BALOC_AMT BOLOC_AMT MTG_AMT TARGET);
	by TARGET ;
run;

*/

/* This part creates the freq tables as desired, for each product into temp files'*/

PROC FREQ DATA=work.data	
	ORDER=INTERNAL;
	TABLES TARGET*(DDA_AMT) /  out=WORK.Results_DDA;
	TABLES TARGET*(MMS_AMT) /  out=WORK.Results_MMS;
	TABLES TARGET*(SAV_AMT) /  out=WORK.Results_SAV;
	TABLES TARGET*(TDA_AMT) /  out=WORK.Results_TDA;
	TABLES TARGET*(CLN_AMT) /  out=WORK.Results_CLN;
	TABLES TARGET*(CLS_AMT) /  out=WORK.Results_CLS;
	TABLES TARGET*(BALOC_AMT) /  out=WORK.Results_BALOC;
	TABLES TARGET*(BOLOC_AMT) /  out=WORK.Results_BOLOC;
	TABLES TARGET*(MTG_AMT) /  out=WORK.Results_MTG;
	TABLES TARGET*(HEQB_AMT) /  out=WORK.Results_HEQB;
	TABLES TARGET*(HEQC_AMT) /  out=WORK.Results_HEQC;
	FORMAT DDA_AMT  MMS_AMT SAV_AMT TDA_AMT CLN_AMT CLS_AMT HEQB_AMT HEQC_AMT BALOC_AMT BOLOC_AMT MTG_AMT balances.;

RUN;
/* this adds the variables I want from DDA results to the result macro table*/


data WORK.FREQS(drop=DDA_AMT TARGET PERCENT COUNT);
	set WORK.Results_DDA;
	Product = "DDA";
	Segment = TARGET;
	Band = DDA_AMT;
	NUM = COUNT;
	format BAND Balances.;
run;

/*Now I need to merge a the next table, seems easier to create a temp one, them merge (Append) it below the first one*/


data work.temp (drop=MMS_AMT TARGET PERCENT COUNT);
set Work.Results_MMS;
	Product = "MMS";
	Segment = TARGET;
	Band = MMS_AMT;
	NUM = COUNT;
	format BAND Balances.;
run;

Proc append base=WORK.FREQS
	data=work.temp;
run;

data work.temp (drop=SAV_AMT TARGET PERCENT COUNT);
set Work.Results_SAV;
	Product = "SAV";
	Segment = TARGET;
	Band = SAV_AMT;
	NUM = COUNT;
	format BAND Balances.;
run;

Proc append base=WORK.FREQS
	data=work.temp;
run;

Data work.temp (drop=TDA_AMT TARGET PERCENT COUNT);
set Work.Results_TDA;
	Product = "TDA";
	Segment = TARGET;
	Band = TDA_AMT;
	NUM = COUNT;
	format BAND Balances.;
run;

Proc append base=WORK.FREQS
	data=work.temp;
run;

data work.temp (drop=MTG_AMT TARGET PERCENT COUNT);
set Work.Results_MTG;
	Product = "MTG";
	Segment = TARGET;
	Band = MTG_AMT;
	NUM = COUNT;
	format BAND Balances.;
run;

Proc append base=WORK.FREQS
	data=work.temp;
run;

data work.temp (drop=CLN_AMT TARGET PERCENT COUNT);
set Work.Results_CLN;
	Product = "CLN";
	Segment = TARGET;
	Band = CLN_AMT;
	NUM = COUNT;
	format BAND Balances.;
run;

Proc append base=WORK.FREQS
	data=work.temp;
run;

data work.temp (drop=CLS_AMT TARGET PERCENT COUNT);
set Work.Results_CLS;
	Product = "CLS";
	Segment = TARGET;
	Band = CLS_AMT;
	NUM = COUNT;
	format BAND Balances.;
run;

Proc append base=WORK.FREQS
	data=work.temp;
run;

data work.temp (drop=BALOC_AMT TARGET PERCENT COUNT);
set Work.Results_BALOC;
	Product = "BAL";
	Segment = TARGET;
	Band = BALOC_AMT;
	NUM = COUNT;
	format BAND Balances.;
run;

Proc append base=WORK.FREQS
	data=work.temp;
run;

data work.temp (drop=BOLOC_AMT TARGET PERCENT COUNT);
set Work.Results_BOLOC;
	Product = "BOL";
	Segment = TARGET;
	Band = BOLOC_AMT;
	NUM = COUNT;
	format BAND Balances.;
run;

Proc append base=WORK.FREQS
	data=work.temp;
run;

data work.temp (drop=HEQB_AMT TARGET PERCENT COUNT);
set Work.Results_HEQB;
	Product = "HEB";
	Segment = TARGET;
	Band = HEQB_AMT;
	NUM = COUNT;
	format BAND Balances.;
run;

Proc append base=WORK.FREQS
	data=work.temp;
run;


data work.temp (drop=HEQC_AMT TARGET PERCENT COUNT);
set Work.Results_HEQC;
	Product = "HEC";
	Segment = TARGET;
	Band = HEQC_AMT;
	NUM = COUNT;
	format BAND Balances.;
run;

Proc append base=WORK.FREQS
	data=work.temp;
run;











/*proc freq data=work.sort;
	format DDA flags.;
	tables DDA;
	
run;

ods pdf file="C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\HHDATA Contents";

proc contents data=BBSEG.HHDATA;
run;

ods pdf close;*/

proc contents data=work.Results_DDA;
run;
