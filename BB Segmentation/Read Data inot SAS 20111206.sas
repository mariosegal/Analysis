/*Read extract from DataMart*/ 

LIBNAME BBSEG 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation';

filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\BBData.txt';




Data BBSEG.HHDATA;
length HHID $ 9 EMPLOYEE_BAND $ 25 SALES_BAND $ 25;
Infile myfile DLM='09'x firstobs=2 lrecl=4096;
Input HHID $
	  Branch $
	  CBR $
	  Market $
	  ST $
	  DDA
	  MMS
	  SAV
	  TDA
	  IRA
	  TRS
	  MTG
	  HEQB
	  HEQC
	  CLN
	  CARD
	  BOLOC
	  BALOC
	  CLS
	  WBB
	  DEB
	  MCC
	  LCKBX
	  RCD
	  BBFB
	  DDA_AMT
	  MMS_AMT
	  SAV_AMT
	  TDA_AMT
	  IRA_AMT
	  MTG_AMT
	  HEQB_AMT
	  HEQC_AMT
	  CLN_AMT
	  CARD_AMT
	  BOLOC_AMT
	  BALOC_AMT
	  CLS_AMT
	  MCC_AMT
	  CON
	  COM
	  WEB_INFO
	  PB $
	  SVCS
	  TENURE
	  TARGET
	  SIC_INT $
	  SIC_EXT $
	  EMPLOYEES
	  WEB_TR
	  EMPLOYEE_BAND $
	  SALES
	  SALES_BAND $
	  CHECK_TR
	  MT_ATM_TR
	  OTH_ATM_TR
	  MT_ATM_AMT
	  OTH_ATM_AMT
	  VPOS_TR
	  MPOS_TR
	  VPOS_AMT
	  MPOS_AMT
	  DEPTKT
	  CURDP_CNT
	  CURDP_AMT
	  CKDEP
	  CHKPD
	  ACH
	  RCD_NUM
	  WEB_INFO_NUM
	  LCKBX_NUM
	  TOP40
	  RM;
RUN;


filename myfile CLEAR;	



filename myfile 'C:\Documents and Settings\ewnym5s\My Documents\BB Segmentation\SIC_Codes.csv';


Data BBSEG.TARGETS_NEW;
length SIC_BEST $ 4 TARGET_NEW $ 1;
Infile myfile DLM=',' firstobs=1 lrecl=4096;
Input SIC_BEST $
      TARGET_NEW $;
run;

 
filename myfile CLEAR;	
