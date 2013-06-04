proc format;
value dist (notsorted) 0 <-< 5 = 'Up to 5 mi'
                       5 - high ='5+ mi'
					   other = 'Unknown';
value assets (notsorted)
           0-<250000 = 'Up to $250,000M'
		   250000-high = '$250,000M+'
		   other - 'Unknown';
		   run;

      
quit;


proc freq data=hudson.hudson_hh;

table area_group_new*ixi_assets*distance / nocol norow nopercent;
format ixi_assets assets. distance dist.;
run;
