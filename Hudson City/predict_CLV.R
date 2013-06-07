setwd("C:/Documents and Settings/ewnym5s/My Documents/Analysis/Lifetime Value")

#careful you saved it on CLV not Hudson

library(randomForest)

library("RODBC")
myconn <- odbcConnect(dsn="SASODBC",believeNRows=FALSE, colQuote=NULL)
hudson <- sqlQuery(myconn,"select * from wip.hudson")

odbcCloseAll()

rm(myconn)

#I need to make the names match the model;
names <- names(hudson)
#I adjusted by hand;
names(hudson) <- names

#add missing data
hudson$IND <- 0;
hudson$IND_AMT <- 0;
hudson$card <- 0;
hudson$ccs_Amt <- 0;
hudson$tenure_yr <- (19514-hudson$open)/365; #6/5/2013 was sas date 19514 dates are in sas numeric format;

hudson$Building_Their_Future[hudson$segment==1] <- 1 
hudson$Building_Their_Future[hudson$segment!=1] <- 0

hudson$Mass_Affluent_no_Kids <- 0 #we have no kid data

hudson$Mainstream_Families[hudson$segment==2] <- 1 
hudson$Mainstream_Families[hudson$segment!=2] <- 0

hudson$Mainstream_Retired[hudson$segment==3] <- 1 
hudson$Mainstream_Retired[hudson$segment!=3] <- 0

hudson$Mass_Affluent_Families[hudson$segment==4] <- 1 
hudson$Mass_Affluent_Families[hudson$segment!=4] <- 0

hudson$Mass_Affluent_Retired[hudson$segment==5] <- 1 
hudson$Mass_Affluent_Retired[hudson$segment!=5] <- 0

hudson$Not_Coded[hudson$segment==6] <- 1 
hudson$Not_Coded[hudson$segment!=6] <- 0

hudson$deposits <-  pmax(hudson$dda,hudson$mms,hudson$sav,hudson$tda,hudson$ira)
hudson$dep_amt <-  (hudson$DDA_Amt+hudson$MMS_amt+hudson$sav_amt+hudson$TDA_Amt+hudson$IRA_amt)

hudson$loans <-  pmax(hudson$mtg,hudson$heq,hudson$iln)
hudson$loan_amt <-  (hudson$MTG_amt+hudson$HEQ_Amt+hudson$iln_amt)

hudson$secure <- pmax(hudson$loans,hudson$heq)

hudson$both <- pmax(hudson$mtg,hudson$deposits)
hudson$both_amt <- pmax(hudson$loan_amt,hudson$dep_amt)

hudson$atm_num <- hudson$ATM_WD_HUDSON + hudson$ATM_WD_OTHER
hudson$atm_amt <- 0
hudson$deb_amt <- 0
hudson$deb_num <- hudson$DEBIT_PURCH
hudson$products <- hudson$dda + hudson$mms +hudson$sav +hudson$tda +hudson$ira +hudson$mtg +hudson$heq +hudson$ILN

hudson$age_18_to_25 <- 0
hudson$age_36_to_45 <- 0
hudson$age_46_to_55 <- 0
hudson$age_56_to_65 <- 0
hudson$age_86_ <- 0
hudson$age_76_to_85 <- 0
hudson$age_66_to_75 <- 0
hudson$age_26_to_35 <- 0
hudson$age_Up_to_17 <- 0

hudson$age_18_to_25[hudson$age %in% 18:25 ] <- 1
hudson$age_36_to_45[hudson$age %in% 36:45 ] <- 1
hudson$age_46_to_55[hudson$age %in% 46:55 ] <- 1
hudson$age_56_to_65[hudson$age %in% 56:65 ] <- 1
hudson$age_86_[hudson$age %in% 86:1000 ] <- 1
hudson$age_76_to_85[hudson$age %in% 76:85 ] <- 1
hudson$age_66_to_75[hudson$age %in% 66:75 ] <- 1
hudson$age_26_to_35[hudson$age %in% 26:35 ] <- 1
hudson$age_Up_to_17[hudson$age %in% 1:17 ] <- 1

hudson$mpos_amt <- 0;
hudson$mpos_num <- hudson$deb_num;

hudson$sec <- hudson$sec_Amt <- 0

hudson$steady <- 0
hudson$steady[hudson$tenure_yr>=2.5] <- 1



save(hudson,file="hudson.RData")

hudson<- hudson[order(hudson$steady),]
load("rf_non_final.RData")
non1 <- predict(rf_non_final,newdata=hudson[hudson$steady==0,][1:25000,],type="class")
non2 <- predict(rf_non_final,newdata=hudson[hudson$steady==0,][25001:50000,],type="class")
non3 <- predict(rf_non_final,newdata=hudson[hudson$steady==0,][50001:63339,],type="class")
non <- unlist(list(non1,non2,non3))
rm(rf_non_final)
save(non,file="non.RData")
rm(non)

save(names,file="names.RData")

load("Final_forest.Rdata")
for (i in 1:10) {
  load("hudson.RData")
  data <- hudson[hudson$steady==1,][((i-1)*20000 + 1):min((i*20000),196039),]
  rm(hudson)
  assign(paste("steady",i,sep=""),predict(final_forest,newdata=data,type="class"))
  rm(data)
}
steady<-unlist(list(steady1,steady2,steady3,steady4,steady5,steady6,steady7,steady8,steady9,steady10))
save(steady,file="steady.RData")
rm(steady1,steady2,steady3,steady4,steady5,steady6,steady7,steady8,steady9,steady10,i)

load("non.Rdata")
all<- unlist(list(non,steady))

load("hudson.RData")
hudson$clv_pred <- all
save(hudson,file="hudson.RData")


#now move to sas and do a profile by H M L;
write.csv(hudson[,c(1,125)],"hudson_clv.csv")