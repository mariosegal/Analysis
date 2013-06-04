setwd("C:/Documents and Settings/ewnym5s/My Documents/ATM")
data <- read.table("matrix_data.txt",header=T,sep=",")

data$avg <- factor(data$avg,levels= c("Under 1 mile","1 to 2 Miles","2 to 3 Miles","3 to 4 Miles","4 to 5 Miles" ,  "5 to 7.5 Miles","7.5 to 10 Miles","10 to 15 Miles","15 to 20 Miles","20 to 50 Miles","Over 50 Miles"))
data$max <- factor(data$max,levels= c("Under 1 mile","1 to 2 Miles","2 to 3 Miles","3 to 4 Miles","4 to 5 Miles" ,  "5 to 7.5 Miles","7.5 to 10 Miles","10 to 15 Miles","15 to 20 Miles","20 to 50 Miles","Over 50 Miles"))
data$hh <- data$N

#if I want the transactions;
high <- with(data[data$group=="High Sheetz Dependency",], tapply(N, list(avg, max), sum,na.rm=T))
med <- with(data[data$group=="Moderate Sheetz Dependency",], tapply(N, list(avg, max), sum,na.rm=T))
low <- with(data[data$group=="Limited Sheetz Usage",], tapply(N, list(avg, max), sum,na.rm=T))

library(ggplot2)
library(scales)
p <- ggplot(data=data[data$group=="High Sheetz Dependency",],aes(x=max,y=avg,size=hh))+theme_bw()
p <- p + geom_point(shape=16,color="#FFB300") 
p <- p+ scale_size(range = c(2, 20),labels = comma,name="Number of HHs")
p <- p+theme(legend.position="bottom",axis.title.x = element_text(face="bold"),axis.title.y = element_text(face="bold"))
p <- p+xlab("Maximum Distance to Nearest Non-Sheetz Alternative")+ylab("Average Distance to Nearest Non-Sheetz Alternative")
p

p <- ggplot(data=data[data$group=="Moderate Sheetz Dependency",],aes(x=max,y=avg,size=hh))+theme_bw()
p <- p + geom_point(shape=16,color="#7AB800") 
p <- p+ scale_size(range = c(2, 20),labels = comma,name="Number of HHs")
p <- p+theme(legend.position="bottom",axis.title.x = element_text(face="bold"),axis.title.y = element_text(face="bold"))
p <- p+xlab("Maximum Distance to Nearest Non-Sheetz Alternative")+ylab("Average Distance to Nearest Non-Sheetz Alternative")
p

p <- ggplot(data=data[data$group=="Limited Sheetz Usage",],aes(x=max,y=avg,size=hh))+theme_bw()
p <- p + geom_point(shape=16,color="#007856") 
p <- p+ scale_size(range = c(2, 20),labels = comma,name="Number of HHs")
p <- p+theme(legend.position="bottom",axis.title.x = element_text(face="bold"),axis.title.y = element_text(face="bold"))
p <- p+xlab("Maximum Distance to Nearest Non-Sheetz Alternative")+ylab("Average Distance to Nearest Non-Sheetz Alternative")
p