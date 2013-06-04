data temp_tran ;
set data.main_201203;
where DDA = 1;
	if VPOS_NUM ge 1 then VPOS = 1; else VPOS = 0;
	if MPOS_NUM ge 1 then MPOS = 1; else MPOS = 0;
	if ATMO_NUM ge 1 then ATMO = 1; else ATMO = 0;
	if ATMT_NUM ge 1 then ATMT = 1; else ATMT = 0;
	if BR_TR_NUM ge 1 then BR_TR = 1; else BR_TR = 0;
	if vru_NUM ge 1 then VRU = 1; else VRU = 0;
    if web_signon ge 1 then web1 = 1; else web1 = 0;
    if bp_num ge 1 then bp1 = 1; else bp1 = 0;
    if sms_num ge 1 then sms1 = 1; else sms1 = 0;
	if wap_num ge 1 then wap1 = 1; else wap1 = 0;
    if fico_num ge 1 then fico1 = 1; else fico1 = 0;
	if fworks_num ge 1 then fworks1 = 1; else fworks1 = 0;
	if chk_num ge 1 then chk1 = 1; else chk1 = 0;

keep HHID HH web bp WAP SMS edeliv estat fico FWorks web_signon BP_NUM BP_AMT SMS_NUM WAP_NUM fico_num fworks_num chk_num cqi_dd
VPOS_AMT vpos_num mpos_amt mpos_num ATMO_AMT ATMO_NUM ATMT_AMT ATMT_NUM BR_TR_NUM BR_TR_amt VRU_NUM  dd_amt
vpos mpos atmo atmt br_tr vru web1 bp1 sms1 wap1 fico1 fworks1 chk1 tran_segment; 
run;


Proc tabulate data=temp_tran out=tran1;
class tran_segment;
var HH web bp WAP SMS edeliv estat fico FWorks web_signon BP_NUM BP_AMT SMS_NUM WAP_NUM fico_num fworks_num chk_num cqi_dd
    VPOS_AMT vpos_num mpos_amt mpos_num ATMO_AMT ATMO_NUM ATMT_AMT ATMT_NUM BR_TR_NUM BR_TR_amt VRU_NUM
    vpos mpos atmo atmt br_tr vru web1 bp1 sms1 wap1 fico1 fworks1 chk1 dd_amt;
table  tran_segment, (sum)*(HH web bp WAP SMS edeliv estat fico FWorks web_signon BP_NUM BP_AMT SMS_NUM WAP_NUM fico_num fworks_num chk_num cqi_dd
                       VPOS_AMT vpos_num mpos_amt mpos_num ATMO_AMT ATMO_NUM ATMT_AMT ATMT_NUM BR_TR_NUM BR_TR_amt VRU_NUM
                       vpos mpos atmo atmt br_tr vru web1 bp1 sms1 wap1 fico1 fworks1 chk1 dd_amt);
run;




data tran2;
set tran1 (drop=_TABLE_ _TYPE_ _PAGE_);
	/*penetrations*/
	web_pct = divide(web_sum,hh_sum);
	bp_pct = divide(bp_sum,hh_sum);
	sms_pct = divide(sms_sum,hh_sum);
	wap_pct = divide(wap_sum,hh_sum);
	fico_pct = divide(fico_sum,hh_sum);
	fworks_pct = divide(fworks_sum,hh_sum);
	estat_pct = divide(estat_sum,hh_sum);
	edeliv_pct = divide(edeliv_sum,hh_sum);
	vpos_pct = .;
	mpos_pct = .;
	atmo_pct = .;
	atmt_pct = .;
	br_tr_pct = .;
	vru_pct = .;
	chk_pct = .;
	dd_pct = .;
	/*avg trans*/
	web_avg1 = divide(web_signon_sum,web_sum);
	bp_avg1 = divide(bp_num_sum,bp_sum);
	sms_avg1 = divide(sms_num_sum,sms_sum);
	wap_avg1 = divide(wap_num_sum,wap_sum);
	fico_avg1 = divide(fico_num_sum,fico_sum);
	fworks_avg1 = divide(fworks_num_sum,fworks_sum);
	estat_avg1 = .;
	edeliv_avg1 = .;
	vpos_avg1 = divide(vpos_num_sum,vpos_sum);
	mpos_avg1 = divide(mpos_num_sum,mpos_sum);
	atmo_avg1 = divide(atmo_num_sum,atmo_sum);
	atmt_avg1 = divide(atmt_num_sum,atmt_sum);
	br_tr_avg1 = divide(br_tr_num_sum,br_tr_sum);
	vru_avg1 = divide(vru_num_sum,vru_sum);
	chk_avg1 = divide(chk_num_sum,chk1_sum);
	dd_avg1 = .;
	/*avg amt*/
	web_avg2 = .;
	bp_avg2 = divide(bp_amt_sum,bp_sum);
	sms_avg2 = .;
	wap_avg2 = .;
	fico_avg2 = .;
	fworks_avg2 = .;
	estat_avg2 = .;
	edeliv_avg2 = .;
	vpos_avg2 = divide(vpos_amt_sum,vpos_sum);
	mpos_avg2 = divide(mpos_amt_sum,mpos_sum);
	atmo_avg2 = divide(atmo_amt_sum,atmo_sum);
	atmt_avg2 = divide(atmt_amt_sum,atmt_sum);
	br_tr_avg2 = divide(br_tr_amt_sum,br_tr_sum);
	vru_avg2 = 0;
	chk_avg2 = .;
	dd_avg2 = divide(dd_amt_sum,cqi_dd_sum);
	/*active, if enrolled did they had activity, for vpos, mpos, atm, br_tr and vru assume all are enrolled*/
	web_pct2 = divide(web1_sum,hh_sum);
	bp_pct2 = divide(bp1_sum,hh_sum);
	sms_pct2 = divide(sms1_sum,hh_sum);
	wap_pct2 = divide(wap1_sum,hh_sum);
	fico_pct2 = divide(fico1_sum,hh_sum);
	fworks_pct2 = divide(fworks1_sum,hh_sum);
	estat_pct2 = .;
	edeliv_pct2 = .;
	vpos_pct2 = divide(vpos_sum,hh_sum);
	mpos_pct2 = divide(mpos_sum,hh_sum);
	atmo_pct2 = divide(atmo_sum,hh_sum);
	atmt_pct2 = divide(atmt_sum,hh_sum);
	br_tr_pct2 = divide(br_tr_sum,hh_sum);
	vru_pct2 = divide(vru_sum,hh_sum);
	chk_pct2 = divide(chk1_sum,hh_sum);
	dd_pct2 = divide(cqi_dd_sum,hh_Sum);
run;

data tran3;
length Name $ 20 HH 8 Penetration 8 Active 8 Avg_Tr 8 Avg_Amt 8 ;
array counts {16} 8 web_Sum bp_Sum SMS_Sum WAP_Sum fico_Sum FWorks_Sum estat_Sum edeliv_Sum vpos_sum mpos_sum atmo_sum atmt_sum br_tr_sum vru_sum chk1_sum cqi_dd_sum;
array pcts {16} 8 web_pct bp_pct sms_pct wap_pct fico_pct fworks_pct estat_pct edeliv_pct vpos_pct mpos_pct atmo_pct atmt_pct br_tr_pct vru_pct chk_pct dd_pct;
array pcts2 {16} 8 web_pct2 bp_pct2 sms_pct2 wap_pct2 fico_pct2 fworks_pct2 estat_pct2 edeliv_pct2 vpos_pct2 mpos_pct2 atmo_pct2 atmt_pct2 br_tr_pct2 vru_pct2 chk_pct2 dd_pct2;
array avg1 {16}  8 web_avg1 bp_avg1 sms_avg1 wap_avg1 fico_avg1 fworks_avg1 estat_avg1 edeliv_avg1 vpos_avg1 mpos_avg1 atmo_avg1 atmt_avg1 br_tr_avg1 vru_avg1 chk_avg1 dd_avg1;
array avg2 {16} 8 web_avg2 bp_avg2 sms_avg2 wap_avg2 fico_avg2 fworks_avg2 estat_avg2 edeliv_avg2 vpos_avg2 mpos_avg2 atmo_avg2 atmt_avg2 br_tr_avg2 vru_avg2 chk_avg2 dd_avg2;
Array Prod {16} $ 20 ('Web Banking' 'Bill Pay' 'Text Banking' 'Mobile Banking' 'FICO Score' 'Finance Works' 'e Statements' 'e Delivery' 
                      'Signature Debit' 'PIN Debit' 'M&T ATM' 'Other ATM' 'Branch' 'VRU' 'Checks' 'Direct Deposit');
set tran2;

do i=1 to 16;
   Name = Prod{i};
   HH = counts{i};
   Penetration = pcts{i};
   Active = pcts2{i};
   Avg_tr = avg1{i};
   Avg_amt = avg2{i};
   output;
end;
   Name = 'Total';
   HH = hh_sum;
   Penetration = .;
   Active = .;
   Avg_tr = .;
   Avg_Amt = .;
   output;
keep tran_segment Name HH  Penetration Active Avg_tr Avg_Amt;
run;

proc print data=tran3 noobs;
run;

%let title = Transaction Segment Analysis;
data wip.chart_data;
set tran3;
where Name ne 'Total';
run;

option orientation=landscape;
ods pdf file="C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\Transaction Detail Analysis 20120601.pdf";
title1 &title;
legend1 position=(outside bottom center) mode=reserve cborder=black shape=bar(.15in,.15in) label=('Transaction Segment' position=(top center));
title2 'Transaction Penetration (CHK HHs)';
axis1 minor=none color=black label=(a=90 f="Arial/Bold" "Enrollment CHK HHs") split=" " order=(0 to 1 by 0.25);
axis2 split=" " value=(h=7pt) label=none value=none;
axis3 split=" " value=(h=7pt) ORDER=('Web Banking' 'Bill Pay' 'Text Banking' 'Mobile Banking' 'FICO Score' 'Finance Works' 'e Statements' 'e Delivery' 
                      'Signature Debit' 'PIN Debit' 'M&T ATM' 'Other ATM' 'Branch' 'VRU' 'Checks' 'Direct Deposit') color=black label=NONE;
%vbar_grouped (analysis_var=Penetration,group_var=Name,class_var=tran_segment,table=chart_data,title_str=&title,value_format=Percent8.1,group_format=);


title2 'Transaction Incidence (CHK HHs)';
axis1 minor=none color=black label=(a=90 f="Arial/Bold" "% Active CHK HHs") split=" ";
%vbar_grouped (analysis_var=Active,group_var=Name,class_var=tran_segment,table=chart_data,title_str=&title,value_format=Percent8.1,group_format=);

title2 'Avg. Tran Volume (CHK HHs)';
axis1 minor=none color=black label=(a=90 f="Arial/Bold" "Avg. Trans CHK HHs") split=" ";
%vbar_grouped (analysis_var=Avg_Tr,group_var=Name,class_var=tran_segment,table=chart_data,title_str=&title,value_format=Comma8.1,group_format=);

title2 'Avg. Tran Amt (CHK HHs)';
axis1 minor=none color=black label=(a=90 f="Arial/Bold" "Avg. Amt CHK HHs") ;
%vbar_grouped (analysis_var=Avg_Amt,group_var=Name,class_var=tran_segment,table=chart_data,title_str=&title,value_format=dollar12.0,group_format=);
ods pdf close;



*#################################################################################################;
*      Summarixe by the 3 groups ;

proc format library=sas;
value $ tranfmt    'Inactive' = 'Inactive'
                     'ATM Dominant' = 'Virtual'
					 'Online Dominant' = 'Virtual'
					 'Phone Dominant' = 'Virtual'
					 'Multi - Low Branch' = 'Virtual'
					 'Multi - Med Branch' = 'Branch'
					 'Multi - High Branch' = 'Branch'
					 'Branch Dominant' = 'Branch';
run;

Proc tabulate data=temp_tran out=tran1b;
class tran_segment;
var HH web bp WAP SMS edeliv estat fico FWorks web_signon BP_NUM BP_AMT SMS_NUM WAP_NUM fico_num fworks_num chk_num cqi_dd
    VPOS_AMT vpos_num mpos_amt mpos_num ATMO_AMT ATMO_NUM ATMT_AMT ATMT_NUM BR_TR_NUM BR_TR_amt VRU_NUM
    vpos mpos atmo atmt br_tr vru web1 bp1 sms1 wap1 fico1 fworks1 chk1 dd_amt;
table  tran_segment, (sum)*(HH web bp WAP SMS edeliv estat fico FWorks web_signon BP_NUM BP_AMT SMS_NUM WAP_NUM fico_num fworks_num chk_num cqi_dd
                       VPOS_AMT vpos_num mpos_amt mpos_num ATMO_AMT ATMO_NUM ATMT_AMT ATMT_NUM BR_TR_NUM BR_TR_amt VRU_NUM
                       vpos mpos atmo atmt br_tr vru web1 bp1 sms1 wap1 fico1 fworks1 chk1 dd_amt) / nocellmerge;
format tran_segment $tranfmt.;
run;




data tran2b;
set tran1b (drop=_TABLE_ _TYPE_ _PAGE_);
	/*penetrations*/
	web_pct = divide(web_sum,hh_sum);
	bp_pct = divide(bp_sum,hh_sum);
	sms_pct = divide(sms_sum,hh_sum);
	wap_pct = divide(wap_sum,hh_sum);
	fico_pct = divide(fico_sum,hh_sum);
	fworks_pct = divide(fworks_sum,hh_sum);
	estat_pct = divide(estat_sum,hh_sum);
	edeliv_pct = divide(edeliv_sum,hh_sum);
	vpos_pct = .;
	mpos_pct = .;
	atmo_pct = .;
	atmt_pct = .;
	br_tr_pct = .;
	vru_pct = .;
	chk_pct = .;
	dd_pct = .;
	/*avg trans*/
	web_avg1 = divide(web_signon_sum,web_sum);
	bp_avg1 = divide(bp_num_sum,bp_sum);
	sms_avg1 = divide(sms_num_sum,sms_sum);
	wap_avg1 = divide(wap_num_sum,wap_sum);
	fico_avg1 = divide(fico_num_sum,fico_sum);
	fworks_avg1 = divide(fworks_num_sum,fworks_sum);
	estat_avg1 = .;
	edeliv_avg1 = .;
	vpos_avg1 = divide(vpos_num_sum,vpos_sum);
	mpos_avg1 = divide(mpos_num_sum,mpos_sum);
	atmo_avg1 = divide(atmo_num_sum,atmo_sum);
	atmt_avg1 = divide(atmt_num_sum,atmt_sum);
	br_tr_avg1 = divide(br_tr_num_sum,br_tr_sum);
	vru_avg1 = divide(vru_num_sum,vru_sum);
	chk_avg1 = divide(chk_num_sum,chk1_sum);
	dd_avg1 = .;
	/*avg amt*/
	web_avg2 = .;
	bp_avg2 = divide(bp_amt_sum,bp_sum);
	sms_avg2 = .;
	wap_avg2 = .;
	fico_avg2 = .;
	fworks_avg2 = .;
	estat_avg2 = .;
	edeliv_avg2 = .;
	vpos_avg2 = divide(vpos_amt_sum,vpos_sum);
	mpos_avg2 = divide(mpos_amt_sum,mpos_sum);
	atmo_avg2 = divide(atmo_amt_sum,atmo_sum);
	atmt_avg2 = divide(atmt_amt_sum,atmt_sum);
	br_tr_avg2 = divide(br_tr_amt_sum,br_tr_sum);
	vru_avg2 = 0;
	chk_avg2 = .;
	dd_avg2 = divide(dd_amt_sum,cqi_dd_sum);
	/*active, if enrolled did they had activity, for vpos, mpos, atm, br_tr and vru assume all are enrolled*/
	web_pct2 = divide(web1_sum,hh_sum);
	bp_pct2 = divide(bp1_sum,hh_sum);
	sms_pct2 = divide(sms1_sum,hh_sum);
	wap_pct2 = divide(wap1_sum,hh_sum);
	fico_pct2 = divide(fico1_sum,hh_sum);
	fworks_pct2 = divide(fworks1_sum,hh_sum);
	estat_pct2 = .;
	edeliv_pct2 = .;
	vpos_pct2 = divide(vpos_sum,hh_sum);
	mpos_pct2 = divide(mpos_sum,hh_sum);
	atmo_pct2 = divide(atmo_sum,hh_sum);
	atmt_pct2 = divide(atmt_sum,hh_sum);
	br_tr_pct2 = divide(br_tr_sum,hh_sum);
	vru_pct2 = divide(vru_sum,hh_sum);
	chk_pct2 = divide(chk1_sum,hh_sum);
	dd_pct2 = divide(cqi_dd_sum,hh_Sum);
run;

data tran3b;
length Name $ 20 HH 8 Penetration 8 Active 8 Avg_Tr 8 Avg_Amt 8 ;
array counts {16} 8 web_Sum bp_Sum SMS_Sum WAP_Sum fico_Sum FWorks_Sum estat_Sum edeliv_Sum vpos_sum mpos_sum atmo_sum atmt_sum br_tr_sum vru_sum chk1_sum cqi_dd_sum;
array pcts {16} 8 web_pct bp_pct sms_pct wap_pct fico_pct fworks_pct estat_pct edeliv_pct vpos_pct mpos_pct atmo_pct atmt_pct br_tr_pct vru_pct chk_pct dd_pct;
array pcts2 {16} 8 web_pct2 bp_pct2 sms_pct2 wap_pct2 fico_pct2 fworks_pct2 estat_pct2 edeliv_pct2 vpos_pct2 mpos_pct2 atmo_pct2 atmt_pct2 br_tr_pct2 vru_pct2 chk_pct2 dd_pct2;
array avg1 {16}  8 web_avg1 bp_avg1 sms_avg1 wap_avg1 fico_avg1 fworks_avg1 estat_avg1 edeliv_avg1 vpos_avg1 mpos_avg1 atmo_avg1 atmt_avg1 br_tr_avg1 vru_avg1 chk_avg1 dd_avg1;
array avg2 {16} 8 web_avg2 bp_avg2 sms_avg2 wap_avg2 fico_avg2 fworks_avg2 estat_avg2 edeliv_avg2 vpos_avg2 mpos_avg2 atmo_avg2 atmt_avg2 br_tr_avg2 vru_avg2 chk_avg2 dd_avg2;
Array Prod {16} $ 20 ('Web Banking' 'Bill Pay' 'Text Banking' 'Mobile Banking' 'FICO Score' 'Finance Works' 'e Statements' 'e Delivery' 
                      'Signature Debit' 'PIN Debit' 'M&T ATM' 'Other ATM' 'Branch' 'VRU' 'Checks' 'Direct Deposit');
set tran2b;

do i=1 to 16;
   Name = Prod{i};
   HH = counts{i};
   Penetration = pcts{i};
   Active = pcts2{i};
   Avg_tr = avg1{i};
   Avg_amt = avg2{i};
   output;
end;
   Name = 'Total';
   HH = hh_sum;
   Penetration = .;
   Active = .;
   Avg_tr = .;
   Avg_Amt = .;
   output;
keep tran_segment Name HH  Penetration Active Avg_tr Avg_Amt;
run;



proc print data=tran3b noobs;
run;
