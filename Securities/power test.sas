data a;
input cell $ response $ count;
datalines;
a_t n 9912 
a_t y 15
a_c n 2369 
a_c y 2
;
run;

proc freq data=a;
table cell*response;
table cell*response / chisq;
run;


proc power;
       twosamplefreq test=pchi
                     groupproportions=(.0026 .0015)
					 groupns=(11383 2757)
					 SIDES=1 2 U L
					 alpha=.05 .1 .25 .3333
                     power =.;

       run;



	   
proc power;
       twosamplefreq test=pchi
                     groupproportions=(.0019 .0015)
					 groupns=(52979 12837)
					 SIDES=1 2 U L
					 alpha=.05 .1 .25 .3333
                     power =.;

       run;
