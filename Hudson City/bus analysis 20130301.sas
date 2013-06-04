data bus;
set hudson.clean_20121106 ;
where sbu_new = 'BUS';
run;

proc sort data=bus;
by pseudo_hh ptype;
run;

proc sort data=bus out=unique nodupkey;
by pseudo_hh;
run;


proc summary data=bus;
by pseudo_hh ptype;
output out=bus_summ(rename=(_freq_ =count)) 
       sum(curr_bal)=balance ;
run;


data bus_summ;
set bus_summ;
by pseudo_hh;
hh = 0;
if first.pseudo_hh then hh = 1;
run;

proc sql;
select sum(hh) into :total from bus_summ ;
run;

data bus_summ;
set bus_summ;
penet = 1/&total;
select (ptype);
	when('DDA') order = 1;
	when('MMS') order = 2;
	when('SAV') order = 3;
	when('CLN') order = 5;
	when('MTG') order = 4;
end;
run;

proc format ;
value $ names (notsorted)
	'DDA' = 'Checking'
	'MMS'= 'Money Market'
	'SAV' = 'Savings'
	'MTG' = 'Mortgage'
	'CLN' = ' Comm Loan';
run;

proc tabulate data=bus_summ missing;
class ptype;
var balance count hh ;
table ptype all , N sum*((hh count)*f=comma12. balance*f=dollar24.);
table sum*hh*f=comma12.;
run;

proc sort data=bus_summ;
by order;
run;


ods pdf file='My Documents\Hudson City\Business Banking Profile 20130301.pdf' style=mtbnew;
options orientation=PORTRAIT;

goptions hsize=7.5 vsize=5;
ODS PDF startpage=NO;
footnote 'MCD - Customer Insights Analysis';

Title 'Product Penetration';
proc sgplot data=bus_summ ;
vbar ptype / missing response=penet nostatlabel grouporder=data 
            datalabel DATALABELATTRS=(family=Arial Size=6);
xaxis label='Product' LABELATTRS=(family=Arial Weight=Bold)   tickvalueformat=DATA type=discrete 
      discreteorder=data fitpolicy=stagger valueattrs=(family=Arial );
yaxis label='Product Penetration' LABELATTRS=(family=Arial Weight=Bold) valueattrs=(family=Arial );
format  ptype $names. penet percent4.;
run;



goptions hsize=7.5 vsize=5;
ODS PDF startpage=NO;
Title 'Average Product Balances';
proc sgplot data=bus_summ ;
vbar ptype / missing response=balance nostatlabel grouporder=data 
            datalabel DATALABELATTRS=(family=Arial Size=6) ;
xaxis label='Product' LABELATTRS=(family=Arial Weight=Bold)   tickvalueformat=DATA type=discrete 
      discreteorder=data fitpolicy=stagger valueattrs=(family=Arial );
yaxis label='Balance' LABELATTRS=(family=Arial Weight=Bold) valueattrs=(family=Arial );
format  ptype $names. balance dollar24.;
run;

options orientation=LANDSCAPE;
ods layout start columns=3;
ods region;
ods graphics / height=5in width=3in; 
Title  'Product Balances';
proc sgplot data=bus_summ ;
where ptype in ('DDA','SAV');
vbox balance / missing group=ptype  grouporder=data MEANATTRS=(color="red" symbol='DiamondFilled') MEDIANATTRS=(color="red")
                OUTLIERATTRS=(color="lightgrey");
/*xaxis label='Product' LABELATTRS=(family=Arial Weight=Bold)   tickvalueformat=DATA type=discrete */
/*      discreteorder=data fitpolicy=stagger valueattrs=(family=Arial );*/
yaxis label='Balance' LABELATTRS=(family=Arial Weight=Bold) valueattrs=(family=Arial ) max=20000;
format  ptype $names. balance dollar24.;
run;

ods region;
ods graphics / height=5in width=3in; 
Title  'Product Balances';
proc sgplot data=bus_summ ;
where ptype in ('MMS');
vbox balance / missing group=ptype  grouporder=data MEANATTRS=(color="red" symbol='DiamondFilled') MEDIANATTRS=(color="red")
                OUTLIERATTRS=(color="lightgrey");
/*xaxis label='Product' LABELATTRS=(family=Arial Weight=Bold)   tickvalueformat=DATA type=discrete */
/*      discreteorder=data fitpolicy=stagger valueattrs=(family=Arial );*/
yaxis label='Balance' LABELATTRS=(family=Arial Weight=Bold) valueattrs=(family=Arial ) max=200000;
format  ptype $names. balance dollar24.;
run;


ods region;
ods graphics / height=5in width=3in; 
Title  'Product Balances';
proc sgplot data=bus_summ ;
where ptype not in ('DDA','MMS','SAV');
vbox balance / missing group=ptype  grouporder=data MEANATTRS=(color="red" symbol='DiamondFilled') MEDIANATTRS=(color="red")
                OUTLIERATTRS=(color="lightgrey");
/*xaxis label='Product' LABELATTRS=(family=Arial Weight=Bold)   tickvalueformat=DATA type=discrete */
/*      discreteorder=data fitpolicy=stagger valueattrs=(family=Arial );*/
yaxis label='Balance' LABELATTRS=(family=Arial Weight=Bold) valueattrs=(family=Arial ) max=1500000;
format  ptype $names. balance dollar24.;
run;

ods layout end;
ods pdf close;
