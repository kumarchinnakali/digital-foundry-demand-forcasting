# Map 1-based optional input ports to variables
dataset1 <- maml.mapInputPort(1) # class: data.frame
dataset2 <- maml.mapInputPort(2) # class: data.frame
dataset2$error <- dataset2$MAPE_error
dataset2<-subset(dataset2,select=c("PRDCTAG", "MRKTTAG","error", "external1"))
dataset1<-subset(dataset1,select=c("PRDCTAG", "MRKTTAG","error", "external1"))
data.set = rbind(dataset1, dataset2);

# Select data.frame to be sent to the output Dataset port
maml.mapOutputPort("data.set")