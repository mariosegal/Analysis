data std_mtgs_2;
length acct_nbr $ 14 portfolio $ 10 street1 $ 255 City1 $ 30 State1 $ 2 zip1 $ 9 add1 $ 255 add2 $ 255 city $ 255 state $ 2 zip $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\Hudson City\Purchased Mtgs GeoCoded.txt' dsd dlm='09'x lrecl=4096 missover firstobs=2 obs=max;
input acct_nbr $  portfolio $ curr_bal :comma12. street1 $  city1 $  state1 $ zip1 $ id add1 $  add2 $  city $  state $ zip $ long lat snl_key distance;
run;

proc meaNS DATA=STD_MTGS_2 N sum;
VAR curr_bal;
format curr_bal dollar24.;
output sum(curr_bal)= total;
run;

proc meaNS DATA=hudson.mtg_external N sum;
var balance;
format balance dollar24.;
/*output sum(curr_bal)= total;*/
run;

proc meaNS DATA=hudson.mtg N sum;
var balance;
format balance dollar24.;
/*output sum(curr_bal)= total;*/
run;

*the file Jeremy gave me, that was given to him was actually the serviced ones, I happen to appear to have std addresses for those let me see;

data hudson.mtg_external;
length zip_clean $ 5;
set hudson.mtg_external;
zip_clean = zip;
b=strip(zip_clean);
a=length(strip(zip_clean));
if length(strip(zip_clean))=4 then zip_clean=cats('0',strip(zip_clean));
key = catx("*",street,city,state,zip_clean);
run;

data hudson.hh_keys_20121106;
set hudson.hh_keys_20121106;
if find(key,'*',-9999999) ne 0 then do;
keyb=substr(key,1,find(key,'*',-9999999)+5);
end;
else do;
keyb=key;
end;
run;

proc sort data=hudson.hh_keys_20121106;
by keyb;
run;

proc datasets library=hudson;
modify mtg_external;
rename key=keyb;
run;

proc sort data=hudson.mtg_external nodupkey out=external;
by keyb;
run;



data matches new old;
merge hudson.hh_keys_20121106 (in=flag1 keep=keyb) hudson.mtg_external(in=flag2);
by keyb;
if flag1 and flag2 then output matches;
if not flag1 and flag2 then output new;
run;

*create file to append mew to clean;
data new1;
length acct_nbr $ 14  zip $ 10 key $ 93;
set new (drop=zip);
acct_nbr = acct;
source = 'EXT';
ptype ='MT1';
sbu_new="CON";
key = keyb;
zip = zip_clean;
keep  open_date   state zip_clean city  key balance sbu_new ptype source acct_nbr;
rename balance=curr_bal open_date=open ;
run;

proc sort data=new1 nodupkey;
by acct_nbr;
run;

*for matches I need to get the real key first and the pseudo_hh;
data matches;
merge hudson.hh_keys_20121106 (in=flag1 keep=keyb key pseudo_hh) hudson.mtg_external(in=flag2);
by keyb;
if flag1 and flag2 then output matches;
run;

proc sort data=matches nodupkey;
by acct;
run;

data matches1;
length acct_nbr $ 14  zip $ 10 ;
set matches (drop=zip);
acct_nbr = acct;
source = 'EXT';
ptype ='MT1';
sbu_new="CON";
zip = zip_clean;
keep     open_date state zip_clean city  key balance sbu_new ptype source acct_nbr pseudo_hh;
rename balance=curr_bal  open_date=open;
run;

data extra;
set new1 matches1;
run;

data hudson.Clean_20121106;
set hudson.Clean_20121106;
open = datepart(open_date);
run;


data clean_test;
set hudson.Clean_20121106 extra;
run;


proc sort data=clean_test;
by  acct_nbr ssn_1;
run;

proc sort data=hudson.hh_keys_20121106;
by  acct_nbr ssn_1;
run;

data clean_test;
merge clean_test (in=a) hudson.hh_keys_20121106(in=b keep=acct_nbr ssn_1 key);
by acct_nbr ssn_1;
if a;
run;

proc freq data=clean_test;
where pseudo_hh eq .;
table source /missing;
run;


proc sort data=clean_test;
by  descending pseudo_hh;
run;


data newkeys;
set clean_test;
where pseudo_hh eq .;
keep key;
run;


proc means data=clean_test;
var pseudo_hh;
run;

proc sort data=newkeys out=xxx nodupkey;
by key;
run;


data xxx;
length pseudo_hh 4;
set xxx;
pseudo_hh = _n_ + 300573;
run;

proc sort data=clean_test;
by key;
run;

data clean_test;
merge clean_test (in=a) xxx (in=b);
by key;
if a;
run;

data hudson.Clean_20121106;
set clean_test;
run;
