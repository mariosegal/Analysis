PROC EXPORT DATA= WORK.Results_trans_mgd 
            OUTFILE= "C:\Documents and Settings\ewnym5s\My Documents\BB 
Segmentation\tran_mgd.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
