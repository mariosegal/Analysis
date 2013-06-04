LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';
OPTIONS FMTSEARCH=(BBSEG WORK);

data temp;
set bbseg.hhdata_new;
where sales ge 7000000 and (cbr ne '');
keep hhid sales ;
run;

data temp1;
set bbseg.baltimore_master bbseg.buffalo_master;
keep hhid;
run;

proc sort data=temp1;
by hhid;
run;

proc sort data=temp;
by hhid;
run;

proc sort data=bbseg.addresses;
by hhid;
run;

data temp3;
merge temp (in=a) temp1 (in=b);
by hhid;
if a and not b;
run;

data temp4;
merge temp3(in=a) bbseg.addresses (in=b);
by hhid;
if a and b;
run;

data temp5;
merge temp4 (in=a) temp (in=b);
by hhid;
if a and b;
run;


libname myxls oledb init_string="Provider=Microsoft.ACE.OLEDB.12.0;
Data Source=C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\Additional List 20120131.xls;
Extended Properties=Excel 12.0";
data myxls.list;
   set temp5;
 run;
libname myxls clear;
