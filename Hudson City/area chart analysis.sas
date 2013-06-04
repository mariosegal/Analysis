data hudson.hudson_hh;
length area_group $ 20;
set hudson.hudson_hh;
area_group = '';
if products eq 1 then do;
	if (tda1 eq 1 or ira1 eq 1) then area_group = 'Single TDA/IRA';
	if (sav1 eq 1 or mms1 eq 1) then area_group = 'Single MMS/SAV';
	if (mtg1 eq 1) then area_group = 'Single Mortgage';
	if (dda1 eq 1) then do;
		if (cqi_dd eq 1 and (cqi_odl eq 1 or cqi_bp eq 1)) then area_group = 'Single CHK Active';
		else area_group = 'Single CHK inactive';
	end;
	if (tda ne 1 and ira1 ne 1 and sav1 ne 1 and mms1 ne 1 and mtg1 ne 1 and dda1 ne 1 and con1 eq 1) then area_group = 'Single Other';
end;
if products gt 1 then do;
	if (dda1 eq 0 and (tda1 eq 1 or ira1 eq 1)) then area_group = 'Multi TDA/IRA';
	if (dda1 eq 1) then do;
		if (cqi_dd eq 1 and (cqi_odl eq 1 or cqi_bp eq 1)) then area_group = 'Muiti CHK Active';
		else  area_group = 'Multi CHK inactive';
	end;
	if (tda ne 1 and ira1 ne 1 dda1 ne 1 and con1 eq 1) then area_group = 'Multi Other';
end;
run;

proc freq data=hudson.hudson_hh;
where state = "NJ" and products ge 1 and con1 eq 1;
table area_group;
table products;
run;



proc tabulate data=hudson.hudson_hh(rename=(IXI_IntChecking=intchk IXI_NonIntChecking=nonintchk IXI_OthChecking=othchk IXI_OtherAssets=other IXI_Annuity=annuity
                                               ixi_bond=bond IXI_Deposits=deposits IXI_Savings=savings IXI_StockAssets=stock IXI_MutualFund=mfunds)) missing;
where  state="NJ" and area_group ne '';
class segment products  state products abbas_grp active distance area_group ixi_assets;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 hh  dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt 
    IXI_Assets Deposits nonintchk intchk othchk Savings IXI__MMS IXI_CD stock mfunds bond annuity other hh;
table  (area_group all), N='HHs'*f=comma12. (dda1='Checking' mms1='Money Market' sav1='Savings' tda1='Time Deposits' ira1='IRAs' 
                                         mtg1='Mortgage' heq1='Home Equity' iln1='Inst. Loan' ccs1='Overdraft')*rowpctsum<hh>*f=pctfmt. /nocellmerge misstext='0.0%';
table area_group ALL, N='HHs'*f=comma12. (dda_amt='Checking'*rowpctsum<dda1> mms_amt='Money Market'*rowpctsum<mms1> sav_amt='Savings'*rowpctsum<sav1> tda_amt='Time Deposits'*rowpctsum<tda1> 
					  ira_amt='IRAs'*rowpctsum<ira1> mtg_amt='Mortgage'*rowpctsum<mtg1> heq_amt='Home Equity'*rowpctsum<heq1> iln_amt='Inst. Loan'*rowpctsum<iln1> 
                      ccs_amt='Overdraft'*rowpctsum<ccs1>)*f=pctdoll./nocellmerge misstext='$0';
table  area_group ALL, distance*N*f=comma12. distance*rowPCTN*f=pctfmt. / nocellmerge misstext='0.0';
table  area_group ALL, segment*N*f=comma12. segment*rowPCTN*f=pctfmt. / nocellmerge misstext='0.0';
table  area_group ALL, ixi_assets*N*f=comma12. ixi_assets*rowPCTN*f=pctfmt. / nocellmerge misstext='0.0';
table area_group ALL, N='HHs'*f=comma12. (IXI_Assets Deposits nonintchk intchk othchk Savings
                                       IXI__MMS IXI_CD stock mfunds bond annuity other)*rowpctsum<hh>*f=pctdoll./nocellmerge misstext='0.0';
keylabel sum='Total' rowpctsum='';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. abbas_grp abbas. active binary_flag. distance distfmt. ixi_assets wealthband.;
run;

proc tabulate data=hudson.hudson_hh(rename=(IXI_IntChecking=intchk IXI_NonIntChecking=nonintchk IXI_OthChecking=othchk IXI_OtherAssets=other IXI_Annuity=annuity
                                               ixi_bond=bond IXI_Deposits=deposits IXI_Savings=savings IXI_StockAssets=stock IXI_MutualFund=mfunds)) missing;
where  state="NJ" and area_group ne '';
class segment products  state products abbas_grp active distance area_group ;
var dda1 mms1 sav1 tda1 ira1 mtg1 heq1 iln1 ccs1 hh  dda_amt mms_amt sav_amt tda_amt ira_amt mtg_amt heq_amt iln_amt ccs_amt 
    IXI_Assets Deposits nonintchk intchk othchk Savings IXI__MMS IXI_CD stock mfunds bond annuity other hh;
table area_group ALL, N='HHs'*f=comma12. (IXI_Assets Deposits nonintchk intchk othchk Savings
                                       IXI__MMS IXI_CD stock mfunds bond annuity other)*rowpctsum<hh>*f=pctdoll./nocellmerge misstext='0.0';
keylabel sum='Total' rowpctsum='';
format products prods. ixi_assets wealthband. state $state. segment hudsonseg. abbas_grp abbas. active binary_flag. distance distfmt. ixi_assets wealthband.;
run;


proc contents data=hudson.hudson_hh varnum short;
run;
