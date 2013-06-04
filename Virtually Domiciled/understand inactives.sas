data temp;
set data.main_201203;
where tran_segment eq "Inactive";
keep dd_amt chk_num tran_segment hh vpos: mpos: debit_num debit_amt trans;
debit_num = vpos_num + mpos_num;
debit_amt = vpos_amt + mpos_amt;
trans=debit_num+chk_num;
run;

proc tabulate data=temp missing;
where tran_segment eq "Inactive";
class dd_amt chk_num debit_num trans;
table (trans ALL), (dd_amt ALL)*N*f=comma12. / nocellmerge;
format dd_amt amtband. trans   trans.;
run;

proc tabulate data=temp missing;
where tran_segment eq "Inactive";
class dd_amt chk_num debit_num;
table (chk_num ALL)*(debit_num ALL) ALL, (dd_amt ALL)*pctN*f=pctfmt. / nocellmerge;
format dd_amt amtband. debit_num  chk_num trans.;
run;


