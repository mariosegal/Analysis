
proc format;
value hudsonseg (notsorted)
   1 = 'Building Their Future'
2 = 'Mainstream Family'
4 = 'Mass Affluent Family'
3 = 'Mainstream Retired'
5 = 'Mass Affluent Retired'
6, . = 'Unable to Code';
run;

data fl;
set hudson.hudson_hh;
where state in ('FL','NJ','CT','NY');
run;

proc sql;
select sum(hh) into :total_fl from fl where state='FL';
select sum(hh) into :total_foot from fl where state ne 'FL';
quit;

data fl;
set fl;

if state = 'FL' then pct = hh/&total_fl;
if state ne 'FL' then pct = hh/&total_foot;
run;

%let N_fl =%sysfunc(putn(&total_fl,comma12.));
%let N_foot =%sysfunc(putn(&total_foot,comma12.));
%put _user_;

proc format;
value $ quick 
	'FL' ="FL Snowbird (N=&N_fl.)"
	other = "NJ/NY/CT (N=&N_foot.)";
run;

/*
proc tabulate data=fl;
class state segment;
var pct;
table state*segment, sum*pct*f=percent6.;
format state $quick. segment hudsonseg.;
run;


ods html style=mtbhtml;

title 'Hudson City Snowbirds Wealth Distribution';
footnote  justify=left height =9pt 'MCD - Customer Insights Analysis';
proc tabulate data=fl order=data missing ;
class adj_tot state / preloadfmt;
table  state,(adj_tot='IXI Wealth Estimate' ALL)* N*f=comma12. (adj_tot='IXI Wealth Estimate' ALL)*rowpctN*f=pctfmt. / MISSTEXT='0.0' nocellmerge;
format adj_tot wltamt. state $quick.;
run;

title 'Hudson City Snowbirds Segment Distribution';
proc tabulate data=fl order=data missing;
class segment / preloadfmt;
var hh;
table segment='Lifecycle Segment' all, hh*sum*f=comma12. hh*colpctsum<hh>*f=pctfmt. / nocellmerge misstext='0';
format segment hudsonseg.;
run;
*/

data fl;
set fl;
label heq1 = 'Home Equity' heq_amt = 'Home Equity';
run;

proc sort data=fl;
by pseudo_hh;
run;


proc transpose daTA=FL out=fl_prods;
BY PSEUDO_HH;
var  dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1;;
run;

data fl_prods;
merge fl_prods (in=a) fl (in=b keep=pseudo_hh state);
by pseudo_hh;
if a;
run;

data fl_prods;
set fl_prods;
if state eq 'FL' then pct=divide(col1,&total_fl);
if state ne 'FL' then pct=divide(col1,&total_foot);
select  (_name_);
	when ('dda1') order=1;
	when ('mms1') order=2;
	when ('sav1') order=3;
	when ('tda1') order=4;
	when ('ira1') order=5;
	when ('mtg1') order=6;
	when ('heq1') order=7;
	when ('iln1') order=8;
end;
run;


proc sort data=fl_prods;
by order;
run;


proc transpose daTA=FL out=fl_bals;
BY PSEUDO_HH;
var dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt;
run;

data fl_bals;
merge fl_bals (in=a) fl (in=b keep=pseudo_hh state);
by pseudo_hh;
if a;
run;

data fl_bals;
set fl_bals;
select  (lowcase(_name_));
	when ('dda_amt') order=1;
	when ('mms_amt') order=2;
	when ('sav_amt') order=3;
	when ('tda_amt') order=4;
	when ('ira_amt') order=5;
	when ('mtg_amt') order=6;
	when ('heq_amt') order=7;
	when ('iln_amt') order=8;
end;
run;

proc sort data=fl_bals;
by order;
run;

/*
title 'Hudson City Snowbirds Product Ownership and Balances';
proc tabulate data=fl order=data missing;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt hh;
table (hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*sum='HHs'*f=comma12./ nocellmerge misstext='0';
table (hh='All' dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1)*pctsum<hh>='Penetration'*f=pctfmt./ nocellmerge misstext='0';
table (dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt)*sum='Total Balances'*f=dollar24. / nocellmerge misstext='0'; 
table (dda_amt*pctsum<dda1> mms_amt*pctsum<mms1> sav_amt*pctsum<sav1> tda_amt*pctsum<tda1> ira_amt*pctsum<ira1> 
        mtg_amt*pctsum<mtg1> heq_amt*pctsum<heq1> iln_amt*pctsum<iln1> ccs_amt*pctsum<ccs1>)*f=pctdoll. / nocellmerge misstext='0';
keylabel pctsum='Average Balance';
run;

*/






data fl_bals1;
set fl_bals;
if state eq 'FL' then FL = COL1;
if state ne 'FL' then NJ = COL1;
run;

proc template;
define statgraph balances;
begingraph;
entrytitle 'Distribution of Product Balances';
layout overlay / yaxisopts=(linearopts=(viewmin=0 viewmax=200000 tickvalueformat=dollar12.) label='Balance' )
xaxisopts=(display=(line ticks tickvalues)) cycleattrs=true;
boxplot x=_LABEL_ y=NJ  / discreteoffset=-0.1 boxwidth=.2 outlierattrs=(color=grey) medianattrs=(color=red) meanattrs=(color=red symbol=Plus)
name='a' legendlabel="NJNY/CT (N=&N_foot.)";
boxplot x=_LABEL_ y=FL / discreteoffset= 0.1 boxwidth=.2 outlierattrs=(color=grey) meanattrs=(color=red symbol=Plus) medianattrs=(color=red )
name='b' legendlabel="FL Snowbird (N=&N_fl.)";
referenceline y=1 / lineattrs=(pattern=dot);
discretelegend 'a' 'b' / location=outside valign=bottom halign=center across=2;
endlayout;
/*entryfootnote halign=left "For ALAT, ASAT and ALKPH, the Clinical ...;";*/
/*entryfootnote halign=left "For BILTOT, the CCL is 1.5 ULN: where ULN ...";*/
endgraph;
end; run;



data anno1;
retain function "Image" x1 99 y1 98 anchor "topright" 
        Image "C:\Documents and Settings\ewnym5s\My Documents\Tools\hboxsmall.png"
		border "TRUE";
run;
footnote;
*generate PDf ;

ods graphics / reset;
ods escapechar="^";  
options nodate nonumber;  
ods pdf file='My Documents\Hudson City\HCSB Snowbirds 20130307.pdf' style=mtbnew nogfootnote nogtitle dpi=300 ;
ODS PDF startpage=NO;

Title j=c height=14pt "Hudson City Savings Bank - Florida Based Customer Profile";
footnote height =8pt justify=left  "MCD - Customer Insights Analysis" j=c 'Page ^{thispage}' j=r "^S={preimage='C:\Documents and Settings\ewnym5s\My Documents\Tools\logo.png'}" ;





options orientation=PORTRAIT;
goptions hsize=7.5 vsize=5;

ods layout start rows=2;
ods region;
ods graphics / height=4.5in width=7.5in; 

data anno2;
   retain function 'text' label 'Hudson City Snowbirds Segment Distribution' x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;

proc sgplot data=fl sganno = anno2;
vbar segment / stat=sum response=pct group=state groupdisplay=cluster nostatlabel datalabel;
xaxis fitpolicy=staggerthin ;
yaxis display=none offsetmax=.15;
format  segment hudsonseg. pct percent6. state $quick.;
keylegend / Title="Type of HH" titleattrs=(weight=BOLD);
run;


ods region;
ods graphics / height=4.5in width=7.5in; 

%let title= Hudson City Snowbirds Wealth Distribution;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;

proc sgplot data=fl sganno = anno2;
vbar adj_tot / stat=sum response=pct group=state groupdisplay=cluster nostatlabel datalabel;
xaxis fitpolicy=rotate ;
yaxis display=none offsetmax=.15;
format adj_tot wltamt.  pct percent6. state $quick.;
keylegend / Title="Type of HH" titleattrs=(weight=BOLD);
run;
ods layout end;

ODS PDF startpage=NOW nogtitle;
ods layout start rows=2;
ods region;
ods graphics / height=4.5in width=7.5in; 

%let title = Hudson City Snowbirds Product Penetration;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;

proc sgplot data=fl_prods sganno=anno2;
vbar _label_ / stat=sum response=pct  group=state groupdisplay=cluster nostatlabel datalabel;
xaxis fitpolicy=staggerthin  label="Product" discreteorder=data;
yaxis display=none offsetmax=.15;
format  pct percent6. state $quick.;
keylegend / Title="Type of HH" titleattrs=(weight=BOLD);
run;

ods region;
ods graphics / height=4.5in width=7.5in; 
%let title=Hudson City Snowbirds Average Balances;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=fl_bals sganno=anno2 ;
vbar _label_ / stat=mean response=col1  group=state groupdisplay=cluster nostatlabel datalabel;
xaxis fitpolicy=staggerthin  label="Product" discreteorder=data;
yaxis display=none offsetmax=.15;
format  col1 dollar12. state $quick.;
keylegend / Title="Type of HH" titleattrs=(weight=BOLD);
run;
quit;
ods layout end;

ODS PDF startpage=NOW nogtitle;
ods layout start rows=2;
ods region;
ods graphics / width=7.5in height=4.5in imagename="balances1";
proc sgrender data=fl_bals1(where=(_name_ not in ('MTG_amt','HEQ_amt','ILN_amt')))  template=balances; run;

/*
%let title = Hudson City Snowbirds Balances - Deposit Products;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;

proc sgplot data=fl_bals sganno=anno2;
where _name_ not in ('MTG_amt','HEQ_amt','ILN_amt');
vbox col1 / group=  _label_ grouporder=data MEANATTRS=(color="red" symbol='DiamondFilled') MEDIANATTRS=(color="red")
                OUTLIERATTRS=(color="lightgrey");
xaxis fitpolicy=staggerthin  label="Product" discreteorder=data offsetmax=.15 ;
yaxis max=200000 label="Balance";
format col1 dollar12.;
run;
*/
ods region;
ods graphics / width=7.5in height=4.5in imagename="balances2";
proc sgrender data=fl_bals1(where=(_name_  in ('MTG_amt','HEQ_amt','ILN_amt')))  template=balances; run;
ods layout end;

/*
%let title = Hudson City Snowbirds  Balances - Loan Products;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=fl_bals sganno=anno2;
where _name_  in ('MTG_amt','HEQ_amt');
vbox col1 / group=  _label_ grouporder=data MEANATTRS=(color="red" symbol='DiamondFilled') MEDIANATTRS=(color="red")
                OUTLIERATTRS=(color="lightgrey");
xaxis fitpolicy=staggerthin  label="Product" discreteorder=data ;
yaxis max=1000000 label="Balance" offsetmax=.25;
format  col1 dollar12.;
run;
*/ 

quit;

ods pdf close;

footnote;
title;


