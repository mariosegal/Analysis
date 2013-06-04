*read the different datasets;


proc import 
   datafile='C:\Documents and Settings\ewnym5s\My Documents\Business Banking\TS Prospects by branch2.xlsx'
   out=prospects
   dbms=EXCEL 
	replace;
   DBDSOPTS= 'FIRSTOBS=5' ;
run;

data prospects;
set prospects;
rename Business_Banking_Target_Segment_=branch f2=name f3=total f4=prospects f5=pct;
run;


proc import 
   datafile='C:\Documents and Settings\ewnym5s\My Documents\Business Banking\Branch Share 3mi.xlsx'
   out=share_3mi
   dbms=EXCEL 
	replace;

run;


proc import 
   datafile='C:\Documents and Settings\ewnym5s\My Documents\Business Banking\Branch Share 1_5 mi.xlsx'
   out=share_1p5mi
   dbms=EXCEL 
	replace;

run;

proc import 
   datafile='C:\Documents and Settings\ewnym5s\My Documents\Business Banking\Branch Share 0_5 mi.xlsx'
   out=share_0p5mi
   dbms=EXCEL 
	replace;

run;

proc import 
   datafile='C:\Documents and Settings\ewnym5s\My Documents\Business Banking\branch_key.xlsx'
   out=key
   dbms=EXCEL 
	replace;

run;

proc import 
   datafile='C:\Documents and Settings\ewnym5s\My Documents\Business Banking\coords.xlsx'
   out=coords
   dbms=EXCEL 
	replace;

run;

proc import 
   datafile='C:\Documents and Settings\ewnym5s\My Documents\Business Banking\FMCG Opp.xlsx'
   out=fmcg
   dbms=EXCEL 
	replace;

run;


proc import 
   datafile='C:\Documents and Settings\ewnym5s\My Documents\Business Banking\BB checking sales oct2011 to sep 2012.xlsx'
   out=sales
   dbms=EXCEL 
	replace;

run;

proc import 
   datafile='C:\Documents and Settings\ewnym5s\My Documents\Business Banking\MAPI Data.xlsx'
   out=mapi
   dbms=EXCEL 
	replace;
run;

*combine them;

*the keys ahev caps sometimes, I need to make it all upcase to fix this;
data key;
set key;
key_new = upcase(key);
run;

data share_0p5mi;
set share_0p5mi;
key_new = upcase(key);
run;

data share_1p5mi;
set share_1p5mi;
key_new = upcase(key);
run;

data share_3mi;
set share_3mi;
key_new = upcase(key);
run;



proc sort data=key;
by key_new;
run;

proc sort data=share_0p5mi;
by key_new;
run;

proc sort data=share_1p5mi;
by key_new;
run;

proc sort data=share_3mi;
by key_new;
run;


data share_3mi;
set share_3mi;
by key_new;
if not first.key_new then delete;
if key_new eq ''  then delete;
run;

data share_1p5mi;
set share_1p5mi;
by key_new;
if not first.key_new then delete;
if key_new eq '' then delete;
run;

data share_0p5mi;
set share_0p5mi;
by key_new;
if not first.key_new then delete;
if key_new eq '' then delete;
run;

data test check;
retain miss miss1;
merge share_0p5mi (in=a) key (in=b) end=eof;
by key_new;
if a and b then output test;
if b and not a then output check;
if a and not b then miss+1;
if b and not a then miss1+1;
if eof then do;
	put 'WARNING: There were ' miss ' Records on A not on B';
	put 'WARNING: There were ' miss1 ' Records on B not on A';
end;
drop miss: ;
run;

data test1 check1;
retain miss miss1;
merge share_1p5mi (in=a) key (in=b) end=eof;
by key_new;
if a and b then output test1;
if b and not a then output check1;
if a and not b then miss+1;
if b and not a then miss1+1;
if eof then do;
	put 'WARNING: There were ' miss ' Records on A not on B';
	put 'WARNING: There were ' miss1 ' Records on B not on A';
end;
drop miss: ;
run;

data test2 check2;
retain miss miss1;
merge share_3mi (in=a) key (in=b) end=eof;
by key_new;
if a and b then output test2;
if b and not a then output check2;
if a and not b then miss+1;
if b and not a then miss1+1;
if eof then do;
	put 'WARNING: There were ' miss ' Records on A not on B';
	put 'WARNING: There were ' miss1 ' Records on B not on A';
end;
drop miss: ;
run;



*I had dto manually fix Manassas Grant as the key was not consistent;
* I am also missing share for wisconsin Avenue, and thaty is only on the 0.5 file so I will fix that now;

data wisc;
set test;
where branch_share eq .;
branch_share = .08;
run;

data combine1;
set test2 wisc;
run;

proc sort data=combine1;
by branch;
run;

proc sort data=prospects;
by branch;
run;

data combine2;
retain miss;
merge combine1 (in=a) prospects (in=b drop=name) end=eof;
by branch;
if a;
if a and not b then miss+1;
if eof then do;
	put 'WARNING: There were ' miss ' Records on A not on B';
end;
drop miss;
run;

*Horshaem 4118 id missing prospect, for now lets move on, I will fic it when I get that;

proc contents data=fmcg varnum short; run;

proc sort data=fmcg;
by snl_key;
run;

proc sort data=combine2;
by branch;
run;

data fmcg1;
set fmcg;
if snl_key eq . then delete;
if rewgion eq 'HUDSON CITY' then delete;
rename snl_key = branch;
run;


data combine3 check_fmcg;
retain miss;
merge combine2(in=a) fmcg1(keep = branch Deposits Dep_index Loans loan_index in=b) end=eof;
by branch;
if a then output combine3;
if a and not b then output check_fmcg;
if a and not b then miss+1;
if eof then do;
	put 'WARNING: There were ' miss ' Records on A not on B';
end;
drop miss;
run;


*2 nion matches, binghamton, IRT, BWI - maybe for a reason, keep going, fix later if fmcg send it;
proc print data=check_fmcg noobs;
var branch name key;
run;


data bb.combined_data;
set combine3;
run;




*do crucnhing;

*manually add data not on source files;

data bb.combined_data;
set bb.combined_data;
total_opp = sum(deposits , loans);
fair_prosp = branch_share*prospects;
fair_deposits = branch_share*deposits*pct;
fair_loans = branch_share*loans*pct;
fair_total = fair_deposits+fair_loans;
run;

proc rank data=bb.combined_data out=bb.combined_data descending ties=low;
var total_opp prospects fair_deposits fair_loans;
ranks opp_rank prosp_rank fair_deposits_rank fair_loans_rank;
run;

proc sql;
select count(*) into :total from bb.combined_data;
quit;

%let top = %sysfunc(floor(&total/5));
%let bottom = %eval(&total - &top +1 );

%put _user_;

proc format ;
value ranges (notsorted)
	1 - &top = 'High'
	&top <-< &bottom = 'Med'
	&bottom - high = 'Low';
run;


data bb.combined_data;
length dep_grp loan_grp total_grp $ 10;
set bb.combined_data;
if fair_deposits_rank eq . then do;
	fair_deposits_rank = 700;
	fair_loans_rank = 700;
end;
dep_grp = put(fair_deposits_rank, ranges.);
loan_grp = put(fair_loans_rank, ranges.);
total_grp = catx('-',dep_grp,loan_grp);
run;


proc import 
   datafile='C:\Documents and Settings\ewnym5s\My Documents\References\Branch CBRs.xlsx'
   out=key
   dbms=EXCEL 
	replace;

run;

data key;
set key;
rename  community = cbr;
run;

options compress=y;
 data bb.combined_data;
length branch  8  cbr 8;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set key (drop=communities_name) end=eof1;
	dcl hash hh1 (dataset: 'key', hashexp: 8, ordered:'a');
	hh1.definekey('branch');
	hh1.definedata('cbr');
	hh1.definedone();
end;

misses = 0;
do until (eof2);
	set bb.combined_data end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		cbr = .;
	end;
	output;
end;

putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;




proc freq data=bb.combined_data order=data;
table total_grp;
table dep_grp*loan_grp / nocol norow;
run;


*compare to sales, etc.;
proc sort data= bb.combined_data ;
by branch;
run;

proc sort data= sales ;
by branch;
run;

data mapi;
set mapi;
if branch_id eq . then delete;
run;

proc sort data=mapi;
by branch_id;
run;



proc format;
value $ order (notsorted)
	'Low' = '1'
	'Med' = '2'
	'High' = '3';
value $ ordera 
	'1' = 'Low'
	'2' = 'Medium'
	'3' = 'High';

run;

data bb.combined_data;
retain miss;
merge bb.combined_data (in=a) sales(in=b rename=(total=sales)) mapi(in=b keep = branch_id SB_DDA_Predicted_10 rename=(branch_id=branch)) end=eof;
by branch;
rank = sum(fair_deposits_rank,fair_loans_rank)/2;
dep = put(dep_grp, $order.);
loan = put(loan_grp, $order.);
predicted= floor(SB_DDA_Predicted_10);
if a then output;
if eof then put 'WARNING: There were ' miss ' Records in A not in B';
drop miss;
rename total_grp = grp1;
label dep = "Deposit Opportunity" loan = "Loan Opportunity" total_grp = "Opportunity Deposits-Loans" sales="sales";
run;

*total grp has to be renamed as the sas procedure uses total_grp, what are the chances;

/*data chart;*/
/*retain miss;*/
/*merge bb.combined_data (in=a keep=branch fair_deposits_rank fair_loans_rank total_grp dep_grp loan_grp)*/
/*	  sales (in=b) end=eof;*/
/*by branch;*/
/*rank = sum(fair_deposits_rank,fair_loans_rank)/2;*/
/*dep = put(dep_grp, $order.);*/
/*loan = put(loan_grp, $order.);*/
/*if a then output;*/
/*if eof then put 'WARNING: There were ' miss ' Records in A not in B';*/
/*drop miss;*/
/*label dep = "Deposit Opportunity" loan = "Loan Opportunity" total_grp = "Opportunity Deposits-Loans";*/
/*run;*/




proc sort data=bb.combined_data;
by dep loan;
run;


/**/
/**/
/*data attrmap;*/
/*retain markersymbol "Circlefilled";*/
/*length value $ 9;*/
/*input id $ value $ markercolor $ linecolor $ ;*/
/*datalines;*/
/*id1 High-High  cxFFB300 cx000000 */
/*id1 High-Med cx007856 cx000000*/
/*id1 Med-High cxC3E76F cx000000*/
/*id1 Med-Med cx86499D cx000000*/
/*id1 Med-Low cx003359 cx000000*/
/*id1 Low-High cxAFAAA3 cx000000*/
/*id1 Low-Med cx7AB800 cx000000*/
/*id1 Low-Low cx23A491 cx000000*/
/*id2 High-High  cx000000 cxFFB300 */
/*id2 High-Med cx000000 cx007856*/
/*id2 Med-High cx000000 cxC3E76F*/
/*id2 Med-Med cx000000 cx86499D*/
/*id2 Med-Low cx000000 cx003359*/
/*id2 Low-High cx000000 cxAFAAA3*/
/*id2 Low-Med cx000000 cx7AB800*/
/*id2 Low-Low cx000000 cx23A491*/
/*;*/
/*run;*/




data attrmap;
retain markersymbol "CircleFilled";
length value $ 9;
input id $ value $ markercolor $ linecolor $ ;
datalines;
id1 High-High  cxFFB300 cxFFB300 
id1 High-Med cx007856 cx007856
id1 Med-High cxC3E76F cxC3E76F
id1 Med-Med cx86499D cx86499D
id1 Med-Low cx003359 cx003359
id1 Low-High cxAFAAA3 cxAFAAA3
id1 Low-Med cx7AB800 cx7AB800
id1 Low-Low cx23A491 cx23A491
;
run;

data attrmap;
set attrmap;
fillcolor = linecolor;
run;

title;
footnote;

ods graphics on / width=8in height=6in border=off imagefmt=png imagename="chart";
ods html style=mtbnew gpath="C:\Documents and Settings\ewnym5s\My Documents\Business Banking\";

proc sgplot data=bb.combined_data daTTRMAP=ATTRMAP;
scatter x=rank y = sales / group=grp1  ATTRID=id1 transparency=0.4;
loess x=rank y = sales / group=grp1 lineattrs=(thickness=1 pattern=Solid)  ATTRID=id1 nomarkers;
yaxis label="Checking Sales Oct-2011 to Sep-2012" labelattrs=(weight=bold) ;
xaxis label="Opportunity Rank (1 = Highest)" labelattrs=(weight=bold);
format dep loan $ordera.;
run;
quit;

ods graphics off;

*sales vs dep oppty colors by opportunity;
proc sgplot data=bb.combined_data ;
scatter x=fair_deposits y = sales / group=grp1   transparency=0.4;
loess x=fair_deposits y = sales / group=grp1 lineattrs=(thickness=1 pattern=Solid)  ATTRID=id1 nomarkers;
yaxis label="Checking Sales Oct-2011 to Sep-2012" labelattrs=(weight=bold) ;
xaxis label="Deposit Opportunity ($MM)" labelattrs=(weight=bold) max=20;
format dep loan $ordera.;
run;
quit;

proc corr data=bb.combined_data outp=corr1 pearson;
where cbr ne .;
by cbr;
var sales rank;
run;

data corr1;
length label $ 12; 
set corr1;
where _type_ eq "CORR" and _name_ eq 'sales';
label = "corr = " || put(rank,comma5.2);
run;

data anno;
set corr1;
retain function "text" color "red" anchor  "TOPRIGHT";
keep function label color anchor cbr;
run;

data chartdata;
merge bb.combined_data (in=a) anno(in=b keep = cbr label);
by cbr;
run;

data chartdata;
length group_name $ 20;
set chartdata;
group_name = trim(put(cbr,cbr2012fmt.)) || " (" || trim(label) || ")";
run;

data fmt;
length label $ 20;
set chartdata;
where cbr ne .;
fmtname = "quickcbr";
START = cbr;
end = CBR;
label = group_name;
type = "N";
HLO = "S";
keep  fmtname start end label hlo type;
by cbr;
if first.cbr then output;
run;


proc format cntlin=fmt;
run;

 
*sales vs dep oppty colors by cbr;
ods graphics on / width=10in height=6in border=off imagefmt=png imagename="chart";
proc sgpanel data=bb.combined_data ;
where cbr ne .;
panelby cbr / layout=panel onepanel start=topleft NOVARNAME uniscale=column columns=6;
/*scatter x=rank y = sales   ;*/
loess x=rank y = sales / lineattrs=(color=cxC3E76F) markerattrs=(color=cx007856 symbol=CircleFilled) NOLEGFIT ;
rowaxis label="Checking Sales Oct-2011 to Sep-2012" labelattrs=(weight=bold) ;
colaxis label="Opportunity Rank (1 = Highest)" labelattrs=(weight=bold) ;
format dep loan $ordera. cbr quickcbr.;
run;
quit;
ods graphics off;

proc sort data=bb.combined_data;
by cbr;
run;

proc corr data=bb.combined_data plots=matrix;
by cbr;
var sales rank;
run;

proc sgscatter data=bb.combined_data;
plot sales*rank / group=cbr;
run;
 

*compare to MAPI;
proc sort data=chart;
by branch;
run;


proc sort data=chart;
by dep loan;
run;

ods graphics on / width=8in height=6in border=off imagefmt=png imagename="sales_v_pred";
ods html style=mtbnew gpath="C:\Documents and Settings\ewnym5s\My Documents\Business Banking\";

proc sgplot data=chart daTTRMAP=ATTRMAP;
scatter x=rank y=predicted / group=grp1 ATTRID=id1 transparency=0.4;
loess x=rank y=predicted / group=grp1 lineattrs=(thickness=1 pattern=Solid)  ATTRID=id1 nomarkers;
/*reg x=total y=predicted / group=grp1 lineattrs=(thickness=1 pattern=Solid)  ATTRID=id1 nomarkers;*/
yaxis label="Predicted BB DDA Sales (McKInsey)" labelattrs=(weight=bold) ;
xaxis label="Opportunity Rank (1 = Highest)" labelattrs=(weight=bold);
format dep loan $ordera.;
run;
quit;
ods graphics off;

proc corr data=chart;
var total predicted ;
run;



*do map on SAS;

proc sort data=coords;
by branch;
run;

proc sort data=chart;
by branch;
run;

data chart;
length state 5;
merge chart(in=a) coords(keep = branch branch_name latitude longitude state in=b rename=(state=statecode));
by branch;
if a;
state = stfips(statecode);
run;

data anno;
set chart;
length color $ 12 x y 8;
keep grp1 lat long color branch flag segment xsys ysys function style text when x y statecode;
xsys='2'; ysys='2'; when='a';
lat = input(latitude,comma24.12);
long = input(longitude,comma24.12);
flag=1;
function="symbol";
style="marker";
text="V";
segment=branch;
select (grp1);
	when ('High-High') color = 'Dark_Red';
	when ('High-Med') color = 'Red';
	when ('Med-High') color = 'Red';
	when ('Med-Med') color = 'Dark_Orange';
	when ('High-Low') color = 'Orange';
	when ('Low-High') color = 'Orange';
	when ('Med-Low') color = 'Dark_Yellow';
	when ('Low-Med') color = 'Dark_Yellow';
	when ('Low-Low') color = 'Yellow';
end;
   x=atan(1)/45*long;
   y=atan(1)/45*lat;
/*x = long; y=lat;*/
x=-x;
rename state=statecode;
run;

data map;
length statecode $ 2;
set  mapssas.states(where=(state in (42,36,34,9,24,51,10,11)));
statecode= fipstate(state);
run;


data all;
set anno map;
run;



proc gproject data=all out=all_p ;
id state;
run;

data map_p dot_p;
   set all_p;
  /* If the FLAG variable has a value of 1, it is an annotate data */
  /* set observation; otherwise, it is a map data set observation. */
   if flag=1 then output dot_p;
   else output map_p;
run;


ods graphics on / width=4in height=3in border=off imagefmt=png imagename="bb_map";
ods html style=mtbnew gpath="C:\Documents and Settings\ewnym5s\My Documents\Business Banking\";
proc gmap map=map_p   all;
id statecode;
choro statecode / discrete nolegend annotate=dot_p coutline=blue levels=1 stat=freq cdefault=lightgray ysize=6in ;
run;
ods graphics off;

%let state=PA;
ods graphics on / width=4in height=3in border=off imagefmt=png imagename="bb_map";
ods html style=mtbnew gpath="C:\Documents and Settings\ewnym5s\My Documents\Business Banking\";
proc gmap map=map_p (where =(statecode eq "&state"))  all;
id statecode;
choro statecode / discrete nolegend annotate=dot_p(where =(statecode eq "&state")) coutline=blue levels=1 stat=freq cdefault=lightgray ysize=3in;
run;
ods graphics off;

ods graphics on / width=4in height=3in border=off imagefmt=png imagename="md_map";
ods html style=mtbnew gpath="C:\Documents and Settings\ewnym5s\My Documents\Business Banking\";
proc gmap map=map_p (where =(statecode in ('MD','DE')))  all;
id statecode;
choro statecode / discrete nolegend annotate=dot_p(where =(statecode in ('MD','DE'))) coutline=blue levels=1 stat=freq cdefault=lightgray ysize=3in;
run;
ods graphics off;

ods graphics on / width=4in height=3in border=off imagefmt=png imagename="dc_map";
ods html style=mtbnew gpath="C:\Documents and Settings\ewnym5s\My Documents\Business Banking\";
proc gmap map=map_p (where =(statecode in ('DC','VA')))  all;
id statecode;
choro statecode / discrete nolegend annotate=dot_p(where =(statecode in ('DC','VA'))) coutline=blue levels=1 stat=freq cdefault=lightgray ysize=3in;
run;
ods graphics off;
proc gproject  out=map_p degree eastlong;
id segment;
run;
