data infousa;
length hhid $ 9 sales $ 25 employees $ 25;
infile 'C:\Documents and Settings\ewnym5s\My Documents\infousa.txt' dsd dlm='09'x lrecl=4096 firstobs=2;
input hhid$ employees $ sales $;
run;

proc sort data=infousa;
by hhid;
run;

data bb.bbmain_201212 (compress=binary );
merge  bb.bbmain_201212 (in =left ) infousa (in=right);
by hhid;
if left;
run;


proc freq data=bb.bbmain_201212;
table sales1 employees1;
run;


data bb.bbmain_201212 (compress=binary);
set bb.bbmain_201212  ;

select(sales);
	when ('$1-2.5 MILLION') x_1_to_2MM = 1;
	when ('$10-20 MILLION') x_10_to_20MM = 1;
	when ('$2.5-5 MILLION') x_2p5_to_5MM = 1;
	when ('$20-50 MILLION') x_20_to_50MM = 1;
	when ('$5-10 MILLION') x_5_to_10MM = 1;
	when ('$50-100 MILLION') x_50_to_100MM = 1;
	when ('$500,000-1 MILLION') x_500k_to_1MM = 1;
	when ('LESS THAN $500,000') to500K = 1;
	otherwise to500K = .;
end;
select(employees);
	when ('1-4') e_1to4 = 1;
	when ('10-19') e_10_19 =1;
	when ('100-249') e_100_249 = 1;
	when ('20-49') e_20_49 = 1;
	when ('5-9') e_5_9 = 1;
	when ('50-99') e_50_99 = 1;
	otherwise e_50_99 = .;
end;

contrib1=sum(DDA_con ,MMS_con ,sav_con ,TDA_con, IRA_con ,MTG_con ,HEQB_con ,CLN_con ,Card_con ,BOLoc_con, BALOC_con ,CLS_con ,MCC_con);

run;

proc contents data=bb.bbmain_201212 varnum short;
run;

%null_to_zero(bb.bbmain_201212,bb.bbmain_201212(compress=binary),x_1_to_2MM x_10_to_20MM x_2p5_to_5MM x_20_to_50MM x_5_to_10MM x_50_to_100MM x_500k_to_1MM to500K e_1to4 e_10_19 e_100_249 e_20_49 e_5_9 e_50_99)


