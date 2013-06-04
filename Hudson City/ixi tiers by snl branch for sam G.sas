proc sort data=temp_tiers;
by snl_branch address city state_2;
run;

proc summary data=temp_tiers;;
by snl_branch address city state_2;
output out=tiers_sum sum(ZeroDollars -- T25mPlusHouseholds)=;
run;

proc export data=tiers_sum (drop = _:) outfile='C:\Documents and Settings\ewnym5s\My Documents\Hudson City\HH Counts by Tier by Branch 20130411.xlsx' dbms=excel;
run;

