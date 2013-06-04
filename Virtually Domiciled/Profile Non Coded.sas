ODS PATH RESET;                              
ODS PATH (PREPEND) WORK.Templat(UPDATE) ;    
                                             
PROC TEMPLATE;                               
  EDIT Base.Freq.OneWayList;                 
    EDIT Frequency;                          
      FORMAT = COMMA12.;                      
    END;                                     
    EDIT CumFrequency;                       
      FORMAT = COMMA12.;                      
    END;                                     
    EDIT Percent;                            
      FORMAT = 5.1;                          
    END;                                     
    EDIT CumPercent;                         
      FORMAT = 5.1;                          
    END;                                     
  END;                                       
RUN;

proc freq data=data.main_201111;
table not_coded;
run;



%profile_analysis (condition=not_coded in ('Uncoded no Check','Uncoded w/Check'),Class1=not_coded,out_file=Non Coded,
                         out_dir=Virtually Domiciled,identifier=201111,
                         dir="C:\Documents and Settings\ewnym5s\My Documents\temp_sas_files", title='Non Coded', clean=1);



data wip.temp;
set wip.temp;
servs = sum(dda,mms,sav,tda,ira,sec,trs,mtg,heq,card,ILN,IND,sln,sdb,ins) ;
run;




proc tabulate data=wip.temp missing;
where not_coded in ('Uncoded no Check','Uncoded w/Check') and servs eq 1;
class not_coded;
var hh dda mms sav tda ira sec trs mtg heq card ILN sln sdb ins;
table not_coded, (hh dda mms sav tda ira sec trs ins mtg heq card ILN sln sdb)*sum*f=comma12. / nocellmerge;
run;

proc tabulate data=wip.temp missing;
where not_coded in ('Uncoded no Check','Uncoded w/Check');
class not_coded;
var hh dda mms sav tda ira sec trs mtg heq card ILN IND sln sdb ins;
table not_coded, (hh dda mms sav tda ira sec trs ins mtg heq card ILN sln sdb)*sum*f=comma12. / nocellmerge;
run;

filename outfile 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\tran_segmebts.txt';
data _NULL_;
file outfile dlm='09'x dsd;
set data.main_201111 (keep = hhid not_coded);
put hhid $ not_coded $;
run;

