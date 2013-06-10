data temp_hh;
length rc 8 ;
if 0 then set IXi.CBR_BY_ZIP_2012(keep=ZIP CBR  rename=(cbr=cbr_zip) );

if _n_ eq 1 then do;
	dcl hash h(dataset:'IXi.CBR_BY_ZIP_2012(keep=ZIP CBR rename=(cbr=cbr_zip))');
    h.definekey('zip');
	h.definedata('cbr_zip');
	h.definedone();
end;

set data.main_201212  (keep=dda: mms: sav: tda: ira: sec: ixi: zip) end=eof;
retain miss;

rc = h.find();
if rc ne 0 then do ;
	cbr_zip = '99';
	miss+1;
end;

ixi_dep= sum(ixi_non_int_chk, ixi_int_chk,ixi_savings, ixi_mms, ixi_tda);
ixi_inv = ixi_tot-ixi_dep;
mtb_dep = sum(dda_amt, sav_amt, tda_amt, ira_amt,mms_amt);
mtb_tot = sum(mtb_dep, sec_amt);
cbr_num = input(cbr_zip,2.);
if eof then put 'WARNING: Records in A not B = ' miss;
drop miss rc;
run;

data temp_hh;
set temp_hh;
dep_wallet = max(ixi_dep,mtb_dep);
inv_wallet = max(ixi_inv,sec_amt);
tot_wallet = sum(dep_wallet,inv_wallet);
*I am not assumign taht if IXI says they have A and we see more in one area, that the extra gets taken from the otehr areas,;
*I am assumig the others stay the same so the wallet goes up;

*The sow can be doine at HH level, but cant be aggregated that way;
/*dep_sow = divide(mtb_dep,dep_wallet);*/
/*inv_sow = divide(sec_amt,inv_wallet);*/
/*tot_sow = divide(mtb_tot,tot_wallet);*/
wealth = tot_wallet; *for later tabulaTION;
run;



proc tabulate data=temp_hh out=cbr_summary;
class cbr_num;
var dep_wallet inv_wallet tot_wallet mtb_tot sec_amt mtb_dep;
table cbr_num all, N sum*(mtb_dep sec_amt mtb_tot dep_wallet inv_wallet tot_wallet);
run;




data cbr_summary;
set cbr_summary;
dep_sow = divide(mtb_dep_sum,dep_wallet_sum);
inv_sow = divide(sec_amt_sum,inv_wallet_sum);
tot_sow = divide(mtb_tot_sum,tot_wallet_sum);
if cbr_num eq . then cbr_num = -1;
run;


proc print data =cbr_summary (drop= _:) noobs label split=' ';;
/*sum mtb_dep_sum sec_amt_sum mtb_tot_sum dep_wallet_sum inv_wallet_sum tot_wallet_sum;*/
format cbr_num cbr2012fmt. dep_sow inv_sow tot_sow percent6.1 mtb_dep_sum sec_amt_sum mtb_tot_sum dep_wallet_sum inv_wallet_sum tot_wallet_sum dollar24. N comma12.;
label N = 'HHs' mtb_dep_sum='MTB Deposits' sec_amt_sum='MTB Investments' mtb_tot_sum='MTB Total' dep_wallet_sum='Deposits Wallet' 
      inv_wallet_sum='Investment Wallet' tot_wallet_sum='Total Wallet' dep_sow='Deposit SOW' inv_sow='Investment SOW' tot_sow='Total SOW' cbr_num='CBR';
run;



*do also by weaLTH;
proc tabulate data=temp_hh out=cbr_wealth;
class cbr_num wealth;
var dep_wallet inv_wallet tot_wallet mtb_tot sec_amt mtb_dep;
table (cbr_num all )*(wealth all), N sum*(mtb_dep sec_amt mtb_tot dep_wallet inv_wallet tot_wallet);
format wealth wealthband.;
run;

data cbr_wealth;
set cbr_wealth;
dep_sow = divide(mtb_dep_sum,dep_wallet_sum);
inv_sow = divide(sec_amt_sum,inv_wallet_sum);
tot_sow = divide(mtb_tot_sum,tot_wallet_sum);
if cbr_num eq . then cbr_num = -1;
run;

proc print data =cbr_wealth (drop= _:) noobs label split=' ';;
/*sum mtb_dep_sum sec_amt_sum mtb_tot_sum dep_wallet_sum inv_wallet_sum tot_wallet_sum;*/
format cbr_num cbr2012fmt. dep_sow inv_sow tot_sow percent6.1 mtb_dep_sum sec_amt_sum mtb_tot_sum dep_wallet_sum inv_wallet_sum tot_wallet_sum dollar24. N comma12.;
label N = 'HHs' wealth='Estimated Wealth' mtb_dep_sum='MTB Deposits' sec_amt_sum='MTB Investments' mtb_tot_sum='MTB Total' dep_wallet_sum='Deposits Wallet' 
      inv_wallet_sum='Investment Wallet' tot_wallet_sum='Total Wallet' dep_sow='Deposit SOW' inv_sow='Investment SOW' tot_sow='Total SOW' cbr_num='CBR';
run;
