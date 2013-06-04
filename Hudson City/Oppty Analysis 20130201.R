library(ggplot2)
library(plyr)

#read data from excel
hudson <- read.xlsx("C:\\Documents and Settings\\ewnym5s\\My Documents\\Hudson City\\Data_for_branch_oppty.xlsx",
                     sheetIndex=1,as.data.frame=T)

# do some massaging and data prep

hudson$Branch <- as.factor(hudson$Branch)
# hudson$Business.Grade <- ordered(hudson$Business.Grade,c("L","M","H"))
# hudson$Affluent.Grade <- ordered(hudson$Affluent.Grade,c("L","M","H"))
hudson$Business.Grade <- factor(hudson$Business.Grade,levels=c("L","M","H"),labels=c("Low Bus Oppty","Med Bus Oppty","High Bus Oppty"))
hudson$Affluent.Grade <- factor(hudson$Affluent.Grade,levels=c("L","M","H"),labels=c("Low Affluent Oppty","Med Affluent Oppty","High Affluent Oppty"))

#define fucntion for lasbeller
a <- summary(hudson$Affluent.Grade)
b <- round(100*(a/sum(a)),1)
c <- summary(hudson$Business.Grade)
d <- round(100*(c/sum(a)),1)
e<- aggregate(x=hudson[,c(5,8)],by=list(hudson$Affluent.Grade,hudson$Business.Grade),FUN="length")[,1:3]
names(e) <- c("Affluent.Grade","Business.Grade","count")
percent<-round(100*e$count/sum(e$count),1)
State<- rep("",9)   #assign any state, somehow it expects it on the dataset
e <- cbind(e,percent,State)
hudson.n <- ddply(.data=hudson,.(Business.Grade,Affluent.Grade),summarize,n=paste("N= ",length(Branch)," (",round(100*length(Branch)/dim(hudson)[1],1),"%)  ",sep=""))

label1 <- function(var,value) {
        if (var=="Affluent.Grade") {
          lab1 <- paste(value," (N=",a[value],", ",b[value],"% )",sep="")}
        else if (var=="Business.Grade") {
          lab1<- paste(value," (N=",c[value],", ",d[value],"% )",sep="")}
           lab2 <- lapply(strwrap(as.character(lab1), width=25, simplify=FALSE), paste, collapse="\n")
        
        return(lab2)
}
        


#do the charts;

ylab<- "Mass Affluent Opportunity Index"
xlab <- "Mainstream Opportunity Index"
main="Hudson City Branch Opportunity Analysis"
rm(p)
pdf("./Hudson City/Branch Opportunity.pdf",onefile=T,paper="USr",width=10,height=7.5)
p <- qplot(x=Mainstream,y=Mass.Affluent,data=hudson,ylab=ylab,xlab=xlab,main=main,color=State,geom="jitter")
p <- p+geom_vline(xintercept= 100,colour="red", linetype = "dashed")+geom_hline(yintercept= 100,colour="red", linetype = "dashed")
p <- p +theme(axis.title.x = element_text(face="bold", size=14),axis.title.y  = element_text(face="bold", size=14),
              plot.title = element_text(face="bold", size=20,color="blue"),
              strip.text.x = element_text(face="bold",size=12),strip.text.y = element_text(face="bold",size=12))

p <- p+ facet_grid(Business.Grade~Affluent.Grade,labeller=label1)
p <- p + geom_text(data=hudson.n,aes(x=400,y=20,label=n,size=11,face="bold"),inherit.aes=F,show_guide=F)+theme_bw()

p
dev.off()
p #also print to console
#+geom_point(colour =  "#007856", size = 2)
#+theme(legend.position = "none")

geom_annotate(aes(400, 20, label=paste("N=",count,"(",percent,"%)",sep=""), group=NULL,size=9,color="black",show_guide=FALSE),data=e)  
