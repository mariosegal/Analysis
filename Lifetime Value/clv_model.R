library("RODBC")
myconn <- odbcConnect(dsn="SASODBC",believeNRows=FALSE, colQuote=NULL)
train <- sqlQuery(myconn,"select * from clv.train_steady")
validate <- sqlQuery(myconn,"select * from clv.validate_steady")
train_non <- sqlQuery(myconn,"select * from clv.train_non")
valid_non <- sqlQuery(myconn,"select * from clv.validate_non")
odbcCloseAll()

setwd("C:/Documents and Settings/ewnym5s/My Documents/Lifetime Value")
save(train_non,file="train_non.RData")
save(valid_non,file="valid_non.RData")
names(train) <- tolower(names(train))

train$rank[train$clv_rank %in% c(0,1,2)] <- 'L'
train$rank[train$clv_rank %in% c(4,5,6,3)] <- 'M'
train$rank[train$clv_rank %in% c(7,8,9)] <- 'H'
train$rank <- factor(train$rank,levels=c('L','M','H'))

valid_non$rank[valid_non$clv_rank %in% c(0,1,2)] <- 'L'
valid_non$rank[valid_non$clv_rank %in% c(4,5,6,3)] <- 'M'
valid_non$rank[valid_non$clv_rank %in% c(7,8,9)] <- 'H'
valid_non$rank <- factor(valid_non$rank,levels=c('L','M','H'))

train$clv_rank <- as.factor(train$clv_rank)
seq <- rep_len(1:50,dim(train)[1])

library(randomForest)
set.seed(6376)
num<-14;
#try a first simple forest, to predict clv_rank;

exclude1 <- which(names(train) %in% c("hhid","clv_total","clv_rem","clv_rem_ten","age","row","rank"))
forest1a <- randomForest(clv_rank ~. , data=train[seq==14,-exclude1])

load(file="validate.Rdata")
valid_rank <- validate$clv_rank

vpred1a <- predict(forest1a,newdata=validate[1:125000,-exclude1])
vpred2a <- predict(forest1a,newdata=validate[125001:250000,-exclude1])
vpred3a <- predict(forest1a,newdata=validate[250001:375000,-exclude1])
vpred4a <- predict(forest1a,newdata=validate[375001:450000,-exclude1])
vpred5a <- predict(forest1a,newdata=validate[450001:dim(validate)[1],-exclude1])
vpred_a <- c(vpred1a,vpred2a,vpred3a,vpred4a,vpred5a)
valid_matrix <- round(100*prop.table(table(valid_rank,vpred_a,dnn=c("Actual","Predicted"))),1)
valid_matrix

save(forest1a,file="forest1a.Rdata")


#try a first simple forest, to predict rank;
setwd("C:/Documents and Settings/ewnym5s/My Documents/Lifetime Value")
load(file="train.Rdata")
set.seed(6376)
num<-14;
exclude <- which(names(train) %in% c("hhid","clv_total","clv_rem","clv_rem_ten","age","row","clv_rank"))

forest1 <- randomForest(rank ~. , data=train[seq==14,-exclude],proximity=F)


#I will try another just to see how resilient they are:
set.seed(56576)
forest2 <- randomForest(rank ~. , data=train[seq==floor(runif(1,min=1,max=50)),-exclude])

set.seed(5658)
num<-floor(runif(1,min=1,max=50))
forest3 <- randomForest(rank ~. , data=train[seq==num,-exclude])


tune3 <- tuneRF(x=train[seq==num,c(-exclude,-72)],y=train[seq==num,c(72)])
#so 8 seems fine;

#extract a sample tree;
sample_tree <- getTree(forest3,k=345,labelVar=T)

imp <- importance(forest3)
impvar <- rownames(imp)[order(imp[, 1], decreasing=TRUE)]


par(mfrow=c(3,3))
for (i in seq_along(impvar[1:9])) {
  partialPlot(forest3, rank, impvar[i], xlab=impvar[i],
              main=paste("Partial Dependence on", impvar[i]))
}
par=mfrow=c(1,1)

#try svm;
library(e1071)
exclude <- which(names(train) %in% c("hhid","clv_total","clv_rem","clv_rem_ten","age","row","clv_rank"))
set.seed(1234)
num<-floor(runif(1,min=1,max=50))
svm1 <- svm(rank ~. , data=train[seq==num,-exclude])
save(svm1,file="svm1.RData")
pred1 = predict(svm1,train[1:250000,-exclude])
pred2 = predict(svm1,train[250001:510590,-exclude])
pred <-c(pred1,pred2)

results=round((prop.table(table(pred,train$rank,dnn=c("Predicted","Actual")))*100),1)
100- (results[1,1]+results[2,2]+results[3,3])
results[1,3]+results[3,1]

load(file="train.Rdata")

myconn <- odbcConnect(dsn="SASODBC",believeNRows=FALSE, colQuote=NULL)
svm_p <- predict(svm1,newdata=validate)

svm_pred1 <- predict(svm1,newdata=validate[1:125000,-exclude])
svm_pred2 <- predict(svm1,newdata=validate[125001:250000,-exclude])
svm_pred3 <- predict(svm1,newdata=validate[250001:375000,-exclude])
svm_pred4 <- predict(svm1,newdata=validate[375001:dim(validate)[1],-exclude])
svm_pred <- c(svm_pred1,svm_pred2,svm_pred3,svm_pred4)
svm_pred <- factor(svm_pred,levels=c(1,2,3),labels=c("L","M","H"))

valid_rank <- rep(0,dim(validate)[1])

valid_rank[validate$clv_rank %in% c(0,1,2)] <- "L"
valid_rank[validate$clv_rank %in% c(4,5,6,3)] <- "M"
valid_rank[validate$clv_rank %in% c(7,8,9)] <- "H"
valid_rank <- factor(valid_rank,levels=c('L','M','H'))

valid_matrix_svm <- round(100*prop.table(table(valid_rank,svm_pred,dnn=c("Actual","Predicted"))),1)
sum(diag(valid_matrix_svm))

valid_matrix_svm[1,3]+valid_matrix_svm[3,1]

svm_pred1 <- predict(svm1,newdata=train[1:125000,-exclude])
svm_pred2 <- predict(svm1,newdata=train[125001:250000,-exclude])
svm_pred3 <- predict(svm1,newdata=train[250001:375000,-exclude])
svm_pred4 <- predict(svm1,newdata=train[375001:dim(train)[1],-exclude])
svm_pred <- c(svm_pred1,svm_pred2,svm_pred3,svm_pred4)
svm_pred <- factor(svm_pred,levels=c(1,2,3),labels=c("L","M","H"))

train_matrix_svm <- round(100*prop.table(table(train$rank,svm_pred,dnn=c("Actual","Predicted"))),1)



##############

for (i in c(12,33,45,6,29)) {
  string <- paste("select * from clv.train_steady where mod(row,",49,") = ",eval(i),sep="")
  data <- sqlQuery(myconn,query=string)
  names(data) <- tolower(names(data))
  data$clv_rank <- as.factor(data$clv_rank)
  exclude <- which(names(data) %in% c("hhid","clv_total","clv_rem","clv_rem_ten","age","row","clv_rank"))
  forest <- randomForest(clv_rank ~. , data=data[,-exclude],proximity=true)
  assign(paste("forest",i,sep=""),forest)
  gc()
}
odbcCloseAll()

save(train,file="train.Rdata")
save(validate,file="C:/Documents and Settings/ewnym5s/My Documents/validate.Rdata")
save(forest1,file="forest1.Rdata")
save(forest2,file="forest2.Rdata")
save(forest3,file="forest3.Rdata")
save(svm1,file="C:/Documents and Settings/ewnym5s/My Documents/svm1.Rdata")


######################################################################;
##############  VALIDATION       #####################################;
######################################################################;
setwd("C:/Documents and Settings/ewnym5s/My Documents/Lifetime Value")
load(file="forest3.Rdata")
load(file="forest2.Rdata")
load(file="forest1.Rdata")

final_forest <- combine(forest1,forest2,forest3)
save(final_forest,file="Final_forest.Rdata")
rm(forest1,forest2,forest3)

load(file="final_forest.Rdata")
load(file="train.Rdata")
pred1 <- predict(final_forest,newdata=train[1:125000,-exclude])
pred2 <- predict(final_forest,newdata=train[125001:250000,-exclude])
pred3 <- predict(final_forest,newdata=train[250001:375000,-exclude])
pred4 <- predict(final_forest,newdata=train[375001:dim(train)[1],-exclude])
pred <- c(pred1,pred2,pred3,pred4)
pred <- factor(pred,levels=c(1,2,3),labels=c("L","M","H"))
train_matrix <- round(100*prop.table(table(train$rank,pred,dnn=c("Actual","Predicted"))),1)
rm(train,pred,pred1,pred2,pred3,pred4)

#test versus validate;
load(file="validate.Rdata")

valid_rank <- rep(0,dim(validate)[1])

valid_rank[validate$clv_rank %in% c(0,1,2)] <- "L"
valid_rank[validate$clv_rank %in% c(4,5,6,3)] <- "M"
valid_rank[validate$clv_rank %in% c(7,8,9)] <- "H"
valid_rank <- factor(valid_rank,levels=c('L','M','H'))

vpred1 <- predict(final_forest,newdata=validate[1:125000,-exclude])
vpred2 <- predict(final_forest,newdata=validate[125001:250000,-exclude])
vpred3 <- predict(final_forest,newdata=validate[250001:375000,-exclude])
vpred4 <- predict(final_forest,newdata=validate[375001:450000,-exclude])
vpred5 <- predict(final_forest,newdata=validate[450001:dim(validate)[1],-exclude])
vpred <- c(vpred1,vpred2,vpred3,vpred4,vpred5)
vpred <- factor(vpred,levels=c(1,2,3),labels=c("L","M","H"))
valid_matrix <- round(100*prop.table(table(valid_rank,vpred,dnn=c("Actual","Predicted"))),1)

library(gridExtra)
library(vcd)
mosaic(final_matrix,main="Random Forest Performance \non Testing Dataset",pop=F,gp=gpar(cex=0.5,fill=c("lightblue","pink","lightyellow")))
labeling_cells(text = final_matrix, margin = 0)(final_matrix);

mosaic(valid_matrix,main="Random Forest Performance \non Validation Dataset",pop=F,gp=gpar(cex=0.5,fill=c("lightblue","pink","lightyellow")))
labeling_cells(text = valid_matrix, margin = 0)(valid_matrix);

                         
mosaic(final_matrix,main="Random Forest Performance \non Testing Dataset")

varImpPlot(final_forest,main="Steady State Model\n Variable Importance Chart",color="blue",cex=0.8)

#what if I add quadratic terms to the tree?

num<-14;
exclude <- which(names(train) %in% c("hhid","clv_total","clv_rem","clv_rem_ten","age","row","clv_rank"))
a<-names(train[,-exclude])
bb <- paste(a[1:64],collapse="+")

q=0

for (i in a[1:(length(a)-1)]) {
 aux = paste("+",i,"^2",sep="")
 b = paste(b,aux,sep="")
}



d <-paste(a[1:64],collapse="+")

new_data <- train[seq==num,-exclude]
names1 <- names(new_data)
q <- 65
for (i in 1:63) {
  q<-q+1
  new_data[,q] <-new_data[,i]^2
  names(new_data)[q] <- paste(names1[i],":",names1[i],sep="")
  for (j in (i+1):64) {   
    q<-q+1
    new_data[,q] <- new_data[,i]*new_data[,j]
    names(new_data)[q] <- paste(names1[i],":",names1[j],sep="")
  }
}
new_data[,q+1] <- new_data[,i]*new_data[,j]
names(new_data)[q+1] <- paste(names1[64],":",names1[64],sep="")

names(new_data) <- tolower(names(new_data))


#c<- as.formula(paste("rank ~ ",b,"+(",d,")^2","-1",sep=""))
#new_data <- as.data.frame(model.matrix(c,data=train[seq==14,-exclude]))
library(randomForest)
set.seed(6376)
seq1 <- rep_len(1:3,dim(new_data)[1])
forest1b <- randomForest(rank~., data=new_data[seq1!=1,])

####TRAIN RANDOM FOREST FOR NON STEADY ##########
train_non$rank[train_non$clv_rank %in% c(0,1,2)] <- 'L'
train_non$rank[train_non$clv_rank %in% c(4,5,6,3)] <- 'M'
train_non$rank[train_non$clv_rank %in% c(7,8,9)] <- 'H'
train_non$rank <- factor(train_non$rank,levels=c('L','M','H'))

library(randomForest)
num<-3;
seq_non <- rep_len(1:10,dim(train_non)[1])
exclude <- which(names(train_non) %in% c("hhid","clv_total","clv_rem","clv_rem_ten","age","row","clv_rank"))


for (num in 1:10) {
  set.seed(478975458)
  rf_non <- randomForest(rank ~. , data=train_non[seq_non==num,-exclude],proximity=F,ntree=501)
  assign(paste("rf_non_",num,sep=""),rf_non)
  save(rf_non,file=paste("rf_non_",num,".RData",sep=""))
  rm(list=ls(pattern="rf_non"))
}

models <- sample(1:10,3) 
models
# i got 2,4,8

for (num in c(2,4,5)) { 
load(paste("rf_non_",num,".RData",sep=""))
assign(paste("rf_non_",num,sep=""),rf_non)
}
rm(rf_non)

#I can either combine fiorst 5 or the last 5, as the Ns are different
rf_non_final <- combine(rf_non_2,rf_non_4,rf_non_5)
save(rf_non_final,file="rf_non_final.RData")

  #create the matrix for it, as it gets lost on the combine;
load("train_non.RData")
p_non <- predict(rf_non_final,newdata=train_non)
non_matrix_train <- round(100*prop.table(table(train_non$rank,p_non,dnn=c("Actual","Predicted"))),1)
sum(diag(non_matrix_train))
non_matrix_train[1,3]+non_matrix_train[3,1]
save(non_matrix_train,file="non_matrix_train.RData")

load("valid_non.RData")
p_non_valid <- predict(rf_non_final,newdata=valid_non)
non_matrix_valid <- round(100*prop.table(table(valid_non$rank,p_non_valid,dnn=c("Actual","Predicted"))),1)
sum(diag(non_matrix_valid))
non_matrix_valid[1,3]+non_matrix_valid[3,1]
save(non_matrix_valid,file="non_matrix_valid.RData")

library(gridExtra)
library(vcd)
mosaic(non_matrix_train,main="Non-Steady State Random Forest Performance \non Training Dataset",pop=F,gp=gpar(cex=0.5,fill=c("lightblue","pink","lightyellow")))
labeling_cells(text = non_matrix_train, margin = 0)(non_matrix_train);

mosaic(non_matrix_valid,main="Non-Steady State Random Forest Performance \non Validation Dataset",pop=F,gp=gpar(cex=0.5,fill=c("lightblue","pink","lightyellow")))
labeling_cells(text = non_matrix_valid, margin = 0)(non_matrix_valid);
varImpPlot(rf_non_final,main="Non-Steady State Model\n Variable Importance Chart",color="blue",cex=0.8)
