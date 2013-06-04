*read data;

data prv_0905;
/*length hhid $ 9 acct $ 28 ptype $ 3 stype $ 3;*/
infile 'C:\Documents and Settings\ewnym5s\My Documents\prv0905.txt' lrecl=4096 obs=max;
input @2 hhid $9. @11 acct $28.  @39 ptype $3. @42 stype $3. @45 open_date mmddyy10.;
acq = 1;
format open_date date.;
run;

data prv_1005;
/*length hhid $ 9 acct $ 28 ptype $ 3 stype $ 3;*/
infile 'C:\Documents and Settings\ewnym5s\My Documents\prv1005.txt' lrecl=4096 obs=max;
input @2 hhid $9. @11 acct $28.  @39 ptype1 $3. @42 stype1 $3. @45 open_date1 mmddyy10.;
y1 = 1;
format open_date1 date.;
run;

data wt_1108;
/*length hhid $ 9 acct $ 28 ptype $ 3 stype $ 3;*/
infile 'C:\Documents and Settings\ewnym5s\My Documents\wt1108.txt' lrecl=4096 obs=max;
input @2 hhid $9. @11 acct $28.  @39 ptype $3. @42 stype $3. @45 open_date mmddyy10.;
acq = 1;
format open_date date.;
run;

data wt_1208;
/*length hhid $ 9 acct $ 28 ptype $ 3 stype $ 3;*/
infile 'C:\Documents and Settings\ewnym5s\My Documents\wt1208.txt' lrecl=4096 obs=max;
input @2 hhid $9. @11 acct $28.  @39 ptype1 $3. @42 stype1 $3. @45 open_date1 mmddyy10.;
y1 = 1;
format open_date1 date.;
run;

data mtb_0905;
/*length hhid $ 9 acct $ 28 ptype $ 3 stype $ 3;*/
infile 'C:\Documents and Settings\ewnym5s\My Documents\xprv0905.txt' lrecl=4096 obs=max;
input @2 hhid $9. @11 acct $28.  @39 ptype $3. @42 stype $3. @45 open_date mmddyy10.;
acq = 1;
format open_date date.;
run;

data mtb_1005;
/*length hhid $ 9 acct $ 28 ptype $ 3 stype $ 3;*/
infile 'C:\Documents and Settings\ewnym5s\My Documents\xprv1005.txt' lrecl=4096 obs=max;
input @2 hhid $9. @11 acct $28.  @39 ptype1 $3. @42 stype1 $3. @45 open_date1 mmddyy10.;
y1 = 1;
format open_date1 date.;
run;

data mtb_1108;
/*length hhid $ 9 acct $ 28 ptype $ 3 stype $ 3;*/
infile 'C:\Documents and Settings\ewnym5s\My Documents\xwt1108.txt' lrecl=4096 obs=max;
input @2 hhid $9. @11 acct $28.  @39 ptype $3. @42 stype $3. @45 open_date mmddyy10.;
acq = 1;
format open_date date.;
run;

data mtb_1208;
/*length hhid $ 9 acct $ 28 ptype $ 3 stype $ 3;*/
infile 'C:\Documents and Settings\ewnym5s\My Documents\xwt1208.txt' lrecl=4096 obs=max;
input @2 hhid $9. @11 acct $28.  @39 ptype1 $3. @42 stype1 $3. @45 open_date1 mmddyy10.;
y1 = 1;
format open_date1 date.;
run;

*sort and merge to create analysis dataset, which will be saved;
proc sort data=prv_0905;
by hhid acct;
run;

proc sort data=prv_1005;
by hhid acct;
run;

proc sort data=wt_1108;
by hhid acct;
run;

proc sort data=wt_1208;
by hhid acct;
run;

proc sort data=mtb_0905;
by hhid acct;
run;

proc sort data=mtb_1005;
by hhid acct;
run;

proc sort data=mtb_1108;
by hhid acct;
run;

proc sort data=mtb_1208;
by hhid acct;
run;

data peter.provident;
merge prv_0905 (in=a) prv_1005 (in=b);
by hhid acct;
if acq = 1 and y1=1 then type = 1;
if acq = 1 and y1=. then type = 2;
if acq = . and y1=1 and open_date1 ge '01JUN2009'd then type = 3 ;
if acq = . and y1=1 and open_date1 lt '01JUN2009'd then type = 4 ;
if open_date1 gt '01JUN2010'd or open_date gt '01JUN2011'd then type=5;
run;

data peter.wt;
merge wt_1108 (in=a) wt_1208 (in=b);
by hhid acct;
if acq = 1 and y1=1 then type = 1;
if acq = 1 and y1=. then type = 2;
if acq = . and y1=1 and open_date1 ge '01SEP2011'd then type = 3;
if acq = . and y1=1 and open_date1 lt '01SEP2011'd then type = 4;
if open_date1 gt '01SEP2012'd or open_date gt '01SEP2011'd then type=5;
run;

data peter.mtb_prov;
merge mtb_0905 (in=a) mtb_1005 (in=b);
by hhid acct;
if acq = 1 and y1=1 then type = 1;
if acq = 1 and y1=. then type = 2;
if acq = . and y1=1 and open_date1 ge '01JUN2009'd then type = 3 ;
if acq = . and y1=1 and open_date1 lt '01JUN2009'd then type = 4 ;
if open_date1 gt '01JUN2010'd or open_date gt '01JUN2011'd then type=5;
run;

data peter.mtb_wt;
merge mtb_1108 (in=a)mtb_1208 (in=b);
by hhid acct;
if acq = 1 and y1=1 then type = 1;
if acq = 1 and y1=. then type = 2;
if acq = . and y1=1 and open_date1 ge '01SEP2011'd then type = 3;
if acq = . and y1=1 and open_date1 lt '01SEP2011'd then type = 4;
if open_date1 gt '01SEP2012'd or open_date gt '01SEP2011'd then type=5;
run;


proc format;
value mytype (notsorted) 1 = 'Stay'
                         2 = 'Lost'
						 3 = 'New'
						 4 = 'move'
						 5 = 'xxxx';
run;

proc freq data=peter.provident;
table type;
format type mytype.;
run;

proc freq data=peter.wt;
table type;
format type mytype.;
run;

*this was to check for weird accts opened in the future;

data t1;
set peter.wt;
x=year(open_date1)*100+month(open_date1);
run;

title 'new';
proc freq data=t1;
where type eq 3;
table x*type / missing;
format type mytype.;
run;

data peter.wt;
set peter.wt;
by hhid;
hh=0;
if first.hhid then hh=1;
run;

data peter.provident;
set peter.provident;
by hhid;
hh=0;
if first.hhid then hh=1;
if ptype1 = 'CCS' and stype in ("NOR","REW","SIG") then ptype1 = 'CRD';
run;

data peter.wt;
set peter.wt;
by hhid;
hh=0;
if first.hhid then hh=1;
if ptype1 = 'CCS' and stype in ("NOR","REW","SIG") then ptype1 = 'CRD';
run;

data peter.mtb_prov;
set peter.mtb_prov;
by hhid;
hh=0;
if first.hhid then hh=1;
if ptype1 = 'CCS' and stype in ("NOR","REW","SIG") then ptype1 = 'CRD';
run;

data peter.mtb_wt;
set peter.mtb_wt;
by hhid;
hh=0;
if first.hhid then hh=1;
if ptype1 = 'CCS' and stype in ("NOR","REW","SIG") then ptype1 = 'CRD';
run;

*############################################################################################;
*do the analysis, goals are t see how many new accts were opened and how many closed by PTYPE;

proc format library=sas outcntl=fmt;
select $ptype_sort;
run;

data ptype1_class;
length ptype1 $ 3;
set fmt;
ptype1 = start;
keep ptype1;
run;

data ptype_class;
length ptype $ 3;
set fmt;
ptype = start;
keep ptype;
run;

%let name = mtb_wt;


proc sort data=peter.&name;
by hhid ptype1;
run;

proc summary data=peter.&name;
where type eq 3;
by hhid ptype1 ;
var type;
output 	out=&name._new (drop=_freq_ _type_)
        N(type) = accts;
run;

/*proc transpose data=provident_new out=peter.provident_new (drop=_name_);*/
/*by hhid;*/
/*id ptype1;*/
/*run;*/
/**/
/*data peter.provident_new;*/
/*set peter.provident_new;*/
/*hh=1;*/
/*run;*/

/*proc tabulate data=peter.&name._new out=&name._purchases;*/
/*var DDA DEB SAV WEB ILN MMS TDA CCS HEQ IRA SEC SDB MTG HBK INS TRS ;*/
/*class hh; */
/*table  (hh DDA DEB SAV WEB ILN MMS TDA CCS HEQ IRA SEC SDB MTG HBK INS TRS), hh*N*f=comma12.;*/
/*run;*/

data &name._new;
set &name._new;
hh=1;
run;

proc tabulate data=&name._new out=&name._purchases order=data classdata=ptype1_class;
class ptype1 /preloadfmt;
var hh;
table ptype1*N, hh /nocellmerge;
format ptype1 $ptype_sort.;
run;


proc sql;
select count(distinct hhid) into :&name from peter.&name where acq = 1;
quit;

options mlogic; 

data &name._purchases;
set &name._purchases;
hh_pct = divide(HH_N, &&&name);
run;

Title "HHs that Purchased Prodcut in First Year for &name";
proc print data=&name._purchases noobs;
var ptype1 hh_N hh_pct;
format hh_N comma12. hh_pct percent8.1;
run;
title;

*closed accts;

%let name = mtb_wt;

proc sort data=peter.&name;
by hhid ptype;
run;

proc summary data=peter.&name;
where type eq 2;
by hhid ptype ;
var type;
output 	out=&name._lost (drop=_freq_ _type_)
        N(type) = accts;
run;

data &name._lost;
set &name._lost;
hh=1;
run;

proc tabulate data=&name._lost out=&name._closed order=data classdata=ptype_class;
class ptype /preloadfmt;
var hh;
table ptype*N, hh /nocellmerge;
format ptype $ptype_sort.;
run;



data &name._closed;
set &name._closed;
hh_pct = divide(HH_N, &&&name);
run;

Title "HHs that Closed Prodcut in First Year for &name";
proc print data=&name._closed noobs;
var ptype hh_N hh_pct;
format hh_N comma12. hh_pct percent8.1;
run;
title;
