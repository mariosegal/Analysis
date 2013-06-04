libname Data 'C:\Documents and Settings\ewnym5s\My Documents\Data';
libname wip 'C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files';

options MSTORED SASMSTORE = mjstore;
libname mjstore 'C:\Documents and Settings\ewnym5s\My Documents\SAS\Macros';

libname sas 'C:\Documents and Settings\ewnym5s\My Documents\SAS';
options fmtsearch=(SAS);



Data tempx;
set Data.Main_201111;
int_bal = sum(dda_amt, sav_amt,mms_amt,ira_amt, tda_amt, sec_amt);
select  ;
	when (int_bal eq 0) asset_segm = 0;
	when (int_bal gt 0 and int_bal lt 5000)  asset_segm = 1;
	when (int_bal ge 5000 and int_bal lt 25000 )  asset_segm = 2;
	when (int_bal ge 25000 and int_bal lt 100000 )  asset_segm = 3;
	when (int_bal ge 100000 and int_bal lt 500000 )  asset_segm = 4;
	when (int_bal ge 500000  )  asset_segm = 5;
	when (int_bal lt 0)  asset_segm = 99;
end;
keep HHid int_bal asset_segm;
run;


 proc freq data=tempy;
 table asset_segm;
 run;


 data tempy;
 merge data.main_201111 (in=a) tempx (in=b);
 by hhid;
 if a;
 run;


 data data.main_201111;
 set tempy;
 run;


data data.asset_band_class;
length asset_seg $ 2;
input asset_seg $ ;
datalines;
0
1
2
3
4
5
99
;
run;


%let class1=asset_band;
%let identifier=201111;
%let title="Tran Segment";
%let out_file=asset_segments;
%let condition=hh eq 1;
%let out_dir=Segmentation;
%let dir="C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files";

option orientation=landscape;
%profile_analysis(condition=hh eq 1,class1=asset_band,out_file=asset_segments,
out_dir=Segmentation,identifier=201111,dir="C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files",title="Asset Segments",clean=0);
