data hudson;
set hudson.hudson_hh;
where dual eq 1;
keep dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 mtx1  DDA_amt TDA_amt IRA_amt SAV_amt MTG_amt MMS_amt ILN_amt HEQ_amt CCS_amt MTX_amt products 
     segment state ixi_assets pseudo_hh distance;
run;


data key;
set hudson.duals;
keep hhid pseudo_hh;
run;

proc sort data=key ;
by hhid pseudo_hh;
run;

data key1;
set key;
by hhid;
dual = 1;
if first.hhid then output;

run;


data data.main_201209;
set data.main_201209 ;
 drop pseudo_hh dual;
 run;



options compress=y;
 data data.main_201209;
length pseudo_hh 8 hhid $ 9 dual 8;


if _n_ eq 1 then do;
	set key1 end=eof1;
	dcl hash hh1 (dataset: 'key1', hashexp: 8, ordered:'a');
	hh1.definekey('hhid');
	hh1.definedata('pseudo_hh', 'dual');
	hh1.definedone();
end;

do until (eof2);
	set data.main_201209 end=eof2;
	if hh1.find()= 0 then output;	
	if hh1.find() ne 0 then  do;
		pseudo_hh = .;
		dual=.;
		output;
	end;
end;
run;


data mtb;
set data.main_201209;
where dual eq 1;
prods_mtb = sum(dda, mms, sav, tda, ira, sec, trs, mtg, heq, card, ILN, sln, sdb, ins, IND);
keep hhid pseudo_hh dda mms sav tda ira sec trs mtg heq card ILN sln sdb ins DDA_Amt MMS_amt sav_amt IND 
     TDA_Amt IRA_amt sec_Amt trs_amt MTG_amt HEQ_Amt ccs_Amt iln_amt sln_amt ind_amt;
run;

proc sql;

  select cat(name, ' = ', cats(name, '_mtb' )) into :renstr separated by ' ' from

    dictionary.columns where libname = 'WORK' and memname='MTB';

quit;

proc datasets library=work;

   modify mtb;

   rename &renstr;

   run;

proc datasets library=work;

   modify mtb;

   rename pseudo_hh_mtb = pseudo_hh;

   run;




proc sort data=mtb;
by pseudo_hh;
run;


data merged;
merge hudson (in=a) mtb (in=b);
by pseudo_hh;
if a;
run;


%null_to_zero(dataset=merged)

data hudson.dual_hh;
set merged;
run;
