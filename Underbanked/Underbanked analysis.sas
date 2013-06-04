/*libname mario odbc DSN=Mario1 user=reporting_user pw=Reporting2 schema=dbo;*/
/**/
/*proc contents data=mario.ACX_RANDOM_OUT varnum short; run;*/
/**/
/*proc freq data=mario.ACX_RANDOM_OUT;*/
/*table _621_Credit_Card_Indicator _693_Credit_Card_User _815_Bank_Card_Presence_in_House */
/*_270_Personicx_Classic_Refresh _350_Economic_Stability_Indicato _351_UnderBanked_Indicator */
/*_356_NetWorth_Gold _358_HeavyTransactors / plots=all missing;*/
/*run;*/


proc format;
value $ networthgold (notsorted)
	'1' = 'Less than $1'
	'2' = '$1 - $4,999'
	'3' = '$5,000 - $9,999'
	'4' = '$10,000 - $24,999'
	'5' = '$25,000 - $49,999'
	'6' = '$50,000 - $99,999'
	'7' = '$100,000 - $249,999'
	'8' = '$250,000 - $499,999'
	'9' = '$500,000 - $999,999'
	'A' = '$1,000,000 - $1,999,999'
	'B' = 'Greater than $1,999,999'
	other = 'Uncoded';

run;



proc freq data=mario.ACX_RANDOM_OUT;
table _351_UnderBanked_Indicator / missing;
run;

proc format;
value $ underb '01'-'05' = '1 to 5'
				'06'-'10' = '6 to 10'
				'11' - '15' = '11 to 15'
				'16' - '20' = '16 to 20';
run;

data under;
length hhid $ 9;
set mario.ACX_RANDOM_OUT (keep= acct_id _351_UnderBanked_Indicator rename=(_351_UnderBanked_Indicator=underbanked));
hhid = left(acct_id);
drop acct_id;
run;



options compress=y;
 data data.main_201212;
length hhid $ 9 underbanked $ 2 ;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set under end=eof1;
	dcl hash hh1 (dataset: 'under', hashexp: 8, ordered:'a');
	hh1.definekey('hhid');
	hh1.definedata('underbanked');
	hh1.definedone();
end;

misses = 0;
do until (eof2);
	set data.main_201212 end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		underbanked = '';
	end;
	output;
end;

putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;

%penetration(period=201212, where=underbanked ne '', fmt1=$underb, class1=underbanked,out=penet)

%contribution(period=201212, where=underbanked ne '', fmt1=$underb, class1=underbanked,out=contr)

%segments(period=201212, where=underbanked ne '', fmt1=$underb, class1=underbanked,out=segments)

%ranges(period=201212, where=underbanked ne '', fmt1=$underb, class1=underbanked)




proc freq data=penet1;
table prod;
format prod $ptypefmt.;
run;

proc format library=sas;
value $ ptypeorder (notsorted)
	'DDA' = 'Checking'
	'MMS' = 'Money Market'
	'SAV' = 'Savings'
	'TDA' = 'Time Deposit'
	'IRA' = 'IRAs'
	'MTG' = 'Mortgage'
	'HEQ' = 'Home Equity'
	'CRD' = 'Credit Card'
	'ILN' = 'Dir. Loan'
	'IND' = 'Ind. Loan'
	'SEC' = 'Securities';
run;

data wip.penet1;
set penet1;
run;


*try charts;
proc sort data=penet;
by underbanked;
run;

proc transpose data=penet out=penet1;
where underbanked ne '';
by underbanked;
run;

data penet1;
length prod $10 what $ 10 what2 $ 10;
set penet1;
prod = upcase(scan(_name_,1,'_','i'));
if prod eq 'CARD' then prod = 'CRD';
if prod eq 'CCS' then prod = 'CRD';
what=lowcase(scan(_name_,2,'_','i'));
what2=lowcase(scan(_name_,3,'_','i'));
run;

data penet1;
set penet1;
if what eq 'pctsum' then col2 = col2/100;
if  what2 eq 'pctsum' then col3 = col3/(100*1000); *make in in thousands, also fix the *100 from tabulate;
run;


data penet1;
set penet1;
select  (prod);
	when ('DDA') order = 1;
	when ('MMS') order = 2;
	when ('SAV') order = 3;
	when ('TDA') order = 4;
	when ('IRA') order = 5;
	when ('SEC') order = 6;
	when ('MTG') order = 7;
	when ('HEQ') order = 8;
	when ('CRD') order = 9;
	when ('ILN') order = 10;
	when ('IND') order = 11;
	OTHERWISE ORDER=99;
END;
run;

proc sort data=penet1;
by order underbanked;
run;


proc sort data=contr;
by underbanked;
run;

proc transpose data=contr out=contr1;
where underbanked ne '';
by underbanked;
run;

data contr1;
length prod $10 what $ 10 what2 $ 10;
set contr1;
prod = upcase(scan(_name_,1,'_','i'));
if prod eq 'CARD' then prod = 'CRD';
if prod eq 'CCS' then prod = 'CRD';
what=lowcase(scan(_name_,2,'_','i'));
what2=lowcase(scan(_name_,3,'_','i'));
run;

data contr1;
set contr1;
if what eq 'con' and  what2 eq 'pctsum' then col1 = col1/100; *fix the *100 from tabulate;
if what eq 'contr' and  what2 eq 'pctsum' then col1 = col1/100; *fix the *100 from tabulate;
run;


data contr1;
set contr1;
select  (prod);
	when ('DDA') order = 1;
	when ('MMS') order = 2;
	when ('SAV') order = 3;
	when ('TDA') order = 4;
	when ('IRA') order = 5;
	when ('SEC') order = 6;
	when ('MTG') order = 7;
	when ('HEQ') order = 8;
	when ('CRD') order = 9;
	when ('ILN') order = 10;
	when ('IND') order = 11;
	OTHERWISE ORDER=99;
END;
run;

proc sort data=contr1;
by order underbanked;
run;



proc sort data=segments;
by underbanked;
run;

data segments1 ;
set segments (rename=(pctn_10000000=pct));
pct = pct / 100;
/*select (trim(left(segment)));*/
/*	when ('Building Their Future') seg1 = 1;*/
/*	when ('Mass Affluent no Kids') seg1 = 2;*/
/*	when ('Mainstream Families') seg1 = 3;*/
/*	when ('Mass Affluent Families') seg1 = 4;*/
/*	when ('Mainstream Retired') seg1 = 5;*/
/*	when ('Mass Affluent Retired') seg1 = 6;*/
/*	when ('Not Coded') seg1 = 7;*/
/*end;*/
seg1=segment;
if seg1 eq . then seg1 = 7;
format seg1 comma1.;
run;

data temp_under;
set data.main_201212;
where underbanked ne '';
keep underbanked hhid fico ixi: dda: mms: sav: tda: ira: sec: mtg: heq: iln: ind: ccs: card;
run;

proc sort data=temp_under;
by underbanked;
run;

data temp_under;
set temp_under;
if dda eq 0 then dda_amt = .;
if mms eq 0 then mms_amt = .;
if sav eq 0 then sav_amt = .;
if tda eq 0 then tda_amt = .;
if ira eq 0 then ira_amt = .;
if sec eq 0 then sec_amt = .;
if mtg eq 0 then mtg_amt = .;
if heq eq 0 then heq_amt = .;
if iln eq 0 then iln_amt = .;
if ind eq 0 then ind_amt = .;
if card eq 0 then ccs_amt = .;
run;


proc sort data=temp_under;
by hhid;
run;


proc transpose data=temp_under out=balancebox;
where underbanked ne '';
by hhid;
var dda_amt mms_amt sav_amt tda_amt ira_amt sec_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt;
run;


data balancebox;
merge balancebox (in=a) temp_under (keep=hhid underbanked in=b);
by hhid;
if a;
run;


data balancebox;
length product $ 14;
set balancebox;
select  (lowcase(_name_));
	when ('dda_amt') order=1;
	when ('mms_amt') order=2;
	when ('sav_amt') order=3;
	when ('tda_amt') order=4;
	when ('ira_amt') order=5;
	when ('sec_amt') order=6;
	when ('mtg_amt') order=7;
	when ('heq_amt') order=8;
	when ('ccs_amt') order=9;
	when ('iln_amt') order=10;
	when ('ind_amt') order=11;
end;
select  (lowcase(_name_));
	when ('dda_amt') product='Checking';
	when ('mms_amt') product='Money Market';
	when ('sav_amt') product='Savings';
	when ('tda_amt') product='Time Deposits';
	when ('ira_amt') product='IRAs';
	when ('sec_amt') product='Securities';
	when ('mtg_amt') product='Mortgage';
	when ('heq_amt') product='Home Equity';
	when ('ccs_amt') product='Credit Card';
	when ('iln_amt') product='Dir. Loan';
	when ('ind_amt') product='Ind. Loan';
end;
select (underbanked);
	when ('01','02','03','04','05') one = col1;
	when ('06','07','08','09','10') two = col1;
	when ('11','12','13','14','15') three = col1;
	when ('16','17','18','19','20') four = col1;
end;
run;

proc sort data=balancebox;
by  order;
run;


proc template;
define statgraph balances4;
begingraph;
entrytitle 'Distribution of Product Balances';
layout overlay / yaxisopts=(linearopts=(viewmin=0 viewmax=100000 tickvalueformat=dollar12.) label='Balance' labelattrs=(weight=bold))
xaxisopts=( label="Product" labelattrs=(weight=bold) discreteopts=(TICKVALUEFITPOLICY=STAGGER) ) cycleattrs=true ;
boxplot x=product y=one  / discreteoffset=-0.3 boxwidth=.2 outlierattrs=(color=grey) medianattrs=(color=red) meanattrs=(color=red symbol=DiamondFilled)
name='a' legendlabel="1 to 5";
boxplot x=product y=two / discreteoffset= -0.1 boxwidth=.2 outlierattrs=(color=grey) meanattrs=(color=red symbol=DiamondFilled) medianattrs=(color=red )
name='b' legendlabel="6 to 10";
boxplot x=product y=three / discreteoffset= 0.1 boxwidth=.2 outlierattrs=(color=grey) meanattrs=(color=red symbol=DiamondFilled) medianattrs=(color=red )
name='c' legendlabel="11 to 15";
boxplot x=product y=two / discreteoffset= 0.3 boxwidth=.2 outlierattrs=(color=grey) meanattrs=(color=red symbol=DiamondFilled) medianattrs=(color=red )
name='d' legendlabel="16 to 20";
referenceline y=1 / lineattrs=(pattern=dot);
discretelegend 'a' 'b' 'c' 'd' / location=outside valign=bottom halign=center across=4;
endlayout;
/*entryfootnote halign=left "For ALAT, ASAT and ALKPH, the Clinical ...;";*/
/*entryfootnote halign=left "For BILTOT, the CCL is 1.5 ULN: where ULN ...";*/
endgraph;
end; run;

proc template;
define statgraph balances4l;
begingraph;
entrytitle 'Distribution of Product Balances';
layout overlay / yaxisopts=(linearopts=(viewmin=0 viewmax=200000 tickvalueformat=dollar12.) label='Balance' labelattrs=(weight=bold))
xaxisopts=(label="Product" labelattrs=(weight=bold) discreteopts=(TICKVALUEFITPOLICY=STAGGER)) cycleattrs=true;
boxplot x=product y=one  / discreteoffset=-0.3 boxwidth=.2 outlierattrs=(color=grey) medianattrs=(color=red) meanattrs=(color=red symbol=DiamondFilled)
name='a' legendlabel="1 to 5";
boxplot x=product y=two / discreteoffset= -0.1 boxwidth=.2 outlierattrs=(color=grey) meanattrs=(color=red symbol=DiamondFilled) medianattrs=(color=red )
name='b' legendlabel="6 to 10";
boxplot x=product y=three / discreteoffset= 0.1 boxwidth=.2 outlierattrs=(color=grey) meanattrs=(color=red symbol=DiamondFilled) medianattrs=(color=red )
name='c' legendlabel="11 to 15";
boxplot x=product y=two / discreteoffset= 0.3 boxwidth=.2 outlierattrs=(color=grey) meanattrs=(color=red symbol=DiamondFilled) medianattrs=(color=red )
name='d' legendlabel="16 to 20";
referenceline y=1 / lineattrs=(pattern=dot);
discretelegend 'a' 'b' 'c' 'd' / location=outside valign=bottom halign=center across=4;
endlayout;
/*entryfootnote halign=left "For ALAT, ASAT and ALKPH, the Clinical ...;";*/
/*entryfootnote halign=left "For BILTOT, the CCL is 1.5 ULN: where ULN ...";*/
endgraph;
end; run;




ods html style=mtbnew;


*#####################################################################################################;
options pdfassembly;
title;
footnote;
ods graphics / reset;
ods escapechar="^";  
options nodate nonumber;  
ods pdf file="C:\Documents and Settings\ewnym5s\My Documents\Underbanked\Underbanked 20130305.pdf" style=mtbnew nogtitle nogfootnote;
options orientation=PORTRAIT;
ODS PDF startpage=NO;

Title j=c height=14pt "Profile of Acxiom Underbanked Indicator Test";
footnote height =8pt justify=left  "Source: MCD - Customer Insights Analysis" j=r "^S={preimage='C:\Documents and Settings\ewnym5s\My Documents\Tools\logo.png'}" ;

ods graphics / height=4.5in width=7.5in;
%let Title=Product Penetration;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=penet1 sganno=anno2;
where prod not in ('HH','PAGE','TABLE','SDB','SLN','TRS') and what = 'pctsum' and what2 eq '1';
vbar prod / missing group=underbanked groupdisplay=cluster response=col2 nostatlabel grouporder=data 
            datalabel DATALABELATTRS=(family=Arial Size=6);
xaxis label='Product' LABELATTRS=(family=Arial Weight=Bold)   tickvalueformat=DATA type=discrete 
      discreteorder=data fitpolicy=stagger valueattrs=(family=Arial );
yaxis label='Percent of HHs' LABELATTRS=(family=Arial Weight=Bold) valueattrs=(family=Arial ) display=(NOVALUES noticks);
keylegend /title="Underbanked Score" TITLEATTRS=(family=Arial Weight=Bold) valueattrs=(family=Arial ) ;
format  prod $ptypeorder. underbanked $underb. col2 percent4.;
run;

/*goptions hsize=7 vsize=5;*/
%let Title=Average Balance;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=penet1 sganno=anno2;
where prod not in ('HH','PAGE','TABLE','SDB','SLN','TRS') and what2 = 'pctsum' and what eq 'amt';
vbar prod / missing group=underbanked groupdisplay=cluster response=col3 nostatlabel grouporder=data 
           datalabel DATALABELATTRS=(Size=6);
xaxis label='Product' LABELATTRS=(Weight=Bold)   tickvalueformat=DATA type=discrete discreteorder=data 
      fitpolicy=stagger;
yaxis label='Average Balance' LABELATTRS=(Weight=Bold) display=(NOVALUES noticks) ;
keylegend /title="Underbanked Score" TITLEATTRS=(Weight=Bold);
format  prod $ptypeorder. underbanked $underb. col3 dollar12.;
run;

ODS PDF startpage=NOW;
proc sgrender data=balancebox(where=(order not in (7,8)))  template=balances4; run;

proc sgrender data=balancebox(where=(order in (7,8)))  template=balances4l; run;


/*goptions hsize=7 vsize=5;*/
ODS PDF startpage=NOW;
%let Title=Average Contribution by Product;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=contr1 sganno=anno2;
where prod not in ('HH','PAGE','TABLE','SDB','SLN','TRS') and what2 = 'pctsum' and what eq 'con';
vbar prod / missing group=underbanked groupdisplay=cluster response=col1 nostatlabel grouporder=data 
           datalabel DATALABELATTRS=(Size=6);
xaxis label='Product' LABELATTRS=(Weight=Bold)   tickvalueformat=DATA type=discrete discreteorder=data 
      fitpolicy=stagger;
yaxis label='Average Contribution' LABELATTRS=(Weight=Bold) display=(NOVALUES noticks);
keylegend /title="Underbanked Score" TITLEATTRS=(Weight=Bold);
format  prod $ptypeorder. underbanked $underb. col1 dollar12.1;
run;

/*goptions hsize=7 vsize=5;*/
%let Title=Average Contribution;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=contr1 sganno=anno2 ;
where prod  in ('TOTAL') and what2 = 'pctsum' and what eq 'contr';
vbar underbanked / missing group=underbanked groupdisplay=cluster response=col1 nostatlabel grouporder=data 
           datalabel DATALABELATTRS=(Size=6);
xaxis label='Underbanked Score' LABELATTRS=(Weight=Bold)   tickvalueformat=DATA type=discrete discreteorder=data 
      fitpolicy=stagger;
yaxis label='Average Contribution' display=(NOVALUES noticks) LABELATTRS=(Weight=Bold) ;
keylegend /title="Underbanked Score" TITLEATTRS=(Weight=Bold);
format  prod $ptypeorder. underbanked $underb. col1 dollar12.1;
run;

proc sort data=segments1;
by seg1;
run;

/*goptions hsize=7 vsize=5;*/
ODS PDF startpage=NOW;
%let Title=Customer Segment;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=segments1 sganno=anno2 ;
where _table_ eq 1 and hh_sum eq . and underbanked ne '';
vbar segment / missing group=underbanked groupdisplay=cluster response=pct nostatlabel grouporder=data 
           datalabel DATALABELATTRS=(Size=6);
xaxis label='Segment' LABELATTRS=(Weight=Bold)   tickvalueformat=DATA type=discrete discreteorder=data 
      fitpolicy=stagger;
yaxis label='Percent of HHs' LABELATTRS=(Weight=Bold) display=(NOVALUES noticks);
keylegend /title="Underbanked Score" TITLEATTRS=(Weight=Bold);
format  underbanked $underb. pct percent6.;
run;

proc sort data=segments1;
by band;
run;

/*goptions hsize=7 vsize=5;*/
%let Title=Profitability;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=segments1 sganno=anno2;
where _table_ eq 7 and hh_sum eq . and underbanked ne '';
vbar band / missing group=underbanked groupdisplay=cluster response=pct nostatlabel grouporder=data 
           datalabel DATALABELATTRS=(Size=6);
xaxis label='Profit Band' LABELATTRS=(Weight=Bold)   tickvalueformat=DATA type=discrete discreteorder=data 
      fitpolicy=stagger;
yaxis label='Percent of HHs' LABELATTRS=(Weight=Bold) display=(NOVALUES noticks);
keylegend /title="Underbanked Score" TITLEATTRS=(Weight=Bold);
format  underbanked $underb. pct percent6.;
run;

proc sort data=segments1;
by ixi_tot;
run;

/*goptions hsize=7 vsize=5;*/
ODS PDF startpage=NOW;
%let Title=Estimated Investable Assets;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=segments1 sganno=anno2;
where _table_ eq 3 and hh_sum eq . and underbanked ne '';
vbar ixi_tot / missing group=underbanked groupdisplay=cluster response=pct nostatlabel grouporder=data 
           datalabel DATALABELATTRS=(Size=6);
xaxis label='Investable Assets' LABELATTRS=(Weight=Bold)   tickvalueformat=DATA type=discrete discreteorder=data 
      fitpolicy=stagger;
yaxis label='Percent of HHs' LABELATTRS=(Weight=Bold) display=(NOVALUES noticks);
keylegend /title="Underbanked Score" TITLEATTRS=(Weight=Bold);
format  underbanked $underb. pct percent6.;
run;

proc sort data=segments1;
by distance;
run;

/*goptions hsize=7 vsize=5;*/
%let Title=Distance to Branch;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=segments1 sganno=anno2;
where _table_ eq 5 and hh_sum eq . and underbanked ne '';
vbar distance / missing group=underbanked groupdisplay=cluster response=pct nostatlabel grouporder=data 
           datalabel DATALABELATTRS=(Size=6);
xaxis label='Distance in Miles' LABELATTRS=(Weight=Bold)   tickvalueformat=DATA type=discrete discreteorder=data 
      fitpolicy=stagger;
yaxis label='Percent of HHs' LABELATTRS=(Weight=Bold) display=(NOVALUES noticks);
keylegend /title="Underbanked Score" TITLEATTRS=(Weight=Bold);
format  underbanked $underb. pct percent6.;
run;

proc sort data=segments1;
by tenure_yr;
run;

/*goptions hsize=7 vsize=5;*/
ODS PDF startpage=NOW;
%let Title=Tenure;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=segments1 sganno=anno2;
where _table_ eq 6 and hh_sum eq . and underbanked ne '';
vbar tenure_yr / missing group=underbanked groupdisplay=cluster response=pct nostatlabel grouporder=data 
           datalabel DATALABELATTRS=(Size=6);
xaxis label='Tenure in Years' LABELATTRS=(Weight=Bold)   tickvalueformat=DATA type=discrete discreteorder=data 
      fitpolicy=stagger;
yaxis label='Percent of HHs' LABELATTRS=(Weight=Bold) display=(NOVALUES noticks);
keylegend /title="Underbanked Score" TITLEATTRS=(Weight=Bold);
format  underbanked $underb. pct percent6.;
run;

proc sort data=segments1;
by cbr;
run;

/*goptions hsize=7 vsize=5;*/
%let Title=CBR;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=segments1 sganno=anno2;
where _table_ eq 4 and hh_sum eq . and underbanked ne '';
vbar cbr / missing group=underbanked groupdisplay=cluster response=pct nostatlabel grouporder=data 
           datalabel DATALABELATTRS=(Size=6) clusterwidth=0.75;
xaxis label='Community Bank Region' LABELATTRS=(Weight=Bold)   tickvalueformat=DATA type=discrete discreteorder=data 
      fitpolicy=stagger;
yaxis label='Percent of HHs' LABELATTRS=(Weight=Bold) display=(NOVALUES noticks);
keylegend /title="CBR" TITLEATTRS=(Weight=Bold);
format  underbanked $underb. pct percent6.;
run;


proc sort data=segments1;
by tran_code;
run;

/*goptions hsize=7 vsize=5;*/
ODS PDF startpage=NOW;
%let Title=Transaction Segment;
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
proc sgplot data=segments1 sganno=anno2;
where _table_ eq 2 and hh_sum eq . and underbanked ne '';
vbar tran_code / missing group=underbanked groupdisplay=cluster response=pct nostatlabel grouporder=data 
           datalabel DATALABELATTRS=(Size=6);
xaxis label='Transaction Segment' LABELATTRS=(Weight=Bold)   tickvalueformat=DATA type=discrete discreteorder=data 
      fitpolicy=stagger;
yaxis label='Percent of HHs' LABELATTRS=(Weight=Bold) display=(NOVALUES noticks);
keylegend /title="Underbanked Score" TITLEATTRS=(Weight=Bold);
format  underbanked $underb. pct percent6.;
run;


/*data anno1;*/
/*retain function "Image" x1 100 y1 0 anchor "bottomright" */
/*        Image "C:\Documents and Settings\ewnym5s\My Documents\Tools\vboxsmall.jpg"*/
/*		border "TRUE";*/
/*run;*/

%let Title=Credit Score (for Lending HHs Only);
data anno2;
   retain function 'text' label "&title" x1 50 y1  98 anchor"TOP" Justify "CENTER"
          TEXTWEIGHT "BOLD" TEXTSIZE 12 TEXTFONT "ARIAL" WIDTH 100;
run;
/*data anno3;*/
/*set anno1 anno2;*/
/*run;*/

proc sgplot data=temp_under sganno=anno2;
vbox fico / group=underbanked groupdisplay=cluster MEANATTRS=(color="red" symbol='DiamondFilled' ) MEDIANATTRS=(color="red") OUTLIERATTRS=(color="lightgrey");
format underbanked $underb.;
xaxis label='Underbanked Score' LABELATTRS=(Weight=Bold)   tickvalueformat=DATA type=discrete discreteorder=data 
      fitpolicy=stagger max=1000 minm=300;
yaxis label='Credit Score' LABELATTRS=(Weight=Bold) ;
keylegend /title="Underbanked Score" TITLEATTRS=(Weight=Bold);
format fico comma8.;
run;

ODS PDF startpage=NOW;
ods pdf text="Parts of a Boxplot";
ods pdf text="^S={preimage='C:\Documents and Settings\ewnym5s\My Documents\Tools\boxplot.pdf'}";

ods pdf close;

title;
footnote;

*#####################################################################################################;

title;




proc sgplot data=penet1 ;
where prod not in ('HH','PAGE','TABLE','SDB','SLN','TRS') and what = 'pctsum' and what2 eq '1';
vbar prod / missing group=underbanked groupdisplay=cluster response=col2 nostatlabel grouporder=data datalabel ;
xaxis label='Transaction Segment' LABELATTRS=(Weight=Bold)   tickvalueformat=DATA type=discrete discreteorder=data 
      fitpolicy=stagger;
yaxis label='Percent of HHs' LABELATTRS=(Weight=Bold) display=(NOVALUES noticks);
keylegend /title="Underbanked Score" TITLEATTRS=(Weight=Bold);
format  prod $ptypeorder. underbanked $underb. col2 comma4.;
run;


*balance boxplots;
*data needs to be long, one row per HH, I also need one column per group I want to chart per variable;






proc sgrender data=balancebox(where=(order not in (7,8)))  template=balances4; run;
proc sgrender data=balancebox(where=(order  in (7,8)))  template=balances4l; run;
