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

*** Check IRA_amt for missing values;
if missing(IRA_amt) then do;
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

_LP0 = _LP0 + (712.425653148887) * dda;
_LP0 = _LP0 + (1125.13842953337) * mms;
_LP0 = _LP0 + (-97.1044991611605) * ira;
_LP0 = _LP0 + (659.868593283127) * sec;
_LP0 = _LP0 + (-287.374605734994) * mtg;
_LP0 = _LP0 + (688.24177077343) * heq;
_LP0 = _LP0 + (-394.789824357593) * card;
_LP0 = _LP0 + (204.955230378895) * ILN;
_LP0 = _LP0 + (295.911792746236) * bus;
_LP0 = _LP0 + (0.0045526247633) * DDA_Amt;
_LP0 = _LP0 + (0.008715994836) * MMS_amt;
_LP0 = _LP0 + (0.02398374751234) * sav_amt;
_LP0 = _LP0 + (0.00894804711658) * TDA_Amt;
_LP0 = _LP0 + (0.00989331558269) * IRA_amt;
_LP0 = _LP0 + (0.00078111076193) * sec_Amt;
_LP0 = _LP0 + (0.00921844287033) * MTG_amt;
_LP0 = _LP0 + (0.03347271374846) * HEQ_Amt;
_LP0 = _LP0 + (0.02241607463597) * ccs_Amt;
_LP0 = _LP0 + (0.02620476359902) * iln_amt;
_LP0 = _LP0 + (0.00158492587087) * IXi_Annuity;
_LP0 = _LP0 + (-0.00017094798323) * ixi_Funds;
_LP0 = _LP0 + (0.00059387235877) * ixi_Other;
_LP0 = _LP0 + (0.00208245789443) * ixi_Non_Int_Chk;
_LP0 = _LP0 + (-0.00086587908611) * ixi_int_chk;
_LP0 = _LP0 + (-0.00080940621418) * ixi_savings;
_LP0 = _LP0 + (0.00038378588462) * ixi_MMS;
_LP0 = _LP0 + (-0.00058750348955) * ixi_tda;
_LP0 = _LP0 + (460.815106434956) * IND;
_LP0 = _LP0 + (0.0489968509079) * IND_AMT;
_LP0 = _LP0 + (15.0036430299744) * distance;
_LP0 = _LP0 + (13.0629974282514) * tenure_yr;
_LP0 = _LP0 + (368.17214573686) * Mass_Affluent_Families;
_LP0 = _LP0 + (-350.487663554886) * Building_Their_Future;
_LP0 = _LP0 + (126.210186399742) * Mass_Affluent_no_Kids;
_LP0 = _LP0 + (294.600542244726) * Mass_Affluent_Retired;
_LP0 = _LP0 + (171.95112191272) * age_36_to_45;
_LP0 = _LP0 + (187.528558652339) * age_18_to_25;
_LP0 = _LP0 + (109.271452517413) * age_46_to_55;
_LP0 = _LP0 + (573.319887729345) * age_Up_to_17;
_LP0 = _LP0 + (-266.771931763837) * age_86_;
_LP0 = _LP0 + (-46.8742930171825) * age_76_to_85;
_LP0 = _LP0 + (-59.4176438754838) * age_66_to_75;
_LP0 = _LP0 + (251.509539787052) * age_26_to_35;
_LP0 = _LP0 + (-254.50469070875) * deposits;
_LP0 = _LP0 + (0.27783145518997) * atm_amt;
_LP0 = _LP0 + (-12.2235264174483) * atm_num;
_LP0 = _LP0 + (0.21994174914382) * deb_amt;
_LP0 = _LP0 + (1.67440919845545) * deb_num;
_LP0 = _LP0 + (125.084276445678) * products;

*** Predicted values;
_LP0 = _LP0 +     290.855346210792;
_SKIP_000:
if _LMR_BAD=1 then do;
   P_clv_total = .;
end;
else do;
   P_clv_total = _LP0;
end;
