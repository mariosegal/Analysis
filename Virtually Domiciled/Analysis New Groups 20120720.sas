libname bagels oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=Mario1;
 Data Source=bagels"  schema=dbo; 



filename mprint "C:\Documents and Settings\ewnym5s\My Documents\SAS\excel.sas" ;
data _null_ ; file mprint ; run ;
options  mfile nomlogic nosymbolgen mcompilenote=all;
%toexcel (filename=Tran_Segment Analysis_20120720,out_dir=virtually domiciled)


%put _user_;


proc means data=bagels.trans_201203;
run;

 proc univariate data=bagels.trans_201203;
 run;


 *#################################################;
 data tran_segments;
 set data.main_201203 (keep=hhid tran_segment where=(tran_segment ne ''));
 tran_code = put(tran_segment, trancode.);
 run;

data _null_;
file 'C:\Documents and Settings\ewnym5s\My Documents\Data\codes.txt' dsd dlm='09'x;
set tran_segments;
put hhid tran_code;
run;

proc freq data=bagels.trans_new_201203 (keep = tran_code);
TABLE TRAN_CODE / missing;
run;

proc contents data=bagels.trans_new_201203  varnum short;
run;

proc datasets library=bagels;
contents data=trans_new_201203 details varnum memtype=data;
run;

proc tabulate data=bagels.trans_new_201203 missing;
class tran_code;
var csw_inq csw_from csw_to vru_inq vru_from vru_to bp_mtb bp_non bp_mtb_amt bp_non_amt ATMO_wdral atmo_dep atmo_trsf atmo_cshck atmo_inq atmo_zcash atmo_with_amt
atmo_dep_amt atmo_trsf_amt atm_cshck_amt atmo_inqry_amt atmo_zcash_amt atmt_wdral AtMt_inqry atmt_xfer atmt_zcash atmt_wdral_amt atmr_inqry_amt atmt_xfer_amt 
atmt_zcash_amt lobby_dep drv_dep nite_dep lobby_dep_amt drvin_dep_amt nite_dep_amt lobby_sav_with lobby_sav_amt drive_sav drive_sav_amt sign_ons wap_balreq 
wap_hist wap_schtran wap_cantran wap_trans wap_bpay sms_bal sms_hist b2b_deb b2b_cred b2b_debit_amt b2b_credit_amt ;
table tran_code all, N sum*(csw_inq csw_from csw_to vru_inq vru_from vru_to bp_mtb bp_non bp_mtb_amt bp_non_amt ATMO_wdral atmo_dep atmo_trsf atmo_cshck atmo_inq 
atmo_zcash atmo_with_amt atmo_dep_amt atmo_trsf_amt atm_cshck_amt atmo_inqry_amt atmo_zcash_amt atmt_wdral AtMt_inqry atmt_xfer atmt_zcash atmt_wdral_amt 
atmr_inqry_amt atmt_xfer_amt atmt_zcash_amt lobby_dep drv_dep nite_dep lobby_dep_amt drvin_dep_amt nite_dep_amt lobby_sav_with lobby_sav_amt drive_sav 
drive_sav_amt sign_ons wap_balreq wap_hist wap_schtran wap_cantran wap_trans wap_bpay sms_bal sms_hist b2b_deb b2b_cred b2b_debit_amt b2b_credit_amt)*f=comma24. 
/ nocellmerge;
format tran_code $transegm.;
run;


proc format library=sas;
value trans 0 = 'None'
            1 = '1'
			2 = '2'
			3 = '3'
			4 = '4'
			5 = '5'
			5<-10 = '6 to 10'
			10<-15 = '11 to 15'
			15<-20 = '16 to 20'
			20<-25 = '20 to 25'
			25<-high = 'Over 25';
run;


ods html off;
proc tabulate data=bagels.trans_new_201203 missing out=wip.tran_summary;
class tran_code csw_inq csw_from csw_to vru_inq vru_from vru_to bp_mtb bp_non bp_mtb_amt bp_non_amt ATMO_wdral atmo_dep atmo_trsf atmo_cshck atmo_inq atmo_zcash atmo_with_amt 
atmo_dep_amt atmo_trsf_amt atm_cshck_amt atmo_inqry_amt atmo_zcash_amt atmt_wdral AtMt_inqry atmt_xfer atmt_zcash atmt_wdral_amt atmr_inqry_amt atmt_xfer_amt 
atmt_zcash_amt lobby_dep drv_dep nite_dep lobby_dep_amt drvin_dep_amt nite_dep_amt lobby_sav_with lobby_sav_amt drive_sav drive_sav_amt sign_ons wap_balreq 
wap_hist wap_schtran wap_cantran wap_trans wap_bpay sms_bal sms_hist b2b_deb b2b_cred b2b_debit_amt b2b_credit_amt;
table  (csw_inq csw_from csw_to vru_inq vru_from vru_to bp_mtb bp_non bp_mtb_amt bp_non_amt ATMO_wdral atmo_dep atmo_trsf atmo_cshck atmo_inq 
atmo_zcash atmo_with_amt atmo_dep_amt atmo_trsf_amt atm_cshck_amt atmo_inqry_amt atmo_zcash_amt atmt_wdral AtMt_inqry atmt_xfer atmt_zcash 
atmt_wdral_amt atmr_inqry_amt atmt_xfer_amt atmt_zcash_amt lobby_dep drv_dep nite_dep lobby_dep_amt drvin_dep_amt nite_dep_amt lobby_sav_with 
lobby_sav_amt drive_sav drive_sav_amt sign_ons wap_balreq wap_hist wap_schtran wap_cantran wap_trans wap_bpay sms_bal sms_hist b2b_deb 
b2b_cred b2b_debit_amt b2b_credit_amt), tran_code*N / nocellmerge ;
format csw_inq csw_from csw_to vru_inq vru_from vru_to bp_mtb bp_non bp_mtb_amt bp_non_amt ATMO_wdral atmo_dep atmo_trsf atmo_cshck atmo_inq 
atmo_zcash atmo_with_amt atmo_dep_amt atmo_trsf_amt atm_cshck_amt atmo_inqry_amt atmo_zcash_amt atmt_wdral AtMt_inqry atmt_xfer atmt_zcash 
atmt_wdral_amt atmr_inqry_amt atmt_xfer_amt atmt_zcash_amt lobby_dep drv_dep nite_dep lobby_dep_amt drvin_dep_amt nite_dep_amt lobby_sav_with 
lobby_sav_amt drive_sav drive_sav_amt sign_ons wap_balreq wap_hist wap_schtran wap_cantran wap_trans wap_bpay sms_bal sms_hist b2b_deb 
b2b_cred b2b_debit_amt b2b_credit_amt  trans.;
run;
ods html;

proc freq data=bagels.trans_new_201203;
table (csw_inq csw_from csw_to vru_inq vru_from vru_to bp_mtb bp_non bp_mtb_amt bp_non_amt ATMO_wdral atmo_dep atmo_trsf atmo_cshck atmo_inq 
atmo_zcash atmo_with_amt atmo_dep_amt atmo_trsf_amt atm_cshck_amt atmo_inqry_amt atmo_zcash_amt atmt_wdral AtMt_inqry atmt_xfer atmt_zcash 
atmt_wdral_amt atmr_inqry_amt atmt_xfer_amt atmt_zcash_amt lobby_dep drv_dep nite_dep lobby_dep_amt drvin_dep_amt nite_dep_amt lobby_sav_with 
lobby_sav_amt drive_sav drive_sav_amt sign_ons wap_balreq wap_hist wap_schtran wap_cantran wap_trans wap_bpay sms_bal sms_hist b2b_deb 
b2b_cred b2b_debit_amt b2b_credit_amt) / out=wip.tran_results_new;
format csw_inq csw_from csw_to vru_inq vru_from vru_to bp_mtb bp_non bp_mtb_amt bp_non_amt ATMO_wdral atmo_dep atmo_trsf atmo_cshck atmo_inq 
atmo_zcash atmo_with_amt atmo_dep_amt atmo_trsf_amt atm_cshck_amt atmo_inqry_amt atmo_zcash_amt atmt_wdral AtMt_inqry atmt_xfer atmt_zcash 
atmt_wdral_amt atmr_inqry_amt atmt_xfer_amt atmt_zcash_amt lobby_dep drv_dep nite_dep lobby_dep_amt drvin_dep_amt nite_dep_amt lobby_sav_with 
lobby_sav_amt drive_sav drive_sav_amt sign_ons wap_balreq wap_hist wap_schtran wap_cantran wap_trans wap_bpay sms_bal sms_hist b2b_deb 
b2b_cred b2b_debit_amt b2b_credit_amt  trans.;
run;


%macro my_freqs;
ods html close;
%let vars = csw_inq csw_from csw_to vru_inq vru_from vru_to bp_mtb bp_non  ATMO_wdral atmo_dep atmo_trsf 
                     atmo_cshck atmo_inq atmo_zcash atmt_wdral AtMt_inqry atmt_xfer atmt_zcash  lobby_dep drv_dep 
                     nite_dep lobby_sav_with  drive_sav  sign_ons wap_balreq 
                     wap_hist wap_schtran wap_cantran wap_trans wap_bpay sms_bal sms_hist b2b_deb b2b_cred  ;
%do i=1 %to 500;
	%let word = %scan(&vars,&i);
	%if &word ne %str( ) %then %do; 
		proc freq data=bagels.trans_new_201203 (keep=tran_code &word);
		table tran_code*&word / nocol norow out=wip.volume_&word (rename=(&word=band));
		format &word trans. tran_code $transegm.;
		run;
	%end;
%end;

%let vars =  bp_mtb_amt bp_non_amt atmo_with_amt atmo_dep_amt atmo_trsf_amt atm_cshck_amt atmo_inqry_amt atmo_zcash_amt 
                      atmt_wdral_amt atmr_inqry_amt atmt_xfer_amt atmt_zcash_amt lobby_dep_amt drvin_dep_amt nite_dep_amt lobby_sav_amt drive_sav_amt  
                     b2b_debit_amt b2b_credit_amt;
%do i=1 %to 500;
	%let word = %scan(&vars,&i);
	%if &word ne %str( ) %then %do; 
		proc freq data=bagels.trans_new_201203 (keep=tran_code &word);
		table tran_code*&word / nocol norow out=wip.volume_&word (rename=(&word=band));
		format &word amtband. tran_code $transegm.;
		run;
	%end;
%end;
ods html;
%mend my_freqs;



options mcompilenote=all ;




%macro combine;
%let vars = csw_inq csw_from csw_to vru_inq vru_from vru_to bp_mtb bp_non bp_mtb_amt bp_non_amt ATMO_wdral atmo_dep atmo_trsf 
                     atmo_cshck atmo_inq atmo_zcash atmo_with_amt atmo_dep_amt atmo_trsf_amt atm_cshck_amt atmo_inqry_amt atmo_zcash_amt 
                     atmt_wdral AtMt_inqry atmt_xfer atmt_zcash atmt_wdral_amt atmr_inqry_amt atmt_xfer_amt atmt_zcash_amt lobby_dep drv_dep 
                     nite_dep lobby_dep_amt drvin_dep_amt nite_dep_amt lobby_sav_with lobby_sav_amt drive_sav drive_sav_amt sign_ons wap_balreq 
                     wap_hist wap_schtran wap_cantran wap_trans wap_bpay sms_bal sms_hist b2b_deb b2b_cred b2b_debit_amt b2b_credit_amt;

%do i=1 %to 500;
%let word = %scan(&vars,&i);
	%if &word ne %str( ) %then %do; 
		data wip.volume_&word;
		length tran_type $ 20;
		set wip.volume_&word;
		tran_type = "&word";
		drop &word;
		run;
	%end;
%end;

%let vars = csw_inq csw_from csw_to vru_inq vru_from vru_to bp_mtb bp_non  ATMO_wdral atmo_dep atmo_trsf 
                     atmo_cshck atmo_inq atmo_zcash atmt_wdral AtMt_inqry atmt_xfer atmt_zcash  lobby_dep drv_dep 
                     nite_dep lobby_sav_with  drive_sav  sign_ons wap_balreq 
                     wap_hist wap_schtran wap_cantran wap_trans wap_bpay sms_bal sms_hist b2b_deb b2b_cred  ;

%let i = 1;
%let word = %scan(&vars,&i);
data wip.volume_combined;
set wip.volume_&word;
where tran_code ne '';
run;

%do i=2 %to 500;
%let word = %scan(&vars,&i);
	%if &word ne %str( ) %then %do; 
	proc datasets library=work nolist;
	append base=wip.volume_combined data=wip.volume_&word (where=(tran_code ne ''));
	run;
	%end;
%end;


%let vars =  bp_mtb_amt bp_non_amt atmo_with_amt atmo_dep_amt atmo_trsf_amt atm_cshck_amt atmo_inqry_amt atmo_zcash_amt 
                      atmt_wdral_amt atmr_inqry_amt atmt_xfer_amt atmt_zcash_amt lobby_dep_amt drvin_dep_amt nite_dep_amt lobby_sav_amt drive_sav_amt  
                     b2b_debit_amt b2b_credit_amt;

%let i = 1;
%let word = %scan(&vars,&i);
data wip.amounts_combined;
set wip.volume_&word;
where tran_code ne '';
run;

%do i=2 %to 500;
%let word = %scan(&vars,&i);
	%if &word ne %str( ) %then %do; 
	proc datasets library=work nolist;
	append base=wip.amounts_combined data=wip.volume_&word (where=(tran_code ne ''));
	run;
	%end;
%end;

%mend combine;


%my_freqs
%combine



filename mprint "C:\Documents and Settings\ewnym5s\My Documents\SAS\combine.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic ;
