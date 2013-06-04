
data branch.atm_june;
infile 'C:\Documents and Settings\ewnym5s\My Documents\ATM\atm_detail.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input group $ internal external volume;
run;

symbol1 value=dot color=blue interpol=none ;
symbol2 value=dot color=green interpol=none ;
symbol3 value=dot color=purple interpol=none ;
symbol4 value=dot color=red interpol=none ;
symbol5 value=dot color=orange interpol=none ;

proc gplot data=branch.atm_june;
where group in ('STZ' 'BWI' 'NOC' 'GGP' 'RUT');
plot volume*internal=group ;
FORMAT INTERNAL PERCENT6.1 VOLUME comma12.0;
run;
quit;

