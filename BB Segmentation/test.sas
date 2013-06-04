PROC EXPORT DATA= BBSEG.Frequency_tables 
            OUTFILE= "C:\Documents and Settings\ewnym5s\My Documents\BB 
Segmentation\Balance Distributions by Product.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
