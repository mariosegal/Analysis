/**************************************************************
** Project:  Score WT Population
** Analyst:  Junli Zhou
** Date:     4/11/2011 
** Location: c:\projects\Bleeder Logistic Model Development\Programs_New\bleeder_model_score_data_wt.sas ;
** Description: This file does the following:
**  a. combine Consumer and Business (bleeder.WT_con and bleeder.WT_bus) ;
**	a. check WT data quality and recode missing value for model predictor vars ;
**	b. recode model predictor vars, where needed ;
**  c. transform model predictor vars, where needed ;
**  d. score WT data ;
**  e. create deciles table ;
***************************************************************/

/* Combine bleeder.WT_con and bleeder.WT_con */

data wt_con1;
  set bleeder.wt_con;
  lob='C';
run;

data wt_bus1;
  set bleeder.wt_bus;
  lob='B';
run;

data bleeder.wt_combined;
  set wt_con1 wt_bus1;
  deposits=wt_dda_mms_sav+wt_tda_ira;
run;




/* Modify vars for scoring */

data bleeder.decile_wt;
  set bleeder.wt_combined;

  
/* Deposits2 */

/*
proc univariate data=bleeder.wt_combined;
  var deposits;
run;
*/


if deposits	ge		324554		then	deposits2	=			324554;		/* 324554 = from original model */
   else deposits2=deposits;
if deposits2=. 	then deposits2=19293.19;

/* MMS_Penet */
if mms=1 then MMS_Penet = 1;
else MMS_Penet=0;

/* Int_Rate2I */

/*
proc univariate data=bleeder.partners;
  var cd_rate;
run;
*/

if cd_int_rate=.		then int_rate2=0; else int_rate2=cd_int_rate;
INT_RATE2I=(1/(INT_RATE2+.01));

/* TDA_Early_Mature */

if urity_date<='31dec2011'd and urity_date^=. then TDA_Early_Mature=1;
else TDA_Early_Mature=0;

/* ATM_Txns  */

ATM_txns=tm_txn;

/* CSW_Inquiries - No Re-coding needed */

CSW_Inquiries=vru;

/* cqi_web -  */

if web=1 then cqi_web=1;
else cqi_web=0;

/* seg4 - Mass Affluent w/o Kids */

if seg=4 then seg4=1;
else seg4=0;

/* seg5 - Mass Affluent w/ Kids */

if seg=5 then seg5=1;
else seg5=0;

/* tenure2l */

/*
proc univariate data=bleeder.wt_combined;
  var tenure;
run;
*/

if tenure=. then tenure2=15.01;
else if tenure   ge		20			then	tenure2		=			20;			
else tenure2=tenure;
tenure2l=log(tenure2+.01);


/* Model Coefficients */

  z = -1.8694
		+ 0.000005632*deposits2
		+ 0.4642*MMS_penet
		+ 0.00907*INT_RATE2I
		+ 0.6951*TDA_early_mature
		+ 0.0306*ATM_TXNS
		+ 0.0974*CSW_INQUIRIES
		+ 0.3832*cqi_web
		+ 0.1776*seg4
		+ -0.2622*seg5
		+ -0.2576*tenure2l;

  score = (1/(1+2.718281828**(-z)));

run;


/* Create Decile Assignment for Entire WT Population */

proc sort data=bleeder.decile_wt;
  by descending score;
run;


data bleeder.decile_wt_assign;
  set bleeder.decile_wt;

  if 1<=_n_<=19517 then tile='01';
  if 19518<=_n_<=39034 then tile='02';
  if 39035<=_n_<=58551 then tile='03';
  if 58552<=_n_<=78068 then tile='04';
  if 78069<=_n_<=97585 then tile='05';
  if 97586<=_n_<=117102 then tile='06';
  if 117103<=_n_<=136619 then tile='07';
  if 136620<=_n_<=156136 then tile='08';
  if 156137<=_n_<=175653 then tile='09';
  if 175654<=_n_<=195172 then tile='10';

run;

proc freq data=bleeder.decile_wt_assign;
  tables tile*lob;
  title 'Decile Distribution for WT Customers';
run;


/* Split into Consumer and Business */

data decile_wt_assign_con
	 decile_wt_assign_bus;
  set bleeder.decile_wt_assign;

  if lob='C' then output decile_wt_assign_con;
  else output decile_wt_assign_bus;

run;


/* Create Decile Assignment for WT Consumer Population */

proc sort data=decile_wt_assign_con;
  by descending score;
run;


data bleeder.decile_wt_assign_con;
  set decile_wt_assign_con;

  if 1<=_n_<=16912 then tile='01';
  if 16913<=_n_<=33824 then tile='02';
  if 33825<=_n_<=50736 then tile='03';
  if 50737<=_n_<=67648 then tile='04';
  if 67649<=_n_<=84560 then tile='05';
  if 84561<=_n_<=101472 then tile='06';
  if 101473<=_n_<=118384 then tile='07';
  if 118385<=_n_<=135296 then tile='08';
  if 135297<=_n_<=152208 then tile='09';
  if 152209<=_n_<=169123 then tile='10';

run;

proc freq data=bleeder.decile_wt_assign_con;
  tables tile;
  title 'Decile Distribution for WT Consumer';
run;


/* Create Decile Assignment for WT Business Population */

proc sort data=decile_wt_assign_bus;
  by descending score;
run;


data bleeder.decile_wt_assign_bus;
  set decile_wt_assign_bus;

  if 1<=_n_<=2605 then tile='01';
  if 2606<=_n_<=5210 then tile='02';
  if 5211<=_n_<=7815 then tile='03';
  if 7816<=_n_<=10420 then tile='04';
  if 10421<=_n_<=13025 then tile='05';
  if 13026<=_n_<=15630 then tile='06';
  if 15631<=_n_<=18235 then tile='07';
  if 18236<=_n_<=20840 then tile='08';
  if 20841<=_n_<=23445 then tile='09';
  if 23446<=_n_<=26049 then tile='10';

run;

proc freq data=bleeder.decile_wt_assign_bus;
  tables tile;
  title 'Decile Distribution for WT Business';
run;

/* Get Decile Distribution with Balance for WT PowerPoint */

proc means data=bleeder.decile_wt_assign_con n mean sum;
  var wt_dda_mms_sav wt_tda_ira;
  class tile;
  title 'Scored WT - Consumer';
run;


proc means data=bleeder.decile_wt_assign_bus n mean sum;
  var wt_dda_mms_sav wt_tda_ira;
  class tile;
  title 'Scored WT - Business Banking';
run;

