*1. Read data on ATM Usagem, decemebr 2012 by typ eof ATM using a special tag on card_tran table in datamart;

filename datafile 'C:\Documents and Settings\ewnym5s\My Documents\rutters.TXT';

data ATM.Dec_12_rutters;
length hhid $ 9;
infile datafile dsd dlm='09'x lrecl=4096 firstobs=2 missover;
input hhid $ rutters_num branch1_num other1_num rutters_amt branch1_amt other1_amt;
run;

options compress=yes;
data data.main_201212;
retain miss miss1;
merge  data.main_201212 (in=left) ATM.Dec_12_rutters (in=right) end=eof;
by hhid;
if left;
if left and not right then miss+1;
if not left and right then miss1+1;
if eof then do;
	if miss ge 1 then  do ; put 'WARNING: There were ' miss " Records on the 'left' file that were not found on the 'right' file"; end;
	if miss1 ge 1 then do; put 'WARNING: There were ' miss1 " Records on the 'right' file that were not found on the 'left' file"; end;
end;
drop miss:;
run;


*check if logical;
proc freq data=data.main_201212;
table atmo_num*(rutters_num branch_num other_num) / missing nocol norow nopercent;
run;

    * great. no issues where my total pre-existing counts are less than in any of the new ones;

proc sql ;
/*select hhid from  data.main_201212 where sum(rutters_num, branch1_num, other1_num) gt atmo_num;*/
select count(*) from  data.main_201212 where sum(rutters_num, branch1_num, other1_num) gt atmo_num;
quit;
   *also no problem when I add, no rows returned;

*3. create the groups for analysis:
		Sheetz Only
		Sheetz and Other M&T (Branch or partner)
		Branch Only
		Other Partner and Branch
	    Other partner only
	    No ATM;

proc format;
value rutters 
	1 = 'Rutters Only'
	2 = 'Rutters and Any Other'
	3 = 'Branch Only'
	4 = 'Other Partner and Branch'
	5 = 'Other Partner Only'
	6 = 'No ATM';
run;

data data.main_201212;
set data.main_201212;
	if rutters_num ge 1 then do;
		if branch1_num in (0,.) and other1_num in (0,.) then rutters_group = 1;
		if branch1_num ge 1 or other1_num ge 1 then rutters_group = 2;
	end;
	else do;
		if branch1_num ge 1 and other1_num in (0,.) then rutters_group = 3;
		if branch1_num ge 1 and other1_num ge 1 then rutters_group = 4;
		if branch1_num in (0,.) and other1_num ge 1 then rutters_group = 5;
		if branch1_num in (0,.) and other1_num in (0,.) then rutters_group = 6;
	end;
 ;
run;

proc freq data=data.main_201212;
table rutters_group;
/*table atm_group*(sheetz_num branch_num other_num);*/
run;

proc freq data=data.main_201212;
table atm_group*rutters_group;
/*table atm_group*(sheetz_num branch_num other_num);*/
run;


proc freq data=data.main_201212;
table sheetz_num branch_num other_num;
run;

proc format ;
value quick 1-high = 'yes'
            other = 'no';
run;


proc tabulate data=data.main_201212;
where dda eq 1 ;
class atmo_num atm_group dda;
table atm_group all,atmo_num*N*f=comma12.;
format atmo_num quick.;
run;

*all looks decent, shocked that less 50% of people use our ATMs;

*4. Now I will do some histograms of the ATM volume;

proc contents data=data.main_201212 varnum short;
run;

%null_to_zero(source=data.main_201212,destination=data.main_201212,
               variables=sheetz_num branch_num other_num sheetz_amt branch_amt other_amt  non_sheetz_num  
               rutters_num rutters_amt branch1_num other1_num branch1_amt other1_amt )


%penetration(class1=rutters_group,fmt1=rutters,where=dda eq 1,period=201212,out=)

%contribution(class1=rutters_group,fmt1=rutters,where=dda eq 1,period=201212,out=)

%segments(class1=rutters_group,fmt1=rutters,where=dda eq 1,period=201212,out=)

%demographics(class1=rutters_group,fmt1=rutters,where=dda eq 1,period=201212,out=)

;

*dataset for R;
options compress=yes;
data wip.rutters;
set data.main_201212;
where dda eq 1 ;
keep rutters_num branch1_num other1_num atmo_num rutters_group non_rutters_num;
run;


proc sgplot data=data.main_201212;
where dda eq 1 and atm_group eq 1;
histogram sheetz_num branch_num other_num;
run;
/**/
/*proc sgplot data=data.main_201212;*/
/*  histogram sheetz_num / fillattrs=graphdata1 name='s' legendlabel='Sheetz' */
/*                       transparency=0.7 nbins=10  showbins; */
/*  histogram branch_num / fillattrs=graphdata2 name='b' legendlabel='Branch' */
/*                       transparency=0.7  nbins=10 showbins; */
/*  histogram other_num / fillattrs=graphdata2 name='o' legendlabel='Other' */
/*                       transparency=0.7  nbins=10showbins; */
/*  keylegend 's' 'b' 'o' / location=inside position=topright across=1;*/
/*/*  xaxis display=(nolabel);*/*/
/*  run;*/


  proc sgplot data=data.main_201212;
  vbox sheetz_num / category = atm_group; 
/*  vbox branch_num / category = atm_group; */
/*  xaxis display=(nolabel);*/
  run;



proc sgplot data=data.main_201212;
  histogram sheetz_num / fillattrs=graphdata1 name='s' legendlabel='Systolic' transparency=0.5;
  histogram branch_num / fillattrs=graphdata2 name='d' legendlabel='Diastolic' transparency=0.5;
  keylegend 's' 'd' / location=inside position=topright across=1;
  xaxis display=(nolabel);
  run;




*How dependent they are on Sheetz;
data data.main_201212;
set data.main_201212;
non_rutters_num = sum(other1_num,branch1_num);
run;




proc format;
value bins (notsorted) 
        0 = 'Zero'
		1 = '1'
		2 = '2'
		3 = '3'
		4 = '4'
		5 ='5'
		6-9 = '6 to 9'
		10-14 = '10 to 14'
		15-19 = '15 to 19'
		20-high = '20+';
		run;


proc freq data=data.main_201212 ;
where dda eq 1;
table non_rutters_num*rutters_num / missing out=data nocol norow nopercent;
format non_rutters_num rutters_num bins.;
run;

ODS GRAPHICS / RESET IMAGENAME = 'Usage' IMAGEFMT =JPEG  
   HEIGHT = 5in WIDTH = 8.5in;
Title ;
proc sgplot data=data NOAUTOLEGEND ;
where rutters_num ne 0 ;
bubble x=non_rutters_num y=rutters_num size=count / bradiusmin = 3 fillattrs=(Color=cx007856);
lineparm x=0 y=0 slope=1 / lineattrs=(Color=cxFFB300);
xaxis DISCRETEORDER=DATA VALUES=(0 1 2 3 4 5 6 10 15 20) label="ATM Withdrawals at Other M&T ATMs" LABELATTRS=(Weight=BOLD);
yaxis label="ATM Withdrawals at Rutters M&T ATMs" LABELATTRS=(Weight=BOLD) DISCRETEORDER=DATA VALUES=( 1 2 3 4 5 6 10 15 20);
format non_Sheetz_num sheetz_num bins. count comma12.;
run;

proc freq data=data ;
table non_rutters_num*rutters_num / list;
run;

proc sql;
select sum(count) from data where rutters_num eq non_rutters_num and rutters_num ge 1;
select  sum(count) from data where rutters_num gt non_rutters_num and rutters_num ge 1;
select  sum(count) from data where rutters_num lt non_rutters_num and non_rutters_num ge 1 and rutters_num ge 1;
select  sum(count) from data where rutters_num ge 1;
quit;


proc means data=data sum ;
where sheetz_num ne 0 ;
var count;
run;


*where are those that are sheetz only;

proc tabulate data=data.main_201212 order=freq;
where rutters_group eq 1;
class state zip;
table state*zip, N colpctN;
run;



*how to do a bar chart with the dispersion;
*1. create data;

options compress=yes;
data wip.products;
set data.main_201212;
where dda eq 1 ;
keep hhid rutters_group dda_amt mms_amt sav_amt tda_amt ira_amt sec_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt
     dda mms sav tda ira sec mtg heq iln ind card;
run;



data wip.products;
retain miss;
merge wip.products (in=left) data.contrib_201212 (in=right drop=STATE ZIP BRANCH CBR MARKET band band_yr rename=(contrib=contrib_mtd)) end=eof;
by hhid;
if left then output;
if left and not right then miss+1;
if eof then put 'WARNING: Records on left not found on right = ' miss;
drop miss;
run;



data wip.products;
set wip.products;
	if not dda then dda_amt = .;
	if not mms then mms_amt = .;
	if not sav then sav_amt = .;
	if not tda then tda_amt = .;
	if not ira then ira_amt = .;
	if not sec then sec_amt = .;
	if not mtg then mtg_amt = .;
	if not heq then heq_amt = .;
	if not iln then iln_amt = .;
	if not ind then ind_amt = .;
	if not card then ccs_amt = .;
	products = sum(dda,mms,sav,tda,ira,mtg,heq,sec,card,iln,ind);
run;



*2. I need to convert it to long here, as melt runs out of memory in R;

data wip.products1 (keep=product balance contrib rutters_group);
set wip.products ;
	product = 1;
	balance = dda_amt;
	contrib = dda_con;
	output;
	product = 2;
	balance = mms_amt;
	contrib = mms_con;
	output;
	product = 3;
	balance = sav_amt;
	contrib = sav_con;
	output;
	product = 4;
	balance = tda_amt;
	contrib = tda_con;
	output;
	product = 5;
	balance = ira_amt;
	contrib = ira_con;
	output;
	product = 6;
	balance = sec_amt;
	contrib = sec_con;
	output;
	product = 7;
	balance = mtg_amt;
	contrib = mtg_con;
	output;
	product = 8;
	balance = heq_amt;
	contrib = heq_con;
	output;
	product = 9;
	balance = ccs_amt;
	contrib = card_con;
	output;
	product = 10;
	balance = iln_amt;
	contrib = iln_con;
	output;
	product = 11;
	balance = ind_amt;
	contrib = ind_con;
	output;
run;

proc format ;
value prods (notsorted)
	1 = 'Checking'
	2 = 'Money Mkt'
	3 = 'Savings'
	4 = 'Time Dep'
	5 = 'IRAs'
	6='Securities'
	7='Mortgage'
	8='Home Eq'
	9='Credit Card'
	10='Dir. Loan'
	11='Ind. Loan';
run;


proc sgplot data=wip.products1 (where=rutters_group ne 6));
   vbox balance / nooutliers category=product group=rutters_group ;
   xaxis label="Product";
   keylegend / title="ATM Group";
   yaxis label='Average Balance' min=0 max=200000;
   format balance dollar12. rutters_group rutters. product prods.;
run; 


proc sgpanel data=wip.products1 (where=(atm_group ne 6));
panelby product;
   vbox balance / nooutliers  group=rutters_group ;
 

   format balance dollar12. atm_group sheetz. product prods.;
run; 

proc means data=wip.products1 mean q1 median q3 min max;
class rutters_group product;
var balance;
output out=out1;
format balance dollar12. rutters_group rutters. product prods.;
run;

*generate numbers for super average chart;
proc tabulate data=wip.products1 missing;
where rutters_group ne 6;
class product rutters_group;
var balance;
table balance*(q1 qrange median mean)*f=comma12.2, product*rutters_group / nocellnmerge;
format balance dollar12. rutters_group rutters. product prods.;
run;


proc tabulate data=wip.products1 missing;
where rutters_group ne 6;
class product rutters_group;
var contrib ;
table contrib*(q1 qrange median mean)*f=comma12.2, product*rutters_group / nocellmerge;
format contrib dollar12. rutters_group rutters. product prods. products comma12.1;
run;



proc tabulate data=wip.products missing;
where rutters_group ne 6;
class rutters_group;
var contrib_mtd products;
table contrib_mtd*(q1 qrange median mean)*f=comma12.2, rutters_group / nocellmerge;
table products*(q1 qrange median mean)*f=comma12.2, rutters_group / nocellmerge;
format contrib_mtd dollar12. rutters_group rutters. products comma12.1;
run;

proc sgpanel data=data.main_201212 ;
where dda eq 1 and rutters_num in(1,2);
panelby rutters_group /  columns=1 onepanel uniscale= all;
histogram rutters_num / scale = percent;
run;

axis1 label=none order=(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);


proc gplot data=data.main_201212 (obs=1000 where=(dda eq 1 and rutters_group in(1,2)));
plot rutters_group / haxis=axis1;
run;


proc print data=data.main_201212 (obs=10 where=(sheetz_num ne 0));
var hhid rutters_group rutters_num;
run;


data test;
set data.main_201212;
where (dda eq 1 and rutters_group ne 6) ;
keep hhid rutters_num rutters_group ;
run;

proc export data=test
outfile='C:\Documents and Settings\ewnym5s\My Documents\rutters.xlsx' dbms=excel;
run;

*percent of usage;

data temp;
set data.main_201212;
where rutters_group in (1,2);
pct = rutters_num/(rutters_num+non_rutters_num);
keep hhid rutters_group rutters_num non_rutters_num pct zip;
format pct percent6.1;
run;


data temp1; 
set temp;
select (rutters_group);
	when(1)  pct1 = pct;
	when(2)  pct2 = pct;
	when(3)  pct3 = pct;
	when(4)  pct4 = pct;
	when(5)  pct5 = pct;
end;
run;

proc sort data=temp1;
by zip;
run;

proc summary data=temp1;
where rutters_group eq 1;
by zip;
output out=temp2 N(pct)=count;
run;


proc summary data=temp1;
where rutters_group eq 2 and pct2 ne . and pct2 lt 0.34;
by zip;
output out=low N(pct)=count;
run;

proc summary data=temp1;
where rutters_group eq 2 and pct2 ge 0.34 and pct2 lt .67;
by zip;
output out=med N(pct)=count;
run;


proc summary data=temp1;
where rutters_group eq 2 and pct2 ge 0.67;
by zip;
output out=hi N(pct)=count;
run;

proc summary data=temp1;
where rutters_group eq 2;
by zip;
output out=temp3 N(pct)=count;
run;


proc export data=temp2 outfile='C:\Documents and Settings\ewnym5s\My Documents\ATM\ruttersONLY.xlsx' dbms=excel replace;
run;

proc export data=temp3 outfile='C:\Documents and Settings\ewnym5s\My Documents\ATM\ruttersOTHER.xlsx' dbms=excel replace;
run;
 
proc export data=temp1 outfile='C:\Documents and Settings\ewnym5s\My Documents\rutterspct.xlsx' dbms=excel replace;
run;

proc export data=low outfile='C:\Documents and Settings\ewnym5s\My Documents\ATM\lowrutters.xlsx' dbms=excel replace;
run;

proc export data=med outfile='C:\Documents and Settings\ewnym5s\My Documents\ATM\medrutters.xlsx' dbms=excel replace;
run;

proc export data=hi outfile='C:\Documents and Settings\ewnym5s\My Documents\ATM\highrutters.xlsx' dbms=excel replace;
run;

ods html mtbhtml;
proc sgplot data=temp1;
histogram pct1 / name = '1' legendlabel="Rutters Only" fill nooutline transparency=.7;
histogram pct2 / name = '2' legendlabel="Rutters and Any Other" fill nooutline transparency=.7;
/*histogram pct3 / name = '3' legendlabel="Branch Only" fill nooutline transparency=.7;*/
/*histogram pct4 / name = '4' legendlabel="Other Partner and Branch" fill nooutline transparency=.7;*/
/*histogram pct5 / name = '5' legendlabel="Other Partner Only" fill nooutline transparency=.7;*/
format pct: percent6.1;
run;


proc freq data=data.main_201212;
table rutters_group*tran_code / missing nocol nopercent nofreq;
format   tran_code $transegm. rutters_group rutters.;
run;

proc freq data=data.main_201212;
table rutters_group*tenure_yr*tran_code / missing norow nopercent nocol;
format tenure_yr tenureband.  tran_code $transegm. rutters_group rutters.;
run;


proc freq data=data.main_201212;
table rutters_group*tenure_yr / missing norow nopercent nocol;
format tenure_yr tenureband.  tran_code $transegm. rutters_group rutters.;
run;
