PROC IMPORT OUT= HUDSON.ACCTS_201302 
            DATAFILE= "C:\Documents and Settings\ewnym5s\My Documents\20
1302_FinalExport.txt" 
            DBMS=TAB REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

*of course this did not work as expected, I need to do i tmanually;

data temp_feb;
length hhld $ 255 ACCT_NBR $ 30 type $ 20 subtype $ 20 name_1 $ 255 name_2 $ 255 ADDRESS_1 $ 255 ADDRESS_2 $ 255 city $ 255 state $ 255
       ZIP $ 255 COUNTRY$ 255 REGION $ 255 SSN_1 $ 9 SSN_2 $ 9 SSN_TYPE $ 10  PHONE_1 $ 20 PHONE_2	 $ 20 DOB $ 20
	   N_ADDRESS $ 255 N_ADDR2 $ 255 N_CITY	$ 150 N_STATE $ 2	N_ZIP10 $ 10 CNAME1	$ 255  Key $ 100 curr_bal $ 20 open_date $ 10 close_date $ 10 MATURITY_DATE $ 10;
infile "C:\Documents and Settings\ewnym5s\My Documents\201302_FinalExport.txt"  dlm='09'x lrecl=4096  firstobs=2 obs=MAX dsd;
input hhld $  acct_nbr $ open_date $  close_date $ status $ type $ subtype $ sbu $ branch $ name_1 $ name_2 $ ADDRESS_1 $ 
      ADDRESS_2 $ CITY $ state $ ZIP $	COUNTRY	$ REGION $ LAT	LONG	SSN_1 $ 	SSN_2 $ SSN_TYPE $  DOB $	MATURITY_DATE $ 	
      CURR_BAL $	AVG_BAL	ORIGINAL_AMT LINE_AMT	PHONE_1 $ 	PHONE_2 $ 	PROFITABILITY $	DEBIT $	DIRECT_DEPOSIT $	BILL_PAY $	ODL $	WEB $	
      N_ADDRESS	$ N_ADDR2 $	N_CITY $	N_STATE	$ N_ZIP10	N_LON	N_LAT	CNAME1	CDIST1  Key $	AM_Annuity	AM_Bond	AM_Deposits	AM_MutualFund	
      AM_OtherAssets	AM_StockAssets	TotalAssets	DM_CD DM_IntChecking	DM_MMS	DM_NonIntChecking	DM_OthChecking DM_Savings	
        Segment $ NOSOL_EMAIL $	NOSOL_FAX $	NOSOL_MAIL $	NOSOL_PHONE $	INT_RATE;
run;


%squeeze(temp_feb,HUDSON.ACCTS_201302);


#curr_bal appears to have - at the end of thenumber, I need to clean that ;

data HUDSON.ACCTS_201302;
length balance 8;
set HUDSON.ACCTS_201302;
if find(curr_bal,'-') ne 0 then 
    balance = -1*input(substr(curr_bal,1,find(curr_bal,'-')-1),comma24.2);
else balance = input(curr_bal,comma24.2);
run;













HHLD_NBR	ACCT_NBR	OPEN_DATE	CLOSE_DATE	STATUS	TYPE	SUBTYPE	SBU	BRANCH	NAME_1	NAME_2	ADDRESS_1	ADDRESS_2	CITY	
STATE	ZIP	COUNTRY	REGION	LAT	LONG	SSN_1	SSN_2	SSN_TYPE	DOB	MATURITY_DATE	CURR_BAL	AVG_BAL	ORIGINAL_AMT	
LINE_AMT	PHONE_1	PHONE_2	PROFITABILITY	DEBIT	DIRECT_DEPOSIT	BILL_PAY	ODL	WEB	N_ADDRESS	N_ADDR2	N_CITY	N_STATE	
N_ZIP10	N_LON	N_LAT	CNAME1	CDIST1	Key	AM_Annuity	AM_Bond	AM_Deposits	AM_MutualFund	AM_OtherAssets	AM_StockAssets	TotalAssets	DM_CD	DM_IntChecking	DM_MMS	DM_NonIntChecking	DM_OthChecking	DM_Savings	Segment	NOSOL_EMAIL	NOSOL_FAX	NOSOL_MAIL	NOSOL_PHONE	INT_RATE
