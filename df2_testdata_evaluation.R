
# Map 1-based optional input ports to variables
dataset1 <- maml.mapInputPort(1) # class: data.frame
dataset1$Accuracy <- (100- dataset1$error)
datasub <- subset(dataset1, select=c("PRDCTAG", "MRKTTAG","Accuracy"))
library(reshape2)
dataset2<- dcast(datasub, PRDCTAG ~ MRKTTAG)
#dataset2<- data.frame(dataset2)
# Select data.frame to be sent to the output Dataset port
maml.mapOutputPort("dataset2");