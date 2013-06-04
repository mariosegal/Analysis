libname IFM oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=Intelligentsia;
 Data Source=bagels"  schema=dbo; 


libname bagels oledb init_string="Provider=SQLOLEDB.1;
 Password=Reporting2;
 Persist Security Info=True;
 User ID=reporting_user;
 Initial Catalog=Mario1;
 Data Source=bagels"  schema=dbo; 


filename mprint "C:\Documents and Settings\ewnym5s\My Documents\SAS\macbug1.sas" ;
data _null_ ; file mprint ; run ;
options  mfile nomlogic nosymbolgen mcompilenote=all;
%merge_sql(table1=adhoc_flow_of_funds_acct,table2=adhoc_acc201203,key1=accountkey,key2=acct_nbr,output_name=Transaction_Data_Merged,
prefix=Intelligentsia.dbo,dir=ifm,where_str=month(a.perioddate) = 3)



proc sql;
create table bagels.chk201203 as select * from chk201203;
run;

proc sql;
   connect to oledb as myconn (init_string='Provider=SQLOLEDB;Password=Reporting2;Persist
Security Info=True;User ID=reporting_user;Initial Catalog=Mario1;
Data Source=Bagels'); 

execute (create table chk_201203(acountkey char(15), stype char(3));) by myconn;
disconnect from myconn;
quit;

proc sql;
insert into bagels.chk_201203 select accountkey, stype from chk201203;
quit;

filename mprint "C:\Documents and Settings\ewnym5s\My Documents\SAS\macbug1.sas" ;
data _null_ ; file mprint ; run ;
options  mfile nomlogic nosymbolgen mcompilenote=all;
%merge_sql(table1=transaction_data_merged,table2=chk_201203,key1=accountkey,key2=acountkey,output_name=Transaction_Analysis,
prefix=Mario1.dbo,dir=bagels)

proc sql;
select count(*) from data.main_201203;
quit;




*##########################################################################################################;


%macro create_sql_text() ;
	%global str1;
	%global str3;
	%let str1 =;
	%let str3 =;
	%do i=1 %to &counta;
		%if &&type_a&i = 1 %then %do;
			%let str1 = &str1 &&names_a&i number(20);
			%let str3 = &str3 a.&&names_a&i;
		%end;
		%else %do;
			%let str1 = &str1 &&names_a&i char(40);
			%let str3 = &str3 a.&&names_a&i;
		%end;
		%if &i ne &counta %then %do;
			%let str1 = &str1 ,;
			%let str3 = &str3 ,;
		%end;
	%end;

	%global str2;
	%global str4;
	%let str2 =;
	%let str4 =;
	%do i=1 %to 5;
		%if &&type_b&i = 1 %then %do;
			%let str2 = &str2 &&names_b&i number(20);
			%let str4 = &str4 b.&&names_a&i;
		%end;
		%else %do;
			%let str2 = &str2 &&names_b&i char(40);
			%let str4 = &str4 b.&&names_a&i;
		%end;
		%if &i ne 5 %then %do;
			%let str2 = &str2 ,;
			%let str4 = &str4 ,;
		%end;
	%end;
%mend create_sql_text;
