data HHLd_file;
length HHID $ 9 ACCOUNT_KEY_1 $ 28 ACCT_NBR_ALPHA $ 28 PTYPE $ 3 STYPE $ 3 SBU_GROUP $ 3;
INFILE 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\virt_acc.TXT' lrecl=4096 dsd dlm='09'x ;                                           
   INPUT HHID                                                          
         ACCOUNT_KEY_1 $                                            
         ACCT_NBR_ALPHA $                                           
         PTYPE $                                                    
         STYPE $                                                    
         SBU_GROUP $                                               
         STATUS_FOR_PRIME $                                         
         STATUS_FOR_PRIME_HEQ_CCS $                                 
         SUB_PROD_CODE $                                            
         CONTR_BALANCE                                             
         CONTR_BILLPAY_FEES_NET_WAIVERS                           
         CONTR_EXPENSE                                            
         CONTR_FOREIGN_ATM_FEE_NET_WVRS                           
         CONTR_INCOME                                             
         CONTR_INTERCHANGE_INCOME                                 
         CONTR_INTEREST_EXPENSE                                  
         CONTR_INTEREST_INCOME                                    
         CONTR_MAINT_FEES_NET_WAIVERS                             
         CONTR_NET_CONTRIBUTION_MTD                               
         CONTR_NET_FEES                                           
         CONTR_POOL_EXPENSE                                       
         CONTR_POS_FEES_NET_WAIVERS                               
         CONTR_TOTAL_NSF_FEES                                     
         CONTR_TOTAL_NSF_FEES_WAIVED                              
         AMT_BAL_CURRENT                                          
         DATE_OPENED_FOR_PRIME : MMDDYY.                                 
         DATE_CLOSED : MMDDYY. ; 
run;
 
data acct_file;
length HHID $ 9 segment $ 1;
INFILE 'C:\Documents and Settings\ewnym5s\My Documents\Virtually Domiciled\virt_hh.TXT' lrecl=4096 dsd dlm='09'x ;                                           
   INPUT HHID $                                                         
         segment $;
run;
 
