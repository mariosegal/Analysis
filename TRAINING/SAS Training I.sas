LIBNAME training 'C:\Documents and Settings\ewnym5s\My Documents\TRAINING';

*Extract Data from a dataset;
DATA training.test_one;
set data.main_201209;
where dda eq 1;
keep hhid dda dda_amt
     sav cbr ;
run;

DATA test_two;
set data.main_201209;
where dda eq 1;
keep hhid dda: sav cbr ;
format cbr cbr2012fmt.;
rename hhid=hh;
run;

proc format ;
value  $ regions (notsorted)
    'NY','NJ','CT' = 'East'
    'CA','NV' = 'West'
	'FL','GA' = 'South'
     other = 'Other';
run;
 


*modify a dataset;
data test_two;
set test_two;
if dda_amt gt 500000 then weird = 1;
run;


proc freq data=training.test_one;
/*table weird / missing;*/
table cbr / missing;
/*format cbr cbr2012fmt.;*/
run;

proc freq data=training.test_one order = freq;
table cbr / missing;
run;


proc freq data=training.test_one;
by sav;
table cbr / missing;
run;


proc sort data=training.test_one;
by sav;
run;

proc freq data=training.test_one;
by sav;
table cbr / missing;
run;


proc freq data=training.test_one;
table cbr*sav / missing;    *rows*columns;
run;

proc freq data=training.test_one;
table cbr*sav / missing nocol norow nopercent out=test_out;
format cbr cbr2012fmt.;
run;

proc sql;
select cbr, count(cbr) from training.Test_one group by cbr;
quit;


proc freq data=data.main_201209;
where dda eq 1;
table cbr*segment / nocol norow nopercent missing;
format segment segfmt. cbr cbr2012fmt.;
run;

proc format; picture fmtround    low-high ='000,000,009' (mult=0.001);run;
proc tabulate data=data.main_201209 missing;
class cbr segment;
var dda_amt;
table cbr all, (segment ALL)*(N='HHs'*f=comma12.) (segment All)*(rowpctN='Percent'*f=pctfmt.) /  nocellmerge misstext='0';
table cbr all, (segment ALL)*(sum*dda_amt*f=fmtround.) / nocellmerge misstext='$0.00';
format segment segfmt. cbr cbr2012fmt.;
run;





*#####################################################################;
proc format ;
value segfmt . = 'Not Coded'
			 1 = 'Building Their Future'
             2 = 'Mass Affluent no Kids'
			 3 = 'Mainstream Families'
			 4 = 'Mass Affluent Families'
			 5 = 'Mainstream Retired'
			 6 = 'Mass Affluent Retired'
			 7 = 'Not Coded'
			 8 = 'Building Their Future'
			 9 = 'Mass Affluent Families'
			Other = 'Not coded';
 
value cbr2012fmt  1 = 'WNY' 
				  2='Roch'              
				  3='Ctl NY'      
	 			  4='S NY'     
				 5='Alb HVN'     
				6='Tarry'    
				7='NYC'     
				8='Philly'      
				9='PA N'     
				10='C&W PA'      
				11='SE PA'          
				12='Balt'             
				13='G Wash'      
				14='Ches A'           
				15='Ches B'         
				16='Ctl VA'         
				17='Ches DE'          
				99='Out of Mkt'
	            Other='Not Coded';
run;






proc summary data=virtual.Main_2011_new;
by hhid;
output out=summary 
       sum(csw) = csw_sum
	   min(csw) = csw_min;
run;

ods html style=mtbnew;
proc sgplot data=test_two;
vbar dda / group=cbr groupdisplay=cluster;
run;

proc sgpanel data=test_two (where=(cbr lt 5));
panelby cbr / columns=2;
vbar dda;
run;

