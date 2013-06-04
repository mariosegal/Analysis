data bbseg.survey_original_sas;
set bbseg.survey_original;
run;

proc datasets library=bbseg memtype=data;
modify survey_original_sas; 
     attrib _all_ format=;
;

proc contents data=bbseg.survey_original varnum out=dump;
run;

proc sort data=dump;
by varnum;
run;

proc print data=dump;
var name label length type informat;
id varnum;
run;



proc sql;
select segment, count(*) from bbseg.survey_original where PID ne '' group by segment;
quit;


data BBSEG.customer_data_orig;
length HEQC_AMT 8;
set bbseg.survey_original;
where PID ne '';
keep segment -- MCC_ ;
drop segdesc;
rename mtid=hhid;
run;

data BBSEG.customer_data_orig;
length HEQC_AMT 8 hhid2 $ 9;
set BBSEG.customer_data_orig;
HEQC_AMT = HEQC_;
hhid2 = acct_id;
run;




proc sort data=BBSEG.customer_data_orig;
by hhid2;
run;


data test;
merge BBSEG.customer_data_orig (in=a keep=hhid2 segment rename=(hhid2=hhid) ) bb.bbmain_201212 (in=b keep=hhid);
by hhid;
if a and b;
run;

proc print data=customers;
var pID;
run;


proc sql;
select count(*) from BBSEG.customer_data_orig where ACCT_COMM_BNK_MKT ne .;
quit;

proc contents data=BBSEG.customer_data_orig varnum short;
run;

%null_to_zero(BBSEG.customer_data_orig,BBSEG.customer_data_orig,
                E1_DDA E2_MMS E3_SAV E4_TDA E5_IRA E6_TRS E7_HEQ_BUS E8_HEQ_CON E9_heqc E10_CLN E11_CARD E12_BOLOC1 E13_BALOC2 E14_CLS 
				E15_WBB E16_DEB E17_MCC E18_CKBX E19_RCD E20_BBFB E21_dda_amt E22_mms_amt E23_sav_amt E24_tda_amt E25_ira_amt E26_mtg_amt 
				E27_heqb_amt E28_heqc_amt E29_CLN_AMT E30_card_amt E31_boloc_amt1 E32_baloc_amt2 E33_cls_amt E34_mcc_amt E35_CON E36_COM E37_info 
				E38_b E39_svcs E40_tenure E41_SIC E42_sign_ons E43_checks E44_ATMO_NUM E45_ATMT_NUM E46_ATMO_AMT E47_ATMT_AMT E48_VPOS_TRAN E49_MPOS_TRAN 
				E50_vpos_amt1 E51_vpos_amt2 E52_deptkt E53_curdep_num E54_curdep_amt E55_chkpd E56_ACH E57_rcd_num E58_winfo_num E59_lckbox E60_op40 E61_RM 
				E64_cb_dist E65_cv0 E66_cr6 E67_com_dda E68_br_tran_num E69_bt_tran_amt E70_vru_num E71_NSF E72_chks_dep E73_mgmt E74_wire_in 
				E75_wire_out DDA_ MMS_ sav_ TDA_ IRA_ MTG_ HEQB_  CLN_ Card_ BOL_ BALOC_ CLS_ MCC_)

;

*i AM ASSUMING THE DATA IS ALL CLEAN, WHY NOT;

*CREATE my DATASET;

data bbseg.model_training;
merge test (in=a) bb.bbmain_201212 (in=b);
by hhid;
if a;
run;

%null_to_zero(bbseg.model_training,bbseg.model_training)

proc contents data=bbseg.model_training varnum short;
run;

data bbseg.model_training;
length segment 8;
set bbseg.model_training;
A=0;
B=0;
C=0;
D=0;
if band = 'A' then A = 1;
if band = 'B' then B = 1;
if band = 'C' then C = 1;
if band = 'D' then D = 1;

drop band_yr state hh products prods1 oth_contr deposits loans both type contrib2 type1 ;
run;

data bbseg.model_training;
set bbseg.model_training;
drop customer pb sales;
run;

proc freq data=bbseg.model_training;
table employees1 / out=vars (keep=employees1);
run;

proc print data=vars noobs;
run;

data bbseg.model_training;
set bbseg.model_training;
select(sales1);
	when ('$1-2.5 MILLION ') _1_to_2MM = 1;
	when ('$10-20 MILLION ') _10_to_20MM = 1;
	when ('$2.5-5 MILLION ') _2p5_to_5MM = 1;
	when ('$20-50 MILLION ') _20_to_50MM = 1;
	when ('$5-10 MILLION ') _5_to_10MM = 1;
	when ('$50-100 MILLION ') _50_to_100MM = 1;
	when ('$500,000-1 MILLION ') _500k_to_1MM = 1;
	when ('LESS THAN $500,000 ') to500K = 1;
	otherwise to500K = 0;
end;
select(employees1);
	when ('1-4 ') e_1to4 = 1;
	when ('10-19 ') e_10_19 =1;
	when ('100-249 ') e_100_249 = 1;
	when ('20-49 ') e_20_49 = 1;
	when ('5-9 ') e_5_9 = 1;
	when ('50-99 ') e_50_99 = 1;
	otherwise e_50_99 = 0;
end;
run;


data bbseg.model_training;
set bbseg.model_training;
drop employees1 sales1 sic: naics: employees cbr market branch band;
run;

data bbseg.model_training;
set bbseg.model_training;
drop  contrib; *contrib was from datamart may include consumer;
run;

data bbseg.model_training;
set bbseg.model_training;
drop private;
run;


%null_to_zero(bbseg.model_training,bbseg.model_training)
