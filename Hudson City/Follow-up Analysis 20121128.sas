proc format;
value  prods (notsorted multilabel)
	      1 = 'Single'
	    2 = '2'
		3 = '3'
		4 = '4'
		5= '5'
		6-high = '6+'
		2-high = 'Multi';
run;

proc tabulate data=hudson.hudson_hh missing;
class products /mlf;
table products*N*f=comma12. products*pcTN*f=pctfmt.;
format products prods.;
run;

proc tabulate data=data.main_201209 missing;
where products ne . and products ne 0;
where also not(products = 1 and IND =1);
class products /mlf;
table products*N*f=comma12. products*pcTN*f=pctfmt.;
format products prods.;
run;
