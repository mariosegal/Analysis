LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

data temp;
length name_str $ 175;
set BBSEG.DDA_DATA;
name_str = catx(" ",Title1,Title2,Title3,Title4);
keep hhid name_str SIC4 SIC key;
run;

data bbseg.wordbag_DDAs;
length word $ 30;
set temp ;
myflag=0;
do i=1 to 100 while (myflag=0);
	word = scan(upcase(name_str),i," ,");
	if (word ne ''  and length(trim(word)) ge 2) then do;
		output;
	end;
	else do;
	    myflag=1;
	end;
end;
keep word;
run;

proc freq data=wordbag_DDAs order=freq;
table word / out=BBSEG.word_counts_DDAs;
run;
