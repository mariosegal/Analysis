proc sql;
select count(*) as both from data.mobile_201209 where hist_req_wap ge 1 and hist_req_smart ge 1;
select count(*) as either from data.mobile_201209 where hist_req_wap ge 1 or hist_req_smart ge 1;
select WAP_ACTIVE, count(*) as either1 from data.mobile_201209 where (hist_req_wap ge 1 or hist_req_smart ge 1) group by WAP_ACTIVE;
select count(*) as wap from data.mobile_201209 where hist_req_wap ge 1 ;
select count(*) as smart from data.mobile_201209 where  hist_req_smart ge 1;
select count(*) as active from data.mobile_201209 where  wap_active eq 1;
quit;


proc sql;
select count(*) as weird from data.mobile_201209 where (hist_req_wap ge 1 or hist_req_smart ge 1) and wap_active ne 1;
quit;

proc sql;
select count(*) as weird from data.mobile_201209 where iphone ge 1 and wap_enroll ne 1;
quit;

Title 'Activity (Excludes iphone and wap)';
proc tabulate data=data.mobile_201209 missing;
where not(iphone_active eq 1 and wap_active eq 1);
class wap_enroll sms_enroll iphone_active wap_active sms_active;
table (wap_enroll sms_enroll All),(iphone_active wap_active sms_active All)*(N*f=comma12. rowpctn*f=pctfmt.) / nocellmerge;
run;
Title ;

Title 'Activity (iphone and wap)';
proc tabulate data=data.mobile_201209 missing;
where (iphone_active eq 1 and wap_active eq 1) ;
class wap_enroll sms_enroll iphone_active wap_active sms_active;
table (wap_enroll sms_enroll All),(iphone_active wap_active sms_active All)*(N*f=comma12. rowpctn*f=pctfmt.) / nocellmerge;
run;
Title ;

*this has all the results I needed for the first page;
Title 'Activity Super Table (All)';
proc tabulate data=data.mobile_201209 missing;
class wap_enroll sms_enroll iphone_active wap_active sms_active both textand group;
table (group ALL),(sms_active all)*((iphone_active wap_active sms_active All)*(N*f=comma12. ) 
                                                (iphone_active wap_active sms_active All)*( pctn*f=pctfmt.)
                                                (iphone_active wap_active sms_active All)*(rowpctn*f=pctfmt.)),(both all)/ nocellmerge;
run;
Title ;

*this will generate the data for the activity page;
proc format;
value quick low-0 = 'N'
            1-high = 'Y';
value activity 0 = 'None'
               1 = 'WAP'
			   2='iPhone'
			   3='Both';
run;

*need to consolidate the iphone and wap variables;
data data.mobile_201209;
set data.mobile_201209;
*do bal requests;
if (BAL_REQ_WAP ge 1 and BAL_REQ_IPHONE ge 1) then balace_req = 3;
if (BAL_REQ_WAP lt 1 and BAL_REQ_IPHONE ge 1) then balace_req = 2;
if (BAL_REQ_WAP ge 1 and BAL_REQ_IPHONE lt 1) then balace_req = 1;
if (BAL_REQ_WAP lt 1 and BAL_REQ_IPHONE lt 1) then balace_req = 0;
*do history requests;
if (HIST_REQ_WAP ge 1 and HIST_REQ_SMART ge 1) then hist_req = 3;
if (HIST_REQ_WAP lt 1 and HIST_REQ_SMART ge 1) then hist_req = 2;
if (HIST_REQ_WAP ge 1 and HIST_REQ_SMART lt 1) then hist_req = 1;
if (HIST_REQ_WAP lt 1 and HIST_REQ_SMART lt 1) then hist_req = 0;
*do transfers ;
if (TRANS_REQ_WAP ge 1 and TRANS_REQ_IPHONE ge 1) then transfers = 3;
if (TRANS_REQ_WAP lt 1 and TRANS_REQ_IPHONE ge 1) then transfers = 2;
if (TRANS_REQ_WAP ge 1 and TRANS_REQ_IPHONE lt 1) then transfers = 1;
if (TRANS_REQ_WAP lt 1 and TRANS_REQ_IPHONE lt 1) then transfers = 0;
*do view sch transfers requests;
if (SCH_TRANS_REQ_WAP ge 1 and SCH_TRANS_REQ_IPHONE ge 1) then view_transfers = 3;
if (SCH_TRANS_REQ_WAP lt 1 and SCH_TRANS_REQ_IPHONE ge 1) then view_transfers = 2;
if (SCH_TRANS_REQ_WAP ge 1 and SCH_TRANS_REQ_IPHONE lt 1) then view_transfers = 1;
if (SCH_TRANS_REQ_WAP lt 1 and SCH_TRANS_REQ_IPHONE lt 1) then view_transfers = 0;
*do  cacnel transfers requests;
if (CAN_TRANS_REQ_WAP ge 1 and CAN_TRANS_REQ_IPHONE ge 1) then cancel_transfers = 3;
if (CAN_TRANS_REQ_WAP lt 1 and CAN_TRANS_REQ_IPHONE ge 1) then cancel_transfers = 2;
if (CAN_TRANS_REQ_WAP ge 1 and CAN_TRANS_REQ_IPHONE lt 1) then cancel_transfers = 1;
if (CAN_TRANS_REQ_WAP lt 1 and CAN_TRANS_REQ_IPHONE lt 1) then cancel_transfers = 0;
*do past  transfers requests;
if (VIEW_TRANS_REQ_WAP ge 1 and VIEW_TRANS_REQ_IPHONE ge 1) then past_transfers = 3;
if (VIEW_TRANS_REQ_WAP lt 1 and VIEW_TRANS_REQ_IPHONE ge 1) then past_transfers = 2;
if (VIEW_TRANS_REQ_WAP ge 1 and VIEW_TRANS_REQ_IPHONE lt 1) then past_transfers = 1;
if (VIEW_TRANS_REQ_WAP lt 1 and VIEW_TRANS_REQ_IPHONE lt 1) then past_transfers = 0;
run;





proc tabulate data=data.mobile_201209 missing;
class group sms_active WAP_active  BAL_REQ_SMS BAL_REQ_WAP BAL_REQ_IPHONE HIST_REQ_SMS HIST_REQ_WAP HIST_REQ_SMART TRANS_REQ_WAP TRANS_REQ_IPHONE
      SCH_TRANS_REQ_WAP SCH_TRANS_REQ_IPHONE CAN_TRANS_REQ_WAP CAN_TRANS_REQ_IPHONE VIEW_TRANS_REQ_WAP VIEW_TRANS_REQ_IPHONE ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL 
	  ANY_LOC_REQ_WI BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI past_transfers cancel_transfers view_transfers transfers hist_req balace_req;
table (ALL past_transfers cancel_transfers view_transfers transfers hist_req balace_req ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL ANY_LOC_REQ_WI
 BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI)*N*f=comma12. 
      (ALL past_transfers cancel_transfers view_transfers transfers hist_req balace_req ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL ANY_LOC_REQ_WI
 BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI)*colpctn*f=pctfmt., group ALL / nocellmerge;
format BAL_REQ_SMS BAL_REQ_WAP BAL_REQ_IPHONE HIST_REQ_SMS HIST_REQ_WAP HIST_REQ_SMART TRANS_REQ_WAP TRANS_REQ_IPHONE
      SCH_TRANS_REQ_WAP SCH_TRANS_REQ_IPHONE CAN_TRANS_REQ_WAP CAN_TRANS_REQ_IPHONE VIEW_TRANS_REQ_WAP VIEW_TRANS_REQ_IPHONE ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL 
	  ANY_LOC_REQ_WI BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI quick. 
     past_transfers cancel_transfers view_transfers transfers hist_req balace_req activity.;
run;

Title ' Sum of activity';
proc tabulate data=data.mobile_201209 missing;
class group sms_active WAP_active  ;
var BAL_REQ_SMS BAL_REQ_WAP BAL_REQ_IPHONE HIST_REQ_SMS HIST_REQ_WAP HIST_REQ_SMART TRANS_REQ_WAP TRANS_REQ_IPHONE
      SCH_TRANS_REQ_WAP SCH_TRANS_REQ_IPHONE CAN_TRANS_REQ_WAP CAN_TRANS_REQ_IPHONE VIEW_TRANS_REQ_WAP VIEW_TRANS_REQ_IPHONE ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL 
	  ANY_LOC_REQ_WI BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI past_transfers cancel_transfers view_transfers transfers hist_req balace_req;
table ( BAL_REQ_SMS BAL_REQ_WAP BAL_REQ_IPHONE HIST_REQ_SMS HIST_REQ_WAP HIST_REQ_SMART TRANS_REQ_WAP TRANS_REQ_IPHONE
      SCH_TRANS_REQ_WAP SCH_TRANS_REQ_IPHONE CAN_TRANS_REQ_WAP CAN_TRANS_REQ_IPHONE VIEW_TRANS_REQ_WAP VIEW_TRANS_REQ_IPHONE ATM_LOC_REQ_ALL BRANCH_LOC_REQ_ALL 
	  ANY_LOC_REQ_WI BPAY_REQ_WI SCH_BPAY_REQ_WI CAN_BPAY_REQ_WI REC_BPAY_REQ_WI)*sum*f=comma12., group ALL / nocellmerge;
/*format ;*/
run;
title;





Title 'Activity Super Table (All)';
proc tabulate data=data.mobile_201209 missing;
class wap_enroll sms_enroll iphone_active wap_active sms_active both textand group;
table (group ALL),(sms_active all)*((iphone_active wap_active sms_active All)*(N*f=comma12. ) 
                                                ),(both all)/ nocellmerge;
run;
Title ;

Title 'wap no sms';
proc tabulate data=data.mobile_201209 missing;
class


Title 'wap no sms';
proc freq data=data.mobile_201209;
where sms_enroll ne 1 and (wap_enroll eq 1);
table sms_active*(wap_active iphone_active)/missing;
run;

Title 'sms no wap';
proc freq data=data.mobile_201209;
where sms_enroll eq 1 and wap_enroll ne 1;
table sms_active*wap_active /missing;
run;
title;




*####################################################################;
* DO BLOCK charts;

data block_data;
length Group $23	Status	$ 22 Mobile_Type	$11;
inFile 'C:\Documents and Settings\ewnym5s\My Documents\Online\Active_Data 20121102.txt' dsd dlm='09'x firstobs=2;
input  group $ status $ mobile_type HHs:comma12. percent:comma24.12;
run;


goptions reset=all;
goptions device=actximg;

PROC gareabar data=block_data;
/*format sales_pct percent6.0;*/
/*format group_total dollar7.0;*/
/* 
this next label is a mis-nomer ... 
sales_pct is really on the left axis, but since the label prints at the top/left
of the graph, I'm making the text for the group_total values 
*/
/*label sales_pct='Wholesale Footwear Sales in $ Million (year = 2003)'; */
/*label company='Manufacturer';  */
/*label grouping='Grouping:';*/
vbar Group*HHs  /
  sumvar=percent subgroup=Status 
  discrete 
  des="" name="&name";
run;
