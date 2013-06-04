LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';
OPTIONS FMTSEARCH=(BBSEG WORK);

/*filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Tr2011.txt';*/

/*Data BBSEG.PRODUCTS2011;*/
/*length HHID $ 9 KEY $ 30 status $ 1 ptype $ 3 stype $ 3 sbu $ 5;*/
/*Infile myfile DLM='09'x firstobs=2 lrecl=4096;*/
/*Input HHID $*/
/*	  DBYEAR*/
/*	  DBMONTH*/
/*	  KEY $*/
/*	  DATE_OPEN :MMDDYY.*/
/*	  STATUS $*/
/*	  PTYPE $*/
/*	  STYPE $*/
/*	  SBU $;*/
/*format date_open date11.;*/
/*run;*/

/*proc freq data=bbseg.products2010;*/
/*tables SBU / nocol norow nopercent;*/
/*run;*/

/*proc freq data=bbseg.products2010 order=freq;*/
/*where (ptype IN ('DDA','MMS','SAV','TDA','IRA') and SBU eq 'BUS' and SUBSTR(STYPE,1,1) eq 'C') or (not (ptype IN ('DDA','MMS','SAV','TDA','IRA'))  and SBU eq 'BUS') ;*/
/*tables ptype / nocol norow nopercent;*/
/*run;*/

/* add order */

/*proc sort data=BBSEG.PRODUCTS2011;*/
/*by ptype;*/
/*run;*/

/*proc sort data=bbseg.ptype_order;*/
/*by ptype;*/
/*run;*/

data tempx;
merge BBSEG.PRODUCTS2010 (where=((SBU eq 'BUS' and STATUS ne 'X') and (stype ne 'OBG'))in=a) bbseg.ptype_order (in=b);
by ptype;
if a;
run;




proc sort data=tempx;
by HHID date_open Order ;
run;

/*proc rank data=tempx out=tempx_ranked ties=low;*/
/*by hhid;*/
/*var hhid;*/
/*ranks rank1;*/
/*run;*/

/* rank did not work */

data tempx_ranked; 
set tempx;
by hhid; 
if first.hhid then seq_id=1;
else seq_id+1;
run;

data weird_hh (keep=hhid);
set tempx_ranked (where=(seq_id=1 and (ptype in ('DEB','ATM','WEB','HBK'))));
run;

data tempx_ranked_new_2010;
merge tempx_ranked (in=a) weird_hh (in=b);
by hhid;
if a and not b;
run;

data bbseg.product_data_combined_clean;
set tempx_ranked_new_2010 tempx_ranked_new_2011;
run;


 /*do analysis by product and order */

proc tabulate data=bbseg.product_data_combined_clean order=freq; 
class seq_id ptype;
tables  seq_id*N, ptype  ;
run;



/*proc freq data=tempx_ranked order=freq;*/
/*where seq_id = 1;*/
/*tables ptype;*/
/*run;*/


/*###########################################################################################################*/
/* do analysis for second products given a specific Nth product */

%let product= 'DDA';
%let prod1 = DDA;
%let num= 1;
%let num1 = first;




data temp_hh;
set tempz1; /* from below, it uses only first 9 months to allow for some maturity */
where  ptype=&product and seq_id=&num;
keep HHID;
run;


data temp;
merge tempz1 (in=a) temp_hh (in=b);
by HHID;
if b;
run;

proc tabulate data=temp order=freq out=work.results_order_first_&prod1;
class seq_id ptype;
tables  seq_id*N, ptype ;
run;

libname myxls oledb init_string="Provider=Microsoft.ACE.OLEDB.12.0;
Data Source=C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\temp.xls;
Extended Properties=Excel 12.0";
data myxls.first_&prod1;
   set work.results_order_first_&prod1 (drop= _TYPE_ _PAGE_ _TABLE_);
 run;
 data myxls.first_CLN;
   set work.results_order_first_CLN (drop= _TYPE_ _PAGE_ _TABLE_);
 run;
libname myxls clear;

/*###########################################################################################################*/
/* analysis for third product */

%let p1a= 'MMS';
%let p1b = MMS;
%let p2a= 'MMS';
%let p2b = MMS;
%let num1= 1;
%let num2 = 2;
%let numa = first;
%let numb = second;



data temp_hh;
set tempx_ranked_new;
where    (ptype eq &p1a and seq_id eq &num1);
keep HHID;
run;

data temp_hh1;
set tempx_ranked_new;
where (ptype eq &p2a and seq_id eq &num2);
keep HHID;
run;

data temp;
merge tempx_ranked_new (in=a) temp_hh (in=b) temp_hh1 (in=c);
by HHID;
if b and c;
run;

proc tabulate data=temp order=freq out=work.results_order_&p1b&p2b;
class seq_id ptype;
tables  seq_id*N, ptype ;
run;

libname myxls oledb init_string="Provider=Microsoft.ACE.OLEDB.12.0;
Data Source=C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Product Order Analysis.xls;
Extended Properties=Excel 12.0";

data myxls.SECOND_&p1b&p2b;
   set work.results_order_&p1b&p2b (drop= _TYPE_ _PAGE_ _TABLE_);
 run;

libname myxls clear;

/*###########################################################################################################*/

data tempz;
set bbseg.product_data_combined_clean;
where (seq_id =1 and dbmonth le 6 and dbyear eq 2011) or (seq_id=1 and dbyear = 2010);
keep hhid;
run;

proc sort data= tempz;
by hhid;
run;

proc sort data=bbseg.product_data_combined_clean;
by hhid;
run;

data tempz1;
merge tempz (in=a) bbseg.product_data_combined_clean (in=b);
by hhid;
if a and b;
run;

proc tabulate data=tempz1 order=freq; 
class seq_id ptype;
tables  seq_id*N, ptype  ;
run;

data tempZ2; 
set tempz1;
length path $ 50 ;
retain path count;
by hhid; 
if first.hhid then do;
	count = 1;
	path=ptype;
end;
else do;
	if count le 10 then do;
		a=path;
    	path=cats(a,'/',ptype);
	end;
	count=count+1;
end;
drop a count;
run;


data bbseg.product_paths;
set tempz2;
by hhid;
if last.hhid then output;
keep hhid path;
run;


proc freq data=bbseg.product_paths order=freq;
table path / out = bbseg.top_paths;
run;

data tempq ;
set bbseg.top_paths (obs = 100);
run;

proc print data=tempq;
where count ge 10;
var path count;
run;

proc freq data=tempz1;
where dbmonth=12 and seq_id=1;
table dbmonth*dbyear;
run;
