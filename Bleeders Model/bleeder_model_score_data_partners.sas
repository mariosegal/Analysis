/**************************************************************
** Project:  Bleeder Logistic Model Development
** Analyst:  Junli Zhou
** Date:     3/8/2011;
** Location: c:\projects\Bleeder Logistic Model Development\Programs_New\bleeder_model_score_data_partners.sas;
** Description: This file does the following:
**	a. check Partners data quality and recode missing value for model predictor vars ;
**	b. recode model predictor vars, where needed;
**  c. transform model predictor vars, where needed;
**  d. score Partners data;
**  e. create deciles for gains table;
***************************************************************/

/* Check Target Variable for Entire Population: Partners vs Provident */

proc freq data=bleeder.partners;
  tables bleeder;  /* 3.15% = Partners Bleeders */
run;

proc freq data=bleeder.bleeders;
  tables group;  /* A=Bleeder, B=Non-Bleeder */  /* 3.96% = Provident Bleeders */
run;

/* Check Target Variable for Heavy Bleeder Population: Partners vs ZProvident */

data heavy_bleeders;
  set bleeder.partners;
  if bleeder=1 then output heavy_bleeders;
  else if apr08_deposits>=10000 then output heavy_bleeders;
run;

proc freq data=heavy_bleeders;
  tables bleeder;  /* 14.85% = Partners Heavy Bleeders */
run;

proc freq data=bleeder.bleeders3;
  tables target;   /* 18.74% = Provident Heavy Bleeders */
run;



/* Modify vars for scoring */

data bleeder.decile_partners;
  set bleeder.partners;

  
/* Deposits2 */

/*
proc univariate data=bleeder.partners;
  var apr08_deposits;
run;
*/

deposits=apr08_deposits;
if deposits	ge		324554		then	deposits2	=			324554;		else deposits2=deposits;
if deposits2=. 	then deposits2=12954.354;

/* MMS_Penet */
if mms=1 then MMS_Penet = 1;
else MMS_Penet=0;

/* Int_Rate2I */

/*
proc univariate data=bleeder.partners;
  var cd_rate;
run;
*/

if cd_rate=.		then cd_rate2=4.62; else cd_rate2=cd_rate;
int_rate2=cd_rate2-2.49;
INT_RATE2I=(1/(INT_RATE2+.01));

/* TDA_Early_Mature - */

TDA_Early_Mature=Early_TDA_Maturity;

/* ATM_Txns - No Re-coding needed */

/* CSW_Inquiries - No Re-coding needed */

/* cqi_web -  */

if cqi in (3, 4, 5) then cqi_web=1;
else cqi_web=0;

/* seg4 - Mass Affluent w/o Kids */
seg4=MA_No_Kids;

/* seg5 - Mass Affluent w/ Kids */
seg5=MA_Families;

/* tenure2l */
if tenure   ge		20			then	tenure2		=			20;			else tenure2=tenure;
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


/* Create Decile Assignment for Entire Partners Population */

proc sort data=bleeder.decile_partners;
  by descending score;
run;


data bleeder.decile_partners_assign;
  set bleeder.decile_partners;

  if 1<=_n_<=11707 then tile='01';
  if 11708<=_n_<=23415 then tile='02';
  if 23416<=_n_<=35123 then tile='03';
  if 35124<=_n_<=46831 then tile='04';
  if 46832<=_n_<=58539 then tile='05';
  if 58540<=_n_<=70247 then tile='06';
  if 70248<=_n_<=81955 then tile='07';
  if 81956<=_n_<=93663 then tile='08';
  if 93664<=_n_<=105371 then tile='09';
  if 105372<=_n_<=117079 then tile='10';

run;

proc freq data=bleeder.decile_partners_assign;
  tables tile*bleeder;
  title 'Decile Distribution for Partners Acquisition';
run;




/* Create Decile Assignment for Partners Heavy Bleeder Population */

data bleeder.decile_partners_heavy_bleeders;
  set bleeder.decile_partners;
  
  if bleeder=1 then output bleeder.decile_partners_heavy_bleeders;
  else if deposits2 >=10000 then output bleeder.decile_partners_heavy_bleeders;

run;

proc sort data=bleeder.decile_partners_heavy_bleeders;
  by descending score;
run;


data bleeder.decile_partners_heavy_bl_assign;
  set bleeder.decile_partners_heavy_bleeders;

  if 1<=_n_<=2487 then tile='01';
  if 2488<=_n_<=4974 then tile='02';
  if 4975<=_n_<=7461 then tile='03';
  if 7462<=_n_<=9948 then tile='04';
  if 9949<=_n_<=12435 then tile='05';
  if 12436<=_n_<=14922 then tile='06';
  if 14923<=_n_<=17409 then tile='07';
  if 17410<=_n_<=19896 then tile='08';
  if 19897<=_n_<=22383 then tile='09';
  if 22384<=_n_<=24870 then tile='10';

run;

proc freq data=bleeder.decile_partners_heavy_bl_assign;
  tables tile*bleeder;
  title 'Decile Distribution for Partners Heavy Bleeders Pop';
run;


