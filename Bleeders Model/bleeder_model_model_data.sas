/**************************************************************
** Project:  Bleeder Logistic Model Development
** Analyst:  Junli Zhou
** Date:     1/12/2011;
** Location: c:\projects\Bleeder Logistic Model Development\Programs_New\bleeder_model_model_data.sas;
** Description: This file does the following:
**	a. run var transformation, using Excel concatenate code;
**	b. run logistic model on M group;
***************************************************************/

/* Assign LIBREF for the Project & set page and line sizes*/

options ps=50  ls=98;

/* Var Transformation */

data bleeder.modgrp2f;
  set modgrp2;
  
IXI2l=log(IXI2+.01); IXI2s=(IXI2**2); IXI2r=((IXI2+.01)**.5); IXI2I=(1/(IXI2+.01));
DEPOSITS2l=log(DEPOSITS2+.01); DEPOSITS2s=(DEPOSITS2**2); DEPOSITS2r=((DEPOSITS2+.01)**.5); DEPOSITS2I=(1/(DEPOSITS2+.01));
LOANS2l=log(LOANS2+.01); LOANS2s=(LOANS2**2); LOANS2r=((LOANS2+.01)**.5); LOANS2I=(1/(LOANS2+.01));
IRA2l=log(IRA2+.01); IRA2s=(IRA2**2); IRA2r=((IRA2+.01)**.5); IRA2I=(1/(IRA2+.01));
MMS2l=log(MMS2+.01); MMS2s=(MMS2**2); MMS2r=((MMS2+.01)**.5); MMS2I=(1/(MMS2+.01));
SAV2l=log(SAV2+.01); SAV2s=(SAV2**2); SAV2r=((SAV2+.01)**.5); SAV2I=(1/(SAV2+.01));
TDA2l=log(TDA2+.01); TDA2s=(TDA2**2); TDA2r=((TDA2+.01)**.5); TDA2I=(1/(TDA2+.01));
SEC2l=log(SEC2+.01); SEC2s=(SEC2**2); SEC2r=((SEC2+.01)**.5); SEC2I=(1/(SEC2+.01));
INT_RATE2l=log(INT_RATE2+.01); INT_RATE2s=(INT_RATE2**2); INT_RATE2r=((INT_RATE2+.01)**.5); INT_RATE2I=(1/(INT_RATE2+.01));
VRU_INQUIRIESl=log(VRU_INQUIRIES+.01); VRU_INQUIRIESs=(VRU_INQUIRIES**2); VRU_INQUIRIESr=((VRU_INQUIRIES+.01)**.5); VRU_INQUIRIESI=(1/(VRU_INQUIRIES+.01));
VRU_TXNSl=log(VRU_TXNS+.01); VRU_TXNSs=(VRU_TXNS**2); VRU_TXNSr=((VRU_TXNS+.01)**.5); VRU_TXNSI=(1/(VRU_TXNS+.01));
WEB_INQUIRIESl=log(WEB_INQUIRIES+.01); WEB_INQUIRIESs=(WEB_INQUIRIES**2); WEB_INQUIRIESr=((WEB_INQUIRIES+.01)**.5); WEB_INQUIRIESI=(1/(WEB_INQUIRIES+.01));
WEB_TXNSl=log(WEB_TXNS+.01); WEB_TXNSs=(WEB_TXNS**2); WEB_TXNSr=((WEB_TXNS+.01)**.5); WEB_TXNSI=(1/(WEB_TXNS+.01));
tenure2l=log(tenure2+.01); tenure2s=(tenure2**2); tenure2r=((tenure2+.01)**.5); tenure2I=(1/(tenure2+.01));
servicesl=log(services+.01); servicess=(services**2); servicesr=((services+.01)**.5); servicesI=(1/(services+.01));

run;

proc corr data=bleeder.modgrp2f rank noprob; var IXI2 IXI2l IXI2s IXI2r IXI2I; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var DEPOSITS2 DEPOSITS2l DEPOSITS2s DEPOSITS2r DEPOSITS2I; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var LOANS2 LOANS2l LOANS2s LOANS2r LOANS2I; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var IRA2 IRA2l IRA2s IRA2r IRA2I; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var MMS2 MMS2l MMS2s MMS2r MMS2I; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var SAV2 SAV2l SAV2s SAV2r SAV2I; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var TDA2 TDA2l TDA2s TDA2r TDA2I; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var SEC2 SEC2l SEC2s SEC2r SEC2I; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var INT_RATE2 INT_RATE2l INT_RATE2s INT_RATE2r INT_RATE2I; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var VRU_INQUIRIES VRU_INQUIRIESl VRU_INQUIRIESs VRU_INQUIRIESr VRU_INQUIRIESI; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var VRU_TXNS VRU_TXNSl VRU_TXNSs VRU_TXNSr VRU_TXNSI; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var WEB_INQUIRIES WEB_INQUIRIESl WEB_INQUIRIESs WEB_INQUIRIESr WEB_INQUIRIESI; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var WEB_TXNS WEB_TXNSl WEB_TXNSs WEB_TXNSr WEB_TXNSI; with target; run;

proc corr data=bleeder.modgrp2f rank noprob; var tenure2 tenure2l tenure2s tenure2r tenure2I; with target; run;
proc corr data=bleeder.modgrp2f rank noprob; var services servicesl servicess servicesr servicesI; with target; run;




/* Run PROC LOGISTIC using STEPWISE var entry option */

proc logistic data=bleeder.modgrp2f descending;
  model target = /*IXI2 */
				 DEPOSITS2 
				 LOANS2

				/* DDA
				 IRA
				 MMS
				 SAV
				 TDA */

				/* IRA_penet */
				 MMS_penet
				/* SAV_penet
				 TDA_penet
				 DDA_penet */
				
				 INT_RATE2i
				 TDA_early_mature
 
				 VRU_INQUIRIES
				 VRU_TXNSs
				 WEB_INQUIRIES
				 /*WEB_TXNSl*/
				 ATM_INQUIRIES
				 ATM_TXNS
				 CSW_INQUIRIES
				 CSW_TXNS
				 DEBIT_TXNS
				 BRANCH_TXNS

				 cqi
				 cqi_bp
				 cqi_dd
				 cqi_deb
				 cqi_od
				 cqi_web

				 seg1
				 seg2
				 seg3
				 seg4
				 seg5
				 seg6
				 seg7

				 Services
				 tenure2l
								
				/selection = stepwise slentry=0.001 slstay=0.001 details stb;

				title 'Bleeder Logistic Model Output';
			
run;


/* Force significant attributes in the model without entry option */
ods output parameterestimates = parmsST; /*work.parmsST used for outputing model coefficients*/
proc logistic data=bleeder.modgrp2f descending;
  model target = deposits2
  				 mms_penet
				 int_rate2i
				 tda_early_mature
				 atm_txns
				 csw_inquiries
				 cqi_web
				 seg4
				 seg5
				 tenure2l
				 / stb ;
  title 'Force Significant Vars in Model without Entry Option';
run;



