data data.main_201203;
length tran_group_12 $ 1;
set data.main_201203;
select;
	when (tran_segment in ('ATM Dominant' 'Online Dominant' 'Phone Dominant' 'Multi - Low Branch')) tran_group_12 = 'V';
	when (tran_segment in ('Inactive')) tran_group_12 = 'I';
	when (tran_segment in ('Multi - Med Branch' 'Multi - High Branch' 'Branch Dominant')) tran_group_12 = 'B';
	when (tran_segment eq '' ) tran_group_12 = 'X';
end;
run;


proc freq data=data.main_201203;
table tran_group_12*tran_segment / missing;
run;


data data.main_201203;
merge data.main_201203 (in=a) virtual.points_2009 (in=b keep=hhid segment rename=(segment=tran_segment_09) );
by hhid;
select;
	when (tran_segment_09 in ('ATM Dominant' 'Online Dominant' 'Phone Dominant' 'Multi - Low Branch')) tran_group_09 = 'V';
	when (tran_segment_09 in ('Inactive')) tran_group_09 = 'I';
	when (tran_segment_09 in ('Multi - Med Branch' 'Multi - High Branch' 'Branch Dominant')) tran_group_09 = 'B';
	when (tran_segment_09 eq '' ) tran_group_09 = 'X';
end;
run;

proc freq data=data.main_201203;
table tran_segment_09*tran_segment / missing nocol norow nopercent;
run;

data data.main_201203;
set data.main_201203;
delta_group = '';
select ;
	when (tran_group_09 eq tran_group_12 and tran_group_09 in ('V' 'B' 'I')) delta_group = 'EQ';
	when (tran_group_09 in ('I' 'V') and tran_group_12 eq 'B') delta_group = '2B';
	when (tran_group_09 in ('I' 'B') and tran_group_12 eq 'V') delta_group = '2V';
	when (tran_group_09 in ('V' 'B') and tran_group_12 eq 'I') delta_group = '2I';
	when (tran_group_09 eq 'X' or tran_group_12 eq 'X') delta_group = 'XX';
	otherwise delta_group = 'chec';
end;
run;

proc freq data=data.main_201203;
table delta_group / missing ;
run;
	

data temp_raw;
	merge data.main_201203 (in=a where=(tran_group_12 in ('V' 'B' 'I')) 
	                        keep=hhid segment tran_segment tran_group_12 tran_group_09 delta_group tran_segment_09 cbr market band rm 
                                 hh dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb  
                                 dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt)
          data.contrib_201203 (in=b drop=cbr market zip branch state band band_yr);
	by hhid;
	if a;
run;

proc contents data=temp_raw varnum short;
run;

proc tabulate data=temp_raw missing;
	class tran_group_12;
    var hh dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb 
         dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt
         DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON SEC_CON TRS_CON mtg_con heq_con card_con ILN_CON SLN_CON IND_con;
	table    (hh='Total' dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb)*(sum='HHs'*f=comma12.) 
                            (dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb)*(pctsum<hh>='Penetration'*f=comma12.2)
                            (dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt)*(sum='Balances'*f=dollar24. ) 
							(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt)*(mean='Bal per Tot HH'*f=dollar24.)
							(DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON  mtg_con heq_con  ILN_CON  IND_con card_con SLN_CON SEC_CON TRS_CON)*(sum='Contrib'*f=dollar24.)
							(DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON  mtg_con heq_con  ILN_CON  IND_con card_con SLN_CON SEC_CON TRS_CON)*(mean='Cont per Tot HH'*f=dollar12.2)
							,tran_group_12 ALL/ nocellmerge ;
	format segment segfmt.;
run;


*compare 2009 to 2012;

proc sql;
select count(hhid) from data.main_201203 where tran_group_12 = 'V' and tran_group_09 = 'B';
quit;

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\2009CON.TXT';

data data.Contrib_200912;
length HHID $ 9 STATE $ 2 ZIP $ 5;
infile myfile DLM='09'x firstobs=2 lrecl=4096 dsd;
	  INPUT hhID $
		STATE $ 
         ZIP $                                                  
         BRANCH $                                           
         CBR                                     
         MARKET  
		 DDA_CON
		 MMS_CON
		 SAV_CON
		 TDA_CON
		 IRA_CON
		 SEC_CON
		 TRS_CON
		 mtg_con
		 heq_con
		 card_con
		 ILN_CON
		 SLN_CON
		 band $
		 band_yr $
		 IND_con;
run;


filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\2009prod.TXT';
data data.Main_200912;
length HHID $ 9 STATE $ 2 ZIP $ 5 RM $ 1;
infile myfile DLM='09'x firstobs=2 lrecl=4096 dsd;

	  INPUT hhID $                                                         
         STATE $ 
         ZIP $                                                  
         BRANCH $                                           
         CBR                                     
         MARKET 
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
         DDA_Amt                                                    
         MMS_amt                                                      
         sav_amt                                                       
         TDA_Amt                                                 
         IRA_amt                                         
         sec_Amt                                              
         trs_amt                                              
         MTG_amt                                                  
         HEQ_Amt                                               
         ccs_Amt                                               
         iln_amt                                                      
         sln_amt                                                  
		 IND
		 IND_AMT;
		 hh=1;
		 if iln_amt eq . then iln_amt = 0;
		 if ind_amt eq . then ind_amt = 0;
run;



data compare_201203 bad_201203;
merge data.main_201203 (in=a  
                        keep=hhid tran_segment dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb
						     dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt 
                             hh tran_group_12 tran_group_09 segment)
	  data.contrib_201203 (in=b);
by hhid;
if a and b then output compare_201203;
if a and not b then output bad_201203;
run;

data compare_200912 ;
merge data.main_200912 (in=b)
	  data.contrib_200912 (in=c);
by hhid;
if b;
run;


proc tabulate data=compare_201203 missing;
    var hh dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb 
         dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt
         DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON SEC_CON TRS_CON mtg_con heq_con card_con ILN_CON SLN_CON IND_con;
	table    (hh='Total' dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb)*(sum='HHs'*f=comma12.) 
                            (dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb)*(pctsum<hh>='Penetration'*f=comma12.2)
                            (dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt)*(sum='Balances'*f=dollar24. ) 
							(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt)*(mean='Bal per Tot HH'*f=dollar24.)
							(DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON  mtg_con heq_con  ILN_CON  IND_con card_con SLN_CON SEC_CON TRS_CON)*(sum='Contrib'*f=dollar24.)
							(DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON  mtg_con heq_con  ILN_CON  IND_con card_con SLN_CON SEC_CON TRS_CON)*(mean='Cont per Tot HH'*f=dollar12.2)
							,ALL / nocellmerge ;
	format segment segfmt.;
run;

proc tabulate data=compare_200912 missing;
    var hh dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb 
         dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt
         DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON SEC_CON TRS_CON mtg_con heq_con card_con ILN_CON SLN_CON IND_con;
	table    (hh='Total' dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb)*(sum='HHs'*f=comma12.) 
                            (dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb)*(pctsum<hh>='Penetration'*f=comma12.2)
                            (dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt)*(sum='Balances'*f=dollar24. ) 
							(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt)*(mean='Bal per Tot HH'*f=dollar24.)
							(DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON  mtg_con heq_con  ILN_CON  IND_con card_con SLN_CON SEC_CON TRS_CON)*(sum='Contrib'*f=dollar24.)
							(DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON  mtg_con heq_con  ILN_CON  IND_con card_con SLN_CON SEC_CON TRS_CON)*(mean='Cont per Tot HH'*f=dollar12.2)
							,ALL / nocellmerge ;
	format segment segfmt.;
run;


*do checking detail;
proc freq data=data.contrib_201203;
table grp_a;
run;

proc contents data=data.contrib_201203 varnuym short;
run;


proc tabulate data=data.contrib_201203 missing ;
/*where grp_a in ('BB' 'VV' 'BV' 'VB');*/
class tran_group_09 tran_group_12;
var billpay atm interchange nii maintenance pos nsf balance ;
table  tran_group_09*tran_group_12, N*f=comma12. (billpay atm interchange nii maintenance pos nsf balance )*sum*f=dollar24.  / nocellmerge;
run;

proc tabulate data=data.main_201203 missing;
where tran_group_12 ne '';
class tran_group_09 tran_group_12;
var vpos: mpos: atmt: atmo:  ;
table  tran_group_09*tran_group_12, N*f=comma12. (vpos: mpos: atmt: atmo: )*sum*f=comma24.  / nocellmerge;
run;


proc tabulate data=data.contrib_200912 missing;
where tran_group_12 ne '' and tran_group_09 ne '';
class tran_group_09 tran_group_12;
var billpay atm interchange nii maintenance pos nsf balance vpos: mpos: atmt: atmo: ;
table  tran_group_09*tran_group_12, N*f=comma12. (billpay atm interchange nii maintenance pos nsf balance )*sum*f=dollar24. 
       (vpos: mpos: atmt: atmo: )*sum*f=comma24.  / nocellmerge;
run;


*detail analysis 2009 to 2012 by group;

proc tabulate data=compare_201203 missing;
where tran_group_12 ne '';
var hh dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb 
         dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt
         DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON SEC_CON TRS_CON mtg_con heq_con card_con ILN_CON SLN_CON IND_con;
class  tran_group_09 tran_group_12   ;
	table   tran_group_09*tran_group_12, (hh='Total' dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb)*(sum='HHs'*f=comma12.) 
                            (dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb)*(pctsum<hh>='Penetration'*f=comma12.2)
                            (dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt)*(sum='Balances'*f=dollar24. ) 
							(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt)*(mean='Bal per Tot HH'*f=dollar24.)
							(DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON  mtg_con heq_con  ILN_CON  IND_con card_con SLN_CON SEC_CON TRS_CON)*(sum='Contrib'*f=dollar24.)
							(DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON  mtg_con heq_con  ILN_CON  IND_con card_con SLN_CON SEC_CON TRS_CON)*(mean='Cont per Tot HH'*f=dollar12.2)
							 / nocellmerge ;
	format segment segfmt.;
run;

proc tabulate data=compare_200912 missing;
where tran_group_12 ne '' and tran_group_09 ne '';
var hh dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb 
         dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt
         DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON SEC_CON TRS_CON mtg_con heq_con card_con ILN_CON SLN_CON IND_con;
class  tran_group_09 tran_group_12   ;
	table   tran_group_09*tran_group_12, (hh='Total' dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb)*(sum='HHs'*f=comma12.) 
                            (dda mms sav tda ira mtg heq iln ind card sln sec ins trs sdb)*(pctsum<hh>='Penetration'*f=comma12.2)
                            (dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt)*(sum='Balances'*f=dollar24. ) 
							(dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ind_amt ccs_amt sln_amt sec_amt trs_amt)*(mean='Bal per Tot HH'*f=dollar24.)
							(DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON  mtg_con heq_con  ILN_CON  IND_con card_con SLN_CON SEC_CON TRS_CON)*(sum='Contrib'*f=dollar24.)
							(DDA_CON MMS_CON SAV_CON TDA_CON IRA_CON  mtg_con heq_con  ILN_CON  IND_con card_con SLN_CON SEC_CON TRS_CON)*(mean='Cont per Tot HH'*f=dollar12.2)
							 / nocellmerge ;
	format segment segfmt.;
run;


proc tabulate data=compare_201203 missing;
where tran_group_12 ne '';
var hh ;
class  tran_group_09 tran_group_12  segment ;
table tran_group_09*tran_group_12, segment;
format segment segfmt.;
run;

proc tabulate data=compare_200912 ;
where tran_group_12 ne '' and tran_group_09 ne '' and nsf gt 0;
var nsf ;
class  tran_group_09 tran_group_12   ;
table tran_group_09*tran_group_12, N nsf*(N sum);
run;

proc tabulate data=compare_200912 ;
where tran_group_12 ne '' and tran_group_09 ne '' ;
var nsf ;
class  tran_group_09 tran_group_12   ;
table tran_group_09*tran_group_12, N ;
run;

*where did the v-> B go;

proc freq data=compare_201203 ;
where tran_group_12 eq 'B' and tran_group_09 eq 'V';
table tran_segment;
run;
