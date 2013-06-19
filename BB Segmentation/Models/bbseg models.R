library("RODBC")
myconn <- odbcConnect(dsn="SASODBC",believeNRows=FALSE, colQuote=NULL)
train <- sqlQuery(myconn,"select * from bbseg.customer_data_orig where acct_comm_bnk_mkt <> .")
odbcCloseAll()
rm(myconn)

names(train)

exclude <- c(names(train)[43:56],"E63_r","E41_SIC","identifier","PID")
#fix HEQC_AMT;
train$HEQC_AMT[is.na(train$HEQC_AMT)] <- 0;

setwd("C:/Documents and Settings/ewnym5s/My Documents/My Projects/BB Segmentation/Models")

#reorder data so segmewnt is the first element;
train <- train[,c(2,1,3:97)]

exclude1 <- c(4,5,7,10,11:20)
train <- train[,-exclude1]
save(train,file="train.RData")
load("train.RData")

#let's visualize data
library(ggplot2)
library(reshape2)


#+facet_grid(segment~variable,as.table=T)
pdf(file="exploratory charts.pdf",width=10, height=7.5,paper="USr")
for (i in 1:11) {
  minv <- (i-1)*9 + 2;
  maxv <- min((i-1)*9 + 10,97);
  
  chartdata <- melt(train[,c(1,minv:maxv)],id.vars="segment")
  chartdata$segment <- factor(chartdata$segment,levels=c(1,2,3,4,5,6),labels=c("Simple & Stable","Successful Service-Dependent","Stable 
Underserved","Content & Well Served","Complex & Extended Mgmt."  ,"Sophisticated & Demanding"))
  p <- ggplot(data=chartdata,aes(x=segment,y=value,color=segment))+geom_jitter()+facet_wrap(~variable)+ggtitle(paste("Panel #",i))
  p <- p + theme(legend.position="bottom",axis.text.x=element_blank(),axis.text.y=element_blank(),axis.ticks=element_blank())
  p <- p+ guides(col=guide_legend(nrow=2))
  print(p)
}
dev.off()



train$segment <- factor(train$segment,levels=c(1,2,3,4,5,6),labels=c("Simple & Stable","Successful Service-Dependent","Stable 
Underserved","Content & Well Served","Complex & Extended Mgmt."  ,"Sophisticated & Demanding"))

train$A <- 0
train$A[train$E62_d=='A'] <-1
train$B <- 0
train$B[train$E62_d=='B'] <-1
train$C <- 0
train$C[train$E62_d=='C'] <-1
train$D <- 0
train$D[train$E62_d=='D'] <-1

train_unscaled <- train
save(train_unscaled,file="train_original.RData")




##################################################################;
#READ NEW DATA ###############

library("RODBC")
myconn <- odbcConnect(dsn="SASODBC",believeNRows=FALSE, colQuote=NULL)
train <- sqlQuery(myconn,"select * from bbseg.model_training")
odbcCloseAll()
rm(myconn)

train$segment <- factor(train$segment,levels=c(1,2,3,4,5,6),labels=c("Simple & Stable","Successful Service-Dependent","Stable 
Underserved","Content & Well Served","Complex & Extended Mgmt."  ,"Sophisticated & Demanding"))

seg_names <- c("Simple & Stable","Successful Service-Dependent","Stable Underserved","Content & Well Served","Complex & Extended Mgmt."  ,"Sophisticated & Demanding")




#let's visualize data
library(ggplot2)
library(reshape2)


#+facet_grid(segment~variable,as.table=T)
pdf(file="exploratory charts.pdf",width=10, height=7.5,paper="USr")
for (i in 1:12) {
  minv <- (i-1)*9 + 2;
  maxv <- min((i-1)*9 + 10,105);
  
  chartdata <- melt(train[,c(1,minv:maxv)],id.vars="segment")
  p <- ggplot(data=chartdata,aes(x=segment,y=value,color=segment))+geom_jitter()+facet_wrap(~variable)+ggtitle(paste("Panel #",i))
  p <- p + theme_bw()+ theme(legend.position="bottom",axis.text.x=element_blank(),axis.text.y=element_blank(),axis.ticks=element_blank())
  p <- p+ guides(col=guide_legend(nrow=2))
  print(p)
}
dev.off()

temp <- train[,-1]
temp <- temp[,colSums(temp)!=0]
pc <- prcomp(temp,scale=TRUE,center=TRUE)
screeplot(pc,type="lines")
pc1 <- pc$rotation[,1]
library(car)
order(pc1)

biplot(pc)

pc1 <- princomp(temp,cor=T)
summary(pc1)
plot(pc1)
biplot(pc1)

summary(pc)


#not going anywhere, I need to learn more about this first;

#lets do some logistic models;

train_unscaled <- train
save(train_unscaled,file="train_original.RData")



num1 <- sapply(train,is.numeric)
train_num <- train_unscaled[,num1]
train_non_num <- as.data.frame(train_unscaled[,!num1])
names(train_non_num) <- "segment"
min1 <- apply(train_num,2,min) 
max1 <- apply(train_num,2,max) 
min2 <- min1 == 0
max2 <- max1 == 1
not1 <- max2 * min2
not1[c(5,6,7,8,18,38,63)] <- 1 #exclude some that are 1/0 but all zero;
not2 <- min1==max1
not1[not2==T] <- 1; #exclude those that min=max, to take out bals all eq 0;
not1==0
train_scaled <- as.data.frame(scale(train_num[,not1==0]))
train_scaled <- cbind(train_non_num,train_scaled,train_num[not1==1])
save(train_scaled,file="train_scaled.RData")
  
load("train_scaled.RData")

train <- train_scaled


train$s1 <- train$s2 <- train$s3 <- train$s4 <- train$s5 <-train$s6 <- 0;
train$s1[train$segment=="Simple & Stable"] <-1
train$s2[train$segment==levels(train$segment)[2]] <-1
train$s3[train$segment==levels(train$segment)[3]] <-1
train$s4[train$segment==levels(train$segment)[4]] <-1
train$s5[train$segment==levels(train$segment)[5]] <-1
train$s6[train$segment==levels(train$segment)[6]] <-1

temp <- train[,-1]
temp <- temp[,colSums(temp)!=0]

include <- names(which(colSums(temp)!=0 ))
include <- include[!include %in% c("s1","s2","s3","s4","s5","s6")] 


log_s1 <- glm(s1~.,data=train[,c("s1",include)],family=binomial(logit))
pred <- data.frame(s1p=log_s1$fitted)


log_s2 <- glm(s2~.,data=train[,c("s2",include)],family=binomial(logit))
pred$s2p <- log_s2$fitted


log_s3 <- glm(s3~.,data=train[,c("s3",include)],family=binomial(logit),control = list(maxit = 50))
pred$s3p <- log_s3$fitted


log_s4 <- glm(s4~.,data=train[,c("s4",include)],family=binomial(logit))
pred$s4p <- log_s4$fitted

log_s5 <- glm(s5~.,data=train[,c("s5",include)],family=binomial(logit))
pred$s5p <- log_s5$fitted

log_s6 <- glm(s6~.,data=train[,c("s6",include)],family=binomial(logit))
pred$s6p <- log_s6$fitted

pred$max <- apply(pred,1,max)
pred$which <- apply(pred[,1:6],1,which.max)
pred$which[pred$max < 0.5] <- 0
pred$which <- factor(pred$which,levels=c(0,1,2,3,4,5,6),labels=c("none",seg_names))

pred$max1 <- pred$max
pred$which1 <- apply(pred[,1:6],1,which.max)
pred$which1 <- factor(pred$which1,levels=c(1,2,3,4,5,6),labels=seg_names)

table1 <- round(prop.table(table(pred$which,train$segment,dnn=c("predicted","actual")))*100,1)
save(table1,pred,log_s1,log_s2,log_s3,log_s4,log_s5,log_s6,include,seg_names,file="logistic_models_scaled.RData")

load ("logistic_models_scaled.RData")
load ("train.RData")

pred1 <- log_s1$fitted
chartdata <- data.frame(score=pred1,actual=train$s1,segment=train$segment)
chartdata$pred[chartdata$score>= 0.5] <- 1
chartdata$pred[chartdata$score< 0.5] <- 0
chartdata$pred <- factor(chartdata$pred,levels=c(0,1),labels=c("No","Yes"))
combined <- chartdata
combined$model <- "segment 1"
g1 <- ggplot(data=chartdata,aes(x=pred1,y=V2,color=pred))+geom_point(position = position_jitter(w = 0.1, h = 0.1))
g1 <- g1 +xlab("Score")+ylab("Actual")+ggtitle("Model for Segment 1")
g1;
matrix1 <- round(prop.table(table(chartdata$pred,chartdata$V2,dnn=c("Predicted","Actual")))*100,1)
error1 = matrix1[1,2]+matrix1[2,1]

pred2 <- log_s2$fitted
chartdata <- data.frame(score=pred2,actual=train$s2,segment=train$segment)
chartdata$pred[chartdata$score>= 0.5] <- 1
chartdata$pred[chartdata$score< 0.5] <- 0
chartdata$pred <- factor(chartdata$pred,levels=c(0,1),labels=c("No","Yes"))
chartdata$model <- "segment 2"
combined <- rbind(combined,chartdata)
g2 <- ggplot(data=chartdata,aes(x=pred2,y=V2,color=pred))+geom_point(position = position_jitter(w = 0.1, h = 0.1))
g2 <- g2 +xlab("Score")+ylab("Actual")+ggtitle("Model for Segment 2")
g2;
matrix2 <- round(prop.table(table(chartdata$pred,chartdata$V2,dnn=c("Predicted","Actual")))*100,1)
error2 = matrix2[1,2]+matrix2[2.1]

pred3 <- log_s3$fitted
chartdata <- data.frame(score=pred3,actual=train$s3,segment=train$segment)
chartdata$pred[chartdata$score>= 0.5] <- 1
chartdata$pred[chartdata$score< 0.5] <- 0
chartdata$pred <- factor(chartdata$pred,levels=c(0,1),labels=c("No","Yes"))
chartdata$model <- "segment 3"
combined <- rbind(combined,chartdata)
g3 <- ggplot(data=chartdata,aes(x=pred3,y=V2,color=pred))+geom_point(position = position_jitter(w = 0.1, h = 0.1))
g3 <- g3 +xlab("Score")+ylab("Actual")+ggtitle("Model for Segment 3")
g3;
matrix3 <- round(prop.table(table(chartdata$pred,chartdata$V2,dnn=c("Predicted","Actual")))*100,1)
error3 = matrix3[1,2]+matrix3[2,1]

pred4 <- log_s4$fitted
chartdata <- data.frame(score=pred4,actual=train$s4,segment=train$segment)
chartdata$pred[chartdata$score>= 0.5] <- 1
chartdata$pred[chartdata$score< 0.5] <- 0
chartdata$pred <- factor(chartdata$pred,levels=c(0,1),labels=c("No","Yes"))
chartdata$model <- "segment 4"
combined <- rbind(combined,chartdata)
g4 <- ggplot(data=chartdata,aes(x=pred4,y=V2,color=pred))+geom_point(position = position_jitter(w = 0.1, h = 0.1))
g4 <- g4 +xlab("Score")+ylab("Actual")+ggtitle("Model for Segment 4")
g4;
matrix4 <- round(prop.table(table(chartdata$pred,chartdata$V2,dnn=c("Predicted","Actual")))*100,1)
error4 = matrix4[1,2]+matrix4[2,1]

pred5 <- log_s5$fitted
chartdata <- data.frame(score=pred5,actual=train$s5,segment=train$segment)
chartdata$pred[chartdata$score>= 0.5] <- 1
chartdata$pred[chartdata$score< 0.5] <- 0
chartdata$pred <- factor(chartdata$pred,levels=c(0,1),labels=c("No","Yes"))
chartdata$model <- "segment 5"
combined <- rbind(combined,chartdata)
g5 <- ggplot(data=chartdata,aes(x=pred5,y=V2,color=pred))+geom_point(position = position_jitter(w = 0.1, h = 0.1))
g5 <- g5 +xlab("Score")+ylab("Actual")+ggtitle("Model for Segment 5")
g5;
matrix5 <- round(prop.table(table(chartdata$pred,chartdata$V2,dnn=c("Predicted","Actual")))*100,1)
error5 = matrix5[1,2]+matrix5[2,1]

pred6 <- log_s6$fitted
chartdata <- data.frame(score=pred6,actual=train$s6,segment=train$segment)
chartdata$pred[chartdata$score>= 0.5] <- 1
chartdata$pred[chartdata$score< 0.5] <- 0
chartdata$pred <- factor(chartdata$pred,levels=c(0,1),labels=c("No","Yes"))
chartdata$model <- "segment 6"
combined <- rbind(combined,chartdata)
g6 <- ggplot(data=chartdata,aes(x=pred6,y=V2,color=pred))+geom_point(position = position_jitter(w = 0.1, h = 0.1))
g6 <- g6 +xlab("Score")+ylab("Actual")+ggtitle("Model for Segment 6")
g6;
matrix6 <- round(prop.table(table(chartdata$pred,chartdata$V2,dnn=c("Predicted","Actual")))*100,1)
error6 = matrix6[1,2]+matrix6[2,1]

combined$model[combined$model=="segment 1"]<-"Simple and Stable (Error=15.4%)"
combined$model[combined$model=="segment 2"]<-"Succes. & Svc Dep (Error=18.9%)"
combined$model[combined$model=="segment 3"]<-"Stable and Underserv (Error=0.0%)"
combined$model[combined$model=="segment 4"]<-"Cont & Well Svd (Error=18.2%)"
combined$model[combined$model=="segment 5"]<-"Cmplx & ext Mgmt (Error=8.2%)"
combined$model[combined$model=="segment 6"]<-"Soph & Demand (Error=10.7%)"

combined$actual <- factor(combined$actual,levels=c(0,1),labels=c("No","Yes"))
g_all <- ggplot(data=combined,aes(x=score,y=actual,color=segment,shape=pred))+geom_point(position = position_jitter(w = 0.1, h = 0.1))+theme_bw()
g_all <- g_all +xlab("Score")+ylab("Actual")+facet_wrap(~ model)+ggtitle("Overview of Model Accuracy")+theme(legend.position="bottom")
g_all <- g_all + scale_color_manual(values=c("#FFB300","#007856","#C3E76F","#86499D","#003359","#AFAAA3"),name="Actual Segment")+geom_vline(xintercept=0.5)
g_all <- g_all + scale_shape_manual(values=c(21,19),name="Prediction")+guides(col=guide_legend(nrow=2))
g_all;

all <- data.frame(predicted = pred$which, actual=train$segment)
levels(all$predicted) <- c("None","Simple \n& Stable","Successful \nService-\nDependent",
                           "Stable \nUnderserved","Content \n& Well Served" ,"Complex & \nExtended Mgmt.","Sophisticated &\n Demanding")
levels(all$actual) <- c("Simple \n& Stable","Successful \nService-\nDependent",
                           "Stable \nUnderserved","Content \n& Well Served" ,"Complex & \nExtended Mgmt.","Sophisticated &\n Demanding")

g_all1 <- ggplot(data=all,aes(x=predicted,y=actual,color=actual))+geom_point(position = position_jitter(w = 0.2, h = 0.2))+theme_bw()
g_all1 <- g_all1 +xlab("Predicted")+ylab("Actual")+ggtitle("Overview of Model Accuracy - Combined")+theme(legend.position="bottom")
g_all1 <- g_all1 + scale_color_manual(values=c("#FFB300","#007856","#C3E76F","#86499D","#003359","#AFAAA3"),name="Actual Segment")
g_all1 <- g_all1 + guides(col=guide_legend(nrow=2))
g_all1;

all2 <- data.frame(predicted = pred$which1, actual=train$segment)
levels(all2$predicted) <- c("Simple \n& Stable","Successful \nService-\nDependent",
                           "Stable \nUnderserved","Content \n& Well Served" ,"Complex & \nExtended Mgmt.","Sophisticated &\n Demanding")
levels(all2$actual) <- c("Simple \n& Stable","Successful \nService-\nDependent",
                        "Stable \nUnderserved","Content \n& Well Served" ,"Complex & \nExtended Mgmt.","Sophisticated &\n Demanding")

g_all2 <- ggplot(data=all2,aes(x=predicted,y=actual,color=actual))+geom_point(position = position_jitter(w = 0.2, h = 0.2))+theme_bw()
g_all2 <- g_all2 +xlab("Predicted")+ylab("Actual")+ggtitle("Overview of Model Accuracy - Combined (Max Value)")+theme(legend.position="bottom")
g_all2 <- g_all2 + scale_color_manual(values=c("#FFB300","#007856","#C3E76F","#86499D","#003359","#AFAAA3"),name="Actual Segment")
g_all2 <- g_all2 + guides(col=guide_legend(nrow=2))
g_all2;


all2_matrix <- round(prop.table(table(pred$which1,train$segment,dnn=c("Predicted","Actual")))*100,1)

library(gridExtra)
library(vcd)

mosaic(non_matrix_train,main="Individual Log Models all variables",pop=F,gp=gpar(cex=0.5,))
labeling_cells(text = table1, margin = 0)(table1);


#cross validation;
cv_s1 <- cv.glm(train[,c("s1",include)],log_s1)
cv_s2 <- cv.glm(train[,c("s2",include)],log_s2)
cv_s3 <- cv.glm(train[,c("s3",include)],log_s3)
cv_s4 <- cv.glm(train[,c("s4",include)],log_s4)
cv_s5 <- cv.glm(train[,c("s5",include)],log_s5)
cv_s6 <- cv.glm(train[,c("s6",include)],log_s6)

cv_err <- numeric(6)
cv_err <- c(cv_s1$delta[2],cv_s2$delta[2],cv_s3$delta[2],cv_s4$delta[2],cv_s5$delta[2],cv_s6$delta[2])
names(cv_err) <- c("s1","s2","s3","s4","s5","s6")
sapply(cv_err, function(x) {paste(round(100*x,1),"%",sep="")})

pdf("model diagnostics.pdf",width=11,height=8.5, paper="USr")
par(mfrow=c(2,2))
plot(log_s1,main="Model 1")
plot(log_s2,main="Model 2")
plot(log_s3,main="Model 3")
plot(log_s4,main="Model 4")
plot(log_s5,main="Model 5")
plot(log_s6,main="Model 6")
dev.off()

step1 <- stepAIC(log_s1,direction="backward")
step2 <- stepAIC(log_s2,direction="backward")
step3 <- stepAIC(log_s3,direction="backward")
step4 <- stepAIC(log_s4,direction="backward")
step5 <- stepAIC(log_s5,direction="backward")
step6 <- stepAIC(log_s6,direction="backward")

pred_back <- data.frame(s1=step1$fitted,s2=step2$fitted,s3=step3$fitted,s4=step4$fitted,s5=step5$fitted,s6=step6$fitted)
max_back <- apply(pred_back,1,max)
which.back <- apply(pred_back,1,which.max)
pred_back$segment <- train$segment
pred_back$max <- max_back
pred_back$which <- which.back
pred_back$which <- factor(pred_back$which,levels=c(1,2,3,4,5,6),labels=seg_names)

g_all3 <- ggplot(data=pred_back,aes(x=which,y=segment,color=segment))+geom_point(position = position_jitter(w = 0.2, h = 0.2))+theme_bw()
g_all3 <- g_all3 +xlab("Predicted")+ylab("Actual")+ggtitle("Overview of Backward Model Accuracy - Combined (Max Value)")+theme(legend.position="bottom")
g_all3 <- g_all3 + scale_color_manual(values=c("#FFB300","#007856","#C3E76F","#86499D","#003359","#AFAAA3"),name="Actual Segment")
g_all3 <- g_all3 + guides(col=guide_legend(nrow=2))
g_all3;

save(step1,step2,step3,step4,step5,step6,file="backward_models.RData")

pred <- log1f$fitted
pred[pred>=0.5] <- 1
pred[pred<0.5] <- 0
a <- prop.table(table(pred,train$s1))
round((1-sum(diag(a)))*100,1)

#do quasi on 5 and 6;
log_q5 <- glm(s5~.,data=train[,c("s5",include)],family=quasibinomial(logit),control = list(maxit = 50))
pred$q5p <- log_s5$fitted

log_q6 <- glm(s6~.,data=train[,c("s6",include)],family=quasibinomial(logit),control = list(maxit = 50))
pred$q6p <- log_s6$fitted
library(car)

log_q5b <- glm(formula = s5 ~ dda_amt + mms_amt + sav_amt + tda_amt + heqc_amt + 
                 cln_amt + baloc_amt + cls_amt + mcc_amt + tenure + sign_ons + 
                 checks + atmo_num + atmt_num + atmo_amt + atmt_amt + vpos_num + 
                 mpos_num + vpos_amt + mpos_amt + deptkt + curdep_num + curdep_amt + 
                 chkpd + ach + winfo_num + cb_dist + br_tran_num + br_tran_amt + 
                 vru_num + nsf + chks_dep + wire_in + wire_out + dda_con + 
                 mms_con + sav_con + tda_con + heqc_con + cln_con + boloc_con + 
                 baloc_con + tenure_yr + contrib1 + dda + mms + sav + tda + 
                 trs + heqc + cln + card + boloc + baloc + cls + wbb + deb + 
                 mcc + lckbx + rcd + bbfb + con + com + web_info + svcs + 
                 rcd_num + top40 + rm + cv0 + cr6 + cash_mgmt + a + c + d + 
                 X_10_to_20mm + X_2p5_to_5mm + X_20_to_50mm + X_50_to_100mm + 
                 to500k + e_1to4 + e_10_19 + e_100_249 + e_20_49 + e_50_99, 
               family = quasibinomial(logit), data = train[, c("s5", include)],,control = list(maxit = 50))

log_q6b <- glm(formula = s6 ~ dda_amt + mms_amt + sav_amt + tda_amt + heqc_amt + 
                cln_amt + baloc_amt + cls_amt + mcc_amt + tenure + sign_ons + 
                checks + atmo_num + atmt_num + atmo_amt + atmt_amt + vpos_num + 
                mpos_num + vpos_amt + mpos_amt + deptkt + curdep_num + curdep_amt + 
                chkpd + ach + winfo_num + cb_dist + br_tran_num + br_tran_amt + 
                vru_num + nsf + chks_dep + wire_in + wire_out + dda_con + 
                mms_con + sav_con + tda_con + heqc_con + cln_con + boloc_con + 
                baloc_con + tenure_yr + contrib1 + dda + mms + sav + tda + 
                trs + heqc + cln + card + boloc + baloc + cls + wbb + deb + 
                mcc + lckbx + rcd + bbfb + con + com + web_info + rcd_num + 
                top40 + rm + cv0 + cr6 + cash_mgmt + a + b + c + d + X_1_to_2mm + 
                X_10_to_20mm + X_2p5_to_5mm + X_20_to_50mm + X_5_to_10mm + 
                X_50_to_100mm + X_500k_to_1mm + to500k + e_1to4 + e_10_19 + 
                e_100_249 + e_20_49 + e_5_9 + e_50_99, family = quasibinomial(logit), 
              data = train[, c("s6", include)],,control = list(maxit = 60))

pred_back1 <- data.frame(s1=step1$fitted,s2=step2$fitted,s3=step3$fitted,s4=step4$fitted,s5=log_q5b$fitted,s6=log_q6b$fitted)
max_back <- apply(pred_back1,1,max)
which.back <- apply(pred_back1,1,which.max)
pred_back1$segment <- train$segment
pred_back1$max <- max_back
pred_back1$which <- which.back
pred_back1$which <- factor(pred_back1$which,levels=c(1,2,3,4,5,6),labels=seg_names)

levels(pred_back1$which) <- c("Simple \n& Stable","Successful \nService-\nDependent",
                            "Stable \nUnderserved","Content \n& Well Served" ,"Complex & \nExtended Mgmt.","Sophisticated &\n Demanding")
levels(pred_back1$segment) <- c("Simple \n& Stable","Successful \nService-\nDependent",
                         "Stable \nUnderserved","Content \n& Well Served" ,"Complex & \nExtended Mgmt.","Sophisticated &\n Demanding")

g_all4 <- ggplot(data=pred_back1,aes(x=which,y=segment,color=segment))+geom_point(position = position_jitter(w = 0.2, h = 0.2))+theme_bw()
g_all4 <- g_all4 +xlab("Predicted")+ylab("Actual")+ggtitle("Overview of Backward Model Accuracy - Combined (Max Value)")+theme(legend.position="bottom")
g_all4 <- g_all4 + scale_color_manual(values=c("#FFB300","#007856","#C3E76F","#86499D","#003359","#AFAAA3"),name="Actual Segment")
g_all4 <- g_all4 + guides(col=guide_legend(nrow=2))
g_all4;
back_table <- table(pred_back1$which,pred_back1$segment,dnn=c("Predicted","Actual"))
back_table_f <- round(prop.table(table(pred_back1$which,pred_back1$segment,dnn=c("Predicted","Actual")))*100,1)
sum(diag(back_table_f))
100-sum(diag(back_table_f))
rows <- round(100*back_table/rowSums(back_table),1)
cols <- round(100*back_table/colSums(back_table),1)

rowSums(round(prop.table(back_table,1)*100,5))-diag(back_table_f)

colSums(round(prop.table(back_table,2)*100,1))-diag(back_table_f)

save(step1,step2,step3,step4,step5,step6,log_q5b,log_q6b,file="backward_models.RData")
########FOREST;

library(randomForest)
names(train) <- make.names(tolower(names(train)))
model_data <- train
model_data$s1 <- factor(model_data$s1)
model_data$s2 <- factor(model_data$s2)
model_data$s3 <- factor(model_data$s3)
model_data$s4 <- factor(model_data$s4)
model_data$s5 <- factor(model_data$s5)
model_data$s6 <- factor(model_data$s6)

rf1 <- randomForest(s1 ~ .,data=model_data[,c("s1",include)],ntree=501)
rf2 <- randomForest(s2 ~ .,data=model_data[,c("s2",include)],ntree=501)
rf3 <- randomForest(s3 ~ .,data=model_data[,c("s3",include)],ntree=501)
rf4 <- randomForest(s4 ~ .,data=model_data[,c("s4",include)],ntree=501)
rf5 <- randomForest(s5 ~ .,data=model_data[,c("s5",include)],ntree=501)
rf6 <- randomForest(s6 ~ .,data=model_data[,c("s6",include)],ntree=501)

save(model_data,rf1,rf2,rf3,rf4,rf5,rf6,include,file="Indiv_forests.RData")

#neural network;

library(neuralnet)
library(nnet)

temp <- train_unscaled[,-1]
temp <- temp[,colSums(temp)!=0]

include <- names(which(colSums(temp)!=0 ))
include=c("segment",include)


nn_10 <- nnet(segment ~ .,data=train_unscaled[,include],size=10)
pred_nn_10 <- nn_10$fitted
pred_nn_10 <- apply(pred_nn_10,1,which.max)
pred_nn_10 <- factor(pred_nn_10,levels=c(1,2,3,4,5,6),labels=seg_names)
nn_10_table <- round(prop.table(table(train_unscaled$segment,pred_nn_10,dnn=c("Actual","Predicted")))*100,1)

#basic tree
library(tree)
tree_all <- tree(segment ~ .,data=train_unscaled[,c("segment",include)])
library(ggplot2)
tree_table <- round(prop.table(table(predict(tree_all,type=c("class")),train$segment,dnn=c("Predicted","Actual")))*100,1)
chart1 <- data.frame(predicted=predict(tree_all,type=c("class")),actual=train$segment)
levels(chart1$predicted) <- levels(chart1$actual) <- c("Simple \n& Stable","Successful \nService-\nDependent",
                      "Stable \nUnderserved","Content \n& Well Served" ,"Complex & \nExtended Mgmt.","Sophisticated &\n Demanding")

chart1$match[chart1$actual==chart1$predicted] <- "Yes" 
chart1$match[chart1$actual!=chart1$predicted] <- "No"


pdf(file="Tree Model for 6 Segments.pdf",width=10.5, height=8,paper="USr")
ch1 <- ggplot(data=chart1,aes(x=actual,y=predicted,color=actual,shape=match))+geom_jitter(position = position_jitter(w = 0.2, h = 0.2))
ch1<- ch1 + theme_bw() +theme(legend.position="bottom",plot.title = element_text(size=14,color="blue", face="bold"))+ scale_color_manual(values=c("#FFB300","#007856","#C3E76F","#86499D","#003359","#AFAAA3"),name="Actual Segment")
ch1 <- ch1 + scale_shape_manual(values=c(4,19),name="Correct Prediction")+ guides(col=guide_legend(nrow=2))+ylab("Predicted")+xlab("Actual")
ch1 <- ch1 + ylab("Predicted")+xlab("Actual")
ch1
dev.off()

sum(diag(tree_table))
aux <- tree_table
diag(aux) <- 0
colSums(aux)
tree_table2 <-table(predict(tree_all,type=c("class")),train$segment,dnn=c("Predicted","Actual"))
sums_all <- colSums(tree_table2)
diag(tree_table2) <- 0
round(100*(1-(colSums(tree_table2)/sums_all)),1) #THIS IS ACCURACY BY SEGMENT;

tree_data <- train_unscaled #used to be just train
#tree_data$s1 <- factor(tree_data$s1,levels=c(0,1),labels=c("No","Yes")); #I had modified this on unscaled, by mistake
tree_data$s2 <- factor(tree_data$s2,levels=c(0,1),labels=c("No","Yes"))
tree_data$s3 <- factor(tree_data$s3,levels=c(0,1),labels=c("No","Yes"))
tree_data$s4 <- factor(tree_data$s4,levels=c(0,1),labels=c("No","Yes"))
tree_data$s5 <- factor(tree_data$s5,levels=c(0,1),labels=c("No","Yes"))
tree_data$s6 <- factor(tree_data$s6,levels=c(0,1),labels=c("No","Yes"))


treeStats <- function(x) {
  accuracy <- round(sum(diag(x)),1)
  recall <- round(100*x[2,2]/(x[2,2]+x[1,2]),1)
  precision <- round(100*x[2,2]/(x[2,2]+x[2,1]))
  f1 = round(2*(precision*recall)/(precision+recall),1)
  result <- c(accuracy, precision, recall,f1)
  names(result) <- c("accuracy", "precision", "recall","f1")
  return(result)
}



panel_data <- data.frame(model=NA,actual=NA,predicted=NA,segment=NA)
panel_data <- panel_data[-1,]
for (i in 1:6) {
  vdata <- tree_data[,c(paste(sep="","s",i),include)]
  form <- formula(paste(sep="","s",i," ~ ."))
  tree <- tree(form, data = vdata,y=T)
  assign(paste(sep="","tree_",i),tree)
  assign(paste(sep="","tree_table_",i),round(prop.table(table(predict(tree,type=c("class")),tree_data[,paste(sep="","s",i)],dnn=c("Predicted","Actual")))*100,1))
  temp_frame <- data.frame(model=seg_names1[i],actual=tree_data[,paste(sep="","s",i)],predicted=predict(tree,type=c("class")),segment=train$segment)
  panel_data <- rbind(panel_data,temp_frame)
}


tree_1a <- ctree(s1 ~ ., data = vdata)

summary <- rbind(treeStats(tree_table_1),treeStats(tree_table_2),treeStats(tree_table_3),treeStats(tree_table_4),treeStats(tree_table_5),treeStats(tree_table_6))
row.names(summary) <- seg_names1

panel_data$match[panel_data$actual==panel_data$predicted] <- "Yes" 
panel_data$match[panel_data$actual!=panel_data$predicted] <- "No"

pdf(file="Individual Tree Models.pdf",width=10.5, height=8,paper="USr")
ch2 <- ggplot(data=panel_data,aes(x=actual,y=predicted,color=segment,shape=match))+geom_jitter()+facet_wrap(~model)+theme_bw()
ch2 <- ch2 + scale_color_manual(values=c("#FFB300","#007856","#C3E76F","#86499D","#003359","#AFAAA3"),name="Actual Segment")
ch2 <- ch2 + guides(col=guide_legend(nrow=2))+ylab("Predicted")+xlab("Actual")
ch2 <- ch2 + scale_shape_manual(values=c(4,19),name="Correct Prediction")+theme(legend.position="bottom",plot.title = element_text(size=14,color="blue", face="bold"))
ch2
dev.off()

treeStats(tree_table_2)



source("C:/Documents and Settings/ewnym5s/My Documents/R/plotTree.R")
t_all <- plotTree(tree_all)
t1 <- plotTree(tree_1)
t2 <- plotTree(tree_2)
t3 <- plotTree(tree_3)
t4 <- plotTree(tree_4)
t5 <- plotTree(tree_5)
t6 <- plotTree(tree_6)

source("C:/Documents and Settings/ewnym5s/My Documents/R/makeFootnote.R")
pdf(file="Tree Model Charts.pdf",width=10, height=8,paper="USr",onefile=T)
  ch1+ggtitle("6 Segment Tree Performance")+theme(plot.title = element_text(size=14,color="blue", face="bold"),plot.margin=unit(c(1,1,1,1), "cm"))
  makeFootnote_left("Figures Page 1 of 9")
  makeFootnote_right("M&T Bank - Customer Insights")
  ch2+ggtitle("Individual Segment Tree Performance")+theme(plot.title = element_text(size=14,color="blue", face="bold"),plot.margin=unit(c(1,1,1,1), "cm"))
  makeFootnote_left("Figures Page 2 of 9")
  makeFootnote_right("M&T Bank - Customer Insights")
  t_all+ggtitle("6 Segment Tree Diagram")+theme(plot.title = element_text(size=14,color="blue", face="bold"))
  makeFootnote_left("Figures Page 3 of 9")
  makeFootnote_right("M&T Bank - Customer Insights")
  t1+ggtitle("Segment 1 Tree Diagram")+theme(plot.title = element_text(size=14,color="blue", face="bold"))
  makeFootnote_left("Figures Page 4 of 9")
  makeFootnote_right("M&T Bank - Customer Insights")
  t2+ggtitle("Segment 2 Tree Diagram")+theme(plot.title = element_text(size=14,color="blue", face="bold"))
  makeFootnote_left("Figures Page 5 of 9")
  makeFootnote_right("M&T Bank - Customer Insights")
  t3+ggtitle("Segment 3 Tree Diagram")+theme(plot.title = element_text(size=14,color="blue", face="bold"))
  makeFootnote_left("Figures Page 6 of 9")
  makeFootnote_right("M&T Bank - Customer Insights")
  t4+ggtitle("Segment 4 Tree Diagram")+theme(plot.title = element_text(size=14,color="blue", face="bold"))
  makeFootnote_left("Figures Page 7 of 9")
  makeFootnote_right("M&T Bank - Customer Insights")
  t5+ggtitle("Segment 5 Tree Diagram")+theme(plot.title = element_text(size=14,color="blue", face="bold"))
  makeFootnote_left("Figures Page 8 of 9")
  makeFootnote_right("M&T Bank - Customer Insights")
  t6+ggtitle("Segment 6 Tree Diagram")+theme(plot.title = element_text(size=14,color="blue", face="bold"))
  makeFootnote_left("Figures Page 9 of 9")
  makeFootnote_right("M&T Bank - Customer Insights")
dev.off()



library(ggdendro)
library(odfWeave)
tree_data <- dendro_data(tree_4)
labels <- as.matrix(as.character(tree_data$labels$label),nrow=1)
splits <- as.matrix(tree_4$frame$splits[,1][as.numeric(row.names(tree_data$labels))],nrow=1)
new_labels <- matrixPaste(as.character(tree_data$labels$label),splits,sep="\n")
tree_data$labels$label <- new_labels
t1 <- ggplot(segment(tree_data)) +geom_segment(aes(x=x, y=y, xend=xend, yend=yend),colour="blue", alpha=0.5) +theme_dendro()
t1 <- t1 +geom_text(data=label(tree_data),aes(x=x, y=y, label=label), vjust=-0.5, size=3) 
t1 <- t1 +geom_text(data=leaf_label(tree_data),aes(x=x, y=y, label=label,color=label), vjust=0.5, hjust=1, size=3,angle=90)
t1 <- t1 + scale_y_continuous(limits=c(700,1000))+theme(legend.position="none")
t1 <- t1 + scale_color_manual(values=c("#FFB300","#007856","#C3E76F","#86499D","#003359","#AFAAA3"))
pdf(file="Combined tree Diagram.pdf",width=10.5, height=8,paper="USr")
t1
dev.off()


#look at all 6 models together;

combo <- data.frame(p1=0,p2=0,p3=0,p4=0,p5=0,p6=0,segment=train$segment)
combo$p1[predict(tree_1,type=c("class"))=="Yes"]<-1
combo$p2[predict(tree_2,type=c("class"))=="Yes"]<-1
combo$p3[predict(tree_3,type=c("class"))=="Yes"]<-1
combo$p4[predict(tree_4,type=c("class"))=="Yes"]<-1
combo$p5[predict(tree_5,type=c("class"))=="Yes"]<-1
combo$p6[predict(tree_6,type=c("class"))=="Yes"]<-1
combo$count <- rowSums(combo[,1:6])

table(combo$count)
table(combo[combo$count==2,1:6])

library(plyr)
ddply(combo[combo$count==2,],c('segment','p1','p2','p3','p4','p5','p6'),function(x) {count(nrow(x))})
ties <- combo[combo$count==2,]
apply(ties[,1:6],1,function(x) match(1,x))
matrix(which(ties[,1:6]==1),nrow=dim(ties)[1],byrow=T)
ties2<- as.data.frame(t(apply(ties[,1:6],1,function(x) which(x==1))))
names(ties2) <- c("First","Second")
table(ties2)
summary1 <- ddply(ties2,c('First','Second'),function(x) {count(nrow(x))})
summary1 <- summary1[order(summary1$x,decreasing=T),]

#apply the tgie breaking rules ;
#first get first one that is zero, this will work for only one match and for the none will give N/A;
combo$predict <- apply(combo[,1:6],1,function(x) match(1,x))
#now apply the rules for the 2's;
combo$predict[combo$p1==1 & combo$p2==1 & combo$count==2] <-1
combo$predict[combo$p1==1 & combo$p4==1 & combo$count==2] <-1
combo$predict[combo$p1==1 & combo$p6==1 & combo$count==2] <-1

combo$predict[combo$p2==1 & combo$p4==1 & combo$count==2] <-2
combo$predict[combo$p2==1 & combo$p6==1 & combo$count==2] <-6

combo$predict[combo$p4==1 & combo$p5==1 & combo$count==2] <-5

#for the 3 and the 4, one ties with no clear winner I choose the first by not doing anything - same error either way

combo$pred_name <- factor(combo$predict,levels=c(1,2,3,4,5,6),labels=seg_names1)

seg_names1 <- c("Simple \n& Stable","Successful \nService-\nDependent",
  "Stable \nUnderserved","Content \n& Well Served" ,"Complex & \nExtended Mgmt.","Sophisticated &\n Demanding")
combo_table <- round((100/dim(combo)[1])*table(combo$pred_name,combo$segment,dnn=c("Predicted","Actual"),useNA="always"),1)
sum(diag(combo_table))
100*sum(table(combo$pred_name,combo$segment,dnn=c("Predicted","Actual")))/291 #this is how many I predict a non NA
100*sum(is.na(combo$pred_name))/291 #this is how many I predict an NA
combo_table2 <- table(combo$pred_name,combo$segment,dnn=c("Predicted","Actual"),useNA="always")
actuals <- colSums(combo_table2)
diag(combo_table2)<- 0
round(100*colSums(combo_table2)/actuals,1); #this is error by segment;
100-round(100*colSums(combo_table2)/actuals,1); #this is recall by segment (how many I predicted correctly);


levels(combo$segment) <- levels(chart1$actual) <- c("Simple \n& Stable","Successful \nService-\nDependent",
                                                       "Stable \nUnderserved","Content \n& Well Served" ,"Complex & \nExtended Mgmt.","Sophisticated &\n Demanding")
combo$match[combo$segment==combo$pred_name] <- "Yes" 
combo$match[combo$segment!=combo$pred_name] <- "No"
combo$match[is.na(combo$pred_name)] <- "No"

ch1a <- ggplot(data=combo,aes(x=segment,y=pred_name,color=segment,shape=match))+geom_jitter(position = position_jitter(w = 0.2, h = 0.2))
ch1a<- ch1a + theme_bw() +theme(legend.position="bottom")+ scale_color_manual(values=c("#FFB300","#007856","#C3E76F","#86499D","#003359","#AFAAA3"),name="Actual Segment")
ch1a <- ch1a + scale_shape_manual(values=c(4,19),name="Correct Prediction")+ guides(col=guide_legend(nrow=2))+ylab("Predicted")+xlab("Actual")
ch1a <- ch1a + ylab("Predicted")+xlab("Actual") +ggtitle("Combination of 6 Segment Models")+theme(plot.title = element_text(size=14,color="blue", face="bold"))


ch1a
makeFootnote_right("M&T Bank - Customer Insights")


#variable importance;

