LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

data temp;
length name_str $ 175;
set union.accts_201209;
name_str = catx(" ",Title1,Title2,Title3,Title4);
name_str = upcase(name_str);
keep hhid name_str SIC4 SIC key;
run;

Data UNION.UNION_ACCTS_BYTEXT_NEW (compress=yes);
set temp (obs=max);
array words{31} $ 15 _temporary_  ('BROTHERHD' 'BROTHERHOOD' 'BHOOD' 'LOCAL' 'LCL' 'UNION' 'GUILD' 'Allied' 'Ind' 'Trans' 'Bflo' 'Lab' 'Brick' 'Pen'
                                   'Cement'  'Concrete' 'CNY' 'Lab' 'Glazrs' 'Marble' 'Industry' 'SEIU' 'Employees' 'Wire' 'LOC' 'IBEW'
                                    'Team' 'Teamsters' 'AFL' 'CIO' 'AFSCME');

tag=0;
nwords = countw(name_str);
do i=1 to 31;	
	do count = 1 to nwords;
      	word = scan(name_str, count);
		if upcase(words{i})=upcase(word) then do;
			tag+1;
			count = nwords;
		end;
/*		output;*/ 
	end;
end;
if tag ge 1 then output;
drop i nwords word count;
run;




proc sort data=union.UNION_ACCTS_BYTEXT_NEW (keep = name_str tag) out=unique nodupkey;
by name_str tag;
run;

proc sort data=unique;
by descending tag;
run;

PROC EXPORT DATA= union.UNION_ACCTS_BYTEXT_NEW
            OUTFILE= 'C:\Documents and Settings\ewnym5s\My Documents\Unions\Union_Accts_201209.xls'
            DBMS=XLS REPLACE;
			sheet="ACCTS";
RUN;

PROC EXPORT DATA= unique
            OUTFILE= 'C:\Documents and Settings\ewnym5s\My Documents\Unions\Union_Accts_201209.xls'
            DBMS=XLS replace ;
			sheet="Unique";
RUN;


ods tagsets.excelxp file="C:\Documents and Settings\ewnym5s\My Documents\Unions\temp.xml";
ods tagsets.excelxp
options(sheet_name="Accts");
proc print data=union.UNION_ACCTS_BYTEXT_NEW;
Run;
ods tagsets.excelxp
options(sheet_name="Names");
proc print data=unique;
run;
ods tagsets.excelxp close;
