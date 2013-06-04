
data mobile_201209;
length  hhid $ 9 ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\mobile.txt' dsd dlm='09'x lrecl=4096 missover firstobs=2;
input  hhid $  sms wap BAL_REQ_SMS BAL_REQ_WAP BAL_REQ_IPHONE HIST_REQ_SMS HIST_REQ_WAP HIST_REQ_SMART TRANS_REQ_WAP TRANS_REQ_IPHONE
      SCH_TRANS_REQ_WAP SCH_TRANS_REQ_IPHONE CAN_TRANS_REQ_WAP CAN_TRANS_REQ_IPHONE VIEW_TRANS_REQ_WAP VIEW_TRANS_REQ_IPHONE ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL 
	  ANY_LOC_REQ_WI BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI SMS_ENROLL_DATE :mmddyy10.  WAP_ENROLL_DATE :mmddyy10. ;
drop drop:;
run;



proc summary data=mobile_201209  noprint;
by hhid;
vars sms wap BAL_REQ_SMS BAL_REQ_WAP BAL_REQ_IPHONE HIST_REQ_SMS HIST_REQ_WAP HIST_REQ_SMART TRANS_REQ_WAP TRANS_REQ_IPHONE
      SCH_TRANS_REQ_WAP SCH_TRANS_REQ_IPHONE CAN_TRANS_REQ_WAP CAN_TRANS_REQ_IPHONE VIEW_TRANS_REQ_WAP VIEW_TRANS_REQ_IPHONE ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL 
	  ANY_LOC_REQ_WI BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI SMS_ENROLL_DATE WAP_ENROLL_DATE;
output out=a sum=;
run;

data a;
set a;
drop _type_ _freq_;
run;

options compress=yes;
%squeeze (a, data.mobile_201209);

data data.mobile_201209;
merge data.mobile_201209 (in=a) data.main_201209 (in=b keep=hhid segment cbr band  clv: dda: mms: sav: tda: ira: mtg: heq: iln: ind: card: sec: ins: ixi_tot ccs_amt hh)
      data.contrib_201209 (in=c drop=cbr market zip state cbr band:);
sms_active =0;
if sms ge 1 then sms_active = 1;
if wap ge 1 then wap_active = 1;
by hhid;
if b;
sms_enroll = 0;
if sms_enroll_date ne . then sms_enroll = 1;
wap_enroll = 0;
if wap_enroll_date ne . then wap_enroll = 1;
svcs=0;
svcs=sum(dda,mms,sav,tda,ira,mtg,heq,iln,ind,card,sec,ins);
run;


data data.mobile_201209;
merge data.mobile_201209 (in=a) data.main_201209 (in=b keep=hhid web: bp: edeliv fico: estat fworks: chk: dd: );
if a;
run;


data data.mobile_201209;
set data.mobile_201209;
iphone = sum(BAL_REQ_IPHONE,HIST_REQ_SMART,TRANS_REQ_IPHONE,SCH_TRANS_REQ_IPHONE,CAN_TRANS_REQ_IPHONE,VIEW_TRANS_REQ_IPHONE);
iphone_active = 0;
if iphone ge 1 then iphone_active = 1;
both = 0;
if iphone_active eq 1 and wap_active eq 1 then both =1;
textand = 0;
if sms_active and (iphone_active or wap_active) then textand =1 ;
run;

data data.mobile_201209;
length group $ 15;
set data.mobile_201209;
if (sms_enroll eq 1 and wap_enroll eq 1) then group = 'Text and Mobile';
if (sms_enroll eq 1 and wap_enroll ne 1) then group = 'Text Only';
if (sms_enroll ne 1 and wap_enroll eq 1) then group = 'Mobile Only';
if (sms_enroll ne 1 and wap_enroll ne 1) then group = 'Not Enrolled';
run;

proc freq data=data.mobile_201209;
table group;
run;


*####################################################################################;
Title 'Counts';
proc sql;
select count(*)  as consumer  from data.mobile_201209;
select count(*)  as web  from data.mobile_201209 where web eq 1;
select count(*)  as web_active  from data.mobile_201209 where web eq 1 and web_signon ge 1;
quit;
Title;

proc freq data=data.mobile_201209;
table sms_enroll*sms_active wap_enroll*wap_active sms_enroll*wap_enroll /missing;
run;

proc freq data=data.mobile_201209;
where sms_enroll eq 1 and wap_enroll eq 1;
table sms_active*wap_active /missing;
run;

Title 'wap no sms';
proc freq data=data.mobile_201209;
where sms_enroll ne 1 and wap_enroll eq 1;
table sms_active*wap_active /missing;
run;

Title 'sms no wap';
proc freq data=data.mobile_201209;
where sms_enroll eq 1 and wap_enroll ne 1;
table sms_active*wap_active /missing;
run;
title;

proc sql;
select count(*) from data.mobile_201209 where sms_enroll eq 1 or wap_enroll eq 1;
quit;


proc format;
value quick low-0 = 'N'
            1-high = 'Y';
run;

proc tabulate data=data.mobile_201209 missing;
where sms_active eq 1 or wap_active eq 1;
class sms_active WAP_active;
var dda mms sav tda ira mtg heq iln ind card sec ins BAL_REQ_SMS BAL_REQ_WAP BAL_REQ_IPHONE HIST_REQ_SMS HIST_REQ_WAP HIST_REQ_SMART TRANS_REQ_WAP TRANS_REQ_IPHONE
      SCH_TRANS_REQ_WAP SCH_TRANS_REQ_IPHONE CAN_TRANS_REQ_WAP CAN_TRANS_REQ_IPHONE VIEW_TRANS_REQ_WAP VIEW_TRANS_REQ_IPHONE ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL 
	  ANY_LOC_REQ_WI BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI;
table   (dda mms sav tda ira mtg heq iln ind card sec ins BAL_REQ_SMS BAL_REQ_WAP BAL_REQ_IPHONE HIST_REQ_SMS HIST_REQ_WAP HIST_REQ_SMART TRANS_REQ_WAP TRANS_REQ_IPHONE
      SCH_TRANS_REQ_WAP SCH_TRANS_REQ_IPHONE CAN_TRANS_REQ_WAP CAN_TRANS_REQ_IPHONE VIEW_TRANS_REQ_WAP VIEW_TRANS_REQ_IPHONE ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL 
	  ANY_LOC_REQ_WI BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI)*(sum)*f=comma12. , (sms_active wap_active all) / nocellmerge;
table (sms_active wap_active)*N;
format BAL_REQ_SMS BAL_REQ_WAP BAL_REQ_IPHONE HIST_REQ_SMS HIST_REQ_WAP HIST_REQ_SMART TRANS_REQ_WAP TRANS_REQ_IPHONE
      SCH_TRANS_REQ_WAP SCH_TRANS_REQ_IPHONE CAN_TRANS_REQ_WAP CAN_TRANS_REQ_IPHONE VIEW_TRANS_REQ_WAP VIEW_TRANS_REQ_IPHONE ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL 
	  ANY_LOC_REQ_WI BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI quick.;
run;

proc tabulate data=data.mobile_201209 missing out=activity;
where sms_active eq 1 or wap_active eq 1;
class sms_active WAP_active  BAL_REQ_SMS BAL_REQ_WAP BAL_REQ_IPHONE HIST_REQ_SMS HIST_REQ_WAP HIST_REQ_SMART TRANS_REQ_WAP TRANS_REQ_IPHONE
      SCH_TRANS_REQ_WAP SCH_TRANS_REQ_IPHONE CAN_TRANS_REQ_WAP CAN_TRANS_REQ_IPHONE VIEW_TRANS_REQ_WAP VIEW_TRANS_REQ_IPHONE ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL 
	  ANY_LOC_REQ_WI BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI;
table   (BAL_REQ_SMS BAL_REQ_WAP BAL_REQ_IPHONE HIST_REQ_SMS HIST_REQ_WAP HIST_REQ_SMART TRANS_REQ_WAP TRANS_REQ_IPHONE
      SCH_TRANS_REQ_WAP SCH_TRANS_REQ_IPHONE CAN_TRANS_REQ_WAP CAN_TRANS_REQ_IPHONE VIEW_TRANS_REQ_WAP VIEW_TRANS_REQ_IPHONE ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL 
	  ANY_LOC_REQ_WI BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI)*(N)*f=comma12. , (sms_active wap_active all) / nocellmerge;
format BAL_REQ_SMS BAL_REQ_WAP BAL_REQ_IPHONE HIST_REQ_SMS HIST_REQ_WAP HIST_REQ_SMART TRANS_REQ_WAP TRANS_REQ_IPHONE
      SCH_TRANS_REQ_WAP SCH_TRANS_REQ_IPHONE CAN_TRANS_REQ_WAP CAN_TRANS_REQ_IPHONE VIEW_TRANS_REQ_WAP VIEW_TRANS_REQ_IPHONE ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL 
	  ANY_LOC_REQ_WI BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI quick.;
run;

data activity1;
set activity;
where sms_active eq 1 or wap_active eq 1 and max(BAL_REQ_SMS,BAL_REQ_WAP,BAL_REQ_IPHONE,HIST_REQ_SMS,HIST_REQ_WAP,HIST_REQ_SMART,TRANS_REQ_WAP,TRANS_REQ_IPHONE
,SCH_TRANS_REQ_WAP,SCH_TRANS_REQ_IPHONE,CAN_TRANS_REQ_WAP,CAN_TRANS_REQ_IPHONE,VIEW_TRANS_REQ_WAP,VIEW_TRANS_REQ_IPHONE,ATM_LOC_REQ_ALL,BRANCH_LOC_REQ_ALL,
	,ANY_LOC_REQ_WI,BPAY_REQ_WI,SCH_BPAY_REQ_WI,CAN_BPAY_REQ_WI,REC_BPAY_REQ_WI);
run;


proc tabulate data=data.mobile_201209 missing;
where sms_active eq 1 or wap_active eq 1;
class sms_active WAP_active  segment;
table   segment*(N)*f=comma12. , (sms_active wap_active all) / nocellmerge;
format segment segfmt.;
run;


proc tabulate data=data.mobile_201209 missing;
class  sms_enroll wap_enroll sms_active wap_active band segment ixi_tot;
table (band  segment  ixi_tot )*(N*f=comma12.) (band  segment  ixi_tot )*(pctn<band segment ixi_tot>*f=pctfmt.), 
      (sms_enroll wap_enroll sms_active wap_active all) / nocellmerge;
format segment segfmt. ixi_tot wealthband.;
run;

proc tabulate data=data.main_201209 missing;
class   band segment ixi_tot;
table (band  segment  ixi_tot )*(N*f=comma12.) (band  segment  ixi_tot )*(pctn<band segment ixi_tot>*f=pctfmt.),All/ nocellmerge;
format segment segfmt. ixi_tot wealthband.;
run;

proc tabulate data=data.mobile_201209 missing;
class sms_enroll wap_enroll sms_active wap_active band;
var dda mms sav tda ira mtg heq iln ind card sec ins dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sec_amt contrib svcs hh ;
table   (N HH*sum )*f=comma12. (dda mms sav tda ira sec mtg heq iln  card  ind ins)*(sum)*f=comma12. 
        (dda mms sav tda ira sec mtg heq iln card ind ins)*(pctsum<hh>*f=pctfmt.)
		(dda_amt mms_amt sav_amt tda_amt ira_amt sec_amt mtg_amt heq_amt iln_amt ccs_amt ind_amt)*sum*f=dollar24.2
        (dda_amt*pctsum<dda> mms_amt*pctsum<mms> sav_amt*pctsum<sav> tda_amt*pctsum<tda> ira_amt*pctsum<ira> sec_amt*pctsum<sec> mtg_amt*pctsum<mtg> 
         heq_amt*pctsum<heq> iln_amt*pctsum<iln> ccs_amt*pctsum<card> ind_amt*pctsum<ind>)*f=pctdoll.
        , (sms_enroll wap_enroll sms_active wap_active all ) / nocellmerge;
table (svcs contrib )*(mean*f=comma12.1) hh*sum*f=comma12., (sms_enroll wap_enroll sms_active wap_active all all) / nocellmerge;
run;

proc tabulate data=data.mobile_201209 missing;
class sms_enroll wap_enroll sms_active wap_active band;
var dda mms sav tda ira mtg heq iln ind card sec ins dda_con mms_con sav_con tda_con ira_con mtg_con heq_con iln_con ind_con card_con sec_con contrib svcs hh clv_total clv_rem_ten clv_rem;
table (dda_con*pctsum<dda> mms_con*pctsum<mms> sav_con*pctsum<sav> tda_con*pctsum<tda> ira_con*pctsum<ira> sec_con*pctsum<sec> mtg_con*pctsum<mtg> 
         heq_con*pctsum<heq> iln_con*pctsum<iln> card_con*pctsum<card> ind_con*pctsum<ind>)*f=pctdoll.
        , (sms_enroll wap_enroll sms_active wap_active all all) / nocellmerge;
table (dda_con mms_con sav_con tda_con ira_con sec_con mtg_con heq_con iln_con card_con ind_con)*pctsum<hh>*f=pctdoll.
        , (sms_enroll wap_enroll sms_active wap_active all all) / nocellmerge;
run;

proc tabulate data=data.mobile_201209 missing;
where clv_flag eq 'Y';
class sms_enroll wap_enroll sms_active wap_active band;
var dda mms sav tda ira mtg heq iln ind card sec ins dda_con mms_con sav_con tda_con ira_con mtg_con heq_con iln_con ind_con card_con sec_con contrib svcs hh clv:;
table (clv_total clv_rem clv_rem_ten)*pctsum<hh>*f=pctdoll. , (sms_enroll wap_enroll sms_active wap_active all all)/ nocellmerge;
run;
