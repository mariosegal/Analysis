LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

/* read new file with all accts */
/*filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Union.txt';*/
/**/
/*Data BBSEG.ACCTS_DEC2011;*/
/*length HHID $ 9 KEY $ 30 ptype $ 3 stype $ 3 sbu $ 5 Title1-Title4 $ 40 SIC4 $ 4 SIC $ 8 SOURCE $ 4;*/
/*Infile myfile DLM='09'x firstobs=2 lrecl=4096;*/
/*Input HHID $*/
/*	  KEY $*/
/*	  PTYPE $*/
/*	  STYPE $*/
/*	  SBU $*/
/*	  TITLE1 $*/
/*	  TITLE2 $*/
/*	  TITLE3 $*/
/*	  TITLE4 $*/
/*	  SIC4 $*/
/*	  SIC $*/
/*	  SOURCE $;*/
/*run;*/




data temp;
length name_str $ 175;
set BBSEG.ACCTS_DEC2011;
name_str = catx(" ",Title1,Title2,Title3,Title4);
keep hhid name_str SIC4 SIC key;
run;

Data BBSEG.UNION_ACCTS_BYTEXT;
set temp;
array words{7} $ 15 _temporary_  ('BROTHERHD' 'BROTHERHOOD' 'BHOOD' 'LOCAL' 'LCL' 'UNION' 'GUILD');
/*array tags{6} 3 flag1-flag7;*/

do i=1 to 6;
	do j = i+1 to 7;
		if find(name_str,words{i},'it') ge 1 and find(name_str,words{j},'it') then do;
			tag = 1;
			OUTPUT;
		end;
	end;
end;
drop i j;
run;

proc sort data=BBSEG.UNION_ACCTS_BYTEXT;
by hhid;
run;

data temphh;
set BBSEG.UNION_ACCTS_BYTEXT;
by HHID;
if first.hhid then output;
run;



/*COUNT BY SIC */
Data BBSEG.UNION_ACCTS_BYSIC;
set temp;
where SIC eq '8631' or sic4 eq '8631';
run;

proc sort data=BBSEG.UNION_ACCTS_BYSIC;
by hhid;
run;

data temphh1;
set BBSEG.UNION_ACCTS_BYSIC;
by HHID;
if first.hhid then output;
run;


data merged;
merge temphh (in=a) temphh1(in=b);
by hhid;
if a and b then do;
	type = 'both';
end;
else if a and not b then do;
	type = 'text';
end;
else if not a and b then do;
	type = 'SICS';
end;
else if not a and not b then do;
	type = 'XXXX';
end;
run;

proc freq data=merged;
table type;
run;

proc sort data=BBSEG.UNION_ACCTS_BYTEXT;
by key;
run;

proc sort data=BBSEG.UNION_ACCTS_BYSIC;
by key;
run;

data BBSEG.UNION_ACCTS_ALL;
merge BBSEG.UNION_ACCTS_BYSIC (in=a) BBSEG.UNION_ACCTS_BYTEXT (in=b);
by key;
run;

proc sort data=BBSEG.ACCTS_DEC2011;
by key;
run;

data products;
merge  BBSEG.UNION_ACCTS_ALL (in=a) BBSEG.ACCTS_DEC2011(in=b drop=sic sic4 title:);
if a and b;
by key;
run;


proc freq data=products order=freq;
table ptype;
run;

/*proc transpose data=products out=prod_table;*/
/*by HHID;*/
/*var ptype;*/
/**/
/*run;*/

proc sort data=products;
by hhid;
run;

data prod_table ;
set products;
by HHID;
retain dda sav mms tda cln cls trs sec ccs iln;
if first.hhid then do;
	dda = 0;
	mms = 0;
	sav = 0;
	tda = 0;
	iln = 0;
	cln = 0;
	cls = 0;
	sec = 0;
	ccs = 0;
	trs=0;
end;
select (ptype);
	when ('DDA') dda=1;
	when ('SAV') sav=1;
	when ('MMS') mms=1;
	when ('TDA') tda=1;
	when ('CLN') cln=1;
	when ('CLS') cls=1;
	when ('TRS') trs=1;
	when ('SEC') sec=1;
	when ('CCS') ccs=1;
	when ('ILN') iln=1;
	otherwise other=1;
end;
if last.hhid then output;
drop ptype stype sic sic4 tag sbu source other;
run;

PROC tabulate data=prod_table;
var  dda mms sav tda iln cln cls ccs sec trs;
table (SUM N),(dda mms sav tda iln cln cls ccs sec trs);
run;

/*#####################################################################################*/
proc sort data=BBSEG.ACCTS_DEC2011;
by hhid;
run;

proc sort data=merged;
by hhid;
run;


data products_hh;
merge merged (in=a keep=hhid) BBSEG.ACCTS_DEC2011 (in=b);
by hhid;
if a and b;
run;

proc freq data=products_hh order=freq;
table ptype;
run;

proc print data=products_hh;
where PTYPE = 'INS';
run;

data prod_table_hh ;
set products_hh;
by HHID;
retain dda sav mms tda cln cls trs sec ccs iln ins;
if first.hhid then do;
	dda = 0;
	mms = 0;
	sav = 0;
	tda = 0;
	iln = 0;
	cln = 0;
	cls = 0;
	sec = 0;
	ccs = 0;
	trs=0;
	ins = 0;
end;
select (ptype);
	when ('DDA') dda=1;
	when ('SAV') sav=1;
	when ('MMS') mms=1;
	when ('TDA') tda=1;
	when ('CLN') cln=1;
	when ('CLS') cls=1;
	when ('TRS') trs=1;
	when ('SEC') sec=1;
	when ('CCS') ccs=1;
	when ('ILN') iln=1;
	when ('INS') ins=1;
	otherwise other=1;
end;
if last.hhid then output;
drop ptype stype sic sic4  sbu source other;
run;

PROC tabulate data=prod_table_hh;
var  dda mms sav tda iln cln cls ccs sec trs ins;
table (SUM N),(dda mms sav tda iln cln cls ccs sec trs ins);
run;
/*#####################################################################################*/


Data bbseg.UNIONS_SUMMARy;
set BBSEG.DDA_DATA_UNIONS;
array a{6} flag:;
array b{6} 3 _temporary_; ;
by HHID;

	if first.hhid then do;
		do i = 1 to 6;
			b{i}=0;
		end;
	end;
	do i = 1 to 6;
		b{i} = max(b{i},a{i});
	end;
	if last.hhid then do;
		do i = 1 to 6;
			a{i}=b{i};
		end;
		IF SUM(OF A{*}) GE 1 THEN output;
	end;
drop i;
run;

/* MINE THE WORDS ON THE Titles FOUBND */
data wordbag_UNIONS;
length word $ 30;
set bbseg.products ;
myflag=0;
do i=1 to 100 while (myflag=0);
	word = scan(upcase(name_str),i," ,");
	if (word ne ''  and length(trim(word)) ge 2) then do;
		output;
	end;
	else do;
	    myflag=1;
	end;
end;
keep word;
run;

proc freq data=wordbag_UNIONS order=freq;
table word / out=BBSEG.word_counts_UNIONS;
run;


proc print data=BBSEG.ACCTS_DEC2011 ;
where PTYPE = 'INS' and find(upcase(catx(" ",title1,title2,title3,title4)),'LOCAL','it');
run;

data tempx;
set bbseg.products;
by hhid;
if first.hhid then output;
run;

proc sort data=tempx;
by name_str;
run;

