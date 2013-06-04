proc sort data=hudson.hudson_hh;
by chk_act;
run;

proc freq data=hudson.hudson_hh;
table chk_act / missing;
run;

data chart;
set hudson.hudson_hh (keep=pseudo_hh distance chk_act dda_amt);
select (chk_act);
	when ('') blank=distance;
	when ('Inactiv') inactive = distance;
	when ('No Chk') nochk=distance;
	when ('Primary') primary = distance;
	when ('Seconda') secondary=distance;
end;
run;

ods pdf file='My Documents\Hudson City\Checking Detail 20130301.pdf' style=mtbnew;
options orientation=PORTRAIT;

goptions hsize=7.5 vsize=5;
ODS PDF startpage=NO;
footnote 'MCD - Customer Insights Analysis';
Title 'Histograms of Distance to Branch';
proc sgplot data=chart ;
histogram primary / legendlabel="Primary Checking" transparency=0.2 ;
histogram secondary / legendlabel="Secondary Checking"  transparency=0.2;
histogram inactive / legendlabel="Inactive Checking"  transparency=0.2;
histogram nochk / legendlabel="No Checking"  transparency=0.2;
keylegend / location=inside position=topright across=1;
xaxis label="Distance to Branch (Miles)" labelattrs=(Weight=Bold);
yaxis labelattrs=(Weight=Bold);
run;

goptions hsize=7.5 vsize=5;
ODS PDF startpage=NO;
Title 'BoxPLots of Distance to Branch';
proc sgplot data=chart ;
where chk_act ne '';
vbox distance / legendlabel="Primary Checking" transparency=0.2 group=chk_act MEANATTRS=(color="red" symbol='DiamondFilled') MEDIANATTRS=(color="red")
                OUTLIERATTRS=(color="lightgrey");
/*vbox secondary / legendlabel="Secondary Checking"  transparency=0.2;*/
/*vbox inactive / legendlabel="Inactive Checking"  transparency=0.2;*/
/*vbox nochk / legendlabel="No Checking"  transparency=0.2;*/
keylegend / location=inside position=topright across=1;
yaxis label="Distance to Branch (Miles)" labelattrs=(Weight=Bold);
run;

goptions hsize=7.5 vsize=5;
ODS PDF startpage=YES;
Title 'BoxPLots of Checking Balance';
proc sgplot data=chart ;
where chk_act ne '';
vbox dda_amt / legendlabel="Primary Checking" transparency=0.2 group=chk_act MEANATTRS=(color="red" symbol='DiamondFilled') MEDIANATTRS=(color="red")
                OUTLIERATTRS=(color="lightgrey");
/*vbox secondary / legendlabel="Secondary Checking"  transparency=0.2;*/
/*vbox inactive / legendlabel="Inactive Checking"  transparency=0.2;*/
/*vbox nochk / legendlabel="No Checking"  transparency=0.2;*/
keylegend / location=inside position=topright across=1;
yaxis label="Distance to Branch (Miles)" labelattrs=(Weight=Bold) max=250000;
format dda_amt dollar12.;
run;

ods pdf close;


*tag interest;
proc freq data=hudson.clean_20121106;
where ptype = 'DDA' and sbu_new="CON";
table stype;
run;

proc format ;
value $ interest 
	'High Value' = 'Interest'
    'Better Int' = 'Interest'
	'Super'='Interest'
	other = 'Non Int';
run;




data dda; 
set hudson.clean_20121106 (keep=pseudo_hh curr_bal stype ptype sbu_new);
where ptype = 'DDA' and sbu_new='CON';
dda_type = put(stype,$interest.);
run;

proc sort data=dda;
by pseudo_hh dda_type;
run;

proc summary data= dda (keep=pseudo_hh dda_type curr_bal);
by pseudo_hh dda_type;
output out=chk sum(curr_bal)=balance;
run;


proc transpose data=chk(drop=_:) out=chk1 (drop=_:) let;
by pseudo_hh;
id dda_type;
run;

proc sort data=chart;
by pseudo_hh;
run;

data chart;
merge chart (in=a) chk1 (in=b);
by pseudo_hh;
if a;
run;


ods pdf file='My Documents\Hudson City\Checking Detail type of Checking 20130301.pdf' style=mtbnew;
options orientation=PORTRAIT;

goptions hsize=7.5 vsize=5;
ODS PDF startpage=NO;

Title 'BoxPLots of Checking Balance - Interest Checking';
proc sgplot data=chart ;
where chk_act ne '';
vbox interest / legendlabel="Primary Checking" transparency=0.2 group=chk_act MEANATTRS=(color="red" symbol='DiamondFilled') MEDIANATTRS=(color="red")
                OUTLIERATTRS=(color="lightgrey");
/*vbox secondary / legendlabel="Secondary Checking"  transparency=0.2;*/
/*vbox inactive / legendlabel="Inactive Checking"  transparency=0.2;*/
/*vbox nochk / legendlabel="No Checking"  transparency=0.2;*/
keylegend / location=inside position=topright across=1;
yaxis label="Distance to Branch (Miles)" labelattrs=(Weight=Bold) max=150000;
format dda_amt dollar12.;
run;

goptions hsize=7.5 vsize=5;
ODS PDF startpage=NO;

Title 'BoxPLots of Checking Balance - Non Interest Checking';
proc sgplot data=chart ;
where chk_act ne '';
vbox non_int / legendlabel="Primary Checking" transparency=0.2 group=chk_act MEANATTRS=(color="red" symbol='DiamondFilled') MEDIANATTRS=(color="red")
                OUTLIERATTRS=(color="lightgrey");
/*vbox secondary / legendlabel="Secondary Checking"  transparency=0.2;*/
/*vbox inactive / legendlabel="Inactive Checking"  transparency=0.2;*/
/*vbox nochk / legendlabel="No Checking"  transparency=0.2;*/
keylegend / location=inside position=topright across=1;
yaxis label="Distance to Branch (Miles)" labelattrs=(Weight=Bold) max=50000;
format dda_amt dollar12.;
run;

ods pdf close;
