data heq;
length hhid $ 9 name $50  lender $ 50 GroupDESC $ 50;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Analysis\ACH\ifmHHClosedLoanActivity.txt' dsd dlm='09'x lrecl=4096 missover firstobs=2;
input hhid $ Customer_Name $	Origination_Date :mmddyy10. Closed_Date:mmddyy10. 	Lender $	EarliestPay :mmddyy10. 	RecentPaymentDate :mmddyy10. 	PaymentPriorToClose :comma12.2	PaymentAfterClose :comma12.2	GroupID	 $ GroupDESC $;
run;

proc tabulate data=heq;
class groupID  GroupDESC ;
table groupID *GroupDESC;
run;

proc sort data=heq;
by hhid;
run;

data data.main_201203 ( compress=binary) ;
merge data.main_201203 (in=a) data.main_201209 (in=b keep= tran_code hhid);
by hhid;
if a;
run;

data heq1;
set heq;
by hhid;
if first.hhid then output;
if hhid eq '#N/A' then delete;
run;


data data.main_201203 ( compress=binary) ;
merge data.main_201203 (in=a) heq1 (in=b keep=groupid groupdesc hhid);
by hhid;
if a;
run;






proc freq data=data.main_201203;
table GroupDESC groupid / missing;
run;

proc format;
value $ quick '1' = 'NO ACH LOAN PAYMENTS'
            '2' = 'STEADY STATE'
			'3' = 'EXISTING LOAN ADJUSTMENT'
			'4' = 'PAYMENT STOP'
			'5' = 'NEW PAYMENT';
run;

filename mprint "C:\Documents and Settings\ewnym5s\My Documents\Analysis\ACH\ach_profiles.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic ;

%create_report(class1 = groupid, fmt1 =$quick,out_dir = C:\Documents and Settings\ewnym5s\My Documents\Analysis\ACH, 
                main_source = data.main_201203,  contrib_source = data.contrib_201203, condition = groupid ne '' and groupid ne '0' ,
                out_file=Lost_HEQ_profile_1,
                logo_file= C:\Documents and Settings\ewnym5s\My Documents\Administrative\Tools\logo.png)
