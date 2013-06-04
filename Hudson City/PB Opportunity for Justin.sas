data temp;
set hudson.hudson_hh;
where mtx eq 0 or (mtx eq 1 and (dda or mms or sav or tda or ira or mtg or heq or iln or ccs));
keep ixi_assets pseudo_hh hh mms_amt tda_amt ira_amt liquid cds ;
cds =tda_amt + ira_amt;
liquid = tda_amt + ira_amt + mms_amt;
run;


proc format;
value balance low-0 = 'Below Zero'
				0,. = 'Zero'
				0<-10000 = 'Up to $10M'
				10000<-25000 = '$10+ to $25M'
				25000<-50000 = '$25+ to $50M'
				50000<-75000 = '$50+ to $75M'
				75000<-100000 = '$75+ to $100M'
				100000<-250000 = '$100+ to $250M'
				250000<-500000 = '$250+ to $500M'
				500000<-1000000 = '$500+ to $1MM'
				1000000<-high ='Over $1MM';
run;


proc tabulate data=temp missing ;
class ixi_assets cds liquid;
var hh;
table cds='CD/IRA Balance', ixi_assets='Investable Assets'*(sum=' '*hh='HHs'*f=comma12.) / nocellmerge misstext='0';
table liquid='CD/IRA/MMS Balance', ixi_assets='Investable Assets'*(sum=' '*hh='HHs'*f=comma12.) / nocellmerge misstext='0';
format ixi_assets ixifmt. cds liquid balance.;
run;
