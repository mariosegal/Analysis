*Read dda acct detauils, manipulate it and append flags required for analysis;

data data.dda_201206;
length hhid $ 9 stype $ 3;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Data\ddajun12.txt' dsd dlm='09'x lrecl=4096 firstobs=1;
input hhid $ stype $ open_date :mmddyy10.;
run;

data x;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Data\XDDA0410.TXT' dsd dlm='09'x lrecl=4096 firstobs=1;
input hhid $;
nodda_apr10 = 1;
if hhid eq '' then delete;
run;


data data.dda_201206;
length dda_grp $ 7;
set data.dda_201206;
Select (stype);
	when ('RE5' ,'RE7')  dda_grp = 'Free';
	when ('RC6')  dda_grp = 'College';
	when ('RH2', 'RW2' ,'RH5' ,'RH3' ,'RH6')  dda_grp = 'Premium';
	otherwise dda_grp='Other';
end;
run;

proc sort data=data.dda_201206;
by hhid dda_grp;
run;

proc freq data=data.dda_201206;
table dda_grp;
run;


proc summary data=data.dda_201206;
by hhid dda_grp;
output out=dda_summary;
run;

proc transpose data=dda_summary out=dda_summary1;
by hhid;
var _freq_;
id dda_grp;
run;

data dda_summary2;
set dda_summary1;
if free gt 1 then free = 1;
if premium gt 1 then premium = 1;
if other gt 1 then other = 1;
if college gt 1 then college = 1;
count=sum(free,premium,other,college);
if count gt 2 then do;
	Multi1=1;
	free1=0;
	other1=0;
	premium1=0;
	college1=0;
end;
if count le 2 then do;
	free1=free;
	other1=other;
	premium1=premium;
	college1=college;
	multi1=0;
end;
run;

proc summary data=data.dda_201206;
by hhid ;
output out=dda_tenure min(open_date)=oldest_dda;
run;

proc sql;
alter table data.main_201206
drop dda_grp, Other, Free, Premium, College, dda_count, oldest_dda, nodda_apr10;
quit;

/*data data.main_201206;*/
/*set data.main_201206;*/
/*drop dda_grp Other Free Premium College dda_count oldest_dda nodda_apr10;*/
/*run;*/

data data.main_201206  ;
merge  data.main_201206 (in=a) dda_summary2 (in=b drop=count _name_) dda_tenure (in=c drop=_type_ rename=(_freq_=dda_count)) x(in=d);
by hhid;
if a ;
run;
 

data wip.dda_analysis;
set data.main_201206 (keep = hhid other free premium college dda_count nodda_apr10 hh dda dda_amt other1 free1 premium1 college1 multi1 dda_2008 dda_2011);
where dda eq 1;
groups = sum(other, free, premium, college);
if premium=. then premium=0;
if premium1=. then premium1=0;
if free=. then free=0;
if free1=. then free1=0;
if college=. then college=0;
if college1=. then college1=0;
if other=. then other=0;
if other1=. then other1=0;
run;

proc freq data=dda_analysis;
table dda*dda_count / missing;
run;

*##############################################################################################################################;
*import and append the codes for 2008 and 2011 HHs;

data ddA_2008;
length hhid $ 9 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Deposits\2008.txt' dsd dlm='09'x lrecl=4096 firstobs=1;
input hhid $ ;
dda_2008 =1;
run;

data ddA_2011;
length hhid $ 9 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\dEPOSITS\2011.txt' dsd dlm='09'x lrecl=4096 firstobs=1;
input hhid $ ;
dda_2011 =1;
run;

proc sql;
alter table data.main_201206
drop dda_2008, dda_2011;
quit;

data data.main_201206;
merge data.main_201206 (in=a) ddA_2008 (in=b) ddA_2011 (in=c);
by hhid;
if a;
run;

proc freq data=wip.dda_analysis;
table dda_2008*dda_2011 / missing;
run;


*##############################################################################################################################;
*set condition to the flag that defines the group;
ods html style=newfonts;
%let condition1 = dda_2008 ne 1 and dda_2011 eq 1;
%let flag = dda_2011;
Title "Analysis for &condition1";
Title2 'Diagonal';
proc tabulate data=wip.dda_analysis missing out=diagonal style=[font_size=1 cellheight=25];
where groups eq 1 and &condition1;
class other free premium college other1 free1 premium1 college1 multi1 /style=[font_size=1 cellheight=25];
var hh /style=[font_size=1 cellheight=25];
table  (free college premium  other)*hh*sum*f=comma12. /nocellmerge style=[font_size=1 cellheight=25] ;
/*keylabel sum='Sum' / style=[font_size=1 cellheight=25];*/
run;

data diagonal_clean;
length y $ 8 x $ 8;
set diagonal;
where sum(free, other , premium, college) eq 1 ;
drop  _page_ _table_ _type_;
if free eq 1 then y='Free';
if other eq 1 then y='Other';
if premium eq 1 then y='Premium';
if college eq 1 then y='College';
if free eq 1 then x='Free';
if other eq 1 then x='Other';
if premium eq 1 then x='Premium';
if college eq 1 then x='College';
Multi=0;
run;

Title2 'Matrix for 2 group HHs';
proc tabulate data=wip.dda_analysis missing out=two_group;
where groups eq 2 and &condition1;
class other free premium college other1 free1 premium1 college1 multi1;
var hh;
table  (free college premium  other),(free1 college1 premium1  other1)*hh*sum*f=comma12. /nocellmerge;
run;

data two_group_clean;
length y $ 8 x $ 8;
set two_group;
where (free eq 1 and sum (premium1 , other1 , college1) eq 1) or (premium eq 1and sum (free1, other1, college1) eq 1) or
      (other eq 1 and sum(premium1, free1, college1) eq 1) or (college eq 1 and sum(free1, other1, premium1) eq 1);
drop  _page_ _table_ _type_;
if free eq 1 then y='Free';
if other eq 1 then y='Other';
if premium eq 1 then y='Premium';
if college eq 1 then y='College';
if free1 eq 1 then x='Free';
if other1 eq 1 then x='Other';
if premium1 eq 1 then x='Premium';
if college1 eq 1 then x='College';
Multi=0;
run;

/*Title2 'Multi HHs';*/
/*proc tabulate data=wip.dda_analysis missing out=multi;*/
/*where groups gt 2;*/
/*class other free premium college other1 free1 premium1 college1 multi1;*/
/*var hh;*/
/*table  (free college premium  other),(multi1)*hh*sum*f=comma12. ;*/
/*run;*/
/**/
/*data multi_clean;*/
/*length y $ 8 x $ 8;*/
/*set multi;*/
/*where sum(free, other , premium, college) eq 1 ;*/
/*drop  _page_ _table_ _type_;*/
/*if free eq 1 then y='Free';*/
/*if other eq 1 then y='Other';*/
/*if premium eq 1 then y='Premium';*/
/*if college eq 1 then y='College';*/
/*x='Multi';*/
/*rename Multi1=Multi;*/
/*run;*/

Title2 'Multi HHs';
proc tabulate data=wip.dda_analysis missing out=multi;
where groups gt 2 and &condition1;
var hh;
table sum*hh*f=comma12./nocellmerge;
run;


Title2 'most common combinations for multi';
proc tabulate data=wip.dda_analysis missing out=multi order=freq;
where groups gt 2 and &condition1;
class free premium college other;
var hh;
table free*college*premium*other,hh*(sum*f=comma12. pctsum*f=pctpic.)/ nocellmerge;
run;


data combined;
set diagonal_clean  two_group_clean;
run;


proc format;
value $ order (notsorted) 'Free' = 'Free'
				'College' = 'College'
				'Premium' = 'Premium'
				'Other' = 'Other'
				'Multi' = 'Multi';
run;

Title2 'Combined Matrix, Ns';
proc tabulate data=combined missing order=data;
class y x /preloadfmt  ;
var hh_sum;
table (Y='HH has Accounts of Type:' All),
      (x='And also has Accounts of Type:' ALL)*hh_sum*(sum='Count of HHs'*f=comma12. )/ nocellmerge;
format y x $order.;
run;

proc sql;
select sum(Free), sum(college), sum(premium), sum(other) into :free,   :college,   :premium,   :other from wip.dda_analysis where &condition1;
quit;

data combined;
set combined;
pct1 = hh_sum / symget(y);
run;

Title2 "Row Percentages &flag";
proc tabulate data=combined missing order=data;
class y x /preloadfmt  ;
var pct1;
table (Y='HH has Accounts of Type:' All),
      (x='And also has Accounts of Type:' ALL)*pct1*(sum='Row% of HHs'*f=percent8. )/ nocellmerge;
format y x $order. ;
run;




Title2 'Total HHs by Product';
proc tabulate data=wip.dda_analysis missing out=multi order=freq;
where &condition1;
var free premium college other;
table sum*(free premium college other)*f=comma12./nocellmerge;
run;


*gET DETAIL ON NUMBER OF ACCTS OWNED;

proc format;
value quick (notsorted) 1 = 'Single'
            1<-high = 'Multi';
run;



Title2 'Diagonal';
proc tabulate data=wip.dda_analysis missing ;
where groups eq 1 and &condition1;
class other free premium college dda_count / preloadfmt;
var hh ;
table  dda_count*hh*(sum*f=comma12. colpctsum) , (free college premium  other)/nocellmerge;
format dda_count quick.;
run;

proc tabulate data=wip.dda_analysis missing ;
where groups eq 1 and &condition1;
class other free premium college ;
var hh dda_count ;
table  dda_count*mean*f=comma8.2, (free college premium  other)/nocellmerge;
run;


Title2 '2 Types';
proc tabulate data=wip.dda_analysis missing out=two_group_mean;
where groups eq 2 and &condition1;
class other free premium college other1 free1 premium1 college1;
var hh dda_count ;
table (free college premium  other), (free1 college1 premium1 other1)* (hh*sum*f=comma12. dda_count*mean*f=comma8.2)/nocellmerge;
run;

data two_group_mean_clean;
length y $ 8 x $ 8;
set two_group_mean;
where (free eq 1 and sum (premium1 , other1 , college1) eq 1) or (premium eq 1and sum (free1, other1, college1) eq 1) or
      (other eq 1 and sum(premium1, free1, college1) eq 1) or (college eq 1 and sum(free1, other1, premium1) eq 1);
drop  _page_ _table_ _type_;
if free eq 1 then y='Free';
if other eq 1 then y='Other';
if premium eq 1 then y='Premium';
if college eq 1 then y='College';
if free1 eq 1 then x='Free';
if other1 eq 1 then x='Other';
if premium1 eq 1 then x='Premium';
if college1 eq 1 then x='College';
Multi=0;
run;

proc tabulate data=two_group_mean_clean missing order=data;
class y x /preloadfmt  ;
var dda_count_mean;
table (Y='HH has Accounts of Type:' All),
      (x='And also has Accounts of Type:' ALL)*dda_count_mean*(sum='Count of HHs'*f=comma12.2 )/ nocellmerge;
format y x $order.;
run;

Title2 'Multi HHs';
proc tabulate data=wip.dda_analysis missing ;
where groups gt 2 and &condition1;
var dda_count hh;
table dda_count*mean*f=comma8.2 sum='Count of HHs'*hh*f=comma12.2 / nocellmerge;

run;

*###################################################################################################;
*develop codes for profiles;
data codes;
length tag $ 20;
set wip.dda_analysis;
if groups eq 1 then do;
	if free eq 1 then tag = 'Free Only';
	if college eq 1 then tag = 'College Only';
	if premium eq 1 then tag = 'Premium Only';
	if other eq 1 then tag = 'Other Only';
end;
if groups gt 2 then tag = 'Multi';
if groups eq 2 then do;
	if free eq 1 and college eq 1 then tag = 'Free & College';
	if free eq 1 and premium eq 1 then tag = 'Free & Premium';
	if free eq 1 and other eq 1 then tag = 'Free & Other';
	if college eq 1 and premium eq 1 then tag = 'College & Premium';
	if college eq 1 and other eq 1 then tag = 'College & Other';
	if premium eq 1 and other eq 1 then tag = 'Premium & Other';
end;
keep hhid tag;
run;

data codes_new;
length tag_new $ 20;
set wip.dda_analysis;
if groups eq 1 then do;
	if free eq 1 then tag_new = 'Free Only';
	if college eq 1 then tag_new = 'College Only';
	if premium eq 1 then tag_new = 'Premium Only';
	if other eq 1 then tag_new = 'Other Only';
end;
if groups gt 2 then tag_new = 'Multi';
/*if groups eq 2 then do;*/
/*	if free eq 1 and college eq 1 then tag = 'Free & College';*/
/*	if free eq 1 and premium eq 1 then tag = 'Free & Premium';*/
/*	if free eq 1 and other eq 1 then tag = 'Free & Other';*/
/*	if college eq 1 and premium eq 1 then tag = 'College & Premium';*/
/*	if college eq 1 and other eq 1 then tag = 'College & Other';*/
/*	if premium eq 1 and other eq 1 then tag = 'Premium & Other';*/
/*end;*/
keep hhid tag_new;
run;


proc freq data=codes_NEW;
table tag_new / missing;
run;

data data.main_201206;
merge data.main_201206 (in=a) codes_new (in=b);
by hhid;
if a;
run;

proc freq data=data.main_201206;
table tag_new / missing;
run;





filename mprint "C:\Documents and Settings\ewnym5s\My Documents\Deposits\profile_macro.sas" ;
data _null_ ; file mprint ; run ;
options  mprint mfile nomlogic ;

%profile2 (classvars= tag_new ,period = 201206, data_library = data,condition = tag_new ne '', name=checking_group_201206)

filename mprint "C:\Documents and Settings\ewnym5s\My Documents\Deposits\output_macro.sas" ;
data _null_ ; file mprint ; run ;
options  mfile nomlogic ;

%output_profile (library=work,name=chk_types_20121005)
