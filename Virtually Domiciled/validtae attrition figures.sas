*read data;

data virtual.dec10;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\dec10.txt' dsd dlm='09'x lrecl=4096 firstobs=2 OBS=MAX;
INPUT hhID $                                                         
         dda                                                            
         mms                                                            
         sav                                                            
         tda                                                             
         ira                                                             
         sec                                                            
         trs                                                             
         mtg                                                            
         heq                                                             
         card                                                       
         ILN                                                             
         sln                                                           
         sdb                                                             
         ins                                                            
         bus                                                             
         com  
         tenure
		 chk_date :mmddyy10.;
tenure_yr = divide(tenure,365);
run;

data x;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\2010IND.txt' dsd dlm='09'x lrecl=4096 firstobs=2 OBS=max;
INPUT hhID $                                                         
         ind;
run;

data virtual.dec10;
merge virtual.dec10 (in=a) x (in=b);
by hhid;
if a;
run;


data virtual.dec11;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\dec11.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=MAX;
INPUT hhID $                                                         
         dda                                                            
         mms                                                            
         sav                                                            
         tda                                                             
         ira                                                             
         sec                                                            
         trs                                                             
         mtg                                                            
         heq                                                             
         card                                                       
         ILN                                                             
         sln                                                           
         sdb                                                             
         ins                                                            
         bus                                                             
         com  
         tenure
		 chk_date :mmddyy10.;
tenure_yr = divide(tenure,365);
run;

data x;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\apr12ten.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=MAX;
INPUT hhID $                                                         
          chk_date :mmddyy10.;
run;

data data.main_201203;
merge data.main_201203 (in=a) x (in=b);
by hhid;
if a;
run;

data distance;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\dist.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=MAX;
input hhid $ distance;
run;

data virtual.dec10;
merge virtual.dec10 (in=a) distance (in=b);
by hhid;
if a;
run;

data coords;
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\coords.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=MAX;
input hhid $ lat long;
run;

data virtual.dec10;
merge virtual.dec10 (in=a) coords (in=b);
by hhid;
if a;
run;

data br;
length hhid $ 9 cb_name $ 5;
infile 'C:\Documents and Settings\ewnym5s\My Documents\y.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=MAX;
input hhid $ cb_name $;
run;

data virtual.dec10;
merge virtual.dec10 (in=a) br (in=b);
by hhid;
if a;
run;

data virtual.dec10;
set virtual.dec10;
exclude = 0;
if lat eq 0 or long eq 0 or cb_name eq '' then exclude=1;
run;


*Merge the 2 Data sets to define if they survived;

data combined;
merge VIRTUAL.dec10 (in=a) VIRTUAL.dec11 (in=b keep=hhid dda rename=(dda=dda_11));
by hhid;
if a;
retain_flag = 0;
if a and b then retain_flag=1; 
chk_tenure = '31dec2010'd - chk_date + 1;
run;


*overall attrition (count the retain_falg=0, look at overall percent on freq table);
proc freq data=combined;
table retain_flag;
run;


*checking attrition;
proc freq data=combined;
table dda*retain_flag / nocol nopercent;
run;



*checking attrition by checking tenure;
proc format;
value months . = 'None'
			1-<30 = '1M'
             30-<60 = '2M'
			 60-<90 = '3M'
			 90-<120 = '4M'
			 120-<150 = '5M'
			 150-<180 = '6M'
			 180-<210 = '7M'
			 210-<240 = '8M'
			 240-<270 = '9M'
			 270-<300 = '10M'
			 300-<330 = '11M'
			 330-<360 = '12M'
			 360-<720 = '1-2Yrs'
			 720-<1080 = '2-3Yrs'
			 1080-<1440 = '3-4Yrs'
			 1440-<1800 = '4-5Yrs'
			 1800-high = '5+ Yrs';
run;


proc freq data=combined;
where dda eq 1;
table (chk_tenure )*(retain_flag )/  nopercent;
format chk_tenure months.;
run;


proc freq data=combined;
where dda eq 1;
table chk_date;
format chk_date mmddyy10.;
run;


*analyze by product ownership;

proc tabulate data=combined missing;
class dda mms sav tda ira sec trs mtg heq card iln ind sln sdb ins  bus com retain_flag;
var ;
table (dda all) (mms all) (sav all) (tda all) (ira all) (sec all) (trs all) (mtg all) (heq all) (card all) (iln all) (ind all)
      (sln all) (sdb all) (ins all)  ALL, (retain_flag ALL)*(N rowpctN) / nocellmerge;
run;

*average tenure for remote transactors;

data temp;
set data.main_201203 (keep=hhid chk_date tran_group_12 tran_segment);
chk_tenure = '30apr2012'd - chk_date + 1;
run;


 
proc tabulate data=temp missing;
where tran_segment not in ('Inactive' 'X' '') ;
class tran_segment chk_tenure;
table (chk_tenure all),(tran_segment ALL)*(N colpctN);
format chk_tenure months.;
run;



proc tabulate data=combined missing;
where exclude eq 0;
class distance retain_flag ;
table distance all, (retain_flag All)*(N rowpctN) / nocellmerge;
format distance distfmt.;
run;


