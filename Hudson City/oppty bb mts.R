library(ggplot2)
library(plyr)
library(xlsx)

#read data from excel
oppty <- read.xlsx("C:\\Documents and Settings\\ewnym5s\\My Documents\\Hudson City\\Branch Opportunity BB and MTS.xlsx",sheetIndex=1,as.data.frame=T)

# do a cahrt of bb oppty vs. affluent oppty;
pdf("C:/Documents and Settings/ewnym5s/My Documents/Hudson City/Branch Oppty BB and MTS.pdf",paper="USr",width=10,height=6.5)
plot <- ggplot(oppty,aes(x=affl_index,y=bb_total_index,colour=State))+theme_bw()+ggtitle("Hudson City Branch Opportunity\n Securities and Business Banking")
plot <- plot +theme(plot.title=element_text(face="bold",size=16,color="blue"))
plot <- plot + geom_hline(aes(yintercept=70),colour="red",linetype="dashed") + geom_vline(aes(xintercept=70),colour="blue",linetype="dashed")
plot <- plot + geom_hline(aes(yintercept=130),colour="red",linetype="dashed") + geom_vline(aes(xintercept=130),colour="blue",linetype="dashed")
plot <- plot +  scale_x_continuous(limits=c(0,400))+ scale_y_continuous(limits=c(0,400))
plot <- plot + xlab("Business Banking Opportunity")+ylab("Affluent (Over $1MM in Assets) Opportunity")
plot <- plot + theme(axis.title.x=element_text(face="bold",size=11),axis.title.y=element_text(face="bold",size=11))
plot <- plot + geom_point(alpha=0.8,size=I(3),shape=I(19))+theme(legend.position="bottom")
plot
dev.off()

oppty$maf <- "X"
oppty$maf[oppty$mass_affl_index<=70]<- "Low"
oppty$maf[oppty$mass_affl_index>70 & oppty$mass_affl_index<=130]<- "Medium"
oppty$maf[oppty$mass_affl_index>130]<- "High"
oppty$maf <- as.factor(oppty$maf)
oppty$maf <- factor(c("Low Mass Aff","Med Mass Affl","High Mass Affl"),levels=c("Low Mass Aff","Med Mass Affl","High Mass Affl"),ordered=T)

pdf("C:/Documents and Settings/ewnym5s/My Documents/Hudson City/Branch Oppty BB and MTS v2.pdf",paper="USr",width=10,height=6.5)
plot<-plot+facet_grid(~maf,labeller=label_value)
plot
dev.off()

oppty$mains <- cut(oppty$mainstream_index,c(0,70,130,max(oppty$mainstream_index)),labels=c("Low Mainst","Med Mainst","High Mainst"))
ddply(oppty,.(mains),summarize,min(mainstream_index),max(mainstream_index))

pdf("C:/Documents and Settings/ewnym5s/My Documents/Hudson City/Branch Oppty BB and MTS v3.pdf",paper="USr",width=10,height=6.5)
plot<-plot+facet_grid(mains~maf,as.table=F,labeller=label_wrap_gen(width=10))
plot
dev.off()

oppty$affl <- cut(oppty$affl_index,c(0,70,130,max(oppty$affl_index)),labels=c("Low Affl","Med Affl","High Affl"))
ddply(oppty,.(affl),summarize,min(affl_index),max(affl_index))


pdf("C:/Documents and Settings/ewnym5s/My Documents/Hudson City/Branch Oppty BB and MTS v4.pdf",paper="USr",width=10,height=6.5)
plot <- ggplot(oppty,aes(x=mass_affl_index,y=bb_total_index,colour=State))+theme_bw()+ggtitle("Hudson City Branch Opportunity\n Securities and Business Banking")
plot <- plot +theme(plot.title=element_text(face="bold",size=16,color="blue"))
plot <- plot + geom_hline(aes(yintercept=70),colour="red",linetype="dashed") + geom_vline(aes(xintercept=70),colour="blue",linetype="dashed")
plot <- plot + geom_hline(aes(yintercept=130),colour="red",linetype="dashed") + geom_vline(aes(xintercept=130),colour="blue",linetype="dashed")
plot <- plot +  scale_x_continuous(limits=c(0,400))+ scale_y_continuous(limits=c(0,400))
plot <- plot + xlab("Business Banking Opportunity")+ylab("Mass Affluent ($100M to $1MM in Assets) Opportunity")
plot <- plot + theme(axis.title.x=element_text(face="bold",size=11),axis.title.y=element_text(face="bold",size=11))
plot <- plot + geom_point(alpha=0.8,size=I(3),shape=I(19))+theme(legend.position="bottom")
plot<-plot+facet_grid(mains~affl,as.table=F,labeller=label_wrap_gen(width=10))
plot
makeFootnote_left("Source: MCD - Customer Insights Analysis")
makeFootnote_right("Confidential")
dev.off()




makeFootnote <- function(footnoteText=
                           format(Sys.time(), "%d %b %Y"),
                         size= .7,color="black")
{
  require(grid)
  pushViewport(viewport())
  grid.text(label= footnoteText ,
            x = unit(1,"npc") - unit(2, "mm"),
            y= unit(2, "mm"),
            just=c("right", "bottom"),
            gp=gpar(cex= size, col=color))
  popViewport()
}

label_wrap_gen <- function(width = 25) {
  function(variable, value) {
    lapply(strwrap(as.character(value), width=width, simplify=FALSE), 
           paste, collapse="\n")
  }
}

label_wrap <- function(variable, value) {
  lapply(strwrap(as.character(value), width=25, simplify=FALSE), 
         paste, collapse="\n")
}  

makeFootnote_left <- function(footnoteText=
                           format(Sys.time(), "%d %b %Y"),
                         size= 0.8, color= "black")
{
  require(grid)
  pushViewport(viewport())
  grid.text(label= footnoteText ,
            x = unit(0.02,"npc"),
            y= unit(0.02, "npc"),
            just=c("left", "bottom"),
            gp=gpar(cex= size, col=color))
  popViewport()
}

makeFootnote_right <- function(footnoteText=
                                format(Sys.time(), "%d %b %Y"),
                              size= 0.8, color= "black")
{
  require(grid)
  pushViewport(viewport())
  grid.text(label= footnoteText ,
            x = unit(.98,"npc"),
            y= unit(0.02, "npc"),
            just=c("right", "bottom"),
            gp=gpar(cex= size, col=color))
  popViewport()
}
