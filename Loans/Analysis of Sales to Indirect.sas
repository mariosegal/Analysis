data temp_ind;
set data.main_201203;
where tran_group_12 ne '' and  ind eq 1 and sum(dda,mms,sav,tda,ira,sec,ins,trs,mtg,heq,iln,card,sdb) ge 1;
keep hh distance dda mms sav tda ira sec ins trs mtg heq iln card sdb;
run;

proc format library = sas;
value distfmt 0-<1 = 'Under 1 mile'
              1-<2 = '1 to 2 Miles'
			  2-<3 = '2 to 3 Miles'
			  3-<4 = '3 to 4 Miles'
			  4-<5 = '4 to 5 Miles'
			  5-<7.5 = '5 to 7.5 Miles'
			  7.5-<10 = '7.5 to 10 Miles'
			  10-<15 = '10 to 15 Miles'
			  15-<20 = '15 to 20 Miles'
			  20-high = 'Over 20 Miles';
run;
 


proc tabulate data=temp_ind missing;
var hh dda mms sav tda ira sec ins trs mtg heq iln card sdb;
class distance;
table hh dda mms sav tda ira sec ins trs mtg heq iln card sdb, distance*(sum) / nocellmerge;
format distance distfmt.;
run;

