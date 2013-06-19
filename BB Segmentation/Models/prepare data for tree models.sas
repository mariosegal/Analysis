data infousa;
length hhid $ 9 sales1 $ 25 employees1 $ 25;
infile 'C:\Documents and Settings\ewnym5s\My Documents\infousa.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input hhid$ sales1 $ employees1 $;
run;

proc sort data=infousa;
by hhid;
run;

data bb.bbmain_201212 (compress=binary );
merge  bb.bbmain_201212 (in =left drop =sales1 employees1) infousa (in=right);
by hhid;
if left;
run;




data bb.bbmain_201212 (compress=binary);
set bb.bbmain_201212 ;

A=0;
B=0;
C=0;
D=0;
if band = 'A' then A = 1;
if band = 'B' then B = 1;
if band = 'C' then C = 1;
if band = 'D' then D = 1;

*need to fix this part, also add zeros to all before;
select(sales1);
	when ('$1-2.5 MILLION ') x_1_to_2MM = 1;
	when ('$10-20 MILLION ') x_10_to_20MM = 1;
	when ('$2.5-5 MILLION ') x_2p5_to_5MM = 1;
	when ('$20-50 MILLION ') x_20_to_50MM = 1;
	when ('$5-10 MILLION ') x_5_to_10MM = 1;
	when ('$50-100 MILLION ') x_50_to_100MM = 1;
	when ('$500,000-1 MILLION ') x_500k_to_1MM = 1;
	when ('LESS THAN $500,000 ') to500K = 1;
	otherwise to500K = 0;
end;
select(employees1);
	when ('1-4 ') e_1to4 = 1;
	when ('10-19 ') e_10_19 =1;
	when ('100-249 ') e_100_249 = 1;
	when ('20-49 ') e_20_49 = 1;
	when ('5-9 ') e_5_9 = 1;
	when ('50-99 ') e_50_99 = 1;
	otherwise e_50_99 = 0;
end;

contrib1=sum(DDA_con ,MMS_con ,sav_con ,TDA_con, IRA_con ,MTG_con ,HEQB_con ,CLN_con ,Card_con ,BOLoc_con, BALOC_con ,CLS_con ,MCC_con);

run;


