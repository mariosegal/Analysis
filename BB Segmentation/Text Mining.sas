LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

data temp;
length name_str $ 175;
set bbseg.DDA_Data;
name_str = catx(" ",Title1,Title2,Title3,Title4);
keep hhid name_str;
run;
/*#########################################################################################################*/
/* create list of al words found*/

data wordbag;
length word $ 30;
set temp ;
myflag=0;
do i=1 to 100 while (myflag=0);
/*	PUTLOG NAME_STR;*/
/*    putlog i myflag _n_ word;*/
	word = scan(upcase(name_str),i," ,");
	if (word ne ''  and length(trim(word)) ge 3) then do;
		output;
	end;
	else do;
	    myflag=1;
	end;
end;
keep word;
run;

proc freq data=wordbag order=freq;
table word / out=word_counts;
run;


data bbseg.top_words ;
set word_counts (obs=1000);
len = length(trim(word));
run;

proc sort data=bbseg.top_words;
by descending len descending count;
run;

/*#########################################################################################################*/
/*create tags for selected words (which were selected manuallyu from top 1,000 */

options symbolgen;

Data BBSEG.DDA_DATA_UNIONS;
set temp;
array words{34} $ 15 _temporary_  ('ASSOC' 'BROTHER' 'CHAPTER' 'CONFERENCE' 'COUNCIL' 'ELECTRIC' 'FIRE' 'GUILD' 'HALL' 'INDUSTRIAL' 'INTERNATIONAL' 
                                  "INT'L" 'JANITORIAL' 'LEGION' 'LOCAL' 'LODGE' 'MACHINE' 'MASONRY' 'MECHANICAL' 'NATIONAL' 'ORDER' 'ORGANIZATION' 
                                  'PLUMBING' 'POLICE' 'SCHOOL' 'SOCIAL' 'SOCIETY' 'TEACHER' 'TRANSIT' 'TRUCK' 'UNION' 'UNITED' 'WELD' 'WORK');

array tags{34} 3 flag1-flag34;

do i=1 to 34;
	if find(name_str,words{i},'it') ge 1 then do;
		tags{i} = 1;
	end;
	else do;
		tags{i} = 0;
	end;
end;
drop i;
run;

Data bbseg.UNIONS_SUMMARy;
set BBSEG.DDA_DATA_UNIONS;
array a{34} flag:;
array b{34} 3 _temporary_;
by HHID;

	if first.hhid then do;
		do i = 1 to 34;
			b{i}=0;
		end;
	end;
	do i = 1 to 34;
		b{i} = max(b{i},a{i});
	end;
	if last.hhid then do;
		do i = 1 to 34;
			a{i}=b{i};
		end;
		output;
	end;
drop i name_str;
run;



/*proc freq data=bbseg.UNIONS_SUMMARy;*/
/*tables _NUMERIC_ / nofreq;*/
/*run;*/

data tempx;
set BBSEG.DDA_DATA_UNIONS;
where flag4 = 1;
by hhid;
if first.HHID then output;
run;


proc print data=tempx;
var hhid name_str;
run;
