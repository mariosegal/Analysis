proc tabulate data=data.main_201206 missing;
class vru_num tran_code;
var hh;
table vru_num, tran_code*sum*hh / nocellmerge;
format tran_code $transegm.;
run;


proc tabulate data=data.main_201206 missing;
class web_signon tran_code web;
var hh;
table web_signon,  tran_code*sum*hh / nocellmerge;
table web,tran_code / nocellmerge;
format tran_code $transegm.;
run;
