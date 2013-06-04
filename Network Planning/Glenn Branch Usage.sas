proc format ;
value cnt_a (notsorted) 
	  . = 'A. None'
      0 = 'A. None'
	  0 <- 1 = 'B. Less than 1'
	  1 <- 3 = 'C. 1 to 3'
	3 <- 5 = 'D. 3 to 5'
	5 <- high = 'E. Over 5'
;
run;

data combo;
merge data.main_201301 (in=a keep=hhid br_tr_num) 
      data.main_201302 (in=b keep=hhid br_tr_num rename=(br_tr_num=br_tr_num1)) 
      data.main_201303 (in=c keep=hhid br_tr_num rename=(br_tr_num=br_tr_num2));
by hhid;
if a and b and c;
run;

data combo;
set combo;
br_avg = mean(of br_tr:);
if br_avg = . then br_avg = 0;
run;

data data.main_201303 (compress=yes);
merge data.main_201303 (in=a ) combo (in=b keep=hhid br_avg);
by hhid;
if a;
run;


%create_report(class1=br_avg,fmt1=cnt_a,condition=dda eq 1,main_source=data.main_201303,contrib_source=data.contrib_201303,out_file=Branch Usage Profile 201303,
               out_dir=C:\Documents and Settings\ewnym5s\My Documents\Misc,
               logo_file=C:\Documents and Settings\ewnym5s\My Documents\Tools\logo.png)
;

proc means data=data.main_201303;
class br_avg;
var br_avg;
format br_avg cnt_a.;
run;
