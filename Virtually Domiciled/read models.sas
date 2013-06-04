data virtual.models_20130220 (compress=binary);
length hhid $ 9;
infile 'C:\Documents and Settings\ewnym5s\My Documents\scoreFile_20130220.txt' lrecl=495 ;
   input @1   hhidentifier      1-15 
                @16  mmaScore          16-25                /*  MMA Score Value */
                @26  securityScore     26-35                /* Securities Score Value */
                @36  instLoanScore     36-45                /* Installment Loan Score Value */
               
                @46  mmDeltaCondEv_Branch    f10.2          /* Channel Adjusted CLV - MMA/Branch */
                @61  mmDeltaCondEv_online    f10.2          /* Channel Adjusted CLV - MMA/Online */
                @76  mmDeltaCondEv_phone     f10.2          /* Channel Adjusted CLV - MMA/Phone */
                @91  mmDeltaCondEv_atm       f10.2          /* Channel Adjusted CLV - MMA/ATM */
                @106 mmDeltaCondEv_mobile    f10.2          /* Channel Adjusted CLV - MMA/Mobile */
                
                @121 secDeltaCondEv_Branch   f10.2          /* Channel Adjusted CLV - Securities/Branch */
                @136 secDeltaCondEv_online   f10.2          /* Channel Adjusted CLV - Securities/Online */
                @151 secDeltaCondEv_phone    f10.2          /* Channel Adjusted CLV - Securities/Phone */
                @166 secDeltaCondEv_atm      f10.2          /* Channel Adjusted CLV - Securities/ATM */
                @181 secDeltaCondEv_mobile   f10.2          /* Channel Adjusted CLV - Securities/Mobile */
                
                @196 ilnDeltaCondEv_Branch   f10.2          /* Channel Adjusted CLV - Installment Loan/Branch */
                @211 ilnDeltaCondEv_online   f10.2          /* Channel Adjusted CLV - Installment Loan/Online */
                @226 ilnDeltaCondEv_phone    f10.2          /* Channel Adjusted CLV - Installment Loan/Phone */
                @241 ilnDeltaCondEv_atm      f10.2          /* Channel Adjusted CLV - Installment Loan/ATM */
                @256 ilnDeltaCondEv_mobile   f10.2          /* Channel Adjusted CLV - Installment Loan/Mobile */
                
                @271 mmCondResp_Branch       f8.5           /* Channel Adjusted Response Rate - MMA/Branch */
                @286 mmCondResp_online       f8.5           /* Channel Adjusted Response Rate - MMA/Online */
                @301 mmCondResp_phone        f8.5           /* Channel Adjusted Response Rate - MMA/Phone */
                @316 mmCondResp_atm          f8.5           /* Channel Adjusted Response Rate - MMA/ATM */
                @331 mmCondResp_mobile       f8.5           /* Channel Adjusted Response Rate - MMA/Mobile */
                                        
                @346 secCondResp_Branch      f8.5           /* Channel Adjusted Response Rate - Securities/Branch */
                @361 secCondResp_online      f8.5           /* Channel Adjusted Response Rate - Securities/Online */
                @376 secCondResp_phone       f8.5           /* Channel Adjusted Response Rate - Securities/Phone */
                @391 secCondResp_atm         f8.5           /* Channel Adjusted Response Rate - Securities/ATM */
                @406 secCondResp_mobile      f8.5           /* Channel Adjusted Response Rate - Securities/Mobile */
                                        
                @421 ilnCondResp_Branch      f8.5           /* Channel Adjusted Response Rate - Installment Loan/Branch */
                @436 ilnCondResp_online      f8.5           /* Channel Adjusted Response Rate - Installment Loan/Online */
                @451 ilnCondResp_phone       f8.5           /* Channel Adjusted Response Rate - Installment Loan/Phone */
                @466 ilnCondResp_atm         f8.5           /* Channel Adjusted Response Rate - Installment Loan/ATM */
                @481 ilnCondResp_mobile      f8.5           /* Channel Adjusted Response Rate - Installment Loan/Mobile */
                ;
hhid = hhidentifier;
run;


data virtual.models_20130220 (compress=binary);
set virtual.models_20130220 ;
run;

proc contents data=virtual.models_20130220 varnum short;
run;

proc means data=virtual.models_20130220;
var mmaScore securityScore instLoanScore mmDeltaCondEv_Branch mmDeltaCondEv_online mmDeltaCondEv_phone mmDeltaCondEv_atm mmDeltaCondEv_mobile 
    secDeltaCondEv_Branch secDeltaCondEv_online secDeltaCondEv_phone secDeltaCondEv_atm secDeltaCondEv_mobile ilnDeltaCondEv_Branch ilnDeltaCondEv_online 
     ilnDeltaCondEv_phone ilnDeltaCondEv_atm ilnDeltaCondEv_mobile mmCondResp_Branch mmCondResp_online mmCondResp_phone mmCondResp_atm mmCondResp_mobile 
     secCondResp_Branch secCondResp_online secCondResp_phone secCondResp_atm secCondResp_mobile ilnCondResp_Branch ilnCondResp_online ilnCondResp_phone 
     ilnCondResp_atm ilnCondResp_mobile;
run;


proc transpose data=virtual.models_20130220 out=chart;
by hhid;
var mmaScore securityScore instLoanScore;
run;


proc sgplot data=virtual.models_20130220;
vbox mmaScore;
yaxis max=250;
run;

 proc sgplot data=virtual.models_20130220;
vbox securityScore;
yaxis max=250;
run;

proc means data=virtual.models_20130220 p1 p10 q1 median q3 p90;
var mmascore;
run;


 proc sgplot data=virtual.models_20130220;
 where mmascore gt 45;
scatter y=mmascore x=mmDeltaCondEv_Branch;
/*yaxis max=250;*/
run;
quit;

proc rank data=virtual.models_20130220 (keep=hhid mmascore mm:) out=mms groups=10;
var mmascore;
ranks mma_rank;
run;

/*proc format ;*/
/*value bands (notsorted) */
/*      low-<0 = 'Negative'*/
/*	  0-<5 = 'Up to $5'*/
/*	  5<-10 = '$5 to 10'*/
/*	  10<-20 = '$10 to 20'*/
/*	  20<-50 = '$20 to 50'*/
/*	  50<-high = 'Over $50';*/
/*run;*/


/*proc sgpanel data=mms;*/
/*panelby mma_rank / columns=3 onepanel novarname;*/
/*histogram mmDeltaCondEv_Branch /scale=percent;*/
/*format mmDeltaCondEv_Branch dollar8.2;*/
/*run;*/

proc sort data=mms;
by hhid ;
run;


proc sgplot data=mms;
where mma_rank >= 7;
histogram mmDeltaCondEv_Branch /  scale=count;
format mmDeltaCondEv_Branch dollar8.2;
run;

data attr1;
retain id  'id1';
input value $ markercolor $;
datalines;
Top cx007856
Second cxffb300
;
run;




proc freq data=mms;
table mma_rank;
run;

proc format ;
value decile 9 = 'Top'
             8 = 'Second';
run;

proc sgplot data=mms dattrmap=attr1;
where mma_rank >= 8;
scatter x=mmDeltaCondEv_Branch y=mmascore/  group=mma_rank attrid=id1 transparency=0.8 markerattrs=(symbol=CircleFilled);
format mmDeltaCondEv_Branch dollar8.2 mmascore comma12. mma_rank decile.;
yaxis max=1000 label="Propensity Score" labelattrs=(weight=bold);
xaxis label="Expected Change in CLV ($)" labelattrs=(weight=bold);
refline 0 / axis=X lineattrs=(color="red");
keylegend / title="Decile" titleattrs=(weight=bold);
run;

data mms;
length channel $ 8;
set mms;
EV= max(of mmdeltacondEV:);
if mmDeltaCondEv_Branch = EV then channel='Branch';
if mmDeltaCondEv_online = EV then channel='Web';
if mmDeltaCondEv_phone = EV then channel='Phone';
if mmDeltaCondEv_atm = EV then channel='ATM';
if mmDeltaCondEv_mobile = EV then channel='Mobile';
resp_mma = max(of mmcondresp:);
if mmcondresp_Branch = resp_mma then channel1='Branch';
if mmcondresp_online = resp_mma then channel1='Web';
if mmcondresp_phone = resp_mma then channel1='Phone';
if mmcondresp_atm = resp_mma then channel1='ATM';
if mmcondresp_mobile = resp_mma then channel1='Mobile';
run;

data attr2;
retain id  'id2';
input value $ markercolor $;
datalines;
Branch cx007856
Web cxC3E76F
Phone cxFFB300
ATM cx86499D
Mobile cx003359
;
run;


ods graphics on / width=8in height=5in border=off ;
proc sgplot data=mms dattrmap=attr2;
where mma_rank >= 8;
scatter x=EV y=mmascore/  group=channel attrid=id2 transparency=0.6 markerattrs=(symbol=CircleFilled);
format EV dollar8.2 mmascore comma12. ;
yaxis max=1000 label="Propensity Score" labelattrs=(weight=bold);
xaxis label="Expected Change in CLV ($)" labelattrs=(weight=bold);
refline 0 / axis=X lineattrs=(color="red");
keylegend / title="Top Channel" titleattrs=(weight=bold);
run;
quit;

proc rank data=virtual.models_20130220 (keep=hhid securityscore sec:) out=sec groups=10;
var securityscore;
ranks sec_rank;
run;

data sec;
length channel $ 8;
set sec;
EV= max(of secdeltacondEV:);
if secDeltaCondEv_Branch = EV then channel='Branch';
if secDeltaCondEv_online = EV then channel='Web';
if secDeltaCondEv_phone = EV then channel='Phone';
if secDeltaCondEv_atm = EV then channel='ATM';
if secDeltaCondEv_mobile = EV then channel='Mobile';
resp_sec = max(of seccondresp:);
if seccondresp_Branch = resp_sec then channel2='Branch';
if seccondresp_online = resp_sec then channel2='Web';
if seccondresp_phone = resp_sec then channel2='Phone';
if seccondresp_atm = resp_sec then channel2='ATM';
if seccondresp_mobile = resp_sec then channel2='Mobile';
run;

ods graphics on / width=8in height=5in border=off ;
proc sgplot data=sec dattrmap=attr2;
where sec_rank >= 8;
scatter x=EV y=securityscore/  group=channel attrid=id2 transparency=0.6 markerattrs=(symbol=CircleFilled);
format EV dollar8.2 securityscore comma12. ;
yaxis max=1000 label="Propensity Score" labelattrs=(weight=bold);
xaxis label="Expected Change in CLV ($)" labelattrs=(weight=bold);
refline 0 / axis=X lineattrs=(color="red");
keylegend / title="Top Channel" titleattrs=(weight=bold);
run;

proc rank data=virtual.models_20130220 (keep=hhid instloanscore iln:) out=iln groups=10;
var instloanscore;
ranks iln_rank;
run;

data iln;
length channel $ 8;
set iln;
EV= max(of ilndeltacondEV:);
if ilnDeltaCondEv_Branch = EV then channel='Branch';
if ilnDeltaCondEv_online = EV then channel='Web';
if ilnDeltaCondEv_phone = EV then channel='Phone';
if ilnDeltaCondEv_atm = EV then channel='ATM';
if ilnDeltaCondEv_mobile = EV then channel='Mobile';
resp_iln = max(of ilncondresp:);
if ilncondresp_Branch = resp_iln then channel3='Branch';
if ilncondresp_online = resp_iln then channel3='Web';
if ilncondresp_phone = resp_iln then channel3='Phone';
if ilncondresp_atm = resp_iln then channel3='ATM';
if ilncondresp_mobile = resp_iln then channel3='Mobile';
run;

ods graphics on / width=8in height=5in border=off ;
proc sgplot data=iln dattrmap=attr2;
where iln_rank >= 8;
scatter x=EV y=instloanscore/  group=channel attrid=id2 transparency=0.6 markerattrs=(symbol=CircleFilled);
format EV dollar8.2 instloanscore comma12. ;
yaxis max=1000 label="Propensity Score" labelattrs=(weight=bold);
xaxis label="Expected Change in CLV ($)" labelattrs=(weight=bold);
refline 0 / axis=X lineattrs=(color="red");
keylegend / title="Top Channel" titleattrs=(weight=bold);
run;

#How many;

Title "Securities Propensity";
proc tabulate data=sec;
class channel sec_rank;
table sec_rank="Decile" All ,N="HHs"*(channel="Best Channel" All)*f=comma12. 
                             rowpctN="Row Percent"*(channel="Best Channel" ALl)*f=pctfmt. 
							 colpctN="Column Percent"*(channel="Best Channel" ALL)*f=pctfmt./ nocellmerge;
run;


Title "Money Market Propensity";
proc tabulate data=mms;
class channel mma_rank;
table mma_rank="Decile" All ,N="HHs"*(channel="Best Channel" All)*f=comma12. 
                             rowpctN="Row Percent"*(channel="Best Channel" ALl)*f=pctfmt. 
							 colpctN="Column Percent"*(channel="Best Channel" ALL)*f=pctfmt./ nocellmerge;
run;

Title "Inst. Loan Propensity";
proc tabulate data=iln;
class channel iln_rank;
table iln_rank="Decile" All ,N="HHs"*(channel="Best Channel" All)*f=comma12. 
                             rowpctN="Row Percent"*(channel="Best Channel" ALl)*f=pctfmt. 
							 colpctN="Column Percent"*(channel="Best Channel" ALL)*f=pctfmt./ nocellmerge;
run;

data mms_sec;
merge mms (in=a) sec(in=b);
by hhid;
if a and b;
run;


Title "Money Market and Securities";
proc tabulate data=mms_sec;
class sec_rank mma_rank;
table sec_rank="Securities Decile" All ,N="HHs"*(mma_rank="Money Mkt Decile" All)*f=comma12. 
                             rowpctN="Row Percent"*(mma_rank="Money Mkt Decile" ALl)*f=pctfmt. 
							 colpctN="Column Percent"*(mma_rank="Money Mkt Decile" ALL)*f=pctfmt./ nocellmerge;
run;

data segments;
set data.main_201303;
keep hhid tran_code dda;
run;


data combined;
merge mms(in=a keep=hhid mmascore mma_rank channel: resp_: EV rename=(channel=channel_mma EV=EV_mma))
      sec(in=b keep=hhid securityscore sec_rank channel: resp_: EV rename=(channel=channel_sec EV=EV_sec))
	  iln(in=c keep=hhid instloanscore iln_rank channel: resp_: EV rename=(channel=channel_iln EV=EV_iln));
by hhid;
if a and b and c;
run;


data combined;
retain miss;
merge combined (in=a) segments(in=b) end=eof;
by hhid;
if a then output;
if a and not b then miss+1;
if eof then put 'WARNING: ' miss ' Records on combined had no segment record';
drop miss;
run;

Title 'Money Market Top 2 Deciles';
proc freq data=combined;
where mma_rank ge 8;
table tran_code*channel_mma / nocol norow nopercent missing;
format tran_code $transegm.;
run;

Title 'Securities Top 2 Deciles';
proc freq data=combined;
where sec_rank ge 8;
table tran_code*channel_sec / nocol norow nopercent missing;
format tran_code $transegm.;
run;

Title 'Inst. Loan Top 2 Deciles';
proc freq data=combined;
where iln_rank ge 8;
table tran_code*channel_iln / nocol norow nopercent missing;
format tran_code $transegm.;
run;

proc sgplot data=combined attrmap=attr1;
where mma_rank ge 8;
scatter x=tran_code y=channel_sec / group= sec_rank attrid = id1;
run;

proc format ;
value bands (notsorted) 
      low-<0 = 'Negative'
	  0-<1 = 'Up to $1'
	  1<-2 = '$1 to 2'
	   2<-3 = '$2 to 3'
	   3<-4 = '$3 to 4'
	  4-<5 = '$4 to $5'
	  5<-10 = '$5 to 10'
	  10<-20 = '$10 to 20'
	  20<-50 = '$20 to 50'
	  50<-high = 'Over $50';
run;

title ;

proc tabulate data=combined missing;
where mma_rank ge 8 ;
class Channel_mma tran_code ev_mma;
table Channel_mma all, ev_mma="Money Market"*n=''*f=COMMA12. / nocellmerge;
format tran_code $transegm. ev_mma bands. ;
run;

proc tabulate data=combined missing;
where sec_rank ge 8 ;
class Channel_sec tran_code ev_sec;
table Channel_sec all , ev_sec="Securities"*n=''*f=COMMA12. / nocellmerge;
format tran_code $transegm. ev_sec bands. ;
run;

proc tabulate data=combined missing;
where iln_rank ge 8 ;
class Channel_iln tran_code ev_iln;
table Channel_iln all, ev_iln="Inst. Loan"*n=''*f=COmma12. / nocellmerge;
format tran_code $transegm. ev_iln bands. ;
run;

proc means data=combined ;
where iln_rank ge 8 ;
var resp:;
run;

*#########################;

proc format;
value pcts 
low -<.001 = 'Less than 0.1%'
.001 -<.0025 = '0.1% to 0.25%'
.0025 -<.005 = '0.25% to 0.5%'
.005 -<.0075 = '0.5% to 0.75%'
.0075 -<.01 = '0.75% to 1%'
.01 -< .0125 = '1% to 1.25%'
.0125 - high = '1.25% and Higher';
run;



proc tabulate data=combined missing;
where mma_rank ge 8 ;
class Channel1 tran_code resp_mma;
table Channel1 all, resp_mma="Money Market"*n=''*f=COMMA12. / nocellmerge;
format tran_code $transegm. resp_mma pcts. ;
run;


proc tabulate data=combined missing;
where sec_rank ge 8 ;
class Channel2 tran_code resp_sec;
table Channel2 all, resp_sec="Securities"*n=''*f=COMMA12. / nocellmerge;
format tran_code $transegm. resp_sec pcts. ;
run;

proc tabulate data=combined missing;
where iln_rank ge 8 ;
class Channel3 tran_code resp_iln;
table Channel3 all, resp_iln="Inst. Loans"*n=''*f=COMMA12. / nocellmerge;
format tran_code $transegm. resp_iln pcts. ;
run;
