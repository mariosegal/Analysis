
modeling <- read.csv("C:/Documents and Settings/ewnym5s/My Documents/Hudson City/modeling.csv")
modeling[is.na(modeling["IXI_tot"]),"IXI_tot"]<-colMeans(modeling["IXI_tot"],na.rm=T)

rand1 <- sample(1:1000000,size=100000)
mydata <- modeling[rand1,]
rm(modeling)

fit <- lm(contrib ~ dda + mms + sav + tda + ira + mtg + ILN + heq + deposits + DDA_Amt + MMS_amt + sav_amt + TDA_Amt +
            IRA_amt + MTG_amt + HEQ_Amt + iln_amt + cqi_DD  + both + dep_amt + loan_amt + both_amt + 
            loans + deposits +s1 +s3 +s4+ s5+ s6+s7 +ixi_new,data=mydata)
step <- stepAIC(fit, direction="both")
step$anova # display results

#contrib ~ dda + mms + sav + tda + ira + mtg + ILN + heq + deposits + DDA_Amt + MMS_amt + sav_amt + TDA_Amt +
#  IRA_amt + MTG_amt + HEQ_Amt + iln_amt + cqi_DD + A + B + C + D + E + both + dep_amt + loan_amt + both_amt + 
#  loans + deposits +s1 +s3 +s4+ s5+ s6+s7 +ixi_newrm


# All Subsets Regression
library(leaps)
attach(mydata)
leaps<-regsubsets(contrib ~ dda + mms + sav + tda + ira + mtg + ILN + heq + deposits + DDA_Amt + MMS_amt + sav_amt + TDA_Amt +
                    IRA_amt + MTG_amt + HEQ_Amt + iln_amt + cqi_DD  + both + dep_amt + loan_amt + both_amt + 
                    loans + deposits +s1 +s3 +s4+ s5+ s6+s7 +ixi_new,data=mydata,nbest=10)
# view results 
summary(leaps)
# plot a table of models showing variables in each model.
# models are ordered by the selection statistic.
plot(leaps,scale="r2")
# plot statistic by subset size 
library(car)
subsets(leaps, statistic="rsq")