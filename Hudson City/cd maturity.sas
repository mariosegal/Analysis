data cds;
set hudson.feb_combined;
where ptype in ( "TDA") and sbu_new="CON" and feb eq 1 ;
run;

data dates;
set hudson.accts_201302;
where type="CD";
keep acct_nbr maturity_date;
run;

proc sort data=dates;
by acct_nbr;
run;

proc sort data=cds;
by acct_nbr;
run;


data dates;
set dates;
maturity = input(maturity_date,mmddyy10.);
run;


data cds;
merge cds (in=a) dates (drop=maturity_date in=b) end=eof;
retain miss;
by acct_nbr;
if a then output;
if a and not b then miss+1;
if eof then put 'WARNING: There were ' miss ' records on A not on B';
drop miss;
run;

data cds;
set cds;
mature = year(maturity)*100+month(maturity);
run;

proc sort data=cds;
by pseudo_hh mature;
run;

proc print data=cds (obs=10);
var pseudo_hh maturity mature;
format maturity date.;
run;


proc summary data=cds;
by pseudo_hh mature;
output out=mature N(maturity)=mature_N sum(balance)=mature_bal;
run;

proc transpose data=mature out=mature1(drop=_name_) prefix=N_;
by pseudo_hh;
id mature;
var mature_n ;
run;

proc transpose data=mature out=mature2 (drop=_name_) prefix=bal_;
by pseudo_hh;
id mature;
var  mature_bal;
run;

proc sort data=hudson.hudson_hh;
by pseudo_hh ;
run;

data merged;
retain miss;
merge hudson.hudson_hh (where=(pseudo_hh ne .) keep = area_group_new distance ixi_assets pseudo_hh tda1 in=a) mature1 (in=b) mature2(in=c) end=eof;
by pseudo_hh;
if a then output;
if a and (not b or not C) then miss+1;
if eof then put 'WARNING: There were ' miss ' records on A not on B';
drop miss;
run;

data merged;
set merged;
N = sum(of N_20:);
n1=SUM(N,-1*n_201303,-1*n_201304);
run;

proc freq data=merged;
/*table N*area_group_new / missing nocol norow nopercent;*/
/*table area_group_new*tda1;*/
table n N1;
run;

proc format;
value dist (notsorted) 0 <-< 1 = 'Up to 1 mi'
						1 -< 2 = '1 to 2 mi'
						2 -< 3 = '2 to 3 mi'
						3 -< 4 = '3 to 4 mi'
						4 -< 5 = '4 to 5 mi'
                       5 - high ='5+ mi'
					   other = 'Unknown';
value assets (notsorted)
			0-<50000 = 'Up to $50M'
			50000-<100000 = '$50 to $100M'
		   100000-<250000 = '$100 to $250M'
		   250000-high = '$250M+'
		   other = 'Unknown';
run;

proc contents data=merged varnum short;
run;


%null_to_zero(merged, merged )


data merged1;
set merged;
array all_nums[*] N_201303 N_201304 N_201305 N_201306 N_201307 N_201308 N_201309 N_201310 N_201311 N_201312 N_201401 N_201402 N_201403 N_201405 N_201406 N_201407 N_201408 N_201409 N_201411 N_201412 N_201501 N_201502 N_201503 N_201504 N_201506 N_201509 N_201511 N_201512 N_201601 N_201602 N_201606 N_201610 N_201701 N_201702 N_201705 N_201711 N_201712 N_201801 N_201802 N_201507 N_201612 N_201404 N_201607 N_201505 N_201710 N_201510 N_201608 N_201611 N_201410 N_201508 N_201603 N_201703 N_201707 N_201706 N_201605 N_201609 N_201604 N_201704 N_201709 N_201708 N_201803 N_201804 N_202903 N_201806; 
do i = 1 to dim(all_nums);
  if all_nums[i] ge 1 then all_nums[i] = 1; 
end; 
drop i; 
run; 



proc TABULATE data=merged1 order=data;
where N1 ge 1;
VAR N_: bal_:;
CLASS area_group_new  ixi_assets DISTANCE /preloadfmt;
tabLE (AREA_GROUP_NEW="Segment" )*(distance="Distance to Branch" All="Subtotal")*ixi_assets="Estimated Wealth" All="Total", 
	 sum*(N_201303 N_201304 N_201305 N_201306 N_201307 N_201308 N_201309 N_201310 N_201311 N_201312 N_201401 N_201402 N_201403 N_201405 N_201406 N_201407 N_201408 N_201409 N_201411 N_201412 )*f=comma12.
sum="Balances (Millions)"*(bal_201303 bal_201304 bal_201305 bal_201306 bal_201307 bal_201308 bal_201309 bal_201310 bal_201311 bal_201312 bal_201401 bal_201402 bal_201403 bal_201405 bal_201406 bal_201407 bal_201408 bal_201409 bal_201411 bal_201412 )*f=doll_mill_final.
     / nocellmerge misstext='0';
format ixi_assets assets.  distance dist.;
run;




