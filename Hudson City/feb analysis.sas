data feb_open;
set hudson.accts_201302;
where close_date eq '';
key1 = catx('*',N_ADDRESS,N_CITY,N_STATE,transtrn(N_ZIP10,"-",trimn('')));
keep acct_nbr type subtype sbu balance open_date close_date N_: key1;
run;

proc freq data=feb_open;
table type;
run;


data nov open; 
set hudson.clean_20121106;
where ptype ne 'MTX';
keep ptype stype key pseudo_hh curr_bal sbu_new acct_nbr curr_bal;
run;


proc sort data=feb_open;
by acct_nbr;
run;

proc sort data=nov;
by acct_nbr;
run;

data hudson.feb_combined;
merge nov (in=a) feb_open (in=b);
by acct_nbr;
nov = 0;
feb=0;
if a then nov =1;
if b then feb = 1;
run;

proc freq data=hudson.feb_combined;
table ptype*nov*feb / missing nocol norow nopercent;
run;

proc freq data=hudson.feb_combined;
where feb eq 1 and nov eq 0;
table type;
run;

data hudson.feb_combined;
set hudson.feb_combined;
if feb eq 1 and nov eq 0 then open_clean = substr(open_date,7,10) || substr(open_date,1,2);
run;


proc freq data=hudson.feb_combined;
where feb eq 1 and nov eq 0;
table open_clean;
run;

*about 4% od 21,000 were opened before november, yet not in nov file - what gives?;

data hudson.feb_combined;
set hudson.feb_combined;
if nov eq 0 and feb eq 1 and open_clean lt '201211' then exclude = 1;
run;

proc freq data=hudson.feb_combined;
where exclude eq 1;
table open_clean;
run;

*create the new ones not weird to see if I can mathc the keys;

data new;
set hudson.feb_combined;
where exclude ne 1 and feb eq 1 and nov eq 0;
keep acct_nbr key1;
run;


proc sort data= hudson.feb_combined(keep=pseudo_hh key nov where=(nov eq 1 )) out=nov_keys(drop=nov) nodupkey;
by key;
run;

data nov_keys;
set nov_keys;
rename pseudo_hh=pseudo_hh1 key=key1;
run;

proc sort data=hudson.feb_combined;
by key1;
run;


data hudson.feb_combined;
retain miss match;
merge hudson.feb_combined (in=a) nov_keys(in=b) end=eof;
by key1;
if a;
if a and b and nov eq 0 and feb eq 1 and exclude ne 1 then match+1;
if a and not b and nov eq 0 and feb eq 1 and exclude ne 1 then miss+1;
if eof then do;
	put 'WARNING: Feb records with match = ' match;
	put 'WARNING: Feb records with no match = ' miss;
end;
run;

data hudson.feb_combined;
set hudson.feb_combined;
if pseudo_hh eq . and pseudo_hh1 ne . then pseudo_hh = pseudo_hh1;
run;
 
proc freq data=hudson.Feb_combined;
where pseudo_hh eq . and exclude ne 1;
table feb*nov;
run;

proc sort data=hudson.feb_combined (keep=key1 pseudo_hh exclude where=(pseudo_hh eq . and exclude ne 1))
           out=feb_new (drop=exclude) nodupkey;
by key1;
run;

data feb_new;
set feb_new;
pseudo_hh = 9999000+_N_;
run;


data hudson.feb_combined;
retain miss ;
merge hudson.feb_combined (in=a) feb_new(in=b where=(key1 ne '')) end=eof;
by key1;
if a;
if a and not b and pseudo_hh eq . and exclude ne 1 then miss+1;
if eof then do;
	put 'WARNING: Feb records with no match = ' miss;
end;
drop  miss match;
run;

proc sort data=hudson.feb_combined;
by pseudo_hh;
run;

proc summary data=hudson.feb_combined;
where exclude ne 1;
by pseudo_hh;
output out=hhs max(nov)=nov max(feb)=feb;
run;

proc sql;
select count(*) as pure from hudson.hudson_hh where not(mtx eq 1 and products eq 1);
select count(*) as all1 from hudson.hudson_hh;
select count(*) as con from hudson.hudson_hh where con1=1;
select count(*) as con_no_mtx from hudson.hudson_hh where con1=1 and not(mtx eq 1 and products eq 1);
create table universe as select pseudo_hh, distance from hudson.hudson_hh where con1=1 and not(mtx eq 1 and products eq 1);
select count(*) as mixed from hudson.hudson_hh where con1=1 and bus1 eq 1 and int1 ne 1;
quit;

data universe;
set universe;
x = 1;
run;

data dist1;
set hudson.accts_201302;
keep acct_nbr cdist1;
run;

proc sort data=hudson.feb_combined;
by acct_nbr;
run;

proc sort data=dist1;
by acct_nbr;
run;

data hudson.feb_combined;
merge hudson.feb_combined (in=a) dist1;
by acct_nbr;
if a;
run;

* I need to add ptype to the new ones;

proc freq data=hudson.feb_combined;
where ptype eq '';
table type / missing;
table sbu_new*stype / missing;
run;


proc format;
value $ savings 	'01' = 'Passbook'
				'41', '60' = 'Statement'
				'31', '32' = 'MMA Sav'
				'22' = 'Hlday Club'
				'23' = 'Vacat Club'
				'54' = 'Rent Scty'
				'55' = 'landlord';
value $ sbu 	'54' ,'55' = 'BUS'
				other = 'CON';
value $ product   '01', '41',  '22', '23', '54', '55' = 'SAV'
				'31' = "MMS"
 				'60' ,'32' = 'IRA';
run;
proc format;
value $ checking 	'02' = 'Employee'
					'03' = 'Estate'
					'01','04','06' = 'Regular'
					'05' = 'Business'
					'08' = 'Super'
					'09' = 'Br Exp'
					'12' = 'MMA'
					'13' = 'Atny Trust'
					'14' = 'Consumer'
					'15' = 'Bus MMA'
					'16' = 'High Value'
					'17' = 'Better Int'
					'10' = 'IOLTA'
					'07' = 'Public'
					'20','21','22','23','24','28' = "Internal";
value $ chktype     '12','15' = 'MMS'
                    Other = 'DDA';
value $ chksbu 		'05','13','15','07' = 'BUS'
					'09','20','21','22','23','24','28' = 'INT'
					Other = 'CON';

value $ cdtype	'24','04','10','14','21','09','27','13','18','16','25','29','30','20','22','80' = 'TDA'
				'72','62','63','67','71','79','75','74','70','76','68','73','77','78','84','69' = 'IRA';
value $ cdstype (notsorted) '24','72' = '91 day'
				'04','62'='4M'
				'10','63'='5M'
				'14','67'='6M'
				'21','71'='7M'
				'09','79'='9M'
				'27','75'='1Y'
				'13','74'='13M'
				'18','70','76'='18M'
				'16','20','68' = '2Y'
				'25','22','73','84' = '3Y'
				'29','77'='4Y'
				'30','78'='5Y'
				'80','69'='OTH';
run;

proc format;
value $ ptype45a '01','02','03','04','05','06','07','08','09' = 'HEQ'
                 '12','13','14' = 'CCS'
				 '41' = 'CLN'
				 '42' = 'CLN'
				 '43'='CLN';
value $ ptype51a '20','40','41','42','43','57','56','52' = 'ILN'
 				 '54' = 'CLN'
                 '58','59' = 'ILN';
value $ ptype52a '01' = 'ILN';
value $ sbu45a '01','02','03','04','05','06','07','08','09','12','13','14' = 'CON'
				'41','42','43' = 'BUS';
value $ sbu51a '54' = 'BUS'
				other = 'CON';
value $ sbu50a '50','51','52' = 'BUS'
				other = 'CON';
run;

data hudson.feb_combined;
set hudson.feb_combined;
if ptype eq '' then do;
    change = 1;
	if TYPE = 'SAV' then do;
		PTYPE = put(subtype, $product.);
		STYPE = put(subtype, $savings.);
		SBU_NEW = put(subtype, $sbu.);
	end;

	if TYPE = 'CHKG' then do;
		PTYPE = put(subtype, $chktype.);
		STYPE = put(subtype, $checking.);
		SBU_NEW = put(subtype, $chksbu.);
	end;

	if TYPE = 'CD' then do;
		PTYPE = put(subtype, $cdtype.);
		STYPE = put(subtype, $cdstype.);
		SBU_NEW = "CON";
	end;

	if substr(acct_nbr,1,2) = '45' then do;
		PTYPE = put(subtype, $ptype45a.);
		STYPE = subtype;
		SBU_NEW = put(subtype, $sbu45a.);
	end;

	if substr(acct_nbr,1,2) = '51' then do;
		PTYPE = put(subtype, $ptype51a.);
		STYPE = subtype;
		SBU_NEW = put(subtype, $sbu51a.);
	end;

	if substr(acct_nbr,1,2) = '52' then do;
		PTYPE = put(subtype, $ptype52a.);
		STYPE = subtype;
		SBU_NEW = "CON";
	end;

	if substr(acct_nbr,1,2) = '50' then do;
		PTYPE = "MTG";
		STYPE = subtype;
		SBU_NEW = put(subtype, $sbu50a.);
	end;
end;
run;

proc sort data=hudson.feb_combined;
by pseudo_hh ptype;
run;

data hudson.feb_combined;
set hudson.feb_combined;
acct = 1;
run;


proc summary data=hudson.feb_combined  ;
where exclude ne 1 and sbu_new="CON";
by pseudo_hh ptype;
output out=prods sum(acct)=Accts sum(balance)= balance ;
run;

data prods;
set prods;
if accts gt 1 then accts = 1;
run;

proc transpose data=prods (keep=pseudo_hh ptype accts) out=prods1(drop=_name_) suffix=_feb;
by pseudo_hh;
id ptype;
run;

proc transpose data=prods (keep=pseudo_hh ptype balance) out=bals1(drop=_name_) suffix=_amt_feb;
by pseudo_hh;
id ptype;
run;

%null_to_zero(source=prods1, destination=prods2, variables=all)
%null_to_zero(source=bals1, destination=bals2, variables=all)

data prods2;
set prods2;
if pseudo_hh eq 0 then pseudo_hh = .;
products = sum(dda_feb,mms_feb,sav_feb,tda_feb,ira_feb,mtg_feb,heq_feb,iln_feb,ccs_feb);
run;

data bals2;
set bals2;
if pseudo_hh eq 0 then pseudo_hh = .;
run;




proc summary data=hudson.feb_combined;
where exclude ne 1 and sbu_new="CON";
by pseudo_hh;
output out=main1(drop=_:) sum(nov) = nov sum(feb)=feb;
run;

data main1;
set main1;
if nov gt 1 then nov = 1;
if feb gt 1 then feb = 1;
run;



proc sort data=hudson.hudson_hh(keep=pseudo_hh con1 segment state dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt where=(con1=1)) out=segment(drop=con1)  nodupkey;
by pseudo_hh;
run;





proc sort data=universe;
by pseudo_hh;
run;

data universe;
set universe;
if pseudo_hh eq 999999 then pseudo_hh = .;
x = 1;
run;

proc sort data=universe;
by pseudo_hh;
run;

proc summary data=hudson.feb_combined  ;
where exclude ne 1 and sbu_new="CON";
by pseudo_hh;
output out=distfeb max(cdist1)=cdist1  ;
run;


data hudson.hudson_feb;
length type $ 8;
merge main1(in=a) prods2 bals2 segment universe(in=b);
by pseudo_hh;
if a;
if nov eq 1 and feb eq 1 then type = 'retained';
if nov eq 1 and feb eq 0 then type = 'attrited';
if nov eq 0 and feb eq 1 then type = 'new';
hh = 1;
run;

data hudson.hudson_feb;
set hudson.hudson_feb;
if type ne 'new' and x ne 1 then drop1 = 1;
run;



data hudson.hudson_feb;
set  hudson.hudson_feb;
prods_nov = sum(dda1,mms1,tda1,sav1,ira1,mtg1,iln1,heq1);
run;


data  hudson.hudson_feb;
merge  hudson.hudson_feb (in=a) distfeb (keep=pseudo_hh cdist1);
by pseudo_hh;
if a;
run;


data  hudson.hudson_feb;
set hudson.hudson_feb;
if type = 'new' then distance = cdist1;
run;


proc freq data=hudson.hudson_feb;

table drop1*x / missing;
table drop1*type / missing;
table type*x/missing;
run;


data segments;
length acct_nbr $ 14 segment_feb $ 30;
infile 'C:\Documents and Settings\ewnym5s\My Documents\201302_Segment.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input acct_nbr $ segment_feb $ ;
run;

proc sort data=hudson.accts_201302;
by acct_nbr;
run;

proc sort data=segments;
by acct_nbr;
run;

data hudson.accts_201302;
merge hudson.accts_201302 (in=a) segments;
by acct_nbr;
if a;
run;

proc sort data=hudson.feb_combined;
by acct_nbr;
run;

data hudson.feb_combined;
merge hudson.feb_combined (in=a) segments;
by acct_nbr;
if a;
run;

proc sort data=hudson.feb_combined;
by pseudo_hh;
run;

data hudson.feb_combined;
set hudson.feb_combined;
select  (ptype);
	when ('DDA') order = 1;
	when ('MMS') order = 2;
	when ('SAV') order = 3;
	when ('TDA') order = 4;
	when ('IRA') order = 5;
	when ('MTG') order = 6;
	when ('HEQ') order = 7;
	when ('ILN') order = 8;
	when ('CCS') order = 9;
	otherwise order=10;
end;
run;

proc sort data=hudson.feb_combined;
by pseudo_hh order;
run;

data seg1;
set hudson.feb_combined (keep=pseudo_hh segment_feb);
by pseudo_hh;
if first.pseudo_hh then output;
run;

data hudson.hudson_feb;
merge hudson.hudson_feb (in=a) seg1;
by pseudo_hh;
if a;
run;

*finally analysis;
Title 'Type of HH';
proc freq data=hudson.hudson_feb;
where drop1 ne 1;
table type / missing;
run;

Title 'November HHs';
proc freq data=hudson.hudson_feb;
where type ne 'new' and drop1 ne 1;;
table type;
run;

proc format;
value  prods (notsorted )
	      1 = 'Single'
		2-high = 'Multi';

value $ state (notsorted) 'CT' = 'CT'
              'NY' = 'NY'
			  'NJ' = 'NJ'
			other = 'Other';
run;

proc format;
value hudsonseg (notsorted)
   1 = 'Building Their Future'
2 = 'Mainstream Family'
4 = 'Mass Affluent Family'
3 = 'Mainstream Retired'
5 = 'Mass Affluent Retired'
6, . = 'Unable to Code';
run;

Title 'Profile of HHs';
proc tabulate data=hudson.hudson_feb missing order=data;
where drop1 ne 1;
class type segment state / preloadfmt ;
var hh dda: mms: sav: tda: ira: heq: mtg: iln: ;
format segment hudsonseg. state $state.;
table type, sum*hh*f=comma12. state*N*f=comma12. state*rowpctN*f=pctfmt. / nocellmerge misstext='0';
table type, sum*hh*f=comma12. segment*N*f=comma12. segment*rowpctN*f=pctfmt. / nocellmerge misstext='0';
table type, sum*(hh dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 )*f=comma12. 
            rowpctsum<hh>*( dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1)*f=pctfmt. / nocellmerge misstext='0';
table type, sum*(hh dda_feb mms_feb sav_feb tda_feb ira_feb mtg_feb heq_feb iln_feb )*f=comma12. 
            rowpctsum<hh>*(dda_feb mms_feb sav_feb tda_feb ira_feb mtg_feb heq_feb iln_feb  )*f=pctfmt. / nocellmerge misstext='0';
table type, sum*hh*f=comma12. (dda_amt*rowpctsum<dda1> mms_amt*rowpctsum<mms1> sav_amt*rowpctsum<sav1> tda_amt*rowpctsum<tda1> 
             ira_amt*rowpctsum<ira1> mtg_amt*rowpctsum<mtg1> heq_amt*rowpctsum<heq1> iln_amt*rowpctsum<iln1> )*f=pctdoll. / nocellmerge misstext='0';
table type, sum*hh*f=comma12. (dda_amt_feb*rowpctsum<dda_feb> mms_amt_feb*rowpctsum<mms_feb> sav_amt_feb*rowpctsum<sav_feb> tda_amt_feb*rowpctsum<tda_feb> 
             ira_amt_feb*rowpctsum<ira_feb> mtg_amt_feb*rowpctsum<mtg_feb> heq_amt_feb*rowpctsum<heq_feb> iln_amt_feb*rowpctsum<iln_feb> )*f=pctdoll. / nocellmerge misstext='0';
run;

proc tabulate data=hudson.hudson_feb missing order=data;
where drop1 ne 1;
class type prods_nov products distance / preloadfmt ;
var hh dda: mms: sav: tda: ira: heq: mtg: iln: ;
table type all, (prods_nov products)*f=comma12. / nocellmerge misstext='0';
table type , distance*f=comma12. distance*rowpctn*f=pctfmt. / nocellmerge misstext='0';
table type all, sum*hh*f=comma12. sum*(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt )*f=dollar24. / nocellmerge misstext='0';
table type all, sum*hh*f=comma12. sum*(dda_amt_feb mms_amt_feb sav_amt_feb tda_amt_feb ira_amt_feb mtg_amt_feb heq_amt_feb iln_amt_feb )*f=dollar24. / nocellmerge misstext='0';
format products prods_nov prods. distance distfmt.;
run;


proc tabulate data=hudson.hudson_feb missing order=data;
where drop1 ne 1;
class type segment_feb / preloadfmt ;
var hh dda: mms: sav: tda: ira: heq: mtg: iln: ;
table type all, (segment_feb)*f=comma12. rowpctN*(segment_feb)*f=pctfmt. / nocellmerge misstext='0';
run;

data bals_a;
set hudson.hudson_feb;
keep dda: mms: sav: tda: ira: mtg: heq: iln: type ;
run;


data bals_a;
set bals_a;
	if not dda1 then dda_amt = .;
	if not mms1 then mms_amt = .;
	if not sav1 then sav_amt = .;
	if not tda1 then tda_amt = .;
	if not ira1 then ira_amt = .;
	if not mtg1 then mtg_amt = .;
	if not heq1 then heq_amt = .;
	if not iln1 then iln_amt = .;

	if not dda_feb then dda_amt_feb = .;
	if not mms_feb then mms_amt_feb = .;
	if not sav_feb then sav_amt_feb = .;
	if not tda_feb then tda_amt_feb = .;
	if not ira_feb then ira_amt_feb = .;
	if not mtg_feb then mtg_amt_feb = .;
	if not heq_feb then heq_amt_feb = .;
	if not iln_feb then iln_amt_feb = .;

run;


proc tabulate data =bals_a;
class type ;
var dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt dda_amt_feb mms_amt_feb sav_amt_feb tda_amt_feb ira_amt_feb mtg_amt_feb heq_amt_feb iln_amt_feb;
table (N q1 qrange median mean),(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt)*(type) / nocellmerge ;
table (n q1 qrange median mean),(dda_amt_feb mms_amt_feb sav_amt_feb tda_amt_feb ira_amt_feb mtg_amt_feb heq_amt_feb iln_amt_feb)*(type) / nocellmerge ;
run;

proc freq data=hudson.hudson_feb;
table type*(products prods_nov);
run;


proc tabulate data=hudson.hudson_feb;
class type;
var products prods_nov;
table type, (N q1 qrange median mean)*(products ) / nocellmerge;
table type, (N q1 qrange median mean)*( prods_nov) / nocellmerge;
run;




proc means data=hudson.hudson_feb min q1 mean median q3 max ;
class type;
var dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt;
run;

proc means data=hudson.hudson_feb min q1 mean median q3 max ;
class type;
var dda_amt_feb mms_amt_feb sav_amt_feb tda_amt_feb ira_amt_feb mtg_amt_feb heq_amt_feb iln_amt_feb;
run;

data hudson.hudson_feb;
set hudson.hudson_feb;
prods_chart = products;
if type eq 'attrited' then prods_chart = prods_nov;
run;

proc sort data=hudson.hudson_feb;
by type;
run;


proc template;
     define style mtbnew1;
     parent=styles.printer;
	 style graphdatadefault  / color=cx007856 contrastcolor=black;
     style graphdata1 from graphdata1 / color=cx7AB800 contrastcolor=black;
     style graphdata2 from graphdata2 / color=cxFFB300 contrastcolor=black;
	 style graphdata3 from graphdata3 / color=cx86499D contrastcolor=black;
	 style graphdata4 from graphdata4 / color=cx003359 contrastcolor=black;
	 style graphdata5 from graphdata5 / color=cx7AB800 contrastcolor=black;
	 style graphdata6 from graphdata6 / color=cx23A491 contrastcolor=black;
	 style graphdata7 from graphdata7 / color=cx144629 contrastcolor=black;
	 style graphdata8 from graphdata8 / color=cx144629 contrastcolor=black;

	 style fonts /
      'TitleFont2' = ('Arial, Helvetica, Helv',12pt,bold italic)
      'TitleFont' = ('Arial, Helvetica, Helv',13pt,bold italic)
      'StrongFont' = ('Arial, Helvetica, Helv',10pt,bold)
      'EmphasisFont' = ('Arial, Helvetica, Helv',10pt,italic)
      'FixedEmphasisFont' = ('Arial, Helvetica, Helv',9pt,italic)
      'FixedStrongFont' = ('Arial, Helvetica, Helv',9pt,bold)
      'FixedHeadingFont' = ('Arial, Helvetica, Helv',9pt,bold)
      'BatchFixedFont' = ("SAS Monospace, <MTmonospace>, Courier",6.7pt)
      'FixedFont' = ('Arial, Helvetica, Helv',9pt)
      'headingEmphasisFont' = ('Arial, Helvetica, Helv',11pt,bold italic)
      'headingFont' = ('Arial, Helvetica, Helv',11pt,bold)
      'docFont' = ('Arial, Helvetica, Helv',10pt);
   style GraphFonts /
      'GraphDataFont' = ('Arial, Helvetica, Helv',7pt)
      'GraphUnicodeFont' = ('Arial, Helvetica, Helv',9pt)
      'GraphValueFont' = ('Arial, Helvetica, Helv',9pt)
      'GraphLabel2Font' = ('Arial, Helvetica, Helv',10pt)
      'GraphLabelFont' = ('Arial, Helvetica, Helv',10pt)
      'GraphFootnoteFont' = ('Arial, Helvetica, Helv',10pt)
      'GraphTitleFont' = ('Arial, Helvetica, Helv',11pt,bold)
      'GraphTitle1Font' = ('Arial, Helvetica, Helv',14pt,bold)
      'GraphAnnoFont' = ('Arial, Helvetica, Helv',10pt);


	 style header  from header / background=cx007856 foreground=white;
	 style ProcTitle from proctitle / foreground=cx007856 ;
	 style SystemTitle from systemtitle / foreground=cx007856 ;
     
	end;
   run;

   Title '';
ods html style=mtbnew1;
proc sgplot data=hudson.hudson_feb noautolegend;
vbox prods_chart / group=type;
yaxis min=0 max = 8 label="Number of Products" LABELATTRS=(Weight=BOLD);
xaxis label="Type of Household" LABELATTRS=(Weight=BOLD);
keylegend "Attrited" "New" "Retained";
run;


data hudson.hudson_feb;
set hudson.hudson_feb;
if type = 'attrite' then prods_attr = prods_chart;
if type = 'new' then prods_new = prods_chart;
if type = 'retained' then prods_ret = prods_chart;
run;

proc template;
define statgraph multhist;
   begingraph;
   layout overlay / xaxisopts=(label="Number of Products");
      /** first plot: a histogram **/
      histogram prods_attr / name="Attrited"
          binwidth=1 fillattrs=(color=cx7AB800); 
      /** second plot: a semi-transparent histogram **/
      histogram prods_new / name="Acquired"
          binwidth=1 datatransparency=0.7
          fillattrs=(color=cxFFB300);
	 histogram prods_ret / name="Retained"
          binwidth=1 datatransparency=0.7  fillattrs=(color=cx86499D);
   endlayout;
   endgraph;
end;
run;


proc sgrender data=hudson.hudson_feb template=multhist;
run;


   Title '';
ods html style=mtbnew1;
proc sgpanel data=hudson.hudson_feb noautolegend;
panelby type / columns=1;
histogram prods_chart / binwidth=1 nbins=8;
colaxis  label="Number of Products" LABELATTRS=(Weight=BOLD);
/*xaxis label="Type of Household" LABELATTRS=(Weight=BOLD);*/
run;

