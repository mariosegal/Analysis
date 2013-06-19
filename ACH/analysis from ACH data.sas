data heq;
length hhid $ 9 name $50  lender $ 50 GroupDESC $ 50;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Analysis\ACH\ifmHHClosedLoanActivity.txt' dsd dlm='09'x lrecl=4096 missover firstobs=2;
input hhid $ Customer_Name $	Origination_Date :mmddyy10. Closed_Date:mmddyy10. 	Lender $	EarliestPay :mmddyy10. 	RecentPaymentDate :mmddyy10. 	PaymentPriorToClose :comma12.2	PaymentAfterClose :comma12.2	GroupID	 $ GroupDESC $;
run;

proc freq data=heq;
table GroupDESC ;
run;

*need aerlier datam waitifng for andrew to move to citrix
