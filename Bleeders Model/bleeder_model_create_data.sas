/**************************************************************************************************
** Project:  Bleeder Logistic Model Development
** Analyst:  Junli Zhou
** Date:     1/12/2011;
** Location: c:\projects\Bleeder Logistic Model Development\Programs_New\bleeder_create_data.sas;
** Description: This file does the following:
**	a. creates modeling file;
**	b. converts char vars and num vars;
**	c. splits file into M and V groups;
** Data Source:
**  a. first file - tab delimited - bleeders.txt (no include Early_Maturity_Flag, SAV_Penet, etc.)
**  b. second file - tab delimited - bleeders_20110114.txt (includes Early_Maturity_Flag, etc.)
**************************************************************************************************/

/* Assign LIBREF for the Project */

libname bleeder 'c:\PROJECTS\Bleeder Logistic Model Development\Data';
run;


/* Run PROC CONTENTS for initial data review */

options ps=50  ls=80;

proc contents data=bleeder.bleeders_20110114 position;
  title 'Data for Bleeder Logistic Model';
  run;

/* Create Final Model Development Universe*/

data bleeder.bleeders2;
  set bleeder.bleeders_20110114;
  if group='A' then target=1;
  else target=0;
  if group='A' then output bleeder.bleeders2;
  else if deposits>=10000 then output bleeder.bleeders2;
run;

/* Separate Modeling Universe into M and V */

data bleeder.bleeders3;
  set bleeder.bleeders2;

  rand = ranuni(7698);

  if rand<=0.50 then group2='M';
  else group2='V';
 
run;

/* Verify M and V split by Target Var */

proc freq data=bleeder.bleeders3;
  tables target*group2;
  title 'Target Var Dist for M vs V Groups';
run;

proc freq data=bleeder.bleeders3;
  tables cqi dda;
  title 'Final Modeling Universe (M + V): CQI DDA';
run;

/* Get Model Building Group, group2=M */


data bleeder.bleeders_modgrp;
  set bleeder.bleeders3 ;

  seg1=(lifecycle=1);
  seg2=(lifecycle=2);
  seg3=(lifecycle=3);
  seg4=(lifecycle=4);
  seg5=(lifecycle=5);
  seg6=(lifecycle=6);
  seg7=(lifecycle=7);

 /* flag_MMS=(mms>=1000);
  flag_SAV=(sav>=1000);
  flag_TDA=(tda>=1000);
  flag_IRA=(ira>=1000);
  flag_SEC=(sec>=1000); */			/* No need to calcualte, Oliver's second file has them */
  
  if group2 = 'M';

 run;


proc contents data=bleeder.bleeders_modgrp position;
title 'Bleeder Logistic Model Building Group';
run;
