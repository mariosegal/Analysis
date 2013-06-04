PROC EXPORT DATA= WORK.Results_prod_mgd 
            OUTFILE= "C:\Documents and Settings\ewnym5s\My Documents\BB 
Segmentation\a.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
