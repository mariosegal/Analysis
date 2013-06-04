*****************************************;
** SAS Scoring Code for PROC REG;
*****************************************;

label P_clv_total = 'Predicted: clv_total' ;
drop _LMR_BAD;
_LMR_BAD=0;

*** Check dda for missing values;
if missing(dda) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check mms for missing values;
if missing(mms) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check ira for missing values;
if missing(ira) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check sec for missing values;
if missing(sec) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check mtg for missing values;
if missing(mtg) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check heq for missing values;
if missing(heq) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check card for missing values;
if missing(card) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check ILN for missing values;
if missing(ILN) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check bus for missing values;
if missing(bus) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check DDA_Amt for missing values;
if missing(DDA_Amt) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check MMS_amt for missing values;
if missing(MMS_amt) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check sav_amt for missing values;
if missing(sav_amt) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check TDA_Amt for missing values;
if missing(TDA_Amt) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check sec_Amt for missing values;
if missing(sec_Amt) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check MTG_amt for missing values;
if missing(MTG_amt) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check HEQ_Amt for missing values;
if missing(HEQ_Amt) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check ccs_Amt for missing values;
if missing(ccs_Amt) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check iln_amt for missing values;
if missing(iln_amt) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check IXi_Annuity for missing values;
if missing(IXi_Annuity) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check ixi_Funds for missing values;
if missing(ixi_Funds) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check ixi_Other for missing values;
if missing(ixi_Other) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check ixi_Non_Int_Chk for missing values;
if missing(ixi_Non_Int_Chk) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check ixi_int_chk for missing values;
if missing(ixi_int_chk) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check ixi_savings for missing values;
if missing(ixi_savings) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check ixi_MMS for missing values;
if missing(ixi_MMS) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check ixi_tda for missing values;
if missing(ixi_tda) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check IND for missing values;
if missing(IND) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check IND_AMT for missing values;
if missing(IND_AMT) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check distance for missing values;
if missing(distance) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check tenure_yr for missing values;
if missing(tenure_yr) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check Mass_Affluent_Families for missing values;
if missing(Mass_Affluent_Families) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check Building_Their_Future for missing values;
if missing(Building_Their_Future) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check Mass_Affluent_no_Kids for missing values;
if missing(Mass_Affluent_no_Kids) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check Mass_Affluent_Retired for missing values;
if missing(Mass_Affluent_Retired) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check age_36_to_45 for missing values;
if missing(age_36_to_45) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check age_18_to_25 for missing values;
if missing(age_18_to_25) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check age_46_to_55 for missing values;
if missing(age_46_to_55) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check age_Up_to_17 for missing values;
if missing(age_Up_to_17) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check age_86_ for missing values;
if missing(age_86_) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check age_76_to_85 for missing values;
if missing(age_76_to_85) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check age_66_to_75 for missing values;
if missing(age_66_to_75) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check age_26_to_35 for missing values;
if missing(age_26_to_35) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check deposits for missing values;
if missing(deposits) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check atm_amt for missing values;
if missing(atm_amt) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check atm_num for missing values;
if missing(atm_num) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check deb_amt for missing values;
if missing(deb_amt) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check deb_num for missing values;
if missing(deb_num) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Check products for missing values;
if missing(products) then do;
   _LMR_BAD=1;
   goto _SKIP_000;
end;

*** Compute Linear Predictors;
drop _LP0;
_LP0 = 0;

_LP0 = _LP0 + (0.24904530694341) * dda;
_LP0 = _LP0 + (0.3876651350159) * mms;
_LP0 = _LP0 + (0.01855750708262) * ira;
_LP0 = _LP0 + (0.22519294248418) * sec;
_LP0 = _LP0 + (-0.0996193935261) * mtg;
_LP0 = _LP0 + (0.23550720818234) * heq;
_LP0 = _LP0 + (-0.13633113351768) * card;
_LP0 = _LP0 + (0.06958278817623) * ILN;
_LP0 = _LP0 + (0.10178562876895) * bus;
_LP0 = _LP0 + (0.05787485149573) * DDA_Amt;
_LP0 = _LP0 + (0.10651009157941) * MMS_amt;
_LP0 = _LP0 + (0.09544405536252) * sav_amt;
_LP0 = _LP0 + (0.04455003964887) * TDA_Amt;
_LP0 = _LP0 + (0.0239675375246) * sec_Amt;
_LP0 = _LP0 + (0.19257849209055) * MTG_amt;
_LP0 = _LP0 + (0.20339504238765) * HEQ_Amt;
_LP0 = _LP0 + (0.00796831561221) * ccs_Amt;
_LP0 = _LP0 + (0.01502612072914) * iln_amt;
_LP0 = _LP0 + (0.02315933975952) * IXi_Annuity;
_LP0 = _LP0 + (-0.01774807033703) * ixi_Funds;
_LP0 = _LP0 + (0.00900232681051) * ixi_Other;
_LP0 = _LP0 + (0.0227724849353) * ixi_Non_Int_Chk;
_LP0 = _LP0 + (-0.00604092251783) * ixi_int_chk;
_LP0 = _LP0 + (-0.01000766028038) * ixi_savings;
_LP0 = _LP0 + (0.01316354218239) * ixi_MMS;
_LP0 = _LP0 + (-0.00696638167579) * ixi_tda;
_LP0 = _LP0 + (0.15809784384735) * IND;
_LP0 = _LP0 + (0.12064410991369) * IND_AMT;
_LP0 = _LP0 + (0.02443144124357) * distance;
_LP0 = _LP0 + (0.05544241557458) * tenure_yr;
_LP0 = _LP0 + (0.12685002059243) * Mass_Affluent_Families;
_LP0 = _LP0 + (-0.11979764549525) * Building_Their_Future;
_LP0 = _LP0 + (0.04323728795013) * Mass_Affluent_no_Kids;
_LP0 = _LP0 + (0.10242824974175) * Mass_Affluent_Retired;
_LP0 = _LP0 + (0.05879373708721) * age_36_to_45;
_LP0 = _LP0 + (0.06449886681403) * age_18_to_25;
_LP0 = _LP0 + (0.0369595968399) * age_46_to_55;
_LP0 = _LP0 + (0.19978376291612) * age_Up_to_17;
_LP0 = _LP0 + (-0.09249707202502) * age_86_;
_LP0 = _LP0 + (-0.01497862123306) * age_76_to_85;
_LP0 = _LP0 + (-0.01963267613327) * age_66_to_75;
_LP0 = _LP0 + (0.08582926767779) * age_26_to_35;
_LP0 = _LP0 + (-0.09308404752138) * deposits;
_LP0 = _LP0 + (0.04469080662904) * atm_amt;
_LP0 = _LP0 + (-0.01432919190182) * atm_num;
_LP0 = _LP0 + (0.0814611280369) * deb_amt;
_LP0 = _LP0 + (0.01481172600804) * deb_num;
_LP0 = _LP0 + (0.04596079030944) * products;

*** Predicted values;
_LP0 = _LP0 +    -0.22980028919389;
_SKIP_000:
if _LMR_BAD=1 then do;
   P_clv_total = .;
end;
else do;
   P_clv_total = _LP0;
end;
