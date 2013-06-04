library("RODBC")
myconn <- odbcConnect(dsn="SASODBC",believeNRows=FALSE, colQuote=NULL)
train <- sqlQuery(myconn,"select * from clv.train_steady_small")
odbcCloseAll()

names(train) <-tolower(names(train))
train <- train[,c(34,1:33,35:69)]
train <- train[,c(-2)]

library(car)
fit1 <- lm(clv_total ~.,data=train[,c(-7,-18,-36,-37)])
par(mfrow=c(2,2))
plot(fit1)
vif(fit1)

#R identified some relaetd variables, i will drop those (they ahve NA in summary)
fit2 <- lm(clv_total ~.,data=train[,c(-7,-18,-36,-37,-47,-56,-61,-62,-63,-68)])
summary(fit2)
par(mfrow=c(2,2))
plot(fit2)
vif(fit2)
vif2<- sqrt(vif(fit2))>2

fit3 <- lm(clv_total ~.,data=train[,c(-7,-18,-36,-37,-47,-56,-61,-62,-63,-68,-23,-40,-59,-57,-58,-60)])
summary(fit3)
par(mfrow=c(2,2))
plot(fit3)
vif(fit3)
sqrt(vif(fit3))
max(sqrt(vif(fit3)))

data <- train[train$clv_total > 0,c(-7,-18,-36,-37,-47,-56,-61,-62,-63,-68,-23,-40,-59,-57,-58,-60,-69)]

fit4 <- lm(log(clv_total) ~.,data=data)
summary(fit4)
par(mfrow=c(2,2))
plot(fit4)
vif(fit4)
sqrt(vif(fit4))
max(sqrt(vif(fit4)))
par(mfrow=c(1,1))
qqPlot(fit4)



#this is not working, I mean the modeling is working but not predicitng sufficiently

library(leaps)
leaps <- regsubsets(log(clv_total) ~.,data=data,nbest=2,really.big=T)
par(mfrow=c(1,1))
plot(leaps,scale="adjr2")

train$log_clv <- log(train$clv_total)
train1 <- train[complete.cases(train),]
train1 <- train1[!is.infinite(train1$log_clv),]

fit_log1 <- lm(log_clv ~.,data=train1[,c(-1,-7,-18,-36,-37,-47,-56,-61,-62,-63,-68,-23,-40,-59,-57,-58,-60)])
par(mfrow=c(2,2))
plot(fit_log1)

ggplot(data=train,aes(x=clv_total))+geom_histogram()
logclv <- data.frame(logclv=log(train$clv_total))
ggplot(data=logclv,aes(x=logclv))+geom_histogram()

library(reshape)
library(ggplot2)
ggplot(data=train,aes(x=dda_amt,y=clv_total))+geom_jitter()+scale_x_continuous(limits=c(0,200000))+stat_smooth()

chartdata <- melt(train[,c(1,13:22)],id.vars=c("clv_total"))

p<- ggplot(data=chartdata,aes(x=value,y=clv_total))+geom_jitter()+scale_x_continuous(limits=c(0,25000))
p<- p+stat_smooth()+facet_wrap(~variable,ncol=3)+scale_y_continuous(limits=c(0,10000))
p