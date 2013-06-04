filename mprint "C:\Documents and Settings\ewnym5s\My Documents\SAS\tran_code analysis.sas" ;
data _null_ ; file mprint ; run ;
options mprint mfile nomlogic ;

%profile2 (classvars= tran_code,period = 201212, data_library = data,condition = dda eq 1, name=tran_code_analysis)
;


*now use tran3 to create some charts;
ods html style=mtbnew;
ods graphics on / height=5in width=7.5in;
proc sgplot data=tran3;
vbar transaction / response=enrolled_pct group=tran_code groupdisplay=cluster datalabel=enrolled_pct ;
xaxis label="Transaction Type"
format enrolled_pct percent6.1;
run;


* that was not the data we needed, more granular;

*read it;

data virtual.trans_detail;
length hhid $ 9  ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\trans.txt' dsd dlm='09'x lrecl=4096 firstobs=2 obs=max;
input hhid $ LOBBY_SVG_WITH LOBBY_LOC_ADV LOBBY_DEP_NO_CSH LOBBY_DEP_CSH_BK DRV_SVG_WITH DRV_DEPNO_CSH DRV_DEP_CSH_BK NIGHT_DEP_NO_CSH NIGHT_DEP_WITH_CSH HE_CHKS LOCKBOX_PMT;
if hhid eq '' then delete;
run;

proc summary data=virtual.trans_detail;
by hhid;
output out=virtual.trans_detail 
       sum(LOBBY_SVG_WITH LOBBY_LOC_ADV LOBBY_DEP_NO_CSH LOBBY_DEP_CSH_BK DRV_SVG_WITH DRV_DEPNO_CSH DRV_DEP_CSH_BK NIGHT_DEP_NO_CSH NIGHT_DEP_WITH_CSH HE_CHKS LOCKBOX_PMT)=
	   LOBBY_SVG_WITH LOBBY_LOC_ADV LOBBY_DEP_NO_CSH LOBBY_DEP_CSH_BK DRV_SVG_WITH DRV_DEPNO_CSH DRV_DEP_CSH_BK NIGHT_DEP_NO_CSH NIGHT_DEP_WITH_CSH HE_CHKS LOCKBOX_PMT;
run;

 OPTIONS COMPRESS = YES;
data virtual.trans_detail_201212;
merge virtual.trans_detail(in=a) data.main_201212 (in=b KEEP = HHID TRAN_CODE);
by hhid;
if a and b;
run;

proc tabulate data=virtual.trans_detail_201212;
class LOBBY_SVG_WITH LOBBY_LOC_ADV LOBBY_DEP_NO_CSH LOBBY_DEP_CSH_BK DRV_SVG_WITH DRV_DEPNO_CSH DRV_DEP_CSH_BK NIGHT_DEP_NO_CSH NIGHT_DEP_WITH_CSH HE_CHKS LOCKBOX_PMT;
class tran_code;
table (LOBBY_SVG_WITH='Lobby Savgs Withd' LOBBY_LOC_ADV='Lobby LOC Advances' LOBBY_DEP_NO_CSH='Lobby Depos no Cash Back' LOBBY_DEP_CSH_BK ='Lobby Depos w Cash Back'
       DRV_SVG_WITH='Drive in Depos Savgs Withd' DRV_DEPNO_CSH='Drive in Depos no Cash Back' DRV_DEP_CSH_BK='Drive in Depos w Cash Back' 
       NIGHT_DEP_NO_CSH='Night Depos no Cash Back' NIGHT_DEP_WITH_CSH='Night Depos w Cash Back' ),
      (tran_code All)*rowpctN='Percent'*f=pctfmt.;
format tran_code $transegm. 
       LOBBY_SVG_WITH LOBBY_LOC_ADV LOBBY_DEP_NO_CSH LOBBY_DEP_CSH_BK DRV_SVG_WITH DRV_DEPNO_CSH DRV_DEP_CSH_BK NIGHT_DEP_NO_CSH NIGHT_DEP_WITH_CSH HE_CHKS LOCKBOX_PMT trans.;
run;

data age;
length hhid $ 9  ;
infile 'C:\Documents and Settings\ewnym5s\My Documents\age.txt' dsd dlm='09'x lrecl=4096 firstobs=1 obs=max;
input hhid $ age;
if hhid eq '' then delete;
run;

data virtual.trans_detail_201212;
merge virtual.trans_detail_201212 (in=a) age (in=b );
by hhid;
if a and b;
run;

proc format ;
value quick low-high = [ageband.]
            . = 'Unknown';
run;


proc tabulate data=virtual.trans_detail_201212;
class LOBBY_SVG_WITH LOBBY_LOC_ADV LOBBY_DEP_NO_CSH LOBBY_DEP_CSH_BK DRV_SVG_WITH DRV_DEPNO_CSH DRV_DEP_CSH_BK NIGHT_DEP_NO_CSH NIGHT_DEP_WITH_CSH HE_CHKS LOCKBOX_PMT;
class age;
table (LOBBY_SVG_WITH='Lobby Savgs Withd' LOBBY_LOC_ADV='Lobby LOC Advances' LOBBY_DEP_NO_CSH='Lobby Depos no Cash Back' LOBBY_DEP_CSH_BK ='Lobby Depos w Cash Back'
       DRV_SVG_WITH='Drive in Depos Savgs Withd' DRV_DEPNO_CSH='Drive in Depos no Cash Back' DRV_DEP_CSH_BK='Drive in Depos w Cash Back' 
       NIGHT_DEP_NO_CSH='Night Depos no Cash Back' NIGHT_DEP_WITH_CSH='Night Depos w Cash Back' ),
      (age All)*N='Count'*f=comma12.;
format age quick. 
       LOBBY_SVG_WITH LOBBY_LOC_ADV LOBBY_DEP_NO_CSH LOBBY_DEP_CSH_BK DRV_SVG_WITH DRV_DEPNO_CSH DRV_DEP_CSH_BK NIGHT_DEP_NO_CSH NIGHT_DEP_WITH_CSH HE_CHKS LOCKBOX_PMT trans.;
run;

proc tabulate data=virtual.trans_detail_201212;
var LOBBY_SVG_WITH LOBBY_LOC_ADV LOBBY_DEP_NO_CSH LOBBY_DEP_CSH_BK DRV_SVG_WITH DRV_DEPNO_CSH DRV_DEP_CSH_BK NIGHT_DEP_NO_CSH NIGHT_DEP_WITH_CSH HE_CHKS LOCKBOX_PMT;
class age;
table (LOBBY_SVG_WITH='Lobby Savgs Withd' LOBBY_LOC_ADV='Lobby LOC Advances' LOBBY_DEP_NO_CSH='Lobby Depos no Cash Back' LOBBY_DEP_CSH_BK ='Lobby Depos w Cash Back'
       DRV_SVG_WITH='Drive in Depos Savgs Withd' DRV_DEPNO_CSH='Drive in Depos no Cash Back' DRV_DEP_CSH_BK='Drive in Depos w Cash Back' 
       NIGHT_DEP_NO_CSH='Night Depos no Cash Back' NIGHT_DEP_WITH_CSH='Night Depos w Cash Back' )*sum*f=comma12.,
      (age All);
format age quick. 
       LOBBY_SVG_WITH LOBBY_LOC_ADV LOBBY_DEP_NO_CSH LOBBY_DEP_CSH_BK DRV_SVG_WITH DRV_DEPNO_CSH DRV_DEP_CSH_BK NIGHT_DEP_NO_CSH NIGHT_DEP_WITH_CSH HE_CHKS LOCKBOX_PMT trans.;
run;
