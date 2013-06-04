filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Data\mario.tab';
libname virtual 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled';
libname Data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname wip 'C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files';

libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
options fmtsearch=(SAS);

data Data.Demog_201111;
length HHID $ 9 ;
infile mydata DLM='09'x firstobs=2 lrecl=4096 dsd;
	  INPUT hhID $ own_age d_age income home_owwer $ children $ education $ ocupation $ age2  ;
run;

filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Data\mario2.tab';

data extra;
length HHID $ 9 flag_under_10 $ 1 flag_11_15 $ 1 flag_16_17 $ 1;
infile mydata DLM='09'x firstobs=2 lrecl=4096  dsd;
	  INPUT hhID $  flag_under_10 $ flag_11_15 $  flag_16_17 $ ;
run;


filename mydata 'C:\Documents and Settings\ewnym5s\My Documents\Data\stts.txt';

data extra;
length HHID $ 9 married $ 1;
infile mydata DLM='09'x firstobs=2 lrecl=4096   dsd;
	  INPUT hhID $ married $  ;
	  if hhid eq '' then delete;
run;



proc sort data=extra;
by hhid;
run;


data merged;
merge data.demog_201111 (in=a) extra (in=b);
by hhid;
if a;
run;


proc contents data=wip.temp_demog short varnum;
run;

proc freq data=merged ;
table married: / missing;
run;

data data.demog_201111;
set merged (rename=(home_owwer=home_owner));
run;

/*###########################################################################*/






proc format library=sas;
   value ageband 
   			low-0= 'Invalid'
            1-17 = 'Under 18'
			18-25 = '18 to 25'
			26-35 = '26 to 35'
			36-45 = '36 to 45'
			46-55 = '46 to 55'
			56-65 = '56 to 65'
			66-70 = '66 to 70'
			71-75 = '71 to 75'
			76-80 = '76 to 80'
			81-85 = '81 to 85'
			86-90 = '86 to 90'
			91-high = '91+';

	value $ocupfmt
		 '1' = 'Prof Tech'
		 '2' = 'Admin Mgr'
		 '3' = 'Sales Svc'
		 '4' = 'Clercl Wh Cllr'
		 '5' = 'Crafts Bl Cllr'
		 '6' = 'Stdnt'
		 '7' = 'Home Maker'
		 '8' = 'Retrd'
		 '9' = 'Farmer'
		 'A' = 'Military'
		 'B' = 'Relig'
		 'C'-'L' = 'Self Empl'
		 'V' = 'Education'
		 'W' = 'Finance'
		 'X' = 'Legal'
		 'Y' = 'Medical'
		 'Z' = 'Other'
		 '' = 'Uncoded';

     value $educfmt
		 '1' = 'HIGH SCHOOL'
		 '2' = 'COLLEGE'
		 '3' = 'GRADUATE SCHOOL'
		 '4' = 'VOCATIONAL/TECHNICAL'
		 '' = 'Uncoded';

		 value incmfmt
		 1 = '<$15M'
		 2 = '$15M-20M'
		 3 = '$20M-30M'
		 4 = '$30M-40M'
		 5 = '$40M-50M'
		 6 = '$50M-75M'
		 7 = '$75M-100M'
		 8 = '$100M-125M'
		 9 = '$125M+'
		 . = 'Uncoded';

value $homeowner
		'O' = 'Owner'
		'R' = 'Renter'
		'' = 'Uncoded';

value $marital
		'M', 'A' = 'Married'
		'S', 'B' = 'Single'
		'' = 'Uncoded';


run;

proc format library=sas fmtlib;

run;


data wip.temp_demog;
merge data.demog_201111 (in=a) data.main_201111 (in=b keep= hhid hh segment cbr market virtual_seg tran_segm distance band where=(virtual_seg ne ''));
by hhid;
if a and b;
run;
		     
proc tabulate data=wip.temp_demog out=wip.own_age1(drop=_PAGE_ _type_ _TABLE_);
class virtual_seg own_age;
var    hh;
table virtual_seg,( own_age*HH )*(N ROWPCTSUM);
format own_age ageband.;
run;

proc tabulate data=wip.temp_demog out=wip.age_prime1(drop=_PAGE_ _type_ _TABLE_);
class virtual_seg age_prime ;
var    hh;
table virtual_seg,( age_prime*HH )*(N ROWPCTSUM);
format age_prime ageband.;
run;

proc tabulate data=wip.temp_demog out=wip.age_hoh1(drop=_PAGE_ _type_ _TABLE_);
class virtual_seg age_hoh ;
var    hh;
table virtual_seg,( age_hoh*HH )*(N ROWPCTSUM);
format age_hoh ageband.;
run;

proc tabulate data=wip.temp_demog out=wip.income1(drop=_PAGE_ _type_ _TABLE_);
class virtual_seg income  ;
var    hh;
table virtual_seg,( income *HH )*(N ROWPCTSUM);
run;

proc tabulate data=wip.temp_demog out=wip.home1(drop=_PAGE_ _type_ _TABLE_);
class virtual_seg  home_owner  ;
var    hh;
table virtual_seg,(  home_owner *HH )*(N ROWPCTSUM);
run;



proc tabulate data=wip.temp_demog out=wip.educ1(drop=_PAGE_ _type_ _TABLE_);
class virtual_seg education  ;
var    hh;
table virtual_seg,( education *HH )*(N ROWPCTSUM);
run;

proc tabulate data=wip.temp_demog out=wip.ocup1(drop=_PAGE_ _type_ _TABLE_);
class virtual_seg ocupation  ;
var    hh;
table virtual_seg,( ocupation *HH )*(N ROWPCTSUM);
run;


proc tabulate data=wip.temp_demog out=wip.married (drop=_PAGE_ _type_ _TABLE_);
class virtual_seg married  ;
var    hh;
table virtual_seg,( married *HH )*(N ROWPCTSUM);
/*format married $marital.;*/
run;

/*children*/
proc tabulate data=wip.temp_demog out=wip.child1a(drop=_PAGE_ _type_ _TABLE_)  ;
class virtual_seg children FLAG_UNDER_10 flag_11_15 flag_16_17;
var    hh;
table  virtual_seg, (children ),(FLAG_UNDER_10 );

run;

proc sort data=wip.child1a;
by children virtual_seg;
run;


proc transpose data=wip.child1a out = wip.child2a label=under10;
by children virtual_seg;
ID flag_under_10;
run;

data wip.child3a;
set wip.child2a (rename=(Y=under10_Y N=under10_N));
drop _NAME_;
run;



proc tabulate data=wip.temp_demog out=wip.child4a(drop=_PAGE_ _type_ _TABLE_)  ;
class virtual_seg children FLAG_UNDER_10 flag_11_15 flag_16_17;
var    hh;
table  virtual_seg, (children ),(flag_11_15 );
run;

proc sort data=wip.child4a;
by children virtual_seg;
run;

proc transpose data=wip.child4a out = wip.child5a label=under10;
by children virtual_seg;
ID flag_11_15;
run;

data wip.child6a;
set wip.child5a (rename=(Y=_11_15_Y N=_11_15_N));
drop _NAME_;
run;

proc tabulate data=wip.temp_demog out=wip.child7a(drop=_PAGE_ _type_ _TABLE_)  ;
class virtual_seg children FLAG_UNDER_10 flag_11_15 flag_16_17;
var    hh;
table  virtual_seg, (children ),(flag_16_17 );
run;

proc sort data=wip.child7a;
by children virtual_seg;
run;

proc transpose data=wip.child7a out = wip.child8a label=under10;
by children virtual_seg;
ID flag_16_17;
run;

data wip.child9a;
set wip.child8a (rename=(Y=_16_17_Y N=_16_17_N));
drop _NAME_;
run;

proc tabulate data=wip.temp_demog out=wip.childa(drop=_PAGE_ _type_ _TABLE_)  ;
class virtual_seg children FLAG_UNDER_10 flag_11_15 flag_16_17;
var    hh;
table  virtual_seg, (children *HH);
run;

proc sort data=wip.childa;
by children virtual_seg;
run;

proc sort data=wip.child3a;
by children virtual_seg;
run;

proc sort data=wip.child6a;
by children virtual_seg;
run;

proc sort data=wip.child9a;
by children virtual_seg;
run;

data wip.child10a;
merge wip.childa (in=a) wip.child3a wip.child6a wip.child9a;
by children virtual_seg;
run;

data wip.child11a;
set wip.child10a;
length segment $ 20 grp $ 8;
array data{7} HH_sum under10_y under10_n _11_15_y _11_15_n _16_17_y _16_17_n;
array Y{8,7} _temporary_;
array N{8,7} _temporary_;

select (virtual_seg);
	when ("ATM Dominant") j=1;
	when ("Branch Dominant") j=2;
	when ("Inac") j=3;
	when ("Multi - High Branch") j=4;
	when ("Multi - Low Branch") j=5;
	when ("Multi - Med Branch") j=6;
	when ("Online Dominant") j=7;
	when ("Phone Dominant") j=8;
end;

if children='N' then do;
	do i = 1 to 7 ;
		N{j,i} = data{i};
	end;
	return;
end;
else if children='Y' then do;
		do i = 1 to 7 ;
			Y{j,i} = data{i};
		end;
    if j ne 8 then do; /*this should stop at the last record allowing me to output the data I really want*/
		return;
	end;
end;

do k=1 to 8;

	select (k);
		when (1) segment = "ATM Dominant" ;
		when (2) segment ="Branch Dominant";
		when (3) segment ="Inac";
		when (4) segment ="Multi - High Branch";
		when (5) segment = "Multi - Low Branch";
		when (6) segment = "Multi - Med Branch";
		when (7) segment = "Online Dominant";
		when (8) segment = "Phone Dominant";
	end;

	Grp = 'All';
	val = 'Y';
	HH = Y{k,1};
	PCT = Y{k,1}/ (Y{k,1}+ N{k, 1});
	output;
	val = 'N';
	HH = N{k, 1};
	PCT = n{k,1}/ (Y{k,1}+ N{k, 1});
	output;

	Grp = 'Under 10';
	val = 'Y';
	HH = sum(Y{k,2},N{k,2});
	PCT = Y{k,2}/ (Y{k,1}+ N{k, 1});
	output;
	val = 'N';
	HH = sum(Y{k,3},N{k,3});
	PCT = n{k,3}/ (Y{k,1}+ N{k, 1});
	output;

	Grp = '11 to 15';
	val = 'Y';
	HH = sum(Y{k,4},N{k,4});
	PCT = Y{k,4}/ (Y{k,1}+ N{k, 1});
	output;
	val = 'N';
	HH = sum(Y{k,5},N{k,5});
	PCT = n{k,5}/ (Y{k,1}+ N{k, 1});
	output;

	Grp = '16 to 17';
	val = 'Y';
	HH = sum(Y{k,6},N{k,6});
	PCT = Y{k,6}/ (Y{k,1}+ N{k, 1});
	output;
	val = 'N';
	HH = sum(Y{k,7},N{k,7});
	PCT = n{k,7}/ (Y{k,1}+ N{k, 1});
	output;
end;

drop i children hh_sum under10_n under10_y _11_15_n _11_15_y _16_17_y _16_17_n virtual_Seg j k;
run;

options orientation=landscape;
ods html close;
ods pdf file = 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\demog_Charts_detail.pdf';

/* charts*/
Title2 'Education level';
axis1 minor=none major=none label=(a=90 f="Arial/Bold" "% of HHs in Group") value=none;
axis2 split="" value=(h=9pt) label=none  color=black label=NONE value=none;
axis3 split=" " value=(h=7pt)  color=black label=NONE ;
legend2 position=(outside bottom center) mode=reserve cborder=black shape=bar(.15in,.15in) label=("Transaction Segment" position=(top center));
%vbar_stacked (analysis_var=HH_N,group_var=virtual_seg,class_var=education,table=educ1,title_str=,value_format=,group_format=$educfmt.,
midpts='HIGH SCHOOL' 'VOCATIONAL/TECHNICAL' 'COLLEGE' 'GRADUATE SCHOOL');


Title2 'Ocupation';
axis1 minor=none major=none label=(a=90 f="Arial/Bold" "% of HHs in Group") value=none;
axis2 split="" value=(h=9pt) label=none  color=black label=NONE value=none;
axis3 split=" " value=(h=7pt)  color=black label=NONE ;
legend2 position=(outside bottom center) mode=reserve cborder=black shape=bar(.15in,.15in) label=("Transaction Segment" position=(top center));
%vbar_stacked (analysis_var=HH_N,group_var=virtual_seg,class_var=ocupation,table=ocup1,title_str=,value_format=,group_format=$ocupfmt.,
midpts='Prof Tech' 'Admin Mgr' 'Sales Svc' 'Clercl Wh Cllr' 'Crafts Bl Cllr' 'Stdnt' 'Home''Retrd' 'Farmer' 'Military' 'Relig' 'Self Empl' 
'Education' 'Finance' 'Legal' 'Medical' 'Other' 'Uncoded');

Title2 'Income';
axis1 minor=none major=none label=(a=90 f="Arial/Bold" "% of HHs in Group") value=none;
axis2 split="" value=(h=9pt) label=none  color=black label=NONE value=none;
axis3 split=" " value=(h=7pt)  color=black label=NONE ;
legend2 position=(outside bottom center) mode=reserve cborder=black shape=bar(.15in,.15in) label=("Transaction Segment" position=(top center));
%vbar_stacked (analysis_var=HH_N,group_var=virtual_seg,class_var=income,table=income1,title_str=,value_format=,group_format=incmfmt.,
midpts='<$15M' '$15M-20M' '$20M-30M'  '$30M-40M' '$40M-50M' '$50M-75M' '$75M-100M' '$100M-125M'  '$125M+' 'Uncoded');

Title2 'Best HH Age Estimate';
axis1 minor=none major=none label=(a=90 f="Arial/Bold" "% of HHs in Group") value=none;
axis2 split="" value=(h=9pt) label=none  color=black label=NONE value=none;
axis3 split=" " value=(h=7pt)  color=black label=NONE ;
legend2 position=(outside bottom center) mode=reserve cborder=black shape=bar(.15in,.15in) label=("Transaction Segment" position=(top center));
%vbar_stacked (analysis_var=HH_N,group_var=virtual_seg,class_var=own_age,table=own_age1,title_str=,value_format=,group_format=ageband.,
midpts='Invalid' 'Under 18'  '18 to 25' '26 to 35' '36 to 45' '46 to 55'  '56 to 65'  '66 to 70' '71 to 75'  '76 to 80'  '81 to 85'  '86 to 90'  '91+');

Title2 'Prime Account Age Estimate';
axis1 minor=none major=none label=(a=90 f="Arial/Bold" "% of HHs in Group") value=none;
axis2 split="" value=(h=9pt) label=none  color=black label=NONE value=none;
axis3 split=" " value=(h=7pt)  color=black label=NONE ;
legend2 position=(outside bottom center) mode=reserve cborder=black shape=bar(.15in,.15in) label=("Transaction Segment" position=(top center));
%vbar_stacked (analysis_var=HH_N,group_var=virtual_seg,class_var=age_prime,table=age_prime1,title_str=,value_format=,group_format=ageband.,
midpts='Invalid' 'Under 18'  '18 to 25' '26 to 35' '36 to 45' '46 to 55'  '56 to 65'  '66 to 70' '71 to 75'  '76 to 80'  '81 to 85'  '86 to 90'  '91+');

Title2 'Head of HHAge Estimate';
axis1 minor=none major=none label=(a=90 f="Arial/Bold" "% of HHs in Group") value=none;
axis2 split="" value=(h=9pt) label=none  color=black label=NONE value=none;
axis3 split=" " value=(h=7pt)  color=black label=NONE ;
legend2 position=(outside bottom center) mode=reserve cborder=black shape=bar(.15in,.15in) label=("Transaction Segment" position=(top center));
%vbar_stacked (analysis_var=HH_N,group_var=virtual_seg,class_var=age_hoh,table=age_hoh1,title_str=,value_format=,group_format=ageband.,
midpts='Invalid' 'Under 18'  '18 to 25' '26 to 35' '36 to 45' '46 to 55'  '56 to 65'  '66 to 70' '71 to 75'  '76 to 80'  '81 to 85'  '86 to 90'  '91+');

Title2 'Homeownership';
axis1 minor=none major=none label=(a=90 f="Arial/Bold" "% of HHs in Group") value=none;
axis2 split="" value=(h=9pt) label=none  color=black label=NONE value=none;
axis3 split=" " value=(h=7pt)  color=black label=NONE ;
legend2 position=(outside bottom center) mode=reserve cborder=black shape=bar(.15in,.15in) label=("Transaction Segment" position=(top center));
%vbar_stacked (analysis_var=HH_N,group_var=virtual_seg,class_var=home_owner,table=home1,title_str=,value_format=,group_format=$homeowner.,
midpts='Owner' 'Renter');

Title2 'Marital Status';
axis1 minor=none major=none label=(a=90 f="Arial/Bold" "% of HHs in Group") value=none;
axis2 split="" value=(h=9pt) label=none  color=black label=NONE value=none;
axis3 split=" " value=(h=7pt)  color=black label=NONE ;
legend2 position=(outside bottom center) mode=reserve cborder=black shape=bar(.15in,.15in) label=("Transaction Segment" position=(top center));
%vbar_stacked (analysis_var=HH_N,group_var=virtual_seg,class_var=married,table=married,title_str=,value_format=,group_format= $marital.,
midpts='Married' 'Single');

DATA wip.child12a;
set wip.child11a;
where val = "Y";
drop val;
run;



Title2 'Presence of Children';
axis1 minor=none  label=(a=90 f="Arial/Bold" "% of HHs With Children");
axis2 split=" " value=(h=7pt) label=none  color=black  value=none ;
axis3 split=" " value=(h=9pt font="Albany AMT/bold")  color=black label=NONE 
order=('Branch Dominant'  'Multi - High Branch'  'Multi - Med Branch'  'Multi - Low Branch'  'ATM Dominant'  'Phone Dominant'  'Online Dominant'  'Inac');
legend2 position=(outside bottom center) mode=reserve cborder=black shape=bar(.15in ,.15in) label=("Children Present" position=(top center)) 
order=('All'  'Under 10'  '11 to 15'  '16 to 17');



proc gchart data=wip.child12a ;
vbar grp /  type=sum  sumvar=PCT
noframe outside=sum   subgroup=grp group=segment
gspace = 1 width=10
raxis = axis1 maxis=axis2 gaxis=axis3 
midpoints = 'All' 'Under 10' '11 to 15' '16 to 17'
autoref clipref cref=graybb
legend=legend2;
format  PCT PERCEnT6.1;
run;




quit;
ods pdf close;
ods html;

proc freq  data=wip.temp_demog;
table children;
where children eq 'Y' and flag_under_10 eq 'N' and flag_11_15 eq 'N' and flag_16_17 eq 'N';
run;
