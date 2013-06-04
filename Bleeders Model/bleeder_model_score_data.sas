/**************************************************************
** Project:  Bleeder Logistic Model Development
** Analyst:  Junli Zhou
** Date:     1/12/2011;
** Location: c:\projects\Bleeder Logistic Model Development\Programs_New\bleeder_model_score_data.sas;
** Description: This file does the following:
**	a. recode missing value for only significant vars;
**	b. recode only significant vars, where needed;
**  c. transform only significant vars, where needed;
**  d. score both M and V groups;
**  e. create deciles for gains table;
***************************************************************/

/* Assign LIBREF for the Project & set page and line sizes*/

options ps=50  ls=98;


/* Modify vars for M and V groups */

data bleeder.decile;
  set bleeder.bleeders3;

  if group2='V' then do;
     target2=target;
	 target=.;
  end;

/* Deposits */
if deposits	ge		324554		then	deposits2	=			324554;		else deposits2=deposits;
if deposits2=. 	then deposits2=54751;

/* MMS_Penet - No coding needed */

/* Int_Rate2I */
if int_rate=.		then int_rate2=1.27; else int_rate2=int_rate;
INT_RATE2I=(1/(INT_RATE2+.01));

/* TDA_Early_Mature - No coding needed */

/* ATM_Txns - No coding needed */

/* CSW_Inquiries - No coding needed */

/* cqi_web - No coding needed */

/* seg4 - No coding needed */
seg4=(lifecycle=4);

/* seg5 - No coding needed */
seg5=(lifecycle=5);

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




/* Calculate Deciles */

/* Compare Score vs Pred */
ods output parameterestimates = parmsSTpred; /*work.parms used for coefficient adjustment*/

proc logistic data=bleeder.decile descending;
  model target = deposits2
  				 MMS_Penet
				 INT_RATE2I
				 TDA_early_mature
				 ATM_TXNS
				 CSW_INQUIRIES
				 cqi_web
				 seg4
				 seg5
				 tenure2l;
               
			   output out=bleeder.preddecile pred=pred;
run;

proc corr data=bleeder.preddecile;
  var score pred;
  where group2='M';
run;

proc sort data=bleeder.preddecile;
  by group2 descending pred;
run;


/* Split into M and V Groups */

data bleeder.decile_m_grp
	 bleeder.decile_v_grp;
  set bleeder.preddecile;

  if group2='M' then output bleeder.decile_m_grp;
  else output bleeder.decile_v_grp;

run;

/* Create Decile Assignment for Each Record for M Group */

data bleeder.decile_assign_m_grp;
  set bleeder.decile_m_grp;

  if 1<=_n_<=2466 then tile='01';
  if 2467<=_n_<=4932 then tile='02';
  if 4933<=_n_<=7398 then tile='03';
  if 7399<=_n_<=9864 then tile='04';
  if 9865<=_n_<=12330 then tile='05';
  if 12331<=_n_<=14796 then tile='06';
  if 14797<=_n_<=17262 then tile='07';
  if 17263<=_n_<=19728 then tile='08';
  if 19729<=_n_<=22193 then tile='09';
  if 22194<=_n_<=24658 then tile='10';

run;

proc freq data=bleeder.decile_assign_m_grp;
  tables tile*target;
  title 'Decile Distribution for M Group';
run;


/* Create Decile Assignment for Each Record for V Group */

data bleeder.decile_assign_v_grp;
  set bleeder.decile_v_grp;

  if 1<=_n_<=2461 then tile='01';
  if 2462<=_n_<=4922 then tile='02';
  if 4923<=_n_<=7383 then tile='03';
  if 7384<=_n_<=9844 then tile='04';
  if 9845<=_n_<=12305 then tile='05';
  if 12306<=_n_<=14766 then tile='06';
  if 14767<=_n_<=17227 then tile='07';
  if 17228<=_n_<=19687 then tile='08';
  if 19688<=_n_<=22147 then tile='09';
  if 22148<=_n_<=24607 then tile='10';

run;

proc freq data=bleeder.decile_assign_v_grp;
  tables tile*target2;
  title 'Decile Distribution for V Group';
run;



*********************************************************************;
*********************************************************************;
**** STOP HERE, CODE BELOW NOT USED, FOR REFERENCE ONLY			  ***;
*********************************************************************;

/* Original Tile Creation Code - Not Used for the Bleeder Model */

data bleeder.preddecile2;
  set bleeder.preddecile;
  if target=. then target=target2;
  if group2='M' then tile=10 - (int(wt2/20393)+1);
  else if group='V' then tile=10 - (int((wt2-203926)/20381)+1);
run;

/*
proc freq data=pred1;
  title 'Credit Attribute Model by Decile for Convert';
  tables group*tile*response /nocol nocum nopercent;   True response people
  weight weight;  Weight will screw up # of Responders/DON'T USE THIS PART!
                  Use Step 2 and Step 3 below
run; 
*/

proc freq data=citibank.predstate;
  title 'Credit & Hilton Attribute Model by Decile for Resp';
  tables group*tile*resp /nocol nocum nopercent;
  weight weight;
run;



/* Produce PROC MEANS output for PowerPoint Presentation */

proc means data=citibank.pred2 mean;
  where group='M';
  class tile;
  var zstaybf
  	  ztenureb
	  natt17r
	  natt22
	  ztenurea
	  zutlall
	  natt68
	  natt26
	  zavghelr
	  natt33r
	  natt30
	  natt67
	  nfico;
	  weight weight;
run;



proc means data=citibank.decilestate n nmiss mean;
  var natt17r
      natt22s
	  natt26
	  natt30
	  natt33r
	  natt68
	  zavghelr
	  znatt67a
	  zutlall
	  zstaybf
	  ztenurea
	  ztenureb
	  stateCO
	  statePA;
  where group='M';
  title 'Re-run with State, using citibank.decilestate';
run;
