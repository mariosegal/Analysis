title 'Consumer Ownership';
proc freq data=bb.bbmain_201212;
table con com / missing ;
run;

data bb.bbmain_201212;
set bb.bbmain_201212;
tenure_yr = divide(tenure,365);
hh=1;
products = sum(dda, mms ,sav ,tda, ira, mtg, heqb ,cln ,card, boloc, baloc,cls ,mcc, lckbx);
prods1 = products;
run;


data bb.bbmain_201212 ;
set bb.bbmain_201212;
array nums{*} dda mms sav tda ira  mtg heqb heqc cln card boloc baloc cls mcc lckbx rcd wbb deb web_info;
do i = 1 to dim(nums);
	if nums{i} gt 1 then nums{i} = 1;
end;
deposits = max(DDA,MMS,SAV,TDA,ira);
loans = max(mtg, heqb,cls,mtg,cln,baloc,boloc);
both = max(deposits,loans);
if deposits and loans then type = 'Both';
if deposits and not loans then type = 'Deps';
if not deposits and loans then type = 'Loan';
drop i;
run;


*read industry and top 40;
libname infousa odbc dsn=infousa;
proc contents data=infousa.info_1 varnum short;
run;

data info;
length hhid $ 9 SIC_DESC $ 40 NAICS_Desc $ 40 Employees1 $ 40 sales1 $ 40;
infile 'C:\Documents and Settings\ewnym5s\My Documents\query2.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input hhid $	customer $	SIC $ 	SIC_DESC $	NAICS_Desc	$ NAICS_Code $	Employees	Employees1 $	sales	sales1	private $;

run;

proc sort data=info;
by hhid;
run;

/*data bb.bbmain_201212;*/
/*retain miss miss1 miss2;*/
/*merge bb.bbmain_201212(in=a) info (in=b rename=(sic=sic_code)) end=eof;*/
/*by hhid;*/
/*if a then output;*/
/*if b and not a then miss1+1;*/
/*if a and not b then miss+1;*/
/*if a and b then miss2+1;*/
/*if eof;*/
/*	put 'WARNING: There were ' miss ' Records on A not on B';*/
/*	put 'WARNING: There were ' miss1 ' Records on B not on A';*/
/*	put 'WARNING: There were ' miss2 ' Records on A and B';*/
/*drop miss: ;*/
/*run;*/


/**/
/*proc sort data=bb.bbmain_201212;*/
/*by hhid;*/
/*run;*/

/*data top40;*/
/*length hhid $ 9;*/
/*infile 'C:\Documents and Settings\ewnym5s\My Documents\top40.txt' dsd dlm='09'x ;*/
/*input hhid $ ;*/
/*top40 = 1;*/
/*if hhid eq '' then delete;*/
/*run;*/
/**/
/*proc sort data=bb.bbmain_201212;*/
/*by hhid;*/
/*run;*/

/*options compress=yes;*/
/*data bb.bbmain_201212;*/
/*merge bb.bbmain_201212 (in=a) top40(in=b);*/
/*by hhid;*/
/*if a;*/
/*run;*/


proc contents data=bb.bbmain_201212 varnum short;
run;

data bb.bbmain_201212;
set bb.bbmain_201212;
contrib1 = sum(dda_con,mms_con,sav_con,tda_con,ira_con,mtg_con,heqb_con,heqc_con,cln_con,card_con,boloc_con,baloc_con,cls_con,mcc_con);
oth_contr = sum(contrib,-1*contrib1);
run;

proc means data =  bb.bbmain_201212;
var contrib: oth:;
run;



Proc tabulate data=bb.bbmain_201212 missing order=data;
class cb_dist tenure_yr band cbr rm top40 con com products/ preloadfmt;
var hh dda: mms: sav: tda: ira: heqb: heqc: mtg: cln: card: boloc: baloc: cls: mcc: contrib1 lckbx rcd wbb deb web_info prods1;
table sum="Product HHs"*(hh dda mms sav tda ira  mtg heqb heqc cln card boloc baloc cls mcc lckbx rcd wbb deb web_info)*f=comma12. / nocellmerge misstext='0';
table pctsum<hh>="Product Penetration"*(hh dda mms sav tda ira mtg heqb heqc cln card boloc baloc cls mcc lckbx rcd wbb deb web_info)*f=pctfmt. / nocellmerge misstext='0';
table (dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heqb_amt heqc_amt cln_amt card_amt boloc_amt baloc_amt cls_amt mcc_amt)*
       pctsum<dda mms sav tda ira mtg heqb heqc cln card boloc baloc cls mcc>="Average Balance"*f=pctdoll. / nocellmerge misstext='$0.00';
table (dda_con mms_con sav_con tda_con ira_con mtg_con heqb_con heqc_con cln_con card_con boloc_con baloc_con cls_con mcc_con)*
       pctsum<dda mms sav tda ira mtg heqb heqc cln card boloc baloc cls mcc>="Average Balance"*f=pctdoll. / nocellmerge misstext='$0.00';
table (dda_con mms_con sav_con tda_con ira_con mtg_con heqb_con heqc_con cln_con card_con boloc_con baloc_con cls_con mcc_con)*
       pctsum<hh>="Average Balance"*f=pctdoll. / nocellmerge misstext='$0.00';
table (cb_dist='Distance to Branch' all), hh='Total HHs'*sum=' '*f=comma12. hh='Percent of HHs'*colpctsum<hh>*f=pctfmt.  
      contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll. prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
table (tenure_yr='Tenure (Yrs.)' all), hh='Total HHs'*sum=' '*f=comma12. hh='Percent of HHs'*colpctsum<hh>*f=pctfmt.  
      contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll. prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
table (cbr='Community Bank Region' all), hh='Total HHs'*sum=' '*f=comma12. hh='Percent of HHs'*colpctsum<hh>*f=pctfmt.  
      contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll. prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
table (band='Profit Band' all), hh='Total HHs'*sum=' '*f=comma12. hh='Percent of HHs'*colpctsum<hh>*f=pctfmt.  
      contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll. prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
table (products='Number of Products' all), hh='Total HHs'*sum=' '*f=comma12. hh='Percent of HHs'*colpctsum<hh>*f=pctfmt.  
      contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll. prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
table (RM='Relationship Managed' all), hh='Total HHs'*sum=' '*f=comma12. hh='Percent of HHs'*colpctsum<hh>*f=pctfmt.  
      contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll. prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
table (con='Has Consumer Products' all), hh='Total HHs'*sum=' '*f=comma12. hh='Percent of HHs'*colpctsum<hh>*f=pctfmt.  
      contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll. prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
table (com='Has Commercial Products' all), hh='Total HHs'*sum=' '*f=comma12. hh='Percent of HHs'*colpctsum<hh>*f=pctfmt.  
      contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll. prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
keylabel sum=' ' pctsum= ' ' rowpctsum = ' ' all='Total';
format cb_dist distfmt. tenure_yr tenureband. cbr cbr2012fmt. rm con com binary_flag. products products. BAND $BAND.;
run;

Proc tabulate data=bb.bbmain_201212 missing order=data;
class cb_dist tenure_yr band cbr rm top40 con com products/ preloadfmt;
var hh dda: mms: sav: tda: ira: heqb: heqc: mtg: cln: card: boloc: baloc: cls: mcc: contrib1 lckbx rcd wbb deb web_info prods1;
table (top40='Top 40' all), hh='Total HHs'*sum=' '*f=comma12. hh='Percent of HHs'*colpctsum<hh>*f=pctfmt.  
      contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll. prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
keylabel sum=' ' pctsum= ' ' rowpctsum = ' ' all='Total';
format cb_dist distfmt. tenure_yr tenureband. cbr cbr2012fmt. rm con com top40 binary_flag. products products. BAND $BAND.;
run;

/*Title 'Data for Boxplots Balances';*/
/*proc means data=bb.bbmain_201212 q1 qrange median mean;*/
/*output out=bal_box ;*/
/*var dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heqb_amt heqc_amt cln_amt card_amt boloc_amt baloc_amt cls_amt mcc_amt;*/
/*run;*/
/**/
/*Title 'Data for Boxplots Contribution';*/
/*proc means data=bb.bbmain_201212 q1 qrange median mean;*/
/*output out=con_box ;*/
/*var dda_con mms_con sav_con tda_con ira_con mtg_con heqb_con heqc_con cln_con card_con boloc_con baloc_con cls_con mcc_con;*/
/*run;*/

Title;

proc format ;
value quick
   0 = 'None'
   1 = '1'
   2 = '2'
   3 = '3'
   4 = '4'
   5 = '5'
   6-high = '6+';
run;

proc tabulate data=bb.bbmain_201212 missing ;
var dda: mms: sav: tda: ira: heqb: heqc: mtg: cln: card: boloc: baloc: cls: mcc: contrib1 ;
class band products cbr type top40 rm tenure_yr;
table (q1 qrange median mean),(dda_amt mms_amt sav_amt tda_amt  mtg_amt heqb_amt  cln_amt card_amt boloc_amt baloc_amt cls_amt )*f=comma12.2 / nocellmerge;
table (q1 qrange median mean),(dda_con mms_con sav_con tda_con  mtg_con heqb_con  cln_con card_con boloc_con baloc_con cls_con )*f=comma12.2 / nocellmerge;
table (q1 qrange median mean),(band all)*(contrib1 )*f=comma12.2 / nocellmerge;
table (q1 qrange median mean),(products all)*(contrib1 )*f=comma12.2 / nocellmerge;
table (q1 qrange median mean),(cbr all)*(contrib1 )*f=comma12.2 / nocellmerge;
table (N q1 qrange median mean),(cbr all)*(contrib1 )*f=comma12.2 / nocellmerge;
table (N q1 qrange median mean),(top40 all)*(contrib1 )*f=comma12.2 / nocellmerge;
table (N q1 qrange median mean),(rm all)*(contrib1 )*f=comma12.2 / nocellmerge;
table (N q1 qrange median mean),(tenure_yr all)*(contrib1 )*f=comma12.2 / nocellmerge;
format band $band. products quick. cbr cbr2012fmt. rm top40 binary_flag. tenure_yr tenureband.;
run;


proc means sum;
var dda_con mms_con sav_con tda_con ira_con mtg_con heqb_con heqc_con cln_con card_con boloc_con baloc_con cls_con mcc_con;
run;

proc freq data=bb.bbmain_201212;
table con*com;
format con com binary_flag.;
run;


proc tabulate data=bb.bbmain_201212 missing;
var hh contrib1 prods1;
where type ne ''; 
class type;
table (type='Type of HH' all), hh='Total HHs'*sum=' '*f=comma12. hh='Percent of HHs'*colpctsum<hh>*f=pctfmt.  
      contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll. prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
keylabel sum=' ' pctsum= ' ' rowpctsum = ' ' all='Total';
format cb_dist distfmt. tenure_yr tenureband. cbr cbr2012fmt. rm con com binary_flag. products products. BAND $BAND.;
run;

data bb.bbmain_201212;
set bb.bbmain_201212;
contrib2 = .;
if dda_con ne . or mms_con ne . or sav_con ne . or tda_con ne . or  mtg_con ne . or heqb ne . or cln_con ne . 
    or boloc_con ne . or baloc_con ne . or cls_con ne .  then contrib2 = contrib1;
select(type);
	when('Deps') type1 = 1;
	when('Loan') type1 = 2;
	when('Both') type1 = 4;
	otherwise type1 = 4;
end;
run;

proc sort data=bb.bbmain_201212;
by type1;
run;

*when I created contrib1 I made 0 be . by using su, that is creting a lot of noise on  the loan only group, so I created contrib 2 without it.;

proc tabulate data=bb.bbmain_201212 missing ;
var dda: mms: sav: tda: ira: heqb: heqc: mtg: cln: card: boloc: baloc: cls: mcc: contrib2 ;
class band products cbr type;
table (N q1 qrange median mean min max),(type all)*(contrib2)*f=comma12.2 / nocellmerge;
format band $band. products quick. cbr cbr2012fmt.;
run;


proc format;
value $ type_a (notsorted)
	'Deps' = 'Deposits Only '
	'Loan' =  'Loans Only'
	'Both' = 'Deposits and Loans';
run;


data attrmap;
length value $ 9;
input id $ value $ fillcolor $ ;
datalines;
id1 Deps  cxFFB300  
id1 Loan  cxFFB300  
id1 Both  cxFFB300  
;
run;

ods graphics on / width=4.5in height=4.5in border=off imagefmt=png imagename="type";
ods html gpath="C:\Documents and Settings\ewnym5s\My Documents\Business Banking\";
proc sgplot data=bb.bbmain_201212 (keep = type contrib2) dattrmap=attrmap;
where type ne '';
vbox contrib2 / category=type fillattrs=(color=cx007856) outlierattrs=(color=cxAFAAA3) medianattrs=(color=red ) meanattrs=(color=red symbol=DiamondFilled);
yaxis max=3000 min=0 label="Contribution ($)" labelattrs=(weight=Bold);
xaxis valueattrs=(weight=Bold) label="Type of Household" labelattrs=(weight=Bold) fitpolicy=stagger;
format type $type_a. contrib2 dollar12.;
run;
ods graphis close;

proc tabulate data=bb.bbmain_201212;
class cbr type;
table cbr,type*rowpctn=' '*f=pctfmt.;
format type $type_a. cbr cbr2012fmt.;
run;


Proc tabulate data=bb.bbmain_201212 missing order=data;
class cb_dist tenure_yr band cbr rm top40 con com products/ preloadfmt;
var hh dda: mms: sav: tda: ira: heqb: heqc: mtg: cln: card: boloc: baloc: cls: mcc: contrib1 lckbx rcd wbb deb web_info prods1;
table (cbr='CBR' all), band*hh='Total HHs'*sum=' '*f=comma12. band*hh='Percent of HHs'*rowpctsum<hh>*f=pctfmt.  
      band*contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll. band*prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
keylabel sum=' ' pctsum= ' ' rowpctsum = ' ' all='Total';
format cb_dist distfmt. tenure_yr tenureband. cbr cbr2012fmt. rm con com top40 binary_flag. products products. BAND $BAND.;
run;

Proc tabulate data=bb.bbmain_201212 missing order=data;
class SIC_DESC NAICS_Desc Employees1 sales1 customer sic_code NAICS_Code Employees sales private/ preloadfmt;
var hh dda: mms: sav: tda: ira: heqb: heqc: mtg: cln: card: boloc: baloc: cls: mcc: contrib1 lckbx rcd wbb deb web_info prods1;
table (sales1='Sales' all),  hh='Total HHs'*sum=' '*f=comma12.  hh='Percent of HHs'*colpctsum<hh>*f=pctfmt.  
       contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll.  prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
table (employees1='Sales' all),  hh='Total HHs'*sum=' '*f=comma12.  hh='Percent of HHs'*colpctsum<hh>*f=pctfmt.  
       contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll.  prods1='Average Products'*rowpctsum<hh>*f=pctcomma./ nocellmerge misstext='0';
keylabel sum=' ' pctsum= ' ' rowpctsum = ' ' all='Total';
format employees1 $EMPLBANDNEW. sales1 $salesband.;
run;

proc format;
value $ sales (notsorted)
'LESS THAN $500,000' = '<500M'
'$500,000-1 MILLION' = '500M-1MM'
'$1-2.5 MILLION' = '1-2.5MM'
'$2.5-5 MILLION' = '2.5-5MM'
'$5-10 MILLION' = '5-10MM'
'$10-20 MILLION' = '10-20MM'
'$20-50 MILLION' = 'over'
'$50-100 MILLION' = 'over'
'$100-500 MILLION' = 'over'
'$500M - $1 BILLION' = 'over'
other = 'unknbown';
value $ empl (notsorted)
'1-4' = '1 to 4'
'5-9' = '5 to 9'
'10-19' = '10 to 19'
'20-49' = '20 to 49'
'50-99' = '50 to 99'
'100-249' = '100 to 249'
'250-499' = '250 to 500'
'500-999' = '500 to 999'
'1000-4999' = 'over'
'5000-9999' = 'over'
other = 'unknown'; 
run;



                             
proc tabulate data=bb.bbmain_201212 missing order=data;
var dda: mms: sav: tda: ira: heqb: heqc: mtg: cln: card: boloc: baloc: cls: mcc: contrib1 ;
class band products cbr type top40 sales1 employees1 /preloadfmt;

table (N q1 qrange median mean),(sales1 all)*(contrib1 )*f=comma12.2 / nocellmerge;
table (N q1 qrange median mean),(employees1 all)*(contrib1 )*f=comma12.2 / nocellmerge;
format band $band. products quick. cbr cbr2012fmt. employees1 $empl. sales1 $sales.;
run;

proc freq data= bb.bbmain_201212;
table employees1;
run;

proc freq data= bb.bbmain_201212 order=freq;
table NAICS_Desc;
run;


*TABLES BY TENURE;
Proc tabulate data=bb.bbmain_201212 missing order=data;
class cb_dist tenure_yr band cbr rm top40 con com products/ preloadfmt;
var hh dda: mms: sav: tda: ira: heqb: heqc: mtg: cln: card: boloc: baloc: cls: mcc: contrib1 lckbx rcd wbb deb web_info prods1;
table tenure_yr, sum="Product HHs"*(hh dda mms sav tda ira  mtg heqb heqc cln card boloc baloc cls mcc lckbx rcd wbb deb web_info)*f=comma12. / nocellmerge misstext='0';
table tenure_yr, pctsum<hh>="Product Penetration"*(hh dda mms sav tda ira mtg heqb heqc cln card boloc baloc cls mcc lckbx rcd wbb deb web_info)*f=pctfmt. / nocellmerge misstext='0';
table tenure_yr, (dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heqb_amt heqc_amt cln_amt card_amt boloc_amt baloc_amt cls_amt mcc_amt)*
       pctsum<dda mms sav tda ira mtg heqb heqc cln card boloc baloc cls mcc>="Average Balance"*f=pctdoll. / nocellmerge misstext='$0.00';
table tenure_yr, (dda_con mms_con sav_con tda_con ira_con mtg_con heqb_con heqc_con cln_con card_con boloc_con baloc_con cls_con mcc_con)*
       pctsum<dda mms sav tda ira mtg heqb heqc cln card boloc baloc cls mcc>="Average Balance"*f=pctdoll. / nocellmerge misstext='$0.00';
table tenure_yr, (dda_con mms_con sav_con tda_con ira_con mtg_con heqb_con heqc_con cln_con card_con boloc_con baloc_con cls_con mcc_con)*
       pctsum<hh>="Average Balance"*f=pctdoll. / nocellmerge misstext='$0.00';
table tenure_yr,(cbr='Community Bank Region' all)*( hh='Total HHs'*sum=' '*f=comma12.) 
                (cbr='Community Bank Region' all)*( hh='Percent of HHs'*colpctsum<hh>*f=pctfmt. ) 
                (cbr='Community Bank Region' all)*(contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll.)
                (cbr='Community Bank Region' all)*(prods1='Average Products'*rowpctsum<hh>*f=pctcomma.)/ nocellmerge misstext='0';
table tenure_yr,(cb_dist='Distance to Branch' all)*( hh='Total HHs'*sum=' '*f=comma12.) 
                (cb_dist='Distance to Branch' all)*( hh='Percent of HHs'*colpctsum<hh>*f=pctfmt. ) 
                (cb_dist='Distance to Branch' all)*(contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll.)
                (cb_dist='Distance to Branch' all)*(prods1='Average Products'*rowpctsum<hh>*f=pctcomma.)/ nocellmerge misstext='0';
table tenure_yr,(band='Profit Band' all)*( hh='Total HHs'*sum=' '*f=comma12.) 
                (band='Profit Band' all)*( hh='Percent of HHs'*colpctsum<hh>*f=pctfmt. ) 
                (band='Profit Band' all)*(contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll.)
                (band='Profit Band' all)*(prods1='Average Products'*rowpctsum<hh>*f=pctcomma.)/ nocellmerge misstext='0';
table tenure_yr,(products='Number of Products' all)*( hh='Total HHs'*sum=' '*f=comma12.) 
                (products='Number of Products' all)*( hh='Percent of HHs'*colpctsum<hh>*f=pctfmt. ) 
                (products='Number of Products' all)*(contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll.)
                (products='Number of Products' all)*(prods1='Average Products'*rowpctsum<hh>*f=pctcomma.)/ nocellmerge misstext='0';
table tenure_yr,(RM='Relationship Managed' all)*( hh='Total HHs'*sum=' '*f=comma12.) 
                (RM='Relationship Managed' all)*( hh='Percent of HHs'*colpctsum<hh>*f=pctfmt. ) 
                (RM='Relationship Managed' all)*(contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll.)
                (RM='Relationship Managed' all)*(prods1='Average Products'*rowpctsum<hh>*f=pctcomma.)/ nocellmerge misstext='0';
table tenure_yr,(con='Has Consumer Products' all)*( hh='Total HHs'*sum=' '*f=comma12.) 
                (con='Has Consumer Products' all)*( hh='Percent of HHs'*colpctsum<hh>*f=pctfmt. ) 
                (con='Has Consumer Products' all)*(contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll.)
                (con='Has Consumer Products' all)*(prods1='Average Products'*rowpctsum<hh>*f=pctcomma.)/ nocellmerge misstext='0';
table tenure_yr,(com='Has Commercial Products' all)*( hh='Total HHs'*sum=' '*f=comma12.) 
                (com='Has Commercial Products' all)*( hh='Percent of HHs'*colpctsum<hh>*f=pctfmt. ) 
                (com='Has Commercial Products' all)*(contrib1='Average Contribution'*rowpctsum<hh>*f=pctdoll.)
                (com='Has Commercial Products' all)*(prods1='Average Products'*rowpctsum<hh>*f=pctcomma.)/ nocellmerge misstext='0';
keylabel sum=' ' pctsum= ' ' rowpctsum = ' ' all='Total';
format cb_dist distfmt. tenure_yr tenureband. cbr cbr2012fmt. rm con com binary_flag. products products. BAND $BAND.;
run;

proc tabulate data=bb.bbmain_201212 missing ;
var dda: mms: sav: tda: ira: heqb: heqc: mtg: cln: card: boloc: baloc: cls: mcc: contrib1 ;
class band products cbr type top40 TENURE_YR;
table tenure_yr*(q1 qrange median mean),(dda_amt mms_amt sav_amt tda_amt  mtg_amt heqb_amt  cln_amt card_amt boloc_amt baloc_amt cls_amt )*f=comma12.2 / nocellmerge;
table tenure_yr*(q1 qrange median mean),(dda_con mms_con sav_con tda_con  mtg_con heqb_con  cln_con card_con boloc_con baloc_con cls_con )*f=comma12.2 / nocellmerge;
table tenure_yr*(q1 qrange median mean),(band all)*(contrib1 )*f=comma12.2 / nocellmerge;
table tenure_yr*(q1 qrange median mean),(products all)*(contrib1 )*f=comma12.2 / nocellmerge;
table tenure_yr*(q1 qrange median mean),(cbr all)*(contrib1 )*f=comma12.2 / nocellmerge;
table tenure_yr*(N q1 qrange median mean),(cbr all)*(contrib1 )*f=comma12.2 / nocellmerge;
table tenure_yr*(N q1 qrange median mean),(top40 all)*(contrib1 )*f=comma12.2 / nocellmerge;
format band $band. products quick. cbr cbr2012fmt. tenure_yr tenureband.;
run;


proc format;
value myten (notsorted)
	0<-<2 = 'Up to 2 Years'
	2-high = '2+ Years'
	other = 'other';
run;


proc tabulate data=bb.bbmain_201212 missing ;
var dda: mms: sav: tda: ira: heqb: heqc: mtg: cln: card: boloc: baloc: cls: mcc: contrib1 ;
class band products cbr type top40 TENURE_YR;
table tenure_yr*(N q1 qrange median mean),(dda_amt mms_amt sav_amt tda_amt  mtg_amt heqb_amt  cln_amt card_amt boloc_amt baloc_amt cls_amt )*f=comma12.2 / nocellmerge;
table tenure_yr*(N q1 qrange median mean),(dda_con mms_con sav_con tda_con  mtg_con heqb_con  cln_con card_con boloc_con baloc_con cls_con )*f=comma12.2 / nocellmerge;
format band $band. products quick. cbr cbr2012fmt. tenure_yr myten.;
run;

proc print data=bb.bbmain_201212 ;
where tenure_yr gt 0 and tenure_yr lt 2 and cls ge 1;
var cls_amt tenure_yr;
format cls_amt dollar24. tenure_yr comma6.2;
run;


proc format library=sas cntlout=wip.formats;
select $band cbr2012fmt tenureband distfmt binary_flag  $EMPLBANDNEW  $salesband;
run;


proc freq data=bb.bbmain_201212 ;
table type;
run;

proc means data=bb.bbmain_201212 missing;
var tenure_yr cb_dist;
run;

proc means data=bb.bbmain_201212 missing;
where cb_dist gt 0;;
var  cb_dist;
run;

proc means data=data.main_201212 missing;

var tenure_yr distance;
run;

proc freq data=bb.bbmain_201212;
table (dda mms sav tda baloc boloc cln cls lckbx mcc)*prods1 / missing;
table prods1 / missing;
format prods1 quick.;
run;

proc freq data=bb.bbmain_201212;
table (HEQB MTG CARD)*prods1 / NOCOL NOROW NOPERCENT missing;
format prods1 quick.;
run;


