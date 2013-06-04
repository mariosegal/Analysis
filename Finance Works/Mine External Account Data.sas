*prepare data for analysis;

data external;
set data.eactivity_201206;
where svc="FINANCEWORKS" and type="ACCOUNT";
run;

data x;
set data.main_201206(keep=hhid fworks_flag1 where=(fworks_flag1 ne "No FWorks"));
run;

data external;
merge external (in=a) x (in=b);
by hhid;
if a;
run;

proc freq data=external;
table fworks_flag1;
run;


data external;
length balance 8 trans 8;
set external;
acct = 1;
balance = value3;
trans = value5;
run;

proc sort data=external;
by hhid value1;
run;


proc summary data=external;
by hhid value1;
output out=summary
       sum(acct)=accts
	   sum(balance)=balance
	   sum(trans)=trans;
run;

proc transpose data=summary out=t1(drop=_name_) name=value1 suffix=_accts;
by hhid;
id value1;
var accts;
run;

proc transpose data=summary out=t2(drop=_name_) name=value1 suffix=_bal;
by hhid;
id value1;
var balance;
run;

proc transpose data=summary out=t3(drop=_name_) name=value1 suffix=_trans;
by hhid;
id value1;
var trans;
run;

data external_all;
merge t1 (in=a drop=value1 ) t2 (in=b drop=value1) t3 (in=c drop=value1);
by hhid;
if a and b and c;
run;

proc contents data=online.external_all varnum short;
run;

data external_all;
set external_all;
hh=1;
if CREDIT_CARD_accts ge 1 then credit = 1;
if TAX_DEFERRED_INVESTMENT_accts ge 1 then deferred = 1;
if CHECKING_accts ge 1 then dda = 1;
if SAVINGS_accts ge 1 then sav = 1;
if TAXABLE_INVESTMENT_accts ge 1 then sec = 1;
if MONEY_MARKET_accts ge 1 then mms = 1;
if LOAN_accts ge 1 then iln_all = 1;
if LINE_OF_CREDIT_accts ge 1 then ccs = 1;
if MORTGAGE_accts ge 1 then mtg = 1;
if CD_accts ge 1 then tda = 1;
run;
  

data online.external_all;
set external_all;
run;

data online.external_all;
merge online.external_all (in=a) x(in=b);
by hhid;
if a or b;
run;

data online.external_all;
set online.external_all;
added= max(credit,deferred,dda,sav,sec,mms,iln_all,ccs,mtg,tda);
if added eq . then added = 0;
hh =1;
run;

data online.external_all;
set online.external_all;

run;
*Start Analysis;

proc tabulate data=online.external_all missing;
where fworks_flag1 ne '';
class fworks_flag1;
var hh credit deferred dda sav sec mms iln_all ccs mtg tda added;
var CREDIT_CARD_bal TAX_DEFERRED_INVESTMENT_bal CHECKING_bal SAVINGS_bal TAXABLE_INVESTMENT_bal MONEY_MARKET_bal LOAN_bal LINE_OF_CREDIT_bal MORTGAGE_bal CD_bal;
var CREDIT_CARD_trans TAX_DEFERRED_INVESTMENT_trans CHECKING_trans SAVINGS_trans TAXABLE_INVESTMENT_trans MONEY_MARKET_trans LOAN_trans LINE_OF_CREDIT_trans MORTGAGE_trans CD_trans ;
table hh*sum='HHs'*f=comma12. 
      (added='Any Ext Acct' dda='Checking' mms='Money Market' sav='Savings' tda='Time Dep' sec='Taxable Inv.' deferred='Tax Def Inv.' credit='Credit Card' iln_all='Lonas (All)' ccs='Lines of Credit incl HELOC' mtg='Mortgage')*sum='Prod HHs'*f=comma12.
      (added='Any Ext Acct' dda='Checking' mms='Money Market' sav='Savings' tda='Time Dep' sec='Taxable Inv.' deferred='Tax Def Inv.' credit='Credit Card' iln_all='Lonas (All)' ccs='Lines of Credit incl HELOC' mtg='Mortgage')*pctsum<hh>='Prod penet'*f=pctfmt.
	  (checking_bal='Checking' money_market_bal='Money Market' savings_bal='Savings' CD_bal='Time Dep' TAXABLE_INVESTMENT_bal='Taxable Inv.' 
       TAX_DEFERRED_INVESTMENT_bal='Tax Def Inv.' CREDIT_CARD_bal='Credit Card' LOAN_bal='Loans (All)' LINE_OF_CREDIT_bal='Lines of Credit incl HELOC' MORTGAGE_bal='Mortgage')*sum='Balances'*f=dollar24.
	   (checking_bal='Checking' money_market_bal='Money Market' savings_bal='Savings' CD_bal='Time Dep' TAXABLE_INVESTMENT_bal='Taxable Inv.' 
       TAX_DEFERRED_INVESTMENT_bal='Tax Def Inv.' CREDIT_CARD_bal='Credit Card' LOAN_bal='Loans (All)' LINE_OF_CREDIT_bal='Lines of Credit incl HELOC' MORTGAGE_bal='Mortgage')*pctsum<dda mms sav tda sec deferred credit iln_all ccs mtg>='Avg. Bal Prod HH'*f=pctdoll.
	   (checking_trans='Checking' money_market_trans='Money Market' savings_trans='Savings' CD_trans='Time Dep' TAXABLE_INVESTMENT_trans='Taxable Inv.' 
       TAX_DEFERRED_INVESTMENT_trans='Tax Def Inv.' CREDIT_CARD_trans='Credit Card' LOAN_trans='Loans (All)' LINE_OF_CREDIT_trans='Lines of Credit incl HELOC' MORTGAGE_trans='Mortgage')*pctsum<dda mms sav tda sec deferred credit iln_all ccs mtg>='Avg. Trans'*f=pctcomma.
, fworks_flag1 ALL / nocellmerge;
format added binary_flag.;
run;


*do cross matrix;

data online.internal;
set data.main_201206 (where=(fworks_flag1 ne 'No FWorks'));
keep hhid fworks_flag1 dda mms sav tda ira sec iln ind card sec ins mtg heq bus 
                       dda_amt mms_amt sav_amt tda_amt ira_amt sec_amt iln_amt ind_amt ccs_amt sec_amt  mtg_amt heq_amt cqi:; 
run;

data combined;
merge online.external_all (in=a keep=hhid dda mms sav tda  sec deferred ccs iln_all mtg credit 
                           rename=(dda=dda_e mms=mms_e sav=sav_e tda=tda_e sec=sec_e ccs=ccs_e mtg=mtg_e credit=credit_e))
	  online.internal (in=b keep= hhid fworks_flag1 dda mms sav tda ira sec ins card iln ind mtg heq);
by hhid;
if a or b;
if dda_e eq . then dda_e = 0;
if mms_e eq . then mms_e = 0;
if sav_e eq . then sav_e = 0;
if tda_e eq . then tda_e = 0;
if sec_e eq . then sec_e = 0;
if ccs_e eq . then ccs_e = 0;
if credit_e eq . then credit_e = 0;
if mtg_e eq . then mtg_e = 0;
if iln_all eq . then iln_all = 0;
if deferred eq . then deferred = 0;
internal = max(dda,mms,sav,tda,ira,sec,ins,mtg,heq,card,ILN,IND) ;
external = max(dda_e,mms_e,sav_e,tda_e,sec_e,deferred,mtg_e,credit_e,iln_all,ccs_e);
run;

proc contents data=combined varnum short;
run;

proc tabulate data=combined missing out=matrix_out;
where fworks_flag1 ne '';
class credit_e deferred dda_e sav_e sec_e mms_e iln_all ccs_e mtg_e tda_e  dda mms sav tda ira sec mtg heq card ILN ins IND fworks_flag1;
table fworks_flag1, (dda mms sav tda ira sec ins  mtg heq card ILN IND)
      ,(dda_e mms_e sav_e tda_e sec_e deferred mtg_e credit_e iln_all ccs_e all)*(N*f=comma12.  rowpctN*f=pctfmt.)/nocellmerge;
run;

proc tabulate data=combined missing out=row_total;
where fworks_flag1 ne '';
class credit_e deferred dda_e sav_e sec_e mms_e iln_all ccs_e mtg_e tda_e  dda mms sav tda ira sec mtg heq card ILN ins IND fworks_flag1;
table fworks_flag1
      ,(dda_e mms_e sav_e tda_e sec_e deferred mtg_e credit_e iln_all ccs_e all)*(N*f=comma12.  rowpctN*f=pctfmt.)/nocellmerge;
run;

data row_total1;
length x $ 10 y $ 5;
set row_total;
percent1 = sum(of pctn:);
if dda_e eq 1 then x = 'DDA';
if mms_e eq 1 then x = 'MMS';
if sav_e eq 1 then x = 'SAV';
if tda_e eq 1 then x = 'TDA';
if sec_e eq 1 then x = 'SEC';
if deferred eq 1 then x = 'DEFFERED';
if mtg_e eq 1 then x = 'MTG';
if ccs_e eq 1 then x = 'Lines';
if credit_e eq 1 then x = 'CARD';
if iln_all eq 1 then x = 'ILN (ALL)';
if x eq '' then x = 'ALL';
y="All";
if (dda_e OR mms_e OR sav_e OR tda_e OR sec_e OR deferred OR mtg_e OR credit_e OR iln_all OR ccs_e)  then output;
drop pctn:  ;
rename N=HHs;
RUN;


proc tabulate data=combined missing out=col_total;
where fworks_flag1 ne '';
class credit_e deferred dda_e sav_e sec_e mms_e iln_all ccs_e mtg_e tda_e  dda mms sav tda ira sec mtg heq card ILN ins IND fworks_flag1;
table fworks_flag1
      ,(dda mms sav tda ira sec ins  mtg heq card ILN IND)*(N*f=comma12.  rowpctN*f=pctfmt.)/nocellmerge;
run;

data col_total1;
length x $ 10 y $ 5;
set col_total;
percent1 = sum(of pctn:);
if dda eq 1 then y = 'DDA';
if mms eq 1 then y = 'MMS';
if sav eq 1 then y = 'SAV';
if tda eq 1 then y = 'TDA';
if ira eq 1 then y = 'IRA';
if sec eq 1 then y = 'SEC';
if ins eq 1 then y = 'INS';
if mtg eq 1 then y = 'MTG';
if heq eq 1 then y = 'HEQ';
if card eq 1 then y = 'CARD';
if iln eq 1 then y = 'ILN';
if ind eq 1 then y = 'IND';

x="All";

if   
    (dda OR mms OR sav OR tda OR ira OR sec OR ins OR mtg OR heq OR card OR ILN OR IND) then output;
drop pctn:  ;
rename N=HHs;

RUN;


data matrix_out1;
length x $ 10 y $ 5;
set matrix_out;
percent1 = sum(of pctn:);
if dda eq 1 then y = 'DDA';
if mms eq 1 then y = 'MMS';
if sav eq 1 then y = 'SAV';
if tda eq 1 then y = 'TDA';
if ira eq 1 then y = 'IRA';
if sec eq 1 then y = 'SEC';
if ins eq 1 then y = 'INS';
if mtg eq 1 then y = 'MTG';
if heq eq 1 then y = 'HEQ';
if card eq 1 then y = 'CARD';
if iln eq 1 then y = 'ILN';
if ind eq 1 then y = 'IND';

if dda_e eq 1 then x = 'DDA';
if mms_e eq 1 then x = 'MMS';
if sav_e eq 1 then x = 'SAV';
if tda_e eq 1 then x = 'TDA';
if sec_e eq 1 then x = 'SEC';
if deferred eq 1 then x = 'DEFFERED';
if mtg_e eq 1 then x = 'MTG';
if ccs_e eq 1 then x = 'Lines';
if credit_e eq 1 then x = 'CARD';
if iln_all eq 1 then x = 'ILN (ALL)';
if x eq '' then x = 'ALL';

if (dda_e OR mms_e OR sav_e OR tda_e OR sec_e OR deferred OR mtg_e OR credit_e OR iln_all OR ccs_e) and  
    (dda OR mms OR sav OR tda OR ira OR sec OR ins OR mtg OR heq OR card OR ILN OR IND) then output;
drop pctn:  ;
rename N=HHs;

RUN;

proc tabulate data=combined missing out=all;
where fworks_flag1 ne '';
class fworks_flag1 internal;
table fworks_flag1
      ,(internal)*(N*f=comma12.  rowpctN*f=pctfmt.)/nocellmerge;
run;


proc print data=matrix_out1;
var x y fworks_flag1 hhs percent1;
format hhs comma12. percent1 pctfmt.;
run;

proc print data=row_total1;
var x y fworks_flag1 hhs percent1;
format hhs comma12. percent1 pctfmt.;
run;


proc print data=col_total1 noobs;
var x y fworks_flag1 hhs percent1;
format hhs comma12. percent1 pctfmt.;
run;

proc print data=all noobs;
where internal eq 1;
var fworks_flag1 N pctn_10;
format hhs comma12. percent1 pctfmt.;
run;


proc tabulate data=matrix_out1;
class y x fworks_flag1;
var percent1;
table fworks_flag1, y,x*sum*percent1*f=pctfmt. / nocellmerge;
run;

proc sql;
select sum(dda), credit_e, fworks_flag1 from combined where dda eq 1  group by credit_e, fworks_flag1;
quit;

PROC gchart data=matrix_out1;
where y = 'DDA' and x='DDA';
vbar fworks_flag1 / sumvar=percent1 outside=sum subgroup=fworks_flag1 discrete;
run;

options orientation=landscape;
ods html style=MTB;
proc sgpanel data=matrix_out1;
panelby  x y / border columns=11 rows=12 layout=lattice ROWHEADERPOS= left novarname uniscale=all ;
vbar fworks_flag1 / response=percent1 STAT=SUM nostatlabel group=fworks_flag1 ;
format percent percent6.1;
run;

*define a macro to:
1) create all the charts in order top to bottom
2) create the panels on greplay (make it be flexible to define n*m, care to define same order
;


ods html style=MTB;
goptions reset=all cback=white noborder htitle=14pt htext=9pt;  

 /* Use the NODISPLAY graphics option when */
 /* creating the original graphs.          */


proc freq data=matrix_out1;
table x y;
run;


data matrix_out1;
set matrix_out1;
percent1=divide(percent1,100);
run;

options mcompilenote=all;
%macro create_panel_charts (size=);
proc sql;
select min((ceil(max(percent1)*10)/10)+ 0.2,1.2) into :max1 from matrix_out1;
quit;


proc catalog c=work.gseg kill; 
run; quit; 

ods html style=MTB;
goptions reset=all cback=white noborder htitle=14pt htext=14pt;  
goptions device=gif nodisplay xpixels=&size ypixels=&size;

%do i = 1 %to 12;
	%if &i eq 1 %then %let yname=DDA;
	%if &i eq 2 %then %let yname=MMS;
	%if &i eq 3 %then %let yname=SAV;
	%if &i eq 4 %then %let yname=TDA;
	%if &i eq 5 %then %let yname=IRA;
	%if &i eq 6 %then %let yname=SEC;
	%if &i eq 7 %then %let yname=INS;
	%if &i eq 8 %then %let yname=MTG;
	%if &i eq 9 %then %let yname=HEQ;
	%if &i eq 10 %then %let yname=CARD;
	%if &i eq 11 %then %let yname=ILN;
	%if &i eq 12 %then %let yname=IND;
	%do j = 1 %to 10;
		%if &j eq 1 %then %let xname=DDA;
		%if &j eq 2 %then %let xname=MMS;
		%if &j eq 3 %then %let xname=SAV;
		%if &j eq 4 %then %let xname=TDA;
		%if &j eq 5 %then %let xname=SEC;
		%if &j eq 6 %then %let xname=DEFFERED;
		%if &j eq 7 %then %let xname=MTG;
		%if &j eq 8 %then %let xname=CARD;
		%if &j eq 9 %then %let xname=ILN (ALL);
		%if &j eq 10 %then %let xname=Lines;

		%if &i eq 1 %then %do;
			title1 "&xname";
		%end;
		%if &i ne 1 %then %do;
			title1 ;
		%end;
		%if &j eq 1 %then %do;
			axis1 label=(angle=90 f="Arial / bo" justify=center color=black height=14pt "&yname")  minor=none major=none color=white value=none order=(0 to &max1 by 0.1); 
		%end;
		%if &j ne 1 %then %do;
			axis1 label=none  minor=none major=none color=white value=none order=(0 to &max1 by 0.1); 
		%end;
		axis2 label=none  minor=none major=none value=none ;

		proc gchart data=matrix_out1(where=(y="&yname" and x="&xname")) gout=work.gseg;
		vbar fworks_flag1 / sumvar=percent1 subgroup=fworks_flag1 discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
		format percent1 percent8.1;
		run;
		quit;
	%end;
%end;
%mend create_panel_charts;

filename mprint "C:\Documents and Settings\ewnym5s\My Documents\Finance Works\panel_charts.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic ;

%create_panel_charts(size=250)





%macro custom_panel(x=,y=);



		goptions reset=all device=gif 
        gsfname=grafout gsfmode=replace 
       	xpixels=2000 ypixels=2000;

		filename grafout 'C:\Documents and Settings\ewnym5s\My Documents\Finance Works\sample.gif'; 
        %let xsize=%eval(100/&x);
		%let ysize=%eval(100/&y
);
proc greplay igout=work.gseg tc=tempcat nofs;

  /* Define a custom template called NEWTEMP */
  tdef newtemp des="y=&y by x=&x panel template"

%do q = 1 %to &y;
  %do p = 1 %to &x; 
		%let panel = %eval(&p + (&q-1)*&x);
        %let s = %eval(&y+1-&q);
       &panel./llx=%eval((&p-1)*&xsize)   lly=%eval((&s-1)*&ysize)

	      lrx=%eval((&p)*&xsize)  lry=%eval((&s-1)*&ysize)

          ulx=%eval((&p-1)*&xsize)    uly=%eval((&s)*&ysize)

          urx=%eval((&p)*&xsize)  ury=%eval((&s)*&ysize)

          color=blue

	%end;
  %end;
  ;

	template newtemp;
    list template;

	treplay 1 : gchart
 	%do r = 1 %to %eval((&x*&y)-1);
	    %if &r le 99 %then %do;
    		%eval(&r+1) :gchart&r

		%end;
		%if &r gt 99 and &r lt 999 %then %do;
    		%eval(&r+1) :gchar&r

		%end;
		%if &r gt 999 and &r lt 9999 %then %do;
    		%eval(&r+1) :gcha&r

		%end;
	%end;
	;
run;
quit;

%mend custom_panel;

filename mprint "C:\Documents and Settings\ewnym5s\My Documents\Finance Works\panel.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic ;

%custom_panel(x=10,y=12);


proc means data=matrix_out1;
var percent1;
run;

proc sql;
select min((ceil(max(percent1)*10)/10)+ 0.2,1.2) into :max1 from matrix_out1;
quit;

