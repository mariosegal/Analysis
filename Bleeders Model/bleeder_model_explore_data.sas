/**************************************************************
** Project:  Bleeder Logistic Model Development
** Analyst:  Junli Zhou
** Date:     1/12/2011;
** Location: c:\projects\Bleeder Logistic Model Development\Programs_New\bleeder_model_explore_data.sas;
** Description: This file does the following:
**	a. create new vars based on existing vars;
**	b. use PROC MEANS and PROC UNIVARIATE to explore num vars (n nmiss mean std
**	   min max kurt skew);
**	c. trim outliers where needed (run trimming macro);
**  d. create categorical/flag vars for num vars based on
**     Knowledge Seeker/CHAID results and use them again
**	   in the Crusher univariate analysis;
**  e. impute missing data where needed (based on KS/CHAID);
**  f. create dummy vars for char/categorical vars from
**     the univariate analysis using the Crusher System;
***************************************************************/

/* Assign LIBREF for the Project & set page and line sizes*/

options ps=50  ls=80;

libname bleeder 'c:\PROJECTS\Bleeder Logistic Model Development\Data';
run;


/* Run PROC MEANS and PROC UNIVARIATE for quick data exploration */

options ps=50  ls=80;
proc means data=bleeder.bleeders_modgrp n nmiss mean min max kurt skew;
  var ixi;
run;

proc univariate data=bleeder.bleeders_modgrp;
  var ixi deposits loans IRA MMS SAV TDA SEC;
  title 'Proc Univariate for Selected Bleeder Model Variables';
run;


*********************************************************************;
**** trim outliers where needed, using trim.sas macro     		 ****;
*********************************************************************;

*** Create bleeder.modgrp in work directory;

data bleeders_modgrp;
  set bleeder.bleeders_modgrp;
run;

 %include 'c:\PROJECTS\Brann Files\Hilton\trim.sas';
 %let dsn = bleeders_modgrp;
 %let cutoff = 10;
 
 %trimout(ixi); %trimout(deposits); %trimout(loans); %trimout(ira); %trimout(mms);
 %trimout(sav); %trimout(tda); %trimout(sec);


/* Apply SAS work.code.sas trimming program from running trim.sas macro to remove outliers */

data modgrp1;
  set bleeder.bleeders_modgrp;

/* From sas output file called CODE in WORK directory */

if ixi		ge		7540710		then	ixi2		=			7540710; 	else ixi2=ixi;
if deposits	ge		324554		then	deposits2	=			324554;		else deposits2=deposits;
if loans	ge		145471		then	loans2		=			145471;		else loans2=loans;
if IRA		ge		62228		then	IRA2		=			62228;		else IRA2=IRA;
if MMS		ge		184648		then	MMS2		=			184648;		else MMS2=MMS;
if SAV		ge		98611		then	SAV2		=			98611;		else SAV2=SAV;
if TDA		ge		199124		then	TDA2		=			199124;		else TDA2=TDA;
if SEC		ge		60018		then	SEC2		=			60018;		else SEC2=SEC;
if tenure   ge		20			then	tenure2		=			20;			else tenure2=tenure;

run;


/* Impute missing data using mean value */

data modgrp2;
  set modgrp1;

  if ixi2=. 		then ixi2=529596;
  if deposits2=. 	then deposits2=54751;
  if loans2=. 		then loans2=6237;
  if IRA2=. 		then IRA2=2677;
  if MMS2=.			then MMS2=15056;
  if SAV2=. 		then SAV2=9122;
  if TDA2=.			then TDA2=16486;
  if SEC=.			then SEC2=2870;
  if int_rate=.		then int_rate2=1.27; else int_rate2=int_rate;

run;



/* Run PROC MEANS again for all num vars */

/* for bleeders */

proc means data=modgrp2 mean std n;
  var ixi2 deposits2 loans2 ira2 mms2 sav2 tda2 sec2 
	  int_rate vru_inquiries vru_txns web_inquiries web_txns;
  where target=1;
  output out=ttestbleeder;
run;

proc transpose data=ttestbleeder out=ttestbleeder2;
  by _type_;
run;

/* for Non-bleeders */

proc means data=modgrp2 mean std n;
  var ixi2 deposits2 loans2 ira2 mms2 sav2 tda2 sec2 
	  int_rate vru_inquiries vru_txns web_inquiries web_txns;
  where target=0;
  output out=ttestnonbleeder;
run;

proc transpose data=ttestnonbleeder out=ttestnonbleeder2;
  by _type_;
run;



/* Run PROC CORR with RANK option to manually check collinearity */

proc corr data=modgrp2 rank noprob;
  var ixi2 deposits2 loans2 ira2 mms2 sav2 tda2 sec2 
	  int_rate vru_inquiries vru_txns web_inquiries web_txns;
  title 'Run Proc Corr to Check Collinearity';
run;


***********************************************************************************;
**** perform ttest of data to check significance between bleeder vs non-bleeder ***;
***********************************************************************************;

ods output Statistics = stats;
  proc ttest data=modgrp2;
    class target;
	/*weight weight;*/
	var ixi2 deposits2 loans2 ira2 mms2 sav2 tda2 sec2 
	  int_rate vru_inquiries vru_txns web_inquiries web_txns;
  run;








