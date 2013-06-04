proc format;
value hudsonseg (notsorted)
   1 = 'Building Their Future'
2 = 'Mainstream Families'
4 = 'Mass Affluent Families'
3 = 'Mainstream Retired'
5 = 'Mass Affluent Retired'
6, .  = 'Unable to Code';
run;

proc format;
value  prods (notsorted )
	      1 = 'Single'
		2-high = 'Multi';

value $ state 'CT' = 'CT'
              'NY' = 'NY'
			  'NJ' = 'NJ'
			other = 'Other';
run;


proc tabulate data=hudson.hudson_hh missing order=data;
/*where state = "NJ";*/
class  products  state products abbas_grp;
class segment / preloadfmt;
class distance / preloadfmt;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 mtx1 hh  dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt mtx_amt;
table  segment, N='HHs'*f=comma12. (dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' mtx1='Non Svcd Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*rowpctsum<hh>*f=pctfmt. /nocellmerge misstext='0.0%';
table segment, N='HHs'*f=comma12. (dda_amt='Checking'*rowpctsum<dda1> mms_amt='Money Market'*rowpctsum<mms1> sav_amt='Savings'*rowpctsum<sav1> tda_amt='Time Deposits'*rowpctsum<tda1> 
					  ira_amt='IRAs'*rowpctsum<ira1> mtg_amt='Mortgage'*rowpctsum<mtg1> mtx_amt='Non Svcd Mortgage'*rowpctsum<mtx1> heq_amt='Home Equity'*rowpctsum<heq1> iln_amt='Inst. Loan'*rowpctsum<iln1> 
                      ccs_amt='Overdraft'*rowpctsum<ccs1>)*f=pctdollm./nocellmerge misstext='$0.0';
table segment, distance*rowpctN*f=pctfmt. / nocellmerge misstext='0.0%';
keylabel sum='Total' rowpctsum='';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. distance distfmt.;
run;

*MATRIX ANALYSIS;

%macro dummy();
	data temp_&group;
	set &source;
	%do k = 1 %to &nvars;
		%scan(&vars2,&k,' ') = %scan(&vars,&k,' ');
	%end;
	run;
%mend dummy;

%let group=Hudson;
%let source=hudson.hudson_hh;
%let vars= dda1 mms1 sav1 tda1 ira1 mtg1 mtx1 heq1 iln1 ccs1;
%let vars2 = dda2 mms2 sav2 tda2 ira2 mtg2 mtx2 heq2 iln2 ccs2;
%let filter = con1 eq 1 ;
%let nvars=10;
%let names="Checking","Money Market","Savings","Time Deposits","IRA","Svcd Mortgage","Non-Svcd Mortgage","Home Equity","Inst. Loan","Overdraft";

%dummy() 

proc tabulate data=temp_&group  missing out=&group._cross order=data;
where &filter;
CLASS  &vars &vars2;
class segment / preloadfmt;
table segment, (&vars ),(&vars2)*rowpctn / nocellmerge;
format segment hudsonseg.;
run;

*2) have to clean the lines that have the crosses for the zeros, you only want rows with 1 or 2 1's, no zeros;
data &group._cross1;
set &group._cross;
array flags{&nvars} &vars;
array flags2{&nvars} &vars2;
group= "&group";
keep = 1;
do i = 1 to &nvars;
   if flags{i} eq 0 then keep=0;
   if flags2{i} eq 0 then keep = 0;
end;
percent = sum(of PCTN:);
if keep eq 1 then output;
drop _type_ _page_ _table_ i keep pctn:;
run; 

*3) define y and x variables that will define the rows (Y dimension) and columns (x dimension) for the matrix;
* y is the first 1 in the matrix, x is the second one if found, if not it is =y;
data &group._cross2;
length x $ 20 y $ 20 group $ 15;
set &group._cross1;
array names{&nvars} $ 20 _temporary_ (&names);
array flags{&nvars} &vars;
array flags2{&nvars} &vars2;

y=""; x="";
do i = 1 to &nvars;
   if flags{i} eq 1 and y eq "" then do; *we found the y one;
   		y=names{i};
   end;
   if flags2{i} eq 1 and x eq "" then do; *we found the x one;
   		x=names{i};
   end;
end;
percent = divide(percent,100);
drop i;
run;

proc format;
value $ productx (notsorted)
      'Checking' = 'Checking'
	'Money Market' = 'Money Market'
	'Savings' = 'Savings'
	'Time Deposits'= 'Time Deposits'
	'IRA'= 'IRA'
	'Svcd Mortgage'= 'Svcd Mortgage'
	'Non-Svcd Mortgage'= 'Non Svcd Mortgage'
	'Home Equity'= 'Home Equity'
	'Inst. Loan'= 'Inst. Loan'
	 'Overdraft'= 'Overdraft';
run;

proc format;
value $ groups (notsorted)
	'Hudson' = 'Hudson'
	'WNY' = 'WNY'
	'Balt' = 'Balt'
	'Wash' = 'Wash';
run;

proc tabulate data=&group._cross2 order=data;
class y x / preloadfmt;
class group / preloadfmt;
var percent;
table group, y,x*sum*percent*f=percent8.1;
format x y $productx. group $groups.;
run;

data extra;
length x $ 20 y $ 20 ;
array flags{&nvars} &vars;
array flags2{&nvars} &vars2;
array names{&nvars} $ 20 _temporary_ (&names);
y=""; x="";
do i = 1 to 6;
   segment=i;
   percent=0;
   y=names{7};
   x=names{8};
   output;
   percent=0;
   y=names{7};
   x=names{10};
   output;
   percent=0;
   y=names{8};
   x=names{7};
   output;
   percent=0;
   y=names{10};
   x=names{7};
   output;
end;
keep x y segment percent;
run;


data combined;
set hudson_cross2 extra;
keep x y  percent segment;
run;

data combined;
length segment_name $ 22;
set combined;
segment_name = put(segment,hudsonseg.);
run;

proc tabulate data=combined;
class y x;
var percent;
table y,x*sum*percent*f=percent6.0;
run;


proc tabulate data=hudson.hudson_hh (keep =  products dda: mms: tda: sav: mtg: heq: iln: ccs: ira: ccs: mtx1 segment) 
                missing out=prods_hudson order=data;
WHERE PRODUCTS GE 1;
var products;
class segment / preloadfmt;
class dda1 mms1 tda1 sav1 ira1  iln1  heq1  mtg1  ccs1 mtx1;
table (dda1 mms1 tda1 sav1 ira1  iln1  heq1  mtg1 mtx1 ccs1)*segment*(N sum*products);
format segment hudsonseg.;
run;

data prods_hudson;
set prods_hudson;
where sum(dda1,mms1,tda1,sav1,ira1, iln1, heq1, mtg1, ccs1, mtx1) eq 1;
prods = products_sum/ N;
drop _type_ _page_ _table_;
run;

data prods_hudson;
set prods_hudson;
if dda1 eq 1 then num =1;
if mms1 eq 1 then num =2;
if sav1 eq 1 then num =3;
if tda1 eq 1 then num =4;
if ira1 eq 1 then num =5;
if mtg1 eq 1 then num =6;
if mtx1 eq 1 then num=7;
if heq1 eq 1 then num =8;
if iln1 eq 1 then num =9;
if ccs1 eq 1 then num =10;
run;

data prods_hudson;
set prods_hudson;
cbr = 0;
keep num prods N cbr segment;
run;


proc sort data=prods_hudson;
by segment num;
run;

data prods_hudson;
length segment_name $ 22;
set prods_hudson;
segment_name = put(segment,hudsonseg.);
run;


proc tabulate data=prods_hudson;
class num segment_name;
var prods;
table num,segment_name*sum*prods*f=comma8.1;
run;

options mcompilenote=all;
%macro create_panel_charts1 (xsize=,ysize=, file=, group1=,  order1=, prodfile=);

%put _user_;
proc sql;
select min((ceil(max(percent)*10)/10)+ 0.2,1.2) into :max1 from &file;
quit;


proc catalog c=work.gseg kill; 
run; quit; 

ods html style=MTB;
goptions reset=all cback=white noborder htitle=14pt htext=10pt;  
goptions device=gif nodisplay xpixels=&xsize ypixels=&ysize;

%do i = 1 %to 10;
	%if &i eq 1 %then %let yname=Checking;
	%if &i eq 2 %then %let yname=Money Market;
	%if &i eq 3 %then %let yname=Savings;
	%if &i eq 4 %then %let yname=Time Deposits;
	%if &i eq 5 %then %let yname=IRA;
	%if &i eq 6 %then %let yname=Svcd Mortgage;
	%if &i eq 7 %then %let yname=Non-Svcd Mortgage;
	%if &i eq 8 %then %let yname=Home Equity;
	%if &i eq 9 %then %let yname=Inst. Loan;
	%if &i eq 10 %then %let yname=Overdraft;
	%do j = 1 %to 10;
		%if &j eq 1 %then %let xname=Checking;
		%if &j eq 2 %then %let xname=Money Market;
		%if &j eq 3 %then %let xname=Savings;
		%if &j eq 4 %then %let xname=Time Deposits;
		%if &j eq 5 %then %let xname=IRA;
		%if &j eq 6 %then %let xname=Svcd Mortgage;
		%if &j eq 7 %then %let xname=Non-Svcd Mortgage;
		%if &j eq 8 %then %let xname=Home Equity;
		%if &j eq 9 %then %let xname=Inst. Loan;
		%if &j eq 10 %then %let xname=Overdraft;

		%if &i eq 1 %then %do;
			title1 "&xname";
		%end;
		%if &i ne 1 %then %do;
			title1 ;
		%end;
		%if &j eq 1 %then %do;
			axis1 label=(angle=90 f="Arial / bo" justify=center color=black height=14pt "&yname")  minor=none major=none color=white value=none order=(0 to &max1 by 0.1); 
		%end;
		%if &j ne 1 %then %do;
			axis1 label=(angle=90 f="Arial / bo" justify=center color=white height=14pt "&yname")  minor=none major=none color=white value=none order=(0 to &max1 by 0.1); 
		%end;
		axis2 label=none  minor=none major=none value=none order=(&order1);
		
	
		proc gchart data=&file(where=(y="&yname" and x="&xname")) gout=work.gseg;
		vbar &group1 / sumvar=percent subgroup=&group1 missing discrete raxis=axis1 width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
		format percent percent8.0 ;
		run;
		quit;
	%end;
	 title1 ;
      %if &i eq 1 %then %do;
		title1 'Avg. Products';
	%end;

	 axis1 label=(angle=90 f="Arial / bo" justify=center color=white height=14pt "&yname")  minor=none major=none color=white value=none order=(0 to 5 by 0.5); 
	  axis2 label=none  minor=none major=none value=none order=(&order1);
	   proc gchart data=&prodfile(where=(num=&i)) gout=work.gseg;
		vbar &group1 / sumvar=prods subgroup=&group1 discrete raxis=axis1 missing width=25 maxis=axis2 gaxis=axis2 outside=sum nolegend noframe;
		format prods comma5.1 ;
		run;
		quit;
%end;



%mend create_panel_charts1;

filename mprint "C:\Documents and Settings\ewnym5s\My Documents\Hudson City\charts.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic ;
%create_panel_charts1 (xsize=300, ysize=200, file=combined, group1=segment_name ,
                         order1 = "Building Their Future" "Mainstream Families" "Mass Affluent Families" "Mainstream Retired" 
                                  "Mass Affluent Retired" "Unable to Code",prodfile=prods_hudson)



%custom_panel(x=11,y=10,fileout=C:\Documents and Settings\ewnym5s\My Documents\Hudson City\panelchart.gif,x_size=3300,y_size=2000)

