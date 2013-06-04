data model_training;
set bbseg.model_training;
s3 = 0;
if segment eq 3 then s3=1;
s5 = 0;
if segment eq 5 then s5=1;
s1 = 0;
if segment eq 1 then s1=1;
s2 = 0;
if segment eq 2 then s2=1;
s4 = 0;
if segment eq 4 then s4=1;
s6 = 0;
if segment eq 6 then s6=1;
run;

proc contents data=model_training varnum short;
run;

proc logistic data=model_training outmodel=bbseg.s3_fwd;
model s3(event='1') = dda_amt sav_amt cln_amt baloc_amt sign_ons  vpos_num boloc 
                      deptkt curdep_num curdep_amt chkpd ach winfo_num
					  cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out 
					  dda_con mms_con  sav_con  cln_con boloc_con baloc_con tenure_yr contrib1
					  cln boloc baloc  deb  wbb mcc  con web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt
                      a  c  / ctable selection=f;

run; quit;

proc logistic data=model_training outmodel=bbseg.s3_back;
model s3(event='1') = dda_amt sav_amt cln_amt baloc_amt sign_ons  vpos_num boloc 
                      deptkt curdep_num curdep_amt chkpd ach winfo_num
					  cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out 
					  dda_con mms_con  sav_con  cln_con boloc_con baloc_con tenure_yr contrib1
					  cln boloc baloc  deb  wbb mcc  con web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt
                      a  c  / ctable selection=b;

run; quit;

proc logistic data=model_training outmodel=bbseg.s3_step;
model s3(event='1') = dda_amt sav_amt cln_amt baloc_amt sign_ons  vpos_num boloc 
                      deptkt curdep_num curdep_amt chkpd ach winfo_num
					  cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out 
					  dda_con mms_con  sav_con  cln_con boloc_con baloc_con tenure_yr contrib1
					  cln boloc baloc  deb  wbb mcc  con web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt
                      a  c  / ctable selection=s;

run; quit;

proc logistic inmodel=bbseg.s3_back;
score data=model_training (rename=(s3=actual)) out=s3_back_scored;
run;

proc freq data=s3_back_scored;
table actual*I_s3;
run;

proc logistic inmodel=bbseg.s3_fwd;
score data=model_training (rename=(s3=actual)) out=s3_fwd_scored;
run;

proc freq data=s3_fwd_scored;
table actual*I_s3;
run;

proc logistic inmodel=bbseg.s3_step;
score data=model_training (rename=(s3=actual)) out=s3_step_scored;
run;

proc freq data=s3_step_scored;
table actual*I_s3;
run;


*model s3(event='1') =  dda_amt mms_amt  heqc_amt cln_amt baloc_amt   mcc_amt   sign_ons checks  
           atmo_num atmt_num atmo_amt atmt_amt vpos_num mpos_num vpos_amt mpos_amt deptkt curdep_num curdep_amt chkpd ach winfo_num     
           cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out dda_con mms_con sav_con tda_con heqc_con cln_con 
           boloc_con baloc_con tenure_yr contrib1 dda mms sav tda trs heqc cln card boloc baloc  wbb deb mcc lckbx rcd bbfb

			con 
           com web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt 

a b c d _1_to_2mm _10_to_20mm _2p5_to_5mm _20_to_50mm _5_to_10mm 
           _50_to_100mm _500k_to_1mm to500k e_1to4 e_10_19 e_100_249 e_20_49 e_5_9 e_50_99 / influence ;
*model s6(event='1') =  dda_amt mms_amt sav_amt tda_amt heqc_amt cln_amt baloc_amt  cls_amt mcc_amt tenure  sign_ons checks  
           atmo_num atmt_num atmo_amt atmt_amt vpos_num mpos_num vpos_amt mpos_amt deptkt curdep_num curdep_amt chkpd ach winfo_num     
           cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out dda_con mms_con sav_con tda_con heqc_con cln_con 
           boloc_con baloc_con tenure_yr contrib1 dda mms sav tda trs heqc cln card boloc baloc cls wbb deb mcc lckbx rcd bbfb con 
           com web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt a b c d _1_to_2mm _10_to_20mm _2p5_to_5mm _20_to_50mm _5_to_10mm 
           _50_to_100mm _500k_to_1mm to500k e_1to4 e_10_19 e_100_249 e_20_49 e_5_9 e_50_99 / ;
run;
quit;

*##############################################################################;
*S2 MODEL;

proc logistic data=model_training outmodel=bbseg.s2_fwd;
model s2(event='1') = dda_amt sav_amt cln_amt baloc_amt sign_ons  vpos_num boloc 
                      deptkt curdep_num curdep_amt chkpd ach winfo_num
					  cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out 
					  dda_con mms_con  sav_con  cln_con boloc_con baloc_con tenure_yr contrib1
					  cln boloc baloc  deb  wbb mcc  con web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt
                      a  c  / ctable selection=f;

run; quit;

proc logistic data=model_training outmodel=bbseg.s2_back;
model s2(event='1') = dda_amt sav_amt cln_amt baloc_amt sign_ons  vpos_num boloc 
                      deptkt curdep_num curdep_amt chkpd ach winfo_num
					  cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out 
					  dda_con mms_con  sav_con  cln_con boloc_con baloc_con tenure_yr contrib1
					  cln boloc baloc  deb  wbb mcc  con web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt
                      a  c  / ctable selection=b;

run; quit;

proc logistic data=model_training outmodel=bbseg.s2_step;
model s2(event='1') = dda_amt sav_amt cln_amt baloc_amt sign_ons  vpos_num boloc 
                      deptkt curdep_num curdep_amt chkpd ach winfo_num
					  cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out 
					  dda_con mms_con  sav_con  cln_con boloc_con baloc_con tenure_yr contrib1
					  cln boloc baloc  deb  wbb mcc  con web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt
                      a  c  / ctable selection=s;

run; quit;

proc logistic inmodel=bbseg.s2_back;
score data=model_training (rename=(s2=actual)) out=s2_back_scored;
run;
title 'Backward';
proc freq data=s2_back_scored;
table actual*I_s2;
run;

proc logistic inmodel=bbseg.s2_fwd;
score data=model_training (rename=(s2=actual)) out=s2_fwd_scored;
run;
title 'Forward';
proc freq data=s2_fwd_scored;
table actual*I_s2;
run;

proc logistic inmodel=bbseg.s2_step;
score data=model_training (rename=(s2=actual)) out=s2_step_scored;
run;
title 'Stepwise';
proc freq data=s2_step_scored;
table actual*I_s2;
run;

*#macro;
%macro mylog(target);
proc logistic data=model_training outmodel=bbseg.&target._fwd;
model &target(event='1') = dda_amt sav_amt cln_amt baloc_amt sign_ons  vpos_num boloc 
                      deptkt curdep_num curdep_amt chkpd ach winfo_num
					  cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out 
					  dda_con mms_con  sav_con  cln_con boloc_con baloc_con tenure_yr contrib1
					  cln boloc baloc  deb  wbb mcc  con web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt
                      a  c  / ctable selection=f;

run; quit;

proc logistic data=model_training outmodel=bbseg.&target._back;
model &target(event='1') = dda_amt sav_amt cln_amt baloc_amt sign_ons  vpos_num boloc 
                      deptkt curdep_num curdep_amt chkpd ach winfo_num
					  cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out 
					  dda_con mms_con  sav_con  cln_con boloc_con baloc_con tenure_yr contrib1
					  cln boloc baloc  deb  wbb mcc  con web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt
                      a  c  / ctable selection=b;

run; quit;

proc logistic data=model_training outmodel=bbseg.&target._step;
model &target(event='1') = dda_amt sav_amt cln_amt baloc_amt sign_ons  vpos_num boloc 
                      deptkt curdep_num curdep_amt chkpd ach winfo_num
					  cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out 
					  dda_con mms_con  sav_con  cln_con boloc_con baloc_con tenure_yr contrib1
					  cln boloc baloc  deb  wbb mcc  con web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt
                      a  c  / ctable selection=s;

run; quit;

proc logistic inmodel=bbseg.&target._back;
score data=model_training (rename=(&target=actual)) out=&target._back_scored;
run;
title 'Backward';
proc freq data=&target._back_scored;
table actual*I_&target;
run;

proc logistic inmodel=bbseg.&target._fwd;
score data=model_training (rename=(&target=actual)) out=&target._fwd_scored;
run;
title 'Forward';
proc freq data=&target._fwd_scored;
table actual*I_&target;
run;

proc logistic inmodel=bbseg.&target._step;
score data=model_training (rename=(&target=actual)) out=&target._step_scored;
run;
title 'Stepwise';
proc freq data=&target._step_scored;
table actual*I_&target;
run;

%mend;

%mylog(s4)

*try all again, to compare;
proc logistic data=model_training outmodel=bbseg.s3_all_fwd;
model s3(event='1') =  dda_amt mms_amt sav_amt tda_amt heqc_amt cln_amt baloc_amt  cls_amt mcc_amt tenure  sign_ons checks  
           atmo_num atmt_num atmo_amt atmt_amt vpos_num mpos_num vpos_amt mpos_amt deptkt curdep_num curdep_amt chkpd ach winfo_num     
           cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out dda_con mms_con sav_con tda_con heqc_con cln_con 
           boloc_con baloc_con tenure_yr contrib1 dda mms sav tda trs heqc cln card boloc baloc cls wbb deb mcc lckbx rcd bbfb con 
           com web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt a b c d _1_to_2mm _10_to_20mm _2p5_to_5mm _20_to_50mm _5_to_10mm 
           _50_to_100mm _500k_to_1mm to500k e_1to4 e_10_19 e_100_249 e_20_49 e_5_9 e_50_99 / selection=f;

run;
quit;


proc logistic inmodel=bbseg.s3_all_fwd;
score data=model_training (rename=(s3=actual)) out=s3_all_fwd_scored;
run;
title 'Forward';
proc freq data=s3_all_fwd_scored;
table actual*I_s3;
run;
 *now I get perfect, whihc is suspect and suggest overfit; 

*try firth;
proc logistic data=model_training outmodel=bbseg.s3_firth_fwd descending;
model s3(event='1') =  dda_amt mms_amt sav_amt tda_amt heqc_amt cln_amt baloc_amt  cls_amt mcc_amt tenure  sign_ons checks  
           atmo_num atmt_num atmo_amt atmt_amt vpos_num mpos_num vpos_amt mpos_amt deptkt curdep_num curdep_amt chkpd ach winfo_num     
           cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out dda_con mms_con sav_con tda_con heqc_con cln_con 
           boloc_con baloc_con tenure_yr contrib1 dda mms sav tda trs heqc cln card boloc baloc cls wbb deb mcc lckbx rcd bbfb con 
           com web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt a b c d _1_to_2mm _10_to_20mm _2p5_to_5mm _20_to_50mm _5_to_10mm 
           _50_to_100mm _500k_to_1mm to500k e_1to4 e_10_19 e_100_249 e_20_49 e_5_9 e_50_99 /  ;
exact dda_amt mms_amt sav_amt tda_amt heqc_amt cln_amt baloc_amt  cls_amt mcc_amt tenure  sign_ons checks  
           atmo_num atmt_num atmo_amt atmt_amt vpos_num mpos_num vpos_amt mpos_amt deptkt curdep_num curdep_amt chkpd ach winfo_num     
           cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out dda_con mms_con sav_con tda_con heqc_con cln_con 
           boloc_con baloc_con tenure_yr contrib1 dda mms sav tda trs heqc cln card boloc baloc cls wbb deb mcc lckbx rcd bbfb con 
           com web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt a b c d _1_to_2mm _10_to_20mm _2p5_to_5mm _20_to_50mm _5_to_10mm 
           _50_to_100mm _500k_to_1mm to500k e_1to4 e_10_19 e_100_249 e_20_49 e_5_9 e_50_99;
run;
quit;

proc logistic inmodel=bbseg.s3_firth_fwd;
score data=model_training (rename=(s3=actual)) out=s3_firth_fwd_scored;
run;
title 'Firth';
proc freq data=s3_firth_fwd_scored;
table actual*I_s3;
run;
*######################################################################################;
*try square's;

proc contents data=model_training (drop=s1 s2 s3 s4 s5 s6 segment) short varnum out=vars; run;



options nosymbolgen;
%macro quad(source=,dest=,vars=);

     %let nvars = %sysfunc(countw(&vars));
     %let nvars1 = %eval((&nvars**2+&nvars)/2);

	 data &dest;
	 set &source;
	 array vars{&nvars} &vars;
	 array new{&nvars1};
     k=1;
	 do i = 1 to &nvars ;
	 	do j = i to &nvars;
			new(k) = vars{i}*vars{j};
			call symputx(vname(new(k)),cats(vname(vars(i)),"_",vname(vars(j))));
			k+1;
		end;
	 end;
     drop i j k;
     run;

	 proc datasets ;
	 modify &dest;
	 	 
		%let k = 1;
		rename
		%do i = 1 %to &nvars;
		    %do j = &i %to &nvars;
			  new&k = &&new&k  
			  %let k = %eval(&k+1);
			%end;
		%end;
		;
	run;
	
%mend quad;




quit;

%let list = dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heqb_amt heqc_amt cln_amt card_amt boloc_amt baloc_amt cls_amt mcc_amt 
sign_ons checks atmo_num atmt_num atmo_amt atmt_amt vpos_num mpos_num vpos_amt mpos_amt deptkt curdep_num curdep_amt chkpd ACH rcd_num winfo_num
br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out DDA_con MMS_con sav_con TDA_con IRA_con MTG_con HEQB_con HEQC_con CLN_con Card_con 
boloc_con BALOC_con CLS_con MCC_con tenure_yr contrib1 ;

filename mprint "C:\Documents and Settings\ewnym5s\My Documents\SAS\quad.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic ;


%quad(source=model_training,dest=model2,vars=&list)

%let vars = dda_amt sav_amt cln_amt baloc_amt;;
 %let nvars = %sysfunc(countw(&vars));
     %let nvars1 = %eval((&nvars**2+&nvars)/2);
%put _user_;





proc sgscatter data=model_training;
compare y=s3 x=(dda_amt mms_amt sav_amt tda_amt  sign_ons checks  
           atmo_num atmt_num atmo_amt atmt_amt vpos_num mpos_num vpos_amt mpos_amt deptkt curdep_num curdep_amt chkpd ach winfo_num     
           cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out dda_con mms_con sav_con tda_con heqc_con cln_con 
           boloc_con baloc_con tenure_yr contrib1 dda mms sav tda trs heqc cln card boloc baloc cls wbb deb mcc lckbx rcd bbfb con 
           com web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt a b c d _1_to_2mm _10_to_20mm _2p5_to_5mm _20_to_50mm _5_to_10mm 
           _50_to_100mm _500k_to_1mm to500k e_1to4 e_10_19 e_100_249 e_20_49 e_5_9 e_50_99);
run;


proc freq data=model_training;
table (dda_amt mms_amt sav_amt tda_amt  sign_ons checks  
           atmo_num atmt_num atmo_amt atmt_amt vpos_num mpos_num vpos_amt mpos_amt deptkt curdep_num curdep_amt chkpd ach winfo_num     
           cb_dist br_tran_num br_tran_amt vru_num nsf chks_dep wire_in wire_out dda_con mms_con sav_con tda_con heqc_con cln_con 
           boloc_con baloc_con tenure_yr contrib1 dda mms sav tda trs heqc cln card boloc baloc cls wbb deb mcc lckbx rcd bbfb con 
           com web_info svcs rcd_num top40 rm cv0 cr6 cash_mgmt a b c d _1_to_2mm _10_to_20mm _2p5_to_5mm _20_to_50mm _5_to_10mm 
           _50_to_100mm _500k_to_1mm to500k e_1to4 e_10_19 e_100_249 e_20_49 e_5_9 e_50_99)*s3 / nocol norow nopercent;
run;
