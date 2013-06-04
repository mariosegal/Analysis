libname infousa odbc dsn=infousa;


proc contents data=infousa.info_1 varnu short;
run;

data bb.private;
set infousa.info_1;
where PUBLIC_PRIVATE_CODE  = "PRIVATE";
run;

proc sort data=bb.private;
by primary_zip_code;
run;


proc sort data=branch.Cbr_by_zip_2012;
by zip;
run;

data bb.private;
merge bb.private (in=left) branch.Cbr_by_zip_2012 (in=right rename=(zip=primary_zip_code));
by primary_zip_code;
if left;
run;


proc format;
value  quick 
	. = 'Out of Mkt'
	other = [cbr2012fmt10.];
run;

title 'Privately held Businesses';
proc tabulate data=bb.private missing ordr=data;
class cbr_zip Location_Sales_Volume_Desc /preloadfmt;
table cbr_zip,Location_Sales_Volume_Desc* N*f=comma12. / nocellmerge misstext ='0';
format cbr_zip quick. Location_Sales_Volume_Desc $salesband.;
run;
