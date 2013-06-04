data temp_merged_all;
merge virtual.points_2009 (in=a keep= hhid segment) virtual.points_201204 (in=b keep=hhid segment rename=(segment=segment_new));
by hhid;
run;

/*data temp_merged;*/
/*merge virtual.points_2009 (in=a keep= hhid segment) virtual.points_201204 (in=b keep=hhid segment rename=(segment=segment_new));*/
/*by hhid;*/
/*if a and b;*/
/*run;*/

/*proc freq data=temp_merged;*/
/*table segment*segment_new / missing nocol norow nopercent;*/
/*run;*/


*read additional data for 2009 to 2012 analysis - one time only;

/*filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\mat_2009.txt';*/
/**/
/*data virtual.extra_2009;*/
/*length hhid $ 9 ;*/
/*infile myfile dlm='09'x dsd firstobs=2 ;*/
/*input hhid $ contrib age oldest:mmddyy10. life_segm svcs;*/
/*run;*/


/*filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\mat_2012.txt';*/
/**/
/*data virtual.extra_2012;*/
/*length hhid $ 9 ;*/
/*infile myfile dlm='09'x dsd firstobs=2 ;*/
/*input hhid $ contrib age oldest:mmddyy10. life_segm svcs;*/
/*run;*/


/*data virtual.extra_2009;*/
/*set virtual.extra_2009;*/
/*flag_2009 = 1;*/
/*run;*/

/*data virtual.extra_2012;*/
/*set virtual.extra_2012;*/
/*flag_2012 = 1;*/
/*run;*/

* create a super dataset that mixes the segments with the extr data;

data matrix_data;
merge temp_merged_all (in=a) virtual.extra_2009 (in=b) 
      virtual.extra_2012 (in=c rename=(contrib=contrib_12 age=age_12 oldest=oldest_12 life_segm = life_Segm_12 svcs = svcs_12));
by hhid;
run;



data matrix_data;
set matrix_data;
if dda_2012 eq . then dda_2012 = 0;
if dda_2009 eq . then dda_2009 = 0;
run;

data matrix_data;
merge matrix_data (in=a) virtual.hhs_200912 (in=b) virtual.hhs_201204 (in=c);
by hhid;
if a;
run;

data matrix_data;
set matrix_data;
if flag_2009_new eq . then flag_2009_new = 0;
if flag_2012_new eq . then flag_2012_new = 0;
run;

data matrix_data1;
set matrix_data;
if (flag_2009_new eq 1 and dda_2009 eq 0 and segment eq '')  then SEGMENT = 'No Checking';
if (flag_2009_new eq 1 and dda_2009 eq 1 and segment eq '')  then SEGMENT = 'Chk not class';
if (flag_2009_new eq 0 and segment eq '' ) then SEGMENT = 'Not Present';
if (flag_2012_new eq 1 and dda_2012 eq 0 and segment_new eq '')  then SEGMENT_new = 'No Checking';
if (flag_2012_new eq 1 and dda_2012 eq 1 and segment_new eq '')  then SEGMENT_new = 'Chk not class';
if (flag_2012_new eq 0 and segment_new eq '')  then SEGMENT_new = 'Not Present';
run;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\201204 Segments.txt';
data _null_;
set matrix_data1;
file myfile dsd dlm=',';
put hhid segment_new;
run;


proc freq data=matrix_data1;
table segment*segment_new / missing norow nocol nopercent;
run;

proc tabulate data=matrix_data1 out=matrix_results;
class segment segment_new life_segm;
var contrib age svcs contrib_12 age_12 svcs_12 flag_2009_new flag_2012_new;
tables segment*segment_new*(life_segm ALL),(flag_2009_new flag_2012_new)*sum (contrib contrib_12)*mean*f=dollar12.2 (age age_12 svcs svcs_12)*mean*f=comma12.1 /  nocellmerge;
format life_segm segfmt.;
run;

proc freq data=matrix_data1;
table segment / norow nocol nopercent out=SEGMENTS (drop = count percent);
run;

proc freq data=matrix_data1;
table segment_new / norow nocol nopercent out=SEGMENT_new (drop = count percent);
run;

/*data total;*/
/*input segment : $20.;*/
/*datalines;*/
/*Total*/
/*;*/
/*run;*/
/**/
/*data segments;*/
/*set segments total ;*/
/*run;*/
/**/
/*data SEGMENT_new;*/
/*set SEGMENT_new total (rename=(segment=segment_new));*/
/*run;*/

proc sql;
create table matrix_class as 
select * from segments, segment_new;
quit;

*THIS IS THE TABULATE FOR THE MATRIX IN EXCEL;
proc tabulate data=matrix_data1 out=wip.matrix_results_summary (drop=_PAGE_ _TYPE_ _TABLE_) classdata=matrix_class MISSING;
class segment segment_new ;
var contrib age svcs contrib_12 age_12 svcs_12 flag_2009_new flag_2012_new;
tables (segment ALL)*(segment_new ALL) ALL, N (flag_2009_new flag_2012_new)*sum (contrib contrib_12)*mean*f=dollar12.2 (age age_12 svcs svcs_12)*mean*f=comma12.1 /  nocellmerge;
/*format life_segm segfmt.;*/
run;

proc tabulate data=matrix_data1 out=TOTAL (drop=_PAGE_ _TYPE_ _TABLE_) classdata=matrix_class MISSING;
class segment segment_new ;
var contrib age svcs contrib_12 age_12 svcs_12 flag_2009_new flag_2012_new;
tables ALL, N (flag_2009_new flag_2012_new)*sum (contrib contrib_12)*mean*f=dollar12.2 (age age_12 svcs svcs_12)*mean*f=comma12.1 /  nocellmerge;
/*format life_segm segfmt.;*/
run;

data wip.matrix_results_summary;
set wip.matrix_results_summary;
if segment eq '' then segment = 'Total';
if segment_new eq '' then segment_new = 'Total';
run;


ods html;




/**/
/*data _NULL_;*/
/*do i = 1 to 9;*/
/*	do j = 2 to 9;*/
/*		a = (i-1)*9 +j;*/
/*		b = put(a,$3.);*/
/*		d = trim(b);*/
/*		put i j a ;*/
/*		call symput(cats('n',b),cats('_c',left(b),"_"));*/
/*		;*/
/*	end;*/
/*end;*/
/*run;*/



proc sort data=wip.matrix_results_summary;
by  segment_new segment;
run;

proc contents data=wip.matrix_results_summary varnum short; run;


data wip.matrix_results_summary;
set wip.matrix_results_summary;
if flag_2009_Sum eq . then flag_2009_Sum = 0;
if flag_2012_Sum eq . then flag_2012_Sum = 0;
if contrib_Mean eq . then contrib_Mean = 0;
if contrib_12_Mean eq . then contrib_12_Mean =0;
if age_Mean eq . then age_Mean = 0;
if age_12_Mean eq . then age_12_Mean = 0;
if svcs_Mean eq . then svcs_Mean = 0;
if svcs_12_Mean eq . then svcs_12_Mean = 0;
run;

data wip.matrix_results_summary;
set wip.matrix_results_summary;
where segment ne 'Total' and segment_new ne 'Total';
run;

data wip.matrix_results_summary;
set wip.matrix_results_summary;
if segment eq '' then segment = 'Total';
if segment_new eq '' then segment_new = 'Total';
N1 = max(flag_2009_sum , flag_2012_sum);
age = max(age_mean, age_12_mean);
run;

proc sort data=wip.matrix_results_summary;
by   segment_new segment ;
run;

ods escapechar="^";
proc report data=wip.matrix_results_summary nowd split='\' ; 
column Segment segment_new,(N1 contrib_mean contrib_12_mean svcs_mean svcs_12_mean age block);
define segment / group ; 
define segment_new / across ; 
define N1 / analysis noprint ; 
define contrib_mean / analysis noprint; 
define contrib_12_mean / analysis noprint; 
define  svcs_mean / analysis noprint;
define  svcs_12_mean / analysis noprint;
define  age / analysis noprint;
define block / computed width=25 ''; 
compute block / char length=250;
   array cols{18}   _c2_	_c3_	_c4_	_c5_ _c6_ _c7_	
					_c9_	_c10_	_c11_ _c12_	_c13_	_c14_	
					_c16_ _c17_ _c18_	_c19_	_c20_	_c21_	; *
					_c29_	_c30_	_c31_	_c32_	_c33_	_c34_	_c35_   _C36_
					_c38_	_c39_	_c40_	_c41_	_c42_	_c43_	_c44_   _C45_
					_c47_	_c48_	_c49_	_c50_	_c51_	_c52_	_c53_   _C54_
					_c56_	_c57_	_c58_	_c59_	_c60_	_c61_	_c62_   _C63_
					_c65_	_c66_	_c67_	_c68_	_c69_	_c70_	_c71_   _c72_
					_c74_	_c75_	_c76_	_c77_	_c78_	_c79_	_c80_   _C81_
					_c83_	_c84_	_c85_	_c86_	_c87_	_c88_	_c89_   _C90_
					_c92_	_c93_	_c94_	_c95_	_c96_	_c97_	_c98_   _C99_
					_c101_	_c102_	_c103_	_c104_	_c105_	_c106_	_c107_  _c108_; 
   array blocks(3)     _c8_  _c15_  _c22_ ;* _c37_  _c46_  _c55_  _c64_  _c73_  _82_  _c91_  _c100_  _c109_;
   do i = 1 to 1;
   		aux=i-1;
          blocks{i} = 'N= ' || put(cols{(i-1)*7 +2+aux} ,comma12.0) || '^n' || 'Contrib (2009) = ' || 
	       put( cols{(i-1)*7 +3+aux}, dollar12.2) || '^n' || 'Contrib (2012) = ' || put(cols{(i-1)*7 +4+aux}, dollar12.2) 
           || '^n' || 'Svcs (2009) = ' || put( cols{(i-1)*7 +5+aux}, comma12.1) || '^n' || 'Svcs (2012) = ' || put( cols{(i-1)*7 +6+aux}, comma12.1)
           || '^n' || 'Avg. Age = ' || put( cols{(i-1)*7 +7+aux}, comma12.1);
	end;
    
	*_C10_ = 'N= ' || put(max(_c2_ , _c3_ ),comma12.0) || '^n' || 'Contrib (2009) = ' || 
	       put( _c4_, dollar12.2) || '^n' || 'Contrib (2012) = ' || put( _c5_, dollar12.2)
           || '^n' || 'Svcs (2009) = ' || put( _c6_, comma12.1) || '^n' || 'Svcs (2012) = ' || put( _c7_, comma12.1)
           || '^n' || 'Avg. Age = ' || put( max(_c8_,_c9_), comma12.1);
	*_C19_ = 'N= ' || put(max(_c11_ , _c12_ ),comma12.0) || '^n' || 'Contrib (2009) = ' || 
	       put( _c13_, dollar12.2) || '^n' || 'Contrib (2012) = ' || put( _c14_, dollar12.2)
           || '^n' || 'Svcs (2009) = ' || put( _c15_, comma12.1) || '^n' || 'Svcs (2012) = ' || put( _c16_, comma12.1)
           || '^n' || 'Avg. Age = ' || put( max(_c17_,_c18_), comma12.1);
	*_C28_ = 'N= ' || put(max(_c20_ , _c21_ ),comma12.0) || '^n' || 'Contrib (2009) = ' || 
	       put( _c22_, dollar12.2) || '^n' || 'Contrib (2012) = ' || put( _c23_, dollar12.2)
           || '^n' || 'Svcs (2009) = ' || put( _c24_, comma12.1) || '^n' || 'Svcs (2012) = ' || put( _c25_, comma12.1)
           || '^n' || 'Avg. Age = ' || put( max(_c26_,_c27_), comma12.1);

/*	_C19_ = 'N= ' || put(max(_c11_ , _c12_ ),comma12.0) || '^n' || 'Contrib (2009) = ' || */
/*	       put( _c13_, dollar12.2) || '^n' || 'Contrib (2012) = ' || put( _c14_, dollar12.2)*/
/*           || '^n' || 'Svcs (2009) = ' || put( _c15_, comma12.1) || '^n' || 'Svcs (2012) = ' || put( _c16_, comma12.1)*/
/*           || '^n' || 'Avg. Age = ' || put( max(_c17_,_c18_), comma12.1);*/

endcomp;
run;

ods escapechar="^";
proc report data=wip.matrix_results_summary nowd split='\' ps=50 out=x; 
column Segment segment_new,(flag_2009_sum  flag_2012_sum contrib_mean contrib_12_mean svcs_mean svcs_12_mean age_mean age_12_mean block);
define segment / group ; 
define segment_new / across ; 
define flag_2009_sum / analysis noprint ; 
define flag_2012_sum / analysis noprint; 
define contrib_mean / analysis noprint; 
define contrib_12_mean / analysis noprint; 
define  svcs_mean / analysis noprint;
define  svcs_12_mean / analysis noprint;
define  age_mean / analysis noprint;
define  age_12_mean / analysis noprint;
define block / computed width=25 ''; 
compute block / char length=250;
   array cols{96}   _c2_	_c3_	_c4_	_c5_	_c6_	_c7_	_c8_    _c9_
					_c11_	_c12_	_c13_	_c14_	_c15_	_c16_	_c17_   _C18_
					_c20_	_c21_	_c22_	_c23_	_c24_	_c25_	_c26_   _C27_
					_c29_	_c30_	_c31_	_c32_	_c33_	_c34_	_c35_   _C36_
					_c38_	_c39_	_c40_	_c41_	_c42_	_c43_	_c44_   _C45_
					_c47_	_c48_	_c49_	_c50_	_c51_	_c52_	_c53_   _C54_
					_c56_	_c57_	_c58_	_c59_	_c60_	_c61_	_c62_   _C63_
					_c65_	_c66_	_c67_	_c68_	_c69_	_c70_	_c71_   _c72_
					_c74_	_c75_	_c76_	_c77_	_c78_	_c79_	_c80_   _C81_
					_c83_	_c84_	_c85_	_c86_	_c87_	_c88_	_c89_   _C90_
					_c92_	_c93_	_c94_	_c95_	_c96_	_c97_	_c98_   _C99_
					_c101_	_c102_	_c103_	_c104_	_c105_	_c106_	_c107_  _c108_; 
   array blocks(12)     _c10_  _c19_  _c28_  _c37_  _c46_  _c55_  _c64_  _c73_  _82_  _c91_  _c100_  _c109_;
   do i = 1 to 12;
   		aux=i-1;
          blocks{i} = 'N= ' || put(max(cols{(i-1)*8 +2+aux} , cols{(i-1)*8 +3+aux}),comma12.0) || '^n' || 'Contrib (2009) = ' || 
	       put( cols{(i-1)*8 +4+aux}, dollar12.2) || '^n' || 'Contrib (2012) = ' || put(cols{(i-1)*8 +5+aux}, dollar12.2) 
           || '^n' || 'Svcs (2009) = ' || put( cols{(i-1)*8 +6+aux}, comma12.1) || '^n' || 'Svcs (2012) = ' || put( cols{(i-1)*8 +7+aux}, comma12.1)
           || '^n' || 'Avg. Age = ' || put( max(cols{(i-1)*8 +8+aux},cols{(i-1)*8 +9+aux}), comma12.1);
	end;
    
	*_C10_ = 'N= ' || put(max(_c2_ , _c3_ ),comma12.0) || '^n' || 'Contrib (2009) = ' || 
	       put( _c4_, dollar12.2) || '^n' || 'Contrib (2012) = ' || put( _c5_, dollar12.2)
           || '^n' || 'Svcs (2009) = ' || put( _c6_, comma12.1) || '^n' || 'Svcs (2012) = ' || put( _c7_, comma12.1)
           || '^n' || 'Avg. Age = ' || put( max(_c8_,_c9_), comma12.1);
	*_C19_ = 'N= ' || put(max(_c11_ , _c12_ ),comma12.0) || '^n' || 'Contrib (2009) = ' || 
	       put( _c13_, dollar12.2) || '^n' || 'Contrib (2012) = ' || put( _c14_, dollar12.2)
           || '^n' || 'Svcs (2009) = ' || put( _c15_, comma12.1) || '^n' || 'Svcs (2012) = ' || put( _c16_, comma12.1)
           || '^n' || 'Avg. Age = ' || put( max(_c17_,_c18_), comma12.1);
	*_C28_ = 'N= ' || put(max(_c20_ , _c21_ ),comma12.0) || '^n' || 'Contrib (2009) = ' || 
	       put( _c22_, dollar12.2) || '^n' || 'Contrib (2012) = ' || put( _c23_, dollar12.2)
           || '^n' || 'Svcs (2009) = ' || put( _c24_, comma12.1) || '^n' || 'Svcs (2012) = ' || put( _c25_, comma12.1)
           || '^n' || 'Avg. Age = ' || put( max(_c26_,_c27_), comma12.1);

/*	_C19_ = 'N= ' || put(max(_c11_ , _c12_ ),comma12.0) || '^n' || 'Contrib (2009) = ' || */
/*	       put( _c13_, dollar12.2) || '^n' || 'Contrib (2012) = ' || put( _c14_, dollar12.2)*/
/*           || '^n' || 'Svcs (2009) = ' || put( _c15_, comma12.1) || '^n' || 'Svcs (2012) = ' || put( _c16_, comma12.1)*/
/*           || '^n' || 'Avg. Age = ' || put( max(_c17_,_c18_), comma12.1);*/

endcomp;
run;


proc report data=wip.matrix_results_summary nowd split='\' ps=50 out=x; 
column Segment segment_new,(flag_2009_sum  flag_2012_sum block1 block2);
define segment / group ; 
define segment_new / across ; 
define flag_2009_sum / analysis noprint ; 
define flag_2012_sum / analysis noprint; 
define block1 / computed width=25 ''; 
define block2 / computed width=25 ''; 
compute block1 / char length=25;
	block1 = put(flag_2009_sum, comma12.);
endcomp;
compute block2 / char length=25;
	block1 = put(flag_2012_sum, comma12.);
endcomp;
run;


*#########################################################################################################################;
*do oldest distribution by the not present in 2009;
filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\mergers.txt';
data virtual.mergers;
length hhid $ 9;
infile myfile dsd dlm='09'x firstobs=2 ;
input hhid $ merge_flag;
if merge_flag eq 0 then delete;
run;

proc sql;
select count(hhid) from virtual.mergers;
quit;

data matrix_data1;
length aux $ 6;
set matrix_data1;
aux=put(year(oldest_12),z4.)||put(month(oldest_12),z2.);
year_12 = year(oldest_12);
format oldest_12 date10.;
run;


data matrix_data1;
merge matrix_data1 (in=a) virtual.mergers (in=b);
by hhid;
if a;
run;



proc freq data=matrix_data1;
where   segment eq 'Not Present';
table year_12 / missing;
run;

proc freq data=matrix_data1;
where   segment eq 'Not Present' and merge_flag eq .;
table year_12 / missing;
run;

proc freq data=matrix_data1;
table segment / missing;
run;


data bads_2007;
set matrix_data1 (where=(merge_flag eq . and segment eq 'Not Present' and year_12 eq 2008) obs=100);
keep hhid segment segment_new;
run;


*in researching the new ones that had old accts after exckluding the acquired ones, I found the expected ones where hh changed
but I also found I missclassified some not present - in an example the 2009 flag was . but the 2009 chk flag was 0, I do not remember how 
I did the chk flag - I reexported the hh present to create new 2009 and 2012 flags;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\h201204.txt';
data virtual.hhs_201204;
length hhid $ 9;
infile myfile dsd dlm='09'x;
input hhid $ flag_2012_new;
run;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\h200912.txt';
data virtual.hhs_200912;
length hhid $ 9;
infile myfile dsd dlm='09'x;
input hhid $ flag_2009_new;
run;
