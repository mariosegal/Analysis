proc freq data=hudson.clean_20121106;
table type;
run;



proc format;
value $ savings 	'01' = 'Passbook'
				'41' = 'Statement'
				'31' = 'MMA Sav'
				'22' = 'Hlday Club'
				'23' = 'Vacat Club'
				'54' = 'Rent Scty'
				'55' = 'landlord'
				'60' = 'Statement IRA'
				'32' = 'MMA Sav IRA';
value $ sbu 	'54' ,'55' = 'BUS'
				other = 'CON';
value $ product   '01', '41',  '22', '23', '54', '55' = 'SAV'
				'31' = "MMS"
 				'60' ,'32' = 'IRA';
run;



Title 'Hudson Savings Accounts';
proc tabulate data=hudson.clean_20121106;
where type = "SAV";
class subtype;
var curr_bal;
table subtype='Account Type' ALL , N='Accounts'*f=comma12. sum*curr_bal='As of Balance'*f=dollar24. / nocellmerge;
format subtype $savings.;
run;


Title 'Hudson Checking Accounts';
proc tabulate data=hudson.clean_20121106;
where type = "CHKG";
class subtype;
var curr_bal;
table subtype='Account Type' ALL , N='Accounts'*f=comma12. sum*curr_bal='As of Balance'*f=dollar24. / nocellmerge;
format subtype $checking.;
run;

proc format;
value $ cdtype	'24','04','10','14','21','09','27','13','18','16','25','29','30','20','22','80' = 'TDA'
				'72','62','63','67','71','79','75','74','70','76','68','73','77','78','84','69' = 'IRA';
value $ cdstype (notsorted) 
                '24'= '91 day'
				'04'='4M'
				'10'='5M'
				'14'='6M'
				'21'='7M'
				'09'='9M'
				'27'='1Y'
				'13'='13M'
				'16' = '2Y'
				'25','22'= '3Y'
				'29'='4Y'
				'30'='5Y'
				'80'='OTH'
				'72' = '91 day IRA'
				'62'='4M IRA'
				'63'='5M IRA'
				'67'='6M IRA'
				'71'='7M IRA'
				'79'='9M IRA'
				'75'='1Y IRA'
				'74'='13M IRA'
				'70','76'='18M IRA'
				'68' = '2Y IRA'
				'73','84' = '3Y IRA'
				'77'='4Y IRA'
				'78'='5Y IRA'
				'69'='OTH IRA';
run;

Title 'Hudson Time Deposit Accounts';
proc tabulate data=hudson.clean_20121106;
where type = "CD";
class subtype;
var curr_bal;
table subtype='Account Type' ALL , N='Accounts'*f=comma12. sum*curr_bal='As of Balance'*f=dollar24. / nocellmerge;
format subtype $cdstype.;
run;
