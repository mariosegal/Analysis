proc freq data=data.main_201111;
table virtual_seg*tran_segm / missing;
run;


proc tabulate data=virtual.points_2011;
var phone Branch Online ATM total;
class segment;
table segment, (phone Branch Online ATM total)*mean='Average'*f=comma10.1;
run;



proc contents data=temp.merged varnum short; run;


data temp.contr;
set data.contrib_201111;
contrib = sum (DDA_CON ,MMS_CON ,SAV_CON, TDA_CON ,IRA_CON ,SEC_CON ,TRS_CON ,mtg_con ,heq_con, card_con ,ILN_CON ,SLN_CON ,IND_con);
keep contrib hhid band band_yr;
run;

data temp.prods;
set data.main_201111;
keep hhid dda mms sav tda ira sec trs mtg heq card ILN sln sdb ins bus com DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt 
     HEQ_Amt ccs_Amt iln_amt sln_amt  IND Ind_AMT virtual_seg;
run;

data temp.merged;
merge temp.prods (in=a) temp.contr (in=b);
by hhid;
if a and b;
run;

data temp.merged;
set temp.merged;
hh =1;
run;

proc format;
value contband low-0 = 'Negative'
               0<-10 = 'Up to $10'
			   10<-20 = '$10 to $20'
			   20<-30 = '$20 to $30'
			   30<-40 = '$30 to $40'
			   40<-50 = '$40 to $50'
			   50<-60 = '$50 to $60'
			   60<-70 = '$60 to $70'
			   70<-80 = '$70 to $80'
			   80<-90 = '$80 to $90'
			   90<-100 = '$90 to $100'
			   100<-125 = '$100 to $110'
			   125<-150 = '$125 to $150'
			   150<-200 = '$150 to $200'
			   200<-high = 'Over $200';
run;


proc tabulate data=temp.merged;
where virtual_seg = 'Inac';
var hh aux dda mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins  DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt  ;
class virtual_seg contrib;
table (hh)*sum='HHs'*f=comma12.0  aux*mean='Avg. Contrib'*f=dollar10.2 (dda mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins)*sum='Prod HHs'*f=comma12.0
      (dda mms sav tda ira sec trs mtg heq card ILN ind sln sdb ins)*pctsum<hh>='Prod Penet.'*f=comma8.2
      (DDA_Amt MMS_amt sav_amt TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt ind_amt sln_amt)*sum='Total Balances'*f=dollar12.
      , (virtual_seg ALL)*(contrib ALL) ALL ;
format contrib contband.;
run;

proc sort data=temp.merged;
by virtual_seg;
run;


data temp;
set temp.merged;
keep virtual_seg hhid sec_amt;
format sec_amt dollar18.0;
run;



ods select ExtremeObs;
proc univariate data=temp nextrobs=10;
var sec_amt ;
class virtual_seg;
run;


PROC TEMPLATE;                               
  EDIT Base.Freq.OneWayList;                 
    EDIT Frequency;                          
      FORMAT = COMMA18.;                      
    END;                                     
    EDIT CumFrequency;                       
      FORMAT = COMMA6.;                      
    END;                                     
    EDIT Percent;                            
      FORMAT = 5.1;                          
    END;                                     
    EDIT CumPercent;                         
      FORMAT = 5.1;                          
    END;                                     
  END;                                       
RUN;    

proc freq data=temp.merged;
table virtual_seg;
format _FREQ_ comma12.0;
run;


options nodate pageno=1 pagesize=60 linesize=72;
proc template;
path sashelp.tmplmst;
list base.univariate / sort=path descending;
run;

proc template;
  source packages.default;
  run;

PROC TEMPLATE;                               
  EDIT  Base.Univariate.ExtObs;                 
    EDIT LowIdNum;                          
      FORMAT = COMMA18.;                      
    END;                                     
    EDIT HighIDNUm;                       
      FORMAT = COMMA18.;                      
    END;                                     
    EDIT Low;                            
      FORMAT = comma18.0;                          
    END;                                     
    EDIT High;                         
      FORMAT = comma18.0;                          
    END;                                     
  END;                                       
RUN;    
