*Read and clean the data;

libname data1 'C:\Documents and Settings\ewnym5s\My Documents\Analysis\Business Banking\Business Customers and Prospects by County & Zip Code.xlsx';

data data2;
set data1.'Prospects by Zip$'n;
where Business_Banking_Prospects_by_Co ne .;
rename Business_Banking_Prospects_by_Co=zip_num
       F2 = propsects f3=avg_sales f4=avg_emp f5=pctTS f6=sales f7=employees f8=Target_prospects;
	   drop f9 f10 f11 f12;
run;

proc datasets library=work;
modify data2;
attrib _all_ label=' ';
run;


data hudson.bb_prospects;
set data2;
run;

*validate the BTAs make sense;




