LIBNAME ixi ODBC DSN=IXI user=reporting_user pw=Reporting2 schema=dbo;

* extract IXI data for analysis;

data wip.ixi_assets_201206 ;
set ixi.mtb_postal;
where cycleid = 201206;
run;


data wip.ixi_tiers_201206 ;
set ixi.mtb_tiers_postal;
where cycleid = 201206;
run;


*aggregate total market by cbr;
proc freq data=branch.Cbr_by_zip_2012;
table cbr_zip / missing;
run;

data temp_assets ;
merge wip.ixi_assets_201206 (in=a) branch.Cbr_by_zip_2012 (in=b rename=(zip=regionzipcode) where=(cbr_zip ne 99)) end=eof;
retain miss;
by regionzipcode;
if b then output temp_assets;
if b and not a then miss+1;
if eof then  do;
	put 'WARNING: Zips with no IXI Data: ' miss;
end;
run;

data temp_tiers ;
merge wip.ixi_tiers_201206 (in=a) branch.Cbr_by_zip_2012 (in=b rename=(zip=regionzipcode) where=(cbr_zip ne 99)) end=eof;
retain miss;
by regionzipcode;
if b then output temp_tiers;
if b and not a then miss+1;
if eof then  do;
	put 'WARNING: Zips with no IXI Data: ' miss;
end;
run;

*check baltimore 2-3MM HHs;
proc fslist fileref='C:\Documents and Settings\ewnym5s\My Documents\hh_zip.txt';
run;

data names;
length hhid $ 9  ptype $ 3 stype $ 3 sbu $ 3 title1 $ 50 title2 $ 50 title3 $ 50 title4 $ 50;
infile 'C:\Documents and Settings\ewnym5s\My Documents\hh_zip.txt' dsd dlm='09'x lrecl=4086 firstobs=2;
input hhid $ ptype $ stype $ sbu $ title1-title4 $ balance ;
run;

proc sort data=data.main_201209;
by hhid;
run;

data temp_check;
merge data.main_201209 (in=a where=(ixi_tot ge 2000000 and ixi_tot lt 3000000) keep=hhid ixi_tot cbr  zip) names (in=b) ;
by hhid;
if b and a;
run;

data temp_check;
set temp_check;
where ptype not in ('DEB','ATM','WEB',"HBK",'SDB');
where also (ptype in ("DDA","MMS","SAV","TDA","IRA") and substr(stype,1,1) = "R") or ( (ptype not in ("DDA","MMS","SAV","TDA","IRA"))and sbu = "CON");
format balance ixi_tot dollar24.;
run;

proc freq data=temp_check order=freq;
table zip ptype;
run;


*aggregate the data for MTB;

proc contents data= temp_assets varnum short;
run;

proc contents data= temp_tiers varnum short;
run;

Title 'Total MKT M&T CBRs';
proc tabulate data=temp_assets missing;
where not (cbr_zip eq 6 and state='NJ');
class cbr_zip;
var TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking Savings MutualFunds Other Stocks 
TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds InterestCheckingHouseholds 
MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds StocksHouseholds;
table sum*(TotalAssets Annuities Bonds Deposits CD InterestChecking MoneyMarket NonInterestChecking OtherChecking Savings MutualFunds Other Stocks)*f=dollar24.
      sum*(TotalHouseholds TotalHouseholdsWithAssets AnnuitiesHouseholds BondsHouseholds DepositsHouseholds CDHouseholds InterestCheckingHouseholds 
		   MoneyMarketHouseholds NonInterestCheckingHouseholds OtherCheckingHouseholds SavingsHouseholds MutualFundsHouseholds OtherHouseholds 	
           StocksHouseholds)*f=comma12., cbr_zip all/ nocellmerge misstext='0';
format cbr_zip cbr2012fmt. ;
keylabel sum=' ';
run;


proc tabulate data=temp_tiers missing;
where not (cbr_zip eq 6 and state='NJ');
class cbr_zip;
var ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
T10mTo15mDollars T15mTo25mDollars T25mPlusDollars ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds 
T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds 
T1P5mTo2mHouseholds T2mTo3mHouseholds T3mTo5mHouseholds T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds 
T25mPlusHouseholds;
table sum*(ZeroDollars T1To2p5kDollars T2p5kTo10kDollars T10kTo25kDollars T25kTo50kDollars T50kTo75kDollars T75kTo100kDollars T100kTo250kDollars 
           T250kTo500kDollars T500kTo1mDollars T1mTo1P5mDollars T1P5mTo2mDollars T2mTo3mDollars T3mTo5mDollars T5mTo7P5mDollars T7P5mTo10mDollars 
           T10mTo15mDollars T15mTo25mDollars T25mPlusDollars)*f=dollar24.
      sum*(ZeroHouseholds T1To2p5kHouseholds T2p5kTo10kHouseholds T10kTo25kHouseholds 
           T25kTo50kHouseholds T50kTo75kHouseholds T75kTo100kHouseholds T100kTo250kHouseholds T250kTo500kHouseholds T500kTo1mHouseholds T1mTo1P5mHouseholds 
           T1P5mTo2mHouseholds T2mTo3mHouseholds T3mTo5mHouseholds T5mTo7P5mHouseholds T7P5mTo10mHouseholds T10mTo15mHouseholds T15mTo25mHouseholds 
           T25mPlusHouseholds)*f=comma12., cbr_zip all/ nocellmerge misstext='0';
format cbr_zip cbr2012fmt. ;
keylabel sum=' ';
run;

*Claculate internal Part;
data data.main_201209;
merge data.main_201209

options compress=y;
 data data.main_201209;
length cbr_zip 8 zip $ 5 ;
length rc 3;
retain misses 3;

if _n_ eq 1 then do;
	set branch.Cbr_by_zip_2012 (keep=cbr_zip zip) end=eof1;
	dcl hash hh1 (dataset: 'branch.Cbr_by_zip_2012', hashexp: 8, ordered:'a');
	hh1.definekey('zip');
	hh1.definedata('cbr_zip');
	hh1.definedone();
end;

misses = 0;
do until (eof2);
	set data.main_201209 end=eof2;
	rc = hh1.find()= 0 ;	
	if hh1.find() ne 0 then  do;
		cbr_zip  = .;
	end;
	output;
end;

putlog 'WARNING: There were ' misses comma6. ' records in large file not matched';
drop rc misses;
run;


data data.main_201209;
set data.main_201209;
if ixi_tot ne . then do;
	adj_tot = max(ixi_tot,sum(dda_amt,sav_amt,mms_amt,tda_amt,ira_amt,sec_amt));
end;
run;

proc tabulate data=data.main_201209 missing;
where not (cbr_zip eq 6 and state='NJ') and cbr_zip not in (99,.);
class adj_tot cbr_zip;
var hh;
table adj_tot all, (cbr_zip all)*sum=''*hh*f=comma12./ nocellmerge misstext='0';
format cbr_zip cbr2012fmt. adj_tot wltamt.;
run;



