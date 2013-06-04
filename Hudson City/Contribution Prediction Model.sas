proc contents data=hudson.modeling varnum short;
run;


proc reg data=hudson.modeling;
      model contrib= dda mms sav tda ira mtg heq ILN DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt MTG_amt HEQ_Amt iln_amt cqi_DD  
                     deposits loans both dep_amt loan_amt both_amt s1 s3 s4 s5 s6 s7 ixi_new ixi_na
            / selection=STEPWISE;
Run;


proc corr data=hudson.modeling nomiss plots(maxpoints=1000000)=scatter;
   var dda mms sav tda ira mtg heq ILN DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt MTG_amt HEQ_Amt iln_amt cqi_DD  
                     deposits loans both dep_amt loan_amt both_amt s1 s3 s4 s5 s6 s7 ixi_new ixi_na;
	with contrib A;
run;

proc corr data=hudson.modeling nomiss outp=corr1;
   var DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt MTG_amt HEQ_Amt iln_amt  dep_amt loan_amt both_amt ixi_new;
	with contrib ;
run;

data anno1;
length function $ 10 x1 y1 8 label $ 50 textcolor $ 10;
input function $ x1 y1 label $ textcolor $;
datalines;
text 25 25 label1 blue
text 50 50 label2 red
text 100 100 label3 green
;
run;

data corr2;
set corr2;
format contrib comma12.4;
run;

data corr2;
length label $ 50;
set corr2;
function = 'text';
label = trim("R2=" || put(contrib,comma12.4)) ;
textcolor='green';
x1=10;
y1=10;
run;

data anno1;
set corr2 (obs=4);
run;

data anno2;
set corr2 (firstobs=5 obs=8);
run;

data anno3;
set corr2 (firstobs=9 obs=12);
run;

options orientation=landscape;

proc sgscatter data=hudson.modeling sganno=anno1; 
plot (DDA_Amt MMS_amt sav_amt tda_amt )*contrib /
   rows=2 grid REG=(lineattrs=(color=red))  ;
run;

proc sgscatter data=hudson.modeling sganno=anno2; 
plot ( ira_amt mtg_amt heq_amt iln_amt )*contrib /
   rows=2 grid REG=(lineattrs=(color=red))  ;
run;

proc sgscatter data=hudson.modeling sganno=anno3; 
plot (  dep_amt loan_amt both_amt ixi_new)*contrib /
   rows=2 grid REG=(lineattrs=(color=red))  ;
run;

*decile it and compare to real deciles;
*then check;

