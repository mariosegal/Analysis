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

proc freq data=bagels.top_company_flow;
table company;
run;

data a;
set bagels.top_company_flow;
dummy_amt= debit_amt;
run;

options missing='0';
proc tabulate data=a (where=(type  eq "R"));
class company debit_amt type;
var  debits dummy_amt credit_amt;
table company, debit_amt*(N*f=comma12. sum*(dummy_amt='Debit_Amt' credit_amt)*f=dollar24.) / nocellmerge;
format debit_amt balband.;
run;
options missing='.';
 
data b;
set a;
where company = 'PERSHING';
run;

proc sort data=b;
by descending debit_amt;
run;
