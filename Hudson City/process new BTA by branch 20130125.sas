*clean new BTA after fixing lat long;
*this is the entire file by branch, need to exclude PA and NY City counties;

data hudson.Bta_3mi_new_20130125;
set  hudson.Bta_3mi_new_20130125;
rename zip = zip_num zip_2 = branch_zip;
run;

data hudson.Bta_3mi_new_20130125;
length zip 8;
set  hudson.Bta_3mi_new_20130125;
zip = zip_num;
format zip z5.;
run;

proc sort data= hudson.Bta_3mi_new_20130125;
by zip;
run;


data hudson.Bta_3mi_new_20130125;
merge  hudson.Bta_3mi_new_20130125 (in=a) sashelp.zipcode (in=b keep=zip countynm statecode);
by zip;
if a;
run;

proc sql;
select count(unique(snl_branch)) from hudson.Bta_3mi_new_20130125;
run;

proc tabulate  data= hudson.Bta_3mi_new_20130125;
class statecode countynm;
table statecode*countynm,N*f=comma12.;
run;

data hudson.Bta_3mi_new_20130125;
set  hudson.Bta_3mi_new_20130125;
if countynm in ('Bronx','Kings','Queens',"New York","Philadelphia") then delete;
run;

*Now I need to create the new footprint file, issus is old one has manual zips, so I will manually add zips to the old one;

proc sort data= hudson.Bta_by_branch_20130120 out=deduped nodupkey;
by zip;
run;

proc sort data= hudson.Bta_3mi_new_20130125 out=deduped1 nodupkey;
by zip;
run;


data test;
set deduped (drop=zip_num) deduped1 (drop=zip_num);
run;

proc sort data= test out=test1 nodupkey;
by zip;
run;

* I was missing M&T plus the manual ones, so adding the old BTA and deduping because I had started with the one by branch, which is needed for branch level analysis;

data bta;
set bta;
rename zip = zip_char;
run;

data bta;
length zip 8;
set bta;
zip = zip_char;
format zip z5.;
run;

data test1;
set test1(drop=state_fips) bta(drop=state_fips);
run;


proc sort data= test1 out=test2 nodupkey;
by zip;
run;

*still not woirking add by hand, I think it was not needed, as I did not export file on test, but it did not hurt;

data extra;
length Zip 8;
input zip;
format zip z5.;
datalines;
07920
07946
07980
07748
07737
07716
07760
07701
07738
07704
07739
07750
07740
07757
07703
07701
07724
07755
07712
07723
07711
07755
08535
12531
10701
10705
;
run;

data test2;
set test2 extra;
run;

proc sort data= test2 out=test2 nodupkey;
by zip;
run;

data hudson.BTA_Final_20130125;
set test2;
run;


*ANALYSIS;

LIBNAME ixi ODBC DSN=IXI user=reporting_user pw=Reporting2 schema=dbo;

data hudson.Bta_3mi_new_20130125;
set hudson.Bta_3mi_new_20130125;
zip_char = put(zip,$5.);
if substr(zip_char,1,1) = "" then zip_char= "0" || substr(zip_char,2,4);
run;

proc sql;
select count(unique(snl_branch)) from hudson.Bta_3mi_new_20130125;
run;


proc sort data=hudson.Bta_3mi_new_20130125;
by branch_char;
run;


data temp;
merge hudson.Bta_3mi_new_20130125 (in=a) 
      ixi.mtb_postal(in=b keep=regionzipcode cycleid totalassets totalhouseholds rename=(regionzipcode=zip_char) where=(cycleid=201206))
      ixi.mtbexp_postal(in=c keep=regionzipcode cycleid totalassets totalhouseholds rename=(regionzipcode=zip_char)  where=(cycleid=201206));
by zip_char;
if a;
run;
 
proc tabulate data=temp out=scatter missing;
class snl_branch state_2;
var totalassets totalhouseholds;
table state_2 * snl_branch, N sum*(totalassets totalhouseholds) rowpctsum<totalhouseholds>*(totalassets)*f=pctdoll.;
run;


*Abbas page;
proc format ;
value a low-<300000 = 'Mainstraeam'
      300000-<1000000 = "Mass Affl"
	  1000000-high = "Affluent";
	  run;

	  data scatter;
	  set scatter;
	  avg = TotalAssets_PctSum_11/100;
		TotalAssets_PctSum_11=TotalAssets_PctSum_11/100;
	  run;

proc tabulate data=scatter;
class avg;
var totalAssets_PctSum_11 TotalHouseholds_Sum totalassets_sum;
table avg all, N sum*(TotalAssets_PctSum_11 TotalHouseholds_Sum totalassets_sum)*f=comma24.;
format avg a.;
run;


*do it by asset band to look at the tails of the distribution. I think it is very heavy;

data temp;
merge hudson.Bta_3mi_new_20130125 (in=a) 
      ixi.mtb_tiers_postal(in=b  rename=(regionzipcode=zip_char) where=(cycleid=201206));
by zip_char;
if a;
run;

proc sort data=temp out=temp1 (keep=snl_branch address city) nodupkey;
by snl_branch;
run;

proc contents data=temp varnum short; run;

proc tabulate data =temp missing;
class snl_branch;
var ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars 
    T100kTo250kDollars T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars
    T5mTo7P5mDollars T7P5mTo10mDollars T10mTo15mDollars T15mTo25mDollars T25mPlusDollars ZeroHouseholds T1To2p5kHouseholds 
    T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds 
    T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds T2mTo3mHouseholds 
    T3mTo5mHouseholds T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds;
table snl_branch, sum*(ZeroHouseholds T1To2p5kHouseholds 
    T2p5kTo10kHouseholds T10kTo25kHouseholds T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds 
    T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds T1P5mTo2mHouseholds T2mTo3mHouseholds 
    T3mTo5mHouseholds T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds T25mPlusHouseholds)*f=comma12. / nocellmerge misstext="0";
table snl_branch, sum*(ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars 
    T100kTo250kDollars T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars
    T5mTo7P5mDollars T7P5mTo10mDollars T10mTo15mDollars T15mTo25mDollars T25mPlusDollars)*f=dollar24. / nocellmerge misstext="0";
run;

